--[[

https://projecteuler.net/problem=17

If the numbers 1 to 5 are written out in words: one, two, three, four, five, 
then there are 3 + 3 + 5 + 4 + 4 = 19 letters used in total.

If all the numbers from 1 to 1000 (one thousand) inclusive were written out 
in words, how many letters would be used?

--------------------------------

Bad spelling made this so much harder than it needed to be

]]


require('strict')


-- Ugh, this is awful.  Naming is hard.
local function numtostr(num)
    
    local onesstr = {
        'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 
        'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen',
        'seventeen', 'eighteen', 'nineteen'
    }
    
    local tensstr = {
        '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'
    }
    
    -- valid range
    if num < 1 or num > 1000 then error('range 1-1000') end
    
    -- special case
    if num == 1000 then return 'one thousand' end
        
    -- 1-999
    local hundreds = math.floor(num/100)
    local tens     = math.floor((num - hundreds * 100)/10)
    local ones     = num - (hundreds * 100) - (tens * 10)
    local str      = {}
    
    -- print('num', num, 'hundreads', hundreads, 'tens', tens, 'ones', ones)
    
    if hundreds > 0 then
        table.insert(str, onesstr[hundreds] .. ' hundred')
        
        if tens ~= 0 or ones ~= 0 then
            table.insert(str, 'and')
        end
    end
    
    if tens == 1 then
        table.insert(str, onesstr[tens + ones + 9])
    else
        if tens > 1 then
            table.insert(str, tensstr[tens])
        end
        
        if ones > 0 then
            table.insert(str, onesstr[ones])
        end
    end
    
    return table.concat(str, ' ')    
end


-- remove spaces
local removespace = function(str)
    return str:gsub(' ', '')
end


-- the actual problem
local problem17 = function(num)
    local count = 0
    
    for i=1, num do
        -- print(numtostr(i))
        count = count + #removespace(numtostr(i))
    end
    
    return count
end


-- cannot work out luaunit (or what version of luaunit I even have)
local assertEquals = function(v1, v2)
    if v1 ~= v2 then
        if v1 == nil then v1 = '(nil)' end
        if v2 == nil then v2 = '(nil)' end
        error(string.format('got: %s  Expected: %s', v1, v2))
        return false
    end
    
    return true
end


-- testing yay
local test_numtostr = function()
    assertEquals(numtostr(1), 'one')
    assertEquals(numtostr(2), 'two')
    assertEquals(numtostr(9), 'nine')
    assertEquals(numtostr(9), 'nine')
    assertEquals(numtostr(14), 'fourteen')
    assertEquals(numtostr(19), 'nineteen')
    assertEquals(numtostr(20), 'twenty')
    assertEquals(numtostr(21), 'twenty one')
    assertEquals(numtostr(29), 'twenty nine')
    assertEquals(numtostr(55), 'fifty five')
    assertEquals(numtostr(99), 'ninety nine')
    assertEquals(numtostr(100), 'one hundred')
    assertEquals(numtostr(400), 'four hundred')
    assertEquals(numtostr(501), 'five hundred and one')
    assertEquals(numtostr(618), 'six hundred and eighteen')
    assertEquals(numtostr(777), 'seven hundred and seventy seven')
    assertEquals(numtostr(1000), 'one thousand')
end

local test_removespaces = function()
    assertEquals(#removespace(numtostr(342)), 23) 
    assertEquals(#removespace(numtostr(115)), 20)
end

local test_problem17 = function()
    assertEquals(problem17(5), 19)
    assertEquals(problem17(9), 36)    
end

test_numtostr()
test_removespaces()
test_problem17()


print('Problem 17:', problem17(1000))