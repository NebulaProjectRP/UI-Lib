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

local gr = Material("vgui/gradient-u")
local glow = Material("gui/center_gradient")
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
    //MsgN(self.IsSlot)
    if not self.IsAllow then
        self:SetTooltip(self.Reference.name)
    end

    if (isLocal) then
        self.Item = LocalPlayer():getInventory()[isLocal]
        if (not table.IsEmpty(self.Item.data)) then
            self:SetTooltip(nil)
        end
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
    self.IsAllow = true

    self:SetTooltip(nil)
    self:SetTip(24, Color(255, 0, 0), itemType.Name .. ":\n", 18, Color(150, 150, 150), itemType.Help)

    if (network) then
        self:Receiver("Receiver." .. kind, function(s, dropList, dropped)
            if not dropped then return end

            if (waitingResult) then
                Derma_Message("You have to wait for the item to be authorized!", "Ok")
                //return
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
            if (item.Reference.basic) then
                Derma_Message("You can't equip this item on a slot", "Error", "Ok")
                return
            end

            if (item.Reference.type == "weapon" and item.Reference.rarity == 6) then
                Derma_Message("You cannot slot permanent weapons. Instead click and use them!", "Error", "Ok")
                return
            end

            local data = table.Copy(item.Reference)
            s:SetItem(data.id)

            net.Start("Nebula.Inv:EquipItem")
            if (self.subslot) then
                net.WriteString(kind .. ":" .. self.subslot)
            else
                net.WriteString(kind)
            end
            net.WriteUInt(item.Slot, 16)
            net.WriteBool(true)
            net.SendToServer()
        end)
    end
end

function PANEL:Paint(w, h)
    surface.SetAlphaMultiplier(self:GetBackgroundAlpha() / 255)
    local rarityColor = self.Reference and NebulaInv.Rarities[self.Reference.rarity] or color_white
    if (self.Reference) then
        draw.RoundedBox(4, 0, 0, w, h, rarityColor)
    else
        draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 5))
    end
    surface.SetAlphaMultiplier(1)

    local size = self:IsHovered() and 3 or 1
    draw.RoundedBox(4, size, size, w - size * 2, h - size * 2, Color(24, 15, 29, not self:IsHovered() and 255 or 200))

    local item
    if isnumber(self.isLocal) then
        item = LocalPlayer():getInventory()[self.isLocal]
    elseif (self.IsSlot and self.Reference and NebulaInv.Loadout[self.IsSlot]) then
        item = NebulaInv.Loadout[self.IsSlot]
    end

    if (self.forceInfo) then
        item = self.forceInfo
    end

    if (NebulaInv.Mutators and item and not table.IsEmpty(item.data)) then
        surface.SetDrawColor(ColorAlpha(rarityColor, 40))
        surface.SetMaterial(glow)
        surface.DrawTexturedRectRotated(w / 2, h / 2, w * 2, h * 2, 0)
        if (self:IsHovered()) then
            DisableClipping(true)
                local cw, ch = 350, 32 + 40 * table.Count(item.data)
                local x, y = w / 2 - cw / 2, -ch - 16
                draw.RoundedBox(8, x, y, cw, ch, Color(255, 255, 255, self:IsHovered() and 50 or 15))
                draw.RoundedBox(8, x + 1, y + 1, cw - 2, ch - 2, Color(16, 0, 24, 250))

                draw.SimpleText(self.Reference.name, NebulaUI:Font(32), w / 2, y + 4, rarityColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                surface.SetDrawColor(255, 255, 255, 25)
                surface.DrawRect(x + 8, y + 40, cw - 16, 1)

                local push = 0
                if (item.data.kills) then
                    draw.SimpleText("Kills: " .. item.data.kills, NebulaUI:Font(24), w / 2, y + 44 + push, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                    push = push + 30
                end
                for k, v in pairs(item.data) do
                    if (k != "kills") then
                        local mut = NebulaInv.Mutators[k]
                        local dark = Color(mut.Color.r * .7, mut.Color.g * .7, mut.Color.b * .7)
                        surface.SetDrawColor(dark)
                        surface.DrawRect(x + 2, y + 44 + push, cw - 4, 32)

                        surface.SetDrawColor(mut.Color.r * 1.5, mut.Color.g * 1.5, mut.Color.b * 1.5)
                        surface.SetMaterial(gr)
                        surface.DrawTexturedRect(x + 2, y + 44 + push, cw - 4, 32)

                        local desc = mut:Display(tonumber(v))
                        draw.SimpleText(mut.Name .. " - Level " .. v, NebulaUI:Font(18), x + 8, y + 44 + push + 8, dark, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(mut.Name .. " - Level " .. v, NebulaUI:Font(18), x + 9, y + 45 + push + 8, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(desc, NebulaUI:Font(14), x + 10, y + 45 + push + 23, dark, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText(desc, NebulaUI:Font(14), x + 9, y + 45 + push + 22, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        push = push + 40
                    end
                end
            DisableClipping(false)
        end
    end

    if (self.itemIcon) then
        self.itemIcon(w / 2 - 16, h / 2 - 16, 32, 32, Color(255, 255, 255, 20))
    end
end

function PANEL:PaintOver(w, h)
    if not isnumber(self.isLocal) and not self.forceInfo then
        return
    end
    local item = LocalPlayer():getInventory()[self.isLocal]
    if (self.forceInfo) then
        item = self.forceInfo
    end
    if (item and item.am > 1) then
        draw.SimpleText("x" .. item.am, NebulaUI:Font(24), w - 8, h - 4, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    end
end

vgui.Register("nebula.item", PANEL, "DButton")
