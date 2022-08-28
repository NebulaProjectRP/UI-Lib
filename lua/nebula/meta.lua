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

function XeninUI:CreateFont(name, size)
    surface.CreateFont(name, {
        font = "Montserrat Medium",
        size = size,
    })
end


XeninUI:CreateFont("XeninUI.NPC.Overhead", 160)
function XeninUI:DrawNPCOverhead(npc, tbl)
  local alpha = tbl.alpha or 255
  local text = tbl.text or npc.PrintName or "NO NAME"
  local icon = tbl.icon
  local hover = tbl.sin
  local xOffset = tbl.xOffset or 0
  local textOffset = tbl.textOffset or 0
  local col = tbl.color or XeninUI.Theme.Accent
  col = ColorAlpha(col, alpha)

  local str = text
  surface.SetFont("XeninUI.NPC.Overhead")
  local width = surface.GetTextSize(str)
  width = width + 40
  if (icon) then
    width = width + (64 * 3)
  else
    width = width + 64
  end

  local center = 900 / 2
  local x = -width / 2 - 30 + (xOffset or 0)
  local y = 220
  local sin = math.sin(CurTime() * 2)
  if (hover) then
    y = math.Round(y + (sin * 30))
  end
  local h = 64 * 3

	local isLookingAt
	if (alpha > 0.5) then
		isLookingAt = LocalPlayer():GetEyeTrace().Entity == npc
	end
	npc.overheadAlpha = npc.overheadAlpha or 0
	if (isLookingAt) then
		npc.overheadAlpha = math.Clamp(npc.overheadAlpha + (FrameTime() * 3), 0, 1)
	else
		npc.overheadAlpha = math.Clamp(npc.overheadAlpha - (FrameTime() * 3), 0, 1)
	end

	local darkerColor = Color(col.r * 0.5, col.g * 0.5, col.b * 0.5)
	XeninUI:DrawRoundedBox(64, x, y, width, h, ColorAlpha(darkerColor, npc.overheadAlpha * 255))
	XeninUI:DrawRoundedBox(64, x + 8, y + 8, width - 16, h - 16, ColorAlpha(col, npc.overheadAlpha * 255))
	--draw.SimpleLinearGradient(x, y, width, h, XeninUI.Theme.Red, XeninUI.Theme.Green, true)
	--XeninUI:DrawRoundedBox(32, x, y, width, h, ColorAlpha(col, npc.overheadAlpha * 255))

	local textX =  !icon and (width / 2) or h
  XeninUI:DrawShadowText(str, "XeninUI.NPC.Overhead", x + textX + textOffset, h / 2 + y - 10, Color(225, 225, 225, alpha), icon and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5, 125)

  if (icon) then
    surface.SetDrawColor(255, 255, 255, alpha)
    surface.SetMaterial(icon)
    local margin = tbl.icon_margin or tbl.iconMargin or 30
    surface.DrawTexturedRect(x + margin, y + margin, h - (margin * 2), h - (margin * 2))
  end


	--[[ Gmod bugs with stencils... fucks up rendering for blue atms and such
  XeninUI:MaskInverse(function()
    XeninUI:DrawRoundedBox(h / 2, x + 8, y + 8, width - 16, h - 16, Color(0, 0, 0, alpha))
  end, function()
    XeninUI:DrawRoundedBox(h / 2, x, y, width, h, col)
  end)
	--]]
end


function XeninUI:DrawShadowText(text, font, x, y, col, xAlign, yAlign, amt, shadow)
    for i = 1, amt do
      draw.SimpleText(text, font, x + i, y + i, Color(0, 0, 0, i * (shadow or 50)), xAlign, yAlign)
    end
  
    draw.SimpleText(text, font, x, y, col, xAlign, yAlign)
  end
  
  function XeninUI:DrawOutlinedText(str, font, x, y, col, xAlign, yAlign, outlineCol, thickness)
      thickness = thickness or 1
      
      for i = 1, thickness do
          draw.SimpleText(str, font, x - thickness, y - thickness, outlineCol or color_black, xAlign, yAlign)
          draw.SimpleText(str, font, x - thickness, y + thickness, outlineCol or color_black, xAlign, yAlign)
          draw.SimpleText(str, font, x + thickness, y - thickness, outlineCol or color_black, xAlign, yAlign)
          draw.SimpleText(str, font, x + thickness, y + thickness, outlineCol or color_black, xAlign, yAlign)
      end
      
      draw.SimpleText(str, font, x, y, col, xAlign, yAlign)
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