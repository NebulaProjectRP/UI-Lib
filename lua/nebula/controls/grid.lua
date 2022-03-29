local deb = CreateClientConVar("ui_debuggrid", "0")

local GRID = {}
AccessorFunc(GRID, "m_rows", "Rows", FORCE_NUMBER)
AccessorFunc(GRID, "m_columns", "Columns", FORCE_NUMBER)
AccessorFunc(GRID, "m_space", "Space", FORCE_NUMBER)
GRID.Rules = {}
GRID.IsGrid = true
function GRID:Init()
    self.Rules = {}
    self.Glow = false
    self:SetRows(4)
    self:SetColumns(4)
    self:SetSpace(4)
end

function GRID:SetGrid(w, h)
    self:SetRows(math.Round(h))
    self:SetColumns(math.Round(w))
    self:InvalidateLayout(true)
end

function GRID:Clear()
    for k, v in pairs(self:GetChildren()) do
        v:Remove()
    end
end

function GRID:SetZone(control, a, b, c, d)
    if not IsValid(control) then
        return
    end
    if (control:GetParent() != self) then
        control:SetParent(self)
    end
    self.Rules[control] = {x = a, y = b, w = c - a, h = d - b}
    self:InvalidateLayout(true)
end

function GRID:Paint(w, h)
    if (deb:GetBool() or self.Glow) then
        surface.SetDrawColor(255, 255, 255, 50)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(Color(255, 0, 0, 100))
        local col_wide = (w / self:GetColumns()) - self:GetSpace() * 1
        local row_height = (h / self:GetRows()) - self:GetSpace() * 1
        for x = 0, self:GetColumns() - 1 do
            for y = 0, self:GetRows() - 1 do
                surface.DrawRect(x * (col_wide + self:GetSpace()) + self:GetSpace() / 2, y * (row_height + self:GetSpace()) + self:GetSpace() / 2, col_wide, row_height)
            end
        end
    end
end

function GRID:PerformLayout(w, h)
    local col_wide = (w / self:GetColumns()) - self:GetSpace() * 1
    local row_height = (h / self:GetRows()) - self:GetSpace() * 1
    for control, points in pairs(self.Rules) do
        if not IsValid(control) then continue end
        local l, t, r, b = control:GetDockMargin()
        control:SetPos(points.x * (col_wide + self:GetSpace()) + self:GetSpace() / 2 + l, points.y * (row_height + self:GetSpace()) + self:GetSpace() / 2 + t)
        control:SetSize(points.w * col_wide + self:GetSpace() * (points.w - 1) - (r + l), points.h * row_height + self:GetSpace() * (points.h - 1) - (b + t))
    end
end

vgui.Register("nebula.grid", GRID, "Panel")

local meta = FindMetaTable("Panel")

function meta:SetPosGrid(x, y, w, h)
    if (!self:GetParent().IsGrid) then
        ErrorNoHaltWithStack("This panel it's not inside a grid element!")
        return
    end
    self:GetParent():SetZone(self, x, y, w, h)
end