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

// Radion: låtarna som spelas på sidan.
// Lägg mp3-filen i mappen "musik" och skriv filnamnet under "fil".
// Låtar vars fil saknas visas som "Kommer snart" och hoppas över.
//   titel:  låtens namn
//   fil:    filnamnet i musik-mappen (använd .mp3, inte .wav – wav är för stort)
//   info:   kort text som visas i spellistan
//   typ:    "Demo", "Ny", "Singel" … valfritt
//   ladda:  true = får laddas ner (efter gilla), false = bara lyssna
window.LATAR = [
  { titel: "Sista kalla flaskan",   fil: "sista-kalla-flaskan.mp3",   info: "Vem snodde sista kalla flaskan i natt?",          typ: "Demo",      ladda: true },
  { titel: "Parapapa (Sommarfest)", fil: "parapapa.mp3",              info: "PARAPA-PAPAPAPA-RAPA-PA! Put 'em up!",           typ: "Sommarhit", ladda: true },
  { titel: "Kom och värm dej",      fil: "kom-och-varm-dej.mp3",      info: "Låten som startade allt.",                        typ: "Singel",    ladda: true },
  { titel: "Svenne G",              fil: "svenne-g.mp3",              info: "Han skulle bara softa och spela spel …",          typ: "Demo",      ladda: true },
  { titel: "Sommargodis",           fil: "sommargodis.mp3",           info: "Godisdag! Reggaepop med strandkänsla.",           typ: "Demo",      ladda: true },
  { titel: "Bollen är röd",         fil: "bollen-ar-rod.mp3",         info: "Hur kan den runda gula bollen rulla?",            typ: "Demo",      ladda: true },
  { titel: "Vi älskar Siwan",       fil: "vi-alskar-siwan.mp3",       info: "En hyllning.",                                    typ: "Demo",      ladda: true },
  { titel: "Ingvar Ståhl",          fil: "ingvar-stahl.mp3",          info: "En låt om en legend.",                            typ: "Ny",        ladda: true },
  { titel: "Vart tog den söta lilla flickan vägen", fil: "vart-tog-flickan-vagen.mp3", info: "Frågan alla ställer klockan tre på natten.", typ: "Demo", ladda: true },
  { titel: "När vi går för guld",   fil: "nar-vi-gar-for-guld.mp3",   info: "Hymnen. Tungan ute, solglasögonen på.",           typ: "Hymn",      ladda: true }
];
