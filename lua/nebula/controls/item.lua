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
    self.Reference = NebulaInv.Items[id]
    self.ID = id
    if not self.Reference then
        return false
    end
    self:SetTooltip(self.Reference.name)

    if (isLocal) then
        self.Item = LocalPlayer():getInventory()[isLocal]
    end

    self:Init()
    if (self.Reference.type == "model") then
        self.Icon:Remove()
        self.model = vgui.Create("DModelPanel", self)
        self.model:SetModel(self.Reference.model)
        self.model:SetMouseInputEnabled(false)
        self.model:Dock(FILL)
    elseif (self.Reference.imgur) then
        self.Icon:SetImage(self.Reference.imgur)
    elseif (self.Reference.icon) then
        self.Icon.Material = Material(self.Reference.icon)
        self.Icon.HasImage = true
    end

    return true
end

local waitingResult = false
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

            if (waitingResult) then
                Derma_Message("You have to wait for the item to be authorized!", "Ok")
                return
            end

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
            s:SetItem(data.id)
            MsgN(data.id)

            net.Start("Nebula.Inv:EquipItem")
            if (self.subslot) then
                net.WriteString(kind .. ":" .. self.subslot)
            else
                net.WriteString(kind)
            end
            net.WriteUInt(item.Slot, 16)
            net.WriteBool(true)
            net.SendToServer()

            waitingResult = item.Slot
            item:SetItem(nil)
        end)
    end
end

function PANEL:Paint(w, h)
    surface.SetAlphaMultiplier(self:GetBackgroundAlpha() / 255)
    if (self.Reference) then
        draw.RoundedBox(4, 0, 0, w, h, NebulaInv.Rarities[self.Reference.rarity or 1])
    else
        draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 5))
    end
    surface.SetAlphaMultiplier(1)

    local size = self:IsHovered() and 3 or 1
    draw.RoundedBox(4, size, size, w - size * 2, h - size * 2, Color(24, 15, 29, not self:IsHovered() and 255 or 200))
    if (self.itemIcon) then
        self.itemIcon(w / 2 - 16, h / 2 - 16, 32, 32, Color(255, 255, 255, 20))
    end
end

function PANEL:PaintOver(w, h)
    //MsgN(self.Item)
    if (self.Reference and self.Item) then
        local count = self.isLocal and self.Item.am or 1
        if (count > 1) then
            draw.SimpleText("x" .. count, NebulaUI:Font(24), w - 8, h - 4, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        end
    end
end

vgui.Register("nebula.item", PANEL, "DButton")

net.Receive("Nebula.Inv:EquipResult", function()
    local result = net.ReadBool()
    if (result) then
        table.remove(NebulaInv.Inventory, waitingResult)
    end
    waitingResult = false
end)