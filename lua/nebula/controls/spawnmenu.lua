local styleMenuConVar = CreateClientConVar("nebula_spawnmenu", "1", true, false, "Style the spawnmenu to NebulaRP")

local prohibitedCategories = NebulaUI.ProhibitedCategories
local prohibitedTools = NebulaUI.ProhibitedTools
local back = Color(34, 1, 51, 225)
local function stylish(panel)
    local isAllowed = NebulaUI.SpawnmenuAdmin[LocalPlayer():GetUserGroup()]
    local tools = panel.ToolMenu

    if (styleMenuConVar:GetBool()) then
        tools.Paint = function(s, w, h)
            draw.RoundedBox(8, 0, 17, w, h - 16, Color(255, 255, 255, (s:IsHovered() or s:IsChildHovered()) and 100 or 25))
            draw.RoundedBox(8, 1, 18, w - 2, h - 19, Color(20, 0, 32))
        end
    end

    for name, v in pairs(tools.ToolPanels) do
        if (styleMenuConVar:GetBool()) then
            v.List.Paint = function(s, w, h)
                draw.RoundedBox(8, 0, 17, w, h - 16, Color(255, 255, 255, 10))
                draw.RoundedBox(8, 1, 18, w - 2, h - 19, back)
            end
        end

        if (styleMenuConVar:GetBool()) then
            v.PropertySheetTab:SetFont(NebulaUI:Font(12))
            v.PropertySheetTab:SetContentAlignment(7)
            v.PropertySheetTab:SetTextInset(0, 0)
            v.PropertySheetTab.Paint = function(s, w, h)
                draw.RoundedBoxEx(8, 0, 0, w - 8, 18, Color(255, 255, 255, (s:IsHovered() or s:IsChildHovered()) and 100 or 25), true, true, false, false)
                draw.RoundedBoxEx(8, 1, 1, w - 10, 18 - 2, back, true, true, false, false)
            end
        end

        for _, p in pairs(v.List:GetCanvas():GetChildren()) do
            if (not isAllowed and prohibitedCategories[p.Header:GetText()]) then
                p:Remove()
                continue
            end

            for k, tool in pairs(p:GetChildren()) do
                if (!isfunction(tool.Command) and not isAllowed and prohibitedTools[tool.Command]) then
                    tool:Remove()
                    continue
                end

                if (styleMenuConVar:GetBool()) then
                    tool:SetTextColor(color_white)
                    tool:SetTall(24)
                    tool:SetFont(NebulaUI:Font(15))
                    tool.Paint = function(s, w, h)
                        if (s.m_bSelected) then
                            draw.RoundedBox(4, 0, 0, w, h, Color(229, 100, 255, 45))
                        end
                    end
                end
            end
        end
    end

    local create = panel.CreateMenu

    if (styleMenuConVar:GetBool()) then
        create.Paint = function(s, w, h)
            draw.RoundedBox(8, 0, 17, w, h - 16, Color(255, 255, 255, (s:IsHovered() or s:IsChildHovered()) and 25 or 5))
            draw.RoundedBox(8, 1, 18, w - 2, h - 19, back)
        end
    end

    local function removeCategories(group)
        local tab = create.CreationTabs["#spawnmenu.category." .. group]

        if not tab then return end
        if IsValid(tab.Tab) then
            tab.Tab:Remove()
        end
        if IsValid(tab.Panel) then
            tab.Panel:Remove()
        end

        create.Items["#spawnmenu.category." .. group] = nil
    end

    if not isAllowed then
        removeCategories("entities")
        removeCategories("npcs")
        removeCategories("saves")
        removeCategories("vehicles")
        removeCategories("weapons")
    end
    if (styleMenuConVar:GetBool()) then
        create.PerformLayout = function(self, w, h)
            local ActiveTab = self:GetActiveTab()
            local Padding = self:GetPadding()

            if not IsValid( ActiveTab ) then return end

            -- Update size now, so the height is definitiely right.
            ActiveTab:InvalidateLayout( true )

            --self.tabScroller:StretchToParent( Padding, 0, Padding, nil )
            self.tabScroller:SetTall( ActiveTab:GetTall() )

            local ActivePanel = ActiveTab:GetPanel()
            local lastPos = 0
            for k, v in pairs( self.Items ) do
                if not IsValid(v.Tab) then
                    self.Items[k] = nil
                    continue
                end

                v.Tab:Dock(NODOCK)
                if ( IsValid(v.Tab) and v.Tab:GetPanel() == ActivePanel ) then

                    if ( IsValid( v.Tab:GetPanel() ) ) then v.Tab:GetPanel():SetVisible( true ) end
                    v.Tab:SetZPos( 100 )

                else

                    if ( IsValid( v.Tab:GetPanel() ) ) then v.Tab:GetPanel():SetVisible( false ) end
                    v.Tab:SetZPos( 1 )

                end

                surface.SetFont(NebulaUI:Font(16))
                local tx, _ = surface.GetTextSize(v.Tab:GetText())

                v.Tab:SetWide(tx + 38)
                v.Tab:SetTextInset(24, 0)
                v.Tab:SetPos(lastPos, 0)
                lastPos = lastPos + v.Tab:GetWide() + 12
            end

            self.tabScroller:SetWide(lastPos + 32)

            if IsValid( ActivePanel ) then
                if not ActivePanel.NoStretchX then
                    ActivePanel:SetWide( self:GetWide() - Padding * 2 )
                else
                    ActivePanel:CenterHorizontal()
                end

                if not ActivePanel.NoStretchY then
                    local _, y = ActivePanel:GetPos()
                    ActivePanel:SetTall( self:GetTall() - y - Padding )
                else
                    ActivePanel:CenterVertical()
                end

                ActivePanel:InvalidateLayout()
            end

        end

        for k, v in pairs(create.CreationTabs) do
            if IsValid(v.Tab) then
                v.Tab:SetFont(NebulaUI:Font(16))
                v.Tab.Paint = function(s, w, h)
                    draw.RoundedBoxEx(8, 0, 0, w - 4, h, Color(255, 255, 255, (s:IsHovered() or s:IsChildHovered()) and 25 or 5), true, true, false, false)
                    draw.RoundedBoxEx(8, 1, 0, w - 6, h - 2, back, true, true, false, false)
                end
            end
        end
    end

    local creationTab = create.CreationTabs["#spawnmenu.content_tab"].Panel
    local sidebar = creationTab:GetChildren()[1].ContentNavBar
    
    if (styleMenuConVar:GetBool()) then
        sidebar.Tree.Paint = function(s, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, (s:IsHovered() or s:IsChildHovered()) and 25 or 5))
            draw.RoundedBox(8, 1, 0, w - 2, h - 2, Color(20, 0, 32))
        end
    end

    local function recurse(children)
        for k, v in pairs(children) do
            v.Label.UpdateColours = function( self, skin )

                if ( self:GetBright() ) then return self:SetTextStyleColor( color_white ) end
                if ( self:GetDark() ) then return self:SetTextStyleColor( color_white ) end
                if ( self:GetHighlight() ) then return self:SetTextStyleColor( color_white ) end

                return self:SetTextStyleColor( color_white )
            end
            v.Label:SetFontInternal(NebulaUI:Font(16))
            -- v.Label:SetTextColor(color_white)
            if (v.ChildNodes and #v.ChildNodes:GetChildren() > 0) then
                recurse(v.ChildNodes:GetChildren())
            else
                v.Label:SetFontInternal(NebulaUI:Font(15))
            end
            v.Label:ApplySchemeSettings()
        end
    end

    if (styleMenuConVar:GetBool()) then
        recurse(sidebar.Tree.RootNode.ChildNodes:GetChildren())
    end
end

hook.Add("OnSpawnMenuOpen", "Nebula.SpawnReskin", function()
    stylish(g_SpawnMenu)
end)
cvars.AddChangeCallback("nebula_spawnmenu", function()
    RunConsoleCommand("spawnmenu_reload")
end)