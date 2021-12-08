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
