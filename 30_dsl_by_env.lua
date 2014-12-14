-- Description: Silly idea about using setfenv make a dsl inside a function --

-- html is just an idea, there's a lot more work to actually make it work
--  * dont auto close some tags (br, hr)
--  * always auto close some tags (script)
--  * first arg should be attributes if table: 
--    div({style=new}, 'Hello', em('World'))
--  * how can you write html(function() html(body())) without the second html 
--    referencing the first?
--  * indentation !?

local html_dsl_index = function(env, name)
    return function(...)
        -- concat all the passed values together
        local inner = ''
        for _,value in ipairs({...}) do
            inner = inner .. value
        end
        return '<' .. name .. '>' .. inner .. '</' .. name .. '>'
    end
end

local html = function(f)
    local env = setmetatable({_html = ''}, {__index = html_dsl_index})
    setfenv(f, env)
    return f()
end

----------------------------------------------------------------

local v = html(function()
    return body(h1('Foo'), h2('Bar'), 'Hello World')
end)

-- <body><h1>Foo</h1><h2>Bar</h2>Hello World</body>
print(v)