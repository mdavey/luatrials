-- Description: Another look at metatables, in particular __index --


-- table -> string
local function dumptable(t)
    local buf = {}
    for i,v in ipairs(t) do
        table.insert(buf, i .. ':' .. v)
    end
    return table.concat(buf, '_')
end


-- Base line
local t = {10, 20, 30}

assert(dumptable(t) == dumptable({10, 20, 30}))


-- Can ipairs() itterate over a table with a __index set to another table
local t1 = {10, 20, 30}
local t2 = {}

setmetatable(t2, {__index = t1})

-- they are different
assert(dumptable(t1) ~= dumptable(t2))

-- but in some ways the same
assert(t1[1] == t2[1] and t1[2] == t2[2] and t1[3] == t2[3])

-- that's because __index actually maintains the what's been added
-- and because nothing was added after we set the metatable on t2
-- it has no information

table.insert(t2, 40)
table.insert(t2, 50)
table.insert(t2, 60)

assert(dumptable(t2) == dumptable({40, 50, 60}))

table.insert(t1, 100)
table.insert(t1, 200)
table.insert(t1, 300)

assert(dumptable(t1) == dumptable({10, 20, 30, 100, 200, 300}))

-- And now t2[1] == 40,  t2[2] == 50,  t2[3] == 60
-- but     t2[4] == 100, t2[5] == 200, t2[6] == 300


-- I think I'm getting the hand of this
