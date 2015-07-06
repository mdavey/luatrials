

--[[
Given numbers x and n, where n is a power of 2, print out the smallest multiple
of n which is greater than or equal to x. Do not use division or modulo 
operator.
]]

local function solve(x, n)
    local v = n
    while true do
        if v >= x then
            return v
        end        
        v = v + n
    end
end

for line in io.lines(arg[1]) do
    local x, n = string.match(line, '^(%d+),(%d+)$')
    print(solve(tonumber(x), tonumber(n)))
end
