local PANEL = {}

function PANEL:Init()
    self:SetFont(NebulaUI:Font(20))
    self:SetTextColor(color_white)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, self:IsHovered() and 25 or 5))
    draw.RoundedBox(4, 1, 1, w - 2, h - 2, IsValid(self.Menu) and Color(49, 6, 70, 250) or Color(16, 0, 24, 250))
end

vgui.Register("nebula.combobox", PANEL, "DComboBox")
