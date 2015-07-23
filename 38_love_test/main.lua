local socket = require('socket')
local LineBuffer = require('linebuffer')
local Fps = require('fps')


----------------


local fps = Fps.new()
local messages = LineBuffer.new(100)


----------------


local function setwindowtitle()
    local major, minor, revision = love.getVersion()
    local versionstring = string.format('%d.%d.%d', major, minor, revision)
    local title = string.format('38_love_test (%s)', versionstring)
    love.window.setTitle(title)
end

local function log(s)
    print(s)
    messages:add(s)
end

local function printmessages(messages)
    local width, height = love.graphics.getDimensions()
    local fontheight = love.graphics.getFont():getHeight()
    local lines = messages:get()   
    
    local y = height - fontheight - 10
    for _,line in ipairs(lines) do
        love.graphics.print(line, 10, y)        
        y = y - fontheight
    end
end


----------------


function love.load()
    log('loading...')
    
    -- http://www.marksimonson.com/fonts/view/anonymous-pro
    local defaultfont = love.graphics.newFont('resources/fonts/AnonymousPro-1.002.001/Anonymous Pro.ttf', 13)
    love.graphics.setFont(defaultfont)
    
    setwindowtitle()
    
    log('done')
end

function love.resize(w, h)
    log(('Window resized to width: %d and height: %d'):format(w, h))
end

function love.update(dt)
    fps:tick(dt)
end

function love.keyreleased(key)
    if key == 'escape' or key == 'q' then
        love.event.quit()
    end
end
 
function love.draw()
    local width, height = love.graphics.getDimensions()
        
    love.graphics.setColor(0xff, 0xff, 0xff)
    love.graphics.print("Hello World!", 400, 300)
    printmessages(messages)
    
    love.graphics.printf('FPS: ' .. fps:get(), 0, 10, width-10, 'right')
    
    love.graphics.setColor(0, 100, 100)
    love.graphics.rectangle('fill', 100, 100, 100, 100)
end
