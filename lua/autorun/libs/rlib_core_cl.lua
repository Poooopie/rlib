/*
*   @package     rLib
*   @author      Richard [http://steamcommunity.com/profiles/76561198135875727]
*   
*   BY MODIFYING THIS FILE -- YOU UNDERSTAND THAT THE ABOVE MENTIONED AUTHORS CANNOT BE HELD RESPONSIBLE
*   FOR ANY ISSUES THAT ARISE FROM MAKING ANY ADJUSTMENTS TO THIS SCRIPT. YOU UNDERSTAND THAT THE ABOVE 
*   MENTIONED AUTHOR CAN ALSO NOT BE HELD RESPONSIBLE FOR ANY DAMAGES THAT MAY OCCUR TO YOUR SERVER AS A 
*   RESULT OF THIS SCRIPT AND ANY OTHER SCRIPT NOT BEING COMPATIBLE WITH ONE ANOTHER.
*/

/*
*	standard tables and localization
*/

rlib = rlib or { }

local base		= rlib
local prefix 	= base.manifest.prefix
local settings  = base.settings
local helper	= base.h
local design	= base.d
local debugger	= base.debug

base.h		= base.h or { }
base.sys	= base.sys or { }

/*
*   initialize materials
* 
*   Check if global mats table exists and assign 
* 
*   @param src table
*   @return table
*/

function helper.materials_initialize( src )
	if #src < 1 then
		return base.m
	else
		return { }
	end
end

/*
*   load materials
*   
*   Takes a list of materials provided in a table and loads
*   them into a system which can be used later to call a material
*   client-side, without the need to define the material.
*   
*   Source material folder takes 3 paramters:
*   
*       [1] Unique name, [2] Path to image, [3] Parameters
*   
*   If [3] is not specified, it will automatically apply
*   'noclamp smooth' to each material. Only use [3] if
*   you wish to not use both noclamp and smooth as your 
*   material parameters.
*   
*   @src
*           materials = 
*           { 
*               { 'uniquename', 'materials/folder/image.png', 'noclamp smooth' } 
*           }
*           
*   @call
*           rlib.h.materials_load( materials )
*           rlib.h.materials_load( materials, 'base' )
*           rlib.h.materials_load( materials, 'base', 'mat' )
*   
*   @result
*           m_rlib_uniquename
*           mbase_uniquename
*           matbase_uniquename
*   
*   @syntax
*       Once your materials have been loaded, you can 
*       call for one such as the result examples above.
*   
*       <append>_<suffix>_<src>
*       <m>_<rlib>_<uniquename
*       m_rlib_uniquename
*   
*   @param tbl src
*   @param str suffix
*   @param str append
*/

function helper.materials_load( src, suffix, append )

	if not src then return end
	if not suffix then suffix = base.name end
	if not append then append = 'm' end

	suffix = string.lower( suffix )
	append = string.lower( append )

	base.m = base.m or { }

	for _, m in pairs( src ) do
		if m[3] then
			base.m[append .. '_' .. suffix .. '_' .. m[1]] = Material( m[2], m[3] )
			base:logconsole( 6, '[L] [' .. append .. '_' .. suffix .. '_' .. m[1] .. ']' )
		else
			base.m[append .. '_' .. suffix .. '_' .. m[1]] = Material( m[2], 'noclamp smooth' )
			base:logconsole( 6, '[L] [' .. append .. '_' .. suffix .. '_' .. m[1] .. ']' )
		end
	end
end

/*
*   panel visible
*   
*   Checks a panel for validation and if currently visible
*   
*   @param pnl panel
*   @return bool
*/

function helper:panel_visible( panel )
	if IsValid( panel ) and panel:IsVisible( ) then
		return true
	end
	return false
end

/*
*   destroy panel
*   
*   Checks a panel for validation and then removes it completely.
*   
*   @param pnl panel
*   @param bool halt
*   @param bool kmouse [optional]
*   @param pnl subpanel [optional]
*/

function helper:panel_destroy( panel, halt, kmouse, sub )
	if sub and not IsValid( sub ) then return end
	if IsValid( panel ) then panel:Remove( ) end
	if kmouse then
		gui.EnableScreenClicker( false )
	end
	if halt then return false end
end

/*
*   destroy visible panel
*   
*   Checks a panel for validation and visible then 
*   removes it completely.
*   
*   @param pnl panel
*   @param bool halt
*/

function helper:panel_vis_destroy( panel )
	if IsValid( panel ) and panel:IsVisible( ) then
		panel:Remove( )
	end
end

/*
*   hide panel
*   
*   Checks a panel for validation and if its currently visible
*   and then sets panel visibility to false.
*   
*   @param pnl panel
*/

function helper:panel_hide( panel, halt, kmouse )
	if IsValid( panel ) then
		panel:SetVisible( false )
		if kmouse then
			gui.EnableScreenClicker( false )
		end
		if halt then return false end
	end
end

/*
*   hide panel isvis
*   
*   Checks a panel for validation and if its currently visible
*   and then sets panel visibility to false.
*   
*   @param pnl panel
*/

function helper:panel_vis_hide( panel, halt, kmouse )
	if IsValid( panel ) and panel:IsVisible( ) then
		panel:SetVisible( false )
		if kmouse then
			gui.EnableScreenClicker( false )
		end
		if halt then return false end
	end
end

/*
*   register panel
*   
*   Creates a usable panel that may need to be accessed
*   globally. Do not store local panels using this method.
*   
*   @param pnl panel
*   @param str id
*   @param str desc
*/

function helper:panel_register( panel, id, desc )
	if not id then
		base:consolelog( 2, 'Cannot register panel' )
		return false
	end

	if not istable( base.p.ind ) then
		base.p.ind = { }
	end

	if IsValid( panel ) then
		base.p.ind[ id ] =
		{
			data = panel,
			desc = desc or 'No data'
		}
	end
end

/*
*   restore panel
*   
*   Checks a panel for validation and if its not currently visible
*   and then sets panel to visible.
*   
*   @param pnl panel
*/

function helper:panel_restore( panel, halt, kmouse )
	if IsValid( panel ) and not panel:IsVisible( ) then
		panel:SetVisible( true )
		if kmouse then
			gui.EnableScreenClicker( true )
		end
		if halt then return false end
	end
end

/*
*   panel visibility flip
*   
*   determines if a panel is currently either visible or not
*	and then flips the panel visibility status.
*   
*	providing a sub panel will check both the parent and 
*	sub for validation, but only flip the sub panel
*	if the parent panel is valid.
*	
*   @param pnl panel
*	@param pnl sub
*/

function helper:panel_vis_flipflop( panel, sub )
	if IsValid( panel ) then
		if sub then
			if not IsValid( sub ) then return end
		else
			sub = panel
		end

		if panel:IsVisible( ) then
			sub:SetVisible( false )
		else
			sub:SetVisible( true )
		end
	end
end

/*
*   pos panel
*   
*   Checks a panel for validation and sets its position
*   
*   @param pnl panel
*   @param int x
*   @param int y
*/

function helper:panel_pos( panel, x, y )
	x = x or 0
	y = y or 0
	if IsValid( panel ) and panel:IsVisible( ) then
		panel:SetPos( x, y )
	end
end

/*
*   str_wrap
*	
*	takes characters in a string and determines where they need to be
*	"word-wrapped" based on the width provided in the parameters.
*	
*	@param str phrase
*	@param int width
*	@return tbl
*/

local function str_wrap( phrase, width )
	local phrase_len = 0
	local pattern = '.'

	phrase = string.gsub( phrase, pattern, function( char )
		phrase_len = phrase_len + surface.GetTextSize( char )
		if phrase_len >= width then
			phrase_len = 0
			return '\n' .. char
		end
		return char
	end )

	return phrase, phrase_len
end

/*
*   str_crop
*	
*	@usage helper:str_crop( 'your test text', 200, 'Trebuchet18' )
*	
*	originally developed by FPtje in DarkRP and as time went on
*	I made my own interpretation, so credit goes to him.
*	
*	@param str phrase
*	@param int width
*	@param str font
*	@return str
*/

function helper:str_crop( phrase, width, font )
	local phrase_len = 0
	local pattern = '(%s?[%S]+)'

	if not phrase or not width then
		local notfound = not phrase and 'phrase' or not width and 'width'
		base:logconsole( 6, 'missing [%s] and unable to crop', notfound )
		return false
	end

	if phrase and phrase == '' then
		base:logconsole( 6, 'phrase contains empty str' )
	end

	if not font then
		font = 'Marlett'
		base:logconsole( 6, 'strcrop font not specified, defaulting to [%s]', font )
	end

	surface.SetFont( font )

	local excludes = { '\n', '\t' }
	local spacer = select( 1, surface.GetTextSize( ' ' ) )

	phrase = string.gsub( phrase, pattern, function( word )

		local char = string.sub( word, 1, 1 )

		for v in rlib.h.getdata( excludes ) do
			if char == v then phrase_len = 0 end
		end

		local str_len = select( 1, surface.GetTextSize( word ) )
		phrase_len = phrase_len + str_len

		if str_len >= width then
			local spl_phrase, spl_cursor = str_wrap( word, width )
			phrase_len = spl_cursor
			return spl_phrase
		elseif phrase_len < width then return word end

		if char == ' ' then
			phrase_len = str_len - spacer
			return '\n' .. string.sub( word, 2 )
		end
		phrase_len = str_len

		return '\n' .. word

	end )

	return phrase

end

/* 
*   setup cvar properties
* 
*   Assigns a ClientConvar based on the parameters specified. These convars will then
*   be used later in order for the player.
*   
*	@param str flag
*	@param str id
*	@param str def
*	@param tbl vals
*   @return void
*/

function base.setup_properties( flag, id, def, vals )
	if flag ~= 'rgba' and flag ~= 'object' and flag ~= 'dropdown' then
		CreateClientConVar( id, def, true, false )
	elseif flag == 'dropdown' then
		CreateClientConVar( id, def or '', true, false )
	elseif flag == 'object' or flag == 'rgba' then
		for dn, dv in pairs( vals ) do
			CreateClientConVar( id .. '_' .. dn, dv, true, false )
		end
	end
end

/* 
*   theme failsafe
*   
*   Checks to see if any theme properties are missing
*   
*   @param tbl tbl
*   @param str val
*   @return bool
*/

function helper:fscheck( tbl, val )
	for k, v in pairs( tbl ) do
		if ( type( v ) == 'table' ) and ( v.DataID == val ) then
			return true
		end
	end
	return false
end

/*
*	create convar
*	
*	Create a client convar
*	
*	@param str name
*	@param str default
*	@param bool shouldsave
*	@param bool userdata
*	@param str helptext
*/

function helper:cvar_create( name, default, shouldsave, userdata, helptext )

	if not name then
		base:consolelog( 2, 'Name not provided for convar' )
		return false
	end

	if not ConVarExists( name ) then

		if not default then
			base:consolelog( 2, 'Default value not provided for convar [%s]', name )
			return false
		end

		shouldsave = shouldsave or true
		userdata = userdata or false
		helptext = helptext or ''

		CreateClientConVar( name, default, true, false, helptext )
		if settings.debug then
			base:logconsole( 4, 'Convar [%s] created', name )
		end

	end
end


/*
*	controlled scale
*	
*	A more controlled solution to screen scaling because I dislike 
*	how doing simple ScreenScaling never makes things perfect.
*	
*	Yes I know, a rather odd way, but it works for the time being.
*
*	-w 800 -h 600
*	-w 1024 -h 768
*	-w 1280 -h 720
*	-w 1366 -h 768
*	-w 1920 -h -1080
*	
*   @param int s800
*   @param int s1024
*   @param int s1280
*   @param int s1366
*   @param int s1600
*   @param int s1920
*   @param int s2xxx
*   @return int
*/

function helper.cscale( is_simple, s800, s1024, s1280, s1366, s1600, s1920, s2xxx )

	if not isbool( is_simple ) then
		base:logconsole( 2, 'Func [%s]: is_simple not bool', 'base.h.cscale' )
	end

	if not s800 then
		base:logconsole( 2, 'Func [%s]: no scale int specified', 'base.h.cscale' )
	end

	if not s1024 then s1024, s1280, s1366, s1600, s1920, s2xxx = s800, s800, s800, s800, s800, s800 end
	if not s1280 then s1280, s1366, s1600, s1920, s2xxx = s800, s800, s800, s800, s800 end
	if not s1366 then s1366, s1600, s1920, s2xxx = s1280, s1280, s1280, s1280 end
	if not s1600 then s1600, s1920, s2xxx = s1366, s1366, s1366 end
	if not s1920 then s1920, s2xxx = s1600, s1600 end
	if not s2xxx then s2xxx = s1920 end

	if ScrW( ) <= 800 then
		return is_simple and s800 or ScreenScale( s800 )
	elseif ScrW( ) > 800 and ScrW( ) <= 1024 then
		return is_simple and s1024 or ScreenScale( s1024 )
	elseif ScrW( ) > 1024 and ScrW( ) <= 1280 then
		return is_simple and s1280 or ScreenScale( s1280 )
	elseif ScrW( ) > 1280 and ScrW( ) <= 1366 then
		return is_simple and s1366 or ScreenScale( s1366 )
	elseif ScrW( ) > 1366 and ScrW( ) <= 1600 then
		return is_simple and s1600 or ScreenScale( s1600 )
	elseif ScrW( ) > 1600 and ScrW( ) <= 1920 then
		return is_simple and s1920 or ScreenScale( s1920 )
	elseif ScrW( ) > 1920 then
		return is_simple and s2xxx or ScreenScale( s2xxx )
	end

end

/*
*	clamp scale
*	
*	clamp a width and height value
*	
*	@param w int
*	@param h int
*	@return w, h
*/

function helper.lscale( w, h )
	if not h then h = w end
	return math.Clamp( 1920, 0, ScrW( ) / w ), math.Clamp( 1080, 0, ScrH( ) / h )
end

/*
*   scale
*   
*   basic scaling control
*   
*   @param int s
*   @param int m
*   @param int l
*   @return int
*/

function helper.scale( s, m, l )
	if not m then m = s end
	if not l then l = s end

	if ScrW( ) <= 1280 then
		return ScreenScale( s )
	elseif ScrW( ) >= 1281 and ScrW( ) <= 1600 then
		return ScreenScale( m )
	elseif ScrW( ) >= 1601 then
		return ScreenScale( l )
	else
		return s
	end
end

/*
*   scalesimple
* 
*   A more controlled solution to screen scaling
* 
*   @param int s
*   @param int m
*   @param int l
*   @return int
*/

function helper.scalesimple( s, m, l )
	if not m then m = s end
	if not l then l = s end

	if ScrW( ) <= 1280 then
		return s
	elseif ScrW( ) >= 1281 and ScrW( ) <= 1600 then
		return m
	elseif ScrW( ) >= 1601 then
		return l
	else
		return s
	end
end

/*
*   movetocenter
* 
*   Animation to move panel to center
*   
*   Can be used as
*       panel:MoveTo( base.h.movetocenter( p_size_w, p_size_h, 0.4 ) )
*   
*   @param int w
*   @param int h
*   @param int time
*   @return int (w), int (h)
*/

function helper:movetocenter( w, h, time )
	if not time then time = 0.5 end
	return ScrW( ) / 2 - math.Clamp( 1920, 0, ScrW( ) / w ) / 2, ScrH( ) / 2 - math.Clamp( 1080, 0, ScrH( ) / h ) / 2, time, 0, -1
end

/*
*   panel_center
* 
*   Animation to move panel to center
*	
*	dframes may not allow top-down animations to work properly
*	and start the panel off-screen, so the effect may not be 
*	as desired.
*   
*   @param pnl pnl
*   @param int time
*/

function helper:panel_center( pnl, time, from )
	if not IsValid( pnl ) then return end
	local w, h = pnl:GetSize( )

	if not time then time = 0 end

	local init_w, init_h	= -w, ( ScrH( ) / 2 ) - ( h / 2 )
	local move_w, move_h	= ScrW( ) / 2 - w / 2, ScrH( ) / 2 - h / 2

	if ( from == 'top' or from == 2 ) then
		init_w, init_h	= ScrW( ) / 2 - w / 2, - h
	elseif ( from == 'right' or from == 3 ) then
		init_w, init_h	= ScrW( ) + w, ( ScrH( ) / 2 ) - ( h / 2 )
	elseif ( from == 'bottom' or from == 4 ) then
		init_w, init_h	= ScrW( ) / 2 - w / 2, ScrH( ) + h
	end

	if not time then
		init_w, init_h = move_w, move_h
	end

	pnl:SetPos( init_w, init_h )

	if time then
		pnl:MoveTo( move_w, move_h, time, 0, -1 )
	end
end

/*
*   debugger initialization
*/

function debugger:push( mtype, ... )
	if not rlib:is_dev( LocalPlayer( ) ) then return end
	-- if not rlib:is_root( LocalPlayer( ) ) and not rlib.permissions_validate( LocalPlayer( ), rlib.permissions[ 'rlib_debug' ].id ) then return end

	if not mtype or not isnumber( mtype ) then
		mtype = 0
	end

	if not debugger.inf then
		debugger.inf = vgui.Create( 'rlib.devconsole' )
		debugger.inf:ActionHide( )
	end

	if IsValid( debugger.inf ) then
		debugger.inf:AddEntry( mtype, { ... } )
	end
end

/*
*   concommand :: matlist
* 
*   Lists materials that can be shared through-out scripts
*/

function base.sys.materials_list( )
	if not base:is_root( LocalPlayer( ) ) and not rlib:is_dev( LocalPlayer( ) ) then return end
	if not base.m or not istable( base.m ) then return end

	for _, m in pairs( base.m ) do
		base:logconsole( 6, '[L] [' .. _ .. ']' )
	end
end
concommand.Add( prefix .. 'materials.list', base.sys.materials_list )

/*
*   concommand :: setup materials
* 
*   Lists materials that can be shared through-out scripts
*	
*	@param str src
*	@param str suffix
*	@param str append
*/

function base.sys.materials_load( src, suffix, append )
	if not base:is_root( LocalPlayer( ) ) and not rlib:is_dev( LocalPlayer( ) ) then return end
	if not src or not istable( src ) then
		base:consolelog( 2, 'Material source table not specified' )
		return
	end
	helper.materials_load( src, suffix, append )
end
concommand.Add( prefix .. 'materials.load', base.materials_setup )

/*
*   netlib :: debug ui
* 
*   prompts an in-game notification for issues
*/

net.Receive( 'rlib.debug.ui', function( len )
	if not helper.pvalid( LocalPlayer( ) ) then return end

	local mtype = net.ReadInt( 4 )
	local msg 	= net.ReadString( )

	mtype	= mtype or 1
	msg		= msg or 'error receiving debug msg'

	design:debug_notify( mtype, msg )
end )

/*
*   netlib :: debugger
* 
*   prompts an in-game notification for issues
*/

net.Receive( 'rlib.debugger', function( len )
	if not helper.pvalid( LocalPlayer( ) ) then return end

	local mtype = net.ReadInt( 4 )
	local msg 	= net.ReadString( )

	mtype	= mtype or 1
	msg		= msg or 'error receiving debug msg'

	debugger:push( mtype, msg )
end )

/*
*   netlib :: event listener
* 
*   output to debugger console when a player connects or disconnects
*	from the server.
*/

net.Receive( 'rlib.debug.eventlistener', function( len )
	local is_join	= net.ReadBool( )
	local is_bot	= net.ReadBool( )
	local target 	= net.ReadString( )
	local addr 		= net.ReadString( )
	local nwid 		= net.ReadString( )
	local param 	= net.ReadString( )

	local c			= is_join and '[ JOIN ] ' or '[ PART ] '
	local a			= not is_bot and addr or 'BOT'
	local append	= not is_join and param or false

	if is_bot then
		debugger:push( 0, Color( 50, 200, 50 ), c, Color( 255, 255, 255 ), target .. ' ', Color( 255, 255, 25 ), '[' .. nwid .. ']' )
	else
		local ip, port = is_join and rlib:format_ipport( addr ) or false, false
		if not is_join then ip = 'D/C' end
		if append then
			debugger:push( 0, Color( 50, 200, 50 ), c, Color( 255, 255, 255 ), target .. ' ', Color( 255, 255, 25 ), '[' .. nwid .. ']', Color( 255, 255, 255 ), '[' .. ip .. '] ', Color( 180, 20, 20 ), append )
		else
			debugger:push( 0, Color( 50, 200, 50 ), c, Color( 255, 255, 255 ), target .. ' ', Color( 255, 255, 25 ), '[' .. nwid .. ']', Color( 255, 255, 255 ), '[' .. ip .. '] ' )
		end

	end

end )