<?php
// Kopiera till config.php och fyll i. config.php ska ALDRIG läggas på GitHub.
return [
  // Lång hemlig nyckel som backoffice använder för att skapa/ta bort koder.
  // Skapa t.ex. med:  php -r "echo bin2hex(random_bytes(24));"
  'admin_nyckel' => 'BYT-TILL-EN-LANG-HEMLIG-NYCKEL',

  // Mapp med låtfilerna (mp3) – ska ligga UTANFÖR webbroten så att de inte kan hämtas direkt.
  'musik_mapp' => '/var/www/privat/evigt-unga/musik',

  // Fil där koderna sparas (bara fingeravtryck, aldrig klartext). Utanför webbroten.
  'koder_fil' => '/var/www/privat/evigt-unga/koder.json',

  // Hemsidans adress (för CORS). Flera tillåtna, t.ex. GitHub Pages och egen domän.
  'tillatna_ursprung' => [
    'https://stiggelindbom.github.io',
    'https://devigtunga.se',
    'https://www.devigtunga.se',
  ],
];
