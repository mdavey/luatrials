--[[

Well I'll be.  wxLua actually makes about 10x more sense than IUP...

The offically documentation is okay, though kinda large:  http://docs.wxwidgets.org/2.8/

Plenty of examples though, and the Python examples are close syntactically too.

I like the idea behind wxLua.exe and wxLuaFreeze.  That's was actually a bit
question make in my head.  Even more so after hearing about hard it was to build
a compat IUP library.

Still lots of typing to do basic stuff, and there's tons of features that I assume
I'm going to have to learn.  I was really thinking about using SDL and essentially
writting a keyboard driven program to avoid all this UI crap...

]]


local wx = require("wx")


local function makeimage()
    local image = wx.wxImage(510, 510)
    
    for x = 0, 510 do
        for y = 0, 510 do
            local r = x
            local g = 0
            local b = y
            
            if x > 255 then r = (510-x) end
            if y > 255 then b = (510-y) end
            
            image:SetRGB(x, y, r, g, b)
        end
    end
    
    return image
end

local frame = nil
local panel = nil
local image = makeimage()


-- paint event handler for the frame that's called by wxEVT_PAINT
local function OnPaint(event)
    local dc = wx.wxPaintDC(panel)
    
    dc:DrawBitmap(wx.wxBitmap(image), 0, 0, false)
    
    dc:delete()
end

-- Create a function to encapulate the code, not necessary, but it makes it
--  easier to debug in some cases.
local function main()

    -- create the wxFrame window
    frame = wx.wxFrame( wx.NULL,
                        wx.wxID_ANY,
                        "wxLua Minimal Demo",
                        wx.wxDefaultPosition,
                        wx.wxSize(600, 600),
                        wx.wxDEFAULT_FRAME_STYLE)

    -- create a single child window, wxWidgets will set the size to fill frame
    panel = wx.wxPanel(frame, wx.wxID_ANY)

    -- connect the paint event handler function with the paint event
    panel:Connect(wx.wxEVT_PAINT, OnPaint)

    -- create a simple file menu
    local fileMenu = wx.wxMenu()
    fileMenu:Append(wx.wxID_EXIT, "E&xit", "Quit the program")

    -- create a simple help menu
    local helpMenu = wx.wxMenu()
    helpMenu:Append(wx.wxID_ABOUT, "&About", "About the wxLua Minimal Application")

    -- create a menu bar and append the file and help menus
    local menuBar = wx.wxMenuBar()
    menuBar:Append(fileMenu, "&File")
    menuBar:Append(helpMenu, "&Help")

    -- attach the menu bar into the frame
    frame:SetMenuBar(menuBar)

    -- create a simple status bar
    frame:CreateStatusBar(1)
    frame:SetStatusText("Welcome to wxLua.")

    -- connect the selection event of the exit menu item to an
    -- event handler that closes the window
    frame:Connect(wx.wxID_EXIT, wx.wxEVT_COMMAND_MENU_SELECTED,
                  function (event) frame:Close(true) end )

    -- connect the selection event of the about menu item
    frame:Connect(wx.wxID_ABOUT, wx.wxEVT_COMMAND_MENU_SELECTED,
        function (event)
            wx.wxMessageBox('This is the "About" dialog of the Minimal wxLua sample.\n'..
                            wxlua.wxLUA_VERSION_STRING.." built with "..wx.wxVERSION_STRING,
                            "About wxLua",
                            wx.wxOK + wx.wxICON_INFORMATION,
                            frame)
        end )

    -- show the frame window
    frame:Show(true)
end

main()

wx.wxGetApp():MainLoop()
