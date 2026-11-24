<?php
if(PHP_SAPI!=='cli'){http_response_code(404);exit;}
require __DIR__.'/../config/conexao.php';
$pdo=db();
$columns=$pdo->query('SHOW COLUMNS FROM categorias')->fetchAll(PDO::FETCH_COLUMN);
if(!in_array('imagem_url',$columns,true))$pdo->exec('ALTER TABLE categorias ADD COLUMN imagem_url VARCHAR(255) NULL AFTER slug');
$sql=file_get_contents(__DIR__.'/009_site_content.sql');
foreach(preg_split('/;\s*(?:\r?\n|$)/',$sql) as $statement){$statement=trim($statement);if($statement!=='')$pdo->exec($statement);}
$pdo->exec('DELETE older FROM banners_site older JOIN banners_site newer ON older.imagem_url=newer.imagem_url AND older.id_banner>newer.id_banner');
$bannerIndexes=$pdo->query("SHOW INDEX FROM banners_site WHERE Key_name='uq_banners_imagem'")->fetchAll();
if(!$bannerIndexes)$pdo->exec('ALTER TABLE banners_site ADD UNIQUE KEY uq_banners_imagem (imagem_url)');
echo "Site content and customer-state tables migrated.\n";
