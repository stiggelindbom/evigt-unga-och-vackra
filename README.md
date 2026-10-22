# De Evigt Unga å Vackra

Hemsida för De Evigt Unga å Vackra – helt statisk, ingen databas behövs.

- `index.html` – hemsidan
- `admin.html` – backoffice för låtar och länkar
- `musik/innehall.json` – låtlistan och länkarna (redigeras via backoffice)
- `musik/*.mp3` – demos som spelas i radion och kan laddas ner
- `assets/` – logga, omslag och bilder

## Så funkar sidan
- **Radion** spelar demos från `musik/`. Besökare kan ladda ner en demo efter att ha klickat
  "Följ oss på Spotify" och "Gilla oss på Facebook" (sidan kan inte kontrollera att de faktiskt gör det).
- **Släppta låtar** ligger längst ner och spelas via Spotify-spelaren, så att lyssningarna räknas på Spotify.

## Backoffice
Öppna `/admin.html` och logga in med en GitHub-nyckel (instruktion finns på inloggningssidan).
Där kan du lägga till låtar, ladda upp mp3, flytta mellan Demo och Släppt, ändra ordning,
klistra in Spotify-länkar och ändra kanaler. Allt sparas direkt i det här repot.

Mer om att lägga upp låtar: `musik/LAGG-UPP-LATAR.md`.

## Drift
Sidan måste köras från en webbserver (GitHub Pages eller egen server). Kör servern en kopia
av repot behöver den hämta ändringar (`git pull`) efter att man sparat i backoffice.
