local banned = GetBansFromDB()
local requestCounts, eventCounts, blockHistory, trafficStats = {}, {}, {}, {}

local function getIP(src)
    return GetPlayerEndpoint(src) or 'unknown'
end

local function getThreshold(base)
    return base + (#GetPlayers() * Config.ActivePlayerFactor)
end

CreateThread(function()
    while true do
        Wait(1000)
        for ip, stats in pairs(trafficStats) do
            if Config.BandwidthProtectionEnabled and stats.bytes > (Config.BandwidthLimitPerSecondKB * 1024) then
                blockHistory[ip] = (blockHistory[ip] or 0) + 1
                local perm = blockHistory[ip] >= Config.PermanentThreshold
                AddBan(ip, "Bandwidth abuse", perm)
                LogToDiscord("Bandwidth Abuse", ip .. " exceeded byte threshold.")
                LogToFail2Ban(ip, "Bandwidth Abuse")
            elseif stats.bytes > (Config.BandwidthLogThresholdKB * 1024) then
                LogBandwidth(ip, stats.bytes)
            end
        end
        trafficStats, requestCounts, eventCounts = {}, {}, {}
    end
end)

CreateThread(function()
    while true do
        Wait(10000)
        local now = os.time()
        local changed = false
        for ip, data in pairs(banned) do
            if not data.permanent and (now - data.time > Config.TempBlockDuration) then
                banned[ip] = nil
                changed = true
                LogToDiscord('IP Unblocked', ip .. ' unblocked')
            end
        end
        if changed then SaveBans() end
    end
end)

AddEventHandler('playerConnecting', function(_, setKickReason)
    local src, ip = source, getIP(source)
    local banData = IsBanned(ip)
    if banData then
        setKickReason(banData.permanent and 'Permanently banned' or 'Temporarily blocked')
        CancelEvent()
        return
    end
    if not IsAllowedCountry(ip) then
        setKickReason('Your country is blocked')
        CancelEvent()
        LogToDiscord('Country Block', ip)
        LogToFail2Ban(ip, "Country Block")
        return
    end
    if IsProxyIP(ip) then
        setKickReason('VPN/Proxy usage not allowed')
        CancelEvent()
        LogToDiscord('VPN Block', ip)
        LogToFail2Ban(ip, "VPN Block")
        return
    end

    local limit = Config.DynamicScaling and getThreshold(Config.MaxConnectionsPerSecond) or Config.MaxConnectionsPerSecond
    requestCounts[ip] = (requestCounts[ip] or 0) + 1
    if requestCounts[ip] > limit then
        blockHistory[ip] = (blockHistory[ip] or 0) + 1
        local perm = blockHistory[ip] >= Config.PermanentThreshold
        AddBan(ip, perm and "Permanent DDoS ban" or "Temporary DDoS block", perm)
        setKickReason(perm and 'Permanent DDoS ban' or 'DDoS blocked')
        CancelEvent()
        LogToDiscord('Blocked Connection', ip .. (perm and ' permanently' or ' temporarily'))
        LogToFail2Ban(ip, "Blocked Connection")
    end
end)

for _, event in pairs(Config.ProtectedEvents) do
    RegisterServerEvent(event)
    AddEventHandler(event, function(...)
        local src, ip = source, getIP(source)
        local key = ip .. ':' .. event
        local limit = Config.DynamicScaling and getThreshold(Config.MaxEventTriggersPerSecond) or Config.MaxEventTriggersPerSecond
        eventCounts[key] = (eventCounts[key] or 0) + 1

        local payload = json.encode({...})
        trafficStats[ip] = trafficStats[ip] or { bytes = 0 }
        trafficStats[ip].bytes = trafficStats[ip].bytes + #payload + #event

        if eventCounts[key] > limit then
            blockHistory[ip] = (blockHistory[ip] or 0) + 1
            local perm = blockHistory[ip] >= Config.PermanentThreshold
            AddBan(ip, "Event spam detected: " .. event, perm)
            DropPlayer(src, perm and 'Permanently banned for spam' or 'Event spam detected')
            LogToDiscord('Event Spam Block', ip .. ' - ' .. event)
            LogToFail2Ban(ip, "Event Spam Block")
        end
    end)
end

-- LogToFail2Ban function for writing log file for Fail2Ban

function LogToFail2Ban(ip, reason)
    local logFile = '/var/log/n9-antiddos.log'
    local f = io.open(logFile, "a")
    if f then
        f:write(os.date("%Y-%m-%d %H:%M:%S") .. " [N9 Anti-DDoS System] " .. reason .. ": " .. ip .. "\n")
        f:close()
    else
        print("Failed to open log file: " .. logFile)
    end
end
