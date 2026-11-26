<?php
require_once __DIR__.'/config/conexao.php';

$user = $_SESSION['usuario'] ?? null;
$customerId = ($user['perfil'] ?? '') === 'cliente' ? (int)$user['id_usuario'] : 0;
$message = $_SESSION['coupon_page_message'] ?? '';
$error = $_SESSION['coupon_page_error'] ?? '';
unset($_SESSION['coupon_page_message'], $_SESSION['coupon_page_error']);
$categories = [];
$availableCoupons = [];
$myCoupons = [];
$notificationCount = 0;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['redeem_coupon'])) {
    validarCsrf();
    if ($customerId < 1) {
        header('Location: auth/login.php?voltar=cupons');
        exit;
    }
    try {
        $code = strtoupper(trim((string)($_POST['coupon_code'] ?? '')));
        $q = db()->prepare('SELECT id_cupom FROM cupons WHERE codigo=? AND ativo=1 AND (validade IS NULL OR validade>=CURRENT_DATE) AND (limite_usos IS NULL OR usos<limite_usos) LIMIT 1');
        $q->execute([$code]);
        $couponId = (int)$q->fetchColumn();
        if (!$couponId) throw new RuntimeException('Este cupom não está mais disponível.');
        $claim = db()->prepare('INSERT IGNORE INTO cupons_clientes(id_usuario,id_cupom) VALUES(?,?)');
        $claim->execute([$customerId, $couponId]);
        if ($claim->rowCount() !== 1) throw new RuntimeException('Você já resgatou este cupom. Confira em Meus cupons.');
        $_SESSION['coupon_page_message'] = 'Cupom resgatado! Ele já está disponível no seu checkout.';
    } catch (RuntimeException $e) {
        $_SESSION['coupon_page_error'] = $e->getMessage();
    } catch (Throwable $e) {
        $_SESSION['coupon_page_error'] = 'Não foi possível resgatar o cupom agora. Tente novamente.';
    }
    header('Location: cupons.php');
    exit;
}

try {
    $categories = db()->query('SELECT nome,slug FROM categorias ORDER BY id_categoria')->fetchAll();
    if ($customerId > 0) {
        $q = db()->prepare('SELECT COUNT(*) FROM pedidos WHERE id_cliente=? AND status IN (\'aguardando_aprovacao\',\'em_transito\',\'problema\')');
        $q->execute([$customerId]);
        $notificationCount = (int)$q->fetchColumn();
        $q = db()->prepare('SELECT c.* FROM cupons c LEFT JOIN cupons_clientes cc ON cc.id_cupom=c.id_cupom AND cc.id_usuario=? WHERE c.ativo=1 AND (c.validade IS NULL OR c.validade>=CURRENT_DATE) AND (c.limite_usos IS NULL OR c.usos<c.limite_usos) AND cc.id_cupom IS NULL ORDER BY c.validade IS NULL,c.validade,c.codigo');
        $q->execute([$customerId]);
        $availableCoupons = $q->fetchAll();
        $q = db()->prepare('SELECT c.*,cc.usado_em,cc.resgatado_em FROM cupons_clientes cc JOIN cupons c USING(id_cupom) WHERE cc.id_usuario=? ORDER BY cc.resgatado_em DESC');
        $q->execute([$customerId]);
        $myCoupons = $q->fetchAll();
    } else {
        $availableCoupons = db()->query('SELECT c.* FROM cupons c WHERE c.ativo=1 AND (c.validade IS NULL OR c.validade>=CURRENT_DATE) AND (c.limite_usos IS NULL OR c.usos<c.limite_usos) ORDER BY c.validade IS NULL,c.validade,c.codigo')->fetchAll();
    }
} catch (Throwable $e) {
    $categories = $categories ?: [];
    $error = $error ?: 'Não foi possível carregar os cupons agora.';
}

function couponDiscountLabel(array $coupon): string {
    if ($coupon['tipo'] === 'percentual') {
        return rtrim(rtrim(number_format((float)$coupon['valor'], 2, ',', '.'), '0'), ',').'% OFF';
    }
    return dinheiro((float)$coupon['valor']).' OFF';
}
function couponDateLabel(?string $date): string {
    return $date ? date('d/m/Y', strtotime($date)) : 'Enquanto houver disponibilidade';
}
?><!doctype html>
<html lang="pt-BR"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="customer-state-csrf" content="<?=h(csrf())?>">
<title>Cupons Alvorada | Supermercado Alvorada</title>
<link rel="stylesheet" href="assets/css/style.css?v=50">
</head><body class="coupon-page">
<div class="topbar"><div class="container"><header class="header">
    <a class="brand" href="index.php" aria-label="Supermercado Alvorada — início"><img class="brand-logo" src="assets/images/alvorada-logo.png?v=1" alt="Supermercado Alvorada"></a>
    <form class="search coupon-search" action="index.php" method="get"><input name="q" placeholder="Buscar produtos, marcas e mais..." aria-label="Buscar produtos"><button class="search-button" aria-label="Buscar">⌕</button></form>
    <a class="head-action address" href="cliente/checkout.php" data-location-open aria-haspopup="dialog" aria-controls="location-dialog"><span class="pin">♥</span><span><small>Entregar para</small><strong data-location-city>São Paulo</strong></span></a>
    <a class="icon-link favorites-link" href="index.php#categorias" aria-label="Produtos curtidos"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8l1.1 1.1L12 21l7.8-7.5 1.1-1.1a5.5 5.5 0 0 0-.1-7.8Z"/></svg></a>
    <a class="icon-link coupon-header-link is-current" href="cupons.php" aria-label="Cupons disponíveis" aria-current="page"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 7.5A2.5 2.5 0 0 0 6.5 5h11A2.5 2.5 0 0 0 20 7.5v2a2.5 2.5 0 0 0 0 5v2a2.5 2.5 0 0 0-2.5 2.5h-11A2.5 2.5 0 0 0 4 16.5v-2a2.5 2.5 0 0 0 0-5z"/><path d="m9 14 6-6M9 8h.01M15 14h.01"/></svg></a>
    <details class="account-menu"><summary class="icon-link account-trigger" aria-label="Minha conta"><svg class="person-icon" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="8" r="4"/><path d="M4.5 21a7.5 7.5 0 0 1 15 0"/></svg><?php if($notificationCount>0):?><span class="account-notification-badge"><?=$notificationCount?></span><?php endif;?><span class="account-trigger-label"><?=($user['perfil']??'')==='cliente'?h($user['nome']??'Minha conta'):'Entrar / Cadastrar'?></span></summary><div class="account-dropdown"><?php if($customerId):?><strong class="account-dropdown-greeting">Olá, <?=h($user['nome']??'Cliente')?></strong><a href="cliente/perfil.php">Meu perfil</a><a href="cliente/perfil.php#pedidos">Meus pedidos</a><a href="cliente/perfil.php#cupons">Cupons &amp; Fidelidade</a><?php else:?><strong class="account-dropdown-greeting">Entre ou cadastre-se</strong><a class="account-dropdown-primary" href="auth/login.php?voltar=cupons">Entrar</a><a href="auth/cadastro.php?voltar=cupons">Criar uma conta</a><?php endif;?></div></details>
    <a class="icon-link cart-link" href="cliente/carrinho.php" aria-label="Abrir carrinho de compras"><svg class="cart-icon" viewBox="0 0 32 32" aria-hidden="true"><path d="M4 6h3l3.2 14.4a2 2 0 0 0 2 1.6h10.2a2 2 0 0 0 1.9-1.4L28 11H9"/><path d="M11 15h14M12 19h12"/><circle cx="13" cy="26" r="1.7"/><circle cx="23" cy="26" r="1.7"/></svg><span data-cart-count>0</span></a>
</header></div></div>
<main class="container coupon-main">
    <nav class="category-breadcrumb" aria-label="Você está em"><a href="index.php">Início</a><span>/</span><span>Cupons</span></nav>
    <section class="coupon-hero"><span class="coupon-eyebrow">VANTAGENS ALVORADA</span><h1>Cupons disponíveis</h1><p>Resgate suas ofertas e use o cupom no carrinho antes de finalizar o pedido.</p></section>
    <?php if($message):?><div class="notice success" role="status"><?=h($message)?></div><?php endif;?>
    <?php if($error):?><div class="notice" role="alert"><?=h($error)?></div><?php endif;?>
    <section class="coupon-section" aria-labelledby="available-coupons-title">
        <div class="section-head"><div><span class="coupon-eyebrow">OFERTAS PARA SUA COMPRA</span><h2 id="available-coupons-title">Resgate um cupom</h2></div><span class="coupon-total"><?=count($availableCoupons)?> disponíveis</span></div>
        <?php if(!$availableCoupons):?><div class="coupon-empty"><span aria-hidden="true">✦</span><h3>Nenhum cupom disponível agora</h3><p>Volte em breve para conferir novas vantagens do Alvorada.</p></div><?php else:?><div class="coupon-grid">
        <?php foreach($availableCoupons as $coupon):?><article class="coupon-card"><div class="coupon-card-top"><span class="coupon-brand-mark" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M4 7.5A2.5 2.5 0 0 0 6.5 5h11A2.5 2.5 0 0 0 20 7.5v2a2.5 2.5 0 0 0 0 5v2a2.5 2.5 0 0 0-2.5 2.5h-11A2.5 2.5 0 0 0 4 16.5v-2a2.5 2.5 0 0 0 0-5z"/><path d="m9 14 6-6"/></svg></span><span class="coupon-discount"><?=h(couponDiscountLabel($coupon))?></span></div><h3><?=h($coupon['titulo'])?></h3><p><?=h($coupon['descricao']?:'Uma vantagem especial para suas compras no Alvorada.')?></p><div class="coupon-terms"><?php if((float)$coupon['pedido_minimo']>0):?><span>Pedido mínimo: <strong><?=dinheiro((float)$coupon['pedido_minimo'])?></strong></span><?php endif;?><span>Válido até: <strong><?=h(couponDateLabel($coupon['validade']))?></strong></span></div><div class="coupon-code-row"><span>Código</span><strong><?=h($coupon['codigo'])?></strong></div><?php if($customerId):?><form method="post"><input type="hidden" name="csrf" value="<?=h(csrf())?>"><input type="hidden" name="redeem_coupon" value="1"><input type="hidden" name="coupon_code" value="<?=h($coupon['codigo'])?>"><button class="coupon-redeem-button" type="submit">Resgatar cupom</button></form><?php else:?><a class="coupon-redeem-button coupon-login-button" href="auth/login.php?voltar=cupons">Entre para resgatar</a><?php endif;?></article><?php endforeach;?>
        </div><?php endif;?>
    </section>
    <?php if($customerId):?><section class="coupon-section coupon-owned-section" aria-labelledby="my-coupons-title"><div class="section-head"><div><span class="coupon-eyebrow">SALVOS NA SUA CONTA</span><h2 id="my-coupons-title">Meus cupons</h2></div><a href="cliente/perfil.php#cupons">Ver fidelidade</a></div><?php if(!$myCoupons):?><p class="coupon-owned-empty">Os cupons que você resgatar aparecerão aqui.</p><?php else:?><div class="coupon-owned-list"><?php foreach($myCoupons as $coupon):$expired=!(int)$coupon['ativo']||($coupon['validade']&&$coupon['validade']<date('Y-m-d'))||($coupon['limite_usos']!==null&&(int)$coupon['usos']>=(int)$coupon['limite_usos']);?><article class="coupon-owned-item"><div><strong><?=h($coupon['codigo'])?></strong><span><?=h($coupon['titulo'])?> · <?=h(couponDiscountLabel($coupon))?></span><small><?=h($coupon['descricao']?:'Use este código no carrinho.')?></small></div><b class="<?=$coupon['usado_em']?'is-used':($expired?'is-expired':'')?>"><?=$coupon['usado_em']?'Usado':($expired?'Indisponível':'Resgatado')?></b></article><?php endforeach;?></div><?php endif;?></section><?php endif;?>
</main>
<?php require __DIR__.'/includes/site-footer.php'; ?>
</body></html>
