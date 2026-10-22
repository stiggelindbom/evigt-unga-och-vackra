# Engångskoder för smakprov – installation (för Fredde)

Den här mappen är en liten PHP-funktion som gör att smakprov (demos med 30 s klipp)
bara kan laddas ner med **engångskoder**. Koden kontrolleras på servern, filen skickas
och koden spärras direkt. Låtfilerna ligger i en mapp som inte går att nå utifrån.

Kräver: PHP 8.1 eller senare (ingen databas behövs).

## 1. Lägg upp filerna
Kopiera `ladda.php`, `koder.php`, `gemensamt.php` och `.htaccess` till en mapp på webbservern,
t.ex. `https://din-server.se/deu/`.

## 2. Skapa config.php
Kopiera `config.exempel.php` till `config.php` (samma mapp) och fyll i:
- `admin_nyckel` – lång hemlig nyckel, skapa med: `php -r "echo bin2hex(random_bytes(24));"`
- `musik_mapp` – mapp **utanför webbroten** där mp3-filerna ligger
- `koder_fil` – fil **utanför webbroten** där koderna sparas (skapas automatiskt)
- `tillatna_ursprung` – hemsidans adress(er)

`config.php` får aldrig läggas på GitHub (den är ignorerad i .gitignore).

## 3. Lägg in låtfilerna
Kopiera mp3-filerna från repots `musik/`-mapp till `musik_mapp`. Filnamnen måste vara samma.

## 4. Koppla ihop med hemsidan
I backoffice → **Länkar** → *Server för engångskoder*: skriv adressen, t.ex. `https://din-server.se/deu/`, och spara.
Under **Engångskoder** fyller Stigge i admin-nyckeln och skapar koder.

## Testa
```
# skapa en kod
curl -X POST -H "X-Admin-Nyckel: DIN_NYCKEL" -H "Content-Type: application/json" \
     -d '{"notering":"test"}' https://din-server.se/deu/koder.php
# ladda ner med koden (fungerar en gång)
curl -X POST -d "fil=svenne-g.mp3&kod=ABCD-EFGH" -o test.mp3 https://din-server.se/deu/ladda.php
```

## Säkerhet
- Koderna sparas bara som SHA-256 – inte i klartext.
- Fillås gör att samma kod inte kan användas två gånger samtidigt.
- Bara `.mp3`-filer i `musik_mapp` kan hämtas; sökvägar som `../` stoppas.
- Fel kod ger en kort fördröjning (gör gissning långsam).
- När servern är inkopplad: ta bort smakprovens mp3-filer från GitHub-repot så att de inte kan hämtas där.
