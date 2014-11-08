
local wx = require('wx')

local youtubedllocation = [[C:\Users\Ardren\Downloads\youtube-dl.exe]]

-- local process = wx.wxProcess(nil, wx.wxPROCESS_REDIRECT)
-- local pid = wx.wxExecute(youtubedllocation, wx.wxEXEC_ASYNC, process)

-- process:Redirect()

--[[
   wxProcess *process = new wxProcess(wxPROCESS_REDIRECT);
   long pid = wxExecute(command, wxEXEC_ASYNC, process);
   process->Redirect();
]]





local size  = wx.wxSize(600, 600)
local title = 'youtube-dl gui'
local frame = wx.wxFrame(wx.NULL, wx.wxID_ANY, title, wx.wxDefaultPosition, size, wx.wxDEFAULT_FRAME_STYLE)

local inputtext  = wx.wxTextCtrl(frame, wx.wxID_ANY, 'rG65hWsRRXI', wx.wxDefaultPosition, wx.wxDefaultSize)
local resulttext = wx.wxTextCtrl(frame, wx.wxID_ANY, '', wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxTE_MULTILINE)

local sizer = wx.wxBoxSizer(wx.wxVERTICAL)
sizer:Add(inputtext,  0, wx.wxEXPAND)
sizer:Add(resulttext, 1, wx.wxEXPAND + wx.wxALL)
frame:SetSizer(sizer)

local coprocess = nil

local stream

local spawn = function()
    local command = youtubedllocation .. ' -F ' .. inputtext:GetValue()
    
    local process = wx.wxProcess(frame, wx.wxPROCESS_REDIRECT)
    process:Redirect()
    
    local pid = wx.wxExecute(command, wx.wxEXEC_ASYNC, process)    
    
    local stream = process:GetInputStream()
    
    print('0')
    
    while stream:Eof() == false do
        print('1')
        if stream:CanRead() then                        
            print('2')
            local s = stream:Read(128)            
            print('3')
            -- resulttext:AppendText(s)
            print(s)
            print('4')
        end
        print('5')
        coroutine.yield()
        print('6')
        print(stream)
        print('7')
        print(stream, stream:IsOk()) -- wtf, crashes here!
        print('8')
        print(stream, stream:Eof()) -- wtf, crashes here!
        print('9')
    end
    
    print('10')
    
    process:CloseOutput()
    
    print('11')

end


inputtext:Connect(wx.wxEVT_KEY_UP, function(e)
    if e:GetKeyCode() == wx.WXK_RETURN then
        if coprocess == nil or coroutine.status(coprocess) == "dead" then
            coprocess = coroutine.create(spawn)        
        else
            print('Already running...')
        end
    end
end)


frame:Connect(wx.wxEVT_IDLE, function(e)
    if coprocess ~= nil and coroutine.status(coprocess) ~= "dead" then
        local status, msg = coroutine.resume(coprocess)
    end
end)


frame:Show(true)
wx.wxGetApp():MainLoop()

