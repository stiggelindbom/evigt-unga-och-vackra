# Så lägger du upp en ny låt

## Enklast: via backoffice
1. Gå till `/admin.html` och logga in.
2. Klicka **+ Ny demo**, skriv titel och kort text.
3. Klicka **Ladda upp mp3** och välj filen. Den laddas upp direkt.
4. Klicka **Spara ändringar**.

När låten släpps på Spotify: byt **Lista** till *Släppt (Spotify)*, klistra in låtens
Spotify-länk (i Spotify: ··· → Dela → Kopiera länk till låt) och spara.

## Om mp3-filen
- Använd mp3, inte wav (wav är 50+ MB). 256–320 kbps räcker gott. Max 40 MB.
- Med ffmpeg: `ffmpeg -i "låten.wav" -b:a 320k laten.mp3`

## Utan backoffice (för Fredde)
Lägg mp3:an i `musik/` och lägg till låten i `musik/innehall.json` med samma filnamn under `"fil"`.
