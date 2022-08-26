NebulaUI = NebulaUI or {
    Fonts = {},
    FontsTitle = {}
}

XeninUI = XeninUI or {}
XeninUI.Branding = false

-- Materials
XeninUI.Materials = {
	CloseButton = Material("xenin/closebutton.png", "noclamp smooth"),
	Search = Material("xenin/search.png", "noclamp smooth")
}
-- Animation
XeninUI.TransitionTime = 0.15

-- UI theme
XeninUI.Theme = {
	Primary = Color(48, 48, 48),
	Navbar = Color(41, 41, 41),
	Background = Color(30, 30, 30),
	--Accent = Color(41, 128, 185),
	Accent = Color(230, 82, 37),
	Red = Color(230, 58, 64),
	Green = Color(46, 204, 113),
	Blue = Color(41, 128, 185),
	Yellow = Color(201, 176, 15)
}

XeninUI.Frame = {
	Width = 960,
	Height = 720
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
