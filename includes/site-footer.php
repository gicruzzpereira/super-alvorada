<?php
$footerRole = $_SESSION['usuario']['perfil'] ?? '';
$footerRoutes = [
    'admin' => '/admin/painel.php',
    'separador' => '/separacao/painel.php',
    'entregador' => '/entrega/painel.php',
    'cliente' => '/cliente/perfil.php',
];
$footerAccountUrl = $footerRoutes[$footerRole] ?? '/auth/login.php';
$footerOrdersUrl = match ($footerRole) {
    'cliente' => '/cliente/pedidos.php',
    '' => '/auth/login.php?voltar=pedidos',
    default => $footerRoutes[$footerRole] ?? '/auth/login.php?voltar=pedidos',
};
$footerColumns = [
    'Links Rápidos' => [
        'Início' => '/',
        'Categorias' => '/categoria.php?slug=todos',
        'Ofertas do Dia' => '/categoria.php?slug=ofertas',
        'Jornal da Semana' => '/categoria.php?slug=jornal',
        'Contato' => '/informacoes.php?pagina=contato',
    ],
    'Atendimento' => [
        'Minha Conta' => $footerAccountUrl,
        'Rastrear Pedido' => $footerOrdersUrl,
        'Entrega em até 50 km' => '/informacoes.php?pagina=entrega',
        'Trocas e Devoluções' => '/informacoes.php?pagina=trocas',
        'Perguntas Frequentes' => '/informacoes.php?pagina=perguntas-frequentes',
    ],
    'Informações' => [
        'Política de Privacidade' => '/informacoes.php?pagina=privacidade',
        'Termos e Condições' => '/informacoes.php?pagina=termos',
        'Política de Reembolso' => '/informacoes.php?pagina=reembolso',
        'Trabalhe Conosco' => '/informacoes.php?pagina=trabalhe-conosco',
    ],
];
$footerPayments = [
    'Pix' => ['pix', 'pix'],
    'Visa' => ['cartoes', 'visa'],
    'Mastercard' => ['cartoes', 'mastercard'],
    'Elo' => ['cartoes', 'elo'],
    'Boleto' => ['boleto', 'boleto'],
    'Na entrega' => ['na-entrega', 'entrega'],
];
?>
<link rel="stylesheet" href="/assets/css/site-footer.css?v=3">
<footer class="site-footer">
    <div class="container">
        <div class="site-footer-columns">
            <a class="site-footer-brand" href="/">
                <img src="/assets/images/alvorada-logo-rodape.png?v=1" alt="Supermercado Alvorada">
            </a>
            <?php foreach ($footerColumns as $heading => $links): ?>
                <nav aria-label="<?=h($heading)?>">
                    <h2><?=h($heading)?></h2>
                    <ul>
                        <?php foreach ($links as $label => $url): ?>
                            <li><a href="<?=h($url)?>"><?=h($label)?></a></li>
                        <?php endforeach; ?>
                    </ul>
                </nav>
            <?php endforeach; ?>
            <section class="site-footer-payment" aria-labelledby="site-footer-payment-title">
                <h2 id="site-footer-payment-title">Formas de Pagamento</h2>
                <ul class="site-footer-payment-grid">
                    <?php foreach ($footerPayments as $label => [$anchor, $icon]): ?>
                        <li>
                            <a href="/informacoes.php?pagina=pagamentos#<?=h($anchor)?>" aria-label="<?=h($label)?>">
                                <svg viewBox="0 0 72 38" aria-hidden="true" focusable="false"><use href="/assets/images/footer-payments.svg#<?=h($icon)?>"></use></svg>
                            </a>
                        </li>
                    <?php endforeach; ?>
                </ul>
                <p>Consulte a disponibilidade de cada opção.</p>
                <div class="site-footer-support">
                    <a href="/informacoes.php?pagina=privacidade">Privacidade da compra</a>
                    <a href="/informacoes.php?pagina=trocas">Suporte à compra</a>
                </div>
            </section>
        </div>
        <div class="site-footer-bottom">
            <span>© <?=date('Y')?> Supermercado Alvorada</span>
            <?php if (!empty($showFooterFavorites)) require __DIR__.'/favorites-button.php'; ?>
        </div>
    </div>
</footer>
<?php if (!empty($showFooterFavorites)) require __DIR__.'/favorites-dialog.php'; ?>
<script src="/assets/js/motion.js?v=1" defer></script>
