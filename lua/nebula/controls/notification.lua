local PANEL = {}

local notifyMat = Material("nebularp/ui/notify")
local icons = {
    notify = {},
    panel = GWEN.CreateTextureBorder(10, 74, 246, 44, 16, 22, 0, 16, notifyMat)
}

for k = 1, 5 do
    icons.notify[k] = GWEN.CreateTextureNormal(51 * (k - 1), 0, 51, 64, notifyMat)
end

function PANEL:Init()
    self:SetSize(ScrW() / 2, ScrH())
    self:SetPos(ScrW() - self:GetWide())
    self.Notifications = {}
    self:SetDrawOnTop(true)
end

function PANEL:addItem(txt, type, length)

    local data = {
        Text = txt,
        Type = type,
        Length = length,
        Max = length,
        Alpha = 255,
        X = self:GetWide(),
        Y = #self.Notifications * 64,
    }

    surface.SetFont(NebulaUI:Font(20))
    local tx, _ = surface.GetTextSize(txt)
    data.TX = tx + 60
    table.insert(self.Notifications, data)
end

PANEL.MouseDown = false
function PANEL:Paint(w, h)
    local showHand = false
    local mx, my = self:ScreenToLocal(gui.MousePos())
    for k, v in pairs(self.Notifications) do
        if (v.Length > 0) then
            v.Length = v.Length - FrameTime()
        elseif (v.Alpha > 0) then
            v.Alpha = v.Alpha - 5
            if (v.Alpha <= 0) then
                table.remove(self.Notifications, k)
                continue
            end
        end
        v.X = Lerp(FrameTime() * 5, v.X, self:GetWide() - v.TX)
        v.Y = Lerp(FrameTime() * 5, v.Y, (k - 1) * 48 + ScrH() * .1)
        icons.panel(v.X, v.Y, v.TX, 44, ColorAlpha(color_white, v.Alpha))
        icons.notify[math.Clamp(v.Type + 1, 1, 5)](v.X + 2, v.Y, 51 * .7, 64 * .7, Color(255, 255, 255, v.Alpha))
        draw.SimpleText(v.Text, NebulaUI:Font(20), v.X + 38, v.Y + 20, Color(255, 255, 255, v.Alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        surface.SetDrawColor(32, 23, 30, v.Alpha)
        surface.DrawRect(v.X + 38, v.Y + 32, v.TX - 42, 3)
        
        surface.SetDrawColor(165, 81, 144, v.Alpha)
        surface.DrawRect(v.X + 38, v.Y + 32, (v.TX - 42) * (v.Length / v.Max), 3)

        local isHovered = mx > 0 and mx < v.X + self:GetWide() and my > v.Y and my < v.Y + 48
        if (isHovered) then
            showHand = true
        end
        if (not self.MouseDown and input.IsMouseDown(MOUSE_LEFT) and isHovered) then
            self.MouseDown = true
            table.remove(self.Notifications, k)
        end
    end

    if (self.MouseDown and not input.IsMouseDown(MOUSE_LEFT)) then
        self.MouseDown = false
    end

    if (#self.Notifications == 0) then
        self:Remove()
    end

    if (showHand) then
        self:SetCursor("hand")
    else
        self:SetCursor("none")
    end
end

vgui.Register("nebulaui.notify", PANEL, "DPanel")


function notification.AddLegacy(txt, type, length)
    if not IsValid(notify_panel) then
        notify_panel = vgui.Create("nebulaui.notify")
    end
    notify_panel:addItem(txt, type, length)
end
