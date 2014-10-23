-- Description: Brain dump regarding tagging file offsets in a hex editor --

--[[

End goal is a hex editor to help with reverse engineering file formats

The gimmick is the ability to write a file descripion format while
looking the hex dump of the file.

I've seen commerical product that uses a C like language to define
structs and basic program flow.  But I'm thinking of moving from structs
to a more flow based structure where we can not only read but jump
around.


Tags
----

Assign meaning to a block of data.  Both large scale (header, index, data)
and small scale (Flags for value 0x25 are read[1], write[4], binary[32])

Hierarchical in nature (I think)

]]


require('strict')
require('futurecode')


--[[

Idea 1
------

Explicit tags + interwoven with code

Ugly, tags defined before reading (no clever tag names).  But explicit
hierarchy

]]


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


--[[

Idea 2
------

Record offsets at runtime, Explicit tags when appropriate

No hierarchy?  Can we imply hierarchy just from file offsets in tags?
What if tags cross over?  Does it matter?

No as ugly.  More felexible in naming tags, and when to add them

]]

-- New readint32() method:
BinaryFile.readint32 = function(self)
    local start = f:seek('cur')
    local value = f:read(4)
    local end   = f:seek('cur')
    return {start=start, value=value, end=end}
end

-- Then tag() could take a object with start and end + message have
-- everything it needs.  While the program can still access the
-- data.

local magic1 = f:readnulstring()
local magic2 = f:readnulstring()

-- ???
assert(magic1.value == 'PAK', 'unknown file format')

-- single tag refering to two pieces of data
tag('magic', {magic1, magic2})

local indexstartoffset = f:readint32()
local indexendoffset = f:readint32()

-- tag individual values
tag('index start', indexstartoffset)
tag('index start', indexendoffset)

-- manually tag entire section of file
tag('index section', {start=indexstartoffset, end=indexendoffset, value=nil})

-- Jump around, jump up and get down
f:seek('set', indexstartoffset.value)


