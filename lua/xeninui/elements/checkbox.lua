local PANEL = {}

XeninUI:CreateFont("XeninUI.Checkbox", 16)
XeninUI:CreateFont("XeninUI.Checkbox.Small", 15)

function PANEL:Init()
  self:SetText("")
  self.state = nil

  self.barPos = 0

  self.offText = "OFF"
  self.onText = "ON"
  self.font = "XeninUI.Checkbox"
end

function PANEL:Paint(w, h)
  surface.SetDrawColor(Color(0, 0, 0, 150))
  surface.DrawRect(0, 0, w, h)

  self.barPos = self.barPos + ((self.state and 1 or 0) - self.barPos) * 8 * FrameTime()

  local offColor = Color(self.barPos * 200, self.barPos * 200, self.barPos * 200)
  local onColor = Color(200 - (self.barPos * 200), 200 - (self.barPos * 200), 200 - (self.barPos * 200))

  surface.SetDrawColor(Color(200, 200, 200))
  surface.DrawRect(math.Clamp(self.barPos * ((w + 4) / 2), 2, w / 2), 2, (w - 4) / 2, h - 4)

  draw.SimpleText(self.offText, self.font, w / 4, h / 2, offColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  draw.SimpleText(self.onText, self.font, w / 2 + w / 4, h / 2, onColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function PANEL:DoClick()
  self:SetState(!self:GetState())
end

function PANEL:SetConVar(cvar)
  self.cv = GetConVar(cvar)
  self:SetState(self.cv:GetBool(), true)
end

function PANEL:OnStateChanged()
  if (self.cv) then
    self.cv:SetBool(self.state)
  end
end

function PANEL:GetState()
  return self.state
end

function PANEL:SetState(state, instant)
  self.state = state

  self:OnStateChanged(state, instant)

  if (instant) then
    self.barPos = state and 1 or 0
  end
end

function PANEL:SetStateText(off, on)
  self.offText = off
  self.onText = on
end

vgui.Register("XeninUI.Checkbox", PANEL, "DButton")