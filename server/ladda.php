<?php
// Nedladdning av smakprov med ENGÅNGSKOD.
// POST fil=<filnamn.mp3>&kod=<KOD>  ->  filen skickas och koden spärras.
declare(strict_types=1);
require __DIR__ . '/gemensamt.php';
cors();

$in  = indata();
$fil = basename((string)($in['fil'] ?? ''));
$kod = (string)($in['kod'] ?? '');

if (!preg_match('/^[a-z0-9][a-z0-9._-]*\.mp3$/i', $fil)) { svara(400, ['fel' => 'Ogiltigt filnamn']); }
$sokvag = rtrim(konfig()['musik_mapp'], '/') . '/' . $fil;
if (!is_file($sokvag)) { svara(404, ['fel' => 'Låten finns inte på servern']); }
if (normalisera($kod) === '') { svara(400, ['fel' => 'Ingen kod']); }

$fa = fingeravtryck($kod);
$ok = med_koder(function (array &$koder) use ($fa, $fil) {
  if (!isset($koder[$fa]) || !empty($koder[$fa]['anvand'])) { return false; }
  $k = &$koder[$fa];
  if (!empty($k['fil']) && $k['fil'] !== $fil) { return false; }   // kod låst till en viss låt
  $k['anvand'] = date('c');
  $k['anvand_fil'] = $fil;
  return true;
});

if (!$ok) { usleep(800000); svara(403, ['fel' => 'Koden är ogiltig eller redan använd']); }

$namn = (string)($in['namn'] ?? $fil);
$namn = preg_replace('/[\\\\\/:*?"<>|]+/', '', $namn) ?: $fil;
header('Content-Type: audio/mpeg');
header('Content-Length: ' . filesize($sokvag));
header("Content-Disposition: attachment; filename=\"" . preg_replace('/[^\x20-\x7e]/', '_', $namn) . "\"; filename*=UTF-8''" . rawurlencode($namn));
header('Cache-Control: no-store');
readfile($sokvag);
