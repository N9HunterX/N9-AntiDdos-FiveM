#!/bin/bash

FIVEM_DIR="/home/fivem"
ANTIDDOS_DIR="$FIVEM_DIR/resources/antiddos"
SERVER_CFG="$FIVEM_DIR/server.cfg"
LOG_FILE="/var/log/fivem-antiddos.log"
FIVEM_PORT=30120
FIVEM_USER="fivem"       # Change to the user running FiveM
FIVEM_GROUP="fivem"      # Change to the group running FiveM

echo "[1/8] Creating Anti-DDoS directory"
mkdir -p "$ANTIDDOS_DIR"

echo "[2/8] Creating log file and setting permissions"
touch "$LOG_FILE"
chown $FIVEM_USER:$FIVEM_GROUP "$LOG_FILE"
chmod 644 "$LOG_FILE"

echo "[3/8] Installing iptables DDoS protection rules"
iptables -F
iptables -A INPUT -p udp --dport $FIVEM_PORT -m connlimit --connlimit-above 20 -j DROP
iptables -A INPUT -p udp --dport $FIVEM_PORT -m hashlimit --hashlimit-above 10/sec --hashlimit-burst 20 --hashlimit-mode srcip --hashlimit-name ddos --hashlimit-htable-expire 10000 -j ACCEPT
iptables -A INPUT -p udp --dport $FIVEM_PORT -j DROP
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
iptables -A INPUT -f -j DROP
iptables -A INPUT -p tcp --syn -m limit --limit 2/s --limit-burst 4 -j ACCEPT
iptables -A INPUT -p tcp --syn -j DROP

if command -v netfilter-persistent >/dev/null 2>&1; then
  netfilter-persistent save
fi

echo "[4/8] Configuring sysctl hardening"
sysctl -w net.ipv4.tcp_syncookies=1
sysctl -w net.ipv4.icmp_echo_ignore_all=1
sysctl -w net.ipv4.tcp_max_syn_backlog=2048

echo "[5/8] Creating Fail2Ban filter and jail files"

cat > /etc/fail2ban/filter.d/fivem-ddos.conf << 'EOF'
[Definition]
failregex = \[Anti-DDoS System\] Blocked Connection: <HOST>
            \[Anti-DDoS System\] Bandwidth Abuse: <HOST>
            \[Anti-DDoS System\] Event Spam Block: <HOST>
            \[Anti-DDoS System\] VPN Block: <HOST>
            \[Anti-DDoS System\] Country Block: <HOST>
ignoreregex =
EOF

cat > /etc/fail2ban/jail.d/fivem-ddos.local << EOF
[fivem-ddos]
enabled = true
filter = fivem-ddos
logpath = $LOG_FILE
maxretry = 3
findtime = 600
bantime = 3600
action = iptables[name=FiveM-DDOS, port=$FIVEM_PORT, protocol=udp]
EOF

echo "[6/8] Downloading Anti-DDoS resource (you must copy the Lua source code into $ANTIDDOS_DIR manually)"

# You can use git clone or copy Lua source code into the antiddos directory here

echo "[7/8] Adding 'ensure antiddos' to server.cfg if not already present"
if ! grep -q "ensure antiddos" "$SERVER_CFG"; then
  echo "ensure antiddos" >> "$SERVER_CFG"
  echo "'ensure antiddos' has been added to $SERVER_CFG"
else
  echo "'ensure antiddos' already exists in $SERVER_CFG"
fi

echo "[8/8] Restarting Fail2Ban"
systemctl restart fail2ban

echo "[✅] Anti-DDoS installation complete! Please configure the webhook and API key in the resource's config.lua."
