-- Description: Testing static html generator for GL KT RaidTracker --

local WowSavedVariables = require('26_wow_load_savedvars')
local Templates = require('28_templates')


-- only us right now.  I really hope the format isn't based in my locale
local strtodate = function(str)
    local m,d,y,h,i,s = str:match("(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)")
    return os.time({year='20' .. y, month=m, day=d, hour=h, min=i, sec=s})
end


-- iso is the only sane format
local datetostr = function(unixtime)
    return os.date('%Y-%m-%d %H:%I:%S', unixtime)
end


local getzones = function(raid)
    local zones = {}
    for _,lootdrop in ipairs(raid['Loot']) do
        zones[lootdrop['zone']] = true
    end
    
    local zonenames = {}
    for zonename,_ in pairs(zones) do
        table.insert(zonenames, zonename)
    end
    
    return zonenames
end


local getplayers = function(raid)
    local players = {}
    for playername,_ in pairs(raid['PlayerInfos']) do
        table.insert(players, playername)
    end
    return players
end


local formattedtimediff = function(t1, t2)   
    local seconds = os.difftime(t1, t2)    
    
    if seconds < 60 then return seconds .. ' seconds' end
    if seconds < 60 * 60 then return math.floor(seconds/60) .. ' minutes' end    
    return math.floor(seconds/(60*60)) .. ' hours'

end


local getgeneralraidinfo = function(raid)
    -- Raiding ending missing.  Because I was still in a raid as quit the game.
    if raid['End'] == nil then
        raid['End'] = raid['key']
    end
    
    return {
        key        = strtodate(raid['key']),
        timestart  = datetostr(strtodate(raid['key'])),
        timeend    = datetostr(strtodate(raid['End'])),
        timelength = formattedtimediff(strtodate(raid['End']), strtodate(raid['key'])),
        numplayers = #getplayers(raid),
        zones      = #getzones(raid) > 0 and table.concat(getzones(raid), ', ') or '(Unknown)'
    }
end


local buildpage_index = function(title, raids)
    local data = {title=title, raids = {}}
    
    for _,raid in ipairs(raids) do
        table.insert(data.raids, getgeneralraidinfo(raid))
    end
    
    return data
end


local buildpage_raid = function(title, raid)
    local data = {
        title = title, 
        raid  = getgeneralraidinfo(raid)
    }
    
    -- loop through players
    -- how long they were in the raid for
    -- what bosses they killed
    -- what loot they got
    
    return data;
end


local settings   = WowSavedVariables.load('.29_settings.lua')
local glctrtdata = WowSavedVariables.load(settings['SavedVariablesDirectory'])

local templates = Templates('29_templates')


templates:rendertofile('index', buildpage_index('All Raids', glctrtdata['CT_RaidTracker_RaidLog']), '29_static/index.html')

for _,raid in pairs(glctrtdata['CT_RaidTracker_RaidLog']) do
    local data = buildpage_raid('Raid Details', raid)
    templates:rendertofile('raid', data , '29_static/raid_' .. data.raid.key .. '.html')
end

-- todo
-- finally make a player page, that contains:
-- all the raids the player has been in
-- all the loot they've gotten