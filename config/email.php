<?php
declare(strict_types=1);

function alvoradaEmailSetting(string $key, string $default = ''): string
{
    static $localSettings = null;
    if ($localSettings === null) {
        $localSettings = [];
        $file = dirname(__DIR__).'/.env.local';
        if (is_file($file) && is_readable($file)) {
            foreach (file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
                $line = trim($line);
                if ($line === '' || str_starts_with($line, '#') || !str_contains($line, '=')) continue;
                [$name, $value] = explode('=', $line, 2);
                $name = trim($name);
                $value = trim(trim($value), "\"'");
                if ($name !== '') $localSettings[$name] = $value;
            }
        }
    }
    $environmentValue = getenv($key);
    if ($environmentValue !== false && $environmentValue !== '') return trim($environmentValue);
    $localValue = trim((string)($localSettings[$key] ?? ''));
    return $localValue !== '' ? $localValue : $default;
}

function alvoradaSmtpRead($socket, array $acceptedCodes): string
{
    $response = '';
    do {
        $line = fgets($socket, 515);
        if ($line === false) throw new RuntimeException('O servidor de e-mail encerrou a conexão.');
        $response .= $line;
    } while (isset($line[3]) && $line[3] === '-');

    $code = (int)substr($line, 0, 3);
    if (!in_array($code, $acceptedCodes, true)) {
        throw new RuntimeException('O servidor SMTP recusou uma etapa do envio (código '.$code.').');
    }
    return $response;
}

function alvoradaSmtpCommand($socket, string $command, array $acceptedCodes): string
{
    if (fwrite($socket, $command."\r\n") === false) throw new RuntimeException('Não foi possível enviar um comando SMTP.');
    return alvoradaSmtpRead($socket, $acceptedCodes);
}

function enviarEmailNewsletter(string $recipient): void
{
    $host = alvoradaEmailSetting('ALVORADA_SMTP_HOST');
    $port = (int)alvoradaEmailSetting('ALVORADA_SMTP_PORT', '465');
    $encryption = strtolower(alvoradaEmailSetting('ALVORADA_SMTP_ENCRYPTION', 'ssl'));
    $username = alvoradaEmailSetting('ALVORADA_SMTP_USERNAME');
    $password = preg_replace('/\s+/', '', alvoradaEmailSetting('ALVORADA_SMTP_PASSWORD')) ?? '';
    $from = alvoradaEmailSetting('ALVORADA_EMAIL_FROM', $username);
    $fromName = alvoradaEmailSetting('ALVORADA_EMAIL_FROM_NAME', 'Supermercado Alvorada');
    $siteUrl = rtrim(alvoradaEmailSetting('ALVORADA_SITE_URL'), '/');

    if (!$host || !$username || !$password || !filter_var($from, FILTER_VALIDATE_EMAIL) || !$siteUrl || !filter_var($siteUrl, FILTER_VALIDATE_URL)) {
        throw new RuntimeException('Configure as variáveis SMTP e ALVORADA_SITE_URL no arquivo .env.local.');
    }
    if (!in_array($encryption, ['tls', 'ssl'], true) || $port < 1 || $port > 65535) {
        throw new RuntimeException('A configuração de segurança SMTP deve ser tls ou ssl e usar uma porta válida.');
    }
    if (!filter_var($recipient, FILTER_VALIDATE_EMAIL)) throw new InvalidArgumentException('O e-mail do destinatário é inválido.');

    $transport = $encryption === 'ssl' ? 'ssl://' : 'tcp://';
    $socket = @stream_socket_client($transport.$host.':'.$port, $errno, $errstr, 15, STREAM_CLIENT_CONNECT);
    if (!$socket) throw new RuntimeException('Não foi possível conectar ao servidor SMTP ('.$errno.').');
    stream_set_timeout($socket, 15);

    try {
        alvoradaSmtpRead($socket, [220]);
        $heloName = preg_replace('/[^a-z0-9.-]/i', '', gethostname() ?: 'localhost') ?: 'localhost';
        alvoradaSmtpCommand($socket, 'EHLO '.$heloName, [250]);
        if ($encryption === 'tls') {
            alvoradaSmtpCommand($socket, 'STARTTLS', [220]);
            if (!stream_socket_enable_crypto($socket, true, STREAM_CRYPTO_METHOD_TLS_CLIENT)) {
                throw new RuntimeException('Não foi possível iniciar a conexão TLS com o servidor SMTP.');
            }
            alvoradaSmtpCommand($socket, 'EHLO '.$heloName, [250]);
        }
        alvoradaSmtpCommand($socket, 'AUTH LOGIN', [334]);
        alvoradaSmtpCommand($socket, base64_encode($username), [334]);
        alvoradaSmtpCommand($socket, base64_encode($password), [235]);
        alvoradaSmtpCommand($socket, 'MAIL FROM:<'.$from.'>', [250]);
        alvoradaSmtpCommand($socket, 'RCPT TO:<'.$recipient.'>', [250, 251]);
        alvoradaSmtpCommand($socket, 'DATA', [354]);

        $subject = '=?UTF-8?B?'.base64_encode('Bem-vindo à Newsletter do Supermercado Alvorada').'?=';
        $offersUrl = $siteUrl.'/#ofertas';
        $safeOffersUrl = htmlspecialchars($offersUrl, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
        $safeFromName = '=?UTF-8?B?'.base64_encode(str_replace(["\r", "\n"], '', $fromName)).'?=';
        $textBody = "Sua inscrição na Newsletter do Supermercado Alvorada foi confirmada.\r\n\r\nAcompanhe nossas novidades e ofertas: {$offersUrl}\r\n";
        $htmlBody = '<!doctype html><html lang="pt-BR"><body style="margin:0;padding:32px;background:#f7f2e8;font-family:Arial,sans-serif;color:#352316"><div style="max-width:560px;margin:auto;padding:32px;background:#fff;border-radius:16px"><p style="color:#b47d28;font-weight:bold;letter-spacing:2px">SUPERMERCADO ALVORADA</p><h1 style="color:#60371f">Inscrição confirmada!</h1><p>Você receberá novidades, descontos e ofertas exclusivas do Alvorada neste e-mail.</p><p style="margin:28px 0"><a href="'.$safeOffersUrl.'" style="display:inline-block;padding:14px 22px;border-radius:28px;background:#d49a3d;color:#352316;text-decoration:none;font-weight:bold">Acessar ofertas</a></p><p style="font-size:13px;color:#78695b">Se você não solicitou esta inscrição, pode ignorar esta mensagem.</p></div></body></html>';
        $boundary = '=_Alvorada_'.bin2hex(random_bytes(12));
        $headers = [
            'Date: '.gmdate('D, d M Y H:i:s').' +0000',
            'From: '.$safeFromName.' <'.$from.'>',
            'To: <'.$recipient.'>',
            'Subject: '.$subject,
            'MIME-Version: 1.0',
            'Content-Type: multipart/alternative; boundary="'.$boundary.'"',
        ];
        $body = '--'.$boundary."\r\nContent-Type: text/plain; charset=UTF-8\r\nContent-Transfer-Encoding: quoted-printable\r\n\r\n".quoted_printable_encode($textBody)."\r\n";
        $body .= '--'.$boundary."\r\nContent-Type: text/html; charset=UTF-8\r\nContent-Transfer-Encoding: quoted-printable\r\n\r\n".quoted_printable_encode($htmlBody)."\r\n--".$boundary."--\r\n";
        $message = implode("\r\n", $headers)."\r\n\r\n".$body;
        $messageLines = preg_split('/\r\n|\r|\n/', $message) ?: [];
        $messageLines = array_map(static fn(string $line): string => str_starts_with($line, '.') ? '.'.$line : $line, $messageLines);
        if (fwrite($socket, implode("\r\n", $messageLines)."\r\n.\r\n") === false) {
            throw new RuntimeException('Não foi possível transmitir a mensagem ao servidor SMTP.');
        }
        alvoradaSmtpRead($socket, [250]);
        alvoradaSmtpCommand($socket, 'QUIT', [221]);
    } finally {
        fclose($socket);
    }
}
