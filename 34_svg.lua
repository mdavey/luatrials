-- Description: Bad idea for generating super simple SVG markup --


local function svg(width, height, svg_inner_function)
    local valid_tags = {
        circle={'cx', 'cy', 'r'},
        line={'x1', 'y1', 'x2', 'y2'},
        rect={'width', 'height'},
        text={'x', 'y', 'content'}
    }

    local env = setmetatable({},
    {
        __index = function(self, tag)
            if not valid_tags[tag] then error('Unknown tag: ' .. tag) end
            
            return function(attr)
                for _,v in ipairs(valid_tags[tag]) do
                    if not attr[v] then error('Tag: ' .. tag .. ' expects attribute: ' .. v) end
                end
                
                if attr['content'] then
                    local attr_string = ''
                    for k,v in pairs(attr) do
                        if k ~= 'content' then
                            attr_string = attr_string .. string.format('%s="%s"', k, v)
                        end
                    end
                    print(string.format('<%s %s>%s</%s>', tag, attr_string, attr['content'], tag))
                else
                    local attr_string = ''
                    for k,v in pairs(attr) do
                        attr_string = attr_string .. string.format('%s="%s" ', k, v)
                    end
                    print(string.format('<%s %s/>', tag, attr_string))
                end
            end
        end
    })
 
    -- close enough to fsetenv
    print(string.format('<svg version="1.1" baseProfile="full" width="%d" height="%d" xmlns="http://www.w3.org/2000/svg">', width, height))
    load(string.dump(svg_inner_function), nil, nil, env)()
    print('</svg>')
end


svg(400, 300, function()
    
    rect {width="100%", height="100%", fill="red"}
    circle {cx="150", cy="100", r="80", fill="green"}
    text {x="150", y="125", ['font-size']="60", ['text-anchor']="middle", fill="white", content="SVG"}    
end)


return svg