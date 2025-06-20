local sqlite3 = require "sqlite3"

local dbPath = GetResourcePath(GetCurrentResourceName()) .. '/data/banlog.db'
local db = sqlite3.open(dbPath)

db:exec([[
CREATE TABLE IF NOT EXISTS bans (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ip TEXT NOT NULL,
    reason TEXT NOT NULL,
    time INTEGER NOT NULL,
    permanent INTEGER NOT NULL
);
]])

function LogBanToDB(ip, reason, permanent)
    local stmt = db:prepare("INSERT INTO bans (ip, reason, time, permanent) VALUES (?, ?, ?, ?)")
    stmt:bind_values(ip, reason, os.time(), permanent and 1 or 0)
    stmt:step()
    stmt:finalize()
end

function GetBansFromDB()
    local bans = {}
    for row in db:nrows("SELECT ip, reason, time, permanent FROM bans") do
        bans[row.ip] = {
            reason = row.reason,
            time = row.time,
            permanent = row.permanent == 1
        }
    end
    return bans
end
