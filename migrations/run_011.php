<?php
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__.'/../config/conexao.php';

$pdo = db();
$sql = file_get_contents(__DIR__.'/011_hortifruti_products.sql');
$sql = preg_replace('/^--.*$/m', '', $sql);
foreach (preg_split('/;\s*(?:\r?\n|$)/', $sql) as $statement) {
    $statement = trim($statement);
    if ($statement !== '') {
        $pdo->exec($statement);
    }
}
$count = $pdo->query("SELECT COUNT(*) FROM produtos p JOIN categorias c USING(id_categoria) WHERE c.slug='hortifruti' AND p.ativo=1")->fetchColumn();
echo "Produtos do Hortifruti cadastrados: {$count}.\n";
