--Description: Attempt to auto update README.md with an index --

local lfs = require('lfs')


local header = [[
luatrials
=========

Personal record/diary of my trials learning Lua

Nothing interesting yet.  Perhaps one day.

Index
-----

Filename  | Description
--------- | -----------]]


local function getfilenames(dir, ext)
    dir = dir or '.'
    ext = ext or '.lua'

    local filenames = {}

    for filename in lfs.dir(dir) do
        if filename:sub(-#ext) == ext then
            table.insert(filenames, filename)
        end
    end
    
    table.sort(filenames)
    
    return filenames
end

local function commentdescription(filename)
    local f = io.open(filename, 'r')
    
    if f == nil then 
        error('Unable to open file for reading: ' .. filename) 
    end
    
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

local luafiles = getfilenames('.', '.lua')

-- and +2 for the brackets we'll add later
local filenamewidth = #longest(luafiles) + 2

print(header)

for _,filename in ipairs(luafiles) do  
    local description = commentdescription(filename) or '(Blank)'
    local line = string.format('[`%s`](%s)  |  %s', filename, filename, description)
    print(line)
end

