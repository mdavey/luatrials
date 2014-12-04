-- Description: Read an WoW addon's saved variables data file --


--[[

Example:

local filename  = 'RaidTracker.lua'
local sv = loadsavedvariables(filename)

for k,v in pairs(sv['KARaidTrackerDB']) do
    print(k, v)
end

]]

local readfile = function(filename)
    local f = io.open(filename, 'r')
    if f == nil then error('unable to open file') end
    local data = f:read('*a')
    f:close()
    return data
end

local loadsavedvariables = function(filename)
    local data = readfile(filename)
    local env  = {}
    local fun  = load(data, data,  't', env)
    fun()
    return env
end

return {load = loadsavedvariables}

