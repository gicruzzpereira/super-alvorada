<?php
/** Somente ambiente local: execute pela CLI (`php seed_demo.php`). */
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require_once __DIR__.'/config/conexao.php';
$demo = [
    ['Cliente Demonstração','cliente@alvorada.local','Cliente123!','cliente'],
    ['Admin Demonstração','admin@alvorada.local','Admin123!','admin'],
    ['Separador Demonstração','separador@alvorada.local','Separador123!','separador'],
    ['Entregador Demonstração','entregador@alvorada.local','Entrega123!','entregador'],
    ['Visitante Demonstração','visitante@alvorada.local','Visitante123!','visitante'],
];
$q=db()->prepare('INSERT INTO usuarios(nome,email,senha,perfil) VALUES(?,?,?,?) ON DUPLICATE KEY UPDATE nome=VALUES(nome)');
foreach($demo as [$nome,$email,$senha,$perfil]) $q->execute([$nome,$email,password_hash($senha,PASSWORD_DEFAULT),$perfil]);
echo "Contas de demonstração criadas/atualizadas. Use apenas localmente.\n";
