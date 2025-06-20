Config = {}

Config.MaxConnectionsPerSecond = 10
Config.MaxEventTriggersPerSecond = 5
Config.TempBlockDuration = 600 -- seconds
Config.PermanentThreshold = 3
Config.DynamicScaling = true
Config.ActivePlayerFactor = 0.2

Config.BandwidthLimitPerSecondKB = 75
Config.BandwidthLogThresholdKB = 50
Config.BandwidthProtectionEnabled = true

Config.BlockVPNs = true
Config.AllowedCountries = { 'VN', 'US', 'CA', 'GB' }
Config.ProxyCheckAPI = 'YOUR_PROXYCHECK_API_KEY'

Config.Webhook = 'https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE'

Config.ProtectedEvents = {
    'qb-menu:client:openMenu',
    'qb-inventory:server:OpenInventory',
    'qb-phone:server:sendNewMessage',
    'player:receiveItem',
    'server:giveMoney'
}

Config.LogToDatabase = true
