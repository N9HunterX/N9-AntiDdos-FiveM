fx_version 'cerulean'
game 'gta5'

author 'N9 Development'
description 'Full-featured N9 Anti-DDoS with bandwidth enforcement, SQLite logging, geoIP, webhook, fail2ban'
version '5.0.0'

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- Optional if you use MySQL
    'config.lua',
    'server/banlist.lua',
    'server/db.lua',
    'server/geoip.lua',
    'server/discord.lua',
    'server/fingerprint.lua',
    'server/main.lua'
}
