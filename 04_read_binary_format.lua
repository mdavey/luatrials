--[[

This is an attempt to re-write my Crimsonland data file pythong script in lua.
I avoided 3rd party librarys (like lpack and vstruct) to try and get a feel
better for the standard library.

The bytes construct doesn't seem very nice at all.

Bytes(string) == Bytes({20,30,40})

Was important, but maybe they should have been seperated out like:

Bytes.fromstring(string) == Bytes.fromtable({1,2,3})


Bytes(file:read(4)):toint32()  is pretty ugly too


Perhaps I went the wrong way and should have made a new file access object?


bf = BinaryFile(io.open(filename, 'rb'))
bf.readint32()
bf.readnulstring()
bf.read(16)

]]


-- Ugh
Bytes = setmetatable({}, { __call = function(self, ...) return self.new(...) end })
Bytes.__index = Bytes

Bytes.new = function(data)
    local bytes = { data={}, length=0 }

    if data.len ~= nil then
        for i=1, data:len() do
            table.insert(bytes.data, data:byte(i))
        end
        bytes.length = data:len()
    else
        local count = 0
        for i,v in ipairs(data) do
            table.insert(bytes.data, v)
            count = count + 1
        end
        bytes.length = count
    end

    return setmetatable(bytes, Bytes)
end

-- 4 bytes, lsb
Bytes.toint32 = function(self)
    if self.length ~= 4 then
        error('int32 is 4 bytes')
    end
    print(self.data[1], self.data[2], self.data[3], self.data[4])
    return (self.data[4] * (256^3)) +
            (self.data[3] * (256^2)) +
            (self.data[2] * (256^1)) +
            (self.data[1] * (256^0))
end

Bytes.__tostring = function(self)
    return string.format('Bytes[%d] -> %s', self.length, table.concat(self.data, ' '))
end

Bytes.__eq = function(self, other)
    return table.concat(self.data) == table.concat(other.data)
end



local readuntilnul = function(f)
    local buf = ''
    while true do
        local ch = f:read(1)
        if ch:byte() == 0 then break end
        buf = buf .. ch
    end
    return buf
end




-- Parse Crimsonland pak file
local readindex = function(filename)

    local file = io.open(filename, 'rb')

    if file == nil then
        error(string.format('Error opening: %s', self.filename))
    end

    -- magic number: PAK(NULL)V11(NULL)
    if Bytes(file:read(8)) ~= Bytes({80, 65, 75, 0, 86, 49, 49, 0}) then
        error('Wrong file format')
    end

    -- raw offsets
    local indexstart = Bytes(file:read(4)):toint32()
    local indexend   = Bytes(file:read(4)):toint32()

    file:seek('set', indexstart)

    -- number index entries
    local indexsize = Bytes(file:read(4)):toint32()
    indexsize = 100
    print(indexsize)

    local index = {}

    for filenum = 1, indexsize  do
        print(file:seek('cur'))
        table.insert(index, {
            name   = readuntilnul(file),
            offset = Bytes(file:read(4)):toint32(),
            length = Bytes(file:read(4)):toint32()
        })

        -- junk
        file:read(8)
    end

    file:close()

    return index
end


local index = readindex('D:\\Steam\\steamapps\\common\\Crimsonland\\data.pak')

for _,v in ipairs(index) do
    -- print(string.format('name:%s offset:%d length:%d', v.name, v.offset, v.length))
end


