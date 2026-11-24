<?php
/** Cria as contas locais de teste (somente CLI): php seed_test_accounts.php */
if(PHP_SAPI!=='cli'){http_response_code(404);exit;}
require_once __DIR__.'/config/conexao.php';
$accounts=[
    ['Cliente Teste Alvorada','cliente@superalvorada.com','Cliente123!','cliente'],
    ['Administrador Teste Alvorada','admin@superalvorada.com','Admin123!','admin'],
];
$query=db()->prepare('INSERT INTO usuarios(nome,email,senha,perfil) VALUES(?,?,?,?) ON DUPLICATE KEY UPDATE nome=VALUES(nome),senha=VALUES(senha),perfil=VALUES(perfil)');
foreach($accounts as [$name,$email,$password,$role]){
    $query->execute([$name,$email,password_hash($password,PASSWORD_DEFAULT),$role]);
    echo $email.' ('.$role.')'.PHP_EOL;
}
echo "Contas de teste gravadas no banco supermercado_alvorada.".PHP_EOL;
