#!/usr/bin/env bash
# Förbereder och installerar iTime (tid.stigges.se) på nbm-1.
# Finns här för att Hetzners webbkonsol inte klarar tecken som : @ _ | (därför går
# inte heller ett GitHub-token att klistra in). I stället används en läsnyckel
# (deploy key) som servern skapar själv och som bara ger läsrätt till repot itime.
#   curl -fsSLo t.sh raw.githubusercontent.com/stiggelindbom/evigt-unga-och-vackra/main/verktyg/itime-forbered.sh
#   bash t.sh      (första gången: visar nyckeln som ska läggas in på GitHub)
#   bash t.sh      (andra gången: hämtar iTime och installerar)
# Inga lösenord eller hemliga nycklar i filen – den privata nyckeln stannar på servern.
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Kör som root."; exit 1; }

apt-get install -y -q git openssh-client >/dev/null

K=/root/.ssh/itime_deploy
mkdir -p /root/.ssh; chmod 700 /root/.ssh
[ -f "$K" ] || ssh-keygen -q -t ed25519 -N "" -C "nbm-1 itime" -f "$K"

# GitHubs publicerade värdnyckel (https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints)
grep -q "^github.com ssh-ed25519" /root/.ssh/known_hosts 2>/dev/null || \
  echo "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl" >> /root/.ssh/known_hosts

if ! grep -q "^Host github-itime" /root/.ssh/config 2>/dev/null; then
  cat >> /root/.ssh/config <<EOF

Host github-itime
  HostName github.com
  User git
  IdentityFile $K
  IdentitiesOnly yes
EOF
fi
chmod 600 /root/.ssh/config

if ! ssh -T github-itime 2>&1 | grep -q "successfully authenticated"; then
  echo
  echo "================ LÄGG IN DEN HÄR NYCKELN PÅ GITHUB ================"
  echo "github.com/stiggelindbom/itime -> Settings -> Deploy keys -> Add deploy key"
  echo "Title: nbm-1   (kryssa INTE i Allow write access)"
  echo
  cat "$K.pub"
  echo
  echo "Bitar om 8 tecken (för avläsning):"
  awk '{print $2}' "$K.pub" | fold -w 8 | nl -w2 -s'  '
  echo
  echo "Fingeravtryck (ska stå samma på GitHub efteråt):"
  ssh-keygen -lf "$K.pub"
  echo "==================================================================="
  # Visa den publika nyckeln (inte hemlig) på en tillfällig adress, så att den kan kopieras exakt.
  if [ -d /etc/caddy/sites ]; then
    IP4="$(ip -4 route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}')"
    cat > /etc/caddy/sites/itime-nyckel.caddy <<EOF
http://nyckel.${IP4//./-}.nip.io {
	respond "$(cat "$K.pub")"
}
EOF
    systemctl reload caddy && echo "Nyckeln visas också på:  http://nyckel.${IP4//./-}.nip.io"
  fi
  echo "Kör sedan:  bash t.sh  igen."
  exit 0
fi
echo "Läsnyckeln fungerar mot GitHub."
if [ -f /etc/caddy/sites/itime-nyckel.caddy ]; then rm -f /etc/caddy/sites/itime-nyckel.caddy; systemctl reload caddy; fi

if [ ! -f /opt/itime/server/server.js ]; then
  rm -rf /opt/itime
  git clone -b claude/sweet-cray-4pooik ssh://github-itime/stiggelindbom/itime.git /opt/itime
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
