<?php
require_once __DIR__.'/config/conexao.php';
require_once __DIR__.'/includes/atendimento.php';

$pages = [
    'contato' => 'Contato',
    'entrega' => 'Entrega em até 50 km',
    'trocas' => 'Trocas e Devoluções',
    'perguntas-frequentes' => 'Perguntas Frequentes',
    'privacidade' => 'Política de Privacidade',
    'termos' => 'Termos e Condições',
    'reembolso' => 'Política de Reembolso',
    'trabalhe-conosco' => 'Trabalhe Conosco',
    'pagamentos' => 'Formas de Pagamento',
];
$page = is_string($_GET['pagina'] ?? null) ? $_GET['pagina'] : 'contato';
if (!isset($pages[$page])) {
    http_response_code(404);
}
$title = $pages[$page] ?? 'Página não encontrada';
?>
<!doctype html>
<html lang="pt-BR">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title><?=h($title)?> · Supermercado Alvorada</title>
    <link rel="stylesheet" href="/assets/css/style.css?v=63">
</head>
<body class="store-info-page">
<main class="container store-info">
    <a href="/">← Voltar à loja</a>
    <article>
        <h1><?=h($title)?></h1>
        <?php switch ($page): case 'contato': ?>
            <p>Fale com a equipe Alvorada sobre produtos, entregas ou pedidos. Se já fez uma compra, tenha o número do pedido à mão.</p>
            <a class="button" href="<?=h(alvoradaWhatsApp('Olá! Preciso de atendimento no Supermercado Alvorada.'))?>">Abrir WhatsApp</a>
        <?php break; case 'entrega': ?>
            <p>Atendemos endereços em até 50 km da loja. Informe seu CEP para consultar a cobertura, o frete e as modalidades disponíveis. Fora do raio, o sistema oferece retirada gratuita.</p>
            <a class="button" href="/cliente/carrinho.php#cart-cep">Consultar meu CEP</a>
        <?php break; case 'trocas': ?>
            <p>Para solicitar troca, devolução ou informar um produto incorreto, danificado ou faltante, fale com a equipe. Informe o número do pedido e identifique o item. A equipe orientará sobre a solução e a devolução, quando aplicável.</p>
            <p>Consulte os detalhes sobre prazos e estorno na <a href="?pagina=reembolso">Política de Reembolso</a>.</p>
            <a class="button" href="<?=h(alvoradaWhatsApp('Olá! Quero solicitar uma troca ou devolução. Meu pedido é '))?>">Solicitar troca ou devolução</a>
        <?php break; case 'perguntas-frequentes': ?>
            <details><summary>Como vejo o andamento do meu pedido?</summary><p>Entre na sua conta e consulte <a href="<?=h(($_SESSION['usuario']['perfil'] ?? '') === 'cliente' ? '/cliente/pedidos.php' : '/auth/login.php?voltar=pedidos')?>">Meus Pedidos</a>.</p></details>
            <details><summary>Como descubro se a loja entrega no meu endereço?</summary><p>Use o <a href="/cliente/carrinho.php#cart-cep">calculador de entrega no carrinho</a> para verificar o CEP e as opções disponíveis.</p></details>
            <details><summary>Como uso um cupom?</summary><p>Acesse <a href="/cupons.php">Cupons</a>, entre na sua conta, resgate um cupom válido e selecione-o na finalização da compra.</p></details>
            <details><summary>Quais são as formas de pagamento?</summary><p>Confira a <a href="?pagina=pagamentos">disponibilidade no checkout</a>.</p></details>
            <details><summary>Como solicito troca ou devolução?</summary><p>Use o canal indicado em <a href="?pagina=trocas">Trocas e Devoluções</a>.</p></details>
        <?php break; case 'privacidade': ?>
            <p>A loja usa os dados de cadastro, endereço e pedido para gerenciar sua conta, processar compras e organizar a entrega. O carrinho, os favoritos e as preferências de entrega são associados à conta ou à sessão do visitante. O e-mail informado na newsletter é usado para comunicações sobre a loja.</p>
            <p>Para pedir acesso, correção ou exercer outros direitos previstos na LGPD, entre em contato com a equipe. Evite enviar senhas ou dados de cartão por mensagem.</p>
            <a class="button" href="<?=h(alvoradaWhatsApp('Olá! Tenho uma solicitação referente aos meus dados pessoais.'))?>">Solicitar atendimento de privacidade</a>
            <p><a href="https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm">Consultar a LGPD</a></p>
        <?php break; case 'termos': ?>
            <p>Antes de confirmar o pedido, confira quantidades, preços, descontos, endereço, modalidade e frete. O checkout exibe as opções disponíveis e o total da compra. Acompanhe a preparação e a entrega na sua conta.</p>
            <p>Para questões sobre o pedido, consulte <a href="?pagina=trocas">Trocas e Devoluções</a> ou fale com a equipe de <a href="?pagina=contato">Atendimento</a>.</p>
            <p><a href="https://www.planalto.gov.br/ccivil_03/_ato2011-2014/2013/decreto/d7962.htm">Consultar as regras do comércio eletrônico</a></p>
        <?php break; case 'reembolso': ?>
            <p>Em compras online, o artigo 49 do Código de Defesa do Consumidor prevê o direito de arrependimento em até sete dias, contados da assinatura ou do recebimento do produto ou serviço, conforme o caso.</p>
            <p>Para solicitar reembolso, informe o número do pedido, os itens envolvidos e o motivo. O atendimento orientará sobre os próximos passos e informará como acompanhar o estorno.</p>
            <a class="button" href="<?=h(alvoradaWhatsApp('Olá! Quero solicitar um reembolso. Meu pedido é '))?>">Solicitar reembolso</a>
            <p><a href="https://www.planalto.gov.br/ccivil_03/leis/l8078compilado.htm">Consultar o Código de Defesa do Consumidor</a></p>
        <?php break; case 'trabalhe-conosco': ?>
            <p>Fale com a equipe para consultar oportunidades e confirmar o canal de envio do currículo. Informe seu nome e a área em que gostaria de trabalhar.</p>
            <a class="button" href="<?=h(alvoradaWhatsApp('Olá! Gostaria de saber sobre oportunidades de trabalho no Supermercado Alvorada.'))?>">Consultar oportunidades</a>
        <?php break; case 'pagamentos': ?>
            <dl>
                <dt id="na-entrega">Pagamento na entrega</dt><dd>Escolha dinheiro ou maquininha na entrega entre as opções do checkout.</dd>
                <dt id="pix">Pix</dt><dd>O checkout exibe um QR Code de demonstração. A cobrança Pix está indisponível.</dd>
                <dt id="cartoes">Visa, Mastercard e Elo</dt><dd>O pagamento online com cartão está em demonstração. Consulte o atendimento sobre as bandeiras aceitas na maquininha.</dd>
                <dt id="boleto">Boleto</dt><dd>A emissão de boleto está indisponível no checkout.</dd>
            </dl>
            <a class="button" href="/cliente/checkout.php#pagamento">Ver opções no checkout</a>
        <?php break; default: ?>
            <p>Confira os links abaixo para encontrar a informação que você procura.</p>
        <?php endswitch; ?>
    </article>
</main>
<?php require __DIR__.'/includes/site-footer.php'; ?>
</body>
</html>
