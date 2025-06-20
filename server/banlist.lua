local banned = GetBansFromDB() or {}

function SaveBans()
    -- Currently bans persist only in DB, extend if needed
end

function AddBan(ip, reason, permanent)
    banned[ip] = {
        reason = reason,
        time = os.time(),
        permanent = permanent or false
    }
    LogBanToDB(ip, reason, permanent)
end

function IsBanned(ip)
    return banned[ip]
end
