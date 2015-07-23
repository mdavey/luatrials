local fps = {}
fps.__index = fps

function fps.new()
    return setmetatable({frames=0, fps=0, dtotal=0}, fps)
end

function fps:tick(dt)
    self.frames = self.frames + 1
    self.dtotal = self.dtotal + dt
    if self.dtotal >= 1 then
        self.dtotal = self.dtotal - 1
        self.fps = self.frames
        self.frames = 0
    end
end

function fps:get()
    return self.fps
end

return fps