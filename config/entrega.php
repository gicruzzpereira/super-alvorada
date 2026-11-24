<?php
declare(strict_types=1);

function normalizarCepEntrega(string $cep): string {
    return preg_replace('/\D+/', '', $cep) ?? '';
}

function coordenadasCepEntrega(string $cep, ?float $latitude=null, ?float $longitude=null, array $address=[]): array {
    $cep=normalizarCepEntrega($cep);
    if(!preg_match('/^\d{8}$/',$cep))throw new InvalidArgumentException('Digite um CEP válido com 8 números.');
    if($latitude!==null&&$longitude!==null){
        if(!is_finite($latitude)||!is_finite($longitude)||$latitude < -34||$latitude > 6||$longitude < -75||$longitude > -30)throw new InvalidArgumentException('Não foi possível validar as coordenadas deste CEP.');
        $location=['cep'=>$cep,'latitude'=>$latitude,'longitude'=>$longitude,'endereco'=>$address];
        if(session_status()===PHP_SESSION_ACTIVE)$_SESSION['cep_location_cache'][$cep]=['saved_at'=>time(),'location'=>$location];
        return $location;
    }
    if(session_status()===PHP_SESSION_ACTIVE&&isset($_SESSION['cep_location_cache'][$cep])&&($_SESSION['cep_location_cache'][$cep]['saved_at']??0)>time()-2592000)return $_SESSION['cep_location_cache'][$cep]['location'];

    $url='https://brasilapi.com.br/api/cep/v2/'.$cep;
    $body=false;
    if(function_exists('curl_init')){
        $curl=curl_init($url);
        curl_setopt_array($curl,[CURLOPT_RETURNTRANSFER=>true,CURLOPT_CONNECTTIMEOUT=>4,CURLOPT_TIMEOUT=>8,CURLOPT_FOLLOWLOCATION=>true,CURLOPT_HTTPHEADER=>['Accept: application/json','User-Agent: SupermercadoAlvorada/1.0']]);
        $body=curl_exec($curl);
        $status=(int)curl_getinfo($curl,CURLINFO_HTTP_CODE);
        curl_close($curl);
        if($status===404)throw new InvalidArgumentException('CEP não encontrado. Confira os números e tente novamente.');
        if($status<200||$status>=300)$body=false;
    }elseif(ini_get('allow_url_fopen')){
        $context=stream_context_create(['http'=>['timeout'=>8,'ignore_errors'=>true,'header'=>"Accept: application/json\r\nUser-Agent: SupermercadoAlvorada/1.0\r\n"]]);
        $body=@file_get_contents($url,false,$context);
        if(isset($http_response_header[0])&&str_contains($http_response_header[0],'404'))throw new InvalidArgumentException('CEP não encontrado. Confira os números e tente novamente.');
    }
    if(!is_string($body)||$body==='')throw new RuntimeException('Não foi possível consultar a localização deste CEP. Tente novamente.');
    $result=json_decode($body,true);
    $latitude=$result['location']['coordinates']['latitude']??null;
    $longitude=$result['location']['coordinates']['longitude']??null;
    if(!is_numeric($latitude)||!is_numeric($longitude))throw new RuntimeException('Não foi possível confirmar a distância para este CEP.');
    $location=['cep'=>$cep,'latitude'=>(float)$latitude,'longitude'=>(float)$longitude,'endereco'=>$result];
    if(session_status()===PHP_SESSION_ACTIVE)$_SESSION['cep_location_cache'][$cep]=['saved_at'=>time(),'location'=>$location];
    return $location;
}

function distanciaEntregaKm(float $latitudeA,float $longitudeA,float $latitudeB,float $longitudeB): float {
    $toRadians=static fn(float $value):float=>$value*(M_PI/180);
    $dLat=$toRadians($latitudeB-$latitudeA);
    $dLon=$toRadians($longitudeB-$longitudeA);
    $a=sin($dLat/2)**2+cos($toRadians($latitudeA))*cos($toRadians($latitudeB))*sin($dLon/2)**2;
    return 6371*2*asin(min(1,sqrt($a)));
}

function configuracaoAgendamento(PDO $pdo): array {
    $settings=$pdo->query("SELECT chave,valor FROM configuracoes WHERE chave IN ('agendamento_dias','agendamento_horarios','entrega_horarios','retirada_horarios')")->fetchAll(PDO::FETCH_KEY_PAIR);
    $days=array_values(array_unique(array_filter(array_map('intval',explode(',',(string)($settings['agendamento_dias']??'1,2,3,4,5,6'))),static fn(int $day):bool=>$day>=1&&$day<=7)));
    $parseSlots=static function(string $value):array{$slots=[];foreach(preg_split('/\R/',$value) as $slot){$slot=trim($slot);if(preg_match('/^(?:[01]\d|2[0-3]):[0-5]\d-(?:[01]\d|2[0-3]):[0-5]\d$/',$slot)&&substr($slot,0,5)<substr($slot,6,5))$slots[]=$slot;}return array_values(array_unique($slots));};
    $legacy=(string)($settings['agendamento_horarios']??"09:00-12:00\n14:00-18:00");
    $deliveryDefaults="09:00-10:00\n10:00-11:00\n11:00-12:00\n14:00-15:00\n15:00-16:00\n16:00-17:00\n17:00-18:00";
    return ['dias'=>$days,'horarios_entrega'=>$parseSlots((string)($settings['entrega_horarios']??$deliveryDefaults)),'horarios_retirada'=>$parseSlots((string)($settings['retirada_horarios']??$legacy))];
}

function validarDataAgendamento(PDO $pdo, string $date): bool {
    $timezone=new DateTimeZone('America/Sao_Paulo');
    $selected=DateTimeImmutable::createFromFormat('!Y-m-d',$date,$timezone);
    $errors=DateTimeImmutable::getLastErrors();
    if(!$selected||$selected->format('Y-m-d')!==$date||($errors&&($errors['warning_count']||$errors['error_count'])))return false;
    $today=new DateTimeImmutable('today',$timezone);
    if($selected<=$today||$selected>$today->modify('+30 days'))return false;
    $availability=configuracaoAgendamento($pdo);
    return in_array((int)$selected->format('N'),$availability['dias'],true);
}

function validarHorarioAgendamento(PDO $pdo, string $date, string $slot, string $mode='agendada'): bool {
    if(!validarDataAgendamento($pdo,$date))return false;
    $schedule=configuracaoAgendamento($pdo);
    $slots=$mode==='retirada'?$schedule['horarios_retirada']:$schedule['horarios_entrega'];
    return in_array($slot,$slots,true);
}

function gerarCodigoPedidoSeguro(PDO $pdo): string {
    $exists=$pdo->prepare('SELECT 1 FROM pedidos WHERE pin_entrega=? LIMIT 1');
    for($attempt=0;$attempt<20;$attempt++){
        $code=(string)random_int(100000,999999);
        $exists->execute([$code]);
        if(!$exists->fetchColumn())return $code;
    }
    throw new RuntimeException('Não foi possível gerar um código de retirada exclusivo. Tente novamente.');
}

function opcoesFretePorCep(PDO $pdo, string $cep, bool $allowPickupOutsideArea=false, ?float $latitude=null, ?float $longitude=null, array $address=[]): array {
    $location=coordenadasCepEntrega($cep,$latitude,$longitude,$address);
    $settings=$pdo->query("SELECT chave,valor FROM configuracoes WHERE chave IN ('frete_padrao','loja_latitude','loja_longitude')")->fetchAll(PDO::FETCH_KEY_PAIR);
    $rawLatitude=$settings['loja_latitude']??'-23.55052';
    $rawLongitude=$settings['loja_longitude']??'-46.63331';
    if(!is_numeric($rawLatitude)||!is_numeric($rawLongitude)||(float)$rawLatitude < -90||(float)$rawLatitude > 90||(float)$rawLongitude < -180||(float)$rawLongitude > 180)throw new RuntimeException('As coordenadas da loja precisam ser configuradas corretamente.');
    $storeLatitude=(float)$rawLatitude;
    $storeLongitude=(float)$rawLongitude;
    $distance=distanciaEntregaKm($storeLatitude,$storeLongitude,$location['latitude'],$location['longitude']);
    if($distance>50){
        if($allowPickupOutsideArea)return ['cep'=>$location['cep'],'distancia_km'=>$distance,'agendada'=>null,'expressa'=>null,'retirada'=>0.0,'entrega_disponivel'=>false,'endereco'=>$location['endereco'],'agendamento'=>configuracaoAgendamento($pdo)];
        throw new OutOfBoundsException('Este CEP está fora da nossa área de entrega, a mais de 50 km da loja. Para essa região, está disponível somente a retirada gratuita.');
    }

    $base=max(0,(float)($settings['frete_padrao']??5));
    $distanceSurcharge=round($distance*0.35,2);
    $scheduled=round($base+$distanceSurcharge,2);
    $express=round($scheduled+max(5,$base),2);
    return ['cep'=>$location['cep'],'distancia_km'=>$distance,'agendada'=>$scheduled,'expressa'=>$express,'retirada'=>0.0,'entrega_disponivel'=>true,'endereco'=>$location['endereco'],'agendamento'=>configuracaoAgendamento($pdo)];
}
