<?php
require_once __DIR__.'/../config/conexao.php';
require_once __DIR__.'/../config/entrega.php';
header('Content-Type: application/json; charset=utf-8');

if($_SERVER['REQUEST_METHOD']!=='POST')jsonResponse(['ok'=>false,'message'=>'Método não permitido.'],405);
validarCsrf();

$cep=(string)($_POST['cep']??'');
$mode=(string)($_POST['modalidade']??'');
$latitude=isset($_POST['latitude'])&&is_numeric($_POST['latitude'])?(float)$_POST['latitude']:null;
$longitude=isset($_POST['longitude'])&&is_numeric($_POST['longitude'])?(float)$_POST['longitude']:null;
$deliveryDate=trim((string)($_POST['data_entrega']??''));
$deliverySlot=trim((string)($_POST['horario_entrega']??''));
$address=['logradouro'=>trim((string)($_POST['logradouro']??'')),'bairro'=>trim((string)($_POST['bairro']??'')),'localidade'=>trim((string)($_POST['cidade']??'')),'uf'=>trim((string)($_POST['uf']??''))];
if(!in_array($mode,['expressa','agendada','retirada'],true))jsonResponse(['ok'=>false,'message'=>'Escolha uma modalidade de entrega válida.'],422);

try{
    $options=opcoesFretePorCep(db(),$cep,$mode==='retirada',$latitude,$longitude,$address);
    $_SESSION['entrega_cep']=$options['cep'];
    $_SESSION['entrega_modalidade']=$mode;
    $_SESSION['entrega_frete']=$options[$mode];
    if(in_array($mode,['agendada','retirada'],true)){
        if($deliveryDate!==''&&!validarDataAgendamento(db(),$deliveryDate))jsonResponse(['ok'=>false,'message'=>'Escolha um dia disponível nos próximos 30 dias.'],422);
        if($deliverySlot!==''&&($deliveryDate===''||!validarHorarioAgendamento(db(),$deliveryDate,$deliverySlot,$mode)))jsonResponse(['ok'=>false,'message'=>'Escolha um horário disponível para o dia selecionado.'],422);
        if($deliveryDate!=='')$_SESSION['entrega_data']=$deliveryDate;else unset($_SESSION['entrega_data']);
        if($deliverySlot!=='')$_SESSION['entrega_horario']=$deliverySlot;else unset($_SESSION['entrega_horario']);
    }else unset($_SESSION['entrega_data'],$_SESSION['entrega_horario']);
    jsonResponse(['ok'=>true,'cep'=>$options['cep'],'modalidade'=>$mode,'frete'=>$options[$mode],'data_entrega'=>$_SESSION['entrega_data']??'','horario_entrega'=>$_SESSION['entrega_horario']??'','opcoes'=>$options]);
}catch(OutOfBoundsException $e){
    jsonResponse(['ok'=>false,'code'=>'out_of_area','message'=>$e->getMessage()],422);
}catch(InvalidArgumentException $e){
    jsonResponse(['ok'=>false,'code'=>'invalid_cep','message'=>$e->getMessage()],422);
}catch(Throwable $e){
    jsonResponse(['ok'=>false,'message'=>'Não foi possível calcular o frete. Tente novamente.'],503);
}
