local PANEL = {}
AccessorFunc(PANEL, "m_fBackgroundAlpha", "BackgroundAlpha", FORCE_NUMBER)

function PANEL:Init()
    self:SetText("")
    self.Icon = vgui.Create("nebula.imgur", self)
    self.Icon:Dock(FILL)
    self.Icon:DockMargin(1, 1, 1, 1)
    self.Icon:SetMouseInputEnabled(false)
    self:SetBackgroundAlpha(255)
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
        self.ID = nil
        return    
    end

    self.isLocal = isLocal
    self.Reference = NebulaInv:GetReference(id)
    self.ID = id
    if not self.Reference then
        return false
    end
    self:SetTooltip(self.Reference.name)

    if (isLocal) then
        self.Item = LocalPlayer():getInventory()[id]
    end

    self:Init()
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

function PANEL:Allow(kind, network, group)
    local itemType = NebulaInv.Types[kind]
    if not itemType then
        error("[ItemUI] Invalid item type: " .. kind)
        return
    end

    self.itemIcon = NebulaUI.Derma.Inventory[itemType.Icon]
    self.itemBig = bigicon
    self:SetTip(24, Color(255, 0, 0), itemType.Name .. ":\n", 18, Color(150, 150, 150), itemType.Help)

    if (network) then
        self:Receiver("Receiver." .. kind, function(s, dropList, dropped)
            if not dropped then return end
            local item = dropList[1]
            
            if (group) then
                local occupied = false
                for k, v in pairs(group) do
                    if (item != v and v.ID == item.ID) then
                        occupied = true
                        break
                    end
                end
                if (occupied) then
                    Derma_Message("You already have this item equipped.", "Error", "Ok")
                    return
                end
            end
            if not item.Reference then return end
            local data = table.Copy(item.Reference)
            s:SetItem(item.Reference.id)

            net.Start("Nebula.Inv:EquipItem")
            if (self.subslot) then
                net.WriteString(kind .. ":" .. self.subslot)
            else
                net.WriteString(kind)
            end
            net.WriteString(item.Reference.id)
            net.WriteBool(true)
            net.SendToServer()

            item:SetItem(nil)
        end)
    end
end


function PANEL:Paint(w, h)
    surface.SetAlphaMultiplier(self:GetBackgroundAlpha() / 255)
    if (self.Reference) then
        draw.RoundedBox(4, 0, 0, w, h, NebulaInv.Rarities[self.Reference.rarity])
    else
        draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 5))
    end
    surface.SetAlphaMultiplier(1)

    draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(24, 15, 29, 150))
    if (self.itemIcon) then
        self.itemIcon(w / 2 - 16, h / 2 - 16, 32, 32, Color(255, 255, 255, 20))
    end
end

function PANEL:PaintOver(w, h)
    if (self.Item) then
        local count = self.isLocal and LocalPlayer():getInventory()[self.ID] or 1
        if (count > 1) then
            draw.SimpleText("x" .. count, NebulaUI:Font(20), w - 4, h - 0, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        end
    end
end

vgui.Register("nebula.item", PANEL, "DButton")