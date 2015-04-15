-- Description: Simple function arguments and return type checking? --

-- https://github.com/rjpcomputing/luaunit
local LuaUnit = require('luaunit')


--[[
Some fun with typed function in Lua... I'm not quite sure what I was trying to do
But it was fun.

Essentially turns this:

    function foobar(a, b) 
        assert(type(a) == 'string')
        assert(type(b) == 'number')
        local result = raboof(a, b)
        assert(type(result) == string or type(result) == 'boolean')
        return result
    end
    
Into:

    foobar = TypeFunction(function(a, b)
        return raboof(a, b)
    end)
    
    foobar:takes('string', 'number')    -- string *and* number
    foobar:returns('string', 'boolean') -- string *or* boolean  (yuck)
    
Alternatively:

    -- If foobar defined elsewhere
    -- foobar = function(a, b) return raboof(b, a) end
    foobar = TypeFunction(foobar):takes('string', 'number'):returns('boolean')
    
    
Now that I think about it, probably coudl be simplier.  We don't really need the table
could just wrap the whole thing in a lambda?   Is that better?

    TypeFunction = function(f, takes={}, returns={})
        return function(...) 
            check_takes()
            val = f(...)
            check_returns()
            return val
        end
    end
    
    
Bugs/Issues/Todo  (that I'll never actually do anything about)

  * optional arguments
      :takes('string', 'number?', '*') 
  * arguments and return values that can be different types
      :returns('string|number)
  * multiple return values
      :returns('string', 'number') means two values not one value with either type
  * better boolean checks
      :returns('string|false')
  * getmetatable checks?  Not sure how to do that, crawl '_G' and create a map of tableids -> names?
      :takes(':DatabaseConnection')
      :returns(':TypedFunction')

]]

local TypedFunction = {}

-- Can be called like:  TypedFunction(function(a, b, c) return {a, b, c} end)
TypedFunction = setmetatable(TypedFunction, {__call = function(self, ...) return TypedFunction.new(...) end})

function TypedFunction.new(func)
    return setmetatable({func=func}, {__call = TypedFunction.call, __index = TypedFunction})
end

function TypedFunction:call(...)
    local args = {...}
    if self._takes ~= nil then
        if args == nil or #self._takes ~= #args then
            error('Incorrect number of arguments passed.  Expected ' .. #self._takes .. ' got ' .. (args and #args or '0'))
        end
        
        for i=1, #args do
            if type(args[i]) ~= self._takes[i] then
                error('Wrong argument type as position ' .. i .. ' expected ' .. self._takes[i] .. ' got ' .. type(args[i]))
            end
        end
    end

    local returnval = self.func(...)
    
    if self._returns ~= nil then
        if returnval == nil then
            error('No value returned from function')
        end
        
        local foundmatch = false
        
        for i,v in ipairs(self._returns) do
            if type(returnval) == v then
                foundmatch = true
            end
        end
        
        if not foundmatch then
            error('Wrong return value type.  Expected ' .. table.concat(self._returns, '|') .. ' got ' .. type(returnval))
        end
    end
    
    return returnval
end

function TypedFunction:takes(...)
    self._takes = {...}
    return self
end

function TypedFunction:returns(...)
    self._returns = {...}
    return self
end
    


TestStringCheckFunction = {}

function TestStringCheckFunction:setup()
    self.reverse = TypedFunction.new(function(s) return string.reverse(s) end)
    self.reverse:takes('string')
    
    self.takes3args = function(a, b, c) return true end
    self.takes3args = TypedFunction(self.takes3args):takes('string', 'number', 'boolean'):returns('boolean')
    
    self.returnsargs = TypedFunction.new(function(...) return ... end)
    
    self.returnsstring = TypedFunction.new(function(s) return s end)
    self.returnsstring:returns('string')
    
    self.returnsstringorint = TypedFunction(function(v) return v end)
    self.returnsstringorint:returns('string', 'number')
    
    print(getmetatable(self.reverse))
end

function TestStringCheckFunction:test_function_can_be_called()
    assertEquals(self.reverse('abc'), 'cba')
    assertEquals(self.reverse(self.reverse('Hello World!')), 'Hello World!')
end

function TestStringCheckFunction:test_function_checks_argument_types()
    assertError(function() self.reverse(1) end)
    assertError(function() self.reverse({}) end)
    assertError(function() self.reverse(function() end) end)
end

function TestStringCheckFunction:test_function_checks_number_args()
    assertError(function() self.reverse() end)
    assertError(function() self.reverse('a', 'b') end)
    assertError(function() self.reverse(1, 2) end)
    assertError(function() self.reverse(print) end)
end

function TestStringCheckFunction:test_mutiple_argument_types()
    assertEquals(self.takes3args('a', 1, false), true)
    assertError(function() self.takes3args() end)
    assertError(function() self.takes3args(1, 2, 3) end)
    assertError(function() self.takes3args('a', 2, {}) end)
    assertError(function() self.takes3args(false, 1, 'a') end)
end

function TestStringCheckFunction:test_returnsargs()
    assertEquals(self.returnsargs('a'), 'a')
    assertEquals(self.returnsargs(1), 1)
    assertEquals(self.returnsargs(), nil)
end

function TestStringCheckFunction:test_returnsstring()
    assertEquals(self.returnsstring('a'), 'a')
    assertEquals(self.returnsstring('a', 'b'), 'a')
    assertError(function() self.returnsstring() end)
    assertError(function() self.returnsstring(1) end)
    assertError(function() self.returnsstring({}) end)
end

function TestStringCheckFunction:test_returnsstringorint()
    assertEquals(self.returnsstringorint('a'), 'a')
    assertEquals(self.returnsstringorint('a', 'b'), 'a')
    assertEquals(self.returnsstringorint(1), 1)
    assertEquals(self.returnsstringorint(2, 3), 2)
    assertError(function() self.returnsstringorint() end)
    assertError(function() self.returnsstringorint(function() end) end)
    assertError(function() self.returnsstringorint({}) end)
end

LuaUnit:run()

