local PANEL = {}

function PANEL:Init()
    self:DockPadding(16, 48, 16, 16)
    self.lblTitle:SetFont(NebulaUI:Font(28))
    self.btnMinim:Remove()
    self.btnMaxim:Remove()

    self.btnClose.Paint = function(s, w, h)
        draw.SimpleText("✕", NebulaUI:Font(s:IsHovered() and 28 or 24), w / 2, h / 2, Color(255, 255, 255, s:IsHovered() and 255 or 100), 1, 1)
    end
end

local purple = Color(16, 0, 24, 250)
local lightWhite = Color(255, 255, 255, 25)
function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, self.Dragging and 100 or 25))
    draw.RoundedBox(8, 1, 1, w - 2, h - 2, purple)

    surface.SetDrawColor(255, 255, 255, 5)
    surface.DrawRect(8, 32, w - 16, 1)
end

function PANEL:SetGrid(x, y)
    if IsValid(self.Grid) then return end

    self.Grid = vgui.Create("nebula.grid", self)
    self.Grid:Dock(FILL)
    self.Grid:SetGrid(x, y)
end

function PANEL:OnChildAdded(pnl)
    if IsValid(self.Grid) then
        pnl:SetParent(self.Grid)
    end
end

function PANEL:PerformLayout(w, h)
    self.lblTitle:SetSize(w - 32, 28)
    self.lblTitle:SetPos(8, 2)

    self.btnClose:SetSize(28, 28)
    self.btnClose:SetPos(w - 32, 2)
    self.btnClose:SetZPos(999)
end

vgui.Register("nebula.frame", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
    self:DockPadding(8, 8, 8, 8)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, lightWhite)
    draw.RoundedBox(8, 1, 1, w - 2, h - 2, pruple)
end

function PANEL:SetGrid(x, y)
    if IsValid(self.Grid) then return end

    self.Grid = vgui.Create("nebula.grid", self)
    self.Grid:Dock(FILL)
    self.Grid:SetGrid(x, y)
end

vgui.Register("nebula.panel", PANEL, "DFrame")

local SCROLL = {}

local lightWhite = Color(255, 255, 255, 15)
local darkPurple = Color(8, 0, 12)
local buttonBase = Color(16, 0, 24)
local buttonBaseHover = Color(63, 10, 90)
function SCROLL:Init()
    local sbar = self:GetVBar()
    sbar:SetWide(20)
    function sbar:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, darkPurple)
    end
    function sbar.btnUp:Paint(w, h)
        draw.RoundedBoxEx(4, 0, 0, w, h, lightWhite, true, true, false, false)
        draw.RoundedBox(4, 1, 1, w - 2, h - 2, self:IsHovered() and buttonBaseHover or buttonBase)
    end
    function sbar.btnDown:Paint(w, h)
        draw.RoundedBoxEx(4, 0, 0, w, h, lightWhite, false, false, true, true)
        draw.RoundedBox(4, 1, 1, w - 2, h - 2, self:IsHovered() and buttonBaseHover or buttonBase)
    end
    sbar.btnGrip:SetCursor("hand")
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBoxEx(4, 0, 0, w, h, lightWhite, false, false, true, true)
        draw.RoundedBox(4, 1, 1, w - 2, h - 2, (self:IsHovered() or self.Depressed) and buttonBaseHover or buttonBase)
    end
end

function SCROLL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, lightWhite)
    draw.RoundedBox(8, 1, 1, w - 2, h - 2, purple)
end

vgui.Register("nebula.scroll", SCROLL, "DScrollPanel")
vgui.Register("nebula.scrollpanel", SCROLL, "DScrollPanel")
vgui.Register("XeninUI.Scrollpanel.Wyvern", SCROLL, "DScrollPanel")

local FORM = {}
AccessorFunc(FORM, "m_sTitle", "Title", FORCE_STRING)

function FORM:Init()
    self:GetCanvas():DockPadding(16, 16, 16, 16)
end

function FORM:SetTitle(title)
    self.m_sTitle = title
    self:GetCanvas():DockPadding(16, title != "" and 48 or 16, 16, 16)
end

function FORM:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, lightWhite)
    draw.RoundedBox(8, 1, 1, w - 2, h - 2, purple)
    draw.SimpleText(self:GetTitle(), NebulaUI:Font(20), w / 2, 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    if (self.m_sTitle) then
        surface.SetDrawColor(255, 255, 255, 5)
        surface.DrawRect(8, 32, w - 16, 1) 
    end
end

function FORM:AddElement(name, vguielement)
    local label = vgui.Create("DLabel", self)
    label:SetFont(NebulaUI:Font(16))
    label:Dock(TOP)
    label:SetText(name)

    local element = vgui.Create(vguielement, self)
    element:Dock(TOP)
    element:DockMargin(0, 4, 0, 8)
    if (vguielement == "nebula.textentry") then
        element:SetTall(24)
    end

    return element, label
end

function FORM:AddSpace(tall)
    local space = vgui.Create("Panel", self)
    space:Dock(TOP)
    space:SetTall(tall or 4)

    return space
end

function FORM:AddLabel(text, size)
    size = size or 16
    local label = vgui.Create("DLabel", self)
    label:Dock(TOP)
    label:SetFont(NebulaUI:Font(size))
    label:SetTall(size + 4)
    label:SetText(text)

    return label
end

vgui.Register("nebula.form", FORM, "DScrollPanel")