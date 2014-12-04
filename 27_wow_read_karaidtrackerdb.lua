-- Description: Read saved variables for WoW addon RaidTracker --

local WowSavedVariables = require('26_wow_load_savedvars')


local isodatestr = function(unixtime)
    return os.date('%Y-%m-%d %H:%I:%S', unixtime)
end


local function playersinraid(raid)
    local players = {}
    
    for _,v in ipairs(raid['Join']) do
        players[v['player']] = {join = v['time']}
    end
    
    for _,v in ipairs(raid['Leave']) do
        players[v['player']]['leave'] = v['time']
    end
    
    for player,details in pairs(players) do
        print(player, 'Join: ' .. isodatestr(details['join']), 'Leave:' .. isodatestr(details['leave']))
    end
end


local function lootinraid(raid)
    for _,v in ipairs(raid['Loot']) do
        print(v['player'], 'looted', v['item']['name'], 'at', isodatestr(v['time']), 'from', v['boss'])
    end
end


local function raidinfo(raid)
    print('Realm', raid['realm'])
    print('Start', isodatestr(raid['key']))
    print('End', isodatestr(raid['End']))
end


local filename  = [[C:\World of Warcraft\WTF\Account\ACCOUNT\SavedVariables\RaidTracker.lua]]
local rtdata = WowSavedVariables.load(filename)

for _,v in pairs(rtdata['KARaidTrackerDB']['Log']) do
    raidinfo(v)
    playersinraid(v)
    lootinraid(v)
    print()
end