-- Description: wxLua program to test buffered text drawing Again --

--[[

wxWidgets docs:  [http://docs.wxwidgets.org/3.0/annotated.html](http://docs.wxwidgets.org/3.0/annotated.html)

wxLua docs: [http://wxlua.sourceforge.net/docs/wxluaref.html](http://wxlua.sourceforge.net/docs/wxluaref.html)



-- Hmmm

local fileAccess = FileAccess.new(filename)
local hexView    = HexView.new(fileAccess)

hexView.setBytesPerLine(16)
local lines = hexView.readLines(8, 20)

for i=1, #lines do
    hexViewControl.draw(lines[i].offset, lines[i].hex, lines[i].assci)
end

-- I think that works, mostly
-- Perhaps calling hexView currentScreen?  More obvious that it's cached?
--
-- Question is how to do:  click.x + click.y  ->  offset[321] with value " " ?
-- HexViewControl should be able to work it out based on bytesPerLine without
-- much work.

-- Perhaps this is simplier

local hexRegion = new HexRegion(filename)  -- init
hexRegion:setBytesPerLine(16)              -- init
hexRegion:setLinesRange(8, 20)             -- cache here, call on resize
local lines = hexRegion:getSelectedLines() -- call on paint with mucking around


-- No, need plain old stuff like file size to

-- init
local f = new FileAccess(filename)
local size = f:getSize()
local currentRegion = f.getHexRegion(8, 20, 16) -- start, end, bytes per line

-- inside onpaint
local lines = hexRegion:getLines()  -- already cached in current region
for i=1, #lines do
    hexViewControl.draw(lines[i])   -- lines.offset, lines.bytes[], lines.ascci[] ?
end

-- inside onresize / scroll
currentRegion = f.getHexRegion(scrollBar:getValue(), scrollBar:getValue() + visibleLines, bytesPerLine)

-- Who owns FileAccess?  I guess HexViewControl
local hexViewControl = HexViewControl.new(frame)
hexViewControl.setFile(filename) -- Does init here  I think that's fine

]]


local wx = require("wx")

--------------------------------------------------------------------------------
local HexViewControl = {}

HexViewControl.__index = HexViewControl

HexViewControl.new = function(frame)    
    local obj = setmetatable({panel=wx.wxPanel(frame, wx.wxID_ANY)}, HexViewControl)
    
    obj.panel:SetBackgroundStyle(wx.wxBG_STYLE_CUSTOM)
    obj.panel:Connect(wx.wxEVT_PAINT, function(e) obj:repaint(e) end)
    obj.panel:Connect(wx.wxEVT_SIZE,  function(e) obj:resize(e) end)
    
    return obj
end

function HexViewControl:repaint(paintEvent)
    local dc = wx.wxBufferedPaintDC(self.panel)
    
    dc:Clear()

    local width = self.panel:GetSize():GetWidth()
    local height = self.panel:GetSize():GetHeight()

    local underline = false
    dc:SetFont(wx.wxFont(10, wx.wxFONTFAMILY_MODERN, wx.wxFONTSTYLE_NORMAL, wx.wxFONTWEIGHT_NORMAL, underline, "Courier New"))

    local textWidth, textHeight = dc:GetTextExtent("i")
        
    local heightOfLine  = math.floor(textHeight)
    local numberOfLines = math.ceil(height / heightOfLine)
    
    local y = 0
    for line = 1, numberOfLines do
        dc:DrawText("Line: " .. line, 0, y)
        y = y + textHeight
    end
        
    dc:SetFont(wx.wxNullFont)
    dc:delete()
end

function HexViewControl:resize(resizeEvent)
    self.panel:Refresh()
end


--------------------------------------------------------------------------------


local size  = wx.wxSize(600, 600)
local title = "Text Drawing 2"
local frame = wx.wxFrame(wx.NULL, wx.wxID_ANY, title, wx.wxDefaultPosition, size, wx.wxDEFAULT_FRAME_STYLE)

HexViewControl.new(frame)

frame:Show(true)

wx.wxGetApp():MainLoop()
