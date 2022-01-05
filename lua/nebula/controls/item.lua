local PANEL = {}

function PANEL:Init()
    self.Icon = vgui.Create("nebula.imgur", self)
    self.Icon:Dock(FILL)
end

function PANEL:SetItem(id, isLocal)
    self.isLocal = isLocal
    if (string.StartWith(id, "unique_")) then
        id = tonumber(string.Explode("_", id)[2])
        MsgN(id)
    end
    self.Reference = NebulaInv.Items[id]

    if (isLocal) then
        self.Item = LocalPlayer():getInventory()[id]
    end

    if (self.Reference.type == "model") then
        self.Icon:Remove()
        self.model = vgui.Create("DModelPanel", self)
        self.model:SetModel(self.Reference.model)
        self.model:Dock(FILL)
    else
        self.Icon:SetImage(self.Reference.id)
    end
end

function PANEL:Allow(kind)
end


function PANEL:Paint(w, h)
    if (self.Reference) then
        draw.RoundedBox(4, 0, 0, w, h, NebulaInv.Rarities[self.Reference.rarity])
    else
        draw.RoundedBox(4, 0, 0, w, h, Color(75, 75, 75, 200))
    end

    draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(235, 235, 235, 50))
end

vgui.Register("nebula.item", PANEL, "DPanel")