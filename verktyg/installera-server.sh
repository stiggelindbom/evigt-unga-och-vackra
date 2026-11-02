#!/usr/bin/env bash
# Installerar devigtunga.se (sajten + /admin) på en egen server bakom Caddy.
# Körs som root på Ubuntu 24.04, t.ex. i Hetzners webbkonsol:
#   curl -fsSL https://raw.githubusercontent.com/stiggelindbom/evigt-unga-och-vackra/main/verktyg/installera-server.sh | bash
#
# - Caddy tar emot trafiken och fixar HTTPS (Let's Encrypt) automatiskt när DNS pekar hit.
# - Sajten hämtas från GitHub var 30:e sekund – GitHub är fortfarande källan, så backoffice,
#   planerade inlägg och Make-kvitton fungerar precis som förut.
# - Andra appar på servern lägger egna filer i /etc/caddy/sites/ – det här skriptet rör bara sin egen.
# - Nattlig säkerhetskopia 03:15 till /var/backups/devigtunga (14 dagar).
# - Inga lösenord eller nycklar behövs: repot är publikt.
# Skriptet går att köra igen – det uppdaterar bara det som behövs.
set -euo pipefail

DOMAN="devigtunga.se"
REPO="https://github.com/stiggelindbom/evigt-unga-och-vackra.git"
GREN="main"
APP="devigtunga"
HEM="/srv/$APP"
SAJT="$HEM/site"
BACKUP="/var/backups/$APP"
EPOST="info@stigges.se"   # för Let's Encrypt-meddelanden (t.ex. om ett certifikat inte kan förnyas)

steg() { printf '\n\033[1;33m==> %s\033[0m\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "Kör som root."; exit 1; }
export DEBIAN_FRONTEND=noninteractive

steg "1/7 Uppdaterar systemet och installerar git, rsync och automatiska säkerhetsuppdateringar"
apt-get update -q
apt-get -y -q upgrade
apt-get install -y -q git rsync curl ca-certificates gnupg debian-keyring debian-archive-keyring apt-transport-https unattended-upgrades
dpkg-reconfigure -f noninteractive unattended-upgrades >/dev/null 2>&1 || true

steg "2/7 Installerar Caddy (officiella paketkällan)"
if ! command -v caddy >/dev/null; then
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor --yes -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' -o /etc/apt/sources.list.d/caddy-stable.list
  apt-get update -q
  apt-get install -y -q caddy
fi
caddy version

steg "3/7 Skapar systemanvändaren $APP och hämtar sajten från GitHub"
id "$APP" >/dev/null 2>&1 || useradd --system --home-dir "$HEM" --shell /usr/sbin/nologin "$APP"
mkdir -p "$HEM"
chown "$APP:$APP" "$HEM"
chmod 755 "$HEM"
if [ ! -d "$SAJT/.git" ]; then
  sudo -u "$APP" git clone -q --depth 1 --branch "$GREN" "$REPO" "$SAJT"
fi

cat > /usr/local/bin/$APP-sync <<EOF
#!/usr/bin/env bash
# Hämtar senaste versionen av sajten från GitHub (servern ändrar aldrig något själv).
set -euo pipefail
cd "$SAJT"
git fetch -q --depth 1 origin "$GREN"
git reset -q --hard "origin/$GREN"
git clean -qfd
EOF
chmod 755 /usr/local/bin/$APP-sync

cat > /etc/systemd/system/$APP-sync.service <<EOF
[Unit]
Description=Hämta devigtunga.se från GitHub
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
User=$APP
ExecStart=/usr/local/bin/$APP-sync
EOF

cat > /etc/systemd/system/$APP-sync.timer <<EOF
[Unit]
Description=Hämta devigtunga.se från GitHub var 30:e sekund

[Timer]
OnBootSec=20s
OnUnitActiveSec=30s
AccuracySec=5s

[Install]
WantedBy=timers.target
EOF

steg "4/7 Skriver Caddy-inställningarna"
IP4="$(curl -4 -fsS --max-time 10 https://ifconfig.co 2>/dev/null || ip -4 route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}')"
IP6="$(ip -6 addr show scope global 2>/dev/null | awk '/inet6/{print $2}' | cut -d/ -f1 | head -1)"
mkdir -p /etc/caddy/sites

# Huvudfilen: en egen fil per app i /etc/caddy/sites/. En Caddyfile som en annan app redan skrivit lämnas orörd.
if [ ! -f /etc/caddy/Caddyfile ] || grep -q "/usr/share/caddy" /etc/caddy/Caddyfile; then
  cat > /etc/caddy/Caddyfile <<EOF
{
	email $EPOST
}

import /etc/caddy/sites/*.caddy
EOF
elif ! grep -q "import /etc/caddy/sites/\*.caddy" /etc/caddy/Caddyfile; then
  printf '\nimport /etc/caddy/sites/*.caddy\n' >> /etc/caddy/Caddyfile
fi

cat > /etc/caddy/sites/$APP.caddy <<EOF
# devigtunga.se – statisk sajt från GitHub ($SAJT). Ingen åtkomstlogg (inga IP-adresser sparas).
(${APP}_innehall) {
	root * $SAJT
	@dolt path /.git* /.github* /server* /CLAUDE.md /README.md /CNAME
	respond @dolt 404
	@farsk path / *.html *.json *.xml */
	header @farsk Cache-Control "no-cache"
	header -Server
	header X-Content-Type-Options nosniff
	header Referrer-Policy strict-origin-when-cross-origin
	encode zstd gzip
	try_files {path} {path}.html
	file_server
}

$DOMAN {
	header Strict-Transport-Security "max-age=31536000"
	import ${APP}_innehall
}

www.$DOMAN {
	redir https://$DOMAN{uri} permanent
}

# Test innan DNS är bytt: http://$IP4 (kan tas bort när sajten fungerar på $DOMAN)
http://$IP4 {
	import ${APP}_innehall
}
EOF

caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile

steg "5/7 Nattlig säkerhetskopia (03:15, sparas i 14 dagar)"
cat > /usr/local/bin/$APP-backup <<EOF
#!/usr/bin/env bash
# Ögonblicksbild av sajten (filer som inte ändrats delas mellan dagarna, så det tar lite plats).
set -euo pipefail
mkdir -p "$BACKUP"
idag="$BACKUP/\$(date +%F)"
senaste="\$(ls -1d "$BACKUP"/20* 2>/dev/null | grep -v "\$idag" | tail -1 || true)"
rsync -a --delete --exclude .git \${senaste:+--link-dest="\$senaste"} "$SAJT/" "\$idag/"
cp -a /etc/caddy "\$idag.caddy-installningar" 2>/dev/null || true
ls -1d "$BACKUP"/20* 2>/dev/null | grep -v caddy-installningar | head -n -14 | xargs -r rm -rf
ls -1d "$BACKUP"/*.caddy-installningar 2>/dev/null | head -n -14 | xargs -r rm -rf
EOF
chmod 755 /usr/local/bin/$APP-backup
mkdir -p "$BACKUP"; chmod 700 "$BACKUP"

cat > /etc/systemd/system/$APP-backup.service <<EOF
[Unit]
Description=Säkerhetskopia av devigtunga.se

[Service]
Type=oneshot
ExecStart=/usr/local/bin/$APP-backup
EOF

cat > /etc/systemd/system/$APP-backup.timer <<EOF
[Unit]
Description=Nattlig säkerhetskopia av devigtunga.se

[Timer]
OnCalendar=*-*-* 03:15:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

steg "6/7 Startar allt"
systemctl daemon-reload
systemctl enable --now $APP-sync.timer $APP-backup.timer
systemctl start $APP-sync.service
systemctl enable caddy
systemctl reload caddy 2>/dev/null || systemctl restart caddy
/usr/local/bin/$APP-backup

steg "7/7 Kontrollerar"
sleep 2
kod="$(curl -s -o /dev/null -w '%{http_code}' "http://$IP4/")"
admin="$(curl -s -o /dev/null -w '%{http_code}' "http://$IP4/admin")"
dolt="$(curl -s -o /dev/null -w '%{http_code}' "http://$IP4/.git/config")"
echo "Startsidan: $kod (ska vara 200) · /admin: $admin (ska vara 200) · /.git: $dolt (ska vara 404)"

cat <<EOF

────────────────────────────────────────────────────────────
✅ KLART PÅ SERVERN

Testa nu i webbläsaren (innan DNS ändras):  http://$IP4
  – sajten och http://$IP4/admin ska synas (utan hänglås, det är normalt för testet)

DNS hos one.com för $DOMAN (ändra INTE MX/TXT – det är e-posten):
  Ta bort:  A    @    185.199.108.153 / 185.199.109.153 / 185.199.110.153 / 185.199.111.153  (GitHub)
  Ta bort:  AAAA @    2606:50c0:8000::153 … (GitHub, om de finns)
  Lägg in:  A    @    $IP4
EOF
[ -n "$IP6" ] && echo "  Lägg in:  AAAA @    $IP6"
cat <<EOF
  www:      CNAME www → $DOMAN   (byt ut stiggelindbom.github.io)

När DNS har slagit igenom (5–60 min) hämtar Caddy certifikatet själv – https://$DOMAN fungerar då.
Följ med:  journalctl -u caddy -f      (avsluta med Ctrl+C)
Säkerhetskopior:  $BACKUP
────────────────────────────────────────────────────────────
EOF
