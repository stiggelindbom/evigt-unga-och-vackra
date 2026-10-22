// ===================================================================
//  HÄR ÄNDRAR DU SIDANS INNEHÅLL – ingen annan fil behöver röras.
// ===================================================================

// Länkar till våra kanaler. Klistra in hela adressen mellan citattecknen.
// Lämna tomt ("") om vi inte har kanalen – då döljs knappen.
window.LANKAR = {
  spotify:   "https://open.spotify.com/artist/1zt7RJzrpN5QPvB789VIuV",
  facebook:  "https://www.facebook.com/deevigtungavackra",
  instagram: "",
  youtube:   "",
  mejl:      ""    // t.ex. "boka@exempel.se"
};

// Radion: låtarna som spelas på sidan, uppdelade i två listor:
//   slappt: true  -> hamnar under "Släppta låtar" (med Spotify-knapp)
//   slappt: false -> hamnar under "Demos"
// Lägg mp3-filen i mappen "musik" och skriv filnamnet under "fil".
// Demos vars fil saknas visas som "Kommer snart" och hoppas över av radion.
// Släppta låtar utan mp3 visas ändå, med knapp till Spotify.
//   titel:   låtens namn
//   fil:     filnamnet i musik-mappen (använd .mp3, inte .wav – wav är för stort)
//   info:    kort text som visas i listan
//   typ:     liten etikett, t.ex. "Singel", "Sommarhit" … valfritt
//   spotify: länk direkt till låten på Spotify (valfritt – annars artistsidan)
//   ladda:   true = får laddas ner (efter följ/gilla), false = bara lyssna
window.LATAR = [
  // ---------- SLÄPPTA ----------
  { slappt: true,  titel: "Kom och värm dej",      fil: "kom-och-varm-dej.mp3", info: "Låten som startade allt.",              typ: "Singel",    spotify: "", ladda: false },
  { slappt: true,  titel: "Parapapa (Sommarfest)", fil: "parapapa.mp3",         info: "PARAPA-PAPAPAPA-RAPA-PA! Put 'em up!", typ: "Sommarhit", spotify: "", ladda: false },
  { slappt: true,  titel: "Svenne G",              fil: "svenne-g.mp3",         info: "Han skulle bara softa och spela spel …", typ: "Singel",  spotify: "", ladda: false },

  // ---------- DEMOS ----------
  { slappt: false, titel: "Sista kalla flaskan",   fil: "sista-kalla-flaskan.mp3",   info: "Vem snodde sista kalla flaskan i natt?",  typ: "Demo", ladda: true },
  { slappt: false, titel: "Sommargodis",           fil: "sommargodis.mp3",           info: "Godisdag! Reggaepop med strandkänsla.",   typ: "Demo", ladda: true },
  { slappt: false, titel: "Bollen är röd",         fil: "bollen-ar-rod.mp3",         info: "Hur kan den runda gula bollen rulla?",    typ: "Demo", ladda: true },
  { slappt: false, titel: "Vi älskar Siwan",       fil: "vi-alskar-siwan.mp3",       info: "En hyllning.",                            typ: "Demo", ladda: true },
  { slappt: false, titel: "Ingvar Ståhl",          fil: "ingvar-stahl.mp3",          info: "En låt om en legend.",                    typ: "Demo", ladda: true },
  { slappt: false, titel: "Vart tog den söta lilla flickan vägen", fil: "vart-tog-flickan-vagen.mp3", info: "Frågan alla ställer klockan tre på natten.", typ: "Demo", ladda: true },
  { slappt: false, titel: "När vi går för guld",   fil: "nar-vi-gar-for-guld.mp3",   info: "Hymnen. Tungan ute, solglasögonen på.",   typ: "Demo", ladda: true }
];
