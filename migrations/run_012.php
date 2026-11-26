<?php
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__.'/../config/conexao.php';

$pdo = db();
$sql = file_get_contents(__DIR__.'/012_hortifruti_product_photos.sql');
foreach (preg_split('/;\s*(?:\r?\n|$)/', $sql) as $statement) {
    $statement = trim($statement);
    if ($statement !== '') { $pdo->exec($statement); }
}
echo "Fotos do tomate e da alface crespa atualizadas.\n";
