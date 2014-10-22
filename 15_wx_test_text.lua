--[[

Docs:  [http://docs.wxwidgets.org/3.0/annotated.html](http://docs.wxwidgets.org/3.0/annotated.html)

]]


local wx = require("wx")


local frame = nil
local scripttextcontrol = nil
local resulttextcontrol = nil


local function runstring(s)
    local block = load(s)
    
    local success, result = xpcall(block, function(err) 
        return debug.traceback(err) 
    end)
    
    if not success then         
        return false, result
    end
    
    return true, result
end


local function keyup(keyevent)
    if keyevent:GetKeyCode() == wx.WXK_F6 then
        
        -- This is mouse position!
        -- local position = keyevent:GetPosition()
        
        -- local selectedtext = scripttextcontrol:GetStringSelection()
        local alltext = scripttextcontrol:GetValue()
        
        local success, returnval = runstring(alltext)
        
        if not success then
            resulttextcontrol:AppendText('\nError:\n' .. returnval)
        else
            resulttextcontrol:AppendText('\nSuccess:\n' .. returnval)
        end
        
        -- frame:SetStatusText()
    end    
end


local function main()

    frame = wx.wxFrame( wx.NULL,
                        wx.wxID_ANY,
                        "Text Control Test",
                        wx.wxDefaultPosition,
                        wx.wxSize(600, 600),
                        wx.wxDEFAULT_FRAME_STYLE)

    local sizer = wx.wxBoxSizer(wx.wxVERTICAL)
    
    local defaulttext = 'return "Foobar";\n-- Press F6 to run\n\n'
    scripttextcontrol = wx.wxTextCtrl(frame, wx.wxID_ANY, defaulttext, wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxTE_MULTILINE + wx.wxTE_RICH2)
    scripttextcontrol:SetDefaultStyle(wx.wxTextAttr(wx.wxColour('DARK GREEN')))
    
    resulttextcontrol = wx.wxTextCtrl(frame, wx.wxID_ANY, '', wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxTE_MULTILINE + wx.wxTE_READONLY)
    resulttextcontrol:SetBackgroundColour(wx.wxLIGHT_GREY)
    
    sizer:Add(scripttextcontrol, 2, bit32.bor(wx.wxEXPAND, wx.wxALL), 0)
    sizer:Add(resulttextcontrol, 1, bit32.bor(wx.wxEXPAND, wx.wxALL), 0)
    
    frame:SetSizer(sizer)

    scripttextcontrol:Connect(wx.wxEVT_KEY_UP, keyup)

    -- create a simple status bar
    frame:CreateStatusBar(1)
    frame:SetStatusText('')

    -- show the frame window
    frame:Show(true)
end

main()

wx.wxGetApp():MainLoop()
