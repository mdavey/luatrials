-- Description: Slightly better idea for working with SVG markup --


function tag(...)
    
    local t = {...}
    
    if #t == 0 then 
        error('Must pass tag name as first argument') 
    end
    
    local tag_name = t[1]  
    
    
    local function build_content(v)
        if type(v) == 'string' then 
            return v
        elseif type(v) == 'table' then
            return table.concat(v)
        else
            error('Unknown type for content: ' .. type(v))
        end
    end
    
    local function build_attr(kv)
        local lines = {}
        for k,v in pairs(kv) do
            table.insert(lines, string.format('%s="%s"', k, v))
        end
        return table.concat(lines, ' ')
    end        
    
    
    if not t[2] then
        -- only tab name passed
        return string.format('<%s />',tag_name)    
    elseif t[2] and type(t[2]) == 'table' and not t[2][1] then
    -- if 2nd arg is set, and it's a table/key_vale assume attributes, and 3rd arg is content
        local attr_string = build_attr(t[2])
        if t[3] then
            return string.format('<%s %s>%s</%s>', tag_name, attr_string, build_content(t[3]), tag_name)
        else
            return string.format('<%s %s />', tag_name, attr_string)
        end    
    elseif t[2] then
    -- if 2nd arg is set, assume it's content
        return string.format('<%s>%s</%s>', tag_name, build_content(t[2]), tag_name)
    end    
end

assert(tag('strong', 'hello') == '<strong>hello</strong>')
assert(tag('strong', {id='foo'}, 'hello') == '<strong id="foo">hello</strong>')
assert(tag('tr', {'a', 'b', 'c'}) == '<tr>abc</tr>')
assert(tag('tr', {class='foo'}, {'a', 'b', 'c'}) == '<tr class="foo">abc</tr>')


html = tag('html', {
        tag('body', {
            tag('h1', 'Heading'), 
            tag('p', 'Some text')
        })
    })

assert(html == '<html><body><h1>Heading</h1><p>Some text</p></body></html>')


return tag