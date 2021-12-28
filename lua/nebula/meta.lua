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

local matBlurScreen = Material( "pp/blurscreen" )

function meta:DrawBlur( passes, power )

	local x, y = self:LocalToScreen( 0, 0 )

	local wasEnabled = DisableClipping( true )

	-- Menu cannot do blur
	if ( !MENU_DLL ) then
		surface.SetMaterial( matBlurScreen )
		surface.SetDrawColor( 255, 255, 255, 255 )

		for i = 0, passes / 3, 0.33 do
			matBlurScreen:SetFloat( "$blur", power * i )
			matBlurScreen:Recompute()
			if ( render ) then render.UpdateScreenEffectTexture() end
			surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
		end
	end
    
	DisableClipping( wasEnabled )

end
