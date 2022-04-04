
local top = surface.GetTextureID("nebularp/ui/sb_logo")
local gr = surface.GetTextureID("vgui/gradient-r")
local PANEL = {}

local money_color = Color(48, 187, 55)
local lightWhite = Color(255, 255, 255, 50)

local branding_icons = {}
local branding_atlas = Material("nebularp/ui/branding")
for k = 1, 4 do
    branding_icons[k] = GWEN.CreateTextureNormal((k - 1) * 64, 0, 64, 64, branding_atlas)
end

local branding = {
    [1] = {
        Name = "Discord",
        Link = "https://discord.gg/NebulaRP",
    },
    [2] = {
        Name = "Steam",
        Link = "https://discord.gg/NebulaRP",
    },
    [3] = {
        Name = "Website",
        Link = "https://discord.gg/NebulaRP",
    }
}
function PANEL:Init()
    NebulaUI.Scoreboard = self
    self:SetSize(ScrW() * .7, ScrH() * .7)
    self:DockPadding(0, 32, 0, 0)
    self:Center()
    self:CenterVertical(.475)
    self:SetTitle("")
    self.Title = vgui.Create("DImage", self)
    self.Title:SetSize(256, 64)
    self.Title:AlignLeft(-16)
    self.Title:AlignTop(4)
    self.Title:SetImage("nebularp/ui/sb_text")

    self.Foot = vgui.Create("DPanel", self)
    self.Foot:SetTall(64)
    self.Foot:Dock(BOTTOM)
    local timerName = LocalPlayer():SteamID64() .. "jobtimer"
    self.Foot.Paint = function(s, w, h)
        NebulaUI.Derma.ScoreBack(0, 0, w, h)
        surface.SetDrawColor(195 * .5, 0, 202 * .5, 75)
        surface.SetTexture(gr)
        surface.DrawTexturedRect(0, 0, w, h)

        local tx, ty = draw.SimpleText(team.GetName(LocalPlayer():Team()), NebulaUI:Font(38, true), 8, 4, color_white)
        draw.SimpleText(DarkRP.formatMoney(LocalPlayer():getDarkRPVar("salary")), NebulaUI:Font(46, true), 8 + tx + 8, 8, money_color)
        surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(8, 4 + ty + 4, tx, 10)

        if (timer.Exists(timerName)) then
            local left = math.Clamp(1 - timer.TimeLeft(timerName) / GAMEMODE.Config.paydelay, 0, 1)
            surface.SetDrawColor(color_white)
            surface.DrawRect(9, 5 + ty + 4, (tx - 2) * left, 8)
        end
        
        draw.SimpleText(player.GetCount() .. "/" .. game.MaxPlayers(), NebulaUI:Font(46, true), w - 8, 8, lightWhite, TEXT_ALIGN_RIGHT)
    end

    for k = 1, 3 do
        local icon = vgui.Create("DButton", self.Foot)
        icon:AlignLeft(self:GetWide() / 3 + 96 * k)
        icon:SetSize(58, 58)
        icon:SetText("")
        icon.Paint = function(s, w, h)
            branding_icons[k](0, 0, w, h, Color(255, 255, 255, s:IsHovered() and 255 or 175))
        end
        icon:SetTooltip(branding[k].Name)
        icon.DoClick = function()
            gui.OpenURL(branding[k].Link)
        end
    end

    self.Body = vgui.Create("DPanel", self)
    self.Body:Dock(FILL)
    self.Body:DockMargin(16, 42, 16, 24)
    self.Body.Paint = function(s, w, h)
        NebulaUI.Derma.ScoreBack(0, 0, w, h)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.SetTexture(gr)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    self.Search = vgui.Create("nebula.textentry", self.Body)
    self.Search:Dock(TOP)
    self.Search:SetTall(32)
    self.Search:DockMargin(8, 8, 8, 8)
    self.Search.OnValueChange = function(s)
        self:FillPlayers()
    end

    self.List = vgui.Create("nebula.scroll", self.Body)
    self.List:Dock(FILL)
    self.List:DockMargin(8, 0, 8, 8)

    self:FillPlayers()
    self:MakePopup()
end

function PANEL:FillPlayers()
    local filter = self.Search:GetText()
    self.List:Clear()

    local categories = {}

    for k, ply in pairs(player.GetAll()) do
        if (filter != "" and not string.find(string.lower(ply:Nick()), string.lower(filter), 1, false)) then continue end
        if (!categories[ply:Team()]) then
            local cat = vgui.Create("DPanel", self.List)
            cat:Dock(TOP)
            cat:SetTall(48)
            cat.Data = RPExtraTeams[ply:Team()]
            cat.Amount = #team.GetPlayers(ply:Team())
            cat.Paint = function(s, w, h)
                draw.SimpleText(s.Data.name, NebulaUI:Font(48), 4, -2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                surface.SetDrawColor(s.Data.color)
                surface.DrawRect(8, 44, w - 16, 2)
                draw.SimpleText(s.Amount .. " player(s)", NebulaUI:Font(24), w - 4, 42, light, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

                draw.SimpleText("Money", NebulaUI:Font(20), (w / 10) * 3.5, 20, lightWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                draw.SimpleText("K", NebulaUI:Font(20), (w / 10) * 6, 20, lightWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                draw.SimpleText("D", NebulaUI:Font(20), (w / 10) * 7, 20, lightWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                draw.SimpleText("A", NebulaUI:Font(20), (w / 10) * 8, 20, lightWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end

            local players = team.GetPlayers(ply:Team())
            table.sort(players, function(a, b)
                if (a == LocalPlayer() or b == LocalPlayer()) then return false end
                return a:Nick() < b:Nick()
            end)
            local i = 0
            for k, plys in pairs(players) do
                local line = vgui.Create("DButton", self.List)
                line:Dock(TOP)
                line:SetText(plys:Nick())
                line:SetTall(28)
                line:DockMargin(8, 4, 8, 0)
                line:SetContentAlignment(4)
                line:SetTextInset(28, 0)
                line:SetFont(NebulaUI:Font(20))
                line.pair = i % 2 == 1
                line:SetTextColor(Color(255, 255, 255, line.pair and 255 or 150))
                line.Paint = function(s, w, h)
                    if not IsValid(plys) then
                        s:Remove()
                        return
                    end
                    draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, s.pair and 35 or 20))
                    draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(24, 0, 40, 228))

                    if (s:IsHovered()) then
                        draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 5))
                    end

                    draw.SimpleText(DarkRP.formatMoney(plys:getDarkRPVar("money")), s:GetFont(), (w / 10) * 3.5, h / 2, money_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(plys:Frags(), s:GetFont(), (w / 10) * 6 + 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(plys:Deaths(), s:GetFont(), (w / 10) * 7 + 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(plys:Assists(), s:GetFont(), (w / 10) * 8 + 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(plys:Ping(), s:GetFont(), w - 8, h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

                    local ccp = LOUNGE_CHAT.CustomColorsPlayers[plys:SteamID()] or LOUNGE_CHAT.CustomColorsPlayers[plys:SteamID64()]
		            local ccu = LOUNGE_CHAT.CustomColorsGroups[plys:GetUserGroup()]
                    if (ccu) then
                        surface.SetFont(s:GetFont())
                        local tx, _ = surface.GetTextSize(plys:Nick())
                        draw.SimpleText(plys:GetUserGroup(), NebulaUI:Font(12), 32 + tx, 11, ccu)
                    end
                end
                line.Avatar = vgui.Create("AvatarImage", line)
                line.Avatar:SetMouseInputEnabled(false)
                line.Avatar:SetSize(20, 20)
                line.Avatar:SetPos(4, 4)
                line.Avatar:SetPlayer(plys, 24)
                i = i + 1
            end
            categories[ply:Team()] = cat
        end
    end
end

function PANEL:Paint(w, h)

    h = h - self.Foot:GetTall() - 8
    surface.SetDrawColor(0, 0, 0, 175)
    surface.DrawRect(0, 0, w, h)

    NebulaUI.Derma.ScoreBack(0, 0, w, h)

    surface.SetDrawColor(195 * .5, 0, 202 * .5, 75)
    surface.SetTexture(gr)
    surface.DrawTexturedRect(0, 0, w, h)
    DisableClipping(true)
    surface.SetTexture(top)
    surface.SetDrawColor(color_white)
    surface.DrawTexturedRectRotated(w / 2, 0, 162, 162, 0)
    DisableClipping(false)
    h = h + 48
end

vgui.Register("nebula.scoreboard", PANEL, "nebula.frame")

hook.Add("OnPlayerChangedTeam", "Nebula.SavePaydays", function(self)
    timer.Create(self:SteamID64() .. "jobtimer", GAMEMODE.Config.paydelay, 0, function() end)
end)

hook.Add("ScoreboardShow", "NebulaRP", function()
    if IsValid(NebulaUI.Scoreboard) then
        NebulaUI.Scoreboard:Remove()
    end
    
    vgui.Create("nebula.scoreboard")
    return true
end)

hook.Add("ScoreboardHide", "NebulaRP", function()
    if IsValid(NebulaUI.Scoreboard) then
        NebulaUI.Scoreboard:Remove()
    end
end)