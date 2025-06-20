function LogToDiscord(title, desc)
    if not Config.Webhook or Config.Webhook == '' then return end
    PerformHttpRequest(Config.Webhook, function() end, 'POST', json.encode({
        username = 'N9 Anti-DDoS System',
        embeds = {{
            ['title'] = title,
            ['description'] = desc,
            ['color'] = 16711680,
            ['timestamp'] = os.date("!%Y-%m-%dT%TZ")
        }}
    }), { ['Content-Type'] = 'application/json' })
end

function LogBandwidth(ip, bytes)
    if bytes < (Config.BandwidthLogThresholdKB * 1024) then return end
    LogToDiscord("High Bandwidth Detected", string.format("**IP**: %s\n**Transferred**: %d KB/sec", ip, bytes / 1024))
end
