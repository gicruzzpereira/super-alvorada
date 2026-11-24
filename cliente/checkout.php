<?php
require_once __DIR__.'/../config/conexao.php';
require_once __DIR__.'/../config/entrega.php';
$user=$_SESSION['usuario']??null;
$loggedIn=($user['perfil']??'')==='cliente';
$storedCustomerCart=null;
if($loggedIn){try{$stateQuery=db()->prepare('SELECT carrinho_json FROM cliente_estado_site WHERE id_usuario=?');$stateQuery->execute([(int)$user['id_usuario']]);$stateJson=$stateQuery->fetchColumn();if($stateJson!==false&&$stateJson!==null){$decoded=json_decode((string)$stateJson,true);$storedCustomerCart=is_array($decoded)?$decoded:[];}}catch(Throwable $e){}}
else{try{$stateQuery=db()->prepare('SELECT carrinho_json FROM visitante_estado_site WHERE session_token=? AND expira_em>NOW()');$stateQuery->execute([siteGuestToken()]);$stateJson=$stateQuery->fetchColumn();if($stateJson!==false&&$stateJson!==null){$decoded=json_decode((string)$stateJson,true);$storedCustomerCart=is_array($decoded)?$decoded:[];}}catch(Throwable $e){}}
if($user&&!$loggedIn){http_response_code(403);exit('Esta etapa está disponível para contas de cliente.');}
$allowedPayments=['pix','cartao_credito','dinheiro_entrega'];
$payment=$_SESSION['checkout_payment']??'pix';
if(!in_array($payment,$allowedPayments,true))$payment='pix';
$selectedCoupon=(int)($_SESSION['checkout_coupon']??($_GET['cupom']??0));
$deliveryMode=(string)($_SESSION['entrega_modalidade']??'');
$deliveryCep=(string)($_SESSION['entrega_cep']??'');
$deliveryDate=(string)($_SESSION['entrega_data']??'');
$deliverySlot=(string)($_SESSION['entrega_horario']??'');
$frete=5.0;
$pdo=null;
$products=[];
$ends=[];
$checkoutCoupons=[];
$msg='';
try{
    $pdo=db();
    $configuredFrete=$pdo->query("SELECT valor FROM configuracoes WHERE chave='frete_padrao'")->fetchColumn();
    if($configuredFrete!==false)$frete=(float)$configuredFrete;
    if(!$deliveryMode)$frete=0.0;
    if($deliveryCep&&in_array($deliveryMode,['expressa','agendada','retirada'],true)){$deliveryRates=opcoesFretePorCep($pdo,$deliveryCep,$deliveryMode==='retirada');$frete=(float)$deliveryRates[$deliveryMode];}
    $products=$pdo->query('SELECT id_produto,nome,tipo_medida,preco_unitario FROM produtos WHERE ativo=1 ORDER BY nome')->fetchAll();
    if($loggedIn){
        $q=$pdo->prepare('SELECT * FROM enderecos WHERE id_usuario=? ORDER BY id_endereco DESC');
        $q->execute([(int)$user['id_usuario']]);
        $ends=$q->fetchAll();
        $q=$pdo->prepare('SELECT c.* FROM cupons c JOIN cupons_clientes cc USING(id_cupom) WHERE cc.id_usuario=? AND cc.usado_em IS NULL AND c.ativo=1 AND (c.validade IS NULL OR c.validade>=CURRENT_DATE) AND (c.limite_usos IS NULL OR c.usos<c.limite_usos) ORDER BY c.codigo');
        $q->execute([(int)$user['id_usuario']]);$checkoutCoupons=$q->fetchAll();
        if($selectedCoupon&&!array_filter($checkoutCoupons,fn($coupon)=>(int)$coupon['id_cupom']===$selectedCoupon))$selectedCoupon=0;
    }
}catch(Throwable $e){$msg='Não foi possível carregar os dados do checkout. Tente novamente.';}
$matchingEnds=[];
if($deliveryMode!=='retirada'&&$deliveryCep){foreach($ends as $savedAddress){if(preg_replace('/\D/','',$savedAddress['cep'])===preg_replace('/\D/','',$deliveryCep))$matchingEnds[]=$savedAddress;}}
$checkoutCsrf=csrf();
if($_SERVER['REQUEST_METHOD']==='POST'){
    validarCsrf();
    $requestedPayment=$_POST['pagamento']??'pix';
    $payment=in_array($requestedPayment,$allowedPayments,true)?$requestedPayment:'pix';
    $selectedCoupon=(int)($_POST['cupom']??$selectedCoupon);
    if($selectedCoupon>0)$_SESSION['checkout_coupon']=$selectedCoupon;else unset($_SESSION['checkout_coupon']);
    if($pdo&&$deliveryCep&&in_array($deliveryMode,['expressa','agendada','retirada'],true)){try{$deliveryRates=opcoesFretePorCep($pdo,$deliveryCep,$deliveryMode==='retirada');$frete=(float)$deliveryRates[$deliveryMode];}catch(Throwable $e){$deliveryMode='';$frete=0.0;}}
    if(!$loggedIn){
        $_SESSION['checkout_payment']=$payment;
        header('Location: /auth/login.php?voltar=checkout');
        exit;
    }
    if(in_array($payment,['pix','cartao_credito'],true)){
        $_SESSION['checkout_payment']=$payment;
        $msg='Pagamento demonstrativo: a integração ainda não está ativa. Nenhum pedido ou cobrança foi criado.';
    }
    elseif(!$pdo){$msg='Não foi possível carregar os dados do checkout. Tente novamente.';}
    else{
    $cart=json_decode($_POST['cart']??'[]',true);
    $end=null;
    if($deliveryMode==='retirada'){$addr=['cep'=>substr($deliveryCep,0,5).'-'.substr($deliveryCep,5)];}
    else{$end=(int)($_POST['endereco']??0);$q=$pdo->prepare('SELECT * FROM enderecos WHERE id_endereco=? AND id_usuario=?');$q->execute([$end,(int)$user['id_usuario']]);$addr=$q->fetch();if($addr&&preg_replace('/\D/','',$addr['cep'])!==preg_replace('/\D/','',$deliveryCep))$addr=false;}
    if(!$addr)$msg='Selecione um endereço de entrega válido.';
    elseif(!preg_match('/^\d{5}-?\d{3}$/',$addr['cep']))$msg='CEP inválido.';
    else{
        if(!$cart||!is_array($cart))$msg='Seu carrinho está vazio.';
        else try{
            if(in_array($deliveryMode,['agendada','retirada'],true)&&(!$deliveryDate||!$deliverySlot||!validarHorarioAgendamento($pdo,$deliveryDate,$deliverySlot,$deliveryMode)))throw new RuntimeException($deliveryMode==='retirada'?'Escolha uma data e um horário disponíveis para a retirada.':'Escolha uma data e um horário disponíveis para a entrega agendada.');
            $pdo->beginTransaction();
            $sum=0;
            $lines=[];
            $st=$pdo->prepare('SELECT * FROM produtos WHERE id_produto=? AND ativo=1 FOR UPDATE');
            foreach($cart as $item){
                if(!is_array($item)||!isset($item['id'],$item['qty']))throw new RuntimeException('O carrinho contém um item inválido.');
                $st->execute([(int)$item['id']]);
                $product=$st->fetch();
                $qty=(float)$item['qty'];
                if(!$product||$qty<=0||($product['tipo_medida']==='UN'&&$qty!=floor($qty))||$product['estoque_qtd']<$qty)throw new RuntimeException('Um item não está mais disponível na quantidade desejada.');
                $sum+=$qty*(float)$product['preco_unitario'];
                $lines[]=[$product,$qty];
            }
            $coupon=null;$discount=0.0;
            if($selectedCoupon){
                $couponQuery=$pdo->prepare('SELECT c.* FROM cupons c JOIN cupons_clientes cc USING(id_cupom) WHERE c.id_cupom=? AND cc.id_usuario=? AND cc.usado_em IS NULL AND c.ativo=1 AND (c.validade IS NULL OR c.validade>=CURRENT_DATE) AND (c.limite_usos IS NULL OR c.usos<c.limite_usos) FOR UPDATE');
                $couponQuery->execute([$selectedCoupon,(int)$user['id_usuario']]);$coupon=$couponQuery->fetch();
                if(!$coupon)throw new RuntimeException('O cupom escolhido não está mais disponível.');
                if($sum<(float)$coupon['pedido_minimo'])throw new RuntimeException('O pedido não atingiu o valor mínimo para usar esse cupom.');
                $discount=$coupon['tipo']==='percentual'?$sum*(float)$coupon['valor']/100:(float)$coupon['valor'];
                $discount=min($sum,$discount);
            }
            $total=max(0,$sum+$frete-$discount);
            $ins=$pdo->prepare("INSERT INTO pedidos(id_cliente,id_endereco,id_cupom,valor_desconto,status,valor_subtotal,valor_frete,valor_total,metodo_pagamento,modalidade_entrega,cep_entrega,data_entrega,horario_entrega,pin_entrega) VALUES(?,?,?,?,'pendente',?,?,?,?,?,?,?,?,?)");
            $hasSchedule=in_array($deliveryMode,['agendada','retirada'],true);
            $orderCode=gerarCodigoPedidoSeguro($pdo);
            $ins->execute([(int)$user['id_usuario'],$end,$coupon?(int)$coupon['id_cupom']:null,$discount,$sum,$frete,$total,$payment,$deliveryMode,$deliveryCep?(substr($deliveryCep,0,5).'-'.substr($deliveryCep,5)):null,$hasSchedule?$deliveryDate:null,$hasSchedule?$deliverySlot:null,$orderCode]);
            $order=(int)$pdo->lastInsertId();
            $itemInsert=$pdo->prepare('INSERT INTO itens_pedido(id_pedido,id_produto,qtd_solicitada,preco_aplicado) VALUES(?,?,?,?)');
            $decrease=$pdo->prepare('UPDATE produtos SET estoque_qtd=estoque_qtd-? WHERE id_produto=?');
            foreach($lines as [$product,$qty]){
                $itemInsert->execute([$order,$product['id_produto'],$qty,$product['preco_unitario']]);
                $decrease->execute([$qty,$product['id_produto']]);
            }
            if($coupon){
                $claimed=$pdo->prepare('UPDATE cupons_clientes SET id_pedido=?,usado_em=NOW() WHERE id_usuario=? AND id_cupom=? AND usado_em IS NULL');$claimed->execute([$order,(int)$user['id_usuario'],(int)$coupon['id_cupom']]);
                if($claimed->rowCount()!==1)throw new RuntimeException('O cupom já foi usado ou não está mais disponível.');
                $pdo->prepare('UPDATE cupons SET usos=usos+1 WHERE id_cupom=?')->execute([(int)$coupon['id_cupom']]);
            }
            $pdo->commit();
            unset($_SESSION['checkout_payment'],$_SESSION['checkout_coupon'],$_SESSION['entrega_cep'],$_SESSION['entrega_modalidade'],$_SESSION['entrega_frete'],$_SESSION['entrega_data'],$_SESSION['entrega_horario']);
            header('Location: /cliente/pedidos.php?pedido='.$order.'&compra=finalizada');
            exit;
        }catch(Throwable $e){
            if($pdo->inTransaction())$pdo->rollBack();
            $msg=$e instanceof RuntimeException?$e->getMessage():'Não foi possível concluir o pedido.';
        }
    }
    }
}
?>
<!doctype html>
<html lang="pt-BR">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Checkout e pagamento · Alvorada</title>
    <link rel="stylesheet" href="/assets/css/style.css?v=44">
</head>
<body>
<main class="container checkout-page">
    <p><a href="/cliente/carrinho.php">← Voltar ao carrinho</a></p>
    <div class="checkout-layout">
        <section class="checkout-panel checkout-summary" aria-labelledby="checkout-summary-title">
            <h1 id="checkout-summary-title">Seus produtos</h1>
            <div class="checkout-items" data-checkout-items></div>
            <p class="checkout-empty muted" data-checkout-empty>Seu carrinho está vazio.</p>
            <div class="checkout-total-row"><span>Subtotal</span><strong data-checkout-subtotal>R$ 0,00</strong></div>
            <div class="checkout-total-row checkout-coupon-total" data-coupon-total hidden><span>Desconto do cupom</span><strong data-coupon-discount>− R$ 0,00</strong></div>
            <div class="checkout-total-row"><span>Frete</span><strong><?=$deliveryMode?dinheiro($frete):'Escolha no carrinho'?></strong></div>
            <?php if($deliveryMode):?><div class="checkout-total-row"><span>Entrega</span><strong><?=h($deliveryMode==='expressa'?'Expressa':($deliveryMode==='agendada'?'Agendada':'Retirada na loja'))?></strong></div><?php endif;?>
            <div class="checkout-total-row checkout-grand-total"><span>Total</span><strong data-checkout-total>R$ 0,00</strong></div>
        </section>
        <section class="checkout-panel" aria-labelledby="checkout-title">
            <h1 id="checkout-title">Checkout e pagamento</h1>
            <?php if($msg): ?><div class="notice" role="alert"><?=h($msg)?></div><?php endif; ?>
            <?php if(!$deliveryMode): ?>
                <div class="notice" role="alert">Informe e valide o CEP no carrinho para escolher a modalidade de entrega.</div>
                <a class="button light" href="/cliente/carrinho.php">Voltar ao carrinho</a>
            <?php elseif(!$loggedIn): ?>
                <div class="notice">Para finalizar seu pedido, entre na sua conta ou crie um cadastro. Sua escolha de pagamento será mantida.</div>
                <p class="checkout-auth-links"><a href="/auth/login.php?voltar=checkout">Entrar</a><span>ou</span><a href="/auth/cadastro.php?voltar=checkout">Criar conta</a></p>
            <?php elseif($deliveryMode==='retirada'): ?>
                <div class="notice success">Retirada gratuita selecionada. Seu pedido estará disponível para retirada na loja.</div>
            <?php elseif(!$matchingEnds): ?>
                <div class="notice">Cadastre um endereço de entrega antes de finalizar o pedido.</div>
                <a class="button" href="/cliente/pedidos.php?voltar=checkout">Adicionar endereço</a>
            <?php else: ?>
                <label class="checkout-label" for="endereco">Endereço de entrega
                    <select id="endereco" name="endereco" form="checkout-form" required>
                        <?php foreach($matchingEnds as $address): ?><option value="<?=$address['id_endereco']?>"><?=h($address['logradouro'].' '.$address['numero'].', '.$address['bairro'].' · '.$address['cep'])?></option><?php endforeach; ?>
                    </select>
                </label>
                <p class="checkout-shipping">Frete: <strong><?=dinheiro($frete)?></strong>. Entrega disponível em até 50 km da loja; acima dessa distância, somente retirada grátis.</p>
            <?php endif; ?>
            <form method="post" class="checkout-payment-form" id="checkout-form">
                <input type="hidden" name="csrf" value="<?=h($checkoutCsrf)?>">
                <input type="hidden" name="cart" id="checkout-cart">
                <input type="hidden" name="delivery_mode" value="<?=h($deliveryMode)?>">
                <input type="hidden" name="delivery_cep" value="<?=h($deliveryCep)?>">
                <?php if($loggedIn):?><label class="checkout-label" for="checkout-coupon">Cupom de desconto<select id="checkout-coupon" name="cupom"><option value="0">Não usar cupom</option><?php foreach($checkoutCoupons as $coupon):?><option value="<?=$coupon['id_cupom']?>" data-type="<?=h($coupon['tipo'])?>" data-value="<?=$coupon['valor']?>" data-minimum="<?=$coupon['pedido_minimo']?>" <?=$selectedCoupon===(int)$coupon['id_cupom']?'selected':''?>><?=h($coupon['codigo'].' · '.$coupon['titulo'])?> (<?=$coupon['tipo']==='percentual'?rtrim(rtrim(number_format((float)$coupon['valor'],2,'.',''),'0'),'.').'%':dinheiro((float)$coupon['valor'])?> off)</option><?php endforeach;?></select></label><p class="checkout-coupon-warning" data-coupon-warning hidden></p><?php endif;?>
                <label class="checkout-label" for="pagamento">Forma de pagamento
                    <select id="pagamento" name="pagamento">
                        <option value="pix" <?=$payment==='pix'?'selected':''?>>PIX</option>
                        <option value="cartao_credito" <?=$payment==='cartao_credito'?'selected':''?>>Cartão de crédito</option>
                        <option value="dinheiro_entrega" <?=$payment==='dinheiro_entrega'?'selected':''?>>Dinheiro / maquininha na entrega</option>
                    </select>
                </label>
                <section class="payment-detail" data-payment-detail="pix" aria-live="polite">
                    <div class="payment-detail-head"><span class="payment-mark">PIX</span><div><strong>Pague com PIX</strong><small>QR Code demonstrativo</small></div></div>
                    <p>O QR Code abaixo serve apenas para demonstração da tela. Ainda não existe cobrança PIX conectada a este site.</p>
                    <div class="pix-demo-box"><img data-pix-qr alt="QR Code PIX demonstrativo" width="190" height="190"><code data-pix-code></code></div>
                    <button type="button" class="copy-pix-code" data-copy-pix>Copiar código demonstrativo</button>
                </section>
                <section class="payment-detail" data-payment-detail="cartao_credito" aria-live="polite" hidden>
                    <div class="payment-detail-head"><span class="payment-mark card-mark">▰</span><div><strong>Dados do cartão</strong><small>Não serão enviados nem armazenados</small></div></div>
                    <div class="card-preview"><span>ALVORADA</span><strong data-card-preview-number>•••• •••• •••• ••••</strong><div><span data-card-preview-name>NOME NO CARTÃO</span><span data-card-preview-expiry>MM/AA</span></div></div>
                    <label class="checkout-label" for="card-name">Nome impresso no cartão<input class="payment-input" id="card-name" autocomplete="cc-name" placeholder="Como aparece no cartão"></label>
                    <label class="checkout-label" for="card-number">Número do cartão<input class="payment-input" id="card-number" inputmode="numeric" autocomplete="cc-number" maxlength="19" placeholder="0000 0000 0000 0000"></label>
                    <div class="form-row"><label class="checkout-label" for="card-expiry">Validade<input class="payment-input" id="card-expiry" inputmode="numeric" autocomplete="cc-exp" maxlength="5" placeholder="MM/AA"></label><label class="checkout-label" for="card-cvv">CVV<input class="payment-input" id="card-cvv" inputmode="numeric" autocomplete="cc-csc" maxlength="4" placeholder="123"></label></div>
                    <label class="checkout-label" for="card-installments">Parcelas<select class="payment-input" id="card-installments"><option>1x sem juros</option><option>2x sem juros</option><option>3x sem juros</option></select></label>
                </section>
                <section class="payment-detail payment-cash" data-payment-detail="dinheiro_entrega" aria-live="polite" hidden>
                    <strong>Pagamento na entrega</strong><p>Escolha dinheiro ou cartão na maquininha quando receber seu pedido.</p>
                </section>
                <?php if(!$loggedIn): ?>
                    <button type="submit" class="checkout-submit">Entrar para finalizar pedido</button>
                <?php elseif($ends): ?>
                    <button type="submit" class="checkout-submit">Finalizar compra</button>
                <?php endif; ?>
            </form>
        </section>
    </div>
</main>
<script>
const checkoutProducts=<?=json_encode($products,JSON_HEX_TAG|JSON_HEX_AMP|JSON_HEX_APOS|JSON_HEX_QUOT|JSON_UNESCAPED_UNICODE)?>;
let checkoutCart=[];
try{checkoutCart=<?= $storedCustomerCart===null?"JSON.parse(localStorage.getItem('alvorada-cart')||'[]')":json_encode($storedCustomerCart,JSON_HEX_TAG|JSON_HEX_AMP|JSON_HEX_APOS|JSON_HEX_QUOT|JSON_UNESCAPED_UNICODE) ?>}catch{}
const customerStateCsrf=<?=json_encode($checkoutCsrf)?>;
const checkoutCatalog=new Map(checkoutProducts.map(product=>[Number(product.id_produto),product]));
const money=value=>Number(value).toLocaleString('pt-BR',{style:'currency',currency:'BRL'});
const checkoutLines=document.querySelector('[data-checkout-items]');
let checkoutSubtotal=0;
checkoutCart=checkoutCart.filter(item=>item&&(checkoutCatalog.has(Number(item.id))||item.encarte===true)&&Number(item.qty)>0);
if(customerStateCsrf){let favorites=[],location=null;try{favorites=JSON.parse(localStorage.getItem('alvorada-favorites')||'[]');location=JSON.parse(localStorage.getItem('alvorada-delivery-location')||'null')}catch{}fetch('/api/cliente_estado.php',{method:'POST',credentials:'same-origin',headers:{'Content-Type':'application/json','X-CSRF-Token':customerStateCsrf},body:JSON.stringify({cart:checkoutCart,favorites,location})}).catch(()=>{});}
checkoutCart.forEach(item=>{
    const product=checkoutCatalog.get(Number(item.id))||{nome:item.name,tipo_medida:item.unit||'UN',preco_unitario:item.price};
    const lineTotal=Number(product.preco_unitario)*Number(item.qty);
    checkoutSubtotal+=lineTotal;
    const row=document.createElement('div');
    row.className='checkout-item';
    const title=document.createElement('strong');
    title.textContent=product.nome;
    const quantity=document.createElement('span');
    quantity.textContent=`${Number(item.qty).toLocaleString('pt-BR')} ${product.tipo_medida}`;
    const price=document.createElement('strong');
    price.textContent=money(lineTotal);
    row.append(title,quantity,price);
    checkoutLines.append(row);
});
const checkoutFreight=<?=json_encode($frete)?>;
const checkoutCoupon=document.querySelector('#checkout-coupon');
const couponTotal=document.querySelector('[data-coupon-total]');
const couponDiscountText=document.querySelector('[data-coupon-discount]');
const couponWarning=document.querySelector('[data-coupon-warning]');
function updateCheckoutTotal(){let discount=0;const option=checkoutCoupon?.selectedOptions[0];if(option&&Number(option.value)>0){const minimum=Number(option.dataset.minimum||0);if(checkoutSubtotal<minimum){couponTotal.hidden=true;if(couponWarning){couponWarning.hidden=false;couponWarning.textContent=`Este cupom exige um pedido mínimo de ${money(minimum)}.`}}else{if(couponWarning)couponWarning.hidden=true;discount=option.dataset.type==='percentual'?checkoutSubtotal*Number(option.dataset.value)/100:Number(option.dataset.value);discount=Math.min(checkoutSubtotal,discount);couponTotal.hidden=discount<=0;couponDiscountText.textContent='− '+money(discount)}}else{if(couponWarning)couponWarning.hidden=true;couponTotal.hidden=true}document.querySelector('[data-checkout-total]').textContent=money(Math.max(0,checkoutSubtotal+(checkoutCart.length?checkoutFreight:0)-discount));}
document.querySelector('[data-checkout-empty]').hidden=checkoutCart.length>0;
document.querySelector('[data-checkout-subtotal]').textContent=money(checkoutSubtotal);
updateCheckoutTotal();
checkoutCoupon?.addEventListener('change',updateCheckoutTotal);
const cartField=document.querySelector('#checkout-cart');
const checkoutForm=document.querySelector('#checkout-form');
if(cartField)cartField.value=JSON.stringify(checkoutCart);
const paymentSelect=document.querySelector('#pagamento');
const paymentDetails=[...document.querySelectorAll('[data-payment-detail]')];
function showPaymentDetail(){paymentDetails.forEach(panel=>{const visible=panel.dataset.paymentDetail===paymentSelect.value;panel.hidden=!visible;panel.querySelectorAll('input,select').forEach(field=>field.disabled=!visible)});}
showPaymentDetail();
paymentSelect?.addEventListener('change',showPaymentDetail);
const pixCode=`ALVORADA-DEMO-SEM-COBRANCA-${Math.round(checkoutSubtotal+checkoutFreight*Boolean(checkoutCart.length)).toFixed(2)}`;
document.querySelector('[data-pix-code]').textContent=pixCode;
document.querySelector('[data-pix-qr]').src=`https://api.qrserver.com/v1/create-qr-code/?size=190x190&data=${encodeURIComponent(pixCode)}`;
document.querySelector('[data-copy-pix]')?.addEventListener('click',async event=>{try{await navigator.clipboard.writeText(pixCode);event.currentTarget.textContent='Código demonstrativo copiado'}catch{event.currentTarget.textContent='Não foi possível copiar o código'}});
const cardNumber=document.querySelector('#card-number'),cardName=document.querySelector('#card-name'),cardExpiry=document.querySelector('#card-expiry');
cardNumber?.addEventListener('input',()=>{const digits=cardNumber.value.replace(/\D/g,'').slice(0,16);cardNumber.value=digits.replace(/(.{4})/g,'$1 ').trim();document.querySelector('[data-card-preview-number]').textContent=cardNumber.value||'•••• •••• •••• ••••'});
cardName?.addEventListener('input',()=>document.querySelector('[data-card-preview-name]').textContent=cardName.value.toUpperCase()||'NOME NO CARTÃO');
cardExpiry?.addEventListener('input',()=>{const digits=cardExpiry.value.replace(/\D/g,'').slice(0,4);cardExpiry.value=digits.length>2?digits.slice(0,2)+'/'+digits.slice(2):digits;document.querySelector('[data-card-preview-expiry]').textContent=cardExpiry.value||'MM/AA'});
checkoutForm?.addEventListener('submit',event=>{
    if(!checkoutCart.length){event.preventDefault();alert('Seu carrinho está vazio.');return;}
    if(checkoutCart.some(item=>item.encarte===true)){event.preventDefault();alert('As ofertas do encarte foram adicionadas ao carrinho para consulta. Para finalizar a compra, esses itens precisam estar cadastrados no catálogo e no estoque da loja.');return;}
    if(paymentSelect.value==='cartao_credito'){event.preventDefault();alert('O pagamento com cartão está em demonstração. A integração ainda não está ativa, então nenhum dado será enviado.');return;}
    if(cartField)cartField.value=JSON.stringify(checkoutCart);
});
</script>
<?php require __DIR__.'/../includes/site-footer.php'; ?>
</body>
</html>
