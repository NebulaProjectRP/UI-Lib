function XeninUI:Ease(t, b, c, d)
	t = t / d
	local ts = t * t
	local tc = ts * t

	return b + c * ts
end

function XeninUI:LerpColor(fract, from, to)
	return Color(
		Lerp(fract, from.r, to.r),
		Lerp(fract, from.g, to.g),
		Lerp(fract, from.b, to.b),
		Lerp(fract, from.a or 255, to.a or 255)
	)
end

local PNL = FindMetaTable("Panel")

function PNL:LerpColor(var, to, duration)
	if (!duration) then duration = XeninUI.TransitionTime end

	local color = self[var]
	local anim = self:NewAnimation(duration)
	anim.Color = to
	anim.Think = function(anim, pnl, fract)
		local newFract = XeninUI:Ease(fract, 0, 1, 1)

		if (!anim.StartColor) then
			anim.StartColor = color
		end

		local newColor = XeninUI:LerpColor(newFract, anim.StartColor, anim.Color)
		self[var] = newColor
	end
end

function PNL:Lerp(var, to, duration, callback)
	if (!duration) then duration = XeninUI.TransitionTime end

	local varStart = self[var]
	local anim = self:NewAnimation(duration)
	anim.Goal = to
	anim.Think = function(anim, pnl, fract)
		local newFract = XeninUI:Ease(fract, 0, 1, 1)

		if (!anim.Start) then
			anim.Start = varStart
		end

		local new = Lerp(newFract, anim.Start, anim.Goal)
		self[var] = new
	end
	anim.OnEnd = function()
		if (callback) then
			callback()
		end
	end
end

function PNL:LerpMove(x, y, duration, callback)
	if (!duration) then duration = XeninUI.TransitionTime end

	local anim = self:NewAnimation(duration)
	anim.Pos = Vector(x, y)
	anim.Think = function(anim, pnl, fract)
		local newFract = XeninUI:Ease(fract, 0, 1, 1)

		if (!anim.StartPos) then
			anim.StartPos = Vector(pnl.x, pnl.y, 0)
		end

		local new = LerpVector(newFract, anim.StartPos, anim.Pos)
		self:SetPos(new.x, new.y)
	end
	anim.OnEnd = function()
		if (callback) then
			callback()
		end
	end
end

function PNL:LerpMoveY(y, duration, callback)
	if (!duration) then duration = XeninUI.TransitionTime end

	local anim = self:NewAnimation(duration)
	anim.Pos = y
	anim.Think = function(anim, pnl, fract)
		local newFract = XeninUI:Ease(fract, 0, 1, 1)

		if (!anim.StartPos) then
			anim.StartPos = pnl.y
		end

		local new = Lerp(newFract, anim.StartPos, anim.Pos)
		self:SetPos(pnl.x, new)
	end
	anim.OnEnd = function()
		if (callback) then
			callback()
		end
	end
end

function PNL:LerpHeight(height, duration, callback)
	if (!duration) then duration = XeninUI.TransitionTime end

	local anim = self:NewAnimation(duration)
	anim.Height = height
	anim.Think = function(anim, pnl, fract)
		local newFract = XeninUI:Ease(fract, 0, 1, 1)

		if (!anim.StartHeight) then
			anim.StartHeight = pnl:GetTall()
		end

		local new = Lerp(newFract, anim.StartHeight, anim.Height)
		self:SetTall(new)
	end
	anim.OnEnd = function()
		if (callback) then
			callback()
		end
	end
end

function PNL:LerpWidth(width, duration, callback)
	if (!duration) then duration = XeninUI.TransitionTime end

	local anim = self:NewAnimation(duration)
	anim.Width = width
	anim.Think = function(anim, pnl, fract)
		local newFract = XeninUI:Ease(fract, 0, 1, 1)

		if (!anim.StartWidth) then
			anim.StartWidth = pnl:GetWide()
		end

		local new = Lerp(newFract, anim.StartWidth, anim.Width)
		self:SetWide(new)
	end
	anim.OnEnd = function()
		if (callback) then
			callback()
		end
	end
end