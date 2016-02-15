-- Description: Happy numbers, a Code Eval challange --

--[[
https://www.codeeval.com/open_challenges/39/

A happy number is defined by the following process. 
 - Starting with any positive integer
 - Replace the number by the sum of the squares of its digits
 - Repeat the process until the number equals 1 (where it will stay)
 - Or it loops endlessly in a cycle which does not include 1. 
 
 Those numbers for which this process ends in 1 are happy numbers, while those
 that do not end in 1 are unhappy numbers.
 ]]

local function split_num(n)
    -- split
    local t = {}
    repeat
        table.insert(t, n%10);
        n = math.floor(n / 10)
    until n <= 0
    
    -- reverse
    local r = {}
    for i=#t, 1, -1 do
        table.insert(r, t[i])
    end
    
    return r
end

local function sum_squares(n)
    local parts = split_num(n)
    local total = 0
    
    for _, v in ipairs(parts) do
        total = total + (v*v)
    end
    
    return total
end

local function is_happy(n)
    local history = {}

    while true do
        n = sum_squares(n)
        
        -- is happy
        if n == 1 then
            return true
        end
        
        -- if we've seen this value before, we are in a loop
        if history[n] then
            return false
        end
        
        history[n] = true
    end
end


--local tests = {7, 22}

--for _,n in ipairs(tests) do
--    print(n, is_happy(n))
--end

--for n=1, 100 do
--    print(n, is_happy(n))
--end


for line in io.lines(arg[1]) do
    if is_happy(line) then
        print('1\n')
    else
        print('0\n')
    end
end