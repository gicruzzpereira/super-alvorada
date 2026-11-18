<?php
declare(strict_types=1);

/** Configuração central, autenticação, autorização e utilitários HTTP. */
if (session_status() !== PHP_SESSION_ACTIVE) {
    $sessionPath = __DIR__.'/../storage/sessions';
    if (!is_dir($sessionPath)) { mkdir($sessionPath, 0700, true); }
    if (is_dir($sessionPath) && is_writable($sessionPath)) { session_save_path($sessionPath); }
    session_set_cookie_params(['httponly'=>true, 'secure'=>!empty($_SERVER['HTTPS']), 'samesite'=>'Lax']);
    session_start();
}
const DB_HOST = '127.0.0.1';
const DB_NAME = 'supermercado_alvorada';
const DB_USER = 'root';
const DB_PASS = '';

function db(): PDO {
    static $pdo;
    if (!$pdo) $pdo = new PDO('mysql:host='.DB_HOST.';dbname='.DB_NAME.';charset=utf8mb4', DB_USER, DB_PASS, [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC, PDO::ATTR_EMULATE_PREPARES=>false]);
    return $pdo;
}
function verificarAcesso(string|array $perfilPermitido): void {
    $permitidos = (array)$perfilPermitido;
    if (empty($_SESSION['usuario']) || !in_array($_SESSION['usuario']['perfil'] ?? '', $permitidos, true)) {
        http_response_code(empty($_SESSION['usuario']) ? 401 : 403);
        if (empty($_SESSION['usuario'])) { header('Location: /auth/login.php'); exit; }
        exit('Acesso não autorizado.');
    }
}
function h(?string $v): string { return htmlspecialchars((string)$v, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); }
function csrf(): string { return $_SESSION['csrf'] ??= bin2hex(random_bytes(32)); }
function validarCsrf(): void { if (!hash_equals(csrf(), (string)($_POST['csrf'] ?? ''))) { http_response_code(400); exit('Token inválido. Atualize a página.'); } }
function jsonResponse(array $data, int $status=200): never { http_response_code($status); header('Content-Type: application/json; charset=utf-8'); echo json_encode($data, JSON_UNESCAPED_UNICODE); exit; }
function dinheiro(float $v): string { return 'R$ '.number_format($v, 2, ',', '.'); }
