<?php

function flyerPhotoSpriteStyle(string $slug): ?string {
    $flyerPhotoCrops = [
        'cuscuz-flocao-500g'=>[77,290,130], 'leite-po-integral-400g'=>[296,289,120], 'acucar-cristal-1kg'=>[520,288,125],
        'biscoito-agua-sal-350g'=>[80,448,128], 'cafe-torrado-moido-500g'=>[312,449,108], 'arroz-branco-tipo1-5kg'=>[519,448,122],
        'multiuso-limpeza-500ml'=>[82,605,118], 'papel-higienico-folha-dupla-12'=>[292,606,132], 'lava-roupas-liquido-3l'=>[519,603,126],
        'pao-frances-500g'=>[80,768,131], 'leite-condensado-395g'=>[294,768,133], 'feijao-carioca-1kg'=>[520,765,127]
    ];
    if (!isset($flyerPhotoCrops[$slug])) return null;
    [$x,$y,$side] = $flyerPhotoCrops[$slug];
    $size = number_format(765 / $side * 100, 4, '.', '');
    $left = number_format($x / (765 - $side) * 100, 4, '.', '');
    $top = number_format($y / (1024 - $side) * 100, 4, '.', '');
    return "background-image:url('/assets/images/encarte-ofertas-do-dia.webp?v=1');background-size:{$size}% auto;background-position:{$left}% {$top}%";
}
