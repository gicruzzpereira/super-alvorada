<?php
require_once __DIR__.'/../config/conexao.php';
$erro='';
$returnTo=(($_POST['return_to']??$_GET['voltar']??'')==='checkout')?'checkout':'';
if($_SERVER['REQUEST_METHOD']==='POST'){
    validarCsrf();
    $q=db()->prepare('SELECT id_usuario,nome,email,senha,perfil FROM usuarios WHERE email=?');
    $q->execute([trim($_POST['email']??'')]);
    $u=$q->fetch();
    if($u&&password_verify($_POST['senha']??'',$u['senha'])){
        session_regenerate_id(true);
        unset($u['senha']);
        $_SESSION['usuario']=$u;
        if($returnTo==='checkout'&&$u['perfil']==='cliente'){
            header('Location: /cliente/checkout.php');
            exit;
        }
        header('Location: '.(['admin'=>'/admin/painel.php','separador'=>'/separacao/painel.php','entregador'=>'/entrega/painel.php','cliente'=>'/cliente/perfil.php'][$u['perfil']]??'/'));
        exit;
    }
    $erro='E-mail ou senha inválidos.';
}
?>
<!doctype html>
<html lang="pt-BR">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Entrar · Alvorada</title>
    <link rel="stylesheet" href="../assets/css/style.css?v=44">
</head>
<body class="auth-body">
<main class="auth-shell auth-shell-login">
    <a class="auth-brand" href="../index.php" aria-label="Voltar à loja">
        <img src="../assets/images/alvorada-logo.png?v=1" alt="Supermercado Alvorada">
    </a>
    <section class="auth-card" aria-labelledby="login-title">
        <h1 id="login-title">Bem-vindo de volta</h1>
        <?php if($returnTo==='checkout'): ?><div class="notice">Entre na sua conta para continuar e finalizar o pedido.</div><?php endif; ?>
        <?php if($erro): ?><div class="notice" role="alert"><?=h($erro)?></div><?php endif; ?>
        <form method="post" class="auth-form">
            <input type="hidden" name="csrf" value="<?=csrf()?>">
            <input type="hidden" name="return_to" value="<?=h($returnTo)?>">
            <label class="auth-field" for="email">E-mail
                <input class="auth-input" id="email" type="email" name="email" required autocomplete="email">
            </label>
            <label class="auth-field" for="senha">Senha
                <span class="auth-password-wrap">
                    <input class="auth-input" id="senha" type="password" name="senha" required autocomplete="current-password">
                    <button class="auth-password-toggle" type="button" data-password-toggle="senha" aria-label="Mostrar senha" aria-pressed="false">
                        <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z"/><circle cx="12" cy="12" r="3"/></svg>
                    </button>
                </span>
            </label>
            <button class="auth-submit" type="submit">Entrar</button>
        </form>
        <p class="auth-switch">É sua primeira visita? <a href="cadastro.php<?= $returnTo==='checkout'?'?voltar=checkout':'' ?>">Crie sua conta</a></p>
    </section>
</main>
<script src="../assets/js/main.js?v=7"></script>
<?php require __DIR__.'/../includes/site-footer.php'; ?>
</body>
</html>
