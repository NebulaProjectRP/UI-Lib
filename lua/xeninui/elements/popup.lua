local PANEL = {}

AccessorFunc(PANEL, "m_bgWidth", "BackgroundWidth")
AccessorFunc(PANEL, "m_bgHeight", "BackgroundHeight")

function PANEL:Init()
  self.background = vgui.Create("nebula.frame", self)
end

function PANEL:Paint(w, h)
  surface.SetDrawColor(20, 20, 20, 160)
  surface.DrawRect(0, 0, w, h)
end

function PANEL:PerformLayout(w, h)
  self.background:SetSize(
    self:GetBackgroundWidth(),
    self:GetBackgroundHeight()
  )
  self.background:Center()
end

function PANEL:SetTitle(str)
  self.background:SetTitle(str)
end

vgui.Register("XeninUI.Popup", PANEL, "EditablePanel")