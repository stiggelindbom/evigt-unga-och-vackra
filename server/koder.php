<?php
// Hantering av engångskoder från backoffice. Kräver headern X-Admin-Nyckel.
//   GET                         -> lista koder (utan klartext)
//   POST {notering, fil?}       -> skapa en kod; klartexten visas BARA i svaret
//   DELETE {id}                 -> ta bort kod
declare(strict_types=1);
require __DIR__ . '/gemensamt.php';
cors();

$nyckel = $_SERVER['HTTP_X_ADMIN_NYCKEL'] ?? '';
if (!hash_equals(konfig()['admin_nyckel'], $nyckel)) { usleep(800000); svara(401, ['fel' => 'Fel admin-nyckel']); }

$metod = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$in = indata();

if ($metod === 'GET') {
  $lista = med_koder(function (array &$koder) {
    $ut = [];
    foreach ($koder as $fa => $k) { $ut[] = ['id' => substr($fa, 0, 12)] + $k; }
    usort($ut, fn($a, $b) => strcmp($b['skapad'] ?? '', $a['skapad'] ?? ''));
    return $ut;
  });
  svara(200, ['koder' => $lista]);
}

if ($metod === 'POST') {
  $alfabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';   // utan O/0/I/1 som är lätta att blanda ihop
  $kod = '';
  for ($i = 0; $i < 8; $i++) { $kod .= $alfabet[random_int(0, strlen($alfabet) - 1)]; }
  $kod = substr($kod, 0, 4) . '-' . substr($kod, 4);
  $post = [
    'notering' => mb_substr(trim((string)($in['notering'] ?? '')), 0, 80),
    'fil'      => basename((string)($in['fil'] ?? '')) ?: null,
    'skapad'   => date('c'),
    'anvand'   => null,
  ];
  med_koder(function (array &$koder) use ($kod, $post) { $koder[fingeravtryck($kod)] = $post; });
  svara(200, ['kod' => $kod] + $post);
}

if ($metod === 'DELETE') {
  $id = preg_replace('/[^a-f0-9]/', '', (string)($in['id'] ?? ''));
  $borta = med_koder(function (array &$koder) use ($id) {
    foreach (array_keys($koder) as $fa) { if ($id !== '' && str_starts_with($fa, $id)) { unset($koder[$fa]); return true; } }
    return false;
  });
  svara($borta ? 200 : 404, ['borttagen' => $borta]);
}

svara(405, ['fel' => 'Metoden stöds inte']);
