// Körs av GitHub Actions var 15:e minut (se .github/workflows/planerade-inlagg.yml).
// Skickar inlägg som väntar (planerade vars tid har kommit, eller som inte kunde skickas direkt) till Make,
// markerar dem som skickade och bygger om inlagg.xml så att de syns i flödet.
import { readFileSync, writeFileSync } from "node:fs";

const SIDA = "https://devigtunga.se/";
const DATAFIL = "musik/innehall.json";
const webhook = process.env.MAKE_WEBHOOK || "";
const nu = new Date();

const data = JSON.parse(readFileSync(DATAFIL, "utf8"));
data.inlagg ||= []; data.artister ||= []; data.lankar ||= {};
const mediaUrl = m => /^https?:/.test(m) ? m : SIDA + m.split("/").map(encodeURIComponent).join("/");
const ren = t => String(t || "").trim().toLowerCase();

const dags = data.inlagg.filter(p => p.vantar && !p.skickad && (!p.planerad || new Date(p.planerad) <= nu));
let andrat = false;
if (!dags.length) console.log("Inget att skicka just nu.");
else if (!/^https:\/\/hook\.[a-z0-9.-]*make\.com\//i.test(webhook)) console.log(`${dags.length} inlägg väntar, men hemligheten MAKE_WEBHOOK saknas eller är fel.`);
else for (const p of dags) {
  if (p.media) {   // filen ska synas på hemsidan innan Make hämtar den
    let ok = false;
    for (let i = 0; i < 6 && !ok; i++) { try { ok = (await fetch(mediaUrl(p.media), { method: "HEAD" })).ok; } catch {} if (!ok) await new Promise(r => setTimeout(r, 10000)); }
    if (!ok) { console.log(`Hoppar över ${p.id}: ${p.media} syns inte på hemsidan än.`); continue; }
  }
  const art = data.artister.find(a => ren(a.namn) === ren(p.artist));
  const k = art || data.lankar, kan = p.kanaler || ["facebook", "instagram", "youtube"];
  const falt = { id: p.id, text: p.text, artist: p.artist || "De Evigt Unga å Vackra", typ: p.typ, format: p.format || "", media_url: p.media ? mediaUrl(p.media) : "", mime: p.mime || "",
    lank: p.lank || SIDA, datum: p.datum, youtube: k.youtube || "", instagram: k.instagram || "", facebook: k.facebook || "", tiktok: k.tiktok || "",
    till_facebook: kan.includes("facebook") ? "ja" : "nej", till_instagram: kan.includes("instagram") ? "ja" : "nej", till_youtube: kan.includes("youtube") ? "ja" : "nej" };
  const svar = await fetch(webhook, { method: "POST", body: new URLSearchParams(falt) });
  if (!svar.ok) { console.log(`Make svarade ${svar.status} för ${p.id} – försöker igen nästa körning.`); continue; }
  p.skickad = nu.toISOString(); delete p.vantar; andrat = true;
  console.log(`Skickade ${p.id} (${kan.join(", ") || "bara hemsidan"}).`);
}

// inlagg.xml: bara det som är publicerat
const x = t => String(t ?? "").replace(/[<>&'"]/g, c => ({ "<": "&lt;", ">": "&gt;", "&": "&amp;", "'": "&apos;", '"': "&quot;" }[c]));
const synliga = data.inlagg.filter(p => p.typ !== "paminnelse" && (!p.planerad || new Date(p.planerad) <= nu)).slice(0, 20);
const flode = `<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
<channel>
<title>De Evigt Unga å Vackra – inlägg</title>
<link>${SIDA}</link>
<description>Inlägg från De Evigt Unga å Vackra (för Facebook, Instagram och YouTube via Make)</description>
<language>sv</language>
${synliga.map(p => `<item>
  <title>${x((p.text.split("\n")[0] || "Nytt från De Evigt Unga å Vackra").slice(0, 90))}</title>
  <description>${x(p.text)}</description>
  <link>${x(p.lank || SIDA)}</link>
  <guid isPermaLink="false">${x(p.id)}</guid>
  <pubDate>${new Date(p.datum).toUTCString()}</pubDate>
  <category>${x(p.artist || "De Evigt Unga å Vackra")}</category>${p.format ? `
  <category domain="format">${x(p.format)}</category>` : ""}${p.media ? `
  <enclosure url="${x(mediaUrl(p.media))}" type="${x(p.mime)}" length="${p.storlek || 0}"/>
  <media:content url="${x(mediaUrl(p.media))}" medium="${p.typ === "video" ? "video" : "image"}" type="${x(p.mime)}"/>` : ""}
</item>`).join("\n")}
</channel>
</rss>
`;
let gammalt = ""; try { gammalt = readFileSync("inlagg.xml", "utf8"); } catch {}
if (flode !== gammalt) writeFileSync("inlagg.xml", flode);
if (andrat) writeFileSync(DATAFIL, JSON.stringify(data, null, 2) + "\n");
