# Så lägger du upp en ny låt

## Enklast: via backoffice
1. Gå till `/admin.html` och logga in.
2. Klicka **+ Ny demo**, skriv titel och kort text.
3. Klicka **Ladda upp mp3/wav** och välj filen. Wav görs automatiskt om till mp3 (320 kbps)
   i webbläsaren innan den laddas upp – det tar ungefär en halv minut för en vanlig låt.
4. Klicka **Spara ändringar**.

När låten släpps på Spotify: byt **Lista** till *Släppt (Spotify)*, klistra in låtens
Spotify-länk (i Spotify: ··· → Dela → Kopiera länk till låt) och spara.

## Om filerna
- Backoffice tar både mp3 och wav. Wav görs om till mp3 320 kbps innan uppladdning,
  så bara mp3:an hamnar på servern. Max 40 MB efter omvandling.
- Utan backoffice, med ffmpeg: `ffmpeg -i "låten.wav" -b:a 320k laten.mp3`

## Utan backoffice (för Fredde)
Lägg mp3:an i `musik/` och lägg till låten i `musik/innehall.json` med samma filnamn under `"fil"`.
