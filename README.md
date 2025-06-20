# N9 Anti-DDoS System for FiveM

**Version:** 1.0.0  
**Author:** ChatGPT (N9 Edition)

---

## 📌 Overview

The **N9 Anti-DDoS** system is a full-featured protection framework for FiveM servers, designed to automatically mitigate common attack vectors like:

- UDP flooding  
- Event spamming  
- VPN/proxy access  
- Country-based restrictions  
- Bandwidth overload  
- Fingerprinting evasion  
- ICMP and SYN floods

---

## 📁 Folder Structure

n9-antiddos/
├── fxmanifest.lua
├── config.lua
├── client/
│ └── main.lua
├── server/
│ ├── main.lua
│ ├── banlist.lua
│ ├── db.lua
│ ├── geoip.lua
│ ├── discord.lua
│ └── fingerprint.lua
└── README.md

---

## ⚙️ Features

- ✅ Real-time player fingerprinting  
- ✅ IP rate limiting via `iptables`  
- ✅ Event spam detection  
- ✅ Bandwidth usage monitor per player  
- ✅ Proxy/VPN detection via ProxyCheck.io  
- ✅ Country-based allowlist  
- ✅ Permanent + temporary ban logic  
- ✅ Logging to SQLite (optional)  
- ✅ Discord webhook alerts  
- ✅ Fail2Ban integration support  

---

## 🛠 Installation

1. **Place the resource in your server resources directory:**

   ```bash
   git clone https://github.com/yourname/n9-antiddos.git /home/fivem/resources/n9-antiddos

Or unzip the archive manually.

Edit your configuration:

Open config.lua and set:

Your ProxyCheck API key

Your Discord webhook URL

Country whitelist

Event list to monitor

Insert into your server.cfg:

🧠 Fail2Ban (optional)
To enable server-side IP banning with Fail2Ban:

Install Fail2Ban:

bash
sudo apt install fail2ban

Filter and jail configuration are included in install_n9_antiddos.sh.

🚨 Troubleshooting
If you're still being attacked, check:

UDP flood protection is applied in iptables

The resource is listed early in server.cfg

You are not using a weak or shared hosting provider

🔒 Recommended Kernel Tweaks

sysctl -w net.ipv4.tcp_syncookies=1
sysctl -w net.ipv4.tcp_max_syn_backlog=2048
sysctl -w net.ipv4.icmp_echo_ignore_all=1
📬 Support
Discord : https://discord.gg/7ChZ9NwU



