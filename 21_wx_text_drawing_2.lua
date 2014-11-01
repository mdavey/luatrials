-- Description: wxLua program to test buffered text drawing Again --

--[[

wxWidgets docs:  [http://docs.wxwidgets.org/3.0/annotated.html](http://docs.wxwidgets.org/3.0/annotated.html)

wxLua docs: [http://wxlua.sourceforge.net/docs/wxluaref.html](http://wxlua.sourceforge.net/docs/wxluaref.html)

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
