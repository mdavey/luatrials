-- Description: Testing the old and new module formats --


assert(_VERSION == 'Lua 5.2')

-- loads the file 09_old_module, but imports the module oldmodule
-- 5.0 and 5.1 style I think
assert(require('09_old_module') == 'Foo!')

-- local = local, global = global
assert(oldmodule.gfun() == 48)

-- local
assert(oldmodule.Comm == nil)

-- Comm2 is reference to Comm
assert(oldmodule.Comm2 ~= nil)

-- Works as expected
assert(oldmodule.Comm2:get() == 'Hello')


-- 5.2 onwards I think
local newmodule = require('10_new_module')

assert(newmodule.l ~= nil)
assert(newmodule.g ~= nil)

assert(newmodule.newlocalfunint == nil)
assert(newmodule.newglobalfunint == nil)

assert(newlocalfunint == nil)

-- Gotcha, shared env.  Still need to be careful...
assert(newglobalfunint ~= nil)