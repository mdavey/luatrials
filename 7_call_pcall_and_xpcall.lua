-- I don't know what I'm doing...


function fail()
  error('Failed')
end

function pass()
    return 'pass'
end

-- Call a function, on error print stacktrace and return nil
-- else return functions return value (ha)
function alwayspass(f)
    local success, result = xpcall(f, function(err) 
        return debug.traceback(err) 
    end)
    
    if not success then 
        print('Error:', result)
        return nil 
    end
    
    return result
end


assert(alwayspass(fail) == nil)
assert(alwayspass(pass) == 'pass')


-- load something (ld can be string, filename, function) with a blank
-- enviroment (cannot modify this env)
--
-- Passing nil to optional arguments okay?
function loadwithnoenv(ld)
    local newenv = {}
    return load(ld, nil, nil, newenv)
end


f = loadwithnoenv([[
    function helloworld()
        return "Hello World"
    end
    
    return helloworld()
]])

-- function works
assert(alwayspass(f) == "Hello World")

-- function hasn't modified this env
assert(helloworld == nil)


-- Little object that can set() and get() a single value
Comm = {}

Comm.new = function()
    return setmetatable({}, {__index=Comm})
end

Comm.set = function(self, v)
    self.value = v
end

Comm.get = function(self)
    return self.value
end
    
-- Make sure it works...
commtest = Comm.new()
commtest:set('Weee!')
assert(commtest:get() == 'Weee!')
    


function loadwithcustomenv(ld)
    local newenv = {}
    newenv.comm = Comm.new()
    newenv.comm:set('Hello from outside')    
    return load(ld, nil, nil, newenv), newenv
end


f,fenv = loadwithcustomenv([[
    -- Get a value from object that was inserted into our env
    -- Oh, there's a problem... assert isn't defined.. Haha
    -- assert(comm:get() == 'Hello from outside')
    
    function helloworld()
        return "Hello World"
    end
    
    -- change the value and hope that the caller is checking our env
    comm:set('Hello from inside')
    
    return helloworld()
]])

-- function works
assert(alwayspass(f) == "Hello World")

-- function hasn't modified this env
assert(helloworld == nil)

assert(fenv.comm:get() == 'Hello from inside')



function loadwithcustomenv2(ld)
    -- new env that can read from our env
    local newenv = setmetatable({}, {__index=_G})
    
    -- inset a comm object
    newenv.comm = Comm.new()
    newenv.comm:set('Hello from outside')    
    
    -- load code with the env
    local v = load(ld, nil, nil, newenv)
    
    -- remove the metatable (so it doesn't index back to _G later)
    -- setmetatable(newenv, nil)
    
    return v, newenv
end


f,fenv = loadwithcustomenv2([[
    -- Get a value from object that was inserted into our env
    assert(comm:get() == 'Hello from outside')
    
    function helloworld()
        return "Hello World"
    end
    
    -- change the value and hope that the caller is checking our env
    comm:set('Hello from inside')
    
    return helloworld()
]])

-- function works
assert(alwayspass(f) == "Hello World")

-- function hasn't modified this env
assert(helloworld == nil)

assert(fenv.comm:get() == 'Hello from inside')

-- hmm, fenv is still using metatable to access _G...
-- assert(fenv.alwayspass == nil)

-- Ok, I need to work out how load and xpcall are working and when things
-- are actually being executed...
setmetatable(fenv, nil)
assert(fenv.alwayspass == nil)

-- Because now we blow up again (env is missing)
-- assert(alwayspass(f) == "Hello World")



-- Okay, 3:30am work in 5 hours.  Last attempt.
p = 'assert(true == true) ; return "Hello World"'
f = load(p)
assert(f() == 'Hello World')

f = load(p, nil, nil, {})
-- error no assert
-- f()

-- again no assert
-- print(pcall(setfenv(f, {__index=_G})))

fenv = setmetatable({}, {__index=_G})
f = load(p, nil, nil, fenv)
f()

-- fallback
print(fenv.alwayspass)

-- remove
setmetatable(fenv, nil)

assert(fenv.alwayspass == nil)

-- Kabloom, no assert.
-- f()


-- So...
function loadwithcleanenv(ld)
    -- make env that falls back to _G
    local fenv = setmetatable({foo=32}, {__index=_G})
        
    for k,v in ipairs(fenv) do
        print(k, v)
    end
    
    print('WTF')
    
    -- load the code with that env
    local f = load(p, nil, nil, fenv)
    
    -- work out what was added to fenv (items in fenv that aren't in _G)
    local cleanfenv = {}
    for k,v in ipairs(fenv) do
        -- why is this blank?
        print(k, v)
        if _G[k] ~= nil then
            cleanfenv[k] = v
        end
    end
    
    return f,cleanfenv
end

print('Ahhh!')

p = 'assert(true == true) ; foo = 42; return "Hello World"'
f,fenv = loadwithcleanenv(p)
assert(f() == 'Hello World')



-- I'm lost...