-- Description: socketloop async http tests for a new project --

-- so, let's try something different (and it's not because I'm too lazy to 
-- download Copos manually)
--
-- Error will be interesting, and why doesn't settimeout work?


local loop = require('socketloop')
local http = require('socket.http')
local ltn12 = require('ltn12')

local function savepage(url, filename)
    local f = assert(io.open(filename, 'wb+'), 'opening filename ' .. filename)
    local ok, code, headers = http.request({
        url = url,
        sink = ltn12.sink.file(f),
        create = function()
            
            local s = socket.try(socket.tcp())
            
            -- this doesn't do anything?
            s:settimeout(0, 't')
            
            return loop.wrap(s)
        end})

    -- host not found returns:  nil, {'host or service not...'}
    -- why is it a table?  docs says it's a string
    assert(ok, code)
end

local function getpage(url)
   local t = {}
   local ok, code, headers = http.request{
      url = url,
      sink = ltn12.sink.table(t),
      create = function()
         return loop.wrap(socket.try(socket.tcp()))
      end,
   }
   assert(ok, code)
   return table.concat(t), headers, code
end

local list = {
    '1455519684103.jpg',
    '1455519699883.jpg',
    '1455520137134.png',
    '1455520901982.jpg',
    '1455520942816.jpg',
    '1455525346410.jpg',
    '1455527579624.jpg',
    '1455528762548.jpg',
    '1455530097702.jpg',
    '1455534918933.jpg',
    '1455538692243.jpg'
}

for i, filename in ipairs(list) do
    local url = 'https://i.4cdn.org/a/' .. filename
    loop.newthread(function()
        savepage(url, filename)
        print('done ' .. url)
    end)
end

loop.start()