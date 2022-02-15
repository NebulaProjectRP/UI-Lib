local PANEL = {}
AccessorFunc(PANEL, "m_bUseTimer", "UseTimer", FORCE_BOOL)
AccessorFunc(PANEL, "m_fTimer", "Seconds", FORCE_NUMBER)

function PANEL:Init()
    if IsValid(NebulaUI.QuestionPanel) then
        NebulaUI.QuestionPanel:Remove()
        NebulaUI.QuestionPanel = nil
    end
    NebulaUI.QuestionPanel = self
    self:SetTitle("Question")
    self:SetSize(math.max(ScrW() * 0.2, 320), 96)
    self:SetPos(ScrW(), ScrH() / 2)
    self:SetAlpha(0)
    self:AlphaTo(255, 0.5, 0)
    self:MoveTo(ScrW() - self:GetWide(), ScrH() / 2, 0.5, 0, .5)
    self.Options = {}
end

function PANEL:UpdateTall()
    local markupTall = self.Markup and (self.Markup:GetHeight() + 16) or 0
    self:SetTall(32 + markupTall + 28 + (self:GetUseTimer() and 10 or 0))
end

function PANEL:SetContent(txt)
    self.Markup = markup.Parse("<font=" .. NebulaUI:Font(20) .. "><color=200, 200, 200>" .. txt .. "</color></font>", self:GetWide() - 16)
    self:UpdateTall()

    return self
end

function PANEL:PaintOver(w, h)
    if (self.Markup) then
        self.Markup:Draw(w / 2, 36, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    if (not self.Disposed and self:GetUseTimer()) then
        draw.RoundedBox(4, 8, h - 46, w - 16, 8, Color(0, 0, 0, 200))
        local progress = self:GetSeconds() / self._maxSeconds
        self:SetSeconds(self:GetSeconds() - FrameTime())

        draw.RoundedBox(4, 8, h - 46, (w - 16) * progress, 8, color_white)
        if (self:GetSeconds() <= 0) then
            self.Disposed = true
            self:AlphaTo(0, .25)
            self:MoveTo(ScrW(), ScrH() / 2, .25, 0, .5, function()
                self:Remove()
            end)
            if (self._callback) then
                self._callback()
            end
        end
    end
end

function PANEL:AddOption(title, func)
    local btn = vgui.Create("nebula.button", self)
    btn:SetText(title)
    btn.DoClick = function(s)
        self:SetMouseInputEnabled(false)
        self.Disposed = true
        self:AlphaTo(0, .25)
        self:MoveTo(ScrW(), ScrH() / 2, .25, 0, .5, function()
            self:Remove()
        end)
        func()
    end
    table.insert(self.Options, btn)
    return self
end

function PANEL:SetTimer(am, cb)
    self:SetUseTimer(true)
    self:SetSeconds(am)
    self._maxSeconds = am
    self._callback = cb
    self:UpdateTall()
    self:InvalidateLayout(true)
end

local cachedName = {}

//Accepts player entity, player steamid and steamid64
function PANEL:SetPlayer(ply)
    local avatar = vgui.Create("AvatarImage", self)
    avatar:SetSize(20, 20)
    avatar:SetPos(8, 6)
    if (isentity(ply)) then
        self.lblTitle:SetText(ply:Nick())
        avatar:SetPlayer(ply)
    elseif (isstring(ply)) then
        local sid = string.StartWith(ply, "STEAM") and util.SteamIDTo64(ply) or ply
        avatar:SetSteamID(sid)
        if (cachedName[sid]) then
            self.lblTitle:SetText(cachedName[sid])
        else
            steamworks.RequestPlayerInfo(sid, function(name)
                cachedName[sid] = name
                self.lblTitle:SetText(name)
            end)
        end
    end
    self.lblTitle:SetTextInset(24, 0)

    return self
end

function PANEL:PerformLayout(w, h)
    local optionCount = #self.Options
    local totalArea = w - 16 - (optionCount - 1) * 4
    local buttonWide = totalArea / optionCount
    local startPos = 8
    for k, v in pairs(self.Options) do
        v:SetPos(startPos, h - v:GetTall() - 8)
        v:SetSize(buttonWide, 24)
        startPos = startPos + v:GetWide() + 4
    end

    self.lblTitle:SetSize(w, 24)
    self.lblTitle:SetPos(8, 2)
    self.btnClose:SetSize(24, 24)
    self.btnClose:SetPos(w - 32, 4)
end

vgui.Register("nebula.dialog", PANEL, "nebula.frame")

function NebulaUI:Ask(...)
    local args = {...}
    local panel = vgui.Create("nebula.dialog")
    if (isentity(args[1])) then
        panel:SetPlayer(args[1])
    else
        panel:SetTitle(args[1])
    end
    panel:SetContent(args[2])
    for k = 3, #args, 2 do
        panel:AddOption(args[k], args[k + 1] or function()
            panel:Remove()
        end)
    end

    return panel
end

if (IsValid(NebulaUI.QuestionPanel)) then
    NebulaUI.QuestionPanel:Remove()
end
/*
NebulaUI:Ask(p(1), "This is a long ass question, this time the timer will happen\nso watcha gonna do!?", "Yes", function()
end, "No", function()
end):SetTimer(5, function()
    MsgN("Timer Off")
end)
*/