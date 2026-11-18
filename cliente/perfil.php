<?php
require_once __DIR__.'/../config/conexao.php';
require_once __DIR__.'/../config/entrega.php';
verificarAcesso('cliente');
$id=(int)$_SESSION['usuario']['id_usuario'];
$pdo=db();
$msg='';$error='';$activeSection=$_GET['secao']??'perfil';
$sections=['perfil','pedidos','aprovacoes','enderecos','cupons','entregas','notificacoes','configuracoes'];
if(!in_array($activeSection,$sections,true))$activeSection='perfil';

if($_SERVER['REQUEST_METHOD']==='POST'){
    validarCsrf();
    $action=$_POST['acao']??'';
    try{
        if($action==='perfil'){
            $name=trim($_POST['nome']??'');$email=filter_var(trim($_POST['email']??''),FILTER_VALIDATE_EMAIL);$phone=trim($_POST['telefone']??'');
            if($name===''||mb_strlen($name)>100||!$email)throw new RuntimeException('Informe seu nome e um e-mail válido.');
            $birthDate=trim($_POST['data_nascimento']??'');$birthForDb=null;
            if($birthDate!==''){$birth=DateTimeImmutable::createFromFormat('!Y-m-d',$birthDate);$dateErrors=DateTimeImmutable::getLastErrors();if(!$birth||($dateErrors&&($dateErrors['warning_count']||$dateErrors['error_count']))||$birth->format('Y-m-d')!==$birthDate||$birth>new DateTimeImmutable('today'))throw new RuntimeException('Informe uma data de nascimento válida.');$birthForDb=$birthDate;}
            $q=$pdo->prepare('UPDATE usuarios SET nome=?,email=?,telefone=?,data_nascimento=? WHERE id_usuario=?');
            $q->execute([$name,$email,$phone,$birthForDb,$id]);
            $_SESSION['usuario']['nome']=$name;$_SESSION['usuario']['email']=$email;
            $msg='Seus dados foram atualizados.';$activeSection='perfil';
        }elseif($action==='foto'){
            $file=$_FILES['foto_perfil']??null;
            if(!$file||$file['error']!==UPLOAD_ERR_OK)throw new RuntimeException('Selecione uma foto para enviar.');
            if($file['size']>5*1024*1024)throw new RuntimeException('A foto deve ter no máximo 5 MB.');
            $imageInfo=@getimagesize($file['tmp_name']);
            $finfo=new finfo(FILEINFO_MIME_TYPE);$mime=$finfo->file($file['tmp_name']);
            $extensions=['image/jpeg'=>'jpg','image/png'=>'png','image/webp'=>'webp'];
            if(!$imageInfo||!isset($extensions[$mime]))throw new RuntimeException('Envie uma imagem JPG, PNG ou WebP válida.');
            if($imageInfo[0]>6000||$imageInfo[1]>6000)throw new RuntimeException('A imagem deve ter até 6000 × 6000 pixels.');
            $directory=__DIR__.'/../assets/uploads/perfil';
            if(!is_dir($directory)&&!mkdir($directory,0755,true)&&!is_dir($directory))throw new RuntimeException('Não foi possível preparar o armazenamento da foto.');
            $filename='cliente-'.$id.'-'.bin2hex(random_bytes(12)).'.'.$extensions[$mime];
            if(!move_uploaded_file($file['tmp_name'],$directory.'/'.$filename))throw new RuntimeException('Não foi possível salvar a foto. Tente novamente.');
            $relative='/assets/uploads/perfil/'.$filename;
            $q=$pdo->prepare('SELECT foto_perfil FROM usuarios WHERE id_usuario=?');$q->execute([$id]);$previous=$q->fetchColumn();
            $pdo->prepare('UPDATE usuarios SET foto_perfil=? WHERE id_usuario=?')->execute([$relative,$id]);
            if(is_string($previous)&&preg_match('~^/assets/uploads/perfil/cliente-'.preg_quote((string)$id,'~').'-[a-f0-9]+\.(jpg|png|webp)$~',$previous)){
                $oldFile=__DIR__.'/../assets/uploads/perfil/'.basename($previous);if(is_file($oldFile))@unlink($oldFile);
            }
            $msg='Foto de perfil atualizada.';$activeSection='perfil';
        }elseif($action==='senha'){
            $q=$pdo->prepare('SELECT senha FROM usuarios WHERE id_usuario=?');$q->execute([$id]);$hash=$q->fetchColumn();
            $current=$_POST['senha_atual']??'';$new=$_POST['senha_nova']??'';$confirm=$_POST['senha_confirmacao']??'';
            if(!$hash||!password_verify($current,$hash))throw new RuntimeException('A senha atual não confere.');
            if(strlen($new)<8||$new!==$confirm)throw new RuntimeException('A nova senha deve ter pelo menos 8 caracteres e as confirmações precisam ser iguais.');
            $pdo->prepare('UPDATE usuarios SET senha=? WHERE id_usuario=?')->execute([password_hash($new,PASSWORD_DEFAULT),$id]);
            $msg='Senha alterada com sucesso.';$activeSection='configuracoes';
        }elseif($action==='aprovacao'){
            $item=(int)($_POST['item']??0);$approved=($_POST['resposta']??'')==='aprovar';
            $q=$pdo->prepare("SELECT i.id_item,i.id_pedido FROM itens_pedido i JOIN pedidos p USING(id_pedido) WHERE i.id_item=? AND p.id_cliente=? AND p.status='aguardando_aprovacao'");
            $q->execute([$item,$id]);$line=$q->fetch();
            if(!$line)throw new RuntimeException('Esta aprovação já foi respondida ou não está disponível.');
            $pdo->prepare('INSERT INTO respostas_item(id_item,cliente_aprovou,respondido_em) VALUES(?,?,NOW()) ON DUPLICATE KEY UPDATE cliente_aprovou=VALUES(cliente_aprovou),respondido_em=NOW()')->execute([$item,$approved?1:0]);
            if(!$approved)$pdo->prepare("UPDATE itens_pedido SET status_item='em_falta' WHERE id_item=?")->execute([$item]);
            $pdo->prepare("UPDATE pedidos SET status='em_separacao' WHERE id_pedido=? AND id_cliente=? AND status='aguardando_aprovacao'")->execute([(int)$line['id_pedido'],$id]);
            $msg=$approved?'Substituição aprovada.':'Item recusado e removido do pedido.';$activeSection='aprovacoes';
        }elseif($action==='endereco'){
            $cep=preg_replace('/\D/','',$_POST['cep']??'');
            $street=trim($_POST['logradouro']??'');$number=trim($_POST['numero']??'');$district=trim($_POST['bairro']??'');$city=trim($_POST['cidade']??'');
            if(!preg_match('/^\d{8}$/',$cep)||$street===''||$number===''||$district===''||$city==='')throw new RuntimeException('Preencha todos os campos com um CEP válido.');
            $served=opcoesFretePorCep($pdo,$cep,true)['entrega_disponivel'];
            $pdo->prepare('INSERT INTO enderecos(id_usuario,logradouro,numero,bairro,cidade,cep,atendido) VALUES(?,?,?,?,?,?,?)')->execute([$id,$street,$number,$district,$city,$cep,$served?1:0]);
            $msg=$served?'Endereço adicionado à sua conta.':'Endereço salvo, mas o CEP está fora da área de entrega.';$activeSection='enderecos';
        }elseif($action==='resgatar_cupom'){
            $code=strtoupper(trim($_POST['codigo_cupom']??''));
            $q=$pdo->prepare('SELECT id_cupom FROM cupons WHERE codigo=? AND ativo=1 AND (validade IS NULL OR validade>=CURRENT_DATE) AND (limite_usos IS NULL OR usos<limite_usos)');$q->execute([$code]);$couponId=(int)$q->fetchColumn();
            if(!$couponId)throw new RuntimeException('Cupom inválido, expirado ou sem usos disponíveis.');
            $q=$pdo->prepare('INSERT IGNORE INTO cupons_clientes(id_usuario,id_cupom) VALUES(?,?)');$q->execute([$id,$couponId]);
            if(!$q->rowCount())throw new RuntimeException('Você já adicionou esse cupom à sua conta.');
            $msg='Cupom adicionado à sua conta. Você poderá selecioná-lo no checkout.';$activeSection='cupons';
        }elseif($action==='cancelar'){
            $orderId=(int)($_POST['pedido']??0);$q=$pdo->prepare("SELECT id_cupom FROM pedidos WHERE id_pedido=? AND id_cliente=? AND status='pendente'");$q->execute([$orderId,$id]);$couponId=$q->fetchColumn();
            $q=$pdo->prepare("UPDATE pedidos SET status='cancelado' WHERE id_pedido=? AND id_cliente=? AND status='pendente'");$q->execute([$orderId,$id]);
            if($q->rowCount()&&$couponId){$pdo->prepare('UPDATE cupons_clientes SET id_pedido=NULL,usado_em=NULL WHERE id_usuario=? AND id_cupom=? AND id_pedido=?')->execute([$id,(int)$couponId,$orderId]);$pdo->prepare('UPDATE cupons SET usos=GREATEST(usos-1,0) WHERE id_cupom=?')->execute([(int)$couponId]);}
            $msg=$q->rowCount()?'Pedido cancelado.':'Só é possível cancelar pedidos pendentes.';$activeSection='pedidos';
        }
    }catch(Throwable $e){$error=$e instanceof RuntimeException?$e->getMessage():'Não foi possível salvar as alterações. Verifique se o e-mail já está sendo usado.';$activeSection=$action==='senha'?'configuracoes':($action==='aprovacao'?'aprovacoes':'perfil');}
}

$q=$pdo->prepare('SELECT id_usuario,nome,email,telefone,data_nascimento,foto_perfil,data_cadastro FROM usuarios WHERE id_usuario=?');$q->execute([$id]);$customer=$q->fetch();
$q=$pdo->prepare('SELECT * FROM enderecos WHERE id_usuario=? ORDER BY id_endereco DESC');$q->execute([$id]);$addresses=$q->fetchAll();
$firstAddress=$addresses[0]??null;
$q=$pdo->prepare('SELECT p.*,e.logradouro,e.numero,e.bairro,e.cidade,e.cep FROM pedidos p LEFT JOIN enderecos e USING(id_endereco) WHERE p.id_cliente=? ORDER BY p.data_criacao DESC');$q->execute([$id]);$orders=$q->fetchAll();
$q=$pdo->prepare("SELECT i.id_item,i.qtd_solicitada,i.qtd_separada,i.preco_aplicado,i.status_item,p.nome produto,o.id_pedido,o.data_criacao FROM itens_pedido i JOIN pedidos o USING(id_pedido) JOIN produtos p USING(id_produto) LEFT JOIN respostas_item r USING(id_item) WHERE o.id_cliente=? AND o.status='aguardando_aprovacao' AND r.cliente_aprovou IS NULL ORDER BY o.data_criacao DESC");$q->execute([$id]);$approvals=$q->fetchAll();
$q=$pdo->prepare("SELECT COUNT(*) FROM pedidos WHERE id_cliente=? AND status IN ('pronto','em_transito')");$q->execute([$id]);$deliveries=(int)$q->fetchColumn();
$q=$pdo->prepare("SELECT COUNT(*) FROM pedidos WHERE id_cliente=? AND status='entregue'");$q->execute([$id]);$completedPurchases=(int)$q->fetchColumn();
$q=$pdo->prepare('SELECT c.* FROM cupons c LEFT JOIN cupons_clientes cc ON cc.id_cupom=c.id_cupom AND cc.id_usuario=? WHERE c.ativo=1 AND (c.validade IS NULL OR c.validade>=CURRENT_DATE) AND (c.limite_usos IS NULL OR c.usos<c.limite_usos) AND cc.id_cupom IS NULL ORDER BY c.validade IS NULL,c.validade,c.codigo');$q->execute([$id]);$availableCoupons=$q->fetchAll();
$q=$pdo->prepare('SELECT c.*,cc.usado_em FROM cupons_clientes cc JOIN cupons c USING(id_cupom) WHERE cc.id_usuario=? ORDER BY cc.resgatado_em DESC');$q->execute([$id]);$myCoupons=$q->fetchAll();
$notificationOrders=array_values(array_filter($orders,fn($o)=>in_array($o['status'],['aguardando_aprovacao','em_transito','problema'],true)));
$notificationCount=count($notificationOrders);
$countOrders=count($orders);$countApprovals=count($approvals);$countAddresses=count($addresses);
function profileDate(?string $date):string{return $date?date('d/m/Y',strtotime($date)):'—';}
?>
<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Meu perfil · Alvorada</title><link rel="stylesheet" href="/assets/css/style.css?v=26"></head>
<body class="profile-body">
<div class="profile-app">
    <aside class="profile-sidebar">
        <a href="/" class="profile-logo"><img src="/assets/images/alvorada-logo.png?v=1" alt="Supermercado Alvorada"></a>
        <nav class="profile-nav" aria-label="Área do cliente">
            <a class="<?=$activeSection==='perfil'?'is-active':''?>" href="#perfil"><span class="profile-nav-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="8" r="4"/><path d="M4.5 21a7.5 7.5 0 0 1 15 0"/></svg></span>Meu Perfil</a>
            <a class="<?=$activeSection==='pedidos'?'is-active':''?>" href="#pedidos"><span class="profile-nav-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M6 3.5h9l4 4V21H6z"/><path d="M14 3.5V8h5M9 12h7M9 16h7"/></svg></span>Meus Pedidos <?php if($countOrders>0):?><b><?=$countOrders?></b><?php endif;?></a>
            <a class="<?=$activeSection==='aprovacoes'?'is-active':''?>" href="#aprovacoes"><span class="profile-nav-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="m8 12 2.5 2.5L16.5 9"/></svg></span>Aprovações Pendentes <?php if($countApprovals>0):?><b><?=$countApprovals?></b><?php endif;?></a>
            <a class="<?=$activeSection==='enderecos'?'is-active':''?>" href="#enderecos"><span class="profile-nav-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M19 10c0 5-7 11-7 11S5 15 5 10a7 7 0 1 1 14 0Z"/><circle cx="12" cy="10" r="2.3"/></svg></span>Endereços Salvos <?php if($countAddresses>0):?><b><?=$countAddresses?></b><?php endif;?></a>
            <a class="<?=$activeSection==='cupons'?'is-active':''?>" href="#cupons"><span class="profile-nav-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M4 7.5A2.5 2.5 0 0 0 6.5 5h11A2.5 2.5 0 0 0 20 7.5v2a2.5 2.5 0 0 0 0 5v2a2.5 2.5 0 0 0-2.5 2.5h-11A2.5 2.5 0 0 0 4 16.5v-2a2.5 2.5 0 0 0 0-5z"/><path d="m9 14 6-6M9 8h.01M15 14h.01"/></svg></span>Cupons & Fidelidade</a>
            <a class="<?=$activeSection==='entregas'?'is-active':''?>" href="#entregas"><span class="profile-nav-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M16 3v4M8 3v4M3 10h18M8 14h3M8 17h7"/></svg></span>Entregas Agendadas <?php if($deliveries>0):?><b><?=$deliveries?></b><?php endif;?></a>
            <a class="<?=$activeSection==='notificacoes'?'is-active':''?>" href="#notificacoes"><span class="profile-nav-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9M10 21h4"/></svg></span>Notificações <?php if($notificationCount>0):?><b><?=$notificationCount?></b><?php endif;?></a>
            <a class="<?=$activeSection==='configuracoes'?'is-active':''?>" href="#configuracoes"><span class="profile-nav-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M12 8.5a3.5 3.5 0 1 0 0 7 3.5 3.5 0 0 0 0-7Z"/><path d="m19.4 15 .1.1a1.8 1.8 0 1 1-2.5 2.5l-.1-.1a1.8 1.8 0 0 0-3 .9v.2a1.8 1.8 0 1 1-3.6 0v-.2a1.8 1.8 0 0 0-3-.9l-.1.1a1.8 1.8 0 1 1-2.5-2.5l.1-.1a1.8 1.8 0 0 0-.9-3H3.8a1.8 1.8 0 1 1 0-3.6H4a1.8 1.8 0 0 0 .9-3l-.1-.1a1.8 1.8 0 1 1 2.5-2.5l.1.1a1.8 1.8 0 0 0 3-.9v-.2a1.8 1.8 0 1 1 3.6 0V2a1.8 1.8 0 0 0 3 .9l.1-.1a1.8 1.8 0 1 1 2.5 2.5l-.1.1a1.8 1.8 0 0 0 .9 3h.2a1.8 1.8 0 1 1 0 3.6H20a1.8 1.8 0 0 0-.6 3Z" transform="translate(0 2) scale(.9)"/></svg></span>Configurações</a>
        </nav>
        <a class="profile-back-store" href="/">← Voltar à loja</a>
    </aside>
    <main class="profile-main">
        <header class="profile-topbar"><div><span>ÁREA DO CLIENTE</span><h1>Meu Perfil</h1></div><a href="#pedidos" class="profile-search-link">Acompanhar pedidos <span>→</span></a></header>
        <?php if($msg):?><div class="notice success" role="status"><?=h($msg)?></div><?php endif;?>
        <?php if($error):?><div class="notice" role="alert"><?=h($error)?></div><?php endif;?>
<section class="profile-card profile-overview" id="perfil">
            <div class="profile-avatar"><?php if(!empty($customer['foto_perfil'])):?><img src="<?=h($customer['foto_perfil'])?>" alt="Foto de perfil de <?=h($customer['nome'])?>"><?php else:?><?=h(mb_strtoupper(mb_substr($customer['nome']??'C',0,1)))?><?php endif;?></div>
            <div class="profile-overview-copy"><span class="profile-eyebrow">CONTA ALVORADA</span><h2><?=h($customer['nome'])?></h2><div class="profile-facts">
<span class="profile-fact"><svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M16 3v4M8 3v4M3 10h18M8 14h3"/></svg><span>Cliente desde: <?=profileDate($customer['data_cadastro'])?></span></span>
<span class="profile-fact"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M19 10c0 5-7 11-7 11S5 15 5 10a7 7 0 1 1 14 0Z"/><circle cx="12" cy="10" r="2.3"/></svg><span><?= $firstAddress?h($firstAddress['logradouro'].' '.$firstAddress['numero'].', '.$firstAddress['cidade'].' · '.$firstAddress['cep']):'Endereço não cadastrado' ?></span></span>
<span class="profile-fact"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 21s-8-4.5-8-11a4.5 4.5 0 0 1 8-2.8A4.5 4.5 0 0 1 20 10c0 6.5-8 11-8 11Z"/><path d="M8 13h2l1-2 2 4 1-2h2"/></svg><span>Nascimento: <?=!empty($customer['data_nascimento'])?profileDate($customer['data_nascimento']):'Não informado'?></span></span>
<span class="profile-fact"><svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="m4 7 8 6 8-6"/></svg><span>E-mail: <?=h($customer['email'])?></span></span>
<span class="profile-fact"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 3h4l2 5-2.5 1.5a15 15 0 0 0 6 6L16 13l5 2v4a2 2 0 0 1-2 2A17 17 0 0 1 3 5a2 2 0 0 1 2-2Z"/></svg><span>Telefone: <?=h($customer['telefone']?:'Não informado')?></span></span>
</div><form class="profile-photo-form" method="post" enctype="multipart/form-data"><input type="hidden" name="csrf" value="<?=csrf()?>"><input type="hidden" name="acao" value="foto"><label for="foto-perfil">Foto de perfil <span>JPG, PNG ou WebP · até 5 MB</span></label><input id="foto-perfil" type="file" name="foto_perfil" accept="image/jpeg,image/png,image/webp" required><button type="submit">Salvar foto</button></form></div>
            <a class="profile-edit-shortcut" href="#dados-pessoais" aria-label="Editar meus dados">✎</a>
        </section>
        <div class="profile-dashboard-grid">
            <div class="profile-column">
                <section class="profile-card profile-section" id="dados-pessoais"><div class="profile-section-heading"><div><span class="profile-eyebrow">SEUS DADOS</span><h2>Dados pessoais</h2></div></div><p class="profile-section-intro">Mantenha suas informações atualizadas para facilitar seus pedidos e entregas.</p>
                    <form method="post" class="profile-form"><input type="hidden" name="csrf" value="<?=csrf()?>"><input type="hidden" name="acao" value="perfil"><label>Nome completo<input name="nome" maxlength="100" autocomplete="name" value="<?=h($customer['nome'])?>" required></label><label>E-mail<input name="email" type="email" autocomplete="email" value="<?=h($customer['email'])?>" required></label><label>Telefone / WhatsApp<input name="telefone" type="tel" maxlength="20" autocomplete="tel" value="<?=h($customer['telefone']??'')?>" placeholder="(11) 99999-9999"></label><label>Data de nascimento<input name="data_nascimento" type="date" autocomplete="bday" max="<?=date('Y-m-d')?>" value="<?=h($customer['data_nascimento']??'')?>"></label><button class="profile-primary-button" type="submit">Salvar alterações</button></form>
                </section>
                <section class="profile-card profile-section" id="pedidos"><div class="profile-section-heading"><div><span class="profile-eyebrow">ACOMPANHAMENTO</span><h2>Meus pedidos</h2></div><a href="/cliente/pedidos.php">Abrir acompanhamento →</a></div>
                    <?php if(!$orders):?><div class="profile-empty"><span>▤</span><strong>Você ainda não tem pedidos</strong><p>Seus pedidos aparecerão aqui depois da primeira compra.</p><a href="/">Explorar produtos</a></div><?php else:?><div class="profile-order-list"><?php foreach(array_slice($orders,0,6) as $order):?><article class="profile-order"><span class="profile-order-icon">▤</span><span class="profile-order-info"><strong>Pedido #<?=$order['id_pedido']?></strong><small><?=profileDate($order['data_criacao'])?> · <?=h(str_replace('_',' ',$order['status']))?></small><small><?=h($order['logradouro'].' '.$order['numero'].', '.$order['cidade'])?></small></span><strong class="profile-order-total"><?=dinheiro((float)$order['valor_total'])?></strong><?php if(($order['modalidade_entrega']??'')==='retirada'&&$order['status']==='pronto'):?><span class="profile-order-pin">Código de retirada: <?=h($order['pin_entrega'])?></span><?php elseif($order['status']==='pendente'):?><form method="post" onsubmit="return confirm('Cancelar este pedido?')"><input type="hidden" name="csrf" value="<?=csrf()?>"><input type="hidden" name="acao" value="cancelar"><input type="hidden" name="pedido" value="<?=$order['id_pedido']?>"><button class="profile-cancel-order">Cancelar</button></form><?php elseif($order['status']==='em_transito'):?><span class="profile-order-pin">PIN <?=$order['pin_entrega']?></span><?php endif;?></article><?php endforeach;?></div><?php endif;?>
                </section>
                <section class="profile-card profile-section" id="aprovacoes"><div class="profile-section-heading"><div><span class="profile-eyebrow">PRECISAMOS DA SUA RESPOSTA</span><h2>Aprovações pendentes</h2></div><span class="profile-count"><?=$countApprovals?></span></div>
                    <?php if(!$approvals):?><div class="profile-empty compact"><span>✓</span><strong>Nenhuma aprovação pendente</strong><p>Avisaremos quando precisarmos confirmar uma substituição.</p></div><?php else:foreach($approvals as $line):?><div class="profile-approval"><div><strong>Pedido #<?=$line['id_pedido']?> · <?=h($line['produto'])?></strong><p>Solicitado: <?=$line['qtd_solicitada']?> · Separado: <?=$line['qtd_separada']??'—'?></p></div><form method="post" class="profile-approval-actions"><input type="hidden" name="csrf" value="<?=csrf()?>"><input type="hidden" name="acao" value="aprovacao"><input type="hidden" name="item" value="<?=$line['id_item']?>"><button name="resposta" value="aprovar">Aprovar</button><button class="is-secondary" name="resposta" value="recusar">Recusar</button></form></div><?php endforeach;endif;?>
                </section>
                <section class="profile-card profile-section" id="enderecos"><div class="profile-section-heading"><div><span class="profile-eyebrow">ENTREGA</span><h2>Endereços salvos</h2></div></div>
                    <?php if(!$addresses):?><div class="profile-empty compact"><span>⌖</span><strong>Nenhum endereço cadastrado</strong><p>Adicione um endereço para agilizar a finalização das compras.</p></div><?php else:?><div class="profile-address-list"><?php foreach($addresses as $address):?><article class="profile-address"><span class="profile-address-icon">⌖</span><div><strong><?=h($address['logradouro'])?>, <?=h($address['numero'])?></strong><p><?=h($address['bairro'])?> · <?=h($address['cidade'])?> · <?=h($address['cep'])?></p></div><span class="profile-address-status <?=$address['atendido']?'':'is-outside'?>"><?=$address['atendido']?'Atendido':'Fora da área'?></span></article><?php endforeach;?></div><?php endif;?>
                    <details class="profile-address-add" id="novo-endereco"><summary>+ Adicionar endereço</summary><form method="post" class="profile-form"><input type="hidden" name="csrf" value="<?=csrf()?>"><input type="hidden" name="acao" value="endereco"><label>Logradouro<input name="logradouro" autocomplete="address-line1" required></label><div class="form-row"><label>Número<input name="numero" required></label><label>CEP<input name="cep" inputmode="numeric" pattern="\d{5}-?\d{3}" placeholder="01000-000" required></label></div><div class="form-row"><label>Bairro<input name="bairro" required></label><label>Cidade<input name="cidade" autocomplete="address-level2" required></label></div><button class="profile-primary-button" type="submit">Salvar endereço</button></form></details>
                </section>
            </div>
            <div class="profile-column profile-column-side">
                <section class="profile-card profile-side-card profile-coupons" id="cupons"><span class="profile-eyebrow">VANTAGENS ALVORADA</span><h2>Cupons & Fidelidade</h2><div class="profile-loyalty-summary"><span class="profile-loyalty-mark">✦</span><div><strong><?=$completedPurchases?> compras concluídas</strong><small>Compras entregues pelo site</small></div></div>
                    <details class="profile-coupon-add"><summary>Adicionar cupom</summary><form method="post" class="profile-coupon-form"><input type="hidden" name="csrf" value="<?=csrf()?>"><input type="hidden" name="acao" value="resgatar_cupom"><label for="codigo-cupom">Código do cupom</label><div><input id="codigo-cupom" name="codigo_cupom" maxlength="40" placeholder="Ex.: ALVORADA10" required><button type="submit">Adicionar</button></div></form></details>
                    <h3>Meus cupons</h3><?php if(!$myCoupons):?><p class="profile-muted-text">Você ainda não adicionou cupons.</p><?php else:?><div class="profile-coupon-list"><?php foreach($myCoupons as $coupon):$couponExpired=!(int)$coupon['ativo']||($coupon['validade']&&$coupon['validade']<date('Y-m-d'))||($coupon['limite_usos']!==null&&(int)$coupon['usos']>=(int)$coupon['limite_usos']);?><article class="profile-coupon-item"><div><strong><?=h($coupon['codigo'])?></strong><span><?=h($coupon['titulo'])?> · <?=$coupon['tipo']==='percentual'?rtrim(rtrim(number_format((float)$coupon['valor'],2,'.',''),'0'),'.').'%':dinheiro((float)$coupon['valor'])?> de desconto</span><?php if($coupon['validade']):?><small>Válido até <?=profileDate($coupon['validade'])?></small><?php endif;?></div><b class="<?=$coupon['usado_em']?'is-used':($couponExpired?'is-expired':'')?>"><?=$coupon['usado_em']?'Usado':($couponExpired?'Expirado':'Disponível')?></b></article><?php endforeach;?></div><?php endif;?>
                    <details class="profile-coupon-available"><summary>Ver cupons disponíveis (<?=count($availableCoupons)?>)</summary><?php if(!$availableCoupons):?><p class="profile-muted-text">Não há novos cupons disponíveis no momento.</p><?php else:?><div class="profile-coupon-list"><?php foreach($availableCoupons as $coupon):?><article class="profile-coupon-item"><div><strong><?=h($coupon['codigo'])?></strong><span><?=h($coupon['titulo'])?> · <?=$coupon['tipo']==='percentual'?rtrim(rtrim(number_format((float)$coupon['valor'],2,'.',''),'0'),'.').'%':dinheiro((float)$coupon['valor'])?> de desconto</span><small><?=h($coupon['descricao']?:'Adicione este cupom e use no checkout.')?><?php if((float)$coupon['pedido_minimo']>0):?> · Pedido mínimo <?=dinheiro((float)$coupon['pedido_minimo'])?><?php endif;?></small></div><form method="post"><input type="hidden" name="csrf" value="<?=csrf()?>"><input type="hidden" name="acao" value="resgatar_cupom"><input type="hidden" name="codigo_cupom" value="<?=h($coupon['codigo'])?>"><button type="submit">Adicionar</button></form></article><?php endforeach;?></div><?php endif;?></details>
                </section>
                <section class="profile-card profile-side-card" id="entregas"><span class="profile-eyebrow">LOGÍSTICA</span><h2>Entregas</h2><div class="profile-mini-stat"><?=$deliveries?><span> pedidos em rota ou prontos</span></div><p>O agendamento de entregas ainda não está habilitado. Acompanhe o andamento em Meus Pedidos.</p><a href="#pedidos">Ver pedidos →</a></section>
                <section class="profile-card profile-section profile-notifications" id="notificacoes"><div class="profile-section-heading"><div><span class="profile-eyebrow">ATUALIZAÇÕES</span><h2>Notificações</h2></div></div><?php if(!$notificationOrders):?><p class="profile-muted-text">Você não tem notificações no momento.</p><?php else:foreach(array_slice($notificationOrders,0,5) as $order):?><div class="profile-notification"><span class="profile-notification-dot"></span><div><strong>Pedido #<?=$order['id_pedido']?> · <?=h(str_replace('_',' ',$order['status']))?></strong><small><?=profileDate($order['data_criacao'])?> · <?=dinheiro((float)$order['valor_total'])?></small></div></div><?php endforeach;endif;?></section>
                <section class="profile-card profile-section" id="configuracoes"><div class="profile-section-heading"><div><span class="profile-eyebrow">SEGURANÇA</span><h2>Alterar senha</h2></div></div><form method="post" class="profile-form"><input type="hidden" name="csrf" value="<?=csrf()?>"><input type="hidden" name="acao" value="senha"><label>Senha atual<input type="password" name="senha_atual" autocomplete="current-password" required></label><label>Nova senha<input type="password" name="senha_nova" minlength="8" autocomplete="new-password" required></label><label>Confirme a nova senha<input type="password" name="senha_confirmacao" minlength="8" autocomplete="new-password" required></label><button class="profile-primary-button" type="submit">Atualizar senha</button></form></section>
            </div>
        </div>
    </main>
</div>
<script>
const profileNav=[...document.querySelectorAll('.profile-nav a')];
const profileSections=[...document.querySelectorAll('.profile-section[id],.profile-overview[id],.profile-side-card[id]')];
const sectionForHash={perfil:'perfil',pedidos:'pedidos',aprovacoes:'aprovacoes',enderecos:'enderecos',cupons:'cupons',entregas:'entregas',notificacoes:'notificacoes',configuracoes:'configuracoes'};
function setProfileActive(){const current=(location.hash||'#perfil').slice(1);const selected=sectionForHash[current]||'perfil';profileNav.forEach(link=>link.classList.toggle('is-active',link.hash==='#'+selected));}
window.addEventListener('hashchange',setProfileActive);setProfileActive();
</script>
</body></html>
