local PANEL = {}
AccessorFunc(PANEL, "m_iAllign", "ContentAlignment", FORCE_NUMBER)
AccessorFunc(PANEL, "m_iGap", "Gap", FORCE_NUMBER)

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
end

local gru = surface.GetTextureID("vgui/gradient-u")
local grl = surface.GetTextureID("vgui/gradient-l")
local grr = surface.GetTextureID("vgui/gradient-r")

function PANEL:Paint(w, h)
    if (self.currAlpha < 255) then
        self.currAlpha = Lerp(FrameTime() * 4, self.currAlpha, 270)
    end

    local barWide = (self.currAlpha / 255) * (w / 2)
    surface.SetDrawColor(255, 255, 255, self.currAlpha * .8)
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
    btn:SetTextColor(Color(255, 255, 255, 150))
    btn:SetText(name)
    btn.DoClick = function(s)
        local newControl = self.Controls[name]
        if (IsValid(newControl) and newControl == self.ActivePanel) then
            return
        end

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
    btn.Paint = function(s, w, h)
        s.Alpha = Lerp(FrameTime() * 10, s.Alpha, (s:IsHovered() or self.ActiveTab == s) and 255 or 0)
        local wide = w * (s.Alpha / 255)
        draw.RoundedBoxEx(4, w / 2 - wide / 2, h - 4, wide, 4, Color(255, 255, 255, s.Alpha), false, false, true, true)
        surface.SetDrawColor(255, 255, 255, s.Alpha * .25)
        surface.DrawRect(2, 0, w - 4, 2)
        surface.SetTexture(gru)
        surface.DrawTexturedRect(4, 4, w - 8, h * (s.Alpha / 255) - 8)

        surface.DrawTexturedRect(0, 0, 2, h * (s.Alpha / 255))
        surface.DrawTexturedRect(w - 2, 0, 2, h * (s.Alpha / 255))
    end

    surface.SetFont(NebulaUI:Font(24))
    local tx, _ = surface.GetTextSize(name)
    tx = tx + 32

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
