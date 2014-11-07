-- Description: Testing without a test library --
-- Alt: I thought I understood (meta)tables --

local tester = {}
tester.passcount = 0
tester.failcount = 0

function tester:__call(success, text)
    text = (text ~= nil) and text or ''
    if success then
        self.passcount = self.passcount + 1
    else
        self.failcount = self.failcount + 1
        local info = debug.getinfo(2)
        print(string.format('[FAIL] %s  %s:%s', text, info.source, info.currentline))
    end
end

function tester:report()
    return string.format('Tester: %d passed, %d failed', self.passcount, self.failcount)
end

setmetatable(tester, tester)


-------------------------------------------------------------------------------


local base64 = require('22_base64')


-- Padding
tester(base64.encode('any carnal pleasure.') == 'YW55IGNhcm5hbCBwbGVhc3VyZS4=', 'Input has 20 bytes, output has 28 bytes (1 padding)')
tester(base64.encode('any carnal pleasure') == 'YW55IGNhcm5hbCBwbGVhc3VyZQ==', 'Input has 19 bytes, output has 28 bytes (2 padding)')
tester(base64.encode('any carnal pleasur') == 'YW55IGNhcm5hbCBwbGVhc3Vy', 'Input has 18 bytes, output has 24 bytes (no padding)')
tester(base64.encode('any carnal pleasu') == 'YW55IGNhcm5hbCBwbGVhc3U=', 'Input has 17 bytes, output has 24 bytes (1 padding)')
tester(base64.encode('any carnal pleas') == 'YW55IGNhcm5hbCBwbGVhcw==', 'Input has 16 bytes, output has 24 bytes (2 padding)') 

tester(base64.encode('pleasure.') == 'cGxlYXN1cmUu')
tester(base64.encode('leasure.') == 'bGVhc3VyZS4=')
tester(base64.encode('easure.') == 'ZWFzdXJlLg==')
tester(base64.encode('asure.') == 'YXN1cmUu')
tester(base64.encode('sure.') == 'c3VyZS4=')


-- Two way
tester(base64.decode(base64.encode('Hello')) == 'Hello', 'Encode/Decode test')
tester(base64.decode(base64.encode('Hello World')) == 'Hello World', 'Encode/Decode test')
tester(base64.decode(base64.encode('Hello World!')) == 'Hello World!', 'Encode/Decode test')
tester(base64.decode(base64.encode('Hello World!@')) == 'Hello World!@', 'Encode/Decode test')


-- Fuzz
math.randomseed(os.time())
for i=1, 20 do
    local length = math.random(1, 100)
    local s = ''
    for j=1, length do
        s = s .. string.char(math.random(0, 255))
    end
    
    tester(base64.decode(base64.encode(s)) == s, 'Fuzz test, length: ' .. length)
end


print(tester:report())

