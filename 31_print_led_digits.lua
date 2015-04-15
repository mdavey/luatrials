-- Description: print numbers in an ASCII art LED style --

--[[
./led 1234567890
   _  _       _   _  _    _   _   _
|  _| _| |_| |_  |_   |  |_| |_| | |
| |_  _|   |  _| |_|  |  |_|  _| |_|
]]

-- https://github.com/Yonaba/Moses/blob/master/doc/tutorial.md#utility

--[[
local _ = require('moses')

local function leddigits2(numbers)
    return _({'', '', ''}):map(function(linenum, line)     
        return _(numbers):map(function(j, number)
            return digits[number][linenum]
        end):concat(' '):value()
    end):concat('\n'):value()
end
]]


local digits = {
    [0] = {' _ ', '| |', '|_|'},        
    [1] = {' ', '|', '|'},
    [2] = {' _ ', ' _|', '|_ '},
    [3] = {'_ ', '_|', '_|'},
    [4] = {'   ', '|_|', '  |'},
    [5] = {' _ ', '|_ ', ' _|'},
    [6] = {' _ ', '|_ ', '|_|'},
    [7] = {'_ ', ' |', ' |'},
    [8] = {' _ ', '|_|', '|_|'},
    [9] = {' _ ', '|_|', ' _|'},
}

local function leddigits(numbers)
    local lines = {'', '' ,''}
    for i=1, 3 do
        for _, num in ipairs(numbers) do
            lines[i] = lines[i] .. digits[num][i] .. ' '
        end
    end
    return table.concat(lines, '\n')
end

if arg[1] == nil then
    print('Usage: lua ' .. arg[0]:match('[\\/]([^\\/]+%.lua)') .. ' numbers')
else
    local numbers = {}
    for num in arg[1]:gmatch('(%d)') do
        table.insert(numbers, tonumber(num))
    end
    print(leddigits(numbers))
end




