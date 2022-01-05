
local PANEL = {}
AccessorFunc(PANEL, "m_bCrop", "Crop", FORCE_BOOL)

function PANEL:DrawModel()

	local curparent = self
	local leftx, topy = self:LocalToScreen( 0, 0 )
	local rightx, bottomy = self:LocalToScreen( self:GetWide(), self:GetTall() )
	while ( curparent:GetParent() != nil ) do
		curparent = curparent:GetParent()

		local x1, y1 = curparent:LocalToScreen( 0, 0 )
		local x2, y2 = curparent:LocalToScreen( curparent:GetWide(), curparent:GetTall() )

		leftx = math.max( leftx, x1 )
		topy = math.max( topy, y1 )
		rightx = math.min( rightx, x2 )
		bottomy = math.min( bottomy, y2 )
		previous = curparent
	end

	-- Causes issues with stencils, but only for some people?
	render.ClearDepth()

	if not self:GetCrop() then
		//render.SetScissorRect( leftx, topy, rightx, bottomy, true )
	end

	local ret = self:PreDrawModel( self.Entity )
	if ( ret != false ) then
		cam.IgnoreZ(true)
		self.Entity:DrawModel()
		cam.IgnoreZ(false)
		self:PostDrawModel( self.Entity )
	end

	if not self:GetCrop() then
		//render.SetScissorRect( 0, 0, 0, 0, false )
	end

end

vgui.Register( "nebula.modelpanel", PANEL, "DModelPanel" )
