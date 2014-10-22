--[[

Docs:  http://docs.wxwidgets.org/3.0/annotated.html

]]


local wx = require("wx")


local frame = nil
local hextextcontrol = nil


local function gethexlines(filename)
    local f = io.open(filename, 'rb')
    
    if f == nil then error('Cannot open file') end
    
    local readsize = 16
    local counter = 0
    local lines = {}
    
    while true do
        local buf = f:read(readsize)
        
        if buf == nil then break end
        
        -- Offset part
        local lineoffset = string.format('%08d', counter)
        
        -- Hex part
        local linehex = {}
        
        for i=1, buf:len() do
            local char = buf:sub(i, i):byte()
            local hex  = string.format('%02X', char)
            table.insert(linehex, hex)
        end
        
        linehex = table.concat(linehex, ' ')
        
        -- ASCII part
        local lineascii = buf:gsub('%c', ' ')
        
        -- Pad to align the ASCII
        if buf:len() < readsize then
            linehex = linehex .. string.rep(' ', 3 * (readsize- buf:len()))
        end
        
        -- Done!
        table.insert(lines, lineoffset .. '  ' .. linehex .. '  ' .. lineascii)
        
        counter = counter + readsize
    end
    
    f:close()
    
    return table.concat(lines, '\n')
end


local function showhexlines(lines)
    -- This loses the default style, while append text doesn't
    -- hextextcontrol:SetValue(lines)
        
    hextextcontrol:SetValue('')
    hextextcontrol:AppendText(lines)
end


local function openfilehandler(evt)
    local opendialog = wx.wxFileDialog(frame, 
                                       'Open file...', -- dialog title
                                       '',             -- default dir
                                       '',             -- default fiename
                                       'All files (*.*)|*.*', 
                                       wx.wxFD_OPEN + wx.wxFD_FILE_MUST_EXIST)
    
    if opendialog:ShowModal() ~= wx.wxID_CANCEL then
        local filename = opendialog:GetPath()
        showhexlines(gethexlines(filename))
    end
end
    

local function main()
    frame = wx.wxFrame( wx.NULL,
                        wx.wxID_ANY,
                        "Hex View",
                        wx.wxDefaultPosition,
                        wx.wxSize(800, 600),
                        wx.wxDEFAULT_FRAME_STYLE)

    hextextcontrol = wx.wxTextCtrl(frame, 
                                   wx.wxID_ANY,
                                   '',
                                   wx.wxDefaultPosition, 
                                   wx.wxDefaultSize, 
                                   wx.wxTE_MULTILINE + wx.wxTE_RICH2 + wx.wxTE_READONLY)
                            
    hextextcontrol:SetBackgroundColour(wx.wxColour('#444444'))
                            
    hextextcontrol:SetDefaultStyle(wx.wxTextAttr(wx.wxColour('GREEN'), 
                                                 wx.wxNullColour, 
                                                 wx.wxFont(10, wx.wxFONTFAMILY_TELETYPE, wx.wxFONTSTYLE_NORMAL, wx.wxFONTWEIGHT_BOLD)
                                                 ))

    local droptarget = wx.wxLuaFileDropTarget()
    
    droptarget.OnDropFiles = function(self, x, y, filenames)
        for i = 1, #filenames do
            showhexlines(gethexlines(filenames[i]))
            break
        end
    end
    
    hextextcontrol:SetDropTarget(droptarget)


    local fileMenu = wx.wxMenu()
    fileMenu:Append(wx.wxID_OPEN, "&Open File...", "Open a file")
    fileMenu:AppendSeparator()
    fileMenu:Append(wx.wxID_EXIT, "E&xit", "Quit the program")

    local menuBar = wx.wxMenuBar()
    menuBar:Append(fileMenu, "&File")
    
    frame:SetMenuBar(menuBar)

    frame:Connect(wx.wxID_EXIT,
                  wx.wxEVT_COMMAND_MENU_SELECTED,
                  function (event) frame:Close(true) end)
              
    frame:Connect(wx.wxID_OPEN,
                  wx.wxEVT_COMMAND_MENU_SELECTED,
                  openfilehandler)
              
    
   

    local accelerators = {
        {wx.wxACCEL_CTRL, string.byte('o'), wx.wxID_OPEN},
        {wx.wxACCEL_ALT,  string.byte('x'), wx.wxID_EXIT} 
    }
    
    local acceleratortable = wx.wxAcceleratorTable(accelerators)
    
    frame:SetAcceleratorTable(acceleratortable)
    
    -- show the frame window
    frame:Show(true)
end

main()

wx.wxGetApp():MainLoop()
