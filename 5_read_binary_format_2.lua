--[[

This is my 2nd attempt to re-write my Crimsonland data file pythong script in
lua.  Again avoided 3rd party libraries.

This seems much nicer, but I'm not 100% sure about wrapping a file object

I'm going to need to learn terminology too, file object? file table?
file handle?  file is the handle, but it has a metatable pointed it
to the table file that has methods on it...

----

I just spent two hours debugging this POS.  I thought I had a off by one error
then I thought it must have been a scope error (global clobbering) then a
reference error (how are file handles copied/assigned).  Turned out to be
missing qoutes about 'rb' in io.open.  Fuck me.

Use require('strict') always, always fucking always

]]


require('strict')



BinaryFile = {}

BinaryFile.new = function(file)
    return setmetatable({file=file}, {__index=BinaryFile})
end

BinaryFile.readint32 = function(self)
    local data = self.file:read(4)
    return (data:byte(4) * (256^3)) +
            (data:byte(3) * (256^2)) +
            (data:byte(2) * (256^1)) +
            (data:byte(1) * (256^0))
end

BinaryFile.readnulstring = function(self)
    local buf = ''
    while true do
        local ch = self.file:read(1)
        if ch:byte() == 0 then break end
        buf = buf .. ch
    end
    return buf
end

BinaryFile.read = function(self, ...)
    return self.file:read(...)
end

BinaryFile.skip = BinaryFile.read

BinaryFile.seek = function(self, ...)
    return self.file:seek(...)
end


--[[

My mythical editor



tag('header')
    tag('magic')
    f:readnulstring()
    f:readnulstring()
    tag()

    tag('index start offset')
    f:readint32()
    tag()

    tag('index end offset')
    f:readint32()
    tag()
tag()


Wow.  No.

----------------

So, what if readint32() really did:
    local s = f:seek('cur')
    local v = f:read(4)
    local e = f:seek('cur')
    return {start=s, vcalue=v, end=e}

Then tag() could take a object with start and end + message have
everything it needs.  While the program can still access the
data.

assert(magic1.value == 'PAK', 'wrong magic header')

Of course all the file access would need to be guarded well if
your def file sucked.


local magic1 = f:readnulstring()
local magic2 = f:readnulstring()

tag('Magic', {magic1,magic2})

local indexstartoffset = f:readint32()
local indexendoffset = f:readint32()

tag('index start', indexstartoffset)
tag('index start', indexendoffset)

f:seek('set', indexstartoffset.value)


hmmm... Still ugly, but better


]]

local readindex = function(filename)
    local f  = io.open(filename, 'rb')
    local bf = BinaryFile.new(f)

    -- Header
    assert(bf:readnulstring() == 'PAK')
    assert(bf:readnulstring() == 'V11')

    -- index offsets
    local indexstartoffset = bf:readint32()
    local indexendoffset   = bf:readint32()

    -- just to index
    bf:seek('set', indexstartoffset)

    -- number of entries
    local indexsize = bf:readint32()

    --indexsize = 100

    local index = {}

    for i=1, indexsize do
        table.insert(index, {
            name   = bf:readnulstring(),
            offset = bf:readint32(),
            length = bf:readint32()
        })

        -- junk
        bf:skip(8)
    end

    f:close()

    return index
end



local index = readindex('D:\\Steam\\steamapps\\common\\Crimsonland\\data.pak')

for _,v in ipairs(index) do
    print(string.format('name:%s offset:%d length:%d', v.name, v.offset, v.length))
end


