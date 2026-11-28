<?php
require_once __DIR__.'/config/conexao.php';
require_once __DIR__.'/includes/flyer-photos.php';

$catalog = [
    'hortifruti' => ['title'=>'Hortifrúti & Orgânicos','summary'=>'Frutas frescas, legumes, verduras, temperos verdes e ovos caipiras.','unit'=>'Produtos vendidos por peso e unidade.'],
    'padaria' => ['title'=>'Padaria & Confeitaria','summary'=>'Pães artesanais, pão francês, bolos caseiros, salgados assados, biscoitos e torradas.','unit'=>'Produtos vendidos por peso e unidade.'],
    'acougue' => ['title'=>'Açougue','summary'=>'Cortes bovinos, suínos, aves, linguiças artesanais e itens para churrasco.','unit'=>'Carnes selecionadas, vendidas por peso.'],
    'peixaria' => ['title'=>'Peixaria','summary'=>'Peixes e frutos do mar frescos para suas receitas.','unit'=>'Consulte a unidade e o preço de cada produto.'],
    'acougue-peixaria' => ['title'=>'Açougue & Peixaria','summary'=>'Cortes bovinos, suínos, aves, linguiças artesanais, itens para churrasco e filés de peixe.','unit'=>'Carnes e peixes vendidos por peso.'],
    'frios-laticinios' => ['title'=>'Frios & Laticínios','summary'=>'Queijos, presuntos, requeijão, manteigas, leites, iogurtes e nata.','unit'=>'Produtos vendidos por peso e unidade.'],
    'mercearia-graos' => ['title'=>'Mercearia & Grãos','summary'=>'Arroz, feijão, macarrão, farinhas, açúcares, cafés, óleos, azeites, molhos e enlatados.','unit'=>'Produtos vendidos por unidade.'],
    'bebidas' => ['title'=>'Bebidas','summary'=>'Sucos naturais e integrais, águas minerais, refrigerantes, chás gelados e cervejas.','unit'=>'Produtos vendidos por unidade.'],
    'limpeza' => ['title'=>'Limpeza & Utilidades','summary'=>'Sabão em pó e líquido, detergentes, desinfetantes, esponjas, sacos de lixo e papel toalha.','unit'=>'Produtos vendidos por unidade.'],
    'farmacia' => ['title'=>'Farmácia / Drogaria','summary'=>'Medicamentos e itens essenciais de cuidado e bem-estar.','unit'=>'Consulte a apresentação e o preço de cada produto.'],
    'pets' => ['title'=>'Pets','summary'=>'Alimentos e cuidados para os companheiros da sua casa.','unit'=>'Produtos vendidos por unidade.'],
    'higiene-perfumaria' => ['title'=>'Higiene & Perfumaria','summary'=>'Sabonetes, shampoos, condicionadores, creme dental, desodorantes e papel higiênico.','unit'=>'Produtos vendidos por unidade.'],
    'jornal' => ['title'=>'Jornal da Semana','summary'=>'Confira o encarte e os destaques da semana no Supermercado Alvorada.','unit'=>'Ofertas válidas enquanto durarem os estoques.'],
    'ofertas' => ['title'=>'Ofertas do Dia','summary'=>'Destaques promocionais e preços especiais para economizar nas compras.','unit'=>'Ofertas válidas enquanto durarem os estoques.'],
    'todos' => ['title'=>'Todas as Categorias','summary'=>'Explore os produtos disponíveis no Supermercado Alvorada.','unit'=>'Escolha seus produtos e adicione ao carrinho.'],
];
$slug = preg_replace('/[^a-z0-9-]/', '', strtolower((string)($_GET['slug'] ?? '')));
if (!isset($catalog[$slug])) { http_response_code(404); $slug = 'todos'; }
$meta = $catalog[$slug];
$categories = [];
$products = [];
$flyerItems = [];
$categoryImage = '';
$siteBanners = [];
$profileNotificationCount = 0;
try {
    $categories = db()->query('SELECT * FROM categorias ORDER BY id_categoria')->fetchAll();
    $categoryRow = null;
    foreach ($categories as $row) if (($row['slug'] ?? '') === $slug) { $categoryRow = $row; break; }
    $categoryImage = (string)($categoryRow['imagem_url'] ?? '');
    if ($slug === 'todos') {
        $products = db()->query('SELECT p.*,c.nome categoria,c.slug FROM produtos p JOIN categorias c USING(id_categoria) WHERE p.ativo=1 ORDER BY c.id_categoria,p.destaque DESC,p.nome')->fetchAll();
    } elseif (in_array($slug, ['ofertas','jornal'], true)) {
        $flyerItems = db()->query('SELECT * FROM itens_encarte_site WHERE ativo=1 ORDER BY ordem,id_item_encarte')->fetchAll();
        $bannerQuery = db()->prepare('SELECT imagem_url,texto_alternativo FROM banners_site WHERE ativo=1 AND categoria_slug IS NULL ORDER BY ordem,id_banner LIMIT 1');
        $bannerQuery->execute();
        $siteBanners = $bannerQuery->fetchAll();
    } else {
        $slugs = $slug === 'acougue-peixaria' ? ['acougue','peixaria'] : [$slug];
        $marks = implode(',', array_fill(0, count($slugs), '?'));
        $query = db()->prepare("SELECT p.*,c.nome categoria,c.slug FROM produtos p JOIN categorias c USING(id_categoria) WHERE p.ativo=1 AND c.slug IN ($marks) ORDER BY c.id_categoria,p.destaque DESC,p.nome");
        $query->execute($slugs);
        $products = $query->fetchAll();
    }
} catch (Throwable $e) {
    $categories = $categories ?: [];
}
$categoryNames = [
    'hortifruti'=>'Hortifrúti','acougue'=>'Açougue','farmacia'=>'Farmácia','frios-laticinios'=>'Frios & Laticínios',
    'mercearia-graos'=>'Mercearia & Grãos','higiene-perfumaria'=>'Higiene & Perfumaria'
];
foreach ($categories as &$category) if (isset($categoryNames[$category['slug'] ?? ''])) $category['nome'] = $categoryNames[$category['slug']];
unset($category);
if (!$categories) {
    foreach (['hortifruti'=>'Hortifrúti','padaria'=>'Padaria','acougue'=>'Açougue','bebidas'=>'Bebidas','limpeza'=>'Limpeza','farmacia'=>'Farmácia','pets'=>'Pets','peixaria'=>'Peixaria','frios-laticinios'=>'Frios & Laticínios','mercearia-graos'=>'Mercearia & Grãos','higiene-perfumaria'=>'Higiene & Perfumaria','jornal'=>'Jornal da Semana'] as $key=>$name) $categories[]=['slug'=>$key,'nome'=>$name];
}
if (($_SESSION['usuario']['perfil'] ?? '') === 'cliente') {
    try { $notice=db()->prepare("SELECT COUNT(*) FROM pedidos WHERE id_cliente=? AND status IN ('aguardando_aprovacao','em_transito','problema')"); $notice->execute([(int)$_SESSION['usuario']['id_usuario']]); $profileNotificationCount=(int)$notice->fetchColumn(); } catch (Throwable $e) {}
}
$itemCount = count($products) + count($flyerItems);
?><!doctype html>
<html lang="pt-BR"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="customer-state-csrf" content="<?=h(csrf())?>">
<title><?=h($meta['title'])?> | Supermercado Alvorada</title>
<link rel="stylesheet" href="assets/css/style.css?v=73">
</head><body class="category-page category-page-<?=h($slug)?>">
<div class="topbar"><div class="container"><header class="header">
    <a class="brand" href="/" aria-label="Supermercado Alvorada — início"><img class="brand-logo" src="assets/images/alvorada-logo.png?v=1" alt="Supermercado Alvorada"></a>
    <form class="search category-search" action="/index.php" method="get"><input id="busca" name="q" placeholder="Buscar produtos, marcas e mais..." autocomplete="off" aria-label="Buscar produtos"><button class="search-button" aria-label="Buscar">⌕</button><div id="autocomplete" class="autocomplete" hidden></div></form>
    <a class="head-action address" href="cliente/checkout.php" data-location-open aria-haspopup="dialog" aria-controls="location-dialog"><span class="pin">♥</span><span><small>Entregar para</small><strong data-location-city>São Paulo</strong></span></a>
    <?php require __DIR__.'/includes/favorites-button.php'; ?>
    <a class="icon-link coupon-header-link" href="cupons.php" aria-label="Cupons disponíveis" title="Cupons disponíveis"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 7.5A2.5 2.5 0 0 0 6.5 5h11A2.5 2.5 0 0 0 20 7.5v2a2.5 2.5 0 0 0 0 5v2a2.5 2.5 0 0 0-2.5 2.5h-11A2.5 2.5 0 0 0 4 16.5v-2a2.5 2.5 0 0 0 0-5z"/><path d="m9 14 6-6M9 8h.01M15 14h.01"/></svg></a>
    <details class="account-menu"><summary class="icon-link account-trigger" aria-label="Minha conta"><svg class="person-icon" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="8" r="4"/><path d="M4.5 21a7.5 7.5 0 0 1 15 0"/></svg><?php if($profileNotificationCount>0):?><span class="account-notification-badge"><?=$profileNotificationCount?></span><?php endif;?><span class="account-trigger-label"><?=($_SESSION['usuario']['perfil']??'')==='cliente'?h($_SESSION['usuario']['nome']??'Minha conta'):'Entrar / Cadastrar'?></span></summary><div class="account-dropdown"><strong class="account-dropdown-greeting"><?=($_SESSION['usuario']['perfil']??'')==='cliente'?'Olá, '.h($_SESSION['usuario']['nome']??'Cliente'):'Entre ou cadastre-se'?></strong><?php if(($_SESSION['usuario']['perfil']??'')==='cliente'):?><a href="cliente/perfil.php">Meu perfil</a><a href="/cliente/perfil.php#pedidos">Meus pedidos</a><?php else:?><a class="account-dropdown-primary" href="auth/login.php">Entrar</a><a href="auth/cadastro.php">Criar uma conta</a><?php endif;?></div></details>
    <a class="icon-link cart-link" href="cliente/carrinho.php" aria-label="Abrir carrinho de compras"><svg class="cart-icon" viewBox="0 0 32 32" aria-hidden="true"><path d="M4 6h3l3.2 14.4a2 2 0 0 0 2 1.6h10.2a2 2 0 0 0 1.9-1.4L28 11H9"/><path d="M11 15h14M12 19h12"/><circle cx="13" cy="26" r="1.7"/><circle cx="23" cy="26" r="1.7"/></svg><span data-cart-count>0</span></a>
</header></div></div>
<div class="category-bar"><nav class="container nav" aria-label="Categorias"><button class="category-menu-toggle" type="button" data-category-menu-toggle aria-expanded="false" aria-controls="category-mega-menu"><b>☰</b> Todas as Categorias <span aria-hidden="true">⌄</span></button><div class="category-marquee"><div class="category-marquee-track"><div class="category-marquee-set"><?php foreach($categories as $c):?><a href="categoria.php?slug=<?=rawurlencode($c['slug'])?>" <?=($c['slug']===$slug)?'aria-current="page"':''?>><?=h($c['nome'])?></a><?php endforeach;?></div><div class="category-marquee-set" aria-hidden="true"><?php foreach($categories as $c):?><a href="categoria.php?slug=<?=rawurlencode($c['slug'])?>" tabindex="-1"><?=h($c['nome'])?></a><?php endforeach;?></div></div></div></nav>
<div class="category-mega-menu container" id="category-mega-menu" hidden>
    <a class="category-mega-link" href="categoria.php?slug=ofertas"><strong>Ofertas do Dia</strong><span>Destaques promocionais e combos especiais.</span></a>
    <?php foreach($categories as $c):if($c['slug']==='jornal')continue;?><a class="category-mega-link" href="categoria.php?slug=<?=rawurlencode($c['slug'])?>"><strong><?=h($c['nome'])?></strong><span><?=h($catalog[$c['slug']]['summary']??'Confira os produtos disponíveis nesta categoria.')?></span></a><?php endforeach;?>
    <a class="category-mega-link" href="categoria.php?slug=jornal"><strong>Jornal da Semana</strong><span>Veja o encarte e as ofertas da semana.</span></a>
</div></div>
<dialog class="location-dialog" id="location-dialog" aria-labelledby="location-title"><div class="location-dialog-head"><h2 id="location-title">Escolha sua localização</h2><button class="location-close" type="button" data-location-close aria-label="Fechar">×</button></div><p>Informe sua cidade e CEP para definir o local de entrega.</p><form method="dialog" class="location-form" data-location-form><label for="location-city-input">Cidade<input id="location-city-input" name="cidade" maxlength="100" autocomplete="address-level2" required placeholder="Ex.: São Paulo"></label><label for="location-cep-input">CEP <span>(opcional)</span><input id="location-cep-input" name="cep" inputmode="numeric" autocomplete="postal-code" pattern="\d{5}-?\d{3}" maxlength="9" placeholder="00000-000"></label><p data-location-status role="status" aria-live="polite"></p><div class="location-dialog-actions"><button type="button" class="button light" data-location-close>Cancelar</button><button type="submit">Salvar localização</button></div></form></dialog>
<?php require __DIR__.'/includes/favorites-dialog.php'; ?>
<main class="container category-main">
    <nav class="category-breadcrumb" aria-label="Você está em"><a href="/">Início</a><span>/</span><span><?=h($meta['title'])?></span></nav>
    <section class="category-page-hero"><div><span class="category-page-kicker">Supermercado Alvorada</span><h1><?=h($meta['title'])?></h1><p><?=h($meta['summary'])?></p><?php if ($slug === 'farmacia'): ?><p><strong>Farmácia Popular — parceria fictícia para demonstração.</strong></p><?php endif; ?><small><?=h($meta['unit'])?></small></div><?php if($categoryImage!==''):?><img src="<?=h($categoryImage)?>" alt="" loading="eager"><?php endif;?></section>
    <?php if($slug==='jornal'):?><section class="category-section category-weekly-section"><div class="section-head"><h2>Jornal da Semana</h2><span class="weekly-flyer-page-total">3 páginas</span></div><div class="weekly-flyer-reader" data-weekly-flyer><div class="weekly-flyer-toolbar"><div><strong>Jornal digital</strong><small>Ofertas por departamento</small></div><div class="weekly-flyer-controls"><button type="button" class="weekly-flyer-zoom" data-flyer-zoom aria-label="Ampliar página" title="Ampliar página" aria-pressed="false"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5"/><path d="m15.5 15.5 5 5M8 10.5h5m-2.5-2.5v5" data-flyer-zoom-mark/></svg></button><button type="button" data-flyer-prev aria-label="Página anterior">‹</button><span data-flyer-counter aria-live="polite">Página 1 de 3</span><button type="button" data-flyer-next aria-label="Próxima página">›</button></div></div><div class="weekly-flyer-stage" data-flyer-stage><button type="button" class="weekly-flyer-side-button weekly-flyer-side-prev" data-flyer-prev aria-label="Página anterior">‹</button><button type="button" class="weekly-flyer-side-button weekly-flyer-side-next" data-flyer-next aria-label="Próxima página">›</button><figure class="weekly-flyer-page is-active" data-flyer-slide aria-hidden="false"><img src="/assets/images/jornal-semana-pagina-1-hortifruti.jpg" alt="Jornal da Semana, página 1: hortifrúti, padaria e açougue" fetchpriority="high"></figure><figure class="weekly-flyer-page" data-flyer-slide aria-hidden="true" inert><img src="/assets/images/jornal-semana-pagina-2-mercearia.jpg" alt="Jornal da Semana, página 2: mercearia, frios e bebidas" loading="lazy"></figure><figure class="weekly-flyer-page" data-flyer-slide aria-hidden="true" inert><img src="/assets/images/jornal-semana-pagina-3-limpeza.jpg" alt="Jornal da Semana, página 3: limpeza, higiene e perfumaria" loading="lazy"></figure></div><div class="weekly-flyer-dots" role="group" aria-label="Selecionar página do jornal"><button type="button" class="is-active" data-flyer-dot aria-label="Página 1" aria-current="page"></button><button type="button" data-flyer-dot aria-label="Página 2"></button><button type="button" data-flyer-dot aria-label="Página 3"></button></div></div></section><?php elseif($slug==='ofertas'):?><section class="category-section"><div class="section-head"><h2><?=h($slug==='jornal'?'Encarte da semana':'Ofertas disponíveis')?></h2><a href="index.php#ofertas">Ver encarte completo <span aria-hidden="true">→</span></a></div><div class="category-offer-grid"><?php foreach($flyerItems as $item):$photoStyle=flyerPhotoSpriteStyle((string)$item['slug']);?><article id="produto-<?=-(900+(int)$item['id_item_encarte'])?>" class="product" data-id="<?=-(900+(int)$item['id_item_encarte'])?>" data-name="<?=h($item['nome'])?>"><div class="category-product-placeholder"><?php if($photoStyle!==null):?><span class="category-product-photo" role="img" aria-label="<?=h($item['nome'])?>" style="<?=h($photoStyle)?>"></span><?php else:?><span>Oferta Alvorada</span><?php endif;?></div><div class="product-body"><span class="badge">Oferta do dia</span><h3><?=h($item['nome'])?></h3><p class="muted"><?=h($item['tipo_medida']==='KG'?'Preço por kg':'Preço por unidade')?></p><p class="price"><?=dinheiro((float)$item['preco'])?></p><div class="product-actions"><button type="button" data-add data-encarte="true" data-id="<?=-(900+(int)$item['id_item_encarte'])?>" data-name="<?=h($item['nome'])?>" data-price="<?=h((string)$item['preco'])?>" data-unit="<?=h($item['tipo_medida'])?>">Adicionar</button></div></div></article><?php endforeach;?></div><?php if(!$flyerItems):?><p class="category-empty">As ofertas serão publicadas aqui em breve.</p><?php endif;?></section>
    <?php else:?><section class="category-section"><div class="section-head"><h2><?=h($slug==='todos'?'Produtos da loja':'Produtos da categoria')?></h2><span class="category-product-count"><?=$itemCount?> <?=($itemCount===1?'produto':'produtos')?></span></div><?php if($products):?><div class="product-grid"><?php foreach($products as $product):?><article id="produto-<?=(int)$product['id_produto']?>" class="product" data-id="<?=(int)$product['id_produto']?>" data-name="<?=h($product['nome'])?>" data-search="<?=h(strtolower($product['nome'].' '.$product['categoria']))?>"><?php if($product['imagem_url']||$categoryImage):?><img src="<?=h($product['imagem_url']?:$categoryImage)?>" alt="<?=h($product['nome'])?>" loading="lazy" onerror="this.hidden=true"><?php else:?><div class="category-product-placeholder"><?=h($product['categoria'])?></div><?php endif;?><div class="product-body"><span class="badge">Preço por <?=h($product['tipo_medida']==='KG'?'kg':'unidade')?></span><h3><?=h($product['nome'])?></h3><?php if(!empty($product['descricao'])): ?><p class="product-description"><?=h($product['descricao'])?></p><?php endif; ?><?php if ($product['slug'] === 'bebidas' && preg_match('/^(Whisky|Gin) /i', $product['nome'])): ?><p class="muted"><strong>Venda exclusiva para maiores de 18 anos</strong></p><?php endif; ?><?php if ((float)$product['estoque_qtd'] > 0): ?><p class="price"><?=dinheiro((float)$product['preco_unitario'])?> / <?=h($product['tipo_medida'])?></p><div class="product-actions"><button type="button" class="product-buy-button" data-add data-go-cart="true" data-id="<?=(int)$product['id_produto']?>" data-name="<?=h($product['nome'])?>" data-price="<?=h((string)$product['preco_unitario'])?>" data-unit="<?=h($product['tipo_medida'])?>"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 4h2l2.2 10.1a2 2 0 0 0 2 1.6h8.5a2 2 0 0 0 1.9-1.4L22 8H6"/><circle cx="10" cy="20" r="1.2"/><circle cx="18" cy="20" r="1.2"/></svg><span>Adicionar</span></button></div><?php else: ?><p class="muted">Indisponível para compra</p><?php if ($product['slug'] === 'farmacia' && str_starts_with((string)$product['imagem_url'], '/assets/images/produto-farmacia-')): ?><p class="muted">Para medicamentos sujeitos a prescrição, é obrigatória a apresentação de receita médica em farmácia ou drogaria autorizada.</p><?php endif; ?><?php if ($product['slug'] === 'limpeza' && $product['imagem_url'] === '/assets/images/produto-limpeza-zulu-alcool-70-1l.jpg'): ?><p><a href="https://www.gov.br/anvisa/pt-br/assuntos/noticias-anvisa/2024/alcool-liquido-70-prazo-para-esgotamento-de-estoques-se-encerrou-em-29-de-abril/" style="text-decoration:underline">Consultar orientação da Anvisa</a></p><?php endif; ?><?php endif; ?></div></article><?php endforeach;?></div><?php else:?><div class="category-empty-state"><span aria-hidden="true">✦</span><h3>Estamos preparando esta seleção</h3><p><?=h($meta['summary'])?> Os produtos desta categoria aparecerão aqui assim que estiverem disponíveis.</p><a class="button" href="categoria.php?slug=todos">Explorar produtos</a></div><?php endif;?></section><?php endif;?>
</main>
<?php require __DIR__.'/includes/site-footer.php'; ?>
<script src="assets/js/main.js?v=27"></script>
<script src="assets/js/category-menu.js?v=1"></script>
<script src="assets/js/weekly-flyer.js?v=1"></script>
</body></html>

