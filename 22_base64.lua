-- Description: Base64 encoder (just for fun) --

--[[

TIL nil ~= ''

This shouldn't have taken over 2 hours to write.  God I suck.

So many little mistakes, off by one errors with padding

23 should be unit testing

]]


local function lookupchar(c)
    b = string.byte(c)
    if b >= string.byte('A') and b <= string.byte('Z') then return b - string.byte('A') + 0  end
    if b >= string.byte('a') and b <= string.byte('z') then return b - string.byte('a') + 26 end
    if b >= string.byte('0') and b <= string.byte('9') then return b - string.byte('0') + 52 end
    if c == '+' then return 62 end
    if c == '/' then return 63 end
    error('Character: ' .. c .. ' not valid')
end


local function lookupval(v)
    if v >= 0  and v <= 25 then return string.char(string.byte('A') + v - 0) end
    if v >= 26 and v <= 51 then return string.char(string.byte('a') + v - 26) end
    if v >= 52 and v <= 61 then return string.char(string.byte('0') + v - 52) end
    if v == 62 then return '+' end
    if v == 63 then return '/' end
    error('Value: ' .. v .. ' not in range (0-63)')
end


local function enctriple(s)
    if #s == 0 or #s > 3 then error('Expected 1-3 character string') end
        
    -- split 3 characters up, if a character is missing substitute 0
    local a = string.byte(s:sub(1, 1))
    local b = #s > 1 and string.byte(s:sub(2, 2)) or 0
    local c = #s > 2 and string.byte(s:sub(3, 3)) or 0
    
    -- make a 24 bit string
    local v = bit32.lshift(a, 16) + bit32.lshift(b, 8) + c

    -- encode the individual 6 bit values
    local e1 = lookupval(bit32.extract(v, 18, 6))
    local e2 = lookupval(bit32.extract(v, 12, 6))
    local e3 = lookupval(bit32.extract(v, 6, 6))
    local e4 = lookupval(bit32.extract(v, 0, 6))
    
    -- handle padding if required
    if #s == 3 then return e1 .. e2 .. e3  .. e4 end
    if #s == 2 then return e1 .. e2 .. e3  .. '=' end
    if #s == 1 then return e1 .. e2 .. '=' .. '=' end
end


local function decodequad(s)
    if #s ~= 4 then error('Must past 4 characters, Im too lazy to deal with no padding') end
    
    -- Split up into four characters.  Only look up the value if the 3rd and 4th aren't padding
    local a = lookupchar(s:sub(1, 1))
    local b = lookupchar(s:sub(2, 2))
    local c = s:sub(3, 3) ~= '=' and lookupchar(s:sub(3, 3)) or 0
    local d = s:sub(4, 4) ~= '=' and lookupchar(s:sub(4, 4)) or 0
    
    -- Make 24 bit string again
    local v = bit32.lshift(a, 18) + bit32.lshift(b, 12) + bit32.lshift(c,  6) + d

    -- Extra 3 8bit values and convert back to ascii
    local d1 = string.char(bit32.extract(v, 16, 8))
    local d2 = string.char(bit32.extract(v, 8,  8))
    local d3 = string.char(bit32.extract(v, 0,  8))
    
    -- Check for padding
    if s:sub(3, 3) == '=' then return d1 end
    if s:sub(4, 4) == '=' then return d1 .. d2 end
    
    return d1 .. d2 .. d3
end


local function encode(s)
    local result = ''
    for i=1, #s, 3 do
        result = result .. enctriple(s:sub(i, i+2))
    end
    return result
end


local function decode(s)
    local result = ''
    for i=1, #s, 4 do
        result = result .. decodequad(s:sub(i, i+3))
    end
    return result
end


-- Not sure which is cleaer

--[[
local M = {}
M.encode = encode
M.decode = decode

return M
]]

return {
    encode = encode,
    decode = decode
}