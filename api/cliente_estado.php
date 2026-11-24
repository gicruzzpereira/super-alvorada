<?php
declare(strict_types=1);
require_once __DIR__.'/../config/conexao.php';
header('Content-Type: application/json; charset=utf-8');

$user=$_SESSION['usuario']??null;
$isCustomer=($user['perfil']??'')==='cliente';
$guestToken=$isCustomer?null:siteGuestToken();
$pdo=db();
$userId=$isCustomer?(int)$user['id_usuario']:null;
$respond=static function(array $data,int $status=200): never {http_response_code($status);echo json_encode($data,JSON_UNESCAPED_UNICODE|JSON_INVALID_UTF8_SUBSTITUTE);exit;};
$decode=static function(?string $value,mixed $fallback): mixed {if($value===null||$value==='')return $fallback;$data=json_decode($value,true);return json_last_error()===JSON_ERROR_NONE?$data:$fallback;};

if($_SERVER['REQUEST_METHOD']==='GET'){
    if($isCustomer){$query=$pdo->prepare('SELECT carrinho_json,favoritos_json,localizacao_json,atualizado_em FROM cliente_estado_site WHERE id_usuario=?');$query->execute([$userId]);}
    else{$pdo->prepare('DELETE FROM visitante_estado_site WHERE expira_em<NOW()')->execute();$query=$pdo->prepare('SELECT carrinho_json,favoritos_json,localizacao_json,atualizado_em FROM visitante_estado_site WHERE session_token=? AND expira_em>NOW()');$query->execute([$guestToken]);}
    $row=$query->fetch();
    $respond(['ok'=>true,'state'=>$row?[
        'cart'=>$decode($row['carrinho_json'],[]),
        'favorites'=>$decode($row['favoritos_json'],[]),
        'location'=>$decode($row['localizacao_json'],null),
        'updatedAt'=>$row['atualizado_em']
    ]:null]);
}
if($_SERVER['REQUEST_METHOD']!=='POST')$respond(['ok'=>false,'message'=>'Método não permitido.'],405);
$csrf=(string)($_SERVER['HTTP_X_CSRF_TOKEN']??'');
if($csrf===''||!hash_equals(csrf(),$csrf))$respond(['ok'=>false,'message'=>'Sessão expirada. Atualize a página.'],400);
$payload=json_decode((string)file_get_contents('php://input'),true);
if(!is_array($payload))$respond(['ok'=>false,'message'=>'Dados inválidos.'],400);
if($isCustomer){$query=$pdo->prepare('SELECT carrinho_json,favoritos_json,localizacao_json FROM cliente_estado_site WHERE id_usuario=?');$query->execute([$userId]);}
else{$query=$pdo->prepare('SELECT carrinho_json,favoritos_json,localizacao_json FROM visitante_estado_site WHERE session_token=? AND expira_em>NOW()');$query->execute([$guestToken]);}
$current=$query->fetch()?:[];
$cart=$decode($current['carrinho_json']??null,[]);
$favorites=$decode($current['favoritos_json']??null,[]);
$location=$decode($current['localizacao_json']??null,null);

if(array_key_exists('cart',$payload)){
    if(!is_array($payload['cart'])||count($payload['cart'])>250)$respond(['ok'=>false,'message'=>'Carrinho inválido.'],400);
    $cart=[];$productQuery=$pdo->prepare('SELECT id_produto FROM produtos WHERE id_produto=? AND ativo=1');
    $offerQuery=$pdo->prepare('SELECT nome,preco,tipo_medida FROM itens_encarte_site WHERE id_item_encarte=? AND ativo=1');
    foreach($payload['cart'] as $item){
        if(!is_array($item)||!isset($item['id'],$item['qty']))continue;
        $id=(int)$item['id'];$qty=(float)$item['qty'];if($qty<=0||$qty>1000)continue;
        if(($item['encarte']??false)===true){
            $offerId=abs($id)-900;if($offerId<=0)continue;
            $offerQuery->execute([$offerId]);$offer=$offerQuery->fetch();if(!$offer)continue;
            $cart[]=['id'=>-$offerId-900,'name'=>$offer['nome'],'price'=>(float)$offer['preco'],'unit'=>$offer['tipo_medida'],'qty'=>$qty,'encarte'=>true];
        }else{
            if($id<=0)continue;$productQuery->execute([$id]);if(!$productQuery->fetchColumn())continue;
            $cart[]=['id'=>$id,'qty'=>$qty];
        }
    }
}
if(array_key_exists('favorites',$payload)){
    if(!is_array($payload['favorites'])||count($payload['favorites'])>500)$respond(['ok'=>false,'message'=>'Lista de favoritos inválida.'],400);
    $favorites=[];$favoriteQuery=$pdo->prepare('SELECT id_produto FROM produtos WHERE id_produto=? AND ativo=1');
    foreach($payload['favorites'] as $value){$id=filter_var($value,FILTER_VALIDATE_INT);if($id===false||$id<1)continue;$favoriteQuery->execute([$id]);if($favoriteQuery->fetchColumn())$favorites[$id]=$id;}
    $favorites=array_values($favorites);
}
if(array_key_exists('location',$payload)){
    $candidate=$payload['location'];
    if($candidate===null){$location=null;}
    elseif(is_array($candidate)){
        $city=trim((string)($candidate['cidade']??''));$cep=preg_replace('/\D/','',(string)($candidate['cep']??''));
        if(mb_strlen($city)>100||($cep!==''&&!preg_match('/^\d{8}$/',$cep)))$respond(['ok'=>false,'message'=>'Localização inválida.'],400);
        $location=['cidade'=>$city,'cep'=>$cep,'uf'=>substr((string)($candidate['uf']??''),0,2)];
    }else $respond(['ok'=>false,'message'=>'Localização inválida.'],400);
}
if($isCustomer){$save=$pdo->prepare('INSERT INTO cliente_estado_site(id_usuario,carrinho_json,favoritos_json,localizacao_json) VALUES(?,?,?,?) ON DUPLICATE KEY UPDATE carrinho_json=VALUES(carrinho_json),favoritos_json=VALUES(favoritos_json),localizacao_json=VALUES(localizacao_json)');$save->execute([$userId,json_encode($cart,JSON_UNESCAPED_UNICODE),json_encode($favorites),json_encode($location,JSON_UNESCAPED_UNICODE)]);}
else{$save=$pdo->prepare('INSERT INTO visitante_estado_site(session_token,carrinho_json,favoritos_json,localizacao_json,expira_em) VALUES(?,?,?,?,DATE_ADD(NOW(),INTERVAL 30 DAY)) ON DUPLICATE KEY UPDATE carrinho_json=VALUES(carrinho_json),favoritos_json=VALUES(favoritos_json),localizacao_json=VALUES(localizacao_json),expira_em=VALUES(expira_em)');$save->execute([$guestToken,json_encode($cart,JSON_UNESCAPED_UNICODE),json_encode($favorites),json_encode($location,JSON_UNESCAPED_UNICODE)]);}
$respond(['ok'=>true]);
