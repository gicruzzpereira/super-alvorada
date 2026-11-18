<?php
require_once __DIR__.'/../config/conexao.php';
require_once __DIR__.'/../config/entrega.php';

$user=$_SESSION['usuario']??null;
$loggedIn=($user['perfil']??'')==='cliente';
$products=[];
$categories=[];
$availableCoupons=[];
$pdo=null;
$shippingOptions=null;
$shippingMode=$_SESSION['entrega_modalidade']??'';
$shippingCep=$_SESSION['entrega_cep']??'';
$couponMessage=$_SESSION['cart_coupon_message']??'';
unset($_SESSION['cart_coupon_message']);
$newsletterMessage=$_SESSION['newsletter_message']??'';
unset($_SESSION['newsletter_message']);

try{
    $pdo=db();
    $products=$pdo->query('SELECT id_produto,nome,tipo_medida,preco_unitario,imagem_url FROM produtos WHERE ativo=1')->fetchAll(PDO::FETCH_UNIQUE);
    $categories=$pdo->query('SELECT nome,slug FROM categorias ORDER BY id_categoria')->fetchAll();
    $cartCategoryLabels=['hortifruti'=>"Hortifr\u{00fa}ti",'acougue'=>"A\u{00e7}ougue",'farmacia'=>"Farm\u{00e1}cia",'frios-laticinios'=>"Frios & Latic\u{00ed}nios",'mercearia-graos'=>"Mercearia & Gr\u{00e3}os",'higiene-perfumaria'=>"Higiene & Perfumaria"];
    foreach($categories as &$category){if(isset($cartCategoryLabels[$category['slug']]))$category['nome']=$cartCategoryLabels[$category['slug']];}unset($category);
    if($loggedIn){
        $couponQuery=$pdo->prepare('SELECT c.* FROM cupons c JOIN cupons_clientes cc USING(id_cupom) WHERE cc.id_usuario=? AND cc.usado_em IS NULL AND c.ativo=1 AND (c.validade IS NULL OR c.validade>=CURRENT_DATE) AND (c.limite_usos IS NULL OR c.usos<c.limite_usos) ORDER BY c.codigo');
        $couponQuery->execute([(int)$user['id_usuario']]);
        $availableCoupons=$couponQuery->fetchAll();
    }
}catch(Throwable $e){$products=[];$categories=[];}

if($pdo&&$shippingCep&&isset($_SESSION['cep_location_cache'][$shippingCep])){
    try{$shippingOptions=opcoesFretePorCep($pdo,(string)$shippingCep,$shippingMode==='retirada');if(!isset($shippingOptions[$shippingMode]))$shippingMode='';}
    catch(Throwable $e){$shippingOptions=null;$shippingMode='';}
}

if($_SERVER['REQUEST_METHOD']==='POST'&&isset($_POST['apply_coupon'])){
    validarCsrf();
    $code=strtoupper(trim((string)($_POST['coupon_code']??'')));
    $coupon=null;
    foreach($availableCoupons as $candidate){if(strtoupper($candidate['codigo'])===$code){$coupon=$candidate;break;}}
    if(!$loggedIn){$_SESSION['cart_coupon_message']='Entre na sua conta para usar um cupom.';}
    elseif($coupon){$_SESSION['checkout_coupon']=(int)$coupon['id_cupom'];$_SESSION['cart_coupon_message']='Cupom aplicado: '.$coupon['codigo'];}
    else{unset($_SESSION['checkout_coupon']);$_SESSION['cart_coupon_message']='Cupom indisponível ou não vinculado à sua conta.';}
    header('Location: /cliente/carrinho.php');
    exit;
}

if($_SERVER['REQUEST_METHOD']==='POST'&&isset($_POST['newsletter_signup'])){
    validarCsrf();
    $email=filter_var(trim((string)($_POST['newsletter_email']??'')),FILTER_VALIDATE_EMAIL);
    if(!$email){$_SESSION['newsletter_message']='Digite um e-mail válido para se inscrever.';}
    else try{
        if(!$pdo)$pdo=db();
        $pdo->exec('CREATE TABLE IF NOT EXISTS newsletter_inscritos (id_inscrito INT AUTO_INCREMENT PRIMARY KEY,email VARCHAR(190) NOT NULL UNIQUE,ativo TINYINT(1) NOT NULL DEFAULT 1,consentido_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
        $newsletter=$pdo->prepare('INSERT INTO newsletter_inscritos(email) VALUES(?) ON DUPLICATE KEY UPDATE ativo=1');
        $newsletter->execute([$email]);
        $_SESSION['newsletter_message']='Inscrição confirmada. Você receberá novidades e ofertas do Alvorada.';
    }catch(Throwable $e){$_SESSION['newsletter_message']='Não foi possível concluir sua inscrição agora. Tente novamente.';}
    header('Location: /cliente/carrinho.php#newsletter');
    exit;
}

$appliedCoupon=null;
if($loggedIn&&!empty($_SESSION['checkout_coupon'])){
    foreach($availableCoupons as $coupon){if((int)$coupon['id_cupom']===(int)$_SESSION['checkout_coupon']){$appliedCoupon=$coupon;break;}}
    if(!$appliedCoupon)unset($_SESSION['checkout_coupon']);
}
$csrfToken=csrf();
?><!doctype html>
<html lang="pt-BR">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Carrinho de Compras | Supermercado Alvorada</title>
    <link rel="stylesheet" href="/assets/css/style.css?v=41">
</head>
<body class="cart-page">
<div class="topbar">
    <div class="container">
        <header class="header cart-site-header">
            <a class="brand" href="/" aria-label="Alvorada Supermercado — início"><img class="brand-logo" src="/assets/images/alvorada-logo.png?v=1" alt="Supermercado Alvorada"></a>
            <form class="search cart-search" action="/" method="get"><input name="q" placeholder="Buscar produtos, marcas e mais..." aria-label="Buscar produtos"><button class="search-button" aria-label="Buscar">⌕</button></form>
            <a class="head-action address" href="/" aria-label="Entrega para São Paulo"><span class="pin">♥</span><span><small>Entregar para</small><strong>São Paulo</strong></span></a>
            <a class="icon-link cart-header-favorites" href="/#produtos" aria-label="Ver produtos"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8l1.1 1.1L12 21l7.8-7.5 1.1-1.1a5.5 5.5 0 0 0-.1-7.8Z"/></svg></a>
            <a class="icon-link cart-header-account" href="<?=$loggedIn?'/cliente/perfil.php':'/auth/login.php'?>" aria-label="<?=$loggedIn?h($user['nome']??'Minha conta'):'Entrar ou cadastrar'?>"><svg class="person-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><circle cx="12" cy="8" r="4"/><path d="M4.5 21a7.5 7.5 0 0 1 15 0"/></svg><span class="account-trigger-label"><?=$loggedIn?h($user['nome']??'Minha conta'):'Entrar / Cadastrar'?></span></a>
            <a class="icon-link cart-header-cart" href="/cliente/carrinho.php" aria-label="Carrinho de compras"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 4h2l2.2 11.2a2 2 0 0 0 2 1.6h8.9a2 2 0 0 0 1.9-1.4L22 8H6"/><circle cx="10" cy="20" r="1"/><circle cx="18" cy="20" r="1"/></svg><span data-cart-count>0</span></a>
        </header>
    </div>
    <div class="category-bar cart-category-bar"><nav class="container nav" aria-label="Categorias"><button class="category-menu-toggle cart-all-categories" type="button" data-cart-category-toggle aria-expanded="false" aria-controls="cart-category-menu"><b>☰</b> Todas as Categorias <span aria-hidden="true">⌄</span></button><div class="category-marquee"><div class="category-marquee-track"><div class="category-marquee-set"><?php foreach($categories as $category):if($category['slug']==='jornal')continue;?><a href="/#produtos" data-cart-category="<?=h($category['slug'])?>"><?=h($category['nome'])?></a><?php endforeach;?></div><div class="category-marquee-set" aria-hidden="true"><?php foreach($categories as $category):if($category['slug']==='jornal')continue;?><a href="/#produtos" tabindex="-1" data-cart-category="<?=h($category['slug'])?>"><?=h($category['nome'])?></a><?php endforeach;?></div></div></div></nav>
        <div class="category-mega-menu container" id="cart-category-menu" hidden>
            <a class="category-mega-link" href="/?categoria=ofertas#ofertas"><strong>Ofertas do Dia</strong><span>Destaques promocionais da semana e combos especiais.</span></a>
            <a class="category-mega-link" href="/?categoria=hortifruti#produtos"><strong>Hortifrúti &amp; Orgânicos</strong><span>Frutas, legumes, verduras, temperos verdes e ovos caipiras.</span></a>
            <a class="category-mega-link" href="/?categoria=padaria#produtos"><strong>Padaria &amp; Confeitaria</strong><span>Pães artesanais, bolos, salgados assados, biscoitos e torradas.</span></a>
            <a class="category-mega-link" href="/?categoria=acougue,peixaria#produtos"><strong>Açougue &amp; Peixaria</strong><span>Carnes, aves, linguiças, itens para churrasco e filés de peixe.</span></a>
            <a class="category-mega-link" href="/?categoria=frios-laticinios#produtos"><strong>Frios &amp; Laticínios</strong><span>Queijos, presuntos, requeijão, leites, iogurtes e manteigas.</span></a>
            <a class="category-mega-link" href="/?categoria=mercearia-graos#produtos"><strong>Mercearia &amp; Grãos</strong><span>Arroz, feijão, massas, farinhas, cafés, óleos, molhos e enlatados.</span></a>
            <a class="category-mega-link" href="/?categoria=bebidas#produtos"><strong>Bebidas</strong><span>Sucos, águas, refrigerantes, chás gelados e cervejas.</span></a>
            <a class="category-mega-link" href="/?categoria=limpeza#produtos"><strong>Limpeza &amp; Utilidades</strong><span>Produtos de limpeza, esponjas, sacos de lixo e utilidades.</span></a>
            <a class="category-mega-link" href="/?categoria=higiene-perfumaria#produtos"><strong>Higiene &amp; Perfumaria</strong><span>Sabonetes, shampoos, creme dental, desodorantes e papel higiênico.</span></a>
        </div>
    </div>
</div>

<main class="cart-main">
    <section class="cart-page-title"><h1>Carrinho de Compras</h1><p><a href="/">Início</a><span>/</span>Carrinho de Compras</p></section>
    <div class="container cart-content">
        <?php if($couponMessage):?><p class="cart-coupon-message" role="status"><?=h($couponMessage)?></p><?php endif;?>
        <div class="cart-layout">
            <section class="cart-items-panel" aria-label="Produtos no carrinho">
                <div class="cart-table-head"><span>Produto</span><span>Preço</span><span>Quantidade</span><span>Subtotal</span></div>
                <div id="cart-items"></div>
                <div id="cart-empty" class="cart-empty" hidden><span aria-hidden="true">🛒</span><h2>Seu carrinho está vazio</h2><p>Encontre produtos fresquinhos e adicione ao seu pedido.</p><a class="button" href="/#produtos">Continuar comprando</a></div>
                <div class="cart-coupon-tools">
                    <?php if($loggedIn):?><form method="post" class="cart-coupon-form"><input type="hidden" name="csrf" value="<?=h($csrfToken)?>"><input type="hidden" name="apply_coupon" value="1"><label class="sr-only" for="cart-coupon-code">Código do cupom</label><input id="cart-coupon-code" name="coupon_code" placeholder="Código do cupom" autocomplete="off" required><button type="submit">Aplicar cupom</button></form><?php else:?><a class="cart-login-coupon" href="/auth/login.php?voltar=checkout">Entre na conta para ver seus cupons</a><?php endif;?>
                    <button type="button" class="cart-clear-button" id="clear-cart">Limpar carrinho</button>
                </div>
                <a class="cart-continue" href="/">← Continuar comprando</a>
            </section>
            <aside class="cart-summary" aria-labelledby="cart-summary-title">
                <h2 id="cart-summary-title">Resumo do Pedido</h2>
                <section class="cart-delivery-calculator" aria-label="Calcular entrega" data-delivery-csrf="<?=h($csrfToken)?>">
                    <label for="cart-cep">Calcule a entrega pelo CEP</label>
                    <div class="cart-cep-entry"><input id="cart-cep" type="text" inputmode="numeric" autocomplete="postal-code" maxlength="9" placeholder="00000-000" value="<?=h($shippingCep)?>"><button type="button" id="calculate-cep">Calcular</button></div>
                    <p class="cart-cep-status" id="cart-cep-status" role="status" aria-live="polite"></p>
                    <div class="cart-delivery-options" id="cart-delivery-options" <?=$shippingOptions?'':'hidden'?> data-selected-mode="<?=h($shippingMode)?>">
                        <p id="cart-cep-address" class="cart-cep-address"></p>
                        <label class="cart-delivery-option"><input type="radio" name="cart-delivery-mode" value="expressa"><span><strong>Entrega expressa</strong><small>Prioridade na entrega</small></span><b data-rate="expressa">—</b></label>
                        <label class="cart-delivery-option"><input type="radio" name="cart-delivery-mode" value="agendada"><span><strong>Entrega agendada</strong><small>Programada conforme disponibilidade</small></span><b data-rate="agendada">—</b></label>
                        <label class="cart-delivery-option"><input type="radio" name="cart-delivery-mode" value="retirada"><span><strong>Retirar na loja</strong><small>Retirada gratuita</small></span><b>Grátis</b></label>
                        <div class="cart-schedule-picker" id="cart-schedule-picker" hidden>
                            <strong id="cart-schedule-title">Escolha o dia e horário</strong>
                            <div class="cart-schedule-fields"><label for="cart-schedule-date">Dia disponível<input id="cart-schedule-date" type="date" lang="pt-BR"></label><label for="cart-schedule-time">Horário<select id="cart-schedule-time" disabled><option value="">Selecione o dia primeiro</option></select></label></div>
                            <small id="cart-schedule-days" class="cart-schedule-days"></small>
                            <p id="cart-schedule-status" class="cart-schedule-status" role="status" aria-live="polite"></p>
                        </div>
                    </div>
                </section>
                <dl><div><dt>Itens</dt><dd id="cart-item-count">0</dd></div><div><dt>Subtotal</dt><dd id="cart-subtotal">R$ 0,00</dd></div><div><dt>Frete</dt><dd id="cart-shipping">—</dd></div><div id="cart-discount-row" hidden><dt>Desconto</dt><dd id="cart-discount">− R$ 0,00</dd></div></dl>
                <div class="cart-total"><strong>Total</strong><strong id="cart-total">R$ 0,00</strong></div>
                <p class="cart-shipping-note" id="cart-shipping-note">Digite um CEP válido e escolha a modalidade para ver o total.</p>
                <a class="button cart-checkout-button is-disabled" id="cart-checkout" aria-disabled="true" href="/cliente/checkout.php">Prosseguir para pagamentos</a>
                <small class="cart-checkout-hint">Você poderá revisar seu pedido antes de finalizar.</small>
            </aside>
        </div>
        <section class="cart-benefits" aria-label="Vantagens Alvorada"><div><span aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M4 10h16l-1.5 10h-13L4 10Z"/><path d="m8 10 4-6 4 6M8 14v3M12 14v3M16 14v3"/></svg></span><p><strong>Produtos selecionados</strong><small>Qualidade e frescor para sua casa</small></p></div><div><span aria-hidden="true"><svg viewBox="0 0 24 24"><rect x="2.5" y="5" width="19" height="14" rx="2.5"/><path d="M3 10h18M7 15h4"/></svg></span><p><strong>Pagamento flexível</strong><small>Escolha a forma no checkout</small></p></div><div><span aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M4 13v-1a8 8 0 0 1 16 0v1"/><rect x="3" y="12" width="4" height="7" rx="2"/><rect x="17" y="12" width="4" height="7" rx="2"/><path d="M17 19a5 5 0 0 1-5 3h-1"/></svg></span><p><strong>Atendimento Alvorada</strong><small>Estamos aqui para ajudar</small></p></div></section>
    </div>
</main>

<section class="cart-newsletter" id="newsletter" aria-labelledby="newsletter-title"><div class="container"><p class="cart-newsletter-kicker">Nossa Newsletter</p><h2 id="newsletter-title">Inscreva-se em nossa Newsletter<br>para receber ofertas exclusivas</h2><p class="cart-newsletter-copy">Receba novidades, descontos e ofertas do Supermercado Alvorada diretamente no seu e-mail.</p><?php if($newsletterMessage):?><p class="cart-newsletter-status" role="status"><?=h($newsletterMessage)?></p><?php endif;?><form class="cart-newsletter-form" method="post"><input type="hidden" name="csrf" value="<?=h($csrfToken)?>"><input type="hidden" name="newsletter_signup" value="1"><label class="sr-only" for="newsletter-email">Seu e-mail</label><input id="newsletter-email" name="newsletter_email" type="email" maxlength="190" autocomplete="email" placeholder="Digite seu e-mail" required><button type="submit">Inscrever-se</button></form></div></section>

<footer class="footer cart-footer"><div class="container"><div class="cart-footer-grid">
    <div class="cart-footer-brand"><a class="brand" href="/" aria-label="Alvorada Supermercado"><img class="brand-logo" src="/assets/images/alvorada-logo-rodape.png?v=1" alt="Supermercado Alvorada"></a><p>Qualidade, frescor e economia para o seu dia a dia.</p></div>
    <div><h2>Loja</h2><a href="/#categorias">Categorias</a><a href="/#ofertas">Ofertas do dia</a><a href="/#jornal">Jornal da semana</a></div>
    <div><h2>Minha conta</h2><a href="<?=$loggedIn?'/cliente/perfil.php':'/auth/login.php'?>">Meu perfil</a><a href="/cliente/perfil.php#pedidos">Meus pedidos</a><a href="/cliente/perfil.php#enderecos">Endereços salvos</a></div>
    <div><h2>Atendimento</h2><p>Precisa de ajuda com seu pedido?</p><a href="/cliente/perfil.php#notificacoes">Fale com a equipe Alvorada</a></div>
</div><div class="cart-footer-bottom"><span>© <?=date('Y')?> Supermercado Alvorada</span><a href="/">Voltar à loja</a></div></div></footer>

<script>
const productCatalog=<?=json_encode($products,JSON_HEX_TAG|JSON_HEX_AMP|JSON_HEX_APOS|JSON_HEX_QUOT|JSON_UNESCAPED_UNICODE)?>;
const cartStorageKey='alvorada-cart';
const deliveryStorageKey='alvorada-delivery';
const appliedCoupon=<?=json_encode($appliedCoupon?['id'=>(int)$appliedCoupon['id_cupom'],'code'=>$appliedCoupon['codigo'],'type'=>$appliedCoupon['tipo'],'value'=>(float)$appliedCoupon['valor'],'minimum'=>(float)$appliedCoupon['pedido_minimo']]:null,JSON_HEX_TAG|JSON_HEX_AMP|JSON_HEX_APOS|JSON_HEX_QUOT|JSON_UNESCAPED_UNICODE)?>;
const serverShippingOptions=<?=json_encode($shippingOptions,JSON_HEX_TAG|JSON_HEX_AMP|JSON_HEX_APOS|JSON_HEX_QUOT|JSON_UNESCAPED_UNICODE)?>;
const serverShippingMode=<?=json_encode($shippingMode)?>;
let cart=JSON.parse(localStorage.getItem(cartStorageKey)||'[]');
let delivery=null;
try{delivery=JSON.parse(localStorage.getItem(deliveryStorageKey)||'null')}catch{}
if(!delivery&&serverShippingOptions&&serverShippingMode){delivery={cep:serverShippingOptions.cep,mode:serverShippingMode,fee:Number(serverShippingOptions[serverShippingMode]),rates:serverShippingOptions,schedule:serverShippingOptions.agendamento,deliveryAvailable:serverShippingOptions.entrega_disponivel!==false};}
const money=value=>Number(value||0).toLocaleString('pt-BR',{style:'currency',currency:'BRL'});
const cepInput=document.querySelector('#cart-cep');
const cepStatus=document.querySelector('#cart-cep-status');
const deliveryOptionsPanel=document.querySelector('#cart-delivery-options');
const shippingCsrf=document.querySelector('[data-delivery-csrf]').dataset.deliveryCsrf;
const cartShippingNote=document.querySelector('#cart-shipping-note');
const schedulePicker=document.querySelector('#cart-schedule-picker');
const scheduleDateInput=document.querySelector('#cart-schedule-date');
const scheduleTimeSelect=document.querySelector('#cart-schedule-time');
const scheduleDaysLabel=document.querySelector('#cart-schedule-days');
const scheduleStatus=document.querySelector('#cart-schedule-status');
const scheduleTitle=document.querySelector('#cart-schedule-title');
const weekdayNames=['domingo','segunda-feira','terça-feira','quarta-feira','quinta-feira','sexta-feira','sábado'];
const localDateString=date=>[date.getFullYear(),String(date.getMonth()+1).padStart(2,'0'),String(date.getDate()).padStart(2,'0')].join('-');
function updateSchedulePicker(){
    const schedule=delivery?.schedule;
    if(!schedule){schedulePicker.hidden=true;return;}
    schedulePicker.hidden=!['agendada','retirada'].includes(delivery.mode);
    scheduleTitle.textContent=delivery.mode==='retirada'?'Escolha o dia e horário para retirar':'Escolha o dia e horário da entrega';
    const today=new Date();today.setHours(0,0,0,0);
    const tomorrow=new Date(today);tomorrow.setDate(tomorrow.getDate()+1);
    const lastDay=new Date(today);lastDay.setDate(lastDay.getDate()+30);
    scheduleDateInput.min=localDateString(tomorrow);scheduleDateInput.max=localDateString(lastDay);
    scheduleDaysLabel.textContent='Dias disponíveis: '+(schedule.dias||[]).map(day=>weekdayNames[day%7]).join(', ')+'.';
    if(delivery.scheduleDate&&scheduleDateInput.value!==delivery.scheduleDate)scheduleDateInput.value=delivery.scheduleDate;
    const selected=scheduleDateInput.value;
    scheduleTimeSelect.replaceChildren(new Option('Selecione um horário',''));
    if(!selected){scheduleTimeSelect.disabled=true;scheduleStatus.textContent='Selecione uma data para ver os horários.';return;}
    const day=new Date(selected+'T12:00:00').getDay();
    const weekday=day===0?7:day;
    if(!(schedule.dias||[]).includes(weekday)){
        scheduleTimeSelect.disabled=true;scheduleStatus.textContent='Esse dia não está disponível. Escolha uma das datas com atendimento.';return;
    }
    const availableSlots=delivery.mode==='retirada'?(schedule.horarios_retirada||[]):(schedule.horarios_entrega||[]);
    availableSlots.forEach(slot=>scheduleTimeSelect.add(new Option(slot,slot)));
    scheduleTimeSelect.disabled=availableSlots.length===0;
    if(delivery.scheduleSlot&&availableSlots.includes(delivery.scheduleSlot))scheduleTimeSelect.value=delivery.scheduleSlot;
    else if(delivery.scheduleSlot){delivery.scheduleSlot='';}
    scheduleStatus.textContent=delivery.scheduleSlot?'Horário selecionado.':'Escolha um horário disponível.';
}
function showCepError(message){delivery=null;localStorage.removeItem(deliveryStorageKey);deliveryOptionsPanel.hidden=true;cepStatus.textContent=message;cepStatus.classList.add('is-error');renderCart();alert(message);}
async function persistDelivery(mode,scheduleDate=['agendada','retirada'].includes(mode)?(delivery?.scheduleDate||''):'',scheduleSlot=['agendada','retirada'].includes(mode)?(delivery?.scheduleSlot||''):''){
    if(!delivery?.cep)return false;
    const form=new FormData();form.set('csrf',shippingCsrf);form.set('cep',delivery.cep);form.set('modalidade',mode);form.set('latitude',String(delivery.latitude??''));form.set('longitude',String(delivery.longitude??''));form.set('logradouro',delivery.street??'');form.set('bairro',delivery.district??'');form.set('cidade',delivery.city??'');form.set('uf',delivery.state??'');form.set('data_entrega',scheduleDate);form.set('horario_entrega',scheduleSlot);
    const response=await fetch('/cliente/salvar_entrega.php',{method:'POST',body:form,credentials:'same-origin'});
    const result=await response.json();
    if(!response.ok||!result.ok)throw new Error(result.message||'Não foi possível salvar a opção de entrega.');
    delivery={...delivery,mode:result.modalidade,fee:Number(result.frete),rates:result.opcoes,distanceKm:Number(result.opcoes.distancia_km),deliveryAvailable:result.opcoes.entrega_disponivel!==false,schedule:result.opcoes.agendamento||delivery.schedule,scheduleDate:result.data_entrega||'',scheduleSlot:result.horario_entrega||''};
    document.querySelector('#cart-shipping').textContent=mode==='retirada'?'Grátis':money(result.frete);
    localStorage.setItem(deliveryStorageKey,JSON.stringify(delivery));
    document.querySelector(`[name="cart-delivery-mode"][value="${mode}"]`).checked=true;
    document.querySelectorAll('[data-rate]').forEach(rate=>rate.textContent=result.opcoes[rate.dataset.rate]===null?'Indisponível':money(result.opcoes[rate.dataset.rate]));
    document.querySelectorAll('[name="cart-delivery-mode"]').forEach(option=>{option.disabled=!delivery.deliveryAvailable&&option.value!=='retirada';});
    updateSchedulePicker();
    deliveryOptionsPanel.hidden=false;cepStatus.classList.remove('is-error');
    renderCart();
    return true;
}
async function lookupCep(){
    const digits=cepInput.value.replace(/\D/g,'');
    if(digits.length!==8){showCepError('Digite um CEP válido com 8 números.');return;}
    cepStatus.classList.remove('is-error');cepStatus.textContent='Consultando CEP…';
    const calculateButton=document.querySelector('#calculate-cep');calculateButton.disabled=true;
    try{
        const response=await fetch(`https://brasilapi.com.br/api/cep/v2/${digits}`,{headers:{Accept:'application/json'}});
        if(response.status===404)throw new Error('CEP nao encontrado.');
        if(!response.ok)throw new Error('Não foi possível consultar o CEP agora. Tente novamente.');
        const address=await response.json();
        const latitude=Number(address.location?.coordinates?.latitude);
        const longitude=Number(address.location?.coordinates?.longitude);
        if(!Number.isFinite(latitude)||!Number.isFinite(longitude))throw new Error('CEP sem coordenadas para calcular frete.');
        if(address.erro){showCepError('CEP não encontrado. Confira os números e tente novamente.');return;}
        const mode=delivery?.mode||serverShippingMode||'expressa';
        delivery={cep:digits,latitude,longitude,street:address.street||'',district:address.neighborhood||'',city:address.city||'',state:address.state||'',mode};
        document.querySelector('#cart-cep-address').textContent=[address.street,address.neighborhood,address.city,address.state].filter(Boolean).join(' · ');
        await persistDelivery(mode);
        cepStatus.textContent='CEP localizado a '+Number(delivery.distanceKm).toFixed(1)+' km da loja. Escolha como deseja receber seu pedido.';
    }catch(error){
        if(error instanceof TypeError)showCepError('Não foi possível consultar o CEP. Verifique sua conexão e tente novamente.');
        else if(error.message.includes('fora da nossa área')){
            try{delivery.mode='retirada';await persistDelivery('retirada');cepStatus.textContent='CEP válido, mas fora da área de entrega. A retirada na loja está disponível gratuitamente.';}
            catch(pickupError){showCepError(pickupError.message);}
        }
        else showCepError(error.message||'Não foi possível calcular o frete. Tente novamente.');
    }finally{calculateButton.disabled=false;}
}
function renderCart(){
    const list=document.querySelector('#cart-items');
    const valid=cart.filter(item=>productCatalog[item.id]);
    cart=valid;
    list.replaceChildren();
    let subtotal=0,totalItems=0;
    cart.forEach((item,index)=>{
        const product=productCatalog[item.id];
        const quantity=Math.max(0,Number(item.qty)||0);
        const lineTotal=Number(product.preco_unitario)*quantity;
        subtotal+=lineTotal;totalItems+=quantity;
        const row=document.createElement('article');row.className='cart-product-row';
        const image=document.createElement('img');image.className='cart-product-image';image.src=product.imagem_url||'/assets/images/produto-placeholder.png';image.alt=product.nome;image.loading='lazy';image.onerror=()=>{image.onerror=null;image.src='https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=160&q=75';};
        const details=document.createElement('div');details.className='cart-product-details';
        const name=document.createElement('strong');name.textContent=product.nome;
        const unit=document.createElement('small');unit.textContent=product.tipo_medida==='KG'?'Vendido por kg':'Unidade';
        details.append(name,unit);
        const price=document.createElement('span');price.className='cart-product-price';price.textContent=money(product.preco_unitario);
        const quantityControl=document.createElement('div');quantityControl.className='cart-quantity-control';
        const step=product.tipo_medida==='KG'?0.5:1;
        const decrease=document.createElement('button');decrease.type='button';decrease.textContent='−';decrease.setAttribute('aria-label','Diminuir quantidade');
        const qty=document.createElement('span');qty.textContent=product.tipo_medida==='KG'?quantity.toLocaleString('pt-BR',{maximumFractionDigits:3}):String(quantity);
        const increase=document.createElement('button');increase.type='button';increase.textContent='+';increase.setAttribute('aria-label','Aumentar quantidade');
        decrease.onclick=()=>{item.qty=Math.max(product.tipo_medida==='KG'?step:1,quantity-step);renderCart();};
        increase.onclick=()=>{item.qty=quantity+step;renderCart();};
        quantityControl.append(decrease,qty,increase);
        const lineSubtotal=document.createElement('strong');lineSubtotal.className='cart-product-subtotal';lineSubtotal.textContent=money(lineTotal);
        const remove=document.createElement('button');remove.className='cart-remove';remove.type='button';remove.textContent='×';remove.setAttribute('aria-label','Remover '+product.nome);remove.onclick=()=>{cart.splice(index,1);renderCart();};
        row.append(remove,image,details,price,quantityControl,lineSubtotal);list.append(row);
    });
    const empty=cart.length===0;
    document.querySelector('#cart-empty').hidden=!empty;
    document.querySelector('.cart-table-head').hidden=empty;
    document.querySelector('.cart-coupon-tools').hidden=empty;
    document.querySelector('#cart-item-count').textContent=totalItems.toLocaleString('pt-BR',{maximumFractionDigits:3});
    document.querySelector('#cart-subtotal').textContent=money(subtotal);
    const deliveryReady=Boolean(delivery&&delivery.cep&&delivery.mode&&Number.isFinite(Number(delivery.fee)));
    const deliveryFee=deliveryReady?Number(delivery.fee):0;
    const displayedFreight=deliveryReady?(delivery.mode==='retirada'?'Grátis':money(deliveryFee)):'—';
    document.querySelector('#cart-shipping').textContent=displayedFreight;
    let discount=0;
    if(appliedCoupon&&subtotal>=appliedCoupon.minimum){discount=appliedCoupon.type==='percentual'?subtotal*appliedCoupon.value/100:appliedCoupon.value;discount=Math.min(discount,subtotal);}
    const discountRow=document.querySelector('#cart-discount-row');
    discountRow.hidden=discount<=0;
    document.querySelector('#cart-discount').textContent='− '+money(discount);
    document.querySelector('#cart-total').textContent=money(Math.max(0,subtotal+deliveryFee-discount));
    const scheduleReady=!['agendada','retirada'].includes(delivery?.mode)||Boolean(delivery.scheduleDate&&delivery.scheduleSlot);
    const checkoutDisabled=empty||!deliveryReady||!scheduleReady;
    document.querySelector('#cart-checkout').setAttribute('aria-disabled',String(checkoutDisabled));
    document.querySelector('#cart-checkout').classList.toggle('is-disabled',checkoutDisabled);
    cartShippingNote.textContent=deliveryReady?`Entrega: ${delivery.mode==='expressa'?'expressa':delivery.mode==='agendada'?'agendada':'retirada na loja'} · CEP ${delivery.cep.slice(0,5)}-${delivery.cep.slice(5)}.${delivery.mode==='agendada'&&delivery.scheduleDate&&delivery.scheduleSlot?' Data: '+delivery.scheduleDate.split('-').reverse().join('/')+' · '+delivery.scheduleSlot+'.':''}`:'Digite um CEP válido e escolha a modalidade para ver o total.';
    document.querySelectorAll('[data-cart-count]').forEach(badge=>badge.textContent=String(cart.reduce((sum,item)=>sum+(Number(item.qty)||0),0)));
    localStorage.setItem(cartStorageKey,JSON.stringify(cart));
}
document.querySelector('#clear-cart').addEventListener('click',()=>{cart=[];renderCart();});
let cepLookupTimer=null;
document.querySelector('#calculate-cep').addEventListener('click',()=>{clearTimeout(cepLookupTimer);lookupCep();});
cepInput.addEventListener('input',()=>{const digits=cepInput.value.replace(/\D/g,'').slice(0,8);cepInput.value=digits.length>5?digits.slice(0,5)+'-'+digits.slice(5):digits;if(digits.length===8){clearTimeout(cepLookupTimer);cepLookupTimer=setTimeout(lookupCep,450);}});
cepInput.addEventListener('keydown',event=>{if(event.key==='Enter'){event.preventDefault();lookupCep();}});
document.querySelectorAll('[name="cart-delivery-mode"]').forEach(input=>input.addEventListener('change',async()=>{delivery.mode=input.value;delivery.fee=input.value==='retirada'?0:Number(delivery.rates?.[input.value]??delivery.fee);if(!['agendada','retirada'].includes(input.value)){delivery.scheduleDate='';delivery.scheduleSlot='';}updateSchedulePicker();renderCart();try{await persistDelivery(input.value);}catch(error){scheduleStatus.textContent=error.message;}}));
scheduleDateInput.addEventListener('change',async()=>{delivery.scheduleDate=scheduleDateInput.value;delivery.scheduleSlot='';scheduleTimeSelect.value='';updateSchedulePicker();renderCart();if(delivery.scheduleDate){try{await persistDelivery(delivery.mode,delivery.scheduleDate,'');}catch(error){scheduleStatus.textContent=error.message;}}else{await persistDelivery(delivery.mode,'','');}});
scheduleTimeSelect.addEventListener('change',async()=>{delivery.scheduleSlot=scheduleTimeSelect.value;renderCart();if(!delivery.scheduleDate||!delivery.scheduleSlot)return;try{await persistDelivery(delivery.mode,delivery.scheduleDate,delivery.scheduleSlot);}catch(error){scheduleStatus.textContent=error.message;}});
document.querySelector('#cart-checkout').addEventListener('click',async event=>{
    event.preventDefault();
    if(!cart.length){document.querySelector('#cart-empty').scrollIntoView({behavior:'smooth',block:'center'});return;}
    if(!delivery?.cep){showCepError('Informe e valide seu CEP antes de prosseguir.');return;}
    if(['agendada','retirada'].includes(delivery.mode)&&(!delivery.scheduleDate||!delivery.scheduleSlot)){schedulePicker.hidden=false;scheduleStatus.textContent=delivery.mode==='retirada'?'Selecione uma data e um horário para retirar seu pedido.':'Selecione uma data e um horário para a entrega agendada.';schedulePicker.scrollIntoView({behavior:'smooth',block:'center'});return;}
    try{await persistDelivery(delivery.mode,delivery.scheduleDate||'',delivery.scheduleSlot||'');window.location.href='/cliente/checkout.php';}
    catch(error){showCepError(error.message);}
});
const categoryToggle=document.querySelector('[data-cart-category-toggle]');
const categoryMenu=document.querySelector('#cart-category-menu');
const closeCategoryMenu=()=>{categoryToggle.setAttribute('aria-expanded','false');categoryMenu.hidden=true;};
categoryToggle.addEventListener('click',()=>{const open=categoryToggle.getAttribute('aria-expanded')!=='true';categoryToggle.setAttribute('aria-expanded',String(open));categoryMenu.hidden=!open;});
document.addEventListener('click',event=>{if(!event.target.closest('.cart-category-bar'))closeCategoryMenu();});
document.addEventListener('keydown',event=>{if(event.key==='Escape')closeCategoryMenu();});
renderCart();
if(delivery){const selectedMode=document.querySelector(`[name="cart-delivery-mode"][value="${delivery.mode}"]`);if(selectedMode)selectedMode.checked=true;updateSchedulePicker();}
if(delivery?.cep){cepInput.value=delivery.cep.slice(0,5)+'-'+delivery.cep.slice(5);lookupCep();}
</script>
</body>
</html>
