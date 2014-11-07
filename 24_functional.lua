-- Description: Functional Programming... No, I don't kow what this is   --

math.randomseed(os.time())


local function collect(f, count)
    local a = {}
    for i=1, count do 
        table.insert(a, f(i)) 
    end
    return a
end

local function map(a, f)
    local r = {}
    for _, v in pairs(a) do
        table.insert(r, f(v))
    end
    return r
end

local function each(a, f)
    for _, v in pairs(a) do
        f(v)
    end
end


-- string of 1 to 10
print(table.concat(collect(function(i) return i end, 10), '_'))


-- string of '#' marks of size 2, 3, and 5
print(table.concat(map({2, 3, 5}, function(i) return string.rep('#', i) end), '_'))


-- Print 20 strings, or random characters (A-Z) of random length
-- Now that I think about it, let's not continue...
each(collect(function() return table.concat(collect(function(i) return string.char(math.random(65, 65+26)) end, math.random(20, 40))) end, 20), function(i) print(i) end)

