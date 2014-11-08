-- Description: wx GUI testing async reading from other processes --

--[[

Still crashes when the App exits.  I thought it was process:CloseOutput() not
being called, but now I'm not sure.

My other crashing problems detailed here:
http://comments.gmane.org/gmane.comp.lib.wxwidgets.wxlua.user/3177

If these do what I think they do, I'll be annoyed
wx.wxSafeYield()
wx.wxWakeUpIdle()
wx.wxMilliSleep(250)
]]


local wx = require('wx')

local youtubedllocation = [[C:\Users\Ardren\Downloads\youtube-dl.exe]]

--------------------------------------------------------------------------------

local spawnedprocess = {}
spawnedprocess.process = nil
spawnedprocess.pid     = nil
spawnedprocess.stream  = nil

spawnedprocess.start = function(self, frame, command)
    self.process = wx.wxProcess(frame, wx.wxPROCESS_REDIRECT)
    self.process:Redirect()
    
    -- Without this (self.process = nil) everything crashes and dies somewhere
    -- around the last read in ASYNC.  WTF.
    --
    -- I think lua is garbage collecting process before the I can even read
    -- from the input stream (which is now referencing random memory)?
    self.process:Connect(wx.wxEVT_END_PROCESS, function(event)
        self.process:CloseOutput()
        self.process = nil
    end)
    
    self.pid = wx.wxExecute(command, wx.wxEXEC_ASYNC, self.process)        
    
    self.stream = self.process:GetInputStream()
end

spawnedprocess.close = function(self)
    self.process:CloseOutput()
end

spawnedprocess.eof = function(self)
    return self.stream:Eof()
end

spawnedprocess.canread = function(self)
    return self.stream:CanRead()
end

spawnedprocess.read = function(self)
    local s = ''
    while self.stream:CanRead() do
        s = s .. self.stream:Read(1024)
    end
    return s
end

--------------------------------------------------------------------------------

local size  = wx.wxSize(600, 600)
local title = 'youtube-dl gui'
local frame = wx.wxFrame(wx.NULL, wx.wxID_ANY, title, wx.wxDefaultPosition, size, wx.wxDEFAULT_FRAME_STYLE)

local inputtext  = wx.wxTextCtrl(frame, wx.wxID_ANY, 'rG65hWsRRXI', wx.wxDefaultPosition, wx.wxDefaultSize)
local resulttext = wx.wxTextCtrl(frame, wx.wxID_ANY, '', wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxTE_MULTILINE)

local sizer = wx.wxBoxSizer(wx.wxVERTICAL)
sizer:Add(inputtext,  0, wx.wxEXPAND)
sizer:Add(resulttext, 1, wx.wxEXPAND + wx.wxALL)
frame:SetSizer(sizer)


inputtext:Connect(wx.wxEVT_KEY_UP, function(e)
    if e:GetKeyCode() == wx.WXK_RETURN then
        -- spawnedprocess:start(frame, youtubedllocation .. ' -F ' .. inputtext:GetValue())
        spawnedprocess:start(frame, youtubedllocation .. ' ' .. inputtext:GetValue())
    end
end)


frame:Connect(wx.wxEVT_IDLE, function(e)
    if spawnedprocess.pid ~= nil and spawnedprocess:eof() == false and spawnedprocess:canread() then
        resulttext:AppendText(spawnedprocess:read())
    end
end)


frame:Show(true)
wx.wxGetApp():MainLoop()

