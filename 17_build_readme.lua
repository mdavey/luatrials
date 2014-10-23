--Description: Attempt to auto update README.md with an index --


local wx = require("wx")

local header = [[
luatrials
=========

Personal record/diary of my trials learning Lua

Nothing interesting yet.  Perhaps one day.

Index
-----

Filename  | Description
--------- | -----------]]


local function getfilenames(dir, spec)
    dir = dir or '.'
    spec = spec or '*'
    
    -- nothing inbuilt to do directory access (!?)
    -- io.popen (and os.execute) opens a console window
    -- normal option is just to use posix or LuaFileSystem libraries
    -- But fuck it, wxLua it is
    
    local _,allfiles = wx.wxDir.GetAllFiles(dir, spec, wx.wxDIR_FILES)    
    return allfiles
end

local function commentdescription(filename)
    local f = io.open(filename, 'r')
    local top = f:read(256)
    f:close()
    
    --  %- = literal '-'
    --  %s = whitespace
    --  .  = anything
    --  .- = match anything zero or more times, not-gready (like .*?)
    local _,_,match = top:find('%-%-%s*Description:%s*(.-)%s*%-%-\n')
    
    -- could be nil if no match found
    return match
end

local function longest(t)
    local best = ''
    for _,v in ipairs(t) do
        if #v > #best then best = v end
    end
    return best
end

local luafiles = getfilenames('.', '*.lua')

--     -2 to account for the leading './',
-- and +2 for the brackets we'll add later
local filenamewidth = #longest(luafiles)

print(header)

for i,v in ipairs(luafiles) do
    local filename = v:sub(3)    
    local description = commentdescription(filename) or '(Blank)'
    -- doesn't look great
    -- local line = string.format('%2d.  %-' .. filenamewidth .. 's  %s', i, '[' .. filename .. ']', description)
    
    local line = string.format('[`%s`](%s)  |  %s', filename, filename, description)
    
    print(line)
end

