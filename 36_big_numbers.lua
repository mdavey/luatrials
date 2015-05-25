-- Description: Add BigNumbers together.  Only add. --

-- yay stdlib
local function table_reverse(t)
    local r = {}
    for i=#t, 1, -1 do
        table.insert(r, t[i])
    end
    return r
end


-- Just for adding
local BigNumber = {}

BigNumber.__index = BigNumber

function BigNumber.new(initial_value)
    local obj = setmetatable({v={0}}, BigNumber)
    if initial_value then
        obj:set(initial_value)
    end
    return obj
end

function BigNumber:set(what)
    self.v = {0}
    self:inc(what)
end

function BigNumber:inc(what)
    -- print(self, what)
    
    if type(what) == 'number' then
        -- print('Adding Number')
        local place = 0
        
        while what > 0 do
            place = place + 1
            
            -- value of the current position
            local value = what % 10
            
            -- increment the correct place 
            if not self.v[place] then
                self.v[place] = 0
            end
            self.v[place] = self.v[place] + value

            -- handle carries
            self:handle_carry()

            -- knock off the lsb
            what = math.floor(what / 10)    
        end
        
    elseif type(what) == 'table' and what.v then
        for place=1, #what.v do
            if not self.v[place] then self.v[place] = 0 end
            self.v[place] = self.v[place] + what.v[place]
        end
        self:handle_carry()
    else
        error('Unable to add: ' .. type(what))
    end
end

function BigNumber:handle_carry()
    local place = 0
    while true do
        place = place + 1
        
        -- no value in this place, then stop
        if not self.v[place] then break end
        
        -- otherwise, carry values > 10
        -- 100% this is the stupid way to do this
        --
        -- next_value = math.floor(self.v[place] / 10)
        -- if next_value > 0 then
        --     self.v[place+1] = self.v[place+1] + next_value
        --     self.v[place] = self.v[place] - (10 * next_value)
        -- end
        while self.v[place] > 9 do
            self.v[place] = self.v[place] - 10
            if not self.v[place+1] then self.v[place+1] = 0 end
            self.v[place+1] = self.v[place+1] + 1
        end
    end
end

function BigNumber.add(a, b)
    local r = BigNumber.new()
    r:inc(a)
    r:inc(b)
    return r
end

BigNumber.__add = BigNumber.add

function BigNumber:__tostring()
    return table.concat(table_reverse(self.v), '')
end

        
return BigNumber