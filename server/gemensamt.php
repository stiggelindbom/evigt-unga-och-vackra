<?php
// Delad kod för ladda.php och koder.php
declare(strict_types=1);

function konfig(): array {
  static $k = null;
  if ($k === null) {
    $fil = __DIR__ . '/config.php';
    if (!is_file($fil)) { svara(500, ['fel' => 'config.php saknas på servern']); }
    $k = require $fil;
  }
  return $k;
}

function cors(): void {
  $ursprung = $_SERVER['HTTP_ORIGIN'] ?? '';
  if (in_array($ursprung, konfig()['tillatna_ursprung'], true)) {
    header('Access-Control-Allow-Origin: ' . $ursprung);
    header('Vary: Origin');
    header('Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, X-Admin-Nyckel');
    header('Access-Control-Expose-Headers: Content-Disposition');
  }
  if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') { http_response_code(204); exit; }
}

function svara(int $status, array $data): never {
  http_response_code($status);
  header('Content-Type: application/json; charset=utf-8');
  echo json_encode($data, JSON_UNESCAPED_UNICODE);
  exit;
}

function indata(): array {
  $typ = $_SERVER['CONTENT_TYPE'] ?? '';
  if (str_contains($typ, 'application/json')) {
    return json_decode(file_get_contents('php://input') ?: '{}', true) ?: [];
  }
  return $_POST + $_GET;
}

// Normalisera koden: versaler, bara A-Z och 0-9
function normalisera(string $kod): string {
  return preg_replace('/[^A-Z0-9]/', '', strtoupper($kod));
}
function fingeravtryck(string $kod): string { return hash('sha256', normalisera($kod)); }

// Läs/ändra kodfilen med fillås så att två samtidiga nedladdningar inte kan använda samma kod
function med_koder(callable $andra) {
  $fil = konfig()['koder_fil'];
  if (!is_dir(dirname($fil))) { mkdir(dirname($fil), 0700, true); }
  $fp = fopen($fil, 'c+');
  if (!$fp) { svara(500, ['fel' => 'Kan inte öppna kodfilen']); }
  flock($fp, LOCK_EX);
  $innehall = stream_get_contents($fp);
  $koder = $innehall ? (json_decode($innehall, true) ?: []) : [];
  $resultat = $andra($koder);
  ftruncate($fp, 0); rewind($fp);
  fwrite($fp, json_encode($koder, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT));
  fflush($fp); flock($fp, LOCK_UN); fclose($fp);
  return $resultat;
}
