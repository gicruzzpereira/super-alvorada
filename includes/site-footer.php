<?php
$footerUser = $_SESSION['usuario'] ?? null;
$footerRole = $footerUser['perfil'] ?? '';
$footerRoutes = [
    'admin' => '/admin/painel.php',
    'separador' => '/separacao/painel.php',
    'entregador' => '/entrega/painel.php',
    'cliente' => '/cliente/perfil.php',
];
$footerAccountUrl = $footerRoutes[$footerRole] ?? '/auth/login.php';
$footerAccountLabel = $footerRole === 'cliente' ? 'Meu perfil' : ($footerRole ? 'Painel da equipe' : 'Entrar / Cadastrar');
$footerOrdersUrl = $footerRole === 'cliente' ? '/cliente/perfil.php#pedidos' : ($footerRoutes[$footerRole] ?? '/auth/login.php');
$footerOrdersLabel = $footerRole === 'cliente' ? 'Meus pedidos' : ($footerRole ? 'Painel de pedidos' : 'Acompanhar pedidos');
$footerAddressesUrl = $footerRole === 'cliente' ? '/cliente/perfil.php#enderecos' : ($footerRole ? $footerAccountUrl : '/auth/login.php');
?>
<footer class="footer cart-footer site-footer">
    <div class="container">
        <div class="cart-footer-grid">
            <div class="cart-footer-brand">
                <a class="brand" href="/" aria-label="Alvorada Supermercado">
                    <img class="brand-logo" src="/assets/images/alvorada-logo-rodape.png?v=1" alt="Supermercado Alvorada">
                </a>
                <p>Qualidade, frescor e economia para o seu dia a dia.</p>
            </div>
            <div>
                <h2>Loja</h2>
                <a href="/#categorias">Categorias</a>
                <a href="/#ofertas">Ofertas do dia</a>
                <a href="/#ofertas">Ver encarte</a>
            </div>
            <div>
                <h2>Minha conta</h2>
                <a href="<?=h($footerAccountUrl)?>"><?=h($footerAccountLabel)?></a>
                <a href="<?=h($footerOrdersUrl)?>"><?=h($footerOrdersLabel)?></a>
                <a href="<?=h($footerAddressesUrl)?>">Endereços salvos</a>
            </div>
            <div>
                <h2>Atendimento</h2>
                <p>Precisa de ajuda com seu pedido?</p>
                <a href="https://wa.me/5511987147839" target="_blank" rel="noopener noreferrer">Fale com a equipe Alvorada</a>
            </div>
        </div>
        <div class="cart-footer-bottom">
            <span>© <?=date('Y')?> Supermercado Alvorada</span>
            <a href="/">Voltar à loja</a>
        </div>
    </div>
</footer>
