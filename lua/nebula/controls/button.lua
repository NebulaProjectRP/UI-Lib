local BUTTON = {}

function BUTTON:Init()
    self:SetFont(NebulaUI:Font(18))
    self:SetTextColor(Color(200, 200, 200))
    self.Alpha = 0
end

local gradient = Material("gui/center_gradient")
function BUTTON:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, self:IsHovered() and 50 or 15))
    draw.RoundedBox(8, 1, 1, w - 2, h - 2, Color(16, 0, 24, 250))

    if (self.HighLight or (self:IsHovered() and input.IsMouseDown(MOUSE_LEFT))) then
        draw.RoundedBox(8, 0, 0, w, h, Color(237, 98, 255, 25))
    end

    self.Alpha = Lerp(FrameTime() * 4, self.Alpha, self:IsHovered() and 255 or 0)
    surface.SetMaterial(gradient)
    surface.SetDrawColor(Color(46, 0, 64, self.Alpha))
    surface.DrawTexturedRectRotated(w / 2, h / 2, w, h, 0)
end

vgui.Register("nebula.button", BUTTON, "DButton")
