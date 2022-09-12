local PANEL = {}
AccessorFunc(PANEL, "m_bgWidth", "BackgroundWidth")
AccessorFunc(PANEL, "m_bgHeight", "BackgroundHeight")

function PANEL:Init()
    self.background = vgui.Create("nebula.frame", self)
    self.background.OnRemove = function()
      self:Remove()
    end
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(20, 20, 20, 160)
    surface.DrawRect(0, 0, w, h)
end

function PANEL:PerformLayout(w, h)
    if not IsValid(self.background) then return end
    //if not IsValid(self) then return end
    self.background:SetSize(self:GetBackgroundWidth(), self:GetBackgroundHeight())
    self.background:Center()
end

function PANEL:SetTitle(str)
    self.background:SetTitle(str)
end

function PANEL:OnRemove()
  if IsValid(self.background) then
    self.background:Remove()
  end
end

vgui.Register("XeninUI.Popup", PANEL, "EditablePanel")
