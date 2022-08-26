local PANEL = {}
local notifyMat = Material("nebularp/ui/notify")

local icons = {
    notify = {},
    panel = GWEN.CreateTextureBorder(10, 74, 246, 44, 16, 22, 0, 16, notifyMat)
}

for k = 1, 5 do
    icons.notify[k] = GWEN.CreateTextureNormal(51 * (k - 1), 0, 51, 64, notifyMat)
end

function PANEL:Init()
    self:SetSize(ScrW() / 2, ScrH())
    self:SetPos(ScrW() - self:GetWide())
    self.Notifications = {}
    self:SetDrawOnTop(true)
end

function PANEL:addItem(txt, type, length)
    local data = {
        Text = txt,
        Type = type,
        Length = length,
        Max = length,
        Alpha = 255,
        X = self:GetWide(),
        Y = #self.Notifications * 64,
    }

    surface.SetFont(NebulaUI:Font(20))
    local tx, _ = surface.GetTextSize(txt)
    data.TX = tx + 60
    table.insert(self.Notifications, data)
end

PANEL.MouseDown = false

function PANEL:Paint(w, h)
    local showHand = false
    local mx, my = self:ScreenToLocal(gui.MousePos())

    for k, v in pairs(self.Notifications) do
        if v.Length > 0 then
            v.Length = v.Length - FrameTime()
        elseif v.Alpha > 0 then
            v.Alpha = v.Alpha - 5

            if v.Alpha <= 0 then
                table.remove(self.Notifications, k)
                continue
            end
        end

        v.X = Lerp(FrameTime() * 5, v.X, self:GetWide() - v.TX)
        v.Y = Lerp(FrameTime() * 5, v.Y, (k - 1) * 48 + ScrH() * .1)
        icons.panel(v.X, v.Y, v.TX, 44, ColorAlpha(color_white, v.Alpha))
        icons.notify[math.Clamp(v.Type + 1, 1, 5)](v.X + 2, v.Y, 51 * .7, 64 * .7, Color(255, 255, 255, v.Alpha))
        draw.SimpleText(v.Text, NebulaUI:Font(20), v.X + 38, v.Y + 20, Color(255, 255, 255, v.Alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(32, 23, 30, v.Alpha)
        surface.DrawRect(v.X + 38, v.Y + 32, v.TX - 42, 3)
        surface.SetDrawColor(165, 81, 144, v.Alpha)
        surface.DrawRect(v.X + 38, v.Y + 32, (v.TX - 42) * (v.Length / v.Max), 3)
        local isHovered = mx > 0 and mx < v.X + self:GetWide() and my > v.Y and my < v.Y + 48

        if isHovered then
            showHand = true
        end

        if not self.MouseDown and input.IsMouseDown(MOUSE_LEFT) and isHovered then
            self.MouseDown = true
            table.remove(self.Notifications, k)
        end
    end

    if self.MouseDown and not input.IsMouseDown(MOUSE_LEFT) then
        self.MouseDown = false
    end

    if #self.Notifications == 0 then
        self:Remove()
    end

    if showHand then
        self:SetCursor("hand")
    else
        self:SetCursor("none")
    end
end

vgui.Register("nebulaui.notify", PANEL, "DPanel")

function notification.AddLegacy(txt, type, length)
    if not IsValid(notify_panel) then
        notify_panel = vgui.Create("nebulaui.notify")
    end

    notify_panel:addItem(txt, type, length)
end

local standardIcons = {
    [NOTIFY_GENERIC] = Material("vgui/notices/generic"),
    [NOTIFY_ERROR] = Material("vgui/notices/error"),
    [NOTIFY_UNDO] = Material("vgui/notices/undo"),
    [NOTIFY_HINT] = Material("vgui/notices/hint"),
    [NOTIFY_CLEANUP] = Material("vgui/notices/cleanup")
}

local PANEL = {}
AccessorFunc(PANEL, "m_progressColor", "Color")
AccessorFunc(PANEL, "m_animTime", "AnimTime")
AccessorFunc(PANEL, "m_iconColor", "IconColor")

function PANEL:Init()
    self.textColor = Color(225, 225, 225)
    self:SetAnimTime(0.2)
    self:SetColor(XeninUI.Theme.Accent)
    self:SetIconColor(color_white)
    self.progressBar = vgui.Create("Panel", self)

    self.progressBar.Paint = function(pnl, w, h)
        local start = self.startTime
        local current = SysTime()
        local timeLeft = current - start
        local width = timeLeft * (w / self.duration)
        surface.SetDrawColor(self:GetColor())
        surface.DrawRect(0, 0, w - width, h)
    end

    self.icon = vgui.Create("Panel", self)
    self.icon:DockMargin(8, 8, 8, 8)

    self.icon.Paint = function(pnl, w, h)
        if not self.img or type(self.img) ~= "IMaterial" then return end
        surface.SetDrawColor(self:GetIconColor())
        surface.SetMaterial(self.img)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    self.label = vgui.Create("DLabel", self)
    self.label:SetFont(NebulaUI:Font(18))
    self.label:SetTextColor(self.textColor)
end

function PANEL:SetIcon(icon)
    self.img = icon
end

function PANEL:SetAvatar(ply)
    self.icon = vgui.Create("XeninUI.Avatar", self)
    self.icon:DockMargin(8, 8, 8, 8)
    self.icon:SetVertices(90)
    self.icon:SetPlayer(ply, 32)
    self.icon:SetWide(self.icon:GetTall())
    self:InvalidateLayout()
end

function PANEL:SetTextColor(col)
    self.label:SetTextColor(col)
end

function PANEL:SetText(text)
    self.label:SetText(text)
    self.label:SizeToContents()
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(20, 20, 20, 200)
    surface.DrawRect(0, 0, w, h)
end

function PANEL:Close()
    local id = self.id
    table.remove(XeninUI.Notifications, id)
    hook.Run("XeninUI.NotificationRemoved")

    self:LerpMove(ScrW() + self:GetWide(), self.y, self:GetAnimTime(), function()
        if not IsValid(self) then return end
        self:Remove()
    end)
end

function PANEL:SetDuration(time)
    self.duration = time
    self.startTime = SysTime()

    timer.Simple(time, function()
        if not IsValid(self) then return end
        self:Close()
    end)
end

function PANEL:PerformLayout(w, h)
    self.progressBar:SetSize(w, 4)
    self.progressBar:SetPos(0, h - self.progressBar:GetTall())
    self.icon:SetPos(4, 4)
    self.icon:SetWide(h - 4 - 8)
    self.label:SetWide(w - self.icon:GetWide() - 8)
    self.label:SetPos(self.icon.x + self.icon:GetWide() + 8, (h / 2 - self.progressBar:GetTall()) / 2)
end

function PANEL:StartNotification()
    local text = self.label:GetText()
    surface.SetFont(NebulaUI:Font(18))
    local tw, th = surface.GetTextSize(text)
    local width = 8 + 24 + 8 + tw + 8
    local x = ScrW() + width
    local y = 128
    local offset = (self.id - 1) * 45
    y = y - offset
    self:SetSize(width, 36)
    self:SetPos(x, y)
    self:LerpMove(ScrW() - width - 20, y, self:GetAnimTime())
end

vgui.Register("XeninUI.Notification", PANEL, "Panel")

function XeninUI:Notify(text, icon, duration, progressColor, textColor)
    text = text or "No Notification Text"
    icon = icon or Material("xenin/logo.png", "noclamp smooth")
    duration = duration or 4
    progressColor = progressColor or XeninUI.Theme.Accent
    textColor = textColor or Color(215, 215, 215)
    iconColor = iconColor or color_white
    local panel = vgui.Create("XeninUI.Notification")
    panel.Start = SysTime()
    panel:SetSize(width, 36)
    panel:SetPos(x, y)
    panel:SetText(text)
    panel:SetColor(progressColor)

    if isnumber(icon) then
        panel:SetIcon(standardIcons[icon])
    elseif IsValid(icon) and icon:IsPlayer() then
        panel:SetAvatar(icon)
    else
        panel:SetIcon(icon)
    end

    if not self.Notifications then
        self.Notifications = {}
    end

    panel:SetTextColor(textColor)
    panel:SetIconColor(iconColor)
    panel:SetDuration(duration)
    local id = table.insert(self.Notifications, panel)
    panel.id = id
    self.Notifications[id].id = id
    panel:StartNotification()
end