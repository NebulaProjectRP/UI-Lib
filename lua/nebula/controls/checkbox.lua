
local Check = {}
AccessorFunc(Check, "m_bChecked", "Checked", FORCE_BOOL)
function Check:Init()
    self:SetText("")
    self:SetSize(32, 32)
end

function Check:SetTarget(target)
    self.Target = target
end

function Check:DoClick()
    self:SetChecked(!self:GetChecked())
    self:SetText(self:GetChecked() and "✔" or "")
    RunConsoleCommand(self.ConVar, self:GetChecked() and 1 or 0)
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