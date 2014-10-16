-- I kinda, maybe, sortof know what I'm doing


function fail()
  error('Failed')
end


function pass()
    return 'pass'
end


-- Call a function, on error print stacktrace and return nil
-- else return functions return value (ha)
local function alwayspass(f)
    local success, result = xpcall(f, function(err) 
        return debug.traceback(err) 
    end)
    
    if not success then         
        print('Error:', result)
        return nil 
    end
    
    return result
end


print('\\/ \\/ \\/ \\/ Expected Error \\/ \\/ \\/ \\/')
assert(alwayspass(fail) == nil)
print('/\\ /\\ /\\ /\\ Expected Error /\\ /\\ /\\ /\\')
print()

assert(alwayspass(pass) == 'pass')


-- load something (ld can be string, filename, function) with a blank
-- enviroment (cannot modify this env)
--
-- Passing nil to optional arguments okay?
local function loadwithoutenv(ld)
    return load(ld, nil, nil, {})
end


local f = loadwithoutenv([[
    function helloworld()
        return "Hello World"
    end
    
    return helloworld()
]])

-- function works
assert(alwayspass(f) == "Hello World")

-- function hasn't modified this env
assert(helloworld == nil)


-- Finally try to call something from inside
local f = loadwithoutenv([[
    print("Hello World")
]])

-- Doesn't work.  Nothing called print exists
print('\\/ \\/ \\/ \\/ Expected Error \\/ \\/ \\/ \\/')
assert(alwayspass(f) == nil)
print('/\\ /\\ /\\ /\\ Expected Error /\\ /\\ /\\ /\\')
print()



-- Little object that can set() and get() a single value
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
    
-- Make sure it works...
local commtest = Comm.new()
commtest:set('Hi!')
assert(commtest:get() == 'Hi!')
    
    

-- Load code with a env that can access _G and insert an object (comm)
-- into the env too
local function loadwithcustomenv(ld, fenv)
    if not fenv then fenv = {} end
    
    -- allow fenv to read _G
    setmetatable(fenv, {__index = _G})

    -- load chunk with custom env
    local result = load(ld, nil, nil, fenv)
    
    -- remove meta table so that fenv doesnt point to when we just 
    -- want to look at it
    setmetatable(fenv, {})
    
    return result, fenv
end


local myenv = {}
myenv.comm = Comm.new()
myenv.comm:set('Hello from outside')
    
local f,fenv = loadwithcustomenv([[
    -- Get a value from object that was inserted into our env
    -- Oh, there's a problem... assert isn't defined.. Haha
    -- assert(comm:get() == 'Hello from outside')
    
    function ghelloworld()
        return "Hello World"
    end
    
    local function lhelloworld()
        return "Hello World"
    end   
    
    -- change the value and hope that the caller is checking our env
    comm:set('Hello from inside')
    
    return ghelloworld()
]], myenv)

-- function works
assert(alwayspass(f) == "Hello World")

-- function hasn't modified this env
assert(helloworld == nil)

-- Can access the global function defined inside
assert(fenv.ghelloworld ~= nil)

-- But can't access the locally defined helloworld
assert(fenv.lhelloworld == nil)

-- Can read from the comm object from inside the efnv
assert(fenv.comm:get() == 'Hello from inside')

-- Make sure it wasn't inserted into the current env
assert(comm == nil)

-- Make sure I can't still access stuff in this env via fenv
assert(fenv.fail == nil)

-- Can probably even edit the env
fenv.comm:set('hmm')
assert(fenv.comm:get() == 'hmm')

