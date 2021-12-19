NebulaUI = NebulaUI or {
    Fonts = {},
    FontsTitle = {}
}

function NebulaUI:Font(x, title)
    if (title) then
        if (self.FontsTitle[x]) then
            return self.FontsTitle[x]
        else
            local fontName = "NebulaUI.Title_" .. x

            surface.CreateFont(fontName, {
                font = "ONE DAY",
                size = x,
            })

            self.FontsTitle[x] = fontName

            return fontName
        end
    elseif (self.Fonts[x]) then
        return self.Fonts[x]
    else
        local fontName = "NebulaUI.Font_" .. x

        surface.CreateFont(fontName, {
            font = "Montserrat Medium",
            size = x,
        })

        self.Fonts[x] = fontName

        return fontName
    end
end

local meta = FindMetaTable("Panel")

function meta:SetPosGrid(x, y, w, h)
    local parent = self:GetParent()

    if (not parent.IsGrid) then
        Error("The ui element it's not parented into a grid (nebula.grid)")
    end

    parent:SetZone(self, x, y, w, h)
end