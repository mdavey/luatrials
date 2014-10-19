local wx = require("wx")

local frame = nil
local panel = nil


local function makeimage(width, height)
    local bitmap = wx.wxBitmap(width, height, 32)
    
    local dc = wx.wxMemoryDC()
    dc:SelectObject(bitmap)
    
    local pen = wx.wxPen()    
    
    for x = 0, 255 do
        for y = 0, 255 do           
            pen:SetColour(wx.wxColour(x, 0, y))
            dc:SetPen(pen)
            dc:DrawPoint(x, y)
        end
    end
    
    dc:delete()
    
    return bitmap
end

local function rotatebitmap(bitmap, angle)
    local img = bitmap:ConvertToImage()
    local img_centre = wx.wxPoint(0, 0) -- img:GetWidth()/2, img:GetHeight()/2 )
    img = img:Rotate(angle, img_centre)
    -- img:Rotate90()
    return wx.wxBitmap(img)
end

local bitmap = makeimage(255, 255)

-- paint event handler for the frame that's called by wxEVT_PAINT
local function OnPaint(event)
    local dc = wx.wxPaintDC(panel)

    dc:DrawBitmap(bitmap, 0, 0, false)
    dc:DrawBitmap(rotatebitmap(bitmap, 90), 255, 0, false)
    dc:DrawBitmap(rotatebitmap(bitmap, 180), 0, 255, false)
    dc:DrawBitmap(rotatebitmap(bitmap, 270), 255, 255, false)
    
    -- for x = 1, 255 do
    --     for y = 1, 255 do
    --         local colour = wx.wxColour(x, 0, y)
    --         local pen = wx.wxPen()
    --         pen:SetColour(colour)
    --         
    --         dc:SetPen(pen)
    --         dc:DrawPoint(x, y)
    --     end
    -- end

    -- dc:DrawRectangle(10, 10, 300, 300);
    -- dc:DrawRoundedRectangle(20, 20, 280, 280, 20);
    -- dc:DrawEllipse(30, 30, 260, 260);
    -- dc:DrawText("A test string", 50, 150);

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
                        wx.wxSize(450, 450),
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
