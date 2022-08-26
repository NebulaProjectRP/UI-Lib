local PANEL = {}

function PANEL:Init()
  self.onAccept = function() end
  self.onDecline = function() end

  self.background.text = self.background:Add("DLabel")
  self.background.text:SetText("XD")
  self.background.text:SetFont(NebulaUI:Font(18))
  self.background.text:SetContentAlignment(8)
  self.background.text:SetTextColor(Color(200, 200, 200))

  self.background.accept = self.background:Add("DButton")
  self.background.accept:SetText("Accept")
  self.background.accept:SetFont(NebulaUI:Font(18))
  self.background.accept:SetTextColor(Color(21, 21, 21))
  self.background.accept.Paint = function(pnl, w, h)
    draw.RoundedBox(6, 0, 0, w, h, XeninUI.Theme.Green)
  end
  self.background.accept.DoClick = function(pnl)
    self:onAccept(pnl)
    self:Remove()
  end

  self.background.decline = self.background:Add("DButton")
  self.background.decline:SetText("Decline")
  self.background.decline:SetFont(NebulaUI:Font(18))
  self.background.decline:SetTextColor(Color(145, 145, 145))
  self.background.decline.Paint = function(pnl, w, h)
    draw.RoundedBox(6, 0, 0, w, h, XeninUI.Theme.Navbar)
    draw.RoundedBox(6, 2, 2, w - 4, h - 4, XeninUI.Theme.Background)
  end
  self.background.decline.DoClick = function(pnl)
    self:onDecline(pnl)
    self:Remove()
  end
end

function PANEL:PerformLayout(w, h)
  surface.SetFont(self.background.text:GetFont())
  local tw = surface.GetTextSize(self.background.text:GetText())
  self:SetBackgroundWidth(tw + 32)

  self.BaseClass.PerformLayout(self, w, h)

  self.background.text:SetWide(self.background:GetWide())
  self.background.text:SizeToContentsY()
  self.background.text:SetPos(0, 56)

  local y = self.background:GetTall() - self.background.accept:GetTall() - 16
  self.background.accept:SizeToContentsX(32)
  self.background.accept:SizeToContentsY(16)
  self.background.decline:SizeToContentsX(32)
  self.background.decline:SizeToContentsY(16)

  self.background.accept:SetPos(self.background:GetWide() / 2 - self.background.accept:GetWide() - 4, y)
  self.background.decline:SetPos(self.background:GetWide() / 2 + 4, y)
end

function PANEL:SetText(text)
  self.background.text:SetText(text)
end

function PANEL:SetAccept(text, func)
  self.background.accept:SetText(text)
  self.onAccept = func
end

function PANEL:SetDecline(text, func)
  self.background.decline:SetText(text)
  self.onDecline = func
end

vgui.Register("XeninUI.Query", PANEL, "XeninUI.Popup")