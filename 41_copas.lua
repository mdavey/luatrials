-- so, this doesn't work on lua52 because of a luasocket bug (yeild, c boundry stuff)
-- luajit wants 5.1 libraries, but luarocks from os only cares about 52
-- probably should just remove all the os/platform packages and do it myself
--
-- ...
--
-- Or, just use luapower on my windows box  <_<

local copas = require("copas")
local asynchttp = require("copas.http").request

local list = {
  "http://www.google.com",
  "http://www.microsoft.com",
  "http://www.apple.com",
  "http://www.facebook.com",
  "http://www.yahoo.com",
}

local handler = function(host)
  res, err = asynchttp(host)
  print("Host done: "..host)
end

for _, host in ipairs(list) do copas.addthread(handler, host) end
copas.loop()
