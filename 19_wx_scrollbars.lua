-- Description: wxLua program to test custom scroll bars --

--[[

wxWidgets docs:  [http://docs.wxwidgets.org/3.0/annotated.html](http://docs.wxwidgets.org/3.0/annotated.html)

wxLua docs: [http://wxlua.sourceforge.net/docs/wxluaref.html](http://wxlua.sourceforge.net/docs/wxluaref.html)

wxScrollbar: [http://docs.wxwidgets.org/2.8/wx_wxscrollbar.html#wxscrollbar](http://docs.wxwidgets.org/2.8/wx_wxscrollbar.html#wxscrollbar)
wxScrollEvent: [http://docs.wxwidgets.org/2.8/wx_wxscrollevent.html#wxscrollevent](http://docs.wxwidgets.org/2.8/wx_wxscrollevent.html#wxscrollevent)

]]


local wx = require("wx")


local frame = nil
local text = nil
local scrollbar = nil


local function keyup(keyevent)
    if keyevent:GetKeyCode() == wx.WXK_F6 then
    end    
end


local function scrolled(event)
    print(event:GetEventType() == wx.wxEVT_SCROLL_CHANGED and 'scroll changed' or 'scroll track',
          'pos',      event:GetPosition(), 
          'thumbpos', scrollbar:GetThumbPosition(),
          'thumbsize', scrollbar:GetThumbSize(),
          string.format('Can see from line %2d to %2d', event:GetPosition(), event:GetPosition() + scrollbar:GetThumbSize()))
      
      -- Ugh, would be better if scrollbar just couldn't take focus...
      text:SetFocus()
end


local function mousewheel(event)
    if event:GetWheelRotation() > 0 then
        scrollbar:SetThumbPosition(scrollbar:GetThumbPosition() - event:GetLinesPerAction())
    else
        scrollbar:SetThumbPosition(scrollbar:GetThumbPosition() + event:GetLinesPerAction())
    end
    
    -- Need to fire off our own event here
    scrollbar:AddPendingEvent(wx.wxScrollEvent(wx.wxEVT_SCROLL_CHANGED, wx.wxID_ANY, scrollbar:GetThumbPosition(), 0) )
end


local function main()

    frame = wx.wxFrame( wx.NULL,
                        wx.wxID_ANY,
                        "Scrollbar Test",
                        wx.wxDefaultPosition,
                        wx.wxSize(600, 600),
                        wx.wxDEFAULT_FRAME_STYLE)

    local sizer = wx.wxBoxSizer(wx.wxHORIZONTAL)
    
    text = wx.wxTextCtrl(frame, wx.wxID_ANY, "Test here", wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxTE_MULTILINE + wx.wxTE_NO_VSCROLL)    
    text:Connect(wx.wxEVT_KEY_UP, keyup)
    text:Connect(wx.wxEVT_MOUSEWHEEL, mousewheel)
    
    -- When defining your own scrollbar behaviour, you will always need to recalculate 
    -- the scrollbar settings when the window size changes. You could therefore put 
    -- your scrollbar calculations and SetScrollbar call into a function named 
    -- AdjustScrollbars, which can be called initially and also from a wxSizeEvent 
    -- event handler function.
    scrollbar = wx.wxScrollBar(frame, wx.wxID_ANY, wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxSB_VERTICAL)
    scrollbar:SetScrollbar(0, 15, 50, 15) -- start, size screen, total, page size
    
    -- wxEVT_SCROLL_CHANGED?  No def for wxEVT_SCROLL ?
    scrollbar:Connect(wx.wxEVT_SCROLL_CHANGED, scrolled) 
    
    -- Live updates, cool.  Still doesn't fire when I change it manually though?
    scrollbar:Connect(wx.wxEVT_SCROLL_THUMBTRACK, scrolled)
    
    -- I'm not sure if this is meant to work?  Proportion=0 = none?
    sizer:Add(text, 1, wx.wxEXPAND + wx.wxALL)
    sizer:Add(scrollbar, 0, wx.wxEXPAND)
    
    frame:SetSizer(sizer)

    -- show the frame window
    frame:Show(true)
end

main()

wx.wxGetApp():MainLoop()
