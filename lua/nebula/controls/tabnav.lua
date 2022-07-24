local PANEL = {}
AccessorFunc(PANEL, "m_iAllign", "ContentAlignment", FORCE_NUMBER)
AccessorFunc(PANEL, "m_iGap", "Gap", FORCE_NUMBER)
AccessorFunc(PANEL, "m_tColor", "Color")
PANEL.Controls = {}
PANEL.Buttons = {}
PANEL.ActiveTab = nil
PANEL._tabOrder = {}

function PANEL:Init()
    self:SetContentAlignment(TEXT_ALIGN_CENTER)
    self:SetGap(16)
    self.Controls = {}
    self.Buttons = {}
    self.ActiveTab = nil
    self.MaxButtonWide = 0
    self._tabOrder = {}

    self.currAlpha = 0
    self:SetColor(color_white)
end

local gru = surface.GetTextureID("vgui/gradient-u")
local grl = surface.GetTextureID("vgui/gradient-l")
local grr = surface.GetTextureID("vgui/gradient-r")

function PANEL:Paint(w, h)
    if (self.currAlpha < 255) then
        self.currAlpha = Lerp(FrameTime() * 4, self.currAlpha, 270)
    end

    local barWide = (self.currAlpha / 255) * (w / 2)
    surface.SetDrawColor(ColorAlpha(self:GetColor(), self.currAlpha * .8))
    surface.SetTexture(grl)
    surface.DrawTexturedRect(w / 2, h - 2, barWide, 2)
    surface.SetTexture(grr)
    surface.DrawTexturedRect(w / 2 - barWide, h - 2, barWide, 2)
end

function PANEL:OnTabSelected(tab)
end

function PANEL:SetContent(pnl)
    self.Container = pnl
end

function PANEL:AddCenter(pnl)
    pnl:SetParent(self)
    self.Header = pnl
    self:InvalidateLayout(true)
end

function PANEL:AddTab(name, control, press)
    if (not IsValid(self.Container)) then
        Error("No container has been setup, use panel:SetContent(container)")
        return
    end
    if type(control) != "string" then
        control:SetVisible(false)
    end

    local btn = vgui.Create("nebula.button", self)
    btn:SetFont(NebulaUI:Font(24))
    btn:SetTall(self:GetTall() - 2)
    btn:SetTextInset(12, -2)
    btn:SetTextColor(Color(255, 255, 255, 150))
    btn:SetText("")
    btn.DoClick = function(s)
        local newControl = self.Controls[name]
        if (IsValid(newControl) and newControl == self.ActivePanel) then
            return
        end

        surface.PlaySound("nebularp/doclick.mp3")
        surface.PlaySound("nebularp/doclick.mp3")
        surface.PlaySound("nebularp/doclick.mp3")

        if IsValid(self.ActivePanel) then
            local ref = self.ActivePanel
            ref:AlphaTo(0, .15, 0, function()
                ref:SetVisible(false)
            end)
        end

        if IsValid(newControl) then
            newControl:SetVisible(true)
            newControl:AlphaTo(255, .15, 0)
        else
            newControl = vgui.Create(control, self.Container)
            newControl:Dock(FILL)
            newControl:SetAlpha(0)
            newControl:AlphaTo(255, .15, 0)
            self.Controls[name] = newControl
        end

        newControl:InvalidateLayout(true)
        self:OnTabSelected(s, newControl)
        self.ActivePanel = newControl
        self.ActiveTab = s
    end
    btn.Alpha = 0
    btn.SetColor = function(s, clr)
        s.TargetColor = clr
        s.Progress = 0

        return s
    end
    btn.SetIcon = function(s, icon)
        btn.iconfunc = icon
        s:SetContentAlignment(5)

        surface.SetFont(s:GetFont())
        local tx, _ = surface.GetTextSize(s:GetText())

        s:SetTextInset(s:GetWide() / 2 - tx / 2 + 14, 0)

        return s
    end
    btn.Paint = function(s, w, h)
        if (s.TargetColor) then
            s.Progress = Lerp(FrameTime() * 2, s.Progress, self.ActiveTab == s and 1 or 0)
            s.Color = LerpVector(s.Progress, color_white:ToVector(), s.TargetColor:ToVector())
        end

        s.Alpha = Lerp(FrameTime() * 10, s.Alpha, (s:IsHovered() or self.ActiveTab == s) and 255 or 0)
        local color = s.Color and s.Color:ToColor() or self:GetColor()
        local wide = w * (s.Alpha / 255)
        draw.RoundedBoxEx(4, w / 2 - wide / 2, h - 2, wide, 2, ColorAlpha(color, s.Alpha), false, false, true, true)
        surface.SetDrawColor(ColorAlpha(color, s.Alpha * .4))
        surface.DrawRect(1, 1, w - 2, 1)

        surface.DrawTexturedRect(0, 0, 1, h * (s.Alpha / 255))
        surface.DrawTexturedRect(w - 1, 0, 1, h * (s.Alpha / 255))

        surface.SetDrawColor(ColorAlpha(color, s.Alpha * .1))
        surface.SetTexture(gru)
        surface.DrawTexturedRect(4, 4, w - 8, h * (s.Alpha / 255) - 8)

        draw.SimpleText(name, s:GetFont(), w / 2 + (s.iconfunc and 12 or 0), h / 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if (s.iconfunc) then
            surface.SetFont(s:GetFont())
            local tx, _ = surface.GetTextSize(name)
            s.iconfunc(w / 2 - tx / 2 - 16, h / 2 - 12, 24, 24, s.TargetColor or self:GetColor())
        end
    end

    surface.SetFont(NebulaUI:Font(24))
    local tx, _ = surface.GetTextSize(name)
    tx = tx + 52

    if (self.MaxButtonWide < tx) then
        self.MaxButtonWide = tx
    end

    if not press and not self.didinit then
        self.didinit = true
        btn:DoClick()
    end

    self.Buttons[name] = btn
    table.insert(self._tabOrder, btn)
    self:InvalidateLayout(true)

    return btn
end

function PANEL:SelectTab(name)
    if IsValid(self.Buttons[name]) then
        self.Buttons[name]:DoClick()
        self.didinit = true
    end
end

function PANEL:PerformLayout(w, h)
    local remainingWide = w
    local totalSize = 0

    for k, v in pairs(self.Buttons) do
        remainingWide = remainingWide - self.MaxButtonWide - self:GetGap()
        totalSize = totalSize + self.MaxButtonWide + self:GetGap()
        v:SetWide(self.MaxButtonWide)
    end

    if (IsValid(self.Header)) then
        remainingWide = remainingWide - self.Header:GetWide() - self:GetGap() * 2
        self.Header:SetPos(w / 2 - self.Header:GetWide() / 2, 0)
    end

    local startAt = remainingWide / 2
    local separation = self.MaxButtonWide + self:GetGap()

    for k = 1, #self._tabOrder do
        local btn = self._tabOrder[k]
        btn:SetPos(startAt, 0)
        startAt = startAt + separation
        if IsValid(self.Header) and math.Round(table.Count(self.Buttons) / 2) == k then
            startAt = startAt + self.Header:GetWide() + self:GetGap()
        end
    end
end

vgui.Register("nebula.tab", PANEL, "DPanel")
