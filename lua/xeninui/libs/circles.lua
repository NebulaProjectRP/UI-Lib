if SERVER then return end

local _R = debug.getregistry()
if (_R.Circles) then return _R.Circles end

local BlurMat = Material("pp/blurscreen")

local CIRCLE = {}
CIRCLE.__index = CIRCLE

do
	CIRCLE_FILLED = 0
	CIRCLE_OUTLINED = 1
	CIRCLE_BLURRED = 2
end

local err = "bad argument #%i to '%s' (%s expected, got %s)"
local function ArgCheck(cond, arg, name, expected, got)
	if (not cond) then
		error(string.format(err, arg, name, expected, type(got)), 3)
	end
end

local function New(typ, r, x, y, ...)
	ArgCheck(isnumber(typ), 1, "New", "number", typ)
	ArgCheck(isnumber(r), 2, "New", "number", r)
	ArgCheck(isnumber(x), 3, "New", "number", x)
	ArgCheck(isnumber(y), 4, "New", "number", y)

	local circle = setmetatable({}, CIRCLE)

	circle:SetType(tonumber(typ))
	circle:SetRadius(tonumber(r))
	circle:SetPos(tonumber(x), tonumber(y))

	if (typ == CIRCLE_OUTLINED) then
		local outline_width = ...
		circle:SetOutlineWidth(tonumber(outline_width))

	elseif (typ == CIRCLE_BLURRED) then
		local blur_layers, blur_density = ...
		circle:SetBlurLayers(tonumber(blur_layers))
		circle:SetBlurDensity(tonumber(blur_density))
	end

	return circle
end

local function RotateVertices(vertices, ox, oy, rotation, rotate_uv)
	ArgCheck(istable(vertices), 1, "RotateVertices", "table", vertices)
	ArgCheck(isnumber(ox), 2, "RotateVertices", "number", ox)
	ArgCheck(isnumber(oy), 3, "RotateVertices", "number", oy)
	ArgCheck(isnumber(rotation), 4, "RotateVertices", "number", rotation)

	rotation = math.rad(rotation)

	local c = math.cos(rotation)
	local s = math.sin(rotation)

	for i = 1, #vertices do
		local vertex = vertices[i]
		local vx, vy = vertex.x, vertex.y

		vx = vx - ox
		vy = vy - oy

		vertex.x = ox + (vx * c - vy * s)
		vertex.y = oy + (vx * s + vy * c)

		if (not rotate_uv) then
			local u, v = vertex.u, vertex.v
			u, v = u - 0.5, v - 0.5

			vertex.u = 0.5 + (u * c - v * s)
			vertex.v = 0.5 + (u * s + v * c)
		end
	end
end

local function CalculateVertices(x, y, radius, rotation, start_angle, end_angle, distance, rotate_uv)
	ArgCheck(isnumber(x), 1, "CalculateVertices", "number", x)
	ArgCheck(isnumber(y), 2, "CalculateVertices", "number", y)
	ArgCheck(isnumber(radius), 3, "CalculateVertices", "number", radius)
	ArgCheck(isnumber(rotation), 4, "CalculateVertices", "number", rotation)
	ArgCheck(isnumber(start_angle), 5, "CalculateVertices", "number", start_angle)
	ArgCheck(isnumber(end_angle), 6, "CalculateVertices", "number", end_angle)
	ArgCheck(isnumber(distance), 7, "CalculateVertices", "number", distance)

	local vertices = {}
	local step = (distance * 360) / (2 * math.pi * radius)

	for a = start_angle, end_angle + step, step do
		a = math.min(end_angle, a)
		a = math.rad(a)

		local c = math.cos(a)
		local s = math.sin(a)

		local vertex = {
			x = x + c * radius,
			y = y + s * radius,

			u = 0.5 + c / 2,
			v = 0.5 + s / 2,
		}

		table.insert(vertices, vertex)
	end

	if (end_angle - start_angle ~= 360) then
		table.insert(vertices, 1, {
			x = x, y = y,
			u = 0.5, v = 0.5,
		})
	else
		table.remove(vertices)
	end

	if (isnumber(rotation) and rotation ~= 0) then
		RotateVertices(vertices, x, y, rotation, rotate_uv)
	end

	return vertices
end

function CIRCLE:__tostring()
	return string.format("Circle: %p", self)
end

function CIRCLE:Copy()
	return table.Copy(self)
end

function CIRCLE:Calculate()
	local rotate_uv = self.m_RotateMaterial
	local x, y = self.m_X, self.m_Y
	local radius = self.m_Radius
	local rotation = self.m_Rotation
	local start_angle = self.m_StartAngle
	local end_angle = self.m_EndAngle
	local distance = self.m_Distance

	assert(radius >= 1, string.format("Circle radius should be >= 1. (%.2f)", radius))
	assert(distance >= 1, string.format("Circle vertice distance should be >= 1. (%.2f)", distance))

	self:SetVertices(CalculateVertices(x, y, radius, rotation, start_angle, end_angle, distance, rotate_uv))

	if (self.m_Type == CIRCLE_OUTLINED) then
		local inner = self.m_ChildCircle or self:Copy()

		inner:SetType(CIRCLE_FILLED)
		inner:SetRadius(self.m_Radius - self.m_OutlineWidth)
		inner:SetAngles(0, 360)

		inner:SetColor(false)
		inner:SetMaterial(false)

		self:SetChildCircle(inner)
	end

	self:SetDirty(false)
end

function CIRCLE:__call()
	if (self.m_Dirty) then
		self:Calculate()
	end

	if (#self.m_Vertices < 3) then
		return
	end

	local col, mat = self.m_Color, self.m_Material

	if (IsColor(col)) then
		surface.SetDrawColor(col.r, col.g, col.b, col.a)
	end

	if (mat == true) then
		draw.NoTexture()
	elseif (TypeID(mat) == TYPE_MATERIAL) then
		surface.SetMaterial(mat)
	end

	if (self.m_Type == CIRCLE_OUTLINED) then
		render.ClearStencil()

		render.SetStencilEnable(true)
			render.SetStencilTestMask(0xFF)
			render.SetStencilWriteMask(0xFF)
			render.SetStencilReferenceValue(0x01)

			render.SetStencilCompareFunction(STENCIL_NEVER)
			render.SetStencilFailOperation(STENCIL_REPLACE)
			render.SetStencilZFailOperation(STENCIL_REPLACE)

			self.m_ChildCircle()

			render.SetStencilCompareFunction(STENCIL_GREATER)
			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)

			surface.DrawPoly(self.m_Vertices)
		render.SetStencilEnable(false)
	elseif (self.m_Type == CIRCLE_BLURRED) then
		render.ClearStencil()

		render.SetStencilEnable(true)
			render.SetStencilTestMask(0xFF)
			render.SetStencilWriteMask(0xFF)
			render.SetStencilReferenceValue(0x01)

			render.SetStencilCompareFunction(STENCIL_NEVER)
			render.SetStencilFailOperation(STENCIL_REPLACE)
			render.SetStencilZFailOperation(STENCIL_REPLACE)

			surface.DrawPoly(self.m_Vertices)

			render.SetStencilCompareFunction(STENCIL_LESSEQUAL)
			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)

			surface.SetMaterial(BlurMat)

			local sw, sh = ScrW(), ScrH()

			for i = 1, self.m_BlurLayers do
				BlurMat:SetFloat("$blur", (i / self.m_BlurLayers) * self.m_BlurDensity)
				BlurMat:Recompute()

				render.UpdateScreenEffectTexture()
				surface.DrawTexturedRect(0, 0, sw, sh)
			end
		render.SetStencilEnable(false)
	else
		surface.DrawPoly(self.m_Vertices)
	end
end

function CIRCLE:Translate(x, y)
	x = tonumber(x)
	y = tonumber(y)
	if (not x and not y) then return end
	if (x == 0 and y == 0) then return end

	self.m_X = self.m_X + x
	self.m_Y = self.m_Y + y

	if (self.m_Dirty) then return end

	x = tonumber(x) or 0
	y = tonumber(y) or 0

	for i, v in ipairs(self.m_Vertices) do
		v.x = v.x + x
		v.y = v.y + y
	end

	if (self.m_Type == CIRCLE_OUTLINED) then
		self.m_ChildCircle:Translate(x, y)
	end
end

function CIRCLE:Scale(scale)
	scale = tonumber(scale)
	if (not scale or scale == 1) then return end

	self.m_Radius = self.m_Radius * scale

	if (self.m_Dirty) then return end

	local x, y = self.m_X, self.m_Y

	for i, vertex in ipairs(self.m_Vertices) do
		vertex.x = x + ((vertex.x - x) * scale)
		vertex.y = y + ((vertex.y - y) * scale)
	end

	if (self.m_Type == CIRCLE_OUTLINED) then
		self.m_ChildCircle:Scale(scale)
	end
end

function CIRCLE:Rotate(rotation)
	rotation = tonumber(rotation)
	if (not rotation or rotation == 0) then return end

	self.m_Rotation = self.m_Rotation + rotation

	if (self.m_Dirty) then return end

	local x, y = self.m_X, self.m_Y
	local vertices = self.m_Vertices
	local rotate_uv = self.m_RotateMaterial

	RotateVertices(vertices, x, y, rotation, rotate_uv)

	if (self.m_Type == CIRCLE_OUTLINED) then
		self.m_ChildCircle:Rotate(rotation)
	end
end

do
	local function AccessorFunc(name, default, dirty, callback)
		local varname = "m_" .. name

		CIRCLE["Get" .. name] = function(self)
			return self[varname]
		end

		CIRCLE["Set" .. name] = function(self, value)
			if (default ~= nil and value == nil) then
				value = default
			end

			if (self[varname] ~= value) then
				if (dirty) then
					self[dirty] = true
				end

				if (isfunction(callback)) then
					value = callback(self, self[varname], value) or value
				end

				self[varname] = value
			end
		end

		CIRCLE[varname] = default
	end

	local function OffsetVerticesX(circle, old, new)
		if (circle.m_Dirty or not circle.m_Vertices) then return end

		for i, vertex in ipairs(circle.m_Vertices) do
			vertex.x = vertex.x + (new - old)
		end

		if (circle.m_Type == CIRCLE_OUTLINED) then
			OffsetVerticesX(circle.m_ChildCircle, old, new)
		end
	end

	local function OffsetVerticesY(circle, old, new)
		if (circle.m_Dirty or not circle.m_Vertices) then return end

		for i, vertex in ipairs(circle.m_Vertices) do
			vertex.y = vertex.y + (new - old)
		end

		if (circle.m_Type == CIRCLE_OUTLINED) then
			OffsetVerticesY(circle.m_ChildCircle, old, new)
		end
	end

	local function UpdateRotation(circle, old, new)
		if (circle.m_Dirty or not circle.m_Vertices) then return end

		local vertices = circle.m_Vertices
		local x, y = circle.m_X, circle.m_Y
		local rotation = new - old
		local rotate_uv = circle.m_RotateMaterial

		RotateVertices(vertices, x, y, rotation, rotate_uv)

		if (circle.m_Type == CIRCLE_OUTLINED) then
			UpdateRotation(circle.m_ChildCircle, old, new)
		end
	end

	-- These are set internally. Only use them if you know what you're doing.
	AccessorFunc("Dirty", true)
	AccessorFunc("Vertices", false)
	AccessorFunc("ChildCircle", false)

	AccessorFunc("Color", false)						-- The colour you want the circle to be. If set to false then surface.SetDrawColor's can be used.
	AccessorFunc("Material", false)						-- The material you want the circle to render. If set to false then surface.SetMaterial can be used.
	AccessorFunc("RotateMaterial", true)				-- Sets whether or not the circle's UV points should be rotated with the vertices.

	AccessorFunc("Type", CIRCLE_FILLED, "m_Dirty")		-- The circle's type.
	AccessorFunc("X", 0, false, OffsetVerticesX)		-- The circle's X position relative to the top left of the screen.
	AccessorFunc("Y", 0, false, OffsetVerticesY)		-- The circle's Y position relative to the top left of the screen.
	AccessorFunc("Radius", 8, "m_Dirty")				-- The circle's radius.
	AccessorFunc("Rotation", 0, false, UpdateRotation)	-- The circle's rotation, measured in degrees.
	AccessorFunc("StartAngle", 0, "m_Dirty")			-- The circle's start angle, measured in degrees.
	AccessorFunc("EndAngle", 360, "m_Dirty")			-- The circle's end angle, measured in degrees.
	AccessorFunc("Distance", 10, "m_Dirty")				-- The maximum distance between each of the circle's vertices. Set to false to use segments instead. This should typically be used for large circles in 3D2D.

	AccessorFunc("BlurLayers", 3)						-- The circle's blur layers if Type is set to CIRCLE_BLURRED.
	AccessorFunc("BlurDensity", 2)						-- The circle's blur density if Type is set to CIRCLE_BLURRED.
	AccessorFunc("OutlineWidth", 10, "m_Dirty")			-- The circle's outline width if Type is set to CIRCLE_OUTLINED.

	function CIRCLE:SetPos(x, y)
		self:SetX(x)
		self:SetY(y)

		if (self.m_Type == CIRCLE_OUTLINED) then
			self.m_ChildCircle:SetPos(x, y)
		end
	end

	function CIRCLE:SetAngles(s, e)
		self:SetStartAngle(s)
		self:SetEndAngle(e)
	end

	function CIRCLE:GetPos()
		return self.m_X, self.m_Y
	end

	function CIRCLE:GetAngles()
		return self.m_StartAngle, self.m_EndAngle
	end
end

_R.Circles = {
	New = New,
	RotateVertices = RotateVertices,
	CalculateVertices = CalculateVertices,
}

return _R.Circles
