<?php
require_once __DIR__.'/../config/conexao.php';
verificarAcesso('separador');
$msg='';
$pdo=db();
if($_SERVER['REQUEST_METHOD']==='POST'){
    validarCsrf();
    $id=(int)($_POST['pedido']??0);
    $action=$_POST['acao']??'';
    if($action==='confirmar_retirada'){
        $code=preg_replace('/\D/','',(string)($_POST['codigo_retirada']??''));
        $q=$pdo->prepare("UPDATE pedidos SET status='entregue' WHERE id_pedido=? AND modalidade_entrega='retirada' AND status='pronto' AND pin_entrega=?");
        $q->execute([$id,$code]);
        $msg=$q->rowCount()?'Retirada confirmada e pedido concluído.':'Código incorreto ou pedido indisponível para retirada.';
    }else{
        $pdo->beginTransaction();
        try{
            $pdo->prepare("UPDATE pedidos SET status='em_separacao',id_separador=? WHERE id_pedido=? AND status IN ('pendente','em_separacao')")->execute([$_SESSION['usuario']['id_usuario'],$id]);
            foreach(($_POST['peso']??[]) as $item=>$qty){
                $q=$pdo->prepare('SELECT i.*,p.tipo_medida,p.preco_unitario FROM itens_pedido i JOIN produtos p USING(id_produto) WHERE i.id_item=? AND i.id_pedido=?');
                $q->execute([(int)$item,$id]);$i=$q->fetch();if(!$i)continue;
                if(isset($_POST['falta'][$item])){$pdo->prepare("UPDATE itens_pedido SET status_item='em_falta',qtd_separada=0 WHERE id_item=?")->execute([$item]);continue;}
                $qty=(float)$qty;if($i['tipo_medida']==='UN')$qty=(int)$qty;if($qty<0)throw new RuntimeException('Quantidade inválida.');
                $pdo->prepare("UPDATE itens_pedido SET qtd_separada=?,status_item='separado' WHERE id_item=?")->execute([$qty,$item]);
                if($i['tipo_medida']==='KG'&&$qty>(float)$i['qtd_solicitada']*1.15){$pdo->prepare("UPDATE pedidos SET status='aguardando_aprovacao' WHERE id_pedido=?")->execute([$id]);$pdo->prepare('INSERT INTO respostas_item(id_item,motivo) VALUES(?,?) ON DUPLICATE KEY UPDATE motivo=VALUES(motivo)')->execute([$item,'Ajuste de peso acima de 15%']);}
            }
            if(empty($_POST['aguardar']))$pdo->prepare("UPDATE pedidos SET status='pronto' WHERE id_pedido=? AND status='em_separacao'")->execute([$id]);
            $pdo->commit();$msg='Separação atualizada.';
        }catch(Throwable $e){$pdo->rollBack();$msg='Não foi possível atualizar a separação.';}
    }
}
$orders=$pdo->query("SELECT * FROM pedidos WHERE status IN ('pendente','em_separacao','aguardando_aprovacao') ORDER BY data_criacao")->fetchAll();
$pickupOrders=$pdo->query("SELECT * FROM pedidos WHERE modalidade_entrega='retirada' AND status='pronto' ORDER BY data_criacao")->fetchAll();
?><!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Painel de separação</title><link rel="stylesheet" href="/assets/css/style.css"></head><body><main class="container"><h1>Fila de separação</h1><p><?=h($_SESSION['usuario']['nome'])?> · <a href="/">Loja</a></p><?php if($msg):?><div class="notice"><?=h($msg)?></div><?php endif;?>
<?php foreach($pickupOrders as $pickup):?><section class="card"><h2>Retirada do pedido #<?=$pickup['id_pedido']?> <span class="status">Pronto para retirada</span></h2><p>Peça ao cliente o código de seis dígitos exibido no acompanhamento do pedido.</p><form method="post" class="form"><input type="hidden" name="csrf" value="<?=csrf()?>"><input type="hidden" name="pedido" value="<?=$pickup['id_pedido']?>"><input type="hidden" name="acao" value="confirmar_retirada"><label>Código de retirada<input name="codigo_retirada" inputmode="numeric" pattern="[0-9]{6}" maxlength="6" autocomplete="one-time-code" required></label><button>Confirmar retirada</button></form></section><?php endforeach;?>
<?php foreach($orders as $o):?><section class="card"><h2>Pedido #<?=$o['id_pedido']?> <span class="status"><?=h($o['status'])?></span></h2><form method="post" class="form"><input type="hidden" name="csrf" value="<?=csrf()?>"><input type="hidden" name="pedido" value="<?=$o['id_pedido']?>"><?php $q=db()->prepare('SELECT i.*,p.nome,p.tipo_medida,p.preco_unitario FROM itens_pedido i JOIN produtos p USING(id_produto) WHERE id_pedido=?');$q->execute([$o['id_pedido']]);foreach($q as $i):?><div class="cart-line"><div><strong><?=h($i['nome'])?></strong> · <?=$i['qtd_solicitada']?> <?=$i['tipo_medida']?> · <?=dinheiro((float)$i['preco_unitario'])?>/<?=$i['tipo_medida']?></div><label>Quantidade aferida<input type="number" name="peso[<?=$i['id_item']?>]" min="0" step="<?=$i['tipo_medida']==='KG'?'0.001':'1'?>" value="<?=$i['qtd_solicitada']?>"></label><label><input type="checkbox" name="falta[<?=$i['id_item']?>]" value="1"> Em falta</label></div><?php endforeach;?><label><input type="checkbox" name="aguardar" value="1"> Aguardando decisão do cliente</label><button>Salvar e concluir separação</button></form></section><?php endforeach;?><?php if(!$orders&&!$pickupOrders):?><div class="card">Nenhum pedido na fila.</div><?php endif;?></main></body></html>
