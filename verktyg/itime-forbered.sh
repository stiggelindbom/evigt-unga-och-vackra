#!/usr/bin/env bash
# Förbereder och installerar iTime (tid.stigges.se) på nbm-1.
# Finns här bara för att Hetzners webbkonsol inte klarar tecken som : @ _ |
# – så räcker det att skriva:  curl -fsSLo t.sh raw.githubusercontent.com/stiggelindbom/evigt-unga-och-vackra/main/verktyg/itime-forbered.sh
#                              bash t.sh
# Inga lösenord eller nycklar i filen. Git frågar efter GitHub-token (klistras in av Stig).
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Kör som root."; exit 1; }

apt-get install -y -q git
git config --global credential.helper store

if [ ! -f /opt/itime/server/server.js ]; then
  rm -rf /opt/itime
  echo
  echo "GitHub frågar nu:  Username = stiggelindbom   Password = klistra in tokenet (syns inte)"
  git clone -b claude/sweet-cray-4pooik https://github.com/stiggelindbom/itime.git /opt/itime
fi

# Svaren på installationens frågor, så att den inte behöver fråga.
mkdir -p /etc/itime
touch /etc/itime/itime.env; chmod 600 /etc/itime/itime.env
grep -q '^ITIME_DOMAIN=' /etc/itime/itime.env || echo 'ITIME_DOMAIN=tid.stigges.se' >> /etc/itime/itime.env
grep -q '^ITIME_ADMIN_EMAIL=' /etc/itime/itime.env || echo 'ITIME_ADMIN_EMAIL=info@stigges.se' >> /etc/itime/itime.env

# Installationen frågar bara om Anthropic-nyckel: tryck Enter för att hoppa över.
bash /opt/itime/deploy/install.sh

echo
echo "==> Kontroller"
curl -s localhost:3020/health; echo
systemctl is-active itime-api caddy
ls /etc/caddy/sites
ip -6 addr show scope global | awk '/inet6/{print $2}'
