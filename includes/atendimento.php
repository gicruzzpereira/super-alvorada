<?php

function alvoradaWhatsApp(string $message = ''): string
{
    $url = 'https://wa.me/5511987147839';
    return $message === '' ? $url : $url.'?text='.rawurlencode($message);
}
