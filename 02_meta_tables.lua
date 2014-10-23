--Description: Intro to metatables --

Set = {}

function Set.new(t)
    local set = setmetatable({}, Set)
    if t ~= nil then
        for i,v in ipairs(t) do
            set[v] = true
        end
    end
    return set
end

function Set.union (a,b)
    local res = Set.new{}
    for k in pairs(a) do res[k] = true end
    for k in pairs(b) do res[k] = true end
    return res
end

function Set.intersection (a,b)
    local res = Set.new{}
    for k in pairs(a) do
        res[k] = b[k]
    end
    return res
end

function Set.__tostring (set)
    local s = "{"
    local sep = ""
    for e in pairs(set) do
        s = s .. sep .. e
        sep = ", "
    end
    return s .. "}"
end

Set.__index = Set
Set.__add   = Set.union
Set.__mul   = Set.intersection


-- I don't understand this line...
-- ...
-- Ahhh, set the metatable on the Set table (not the table returned by Set.new)
setmetatable(Set, { __call = function(self, ...) return self.new(...) end })



local s1 = Set.new({10, 20, 30, 40})
local s2 = Set.new({30, 40, 50})

print(s1)
print(s2)
print(Set.union(s1, s2))
print(s1 + s2)
print(s1:intersection(s2))

print(Set.new({1,2,3,4}))
print(Set({1,2,3,4}))




MySqlConnection = {}
MySqlConnection.__index = MySqlConnection
setmetatable(MySqlConnection, {__call = function(self, ...) return self.new(...) end})

MySqlConnection.new = function(server, user, password)
    return setmetatable({server=server, user=user, password=password}, MySqlConnection)
end

MySqlConnection.connect = function(self)
    print("Connecting to:", self)
end

MySqlConnection.__tostring = function(self)
    return string.format('server: %s, user: %s, password: %s', self['server'], self['user'], self['password'])
end


local conn = MySqlConnection('db1', 'root', 'password')
conn:connect()
print(conn)

