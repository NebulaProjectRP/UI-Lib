local PANEL = {}

function PANEL:Init()
    if IsValid(PLAYER_SEARCH) then
        PLAYER_SEARCH:Remove()
    end

    PLAYER_SEARCH = self
    local x, y = input.GetCursorPos()
    local tall = math.max(ScrH() - y - 32, 400)
    self:SetPos(x, math.min(y, ScrH() - tall -  32))
    self:SetSize(512, tall)
    self:SetTitle("")
    self:SetTitle("Search an Item...")
    self.Search = vgui.Create("nebula.textentry", self)
    self.Search:Dock(TOP)
    self.Search:SetTall(32)
    self.Search:SetPlaceholder("Bananas!")
    self.Search:SetUpdateOnType(true)
    self.Search:DockMargin(8, 8, 8, 0)

    self.Search.OnValueChange = function(s, val)
        self:Populate(val)
    end

    self.List = vgui.Create("nebula.scroll", self)
    self.List:Dock(FILL)
    self.List:DockMargin(8, 8, 10, 10)
    self.List:GetCanvas():DockPadding(2, 2, 2, 2)

    self.List.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)
    end

    self.Grid = vgui.Create("DIconLayout", self.List)
    self.Grid:Dock(FILL)
    self.Grid:SetSpaceX(8)
    self.Grid:SetSpaceY(8)

    self:SetScreenLock(true)
    self:SetMinHeight(800)
    self:MakePopup()
end

function PANEL:Open()
    self:Populate()
end

function PANEL:PaintOver(w, h)
    local x, y = self:ScreenToLocal(gui.MouseX(), gui.MouseY())

    if ((input.IsKeyDown(KEY_TAB) or input.IsMouseDown(MOUSE_LEFT)) and (x < 0 or x > w or y < 0 or y > h)) then
        self:Remove()
    end
end

function PANEL:OnItemSelected(k, v)
end

function PANEL:Filter(item, slot)
    return true
end

local noitem = Material("asap_printers/noaccess.png")
function PANEL:Populate(filter)
    self.Grid:Clear()

    local cancel = vgui.Create("DButton", self.Grid)
    cancel:SetSize(96, 96)
    cancel:SetText("")
    cancel.Paint = function(s, w, h)
        draw.SimpleText("(X)", NebulaUI:Font(32), w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    cancel.DoClick = function()
        self:OnItemSelected()
        self:Remove()
    end

    for k, v in pairs(LocalPlayer():getInventory()) do
        if not NebulaInv.Items[v.id] then continue end
        if (self:Filter(v.id, k) == false) then continue end
        local name = NebulaInv.Items[v.id].name
        local found = string.find(string.lower(name), string.lower(filter or ""), 1, false)
        if not found then continue end
        local item = vgui.Create("nebula.item", self.Grid)
        item:SetSize(96, 96)
        item:SetItem(v.id)
        item.forceInfo = {
            id = v.id,
            am = v.am,
            data = v.data
        }

        item.DoClick = function()
            self:OnItemSelected(v.id, v, k)
            self:Remove()
        end
    end

    self:SetScreenLock(true)
end

vgui.Register("nebula.itempicker", PANEL, "nebula.frame")

function ItemPicker()
    local sel = vgui.Create("nebula.itempicker")

    return sel
end