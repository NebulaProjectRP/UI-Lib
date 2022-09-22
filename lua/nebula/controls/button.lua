local BUTTON = {}
AccessorFunc(BUTTON, "m_iRoundSize", "Radius", FORCE_NUMBER)
function BUTTON:Init()
    self:SetFont(NebulaUI:Font(18))
    self:SetTextColor(Color(200, 200, 200))
    self:SetRadius(8)
    self.Alpha = 0
end

local gradient = Material("gui/center_gradient")
local purple = Color(16, 0, 24, 250)
local lightWhite = Color(237, 98, 255, 25)
function BUTTON:Paint(w, h)
    draw.RoundedBox(self:GetRadius(), 0, 0, w, h, Color(255, 255, 255, self:IsHovered() and 50 or 15))
    draw.RoundedBox(self:GetRadius(), 1, 1, w - 2, h - 2, purple)

    if (self.HighLight or (self:IsHovered() and input.IsMouseDown(MOUSE_LEFT))) then
        draw.RoundedBox(self:GetRadius(), 0, 0, w, h, self.Color or lightWhite)
    end

    self.Alpha = Lerp(FrameTime() * 4, self.Alpha, self:IsHovered() and 255 or 25)
    surface.SetMaterial(gradient)
    surface.SetDrawColor(46, 0, 64, self.Alpha)
    surface.DrawTexturedRectRotated(w / 2, h / 2, w, h, 0)
end

function BUTTON:SetRound(x)
    self:SetRadius(x)
end

function BUTTON:SetFontSize(size)
    self:SetFont(NebulaUI:Font(size or 18))
end

vgui.Register("nebula.button", BUTTON, "DButton")

local CLOSE = {}

function CLOSE:Init()
    self:SetText("✕")
    self:SetSize(32, 32)
end

function CLOSE:SetTarget(target)
    self.Target = target
end

function CLOSE:DoClick()
    if (self.Target and not isfunction(self.Target)) then
        self.Target:Remove()
    elseif (self.Target and isfunction(self.Target)) then
        self.Target()
    end
end

function CLOSE:OnCursorEntered()
    self:SetFont(NebulaUI:Font(24))
end

function CLOSE:OnCursorExited()
    self:SetFont(NebulaUI:Font(20))
end

vgui.Register("nebula.close", CLOSE, "nebula.button")