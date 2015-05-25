-- Description: This is horrible.  The result of not thinking first --

local function table_reverse(t)
    local r = {}
    for i=#t, 1, -1 do
        table.insert(r, t[i])
    end
    return r
end

-- All this stuff should always return a new object.  Not modify itself

-- Just for adding
local BigNumber = {}

local BigNumber_MT = {}
BigNumber_MT.__index = BigNumber
BigNumber_MT.__tostring = function(self)
    return 'BigNumber: ' .. table.concat(table_reverse(self.v), '')
end

function BigNumber.new()
    return setmetatable({v={0}}, BigNumber_MT)
end

function BigNumber:add(what)
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
            self:normalise()

            -- knock off the lsb
            what = math.floor(what / 10)    
        end
        
    elseif type(what) == 'table' and what.v then
        for place=1, #what.v do
            self.v[place] = self.v[place] + what.v[place]                        
        end
        self:normalise()
    else
        error('Unable to add: ' .. type(what))
    end
end

function BigNumber:normalise()
    local place = 0
    while true do
        place = place + 1
        
        -- no value in this place, then stop
        if not self.v[place] then break end
        
        -- otherwise, carry values > 10
        -- 100% this is the stupid way to do this
        while self.v[place] > 9 do
            self.v[place] = self.v[place] - 10
            if not self.v[place+1] then self.v[place+1] = 0 end
            self.v[place+1] = self.v[place+1] + 1
        end
    end
end


---[[
local v = 1

local num = BigNumber.new()
num:add(1)


for i=1, 1000, 1 do
    v = v + v
    num:add(num)
    print(v, num)    
end
--]]
