<?php
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__.'/../config/conexao.php';

$pdo = db();
$columns = $pdo->query('SHOW COLUMNS FROM produtos')->fetchAll(PDO::FETCH_COLUMN);
if (!in_array('descricao', $columns, true)) {
    $pdo->exec('ALTER TABLE produtos ADD COLUMN descricao VARCHAR(255) NULL AFTER nome');
}
$sql = file_get_contents(__DIR__.'/013_hortifruti_descriptions.sql');
foreach (preg_split('/;\s*(?:\r?\n|$)/', $sql) as $statement) {
    $statement = trim($statement);
    if ($statement !== '') { $pdo->exec($statement); }
}
echo "Descrições do Hortifrúti salvas.\n";
