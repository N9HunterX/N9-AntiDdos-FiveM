local fingerprints = {}

RegisterNetEvent('n9-antiddos:sendFingerprint')
AddEventHandler('n9-antiddos:sendFingerprint', function(fingerprintData)
    local src = source
    if fingerprintData and type(fingerprintData) == 'table' then
        fingerprints[src] = fingerprintData
        print(('[n9-antiddos] Received fingerprint from %d'):format(src))
    end
end)

function GetFingerprint(src)
    return fingerprints[src]
end

AddEventHandler('playerDropped', function(reason)
    local src = source
    fingerprints[src] = nil
end)
