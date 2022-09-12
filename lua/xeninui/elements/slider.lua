local PANEL = {}

XeninUI:CreateFont("XeninUI.SliderText", 22)
XeninUI:CreateFont("XeninUI.Title", 40)

AccessorFunc(PANEL, "m_sliderColor", "Color")
AccessorFunc(PANEL, "m_max", "Max")
AccessorFunc(PANEL, "m_min", "Min")
AccessorFunc(PANEL, "m_sliderHeight", "Height")

function PANEL:Init()
  self:SetText("")

  self:SetMin(0)
  self:SetMax(10)
  self:SetHeight(2)
  self:SetColor(XeninUI.Theme.Accent)
  self.fraction = 0

  self.grip = vgui.Create("DButton", self)
  self.grip:SetText("")
  self.grip:NoClipping(true)
  self.grip.xOffset = 0
  self.grip.startSize = self:GetHeight() * 4
  self.grip.size = self.grip.startSize
  self.grip.outlineSize = self.grip.startSize
  self.grip.Paint = function(pnl, w, h)
    XeninUI:DrawCircle(pnl.startSize, h / 2, pnl.outlineSize, 45, ColorAlpha(self:GetColor(), 30), 0)

    XeninUI:DrawCircle(pnl.startSize, h / 2, pnl.size, 45, self:GetColor(), 0)
  end
  self.grip.OnCursorEntered = function(pnl)
    pnl:Lerp("outlineSize", pnl:GetTall() / 2)
  end
  self.grip.OnCursorExited = function(pnl)
    pnl:Lerp("outlineSize", pnl.startSize)
  end
  self.grip.OnMousePressed = function(pnl)
    pnl.Depressed = true

    pnl:MouseCapture(true)
    pnl:Lerp("size", pnl:GetTall() / 2)
    pnl:LerpWidth(pnl:GetTall() * 2)
    self.Pressing = true
  end
  self.grip.OnMouseReleased = function(pnl)
    pnl.Depressed = nil

    pnl:Lerp("size", pnl.startSize)
    pnl:LerpWidth(pnl.startSize * 2)
    pnl:MouseCapture(false)

    self.Pressing = false
  end
  self.grip.OnCursorMoved = function(pnl, x, y)
    if (!pnl.Depressed) then return end

    local x, y = pnl:LocalToScreen(x, y)
    x, y = self:ScreenToLocal(x, y)

    local w = self:GetWide()
    local newX = math.Clamp(x / w, 0, 1)
    self.fraction = newX

    self:OnValueChanged(self.fraction)
    self:InvalidateLayout()
  end
  self.grip:SetWide(self.grip.startSize * 2)
end

--[[
min = 30
max = 90
diff = 60

input = 45
calc = (45 - min) / dif
calc = 15 / 60
]]--
function PANEL:SetValue(val)
  self.fraction = ( math.Clamp(val, self:GetMin(), self:GetMax()) - self:GetMin()) / (self:GetMax() - self:GetMin())
  self:InvalidateLayout()
end

function PANEL:OnMousePressed()
  local x, y = self:CursorPos()
  local w = self:GetWide() + (self:GetHeight() * 2)
  local newX = math.Clamp(x / w, 0, 1)

  self.fraction = newX
  self:OnValueChanged(self.fraction)
  self:InvalidateLayout()
end

function PANEL:OnValueChanged(fraction)
end

function PANEL:GetValue()
  return self:GetMin() + self.fraction * (self:GetMax() - self:GetMin())
end


PANEL.AlphaGrip = 0
function PANEL:Paint(w, h)
  local height = self:GetHeight()
  local y = h / 2 - height / 2 

  surface.SetDrawColor(ColorAlpha(self:GetColor(), 50))
  surface.DrawRect(height, y, w - (height * 2), height)

  local width = self.fraction * (w - (self:GetHeight() / 2)) 
  surface.SetDrawColor(self:GetColor())
  surface.DrawRect(height, y, width, height)

  self.AlphaGrip = Lerp(FrameTime() * 5, self.AlphaGrip, self.Pressing && 100 or -1)
  if (self.AlphaGrip > 0) then
    DisableClipping(true)
      local gx, gy = self.grip:GetPos()
      surface.SetFont("XeninUI.SliderText")
      local wide,_ = surface.GetTextSize(math.Round(self:GetValue()))
      wide = wide + 16

      surface.SetDrawColor(26, 26, 26, 255 * (self.AlphaGrip / 100))
      surface.DrawRect(gx + self.grip.startSize / 2 - wide / 2, gy - 42, wide, 32)

      surface.SetDrawColor(255, 255, 255, 25 * (self.AlphaGrip / 100))
      surface.DrawOutlinedRect(gx + self.grip.startSize / 2 - wide / 2, gy - 42, wide, 32)

      draw.SimpleText(math.Round(self:GetValue()), "XeninUI.SliderText", gx + self.grip.startSize / 2, gy - 36, Color( 255, 255, 255, self.AlphaGrip ), TEXT_ALIGN_CENTER)
    DisableClipping(false)
  end
end

function PANEL:PerformLayout(w, h)
  self.grip:SetTall(h)
  self.grip:SetPos(self.fraction * (w - self.grip.size - (self:GetHeight() / 2)))
end

vgui.Register("XeninUI.Slider", PANEL, "DButton")