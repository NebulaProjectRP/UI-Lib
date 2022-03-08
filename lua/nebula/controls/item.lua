local PANEL = {}

function PANEL:Init()
    self:SetText("")
    self.Icon = vgui.Create("nebula.imgur", self)
    self.Icon:Dock(FILL)
    self.Icon:DockMargin(1, 1, 1, 1)
    self.Icon:SetMouseInputEnabled(false)
end

function PANEL:SetItem(id, isLocal)
    if (id == nil) then
        if (IsValid(self.Icon)) then
            self.Icon:Remove()
        elseif (IsValid(self.model)) then
            self.model:Remove()
        end
        self:SetTooltip(nil)
        self.Reference = nil
        return    
    end

    self.isLocal = isLocal
    if (string.StartWith(id, "unique_")) then
        id = tonumber(string.Explode("_", id)[2])
    end
    self.Reference = NebulaInv.Items[id]
    if not self.Reference then
        return false
    end
    self:SetTooltip(self.Reference.name)

    if (isLocal) then
        self.Item = LocalPlayer():getInventory()[id]
    end

    if (self.Reference.type == "model") then
        self.Icon:Remove()
        self.model = vgui.Create("DModelPanel", self)
        self.model:SetModel(self.Reference.model)
        self.model:Dock(FILL)
    else
        self.Icon:SetImage(self.Reference.icon)
    end

    return true
end

function PANEL:Allow(kind, network)
    local itemType = NebulaInv.Types[kind]
    if not itemType then
        error("[ItemUI] Invalid item type: " .. kind)
        return
    end

    self.itemIcon = NebulaUI.Derma.Inventory[itemType.Icon]
    self.itemBig = bigicon
    self:SetTooltip(itemType.Name .. ":\n" .. itemType.Help)

    if (network) then
        self:Receiver("Receiver." .. kind, function(s, dropList, dropped)
            if not dropped then return end
            local item = dropList[1]
            
            if not item.Reference then return end
            local data = table.Copy(item.Reference)
            s:SetItem(item.Reference.id)
            item:SetItem(nil)

            net.Start("Nebula.Inv:EquipItem")
            net.WriteString(kind)
            net.WriteString(item.Reference.id)
            net.WriteBool(true)
            net.SendToServer()
        end)
    end
end


function PANEL:Paint(w, h)
    if (self.Reference) then
        draw.RoundedBox(4, 0, 0, w, h, NebulaInv.Rarities[self.Reference.rarity])
    else
        draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 5))
    end

    draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(24, 15, 29, 150))
    if (self.itemIcon) then
        self.itemIcon(w / 2 - 16, h / 2 - 16, 32, 32, Color(255, 255, 255, 20))
    end
end

vgui.Register("nebula.item", PANEL, "DButton")