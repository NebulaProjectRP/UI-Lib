
local Check = {}
AccessorFunc(Check, "m_bChecked", "Checked", FORCE_BOOL)
function Check:Init()
    self:SetText("")
    self:SetSize(32, 32)
end

function Check:SetTarget(target)
    self.Target = target
end

function Check:OnValueChange(b)
end

function Check:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, self:IsHovered() and 50 or 15))
    draw.RoundedBox(8, 2, 2, w - 4, h - 4, Color(16, 0, 24, 250))
    draw.SimpleText(self:GetChecked() and "✔" or "", NebulaUI:Font(24), w / 2, h / 2, color_white, 1, 1)
end

function Check:DoClick()
    self:SetChecked(!self:GetChecked())
    self:SetText(self:GetChecked() and "✔" or "")
    self:OnValueChange(self:GetChecked())
    if (self.ConVar) then
        RunConsoleCommand(self.ConVar, self:GetChecked() and "1" or "0")
    end
end

function Check:SetConVar(cvarname)
    self.ConVar = cvarname
    self:SetChecked(GetConVar(cvarname):GetBool())
end

function Check:OnCursorEntered()
    self:SetFont(NebulaUI:Font(24))
end

function Check:OnCursorExited()
    self:SetFont(NebulaUI:Font(20))
end

vgui.Register("nebula.checkbox", Check, "nebula.button")

local Check = {}
AccessorFunc(Check, "m_bChecked", "Checked", FORCE_BOOL)
function Check:Init()
    self:SetContentAlignment(4)
    self:SetTextInset(8, 0)
    self:SetChecked(false)
end

function Check:Paint(w, h)
    draw.RoundedBox(8, w - h + 2, 2, h - 4, h - 4, Color(255, 255, 255, self:IsHovered() and 50 or 15))
    draw.RoundedBox(8, w - h + 3, 3, h - 6, h - 6, Color(16, 0, 24, 250))
    draw.SimpleText(self:GetChecked() and "✔" or "", NebulaUI:Font(24), w - h / 2, h / 2, color_white, 1, 1)
    MsgN(self:GetChecked())
end

function Check:OnValueChange(b)
end

function Check:DoClick()
    self:SetChecked(!self:GetChecked())
    self:OnValueChange(self:GetChecked())
    if (self.ConVar) then
        RunConsoleCommand(self.ConVar, self:GetChecked() and 1 or 0)
    end
end

function Check:SetTarget(target)
    self.Target = target
end

vgui.Register("nebula.checkboxlabel", Check, "nebula.checkbox")