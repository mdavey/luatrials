-- Description: Wrapping lustache around html files --

local lustache = require('lustache')
local lfs = require('lfs')


--[[
Every .html file in specified directory is loaded as a partial
Even when rendering a template we pick it out of the partials table

It feels really hacking, but I think it will work well for me as a static
html generator
]]

local templates = {}

function templates.new(dir)
    local t = setmetatable({dir=dir, partials={}}, {__index = templates})
    t:refresh()
    return t
end

function templates._readfile(filename)
    local f = io.open(filename, 'r')
    if f == nil then error('Unable to open file' .. filename) end
    local data = f:read('*a')
    f:close()
    return data
end

function templates:refresh()
    for filename in lfs.dir(self.dir) do
        if filename:sub(-5) == '.html' then
            local basename = filename:sub(1, -6)
            print('loading', filename, 'as', basename)
            self.partials[basename] = self._readfile(self.dir ..'/' .. filename)
        end
    end
end

function templates:render(name, data)
    return lustache:render(self.partials[name], data, self.partials)
end


--[[ 
This seems to make a calling the libary nice and simple.  e.g.

 > local templates = require('28_templates')
 > 
 > local t = templates('28_templates')
 > print(t:render('hello', {name = 'World', page_title = 'Templating'}))

Though is there any difference to just returning template and calling .new() ?

 > local templates = require('28_templates')
 > 
 > local t = templates.new('28_templates')
]]

return setmetatable({}, {__call = function(self, ...) return templates.new(...) end})
