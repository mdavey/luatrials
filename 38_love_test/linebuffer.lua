local linebuffer = {}
linebuffer.__index = linebuffer

function linebuffer.new(size)
    if not size then size = 100 end
    return setmetatable({lines={}, size=size}, linebuffer)
end

function linebuffer:add(line)
    table.insert(self.lines, 1, line)
    if self.lines[self.size+1] then
        self.lines[self.size+1] = nil
    end
end

function linebuffer:get()
    return self.lines
end

return linebuffer