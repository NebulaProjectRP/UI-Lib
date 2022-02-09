local PANEL = {}
AccessorFunc(PANEL, "bAllowNone", "AllowNone", FORCE_BOOL)
AccessorFunc(PANEL, "bAllowLP", "LocalPlayer", FORCE_BOOL)

function PANEL:Init()
    if IsValid(PLAYER_SEARCH) then
        PLAYER_SEARCH:Remove()
    end
    PLAYER_SEARCH = self
    local x, y = input.GetCursorPos()
    self:SetPos(x, y)
    self:DockPadding(4, 42, 4, 4)
    self:SetSize(256, 228)
    self:SetTitle("")
    self:SetTitle("Select a player")

    self.Search = vgui.Create("nebula.textentry", self)
    self.Search:Dock(TOP)
    self.Search:SetPlaceholderText("Filter...")
    self.Search:SetTall(24)
    self.Search:SetUpdateOnType(true)
    self.Search:DockMargin(4, 0, 4, 0)

    self.Search.OnValueChange = function(s, val)
        self:Open()
    end

    self.List = vgui.Create("nebula.scroll", self)
    self.List:Dock(FILL)
    self.List:DockMargin(4, 8, 4, 4)
    self.List:GetCanvas():DockPadding(2, 2, 2, 2)

    self.List.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)
    end

    self:MakePopup()
end

function PANEL:PaintOver(w, h)
    local x, y = self:ScreenToLocal(gui.MouseX(), gui.MouseY())

    if ((input.IsKeyDown(KEY_TAB) or input.IsMouseDown(MOUSE_LEFT)) and (x < 0 or x > w or y < 0 or y > h)) then
        self:Remove()
    end
end

function PANEL:Populate()
end

function PANEL:OnSelect(val)
end

function PANEL:Open()
    self.List:Clear()
    local players = self:DoFilter()
    local filter = self.Search:GetText()
    if (self:GetAllowNone()) then
        table.insert(players, 1, false)
    end

    local count = 0
    for k, v in pairs(players) do
        if (not self:GetLocalPlayer() and v == LocalPlayer()) then continue end
        if (v) then
            local found = string.find(string.lower(v:Nick()), string.lower(filter or ""), 1, false)
            if (not found) then continue end
        end

        local but = vgui.Create("nebula.button", self.List)
        but:Dock(TOP)
        but:SetTall(28)
        but:SetText(v:Nick())
        but:DockMargin(0, 0, 0, 4)
        but:SetTextColor(v and color_white or Color(125, 125, 125))

        but.DoClick = function()
            self:OnSelect(v)
            self:Remove()
        end
        count = count + 1
    end

    if (count < 5) then
        self:SetTall(82 + count * 32)
        local x, y = self:GetPos()
        local w, h = self:GetSize()
        self:SetPos(math.Clamp(x, 0, ScrW() - w), math.Clamp(y, 0, ScrH() - h))
    end
end

function PANEL:DoFilter()
    local list = {}
    local func = self.Filter
    if (not func) then return player.GetAll() end

    for k, v in pairs(player.GetAll()) do
        if (func(v)) then
            table.insert(list, v)
        end
    end

    return list
end

vgui.Register("nebula.playerselector", PANEL, "nebula.frame")

function PlayerSelector()
    local sel = vgui.Create("nebula.playerselector")

    return sel
end
