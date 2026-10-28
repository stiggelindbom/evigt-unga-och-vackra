# devigtunga.se – arbetsregler för Claude

Bandsidan för De Evigt Unga å Vackra och DJ Stigge (Stig Lindbom). GitHub Pages, data i `musik/innehall.json`, backoffice i `admin.html`.

## Kommunikation
- Skriv alltid på **svenska**. Stig är inte programmerare: korta steg, ett i taget, be gärna om skärmbilder.
- Tider anges i svensk tid med 24-timmarsklocka ("femton till nitton", inte "tre till sju").

## Dokument och filer
- Stig använder **Microsoft 365 / OneDrive – inte Google Drive**. Dokument, listor och rapporter sparas i OneDrive-mappen **"Hemsidan devigtunga.se"**.
- Att göra-listan heter `ATT-GÖRA – få igång allt.md` i den mappen – håll den uppdaterad.
- Låtarnas originalfiler (WAV, stems, omslag) ligger i OneDrive under `De evigt unga å vackra/<låt>/`.

## Säkerhet
- Lösenord, nycklar och tokens skrivs **aldrig** i chatten eller i repot – de ligger i backoffice → 🔐 Valv.
- `config.php` får aldrig hamna på GitHub. Spara inga IP-adresser (GDPR).

## Git
- Committa som Stig Lindbom <info@stigges.se>. Stagea bara de filer du ändrat.
- Ändra inte `musik/innehall.json` medan Stig kan ha backoffice öppet – varna först (annars blir det sparkonflikt).
- Repot är publikt och allt publiceras på devigtunga.se – inget känsligt i filerna.

## Bra att veta
- Planerade inlägg skickas av `.github/workflows/planerade-inlagg.yml` (GitHub kör schemat ojämnt – väckarklocka via cron-job.org rekommenderas).
- Make tar emot inlägg via webhook och skickar kvitto tillbaka (`status/<id>.json`, grön prick i backoffice).
- AI-studion i backoffice använder fal.ai (nyckel i valvet). Research om modeller och priser: OneDrive-filen `AI-research – fal, Make, Suno (sammanfattning).md`.
- Wifi-/Bluetooth-högtalare fördröjer ljudet – synka video med hörlurar.
