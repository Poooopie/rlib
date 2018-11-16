/*
*	@package     rlib
*	@author      Richard [http://steamcommunity.com/profiles/76561198135875727]
*	
*	BY MODIFYING THIS FILE -- YOU UNDERSTAND THAT THE ABOVE MENTIONED AUTHORS CANNOT BE HELD RESPONSIBLE
*	FOR ANY ISSUES THAT ARISE FROM MAKING ANY ADJUSTMENTS TO THIS SCRIPT. YOU UNDERSTAND THAT THE ABOVE 
*	MENTIONED AUTHOR CAN ALSO NOT BE HELD RESPONSIBLE FOR ANY DAMAGES THAT MAY OCCUR TO YOUR SERVER AS A 
*	RESULT OF THIS SCRIPT AND ANY OTHER SCRIPT NOT BEING COMPATIBLE WITH ONE ANOTHER.
*/

/*
*	standard tables and localization
*/

rlib			= rlib or { }
rlib.d			= rlib.d or { }

local base 		= rlib
local prefix 	= base.manifest.prefix
local settings	= base.settings
local helper	= base.h
local design	= base.d
local debugger	= base.debug

/*
*	ui fonts
*/

surface.CreateFont( prefix .. 'notice.text', { font = 'Roboto', size = 16, weight = 100, antialias = true } )

/*
*	draw :: blur
*	
*	@param pnl panel
*	@param int amount
*	@param int heavyness
*/

local blur = Material( 'pp/blurscreen' )
function design.blur( panel, amount, heavyness )
	if not IsValid( panel ) then return end

	local x, y = panel:LocalToScreen( 0, 0 )
	local scr_w, scr_h = ScrW( ), ScrH( )

	surface.SetDrawColor( 255, 255, 255 )
	surface.SetMaterial( blur )

	for i = 1, ( heavyness or 3 ) do
		blur:SetFloat( '$blur', ( i / 3 ) * ( amount or 6 ) )
		blur:Recompute( )

		render.UpdateScreenEffectTexture( )
		surface.DrawTexturedRect( x * -1, y * -1, scr_w, scr_h )
	end
end

/*
*	draw :: box
*/

function design.box( x, y, w, h, color )
	surface.SetDrawColor( color )
	surface.DrawRect( x, y, w, h )
end

/*
*	draw :: material
*/

function design.mat( mat, color, x, y, w, h )

	color = color or Color( 255, 255, 255, 255 )
	h = h or w

	surface.SetMaterial( mat or Material( 'pp/colour' ) )
	surface.SetDrawColor( color or Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( x, y, w, h )
end

/*
*	draw :: material rotated
*/

function design.mat_r( mat, color, x, y, w, h, r )
	color = color or Color( 255, 255, 255, 255 )
	surface.SetMaterial( mat )
	surface.SetDrawColor( color or Color( 255, 255, 255 ) )
	surface.DrawTexturedRectRotated( x, y, w, h, r )
end

/*
* Draw Outlined Box
*/

function design.obox( x, y, w, h, colorMain, colorBorder )
	local i = 1
	local n = 2
	local defColor = Color( 0, 0, 0, 0 )

	surface.SetDrawColor( colorMain or defColor )
	surface.DrawRect(x + i, y + i, w - n, h - n )
	surface.SetDrawColor( colorBorder or defColor )
	surface.DrawOutlinedRect( x, y, w, h )
end

/*
*	draw :: outlined box thick
*/

function design.obox_th( x, y, w, h, borderthick, clr )
	surface.SetDrawColor( clr )
	for i = 0, borderthick - 1 do
		surface.DrawOutlinedRect( x + i, y + i, w - i * 2, h - i * 2 )
	end
end

/*
*	draw :: bokeh eff
*	
*	@param int amt
*	@param int, tbl isize
*	@param int, tbl ispeed
*	@param clr, str color
*	@return int amt, tbl fx_bokeh
*/

function design:bokeh( amt, isize, ispeed, color, alpha )
	amt = amt or 25

	if istable( isize ) then
		size_min, size_max = isize[1], isize[2]
	elseif isnumber( isize ) then
		size_min, size_max = isize, isize
	else
		size_min, size_max = 25, 25
	end

	if istable( ispeed ) then
		speed_min, speed_max = ispeed[1], ispeed[2]
	elseif isnumber( ispeed ) then
		speed_min, speed_max = ispeed, ispeed
	else
		speed_min, speed_max = 20, 20
	end

	alpha = alpha or 100

	local fx_bokeh = { }

	local clr_r, clr_g, clr_b = 255, 255, 255, alpha
	if ( amt >= 1 ) then
		local wsize, hsize = ScrW( ), ScrH( )
		for n = 1, amt do
			if IsColor( color ) then
				clr_r, clr_g, clr_b, clr_a = color.r, color.g, color.b, alpha
			elseif color == 'random' then
				clr_r, clr_g, clr_b, clr_a = math.random( 0, 255 ), math.random( 0, 255 ), math.random( 0, 255 ), alpha
			end
			fx_bokeh[n] =
			{
				xpos	= math.random( 0, wsize ),
				ypos	= math.random( -hsize, hsize ),
				size	= math.random( size_min, size_max ),
				color	= Color( clr_r, clr_g, clr_b, clr_a ),
				speed	= math.random( speed_min, speed_max ),
				area	= math.Round( math.random( -150, 150 ) ),
			}
		end
		return amt, fx_bokeh
	end
end

/*
*	draw :: bokeh fx
*	
*	@param int amt
*	@param tbl effects
*/

function design:bokehfx( w, h, amount, object, effects, selected, speed, offset )

	local fx_type = effects[ selected ]

	if not fx_type then return end

	speed = speed or 30
	offset = offset or 0

	surface.SetMaterial( Material( fx_type, 'noclamp smooth' ) )

	local count = table.Count( object )
	if ( count > 0 ) then
		local cos = 0
		for n = 1, amount do
			object[ n ].xpos = object[ n ].xpos + ( object[ n ].area * math.cos( n ) / ( count ) )
			object[ n ].ypos = object[ n ].ypos + ( math.sin( offset ) / 20 + object[ n ].speed / speed )
		end

		for n = 1, amount do
			local clr_r, clr_g, clr_b, clr_a = object[ n ].color.r, object[ n ].color.g, object[ n ].color.b, object[ n ].color.a
			surface.SetDrawColor( Color( clr_r, clr_g, clr_b, clr_a ) or Color( 255, 255, 255, 5 ) )
			surface.DrawTexturedRect( object[ n ].xpos, object[ n ].ypos, object[ n ].size, object[ n ].size )
		end
	end
end

/*
*	draw :: circle
*/

function design.circle( x, y, radius, seg )
	local cir = { }

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 )
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

/*
*	draw :: circle stencil
*/

function design.circle_sten( x, y, radius, color )
	local p = { }
	local a = 40
	local c = 360
	local r = radius

	for n = 0, a do
		p[ n + 1 ] =
		{
			x = math.sin(-math.rad( n / a * c ) ) * r + x,
			y = math.cos(-math.rad( n / a * c ) ) * r + y
		}
	end

	draw.NoTexture( )
	surface.SetDrawColor( color )
	surface.DrawPoly( p )
end

/*
*	draw :: circle_t2_g
*	
*	used in conjunction with ct2
*/

function design.circle_t2_g( xpos, ypos, radius, seg )
	local c = { }
	local u = 0.5
	local v = 0.5
	local s = seg
	local r = radius

	surface.SetTexture( 0 )
	table.insert( c,
	{
		x = xpos,
		y = ypos,
		u = u,
		v = v
	})

	for n = 0, s do
		local a = math.rad( (n / s ) * -360 )
		table.insert( c,
		{
			x = xpos + math.sin( a ) * r,
			y = ypos + math.cos( a ) * r,
			u = math.sin( a ) / 2 + u,
			v = math.cos( a ) / 2 + v
		})
	end

	local a = math.rad( 0 )
	table.insert( c,
	{
		x = xpos + math.sin( a ) * r,
		y = ypos + math.cos( a ) * r,
		u = math.sin( a ) / 2 + u,
		v = math.cos( a ) / 2 + v
	})

	return c
end

/*
*	draw :: circle_t2
* 
*	used in conjunction with circle_t2_g
*/

function design.circle_t2( x, y, radius, seg, color )
	surface.SetDrawColor( color or Color( 0, 0, 0, 0 ) )
	surface.DrawPoly( design.circle_t2_g( x, y, radius, seg ) )
end

/*
*	draw :: circle_anim_g
* 
*	used in conjunction with circle_anim
*/

function design.circle_anim_g( x, y, radius, seg, frac )
	frac = frac or 1
	local poly = { }

	surface.SetTexture( 0 )
	table.insert( poly, { x = x, y = y, u = 0.5, v = 0.5 } )

	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 * frac )
		table.insert( poly, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 )
	table.insert( poly, { x = x, y = y, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	return poly
end

/*
*	draw :: circle_anim
* 
*	used in conjunction with circle_anim_g
*	
*	@note frac = curr / 100
*/

function design.circle_anim( x, y, radius, seg, color, frac )
	surface.SetDrawColor( color or Color( 0, 0, 0, 0 ) )
	surface.DrawPoly( design.circle_anim_g( x, y, radius, seg, frac ) )
end

/*
*	stencils
*/

function design.StencilStart( )
	render.ClearStencil( )
	render.SetStencilEnable( true )
	render.SetStencilWriteMask( 1 )
	render.SetStencilTestMask( 1 )
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
	render.SetStencilReferenceValue( 1 )
	render.SetColorModulation( 1, 1, 1 )
end

function design.StencilReplace( v )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilReferenceValue( v or 1 )
end

function design.StencilEnd( )
	render.SetStencilEnable( false )
end

/*
*   draw indicator
*/

function design.indicator( value, unique_id, mat, ftop, ttop, font, duration )
	local calc = helper.calc

	if not value then return end

	surface.CreateFont( prefix .. 'hud.indicator', { font = 'Roboto Light', size = 22, weight = 400, antialias = true, shadow = true } )

	unique_id	= unique_id or calc.rand_string( 10 )
	mat			= mat or nil
	ftop		= ftop or -20
	ttop		= ttop or 85
	font		= font or prefix .. 'hud.indicator'
	duration	= duration or 3

	local fade	= 0.3
	local start	= CurTime( )
	local alpha = 255

	local mat_indicator = mat and Material( mat, 'noclamp smooth' ) or Material( 'general/auras/aura-005.png', 'noclamp smooth' )
	local function draw_indicator( )
		local dtime = CurTime( ) - start
		if alpha < 0 then
			alpha = 0
		end

		if dtime > duration then
			hook.Remove( 'HUDPaint', unique_id .. 'paint.indicator' )
			return
		end

		if fade - dtime > 0 then -- beginning fade
			alpha = (fade - dtime) / fade -- 0 to 1
			alpha = 1 - alpha -- Reverse
			alpha = alpha * 255
		end

		if duration - dtime < fade then -- ending fade
			alpha = (duration - dtime) / fade -- 0 to 1
			alpha = alpha * 255
		end

		local calpha = math.Clamp( alpha, 0, 255 )

		if mat_indicator then
			surface.SetDrawColor( Color( 255, 255, 255, calpha ) )
			surface.SetMaterial( mat_indicator )
			surface.DrawTexturedRect( ScrW( ) / 2 - ( 200 / 2 ), ftop, 200, 200 )
		end

		draw.SimpleText( value, font, ScrW( ) / 2, ttop, Color( 255, 255, 255, calpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	hook.Add( 'HUDPaint', unique_id .. 'paint.indicator', draw_indicator )
end

/*
*	get_padding
*	
*	return current padding
*/

function design:get_padding( )
	return val
end

/*
*	get_margin
*	
*	return current margin
*/

function design:get_margin( )
	return val
end

/*
*	debug_notify
*	
*	displays a simple slide-in notification box that will allow players to
*	see when something has happened.
*	
*	@param int mtype
*	@param str msg
*/

function design:debug_notify( mtype, msg )

	helper:panel_vis_destroy( rlib.notify )

	local clr = helper._debuggerColors[1]
	if mtype and IsColor( mtype ) then
		clr = mtype
	elseif mtype and isnumber( mtype ) then
		clr = helper._debuggerColors[mtype]
	end

	if not msg then
		mtype. msg = 2, 'an error occured'
	end

	local src_w, src_h = ScrW( ), ScrH( )
	local ui_w, ui_h = src_w, draw.GetFontHeight( prefix .. 'notice.text' ) + 16

	local obj = vgui.Create( 'DButton' )
	obj:SetFont( prefix .. 'notice.text' )
	obj:SetText( msg or 'error' )
	obj:SetColor( Color( 255, 255, 255, 255 ) )
	obj:SetSize( ui_w, ui_h )
	obj:MoveToFront( )
	obj:AlignTop( src_h )
	obj.Paint = function( s, w, h )
		surface.SetDrawColor( clr )
		surface.DrawRect( 3, 2, w - 6, h - 4 )
	end
	obj.DoClick = function( s )
		if s.action_close then return end
		s.action_close = true
		s:Stop( )
		s:MoveTo( 0, src_h, 0.5, 0, -1, function( )
			helper:panel_vis_destroy( s )
		end )
	end

	if IsValid( obj ) then
		rlib.notify = obj

		obj:MoveTo( 0, src_h - obj:GetTall( ), 0.5, 0, -1, function( )
			obj:MoveTo( 0, src_h, 0.5, settings.debug_notify_interval or 7, -1, function( )
				helper:panel_vis_destroy( obj )
			end )
		end )
	end
end

/*
*	debugger :: initialize
*	
*	create the debugger panel
*/

function debugger:initialize( )
	if not rlib:is_dev( LocalPlayer( ) ) then return end
	-- if not rlib:is_root( LocalPlayer( ) ) and not rlib.permissions_validate( LocalPlayer( ), rlib.permissions['rlib_debug'].id ) then return end
	if not IsValid( debugger.inf ) then
		debugger.inf = vgui.Create( 'rlib.devconsole' )
	end
	debugger.inf:ActionShow( )
end
concommand.Add( prefix .. 'devconsole', debugger.initialize )

/*
*	dconsole keybinds
*	
*	checks to see if the assigned keys are being pressed to
*	activate the developer console
*	
*	@param int mtype
*	@param str msg
*/

local dcon_dothink = 0
hook.Add( 'Think', prefix .. 'keybinds.debugger', function()
	if gui.IsConsoleVisible( ) then return end
	-- if not rlib:is_root( LocalPlayer( ) ) and not rlib.permissions_validate( LocalPlayer( ), rlib.permissions['rlib_debug'].id ) then return end
	if not rlib:is_dev( LocalPlayer( ) ) then return end

	local bKey_one = 79
	local bKey_two = 59
	local b_Keybfocus = vgui.GetKeyboardFocus( )

	if not LocalPlayer( ):IsTyping( ) and not b_Keybfocus then
		if bKey_one and isnumber( bKey_one ) and bKey_one ~= 0 then
			if ( input.IsKeyDown( bKey_one ) and input.IsKeyDown( bKey_two ) ) then
				if dcon_dothink > CurTime( ) then return end
				debugger:initialize( )
				dcon_dothink = CurTime( ) + 1
			end
		else
			if ( bKey_two and input.IsKeyDown( bKey_two ) ) then
				if dcon_dothink > CurTime( ) then return end
				debugger:initialize( )
				dcon_dothink = CurTime( ) + 1
			end
		end
	end
end )

/*
*	dconsole keybinds
*	
*	checks to see if the assigned keys are being pressed to
*	activate the developer console
*/

local rlib_dothink = 0
function base:think_plymres( )

	if rlib_dothink > CurTime( ) then return end
	if not helper.pvalid( LocalPlayer( ) ) then return end

	ply = LocalPlayer( )

	-- Rather than painting positions, just store the players old monitor resolution
	-- and reinit the HUD if the monitor resolution changes.
	if not ( ply.scrres_w or ply.scrres_h ) or ( ply.scrres_w ~= ScrW( ) or ply.scrres_h ~= ScrH() ) then
		ply.scrres_w = ScrW( )
		ply.scrres_h = ScrH( )
	end

	rlib_dothink = CurTime( ) + 0.2

end
hook.Add( 'Think', prefix .. 'think.plymres', base.think_plymres )