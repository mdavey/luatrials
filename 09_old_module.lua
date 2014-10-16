module('oldmodule')


local function lfun()
    return 42
end

function gfun()
    return 48
end


local Comm = {}

Comm.new = function()
    return setmetatable({}, {__index=Comm})
end

Comm.set = function(self, v)
    self.value = v
end

Comm.get = function(self)
    return self.value
end

-- Global reference, to local var
Comm2 = Comm

-- References are references
Comm:set('Hello')

-- Ha!  module() removes print
-- assert(print == nil)
-- Oh, and assert... Hmm


-- I swear everything is a funtion
return 'Foo!'