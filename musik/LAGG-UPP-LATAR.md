# Så lägger du upp en ny låt på radion

1. **Gör om låten till mp3.** Wav-filer är 50+ MB, vilket är för stort. 320 kbps räcker gott.
   Med ffmpeg: `ffmpeg -i "låten.wav" -b:a 320k sista-kalla-flaskan.mp3`
   (eller exportera som mp3 direkt från Suno eller DAW:en).
2. **Döp filen enkelt**: små bokstäver, bindestreck i stället för mellanslag, inga å/ä/ö.
   Exempel: `sista-kalla-flaskan.mp3`
3. **Lägg filen i den här mappen** (`musik/`).
   På GitHub: öppna mappen → *Add file* → *Upload files* → dra in mp3:an → *Commit changes*.
4. **Lägg till en rad i `innehall.js`** under `window.LATAR`, eller kontrollera att filnamnet
   stämmer om låten redan står där. Låten som står överst spelas först.

Klart! Låtar vars fil saknas visas som "Kommer snart" och hoppas över av radion.

## Spotify, Facebook m.m.
Klistra in länkarna överst i `innehall.js` under `window.LANKAR`.
När Spotify-länken finns visas Spotify-spelaren på sidan automatiskt, och
nedladdningsknappen ber besökaren följa och gilla innan låten laddas ner.
