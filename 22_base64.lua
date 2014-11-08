-- Description: Base64 encoder (just for fun) --

--[[

TIL nil ~= ''

This shouldn't have taken over 2 hours to write.  God I suck.

So many little mistakes, off by one errors with padding

-- Lookup tables:  Surely faster, but didn't turn out to 
-- be that much simplier, readable or shorter

local a = {}
local b = {}
for i=0, 63 do
    table.insert(a, string.format('[%d]=\'%s\'', i, lookupval(i)))
    table.insert(b, string.format('[\'%s\']=%d', lookupval(i), i))
end
print('local lookupenc = {' .. table.concat(a, ', ') .. '}')
print('local lookupdec = {' .. table.concat(b, ', ') .. '}')


local lookupenc = {[0]='A',  [1]='B',  [2]='C',  [3]='D',  [4]='E',  [5]='F',  [6]='G',  [7]='H', 
                   [8]='I',  [9]='J',  [10]='K', [11]='L', [12]='M', [13]='N', [14]='O', [15]='P', 
                   [16]='Q', [17]='R', [18]='S', [19]='T', [20]='U', [21]='V', [22]='W', [23]='X', 
                   [24]='Y', [25]='Z', [26]='a', [27]='b', [28]='c', [29]='d', [30]='e', [31]='f', 
                   [32]='g', [33]='h', [34]='i', [35]='j', [36]='k', [37]='l', [38]='m', [39]='n', 
                   [40]='o', [41]='p', [42]='q', [43]='r', [44]='s', [45]='t', [46]='u', [47]='v', 
                   [48]='w', [49]='x', [50]='y', [51]='z', [52]='0', [53]='1', [54]='2', [55]='3', 
                   [56]='4', [57]='5', [58]='6', [59]='7', [60]='8', [61]='9', [62]='+', [63]='/'}
               
local lookupdec = {['A']=0,  ['B']=1,  ['C']=2,  ['D']=3,  ['E']=4,  ['F']=5,  ['G']=6,  ['H']=7, 
                   ['I']=8,  ['J']=9,  ['K']=10, ['L']=11, ['M']=12, ['N']=13, ['O']=14, ['P']=15, 
                   ['Q']=16, ['R']=17, ['S']=18, ['T']=19, ['U']=20, ['V']=21, ['W']=22, ['X']=23,
                   ['Y']=24, ['Z']=25, ['a']=26, ['b']=27, ['c']=28, ['d']=29, ['e']=30, ['f']=31, 
                   ['g']=32, ['h']=33, ['i']=34, ['j']=35, ['k']=36, ['l']=37, ['m']=38, ['n']=39, 
                   ['o']=40, ['p']=41, ['q']=42, ['r']=43, ['s']=44, ['t']=45, ['u']=46, ['v']=47, 
                   ['w']=48, ['x']=49, ['y']=50, ['z']=51, ['0']=52, ['1']=53, ['2']=54, ['3']=55, 
                   ['4']=56, ['5']=57, ['6']=58, ['7']=59, ['8']=60, ['9']=61, ['+']=62, ['/']=63}
]]


-- for encoding
local function lookupval(v)
    if v >= 0  and v <= 25 then return string.char(string.byte('A') + v - 0) end
    if v >= 26 and v <= 51 then return string.char(string.byte('a') + v - 26) end
    if v >= 52 and v <= 61 then return string.char(string.byte('0') + v - 52) end
    if v == 62 then return '+' end
    if v == 63 then return '/' end
    error('Value: ' .. v .. ' not in range (0-63)')
end


-- for decoding
local function lookupchar(c)
    b = string.byte(c)
    if b >= string.byte('A') and b <= string.byte('Z') then return b - string.byte('A') + 0  end
    if b >= string.byte('a') and b <= string.byte('z') then return b - string.byte('a') + 26 end
    if b >= string.byte('0') and b <= string.byte('9') then return b - string.byte('0') + 52 end
    if c == '+' then return 62 end
    if c == '/' then return 63 end
    error('Character: ' .. c .. ' not valid')
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


return {
    encode = encode,
    decode = decode
}