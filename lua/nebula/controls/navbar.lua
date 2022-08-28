XeninUI:CreateFont("XeninUI.Navbar.Button", 25)

local PANEL = {}

function PANEL:Init()
	self.buttons = {}
	self.panels = {}

	self.active = 0
end

function PANEL:CanSelect(name)
    return true
end

function PANEL:OnTabSelected(name, panel)
end

function PANEL:AddTab(name, panel, weight)
	self.buttons[name] = vgui.Create("DButton", self)
	self.buttons[name]:Dock(LEFT)
	self.buttons[name]:SetText(name)
	self.buttons[name].weight = weight
	self.buttons[name]:SetFont(NebulaUI:Font(20))
	self.buttons[name].lineWidth = 0
	self.buttons[name].textColor = Color(120, 120, 120)
	self.buttons[name].Paint = function(pnl, w, h)
		surface.SetDrawColor(XeninUI.Theme.Accent)
		surface.DrawRect(w / 2 - pnl.lineWidth / 2, h - 2, pnl.lineWidth, 2)

		pnl:SetTextColor(pnl.textColor)
	end
	self.buttons[name].DoClick = function(pnl)
		self:OnTabSelected(name, self.panels[self.active])
		self:SetActive(name)
	end
	self.buttons[name].OnCursorEntered = function(pnl)
		pnl:LerpColor("textColor", XeninUI.Theme.Accent)
	end
	self.buttons[name].OnCursorExited = function(pnl)
		if (self.active == name) then return end
		
		pnl:LerpColor("textColor", Color(120, 120, 120))
	end

	surface.SetFont(NebulaUI:Font(20))
	local tw, th = surface.GetTextSize(name)
	self.buttons[name]:SetWide(math.max(80, tw + 60))

	if (!panel) then panel = "Panel" end

	self.panels[name] = vgui.Create(panel, self.body)
	self.panels[name]:Dock(FILL)
	self.panels[name]:SetVisible(false)
end

function PANEL:PerformLayout(w, h)
	local buttonWeight = {}
	surface.SetFont(NebulaUI:Font(20))
	for k,v in pairs(self.buttons) do
		local tx, _ = surface.GetTextSize(k)
		v:SetWide(v.weight and w * v.weight or math.max(80, tx + 60))
	end

end

function PANEL:SetActive(name)
	if (!self:CanSelect(name)) then return end

	if (self.buttons[self.active]) then
		self.buttons[self.active]:LerpColor("textColor", Color(120, 120, 120))
		self.buttons[self.active]:Lerp("lineWidth", 0)
	end

	if (self.panels[self.active]) then
		self.panels[self.active]:SetVisible(false)
	
		if (self.panels[name].OnSwitchedFrom) then
			self.panels[name]:OnSwitchedFrom()
		end
	end

	self.active = name
	
	if (self.buttons[name]) then
		self.buttons[name]:LerpColor("textColor", XeninUI.Theme.Accent)
		self.buttons[name]:Lerp("lineWidth", self.buttons[name]:GetWide())
	end

	if (self.panels[name]) then
		self.panels[name]:SetVisible(true)

		if (self.panels[name].OnSwitchedTo) then
			self.panels[name]:OnSwitchedTo(name)
		end
	end
end

function PANEL:SetBody(pnl)
	self.body = pnl
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(XeninUI.Theme.Navbar)
	surface.DrawRect(0, 0, w, h)
end


vgui.Register("XeninUI.Navbar", PANEL)