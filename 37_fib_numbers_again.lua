-- Description: Fibonacci sequence again, this time without overflowing --

local BigNumber = require('36_big_numbers')

local function BigNumber_FibTable(table_size)
    local fibs = {
        BigNumber.new(0),
        BigNumber.new(1),
        BigNumber.new(1)}
    
    for i=4, table_size do
        fibs[i] = fibs[i-1] + fibs[i-2]
    end
    
    return fibs
end


for i,fib in ipairs(BigNumber_FibTable(100)) do
    print(i, fib)
end