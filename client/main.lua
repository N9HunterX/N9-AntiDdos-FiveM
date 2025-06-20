Citizen.CreateThread(function()
    local fingerprintData = {
        license = GetPlayerIdentifier(PlayerId(), 0),
        steam = GetPlayerIdentifier(PlayerId(), 1),
        ip = GetPlayerEndpoint(PlayerId()),
        hwid = GetGameTimer() .. tostring(math.random(1000,9999)) -- ví dụ giả định
    }

    TriggerServerEvent('n9-antiddos:sendFingerprint', fingerprintData)
end)
