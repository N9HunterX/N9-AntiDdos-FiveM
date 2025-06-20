local function getCountry(ip)
    local country = nil
    local url = ('https://ipapi.co/%s/json/'):format(ip)
    PerformHttpRequest(url, function(status, body)
        if status == 200 then
            local data = json.decode(body)
            if data and data.country then
                country = data.country
            end
        end
    end, 'GET')
    local start = os.time()
    while country == nil and os.time() - start < 5 do
        Citizen.Wait(100)
    end
    return country
end

function IsAllowedCountry(ip)
    if not Config.AllowedCountries or #Config.AllowedCountries == 0 then return true end
    local country = getCountry(ip)
    if not country then return false end
    for _, c in ipairs(Config.AllowedCountries) do
        if c == country then return true end
    end
    return false
end

function IsProxyIP(ip)
    if not Config.BlockVPNs then return false end
    local isProxy = false
    local url = ('https://proxycheck.io/v2/%s?vpn=1&key=%s'):format(ip, Config.ProxyCheckAPI)
    PerformHttpRequest(url, function(status, body)
        if status == 200 then
            local data = json.decode(body)
            if data[ip] and data[ip].proxy == 'yes' then
                isProxy = true
            end
        end
    end, 'GET')
    local start = os.time()
    while not isProxy and os.time() - start < 5 do
        Citizen.Wait(100)
    end
    return isProxy
end
