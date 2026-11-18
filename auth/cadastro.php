<?php
require_once __DIR__.'/../config/conexao.php';
$erro='';
$returnTo=(($_POST['return_to']??$_GET['voltar']??'')==='checkout')?'checkout':'';
if($_SERVER['REQUEST_METHOD']==='POST'){
    validarCsrf();
    $nome=trim($_POST['nome']??'');
    $email=filter_var($_POST['email']??'',FILTER_VALIDATE_EMAIL);
    $senha=$_POST['senha']??'';
    if(!$nome||!$email||strlen($senha)<8){
        $erro='Informe nome, e-mail válido e senha com ao menos 8 caracteres.';
    }else{
        try{
            $q=db()->prepare("INSERT INTO usuarios(nome,email,senha,perfil,telefone) VALUES(?,?,?,'cliente',?)");
            $q->execute([$nome,$email,password_hash($senha,PASSWORD_DEFAULT),trim($_POST['telefone']??'')]);
            $_SESSION['usuario']=['id_usuario'=>(int)db()->lastInsertId(),'nome'=>$nome,'email'=>$email,'perfil'=>'cliente'];
            header('Location: '.($returnTo==='checkout'?'/cliente/checkout.php':'/cliente/perfil.php'));
            exit;
        }catch(PDOException $e){
            $erro=$e->getCode()==='23000'?'Este e-mail já está cadastrado.':'Não foi possível criar a conta.';
        }
    }
}
?>
<!doctype html>
<html lang="pt-BR">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Criar conta · Alvorada</title>
    <link rel="stylesheet" href="../assets/css/style.css?v=13">
</head>
<body class="auth-body">
<main class="auth-shell auth-shell-register">
    <a class="auth-brand" href="../index.php" aria-label="Voltar à loja">
        <img src="../assets/images/alvorada-logo.png?v=1" alt="Supermercado Alvorada">
    </a>
    <section class="auth-card auth-card-register" aria-labelledby="register-title">
        <header class="auth-intro">
            <h1 id="register-title">Crie sua <span>conta</span></h1>
            <p>Cadastre-se no Supermercado Alvorada para começar suas compras e ter acesso a descontos exclusivos.</p>
        </header>
        <?php if($returnTo==='checkout'): ?><div class="notice">Crie sua conta para continuar e finalizar o pedido.</div><?php endif; ?>
        <?php if($erro): ?><div class="notice" role="alert"><?=h($erro)?></div><?php endif; ?>
        <form method="post" class="auth-form">
            <input type="hidden" name="csrf" value="<?=csrf()?>">
            <input type="hidden" name="return_to" value="<?=h($returnTo)?>">
            <label class="auth-field" for="nome">Nome completo
                <input class="auth-input" id="nome" name="nome" required maxlength="100" autocomplete="name">
            </label>
            <label class="auth-field" for="email">Endereço de e-mail
                <input class="auth-input" id="email" type="email" name="email" required autocomplete="email">
            </label>
            <label class="auth-field" for="telefone">Telefone (WhatsApp)
                <input class="auth-input" id="telefone" type="tel" name="telefone" autocomplete="tel">
            </label>
            <label class="auth-field" for="senha">Criar senha <span class="auth-hint">(mínimo 8 caracteres)</span>
                <span class="auth-password-wrap">
                    <input class="auth-input" id="senha" type="password" name="senha" minlength="8" required autocomplete="new-password">
                    <button class="auth-password-toggle" type="button" data-password-toggle="senha" aria-label="Mostrar senha" aria-pressed="false">
                        <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z"/><circle cx="12" cy="12" r="3"/></svg>
                    </button>
                </span>
            </label>
            <button class="auth-submit" type="submit">Criar conta <span aria-hidden="true">→</span></button>
        </form>
        <p class="auth-switch">Já tem uma conta? <a href="login.php<?= $returnTo==='checkout'?'?voltar=checkout':'' ?>">Entrar</a></p>
    </section>
</main>
<script src="../assets/js/main.js?v=7"></script>
</body>
</html>
