-- Description: wxLua program to test buffered text drawing --

--[[

wxWidgets docs:  [http://docs.wxwidgets.org/3.0/annotated.html](http://docs.wxwidgets.org/3.0/annotated.html)

wxLua docs: [http://wxlua.sourceforge.net/docs/wxluaref.html](http://wxlua.sourceforge.net/docs/wxluaref.html)

]]


local wx = require("wx")


local frame = nil
local panel = nil


local function repaint(repaintevent)
    -- **MUST** create a wxPaintDC inside the here or wxWidgets + Windows when 
    -- generate an endless stream of paint events
    -- local dc = wx.wxPaintDC(panel)
    
    local dc = wx.wxBufferedPaintDC(panel)
    
    -- Buffered + wxBG_STYLE_CUSTOM/wxBG_STYLE_PAINT means we do this manually
    dc:Clear()
    
    -- Text has a solid background color
    dc:SetBackgroundMode(wx.wxSOLID)

    -- Set font for the DC, must be cleaned up at the end
    local underline = false
    dc:SetFont(wx.wxFont(10, wx.wxFONTFAMILY_MODERN, wx.wxFONTSTYLE_NORMAL, wx.wxFONTWEIGHT_NORMAL, underline, "Courier New"))

    -- The width, height and other dimensions of the text string.
    -- Should be constant for a monospaced font
    local textwidth, textheight, _ = dc:GetTextExtent("Hello World")
    
    -- Where we are painting
    local width = panel:GetSize():GetWidth()
    local height = panel:GetSize():GetHeight()
    
    for i = 1, 2000 do
        local x = math.random(0, width-textwidth)
        local y = math.random(0, height-textheight)    
        
        local r = math.random(0, 255)
        local g = math.random(0, 255)
        local b = math.random(0, 255)
        
        dc:SetTextForeground(wx.wxColour(r, g, b))
        dc:SetTextBackground(wx.wxColour(math.floor(r/2),  math.floor(g/2), math.floor(b/2)))
        
        dc:DrawText("Hello World", x, y)
    end
    
    -- Cleanup.  Must delete DC and unset font
    dc:SetFont(wx.wxNullFont)
    dc:delete()
end


local function resize(resizeevent)
    -- local size = resizeevent:GetSize()
    -- print(size:GetWidth(), size:GetHeight())
    
    -- Refresh the panel on resize, otherwise let Windows try and sort it out... 
    -- Which doesn't work
    panel:Refresh()
end


local function main()

    frame = wx.wxFrame( wx.NULL,
                        wx.wxID_ANY,
                        "Text Drawing",
                        wx.wxDefaultPosition,
                        wx.wxSize(600, 600),
                        wx.wxDEFAULT_FRAME_STYLE)

   -- create a single child window, wxWidgets will set the size to fill frame
    panel = wx.wxPanel(frame, wx.wxID_ANY)
    
    -- Hmmm, wxBG_STYLE_PAINT is missing.. Docs say to use it with wxBufferedPaintDC
    -- panel:SetBackgroundStyle(wx.wxBG_STYLE_PAINT)
    -- I'm confused the enum for wxBackgroundStyle in wxLua is different from wxWidgets
    -- wxWidgets source:  https://github.com/wxWidgets/wxWidgets/blob/6283e4e6f160a8c083256fd716fad3936e225f4d/include/wx/defs.h#L2034
    -- wxLua source:      https://github.com/LuaDist/wxlua/blob/83649e035070ccd335ee9b3efe6eadd219f3cc8a/bindings/wxwidgets/wxcore_defsutils.i#L475
    --
    -- wxWidgets does say that CUSTOM is the same as PAINT...
    -- ... and it works!
    panel:SetBackgroundStyle(wx.wxBG_STYLE_CUSTOM)

    -- connect the paint event handler function with the paint event
    panel:Connect(wx.wxEVT_PAINT, repaint)
    panel:Connect(wx.wxEVT_SIZE, resize)

    -- show the frame window
    frame:Show(true)
end

main()

wx.wxGetApp():MainLoop()
