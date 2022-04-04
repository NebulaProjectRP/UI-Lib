local PANEL = {}
AccessorFunc( PANEL, "m_hOwner", "Owner")

function PANEL:Init()
    self:SetWide(350)
    self:SetAlpha(0)
    self:AlphaTo(255, .25, 0)
    self:SetDrawOnTop(true)
    self.MarkupBody = ""

    hook.Add("Think", self, function(s)
        s:RealThink()
    end)
end

function PANEL:RealThink()
    local owner = self:GetOwner()
    if (not vgui.CursorVisible()) then
        self:Dispatch()
    end

    if (not IsValid(owner) and self.persist) then
        self:Remove()
        return
    end

    if not self:IsVisible() and owner:IsHovered() then
        self:SetVisible(true)
        self._dispatched = false
        self:AlphaTo(255, .25, 0)
        self.buildMarkup = false
    end
end

function PANEL:SetImageHeader(img)
end

PANEL.HadColorTag = false
PANEL.HadFontTag = false
function PANEL:AddContent(...)
    self.buildMarkup = false
    for k, v in pairs({...}) do
        if isstring(v) then
            self.MarkupBody = self.MarkupBody .. v
        elseif istable(v) then
            if (self.HadColorTag) then
                self.MarkupBody = self.MarkupBody .. "</color>"
                self.HadColorTag = false
            end
            self.MarkupBody = self.MarkupBody .. "<color=" .. v.r .. "," .. v.g .. "," .. v.b .. "," .. v.a .. "0>"
            self.HadColorTag = true
        elseif isnumber(v) then
            if (self.HadFontTag) then
                self.MarkupBody = self.MarkupBody .. "</font>"
                self.HadFontTag = false
            end
            self.MarkupBody = self.MarkupBody .. "<font=" .. NebulaUI:Font(v) .. ">"
        end
    end

    if (self.HadColorTag) then
        self.MarkupBody = self.MarkupBody .. "</color>"
        self.HadColorTag = false
    end

    if (self.HadFontTag) then
        self.MarkupBody = self.MarkupBody .. "</font>"
        self.HadFontTag = false
    end

    self.buildMarkup = true
end

function PANEL:Dispatch()
    if (self._dispatched) then return end
    self._dispatched = true
    local x, y = self:GetPos()
    self:MoveTo(x, y + 64, .1, 0)
    self:AlphaTo(0, .1, 0, function()
        if (self.persist) then
            self:SetVisible(false)
            return
        end
        self:Remove()
    end)
end

function PANEL:Close()
    self:Dispatch()
end

function PANEL:Think()
    if !IsValid(self:GetOwner()) and self.persist then
        self:Remove()
        return
    end

    if not self:IsHovered() and not self:GetOwner():IsHovered() then
        self:Dispatch()
    end
end

local light = Color(255, 255, 255, 50)
local Mat = Material( "vgui/arrow" )

function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, light)
    draw.RoundedBox(8, 1, 1, w - 2, h - 2, Color(16, 0, 24, 250))

    if (IsValid(self.ImageHeader)) then
        surface.SetMaterial(self.ImageHeader)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(8, 8, w - 32, self.Aspect * w)
    end

    if (not self.buildMarkup) then
        self.buildMarkup = true
        self.Markup = markup.Parse(self.MarkupBody, w - 16)
        self:InvalidateLayout(true)
    end

    if (self.Markup) then
        self.Markup:Draw(8, 8, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    self:DrawArrow(w, h)
end

function PANEL:DrawArrow(w, h)
	draw.NoTexture()
    DisableClipping(true)
        surface.SetDrawColor(light)
        surface.DrawPoly({
            {x = w / 2 - 9, y = h},
            {x = w / 2 + 9, y = h},
            {x = w / 2, y = h + 14},
        })
        surface.SetDrawColor(Color(16, 0, 24, 250))
        surface.DrawPoly({
            {x = w / 2 - 8, y = h - 2},
            {x = w / 2 + 8, y = h - 2},
            {x = w / 2, y = h + 12},
        })
    DisableClipping(false)
end

function PANEL:SetText(txt)
    surface.SetFont(NebulaUI:Font(16))
    local w, h = surface.GetTextSize(txt)
    self:SetWide(w + 20)
    self.MarkupBody = "<font=" .. NebulaUI:Font(16) .. ">" .. txt .. "</font>"
    self.buildMarkup = false
end

function PANEL:PerformLayout(w, h)
    if not self.Markup then return end
    if not IsValid(self:GetOwner()) then return end
    local totalHeight = self.Markup:GetHeight()
    if (self.ImageHeader) then
        local imageSize = self.Aspect * (w - 16)
        self:SetTall(totalHeight + (imageSize + 16))
    else
        self:SetTall(totalHeight + 16)
    end

    local owx, owy = self:GetOwner():LocalToScreen(self:GetOwner():GetWide() / 2 - w / 2, 0)
    local x, y = owx, owy - self:GetTall() - 8
    self:SetPos(x, y + 16)
    self:MoveTo(x, y, .25, 0)
end

function PANEL:OpenForPanel(a)
    self:SetOwner(a)
end

timer.Simple(0, function()
    vgui.Register("DTooltip", PANEL, "DPanel")
end)

local meta = FindMetaTable("Panel")

function meta:SetTip( ... )
    local args = {...}
    local tooltip = vgui.Create("DTooltip")
    tooltip:AddContent(unpack(args))
    tooltip:OpenForPanel(self)
    tooltip:SetVisible(false)
    tooltip.persist = true
end
