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

rlib = rlib or { }

local base			= rlib
local prefix 		= base.manifest.prefix
local script		= base.manifest.name
local version		= base.manifest.build
local settings		= base.settings

/*
*	Localized cmd func
*   
*   @source lua\autorun\libs\calls
*   @param type string
*   @param ... mixed
*/

local function call( t, ... )
	return rlib:call( t, ... )
end

/*
*	Localized shortcuts
* 
* 		base.h			= helpers
* 		base.d			= draw/design
* 		base.c			= calls
* 		base.p			= panels
*		base.p.ind 		= panels ind
*		base.i			= interface
*		base.s			= storage
*/

local helper 		= base.h
local design 		= base.d
local pnl 			= base.p
local interface 	= base.i
local storage 		= base.s
local utils			= base.u

local debugger		= base.debug or { }
local calc			= base.calc or { }

/*
*	colorful styles for debuggers
*	
*	these are for in-game use so its ok to
*	use any color.
*/

helper._debuggerColors =
{
	[ 1 ] = Color( 82, 89, 156, 255 ),		-- blue
	[ 2 ] = Color( 184, 59, 59, 255 ),		-- red
	[ 3 ] = Color( 168, 107, 3, 255 ),		-- orange
	[ 4 ] = Color( 66, 128, 59, 255 ),		-- green
	[ 5 ] = Color( 113, 84, 128, 255 ),		-- purple
	[ 6 ] = Color( 168, 44, 116, 255 ),		-- fuchsia
	[ 7 ] = Color( 217, 202, 46, 255 ),		-- dark yellow / gold
}

/*
*	colorful console output styles
*	
*	most consoles ( except for srcds in windows )
*	only allow for the basic r g b type colors.
*	which means we cant do fancy colors that will
*	most likely not show up.
*/

helper._consoleColors =
{
	[ 1 ] = Color( 255, 255, 255 ),		-- white
	[ 2 ] = Color( 255, 0, 0 ),			-- red
	[ 3 ] = Color( 255, 255, 0 ),		-- yellow
	[ 4 ] = Color( 0, 255, 0 ),			-- green
	[ 5 ] = Color( 255, 255, 255 ),		-- white
	[ 6 ] = Color( 255, 255, 0 ),		-- yellow
	[ 7 ] = Color( 255, 255, 0 )		-- yellow
}

/*
*	console output types
*	
*	different types of messages. these will
*	be attached to the beginning of both console
*	and debugger messages.
*	
*	@ex [Info] <player> has joined
*/

helper._debugTitles =
{
	[1]	= 'Info',
	[2] = 'Error',
	[3] = 'Warning',
	[4] = 'OK',
	[5] = 'Status',
	[6] = 'Debug',
	[7] = 'Admin',
}

if SERVER then
	util.AddNetworkString( 'RLibNet' )
end

/*
*	validate
*	
*	check validation of object
*
*	@param ent target
*	@return bool
*/

function helper.valid( target )
	return IsValid( target ) and true or false
end

/*
*	validate player
*	
*	checks to see if a entity is both valid and a player
*
*	@param ent target
*	@return bool
*/

function helper.pvalid( target )
	if IsValid( target ) and target:IsPlayer( ) then return true end
end

/*
*	validate entity
*	
*	Checks to see if target is entity and valid
*
*	@param ent target
*	@return bool
*/

function helper.entvalid( target )
	return isentity( target ) and target:IsValid( )
end

/*
*	validate physobject
*	
*	checks to see if a entity is both valid and a player
*
*	@param ent target
*/

function helper.physobjvalid( target )
	return ( TypeID( target ) == TYPE_PHYSOBJ ) and target:IsValid( ) and target ~= NULL
end

/*
*	uppercase first
*
*	takes the first letter of a string and transforms to upper-case
* 
*	@param str val
*	@return str
*/

function base:ucfirst( val )
	return val:gsub( '^%l', string.upper )
end

/*
*	clean string
*
*	removes spaces and specials from a string
* 
*	@param str val
*	@return str
*/

function base:str_clean( val )

	if not isstring( val ) then
		val = tostring( val )
	end

	val	= string.lower( val )
	val	= val:gsub( '%s+', '_' )

	return val
end

/*
*	string :: starts with
*
*	determines if a string starts with a particular word/char
* 
*	@param str src
*	@param str starts
*	@return str
*/

function base:str_starts( src, starts )
	if not isstring( src ) and not isstring( starts ) then return end
	return string.sub( src, 1, string.len( starts ) ) == starts
end

/*
*	string :: ends with
*
*	determines if a string ends with a particular word/char
* 
*	@param str src
*	@param str ends
*	@return str
*/

function base:str_ends( src, ends )
	if not isstring( src ) and not isstring( ends ) then return end
	return ends == '' or string.sub( src, -string.len( ends ) ) == ends
end

/*
*	string valid
*
*	simply ensures a string is cleaned up and not left blank
* 
*	@param str val
*	@return bool | str
*/

function helper.str_valid( val )

	if not isstring( val ) then return end

	val = string.Trim( val )
	if val ~= nil and val ~= '' then
		return true, val
	end

	return false, val
end

/*
*	split paths
*
*	typically used to split module paths up
* 
*	@param str val
*	@return str
*/

function base:split_paths( val )
	return val:match('(.+)/(.+)')
end

/*
*	console Log : network : format
* 
*	takes the data that will be sent to the console and formats the way it displays in the 
*	the console using columns.
*	
*	@param int type
*	@param str msg
*/

function base:_consoleFormat( mtype, msg )

	msg = string.format( '%s', msg )

	local col_1 = string.format( '%-9s', os.date( '%I:%M:%S' ) )
	local col_2 = string.format( '%-12s', '[' .. self:ucfirst( helper._debugTitles[mtype] ) .. ']' )
	local col_3 = string.format( '%-3s', '|' )
	local col_4 = string.format( '%-30s', msg )

	MsgC( Color( 0, 255, 0 ), '[' .. script .. '] ', Color( 255, 255, 255 ),  col_1, helper._consoleColors[mtype] or helper._consoleColors[1] or Color( 255, 255, 255 ), col_2, Color( 255, 0, 0 ), col_3, Color( 255, 255, 255 ), col_4 .. '\n')
end

/*
*	sets up a log message to be formatted
*	
*	@param int mtype
*	@param str msg
*	@param mix { ... }
*/

local function _formatLognet( mtype, msg, ... )

	mtype = mtype or 1
	msg = msg .. table.concat( { ... } , ', ' )

	base:_consoleFormat( mtype, msg )

end

/*
*	sends information to the debugger
*	
*	@param int mtype
*	@param str msg
*	@param mix { ... }
*	
*	@example self:logconsole( 4, 'Hello %s', 'world' )
*/

function debugger:post( mtype, msg, ... )

	if CLIENT then return end

	mtype = mtype or 1
	if not msg or not isstring( msg ) then return end

	local args = { ... }

	for ply in helper.getplayers( ) do
		-- if rlib:is_root( ply ) or rlib.permissions_validate( ply, rlib.permissions[ 'rlib_debug' ].id ) then
		if rlib:is_dev( ply ) then
			net.Start( 'rlib.debugger' )
			net.WriteInt( mtype, 4 )
			net.WriteString( msg )
			net.Send( ply )
		end
	end

end

/*
*	sends a simple string to the debugger without
*	accepting vars as a table.
*	
*	@param int mtype
*	@param str msg
*	
*	@example self:logconsole( 4, 'Hello world' )
*/

function debugger:post_simple( mtype, msg )
	if CLIENT then return end

	mtype = mtype or 1
	if not msg or not isstring( msg ) then return end

	for ply in helper.getplayers( ) do
		-- if rlib:is_root( ply ) or rlib.permissions_validate( ply, rlib.permissions[ 'rlib_debug' ].id ) then
		if rlib:is_dev( ply ) then
			net.Start( 'rlib.debugger' )
			net.WriteInt( mtype, 4 )
			net.WriteString( msg )
			net.Send( ply )
		end
	end
end

/*
*	sends visual messages in-game to a valid player
*	
*	@param int mtype
*	@param str msg
*	@param mix { ... }
*	
*	@example self:logconsole( 4, 'Hello %s', 'world' )
*/

function debugger:activate_input( ply, mtype, msg, ... )

	if not helper.pvalid( ply ) then return end
	if not msg or not isstring( msg ) then return end

	local args = { ... }

	local result, msg = pcall( string.format, msg, unpack( args ) )
	if result then
		net.Start( 'rlib.debug.ui' )
		net.WriteInt( mtype, 4 )
		net.WriteString( msg )
		net.Send( ply )
	end
end

function base:logconsole( mtype, msg, ... )

	local args = { ... }

	if mtype ~= 0 then
		local result, msg = pcall( string.format, msg, unpack( args ) )
		if result then
			_formatLognet( mtype, msg )
			debugger:post( mtype, msg, ... )
		else
			error( msg, 2 )
		end

		if SERVER and msg and ( mtype ~= 1 and mtype ~= 4  ) then
			utils:debug_write( mtype, msg )
		end
	elseif mtype == 0 then
		print(' ')
	end

end

/*
*	advanced logging which allows for any client-side errors to be 
*	sent to the server as well.
*	
*	@param str mtype
*	@param str msg
*	@param mix { ... }
*/

function base:_consolenet( mtype, msg, ... )

	if SERVER then
		msg = msg .. table.concat( { ... } , ', ' )
	end

	net.Start( 'rlib.debug.console' )
	net.WriteInt( mtype, 4 )
	net.WriteString( msg )
	net.SendToServer( )

	self:_consoleFormat( mtype, msg )

end

/*
*	sends information to the console for view
*	
*	@param str mtype
*	@param str msg
*	@param mix { ... }
*/

function base:logconsole_net( mtype, msg, ... )

	local args = { ... }

	local result, msg = pcall( string.format, msg, unpack( args ) )
	if result then
		base:_consolenet( mtype, msg )
	else
		error( msg, 2 )
	end

end

/*
*	shortens the provided string down based on a length specified
*	
*	@param str str
*	@param int limit
*	
*	@example self:truncate( 'this is a test string', 12 )
*	@return 'this is a te...'
*/

function base:truncate( str, limit, affix )
	if not limit then limit = 9 end
	if not affix then affix = '...' end

	if string.len( str ) > limit then
		str = string.sub ( str, 1, limit - 3 ) .. affix
	else
		str = string.format ( '%9s' , str )
	end

	return string.TrimLeft( str, ' ' )
end

/* 
*   sortbykey
* 
*   Assigns a ClientConvar based on the parameters specified.
*   These convars will then be used later in order for the 
*   player to modify their settings on-the-fly.
* 
*   Example
*   
*        for name, line in base.sortbykey( table ) do
*            table.insert( new_sorted_table, line )
*        end
*   
*   @return mixed
*/

function helper:sortbykey( tblsrc, funcsort )
	local a = { }
	for n in pairs( tblsrc ) do
		table.insert( a, n )
	end
	table.sort( a, funcsort )
	local i = 0
	local iter = function( )
		i = i + 1
		if a[i] == nil then
			return nil
		else
			return a[i], tblsrc[a[i]]
		end
	end
	return iter
end

/* 
*   table :: is exact
* 
*   compares two tables and determines if both
*	are identical.
*	
*	@param tbl a
*	@param tbl b
*   
*   @return bool
*/

function helper:table_isexact( a, b )

	local function compare_table( t1, t2 )

		if t1 == t2 then return true end

		for k, v in pairs( t1 ) do

			if type( t1[ k ] ) ~= type( t2[ k ] ) then
				return false
			end

			if type( t1[ k ] ) == 'table' then
				if not compare_table( t1[ k ], t2[ k ] ) then
					return false
				end
			else
				if t1[ k ] ~= t2[ k ] then
					return false
				end
			end
		end

		for k, v in pairs( t2 ) do

			if type( t2[ k ] ) ~= type( t1[ k ] ) then
				return false
			end

			if type( t2[ k ] ) == 'table' then
				if not compare_table( t2[ k ], t1[ k ] ) then
					return false
				end
			else
				if t2[ k ] ~= t1[ k ] then
					return false
				end
			end
		end

		return true
	end

	if type( a ) ~= type( b ) then
		return false
	end

	if type( a ) == 'table' then
		return compare_table( a, b )
	else
		return ( a == b )
	end

end

/* 
*	color clamp
* 
*	clamps a value to be within the boundaries of a color ( 0 - 255 )
*	defaults to white if no val specified
*	
*	@param int val
*	@return int
*/

function helper:color_c( val )
	if not val or ( not IsColor( val ) and not isnumber( val ) ) then
		return Color( 255, 255, 255, 255 )
	end
	if IsColor( val ) then
		local r = math.Clamp( math.Round( val.r ), 0, 255 )
		local g = math.Clamp( math.Round( val.g ), 0, 255 )
		local b = math.Clamp( math.Round( val.b ), 0, 255 )
		local a = math.Clamp( math.Round( val.a ), 0, 255 )

		return Color( r, g, b, a )
	else
		return math.Clamp( math.Round( val ), 0, 255 )
	end
end

/* 
*	convar :: rgba
* 
*	fetches the proper colors associated with a particular convar.
*	
*	@param str id
*	@param tbl alt
*	@return tbl
*/

function helper:cvar_color( id, alt )
	local colorList = { id .. '_red', id .. '_green', id .. '_blue', id .. '_alpha' }

	local countEntries = 0
	for _, v in pairs( colorList ) do
		if ConVarExists( v ) then
			countEntries = countEntries + 1
		end
	end

	if countEntries < 3 then
		return alt or Color( 255, 255, 255, 255 )
	elseif countEntries == 3 then
		return Color( GetConVar( id .. '_red' ):GetInt( ), GetConVar( id .. '_green' ):GetInt( ), GetConVar( id .. '_blue' ):GetInt( ) )
	elseif countEntries > 3 then
		return Color( GetConVar( id .. '_red' ):GetInt( ), GetConVar( id .. '_green' ):GetInt( ), GetConVar( id .. '_blue' ):GetInt( ), GetConVar( id .. '_alpha' ):GetInt( ) )
	end
end

/* 
*	convar :: int
* 
*	fetches the proper int associated with a particular convar.
* 
*	@param str id
*	@param int alt
*	@return int
*/

function helper:cvar_int( id, alt )
	if ConVarExists( id ) then
		return GetConVar( id ):GetInt( )
	else
		return alt or 0
	end
end

/* 
*	convar :: string
*	
*	fetches the proper str associated with a particular convar.
*	
*	@param str id
*	@param str alt
*	@return str
*/

function helper:cvar_string( id, alt )
	if ConVarExists( id ) then
		return GetConVar( id ):GetString( )
	else
		return alt or nil
	end
end

/* 
*	convar :: bool
* 
*	fetches the proper bool associated with a particular convar.
*	
*	@param str id
*	@return bool
*/

function helper:cvar_bool( id )
	if ConVarExists( id ) then
		return GetConVar( id ):GetBool( )
	else
		return false
	end
end

/*
*	bool to string
*	
*	converts a bool to a string
* 
*	@param bool bool
*	@return str
*/

function helper.booltostr( bool )
	if bool then
		return '1'
	else
		return '0'
	end
end

/*
*	integer to bool
*	
*	transforms an integer into a bool
* 
*	@param bool bool
*	@param bool cstring [optional]
*	@return mix [ bool | str ]
*/

function helper.booltoint( bool, cstring )
	local n = 0
	if bool then n = 1 end

	if cstring then
		n = tostring( n )
	end
	return n
end

/* 
*	bool to integer
*	
*	transforms a bool into an integer
* 
*	@param int int
*	@return bool
*/

function helper.inttobool( int )
	if int == 1 then
		return true
	end
	return false
end

/* 
*	type to bool toggle
*	
*	allows user-input to toggle something using common words
*	such as 'true', 'enable', 'on', etc with a boolean
*	return.
*	
*	@param mix val
*	@return bool
*/

function helper:type_toggle_bool( val )

	if not val then return end

	if ( type( val ) == 'string' ) then
		if ( val == 'true' or val == '1' or val == 'on' or val == 'enable' ) then
			return true
		elseif ( val == 'false' or val == '0' or val == 'off' or val == 'disable' ) then
			return false
		end
	elseif ( type( val ) == 'number' ) then
		if ( val == 1 ) then
			return true
		elseif ( val == 0 ) then
			return false
		end
	elseif ( type( val ) == 'boolean' ) then
		if ( val == true ) then
			return true
		elseif ( val == false ) then
			return false
		end
	end

	return false

end

/*
*	console
*
*	displays a message in the player's console
*	Used in conjunction with base.rsay
* 
*	@param ent ply
*	@param str msg
*/

function base.console( ply, msg )
	if CLIENT or ( ply and not ply:IsValid( ) ) then
		Msg( msg .. '\n' )
		return
	end

	if ply then
		ply:PrintMessage( HUD_PRINTCONSOLE, msg .. '\n' )
	else
		local players = player.GetAll( )
		for _, player in ipairs( players ) do
			player:PrintMessage( HUD_PRINTCONSOLE, msg .. '\n' )
		end
	end
end

/*
*	isconsole
*	
*	checks to see if an action was done by console instead of a player
*	
*	@param ent ply
*/

function helper:isconsole( ply )
	if not ply then return false end
	return ply:EntIndex( ) == 0 and true or false
end

/*
*	toconsole
*	
*	can determine if either the console or a player is executing a
*	console command and then return output back to that console
* 
*	@param ent ply
*	@param tbl { ... }
*/

function helper:toconsole( ply, ... )

	local args = { ... }
	table.insert( args, '\n' )

	if self:isconsole( ply ) then
		MsgC( Color( 255, 255, 255 ), unpack( args ) )
	else
		ply:sendconsole( ... )
	end
end

/*
*	cmsg
*	
*	sends a message as either a private or broadcast using style properties
*	
*	@param ent ply
*	@parem str parent
*	@param str subcategory
*	@param mix { ... }
*/

function helper:cmsg( ply, parent, subcategory, ... )

	if not settings then
		base:logconsole( 2, 'helper cmsg missing style table' )
		return false
	end

	if helper.pvalid( ply ) then
		ply:CMessage( settings.cmsg_color_category, '[' .. settings.cmsg_private_tag .. '] ', settings.cmsg_color_subcategory, '[' .. string.upper( subcategory ) .. '] ', settings.cmsg_color_message, ... )
	else
		base:Broadcast( settings.cmsg_color_category, '[' .. settings.cmsg_server_tag .. '] ', settings.cmsg_color_subcategory, '[' .. string.upper( subcategory ) .. '] ', settings.cmsg_color_message, ... )
	end

end

/*
*	gmsg
*	
*	Can send a message via multiple routes
*	If console, the message reply will simply go back to 
*	the console.
*	
*	If player, the reply output will be sent both to
*	their chat using CMessage, and to their console
*	using toconsole.
*	
*	Since sending to player chat has a tendency to also
*	add to the player console, toconsole has been added.
* 
*	@param ent ply
*	@param tbl { ... }
*/

function helper:gmsg( ply, toconsole, ... )

	local args = { ... }
	table.insert( args, '\n' )

	if ply and ply ~= nil then
		if self:isconsole( ply ) then
			MsgC( Color( 255, 255, 255 ), unpack( args ) )
		else
			if toconsole then
				ply:sendconsole( ... )
			end
			ply:CMessage( ... )
		end
	else
		rlib:Broadcast( ... )
	end
end

/*
*	parent owners
*	
*	fetches the parent script owners to use in
*	a table
*	
*	@param tbl source
*/

function base:parent_owners( source )
	source = source or base.scripts

	if not istable( source ) then
		base:logconsole( 2, 'Invalid table specified for parent_owner' )
		return false
	end

	for _, v in pairs( base.scripts ) do
		if type( v.script.owner ) == 'string' then
			if self:valid_steam64( v.script.owner ) and not table.HasValue( base.o, v.script.owner ) then
				table.insert( base.o, v.script.owner )
			end
		elseif type( v.script.owner ) == 'table' then
			for t, i in pairs( v.script.owner ) do
				if self:valid_steam64( i ) and not table.HasValue( base.o, i ) then
					table.insert( base.o, i )
				end
			end
		end
	end

	return base.o
end

/*
*	is owner
*	
*	returns if a player is the owner of a script
*	
*	@param ent ply
*/

function base:is_owner( ply )
	if not ply then return end
	if not self.h.pvalid( ply ) then return end

	local owners = { }
	owners = base:parent_owners( )

	if table.HasValue( owners, ply:SteamID64( ) ) then
		return true
	end

	return false
end

/*
*	is root
*	
*	ply must either be console, a script owner, or
*	have superadmin permissions.
*	
*	functionality with this restriction means very few people
*	will be able to use the feature.
*	
*	@param ent ply
*	@param bool bBlockConsole
*/

function base:is_root( ply, b_blkconsole )
	if not b_blkconsole and self.h:isconsole( ply ) then
		return true
	else
		if self.h.pvalid( ply ) then
			if self:is_owner( ply ) then
				return true
			elseif ply:IsSuperAdmin( ) then
				return true
			end
		end
	end
	return false
end

/*
*	is developer
*	
*	rlib features a developer console which should only
*	be accessed by the developer of the script.
*	
*	this doesnt give the developer any special
*	permissions to do anything to a server other than
*	to read more in-depth debugging info
*	
*	script owners could have access but i felt it may
*	be annoying to server owners to have text
*	scrolling in the bottom right of their screen.
*	
*	@param ent ply
*/

function base:is_dev( ply )
	if self.h:isconsole( ply ) then
		return true
	else
		if not rlib.manifest.developers then return end
		local devs = rlib.manifest.developers or { }

		if table.HasValue( devs, ply:SteamID64( ) ) then
			return true
		end
	end
	return false
end

/*
*	return a split ip and port from target
*	
*	@param str val
*/

function base:format_ipport( val )
	return unpack( string.Split( val, ':' ) )
end

/*
*	return the server hostname
*	@return str
*/

function base:server_hostname( )
	return GetHostName( ) or 'unknown server'
end

/*
*	return the current ip address and port for the server
*/

function base:server_ipport( )
	return self:format_ipport( game.GetIPAddress( ) )
end

/*
*	create hash from server ip and port
*	
*	@return str
*/

function base:server_hash( )
	local ip, port = base:server_ipport( )
	if not ip then return end
	port = port or '27015'

	local checksum = util.CRC( ip .. port )
	return string.format( '%x', checksum )
end

/*
*	return now timestamp
*	
*	@param str flags
*	@return str
*/

function helper:time_now( flags )
	flags = flags or '%Y-%m-%d %H:%M:%S'
	return os.date( flags )
end

/*
*	checks to see if a provided steam32 is valid
*	
*	@param str steamid
*	@return bool
*/

function base:valid_steam32( sid )
	return sid:match( '^STEAM_%d:%d:%d+$' ) ~= nil
end

/*
*	checks to see if a provided steam64 is valid
*	
*	@param str sid
*	@return bool
*/

function base:valid_steam64( sid )
	if sid then
		return sid:match( '^7656%d%d%d%d%d%d%d%d%d%d%d%d%d+$' ) ~= nil
	end
	return false
end

/*
*	canvert steam 32 -> 64
*	
*	@reference https://developer.valvesoftware.com/wiki/SteamID
*	
*	@param str sid
*	@return str
*/

function base:sid_32to64( sid )
	if not sid or not self:valid_steam32( sid ) then
		local ret = 'nil'
		if sid and sid ~= nil then ret = sid end
		base:logconsole( 2, 'Cannot convert invalid steam32 [%s]', ret )
		return false
	end

	sid = string.upper( sid )

	local prefix	= '7656'
	local segs		= string.Explode( ':', string.sub( sid, 7 ) )
	local to64		= ( 1197960265728 + tonumber( segs[ 2 ] ) ) + ( tonumber( segs[ 3 ] ) * 2 )
	local output	= string.format( '%f', to64 )

	return prefix .. string.sub( output, 1, string.find( output, '.', 1, true ) - 1 )
end

/*
*	canvert steam 64 -> 32
*	
*	@reference https://developer.valvesoftware.com/wiki/SteamID
*	
*		STEAM_X:Y:Z
*			X = universe ( 0 - 5 | def. 0 )
*			Y = Lowest bit for acct id ( 0 or 1 )
*			Z = upper 31 bits for acct id
*	
*		Universes
*			0	Individual / Unspecified
*			1	Public
*			2	Beta
*			3	Internal
*			4	Dev
*			5	RC
*	
*	@param str sid
*	@param int x [optional]
*	@return str
*/

function base:sid_64to32( sid, x )

	if not sid or tonumber( sid ) == nil then
		local ret = 'nil'
		if sid and sid ~= nil then ret = sid end
		base:logconsole( 2, 'Cannot convert invalid steam64 [%s]', ret )
		return false
	end

	x = x or 0
	if x > 5 then x = 0 end

	local base		= 6561197960265728
	local from64	= tonumber( sid:sub( 2 ) )
	local y			= from64 % 2 == 0 and 0 or 1
	local z			= math.abs( base - from64 - y ) / 2

	return 'STEAM_' .. x .. ':' .. y .. ':' .. ( y == 1 and z - 1 or z )

end

/*
*	checks to see if an ip address is valid
*	
*	@param str ip
*	@return mix 
*/

function base:valid_ipaddress( ip )
	return ip:find( '^%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?$' ) and true or false
end

/*
*	attempts to locate a player by the specified name
*	
*	@param str name
*	@return ent
*/

function helper:whois_name( name )
	local val = nil
	for i, v in pairs( player.GetAll( ) ) do
		if v.Nick( ) == name then val = v end
	end
	return val
end

/*
*	attempts to locate a darkrp job by the specified name in a wildcard fashion (partial name matches)
* 
*	@param str name
*	@return ent
*/

function helper:whois_wildcard( name )
	name = string.lower( name )
	local cnt = 0
	local result = false
	for _, v in ipairs( player.GetAll( ) ) do
		if ( string.find( string.lower( v:Name( ) ), name, 1, true) ~= nil ) then
			result = v
			cnt = cnt + 1
		end
	end

	return cnt, result
end

/*
*	attempts to locate a darkrp job by the specified name
* 
*	@param str name
*	@return tbl
*/

function helper:locate_rp_job( name )
	if not RPExtraTeams then
		base:logconsole( 2, 'darkrp table RPExtraTeams does not exist -- check your gamemode' )
		return false
	end

	local retval = nil
	for i, v in pairs( RPExtraTeams ) do
		if string.lower( v.name ) == string.lower( name ) then
			retval = { i, v }
		end
	end
	return retval
end

/*
*	count from a min and max number set
* 
*	@param int from
*	@param int to
*/

function calc.sequence( from, to )
	return coroutine.wrap( function( )
		for i = from, to do
			coroutine.yield( i )
		end
	end )
end

/*
*	return list of all players
*/

function helper.getplayers( )
	return coroutine.wrap( function( )
		for _, v in pairs( player.GetAll( ) ) do
			coroutine.yield( v )
		end
	end )
end

/*
*	return list of all bots
*/

function helper.getbots( )
	return coroutine.wrap( function( )
		for _, v in pairs( player.GetBots( ) ) do
			coroutine.yield( v )
		end
	end )
end

/*
*	return list of all ents
*/

function helper.getents( )
	return coroutine.wrap( function( )
		for _, v in pairs( ents.GetAll( ) ) do
			coroutine.yield( v )
		end
	end )
end

/*
*	return list of all items in table
*	
*	@param tbl tbl
*/

function helper.getdata( tbl )
	if not istable( tbl ) then return end
	return coroutine.wrap( function( )
		for _, v in pairs( tbl ) do
			coroutine.yield( v )
		end
	end )
end

/*
*	shuffles items in a table
*	
*	@param tbl tbl
*/

function helper.shuffle_table( tbl )
	if not istable( tbl ) then return end
	return coroutine.wrap( function( )
		size = #tbl
		for i = size, 1, -1 do
			local rand = math.random( size )
			tbl[ i ], tbl[ rand ] = tbl[ rand ], tbl[ i ]
		end
		coroutine.yield( tbl )
	end )
end

/*
*	return counted items
*	
*	@usage mdata = helper.countdata( settings.table, 'tablerow' )( )
*	@param tbl tbl
*	@param int count
*	@param str target
*	@param str check
*/

function helper.countdata( tbl, count, target, check )
	if not istable( tbl ) then return end
	count = isnumber( count ) and count or 1
	return coroutine.wrap( function( )
		local data_cnt = 0
		for _, v in pairs( tbl ) do
			if check and not v[ check ] then continue end
			if target and v[ target ] then
				data_cnt = data_cnt + v[ target ] + count
			else
				data_cnt = data_cnt + count
			end
		end
		coroutine.yield( data_cnt )
	end )
end

/*
*	formats time into a human readable format
*	
*	@param int time
*	@return str
*/

function calc.secs_to_short( time, bShowEmpty )
	local str = ''
	local set_format = '%02.f'

	time = tonumber( time ) or 0
	if time < 0 then time = 0 end
	time = math.Round( time )

	local is_lowpoint = time < 60 and true or false

	local days = string.format( set_format, math.floor( ( time - time % 86400 ) / 86400 ) )
	time = time - days * 86400

	local hours = string.format( set_format, math.floor( ( time - time % 3600 ) / 3600 ) )
	time = time - hours * 3600

	local minutes = string.format( set_format, math.floor( ( time - time % 60 ) / 60 ) )
	time = time - minutes * 60

	local seconds = string.format( '%02d', time )

	if ( is_lowpoint and ( ( not bShowEmpty and seconds ~= 0 ) or bShowEmpty ) ) then
		seconds = math.abs( seconds )
		str = seconds .. 's'
	end

	if ( not is_lowpoint and ( ( not bShowEmpty and minutes ~= 0 ) or bShowEmpty ) ) then
		str = minutes .. 'm ' .. str
	end

	if ( not is_lowpoint and ( ( not bShowEmpty and hours ~= 0 ) or bShowEmpty ) ) then
		str = hours .. 'h ' .. str
	end

	if ( not is_lowpoint and ( ( not bShowEmpty and days ~= 0 ) or bShowEmpty ) ) then
		str = days .. 'd ' .. str
	end

	return str
end

/*
*	formats time into a human readable format
*	
*	@param int time
*	@return str
*/

function calc.secs_to_short_s( time )
	local set_format = '%02.f'

	time = tonumber( time ) or 0
	if time < 0 then time = 0 end
	time = math.Round( time )

	local days_raw = math.floor( ( time - time % 86400 ) / 86400 )
	local days = string.format( set_format, days_raw )
	time = time - days * 86400

	local hours_raw	= math.floor( ( time - time % 3600 ) / 3600 )
	local hours	= string.format( set_format, hours_raw )
	time = time - hours * 3600

	local minutes_raw = math.floor( ( time - time % 60 ) / 60 )
	local minutes = string.format( set_format, minutes_raw )
	time = time - minutes * 60

	local seconds = string.format( set_format, time )

	if days_raw > 0 then
		return days .. 'd '
	end

	if hours_raw > 0 then
		return hours .. 'h '
	end

	if minutes_raw > 0 then
		return minutes .. 'm '
	end

	if time < 60 then
		return seconds .. 's'
	end

end

/*
*	formats time into a human readable format
*	
*	@ex	1:23 == 1 minute : 23 seconds
*	@param int time
*	@return str
*/

function calc.secs_shorthand( time )
	local str = ''

	time = time and tonumber( time ) or 0

	local hours = ( time - time % 3600 ) / 3600
	time = time - hours * 3600
	local minutes = ( time - time % 60 ) / 60
	time = time - minutes * 60
	local seconds = string.format( '%02d', time )

	if seconds ~= 0 then
		str = seconds
	end

	if minutes ~= 0 then
		if seconds == 0 then
			str = minutes .. '' .. str
		else
			str = minutes .. ':' .. str
		end
	end

	if hours ~= 0 then
		str = hours .. ':' .. str
	end

	return str
end

/*
*	seconds to string
*	
*	calculates how many seconds are within the current timeframe. Added support
*	for seconds, minutes, and hours (just in case).
*	
*	@param int seconds
*	@return str
*/

function calc.secs_to_str( seconds )

	seconds = seconds and tonumber( seconds ) or 0

	local mins, secs, hours = 0

	if seconds <= 0 then
		return '00:00'
	else
		hours	= string.format( '%02.f', math.floor( seconds / 3600 ) )
		mins	= string.format( '%02.f', math.floor( seconds / 60 - ( hours * 60 ) ) )
		secs	= string.format( '%02.f', math.floor( seconds - hours * 3600 - mins * 60 ) )

		return mins .. ':' .. secs
	end
end

/*
*	format seconds to short-hand readable format
*	
*	@example 00w 01d 21h 55m 19s
*	@param int time
*	@return str
*/

function calc.secs_to_abbrev( time )

	time = time and tonumber( time )

	local tmp = time
	local s = tmp % 60
	tmp = math.floor( tmp / 60 )
	local m = tmp % 60
	tmp = math.floor( tmp / 60 )
	local h = tmp % 24
	tmp = math.floor( tmp / 24 )
	local d = tmp % 7
	local w = math.floor( tmp / 7 )

	return string.format( '%02iw %02id %02ih %02im %02is', w, d, h, m, s )
end

/*
*	is_inf
*	
*	@param int num
*	@return bool
*/

function calc.is_inf( num )
	return not ( num ~= num or num == math.huge or num == -math.huge )
end

/*
*	is_num
*	
*	checks for valid number
*	
*	@param int num
*	@return bool
*/

function calc.is_num( num )
	num = num and tonumber( num )

	if num ~= num then return false end
	if not num or not isnumber( num ) or num <= 0 then return false end
	if num == math.huge or num == -math.huge then return false end

	return true
end

/*
*	create random string based on int length
*	
*	@param int int
*	@return str
*/

function calc.rand_string( int, min, max )

	int = int and tonumber( int ) or 1
	min = min and tonumber( min ) or 50
	max = max and tonumber( max ) or 100

	math.randomseed( os.time( ) )
	local s = ''

	for i = 1, int do
		s = s .. string.char( math.random( min, max ) )
	end

	return s
end

/*
*	return bench time
*	
*	@param int seconds
*	@param int offset [optional]
*	@return str
*/

function calc.benchtime( seconds, offset )

	seconds = seconds and tonumber( seconds ) or 0
	offset = offset and tonumber( offset ) or 0

	if seconds < 1 then
		return math.Truncate( seconds, 3 ) .. ' ms'
	else
		local time = math.Truncate( seconds, 2 )
		if offset and offset > 0 then
			time = time - offset
		end
		return time .. ' s'
	end
end

/*
*	return bytes to human readable
*	
*	@param int bytes
*	@return str
*/

function calc.bytes_size( bytes )
	local rpos = 2
	local kb = 1024
	local mb = kb * 1024
	local gb = mb * 1024
	local tb = gb * 1024

	if ( ( bytes >= 0 ) and ( bytes < kb ) ) then
		return bytes .. ' Bytes'
	elseif ( ( bytes >= kb ) and ( bytes < mb ) ) then
		return math.Round( bytes / kb, rpos ) .. ' KB'
	elseif ( ( bytes >= mb ) and ( bytes < gb ) ) then
		return math.Round( bytes / mb, rpos ) .. ' MB'
	elseif ( ( bytes >= gb ) and (bytes < tb ) ) then
		return math.Round(bytes / gb, rpos ) .. ' GB'
	elseif ( bytes >= tb ) then
		return math.Round( bytes / tb, rpos ) .. ' TB'
	else
		return bytes .. ' B'
	end
end

/*
*	return the operating system for the server the script is running on
*	
*	@return str
*/

function base:os( )
	if system.IsWindows( ) then
		return 1, 'Windows'
	elseif system.IsLinux( ) then
		return 2, 'Linux'
	else
		return 0, 'Unknown'
	end
end

/*
*	checks if the provide param is a function
*	
*	@param mix obj
*	@return bool
*/

function base:isfunction( obj )
	if ( type( obj ) == 'function' ) then
		return true
	end
	return false
end

/*
*	Checks if the provide param is a table
*	
*	@param mix obj
*	@return bool
*/

function base:istable( obj )
	if ( type( obj ) == 'table' ) then
		return true
	end
	return false
end

/*
*	created a hash of a speciifed length
*	
*	@param int len
*	@return str
*/

function base:create_hash( len )
	if ( len == nil or len <= 0 ) then len = 16 end
	local response = ''

	local charset =
	{
		'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
		'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
		'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
		'U', 'V', 'W', 'X', 'Y', 'Z'
	}

	for i = 1, len do
		local index = math.random( 1, #charset )
		response = response .. charset[ index ]
	end

	return tostring( response )
end

/*
*	allowed characters
*
*	The characters that a player is allowed to use when they are using an input field.
*	Anything not in the following table will be classified as an invalid character.
*	
*	@param str text
*	@return bool
*/

function helper:is_alpha( text )

	local filter_alphalist =
	{
		'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o',
		'p', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k',
		'l', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ' '
	}

	for k in string.gmatch( text, '.' ) do
		if table.HasValue( filter_alphalist, string.lower( k ) ) then
			return true
		end
	end

	return false

end

/*
*	allowed numbers
*	
*	The listed values in the local table will determine what characters are allowed 
*	in the function being used.
*	
*	@param str text
*	@return bool
*/

function helper:is_number( text )

	text = tostring( text )
	local filter_numlist = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' }

	for k in string.gmatch( text, '.' ) do
		if table.HasValue( filter_numlist, string.lower( k ) ) then
			return true
		end
	end

	return false

end

/*
*	alpha-numerical
*
*	allows for a string to only contain alphanumerical characters.
*	
*	@param str text
*	@return bool
*/

function helper:is_alphanumerical( text )

	local filter_anumlst =
	{
		'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', 'a', 's',
		'd', 'f', 'g', 'h', 'j', 'k', 'l', 'z', 'x', 'c', 'v', 'b',
		'n', 'm', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
	}

	for k in string.gmatch( text, '.' ) do
		if table.HasValue( filter_anumlst, string.lower( k ) ) then
			return true
		end
	end

	return false

end

/*
* 	throwBadArg
*
* 	throws an error similar to the lua 'bad argument #x to 
* 	<fn_name> (<type> expected, got <type>).
* 
* 	@param int argnum [optional]
* 	@param str fnName [optional]
* 	@param str expected [optional]
* 	@param mix data [optional]
* 	@param int throwLevel [optional]
* 	@return err
*/

function base.throwBadArg( argnum, fnName, expected, data, throwLevel )
	throwLevel = throwLevel or 3

	local str = 'bad argument'
	if argnum then
		str = str .. ' #' .. tostring( argnum )
	end
	if fnName then
		str = str .. ' to ' .. fnName
	end
	if expected or data then
		str = str .. ' ('
		if expected then
			str = str .. expected .. ' expected'
		end
		if expected and data then
			str = str .. ', '
		end
		if data then
			str = str .. 'got ' .. type( data )
		end
		str = str .. ')'
	end

	error( str, throwLevel )
end

/*
*	checkarg
*	
*	Throws an error similar to the lua 'bad argument #x to 
*	<fn_name> (<type> expected, got <type>).
*	
*	credit to ulx/ulib devs for functionality, used for servers
*	that may not use ulx/ulib (unfortunate)
*	
*	@param int argnum [optional]
*	@param str fnName [optional]
*	@param str expected [optional]
*	@param mix data [optional]
*	@param int throwLevel [optional]
*	@return err (bad data) OR ELSE nil
*/

function base.checkArg( argnum, fnName, expected, data, throwLevel )
	throwLevel = throwLevel or 4
	if type( expected ) == 'string' then
		if type( data ) == expected then
			return
		else
			return base.throwBadArg( argnum, fnName, expected, data, throwLevel )
		end
	else
		if table.HasValue( expected, type( data ) ) then
			return
		else
			return base.throwBadArg( argnum, fnName, table.concat( expected, ',' ), data, throwLevel )
		end
	end
end

if CLIENT then

	local function RLibnet( )
		local fn_string 	= net.ReadString( )
		local args 			= net.ReadTable( )
		local success, func = ULib.findVar( fn_string )

		if not success or type( func ) ~= 'function' then return error( 'Received bad RPC, invalid function (' .. tostring( fn_string ) .. ')!' ) end

		local max = 0
		for k, v in pairs( args ) do
			local n = tonumber( k )
			if n and n > max then
				max = n
			end
		end

		func( unpack( args, 1, max ) )
	end
	net.Receive( 'RLibNet', RLibnet )

	function base.d.rsay( msg, color, duration, fade )
		color = color or Color( 255, 255, 255, 255 )
		duration = duration or 10
		fade = fade or 0.5
		local start = CurTime()

		local function drawToScreen()
			local alpha = 255
			local dtime = CurTime() - start

			if dtime > duration then
				hook.Remove( 'HUDPaint', prefix .. 'draw_notification' )
				return
			end

			if fade - dtime > 0 then
				alpha = (fade - dtime) / fade
				alpha = 1 - alpha
				alpha = alpha * 255
			end

			if duration - dtime < fade then
				alpha = (duration - dtime) / fade
				alpha = alpha * 255
			end
			color.a  = alpha

			draw.DrawText( msg, 'classsystem.notification', ScrW() * 0.5, ScrH() * 0.25, color, TEXT_ALIGN_CENTER )
		end

		hook.Add( 'HUDPaint', prefix .. 'draw_notification', drawToScreen )
	end
end

/*
*	rsay
*	
*	prints a message in center of the screen as well as in the user's consoles.
*	
*	Parameters:
*		ply - The player to print to, set to nil to send to everyone. (Ignores this param if called on client)
*		msg - The message to print.
*		color - *(Optional, defaults to 255, 255, 255, 255)* The color of the text.
*		duration - *(Optional)* The amount of time to show the text.
*		fade - *(Optional, defaults to 0.5)* The length of fade time
*/

function base.rsay( ply, msg, color, duration, fade )
	if CLIENT then
		base.d.rsay( msg, color, duration, fade )
		Msg( msg .. '\n' )
		return
	end

	if ULib then
		base.clnetlib( ply, 'rlib.d.rsay', msg, color, duration, fade )
		base.console( ply, msg )
	end
end

if SERVER then
	function base.clnetlib( plys, func, ... )
		base.checkArg( 1, 'rlib.clnetlib', { 'nil', 'Player', 'table' }, plys )
		base.checkArg( 2, 'rlib.clnetlib', { 'string' }, func )

		net.Start( 'RLibNet' )
		net.WriteString( func )
		net.WriteTable( { ... } )
		if plys then
			net.Send( plys )
		else
			net.Broadcast( )
		end
	end
end

/*
*	ratio
*
*	Gets the average amount of two numbers while keeping the number 
*	out of the negative.
*	
*	@param int k
*	@param int v
*	@return str
*/

function calc.ratio( k, v )

	local ratio = 0.00

	k = tonumber( k ) or 0
	v = tonumber( v ) or 0

	if ( v == 0 and k == 0 ) then
		ratio = 0.00
	else
		if v == 0 then v = 1 end

		ratio = math.Round( k / v, 2 )

		if k == 0 and v > 0 then
			ratio = -v
		elseif k == v then
			ratio = 1
		elseif k > 0 and v == 0 then
			ratio = k
		end
	end

	return string.format( '%.2f', ratio )

end

/*
*	integer to percent string
*
*	@param int num
*	@return str
*/

function calc.int_to_percent( num )
	num = tostring( num ) or 0
	if string.match( num, '%.' ) then
		num = num .. '0'
	else
		num = num .. '.00'
	end

	return string.match( num, '^(%d+%.%d%d)' )
end

/*
*	integer to percent
*
*	@param int num
*	@return int
*/

function calc.topercent( num, max )
	num = tonumber( num )
	max = max and tonumber( max ) or 100

	local pcalc = 100 * num / max
	pcalc = math.Clamp( pcalc, 0, 100 )
	pcalc = math.Round( pcalc )

	return pcalc
end

/*
*	permissions_ulx
*	
*	specifies the default usergroup that will be allowed
*	to access a command.
*	
*	@assoc	base.permissions_initialize( )
*	
*	@param str permission
*	@return tbl
*/

function base.permissions_ulx( permission )

	local group_perms =
	{
		[ 'superadmin' ]	= ULib.ACCESS_SUPERADMIN,
		[ 'admin' ]			= ULib.ACCESS_ADMIN,
		[ 'operator' ]		= ULib.ACCESS_OPERATOR,
		[ 'all' ]			= ULib.ACCESS_ALL
	}

	if permission and group_perms[ permission ] then
		return group_perms[ permission ]
	else
		return group_perms[ 'superadmin' ]
	end

end

/*
*	permissions initialize
*	
*	At server start, load all permissions provided through
*	a table.
*	
*	If no table specified; it will load the base script permissions
*	which should be in base.permissions table
*
*	@param tbl perms
*/

function base.permissions_initialize( perms )
	if CLIENT then return end

	if not perms then perms = base.permissions end

	-- local permissions = { ['superadmin'] = 'superadmin', ['admin'] = 'admin', ['operator'] = 'operator', ['all'] = 'user' }

	local category = 'General'
	if perms[ 'index' ] and perms[ 'index' ].category then
		category = perms[ 'index' ].category
	end

	for k, v in pairs( perms ) do
		if k == 'index' then continue end
		if v.is_linkedonly then continue end
		if perms[ k ].category then
			category = perms[ k ].category
		end
		if ulx then
			local ulx_usrgroup = base.permissions_ulx( perms[ k ].accesslvl )
			ULib.ucl.registerAccess( k, ulx_usrgroup, perms[ k ].description, category )
		end
		if rlib.settings.debug then
			rlib:logconsole( 6, 'Registered permission %s', perms[k].id )
		end
	end

	if serverguard then
		for k, v in pairs( perms ) do
			serverguard.permission:Add( k )
		end
	end

end
hook.Add( 'InitPostEntity', prefix .. 'permissions_initialize', base.permissions_initialize )

/*
*	validate permissions
*	
*	Checks to see if a player has permission to utilize
*	the desired permission.
*
*	@usage base.permissions_validate( ply, base.permissions['core_permission_name'].id )
*	
*	@param ent self
*	@param str permission
*	@return bool
*/

function base.permissions_validate( self, permission )

	if not IsValid( self ) then
		if helper:isconsole( self ) then return true end
		return false
	end

	-- Work around for the occasional ulib.authed error
	local unique_id = self:UniqueID()
	if CLIENT and game.SinglePlayer() then unique_id = '1' end

	if self:IsSuperAdmin( ) then return true end
	if base:is_root( self ) then return true end

	if permission and isstring( permission ) then
		if ulx then
			if not ULib or not ULib.ucl.authed[ unique_id ] then return end
			if ULib.ucl.query( self, permission ) then return true end
		elseif maestro then
			if maestro.rankget( maestro.userrank( self ) ).flags[ permission ] then return true end
		elseif evolve then
			if self:EV_HasPrivilege( permission ) then return true end
		elseif serverguard then
			if serverguard.player:HasPermission( self, permission ) then return true end
		end
	end

	return false
end

/*
*	has dependencies
*	
*	checks to see if a function has the required dependencies
*	such as rlib, the rcore, and the module associated to the
*	function
*	
*	@param ent self
*	@param str permission
*	@return bool
*/

function base.has_dependencies( req_base, req_mod )

	if not req_base then
		local trcback = debug.traceback( )
		base:logconsole( 2, 'cannot execute :: missing required dependency [ %s ]\n%s', 'base', tostring( trcback ) )
		return false
	end

	if not req_mod then
		local trcback = debug.traceback( )
		base:logconsole( 2, 'cannot execute :: missing required dependency module\n%s', tostring( trcback ) )
		return false
	end

	return true

end

/*
*	has permission
*	
*	see if the executing player has permission to
*	utilize the specified task
*	
*	@param ent self
*	@param str permission
*	@return bool
*/

function base.has_permission( self, permission )

	if not self then
		-- local trcback = debug.traceback( )
		-- base:logconsole( 2, 'cannot validate permission for missing target\n%s', tostring( trcback ) )
		-- return
	end

	if base.permissions_validate( self, permission ) then
		return true
	end

	local str_perm = permission and tostring( permission ) or 'requested action'

	if SERVER then
		helper:gmsg( self, false, Color( 255, 255, 0 ), '[' .. base.manifest.name .. '] ', Color( 255, 255, 255 ), 'invalid permission to access ', Color( 13, 134, 255 ), str_perm )
	elseif CLIENT then
		print( '[' .. base.manifest.name .. '] invalid permission to access' )
	end

	return false
end

/*
*	helper :: timers
*	
*	These functions deal with timer validation and 
*	assignment.
*	
*	@param str id
*	@return bool
*/

function helper.is_timer( id )
	if timer.Exists( id ) then
		return true
	end
	return false
end

/*
*	helper :: kill
*	
*	destroys a timer if it exists
*	
*	@param str id
*/

function helper.timer_kill( id )
	if timer.Exists( id ) then
		timer.Remove( id )
	end
end

/*
*	helper :: halt
*	
*	pauses a timer if it exists
*	
*	@param str id
*/

function helper.timer_halt( id )
	if timer.Exists( id ) then
		timer.Pause( id )
	end
end

/*
*	helper :: resume
*	
*	continues a timer where it left off
*	
*	@param str id
*/

function helper.timer_resume( id )
	if timer.Exists( id ) then
		timer.UnPause( id )
	end
end

/*
*	helper :: time left
*	
*	returns the time in seconds remaining on a valid timer
*	
*	@param str id
*	@return int
*/

function helper.timer_left( id )
	if timer.Exists( id ) then
		return math.Round( timer.TimeLeft( id ) )
	end
end

/*
*	helper :: timer create
*	
*	created a detailed timer.
*	
*	@todo cache timers to storage
*	@param str id
*	@return int
*/

function helper.timer_c( id, delay, reps, func )
	if not id then
		local trcback = debug.traceback( )
		base:logconsole( 2, 'cannot create timer :: invalid id\n%s', tostring( trcback ) )
		return false
	end

	id		= prefix .. tostring( id )
	delay	= delay or 0.1
	reps	= reps or 1

	if not func or not base:isfunction( func ) then
		func = function( ) end
	end

	timer.Create( id, delay, reps, func )
end

/*
*	helper :: table del index
*	
*	removes a specified number of table indexes
*	
*	@param tbl tbl
*	@param int int
*/

function helper:table_rmindex( tbl, int )

	if not istable( tbl ) then
		base:logconsole( 2, 'cannot remove table indexes without valid table' )
		return
	end

	int = int or 1

	for i = 1, int do
		table.remove( tbl, 1 )
	end
end

/*
*	helper :: garbage
*	
*	Loops through the provided table and sets objects to nil
*	rendering them deleted. Used to cleanup objects no longer
*	needed by the system.
*
*	@example helper.garbage( 'id', { object_1, object2, ... } )
*	@param str id
*	@param tbl trash
*/

function helper:garbage( id, trash )

	if not id then id = 'unknown' end

	if not trash or not istable( trash ) then
		rlib:logconsole( 2, 'Cannot clean garbage for [%s]', id )
		return
	end

	local cnt = 0
	for _, v in pairs( trash ) do
		v = nil
		cnt = cnt + 1
	end

	rlib:logconsole( 6, 'Dumped [%i] objects to garbage [%s]', cnt, id )
end

/*
* 	create directory
* 
* 	creates a new directory based on the specified parameters
* 
*	@param str name
*	@param str path
*/

function base:create_dir( name, path )
	name = name or 'rlib'
	path = path or 'DATA'
	if not file.Exists( name, path ) then
		file.CreateDir( name )
		self:logconsole( 6, 'Created directory %s', name )
	end
end

/*
*	append to file
* 
* 	adds additional data to EOF
* 
*	@param str name
*	@param str target
*	@param str data
*	@param str path
*/

function base:append_file( name, target, data, path )

	if CLIENT then return end

	name = name or 'rlib'
	path = path or 'DATA'

	if not target then
		self:logconsole( 2, 'cannot append without filename' )
		return
	end

	if not data then
		self:logconsole( 2, 'cannot append blank data' )
		return
	end

	if file.Exists( name, path ) then
		file.Append( name .. '/' .. target, data )
		file.Append( name .. '/' .. target, '\r\n' )
	end
end

/*
*	recursive loading
* 
*	cycle through files and folders at root and sub levels
* 
*	@param str name
*	@param str path
*	@param str loc [optional]
*/

function base:addfile_recurv( name, path, loc )

	if CLIENT then return end

	name = name or script

	if not path then
		self:logconsole( 6, 'cannot add resource files without path for %s', tostring( name ) )
		return false
	end

	loc = loc or 'LUA'

	local files, folders = file.Find( path .. '/*', loc )

	/*
	*	add folders
	*/

	for _, v in pairs( folders ) do
		self:addfile_recurv( name, path .. '/' .. v, loc )
	end

	/*
	*	add files
	*/

	for _, v in pairs( files ) do
		resource.AddFile( path .. '/' .. v )
		self:logconsole( 6, '[%s] [fastdl] %s', tostring( name ), v )
	end

end

/*
*	data folder creation
* 
*	creates a new set of folders within the data folder for
*	storage of a feature
* 
*	@param str parent
*	@param str sub [optional]
*	@param str sub2 [optional]
*/

function base:cdata_create( parent, sub, sub2 )

	if CLIENT then return end

	if not parent then
		rlib:logconsole( 6, 'cannot create data folders without a valid dir' )
		return false
	end

	local fol_parent = tostring( parent )

	if not helper:is_alphanumerical( fol_parent ) then
		rlib:logconsole( 2, 'parent folder contains invalid characters, must be alpha-numerical' )
		return false
	end

	if not file.Exists( fol_parent, 'DATA' ) then
		file.CreateDir( fol_parent )
		rlib:logconsole( 6, 'created datafolder [%s]', fol_parent )
	end

	if not sub then return end

	local fol_sub = tostring( sub )

	if not helper:is_alphanumerical( fol_sub ) then
		rlib:logconsole( 2, 'sub folder contains invalid characters, must be alpha-numerical' )
		return false
	end

	if not file.Exists( fol_parent .. '/' .. fol_sub, 'DATA' ) then
		file.CreateDir( fol_parent .. '/' .. fol_sub )
		rlib:logconsole( 6, 'created datafolder sub [%s]', fol_sub )
	end

	if not sub2 then return end

	local fol_sub2 = tostring( sub2 )

	if not helper:is_alphanumerical( fol_sub2 ) then
		rlib:logconsole( 2, 'sub folder contains invalid characters, must be alpha-numerical' )
		return false
	end

	if not file.Exists( fol_parent .. '/' .. fol_sub .. '/' .. fol_sub2, 'DATA' ) then
		file.CreateDir( fol_parent .. '/' .. fol_sub .. '/' .. fol_sub2 )
		rlib:logconsole( 6, 'created datafolder sub [%s]', fol_sub2 )
	end

end

/*
*	storage :: read data
* 
*	reads saved data using the glon module from
*	a specified file in the data folder
*	
*	if no path is specified, data will be saved
*	in /data/rlib
*	
*	requires glon module to be installed (comes with rlib)
*	
*	@param str src
*	@param str path [optional]
*	@return tbl
*/

function storage:data_read( src, path )

	if not glon then
		rlib:logconsole( 2, '[%s] module missing - aborting request', 'glon' )
		return false
	end

	if not src then
		rlib:logconsole( 2, 'cannot read without valid file' )
		return false
	end

	path = path or 'rlib'

	local f_src		= src .. '.txt'
	local f_path	= path .. '/' .. f_src

	if not file.Exists( f_path, 'DATA' ) then
		rlib:logconsole( 2, 'failed to locate specified dir and file - [%s]', f_path )
		return false
	end

	local data_enc 	= file.Read( f_path, 'DATA' )
	local data_raw 	= glon.decode( data_enc ) or { }

	return data_raw

end

/*
*	storage :: save data
* 
*	stores data using the glon module into
*	the specified file in the data folder
*	
*	if no path is specified, data will be saved
*	in /data/rlib
*	
*	requires glon module to be installed (comes with rlib)
*	
*	@param tbl data
*	@param str src
*	@param str path [optional]
*/

function storage:data_save( data, src, path )

	if not glon then
		rlib:logconsole( 2, '[%s] module missing - aborting request', 'glon' )
		return false
	end

	if not data or not istable( data ) then
		rlib:logconsole( 2, 'cannot save without valid data' )
		return false
	end

	if not src then
		rlib:logconsole( 2, 'cannot save without valid file dest' )
		return false
	end

	path = path or 'rlib'

	local data_table 		= data
	local to_encode 		= glon.encode( data_table )

	file.Write( path .. '/' .. src .. '.txt', to_encode )

	rlib:logconsole( 6, 'wrote data to file' )
end

/*
*   register calls
*   
*   grab call categories from main lib table
*   which typically include
*   
*       hooks
*       timers
*       commands
*       net
*   
*   Send regsitered calls from source 
*   table rlib.c[type] to .G_calls[type]
*   
*	@param tbl parent
*   @param tbl src
*/

function base:register_calls( parent, src )

	if not parent.script.calls or not istable( parent.script.calls ) then
		self:logconsole( 2, 'Calls definition table not found -- cannot continue' )
		return
	end

	if not src or not istable( src ) then
		self:logconsole( 2, 'Cannot run calls without valid table' )
		return
	end

	for _, v in pairs( parent.script.calls ) do
		-- v is the hooks, timers, net
		local call_type = string.lower( v )
		if not src[ call_type ] then
			src[ call_type ] = { }
			continue
		end
		for l, m in pairs( src[call_type] ) do
			_G.calls[ call_type ]     = _G.calls[call_type] or { }
			_G.calls[ call_type ][ l ]  = tostring( m[ 1 ] )
		end
		-- self:logconsole( 6, 'Registered call: [%s]', call_type )
	end

end
concommand.Add( prefix .. 'debug.calls', base.register_calls )

/*
*   calls : load
*   
*   takes all registered calls and loads them into the server
*	if net call then network library will be added.
*/

function base:calls_load( )

	self:logconsole( 6, 'Registering netlibs' )

	if not _G.calls[ 'net' ] then
		_G.calls[ 'net' ] = { }
		self:logconsole( 2, 'netlib calls table created' )
	end

	for _, v in pairs ( _G.calls[ 'net' ] ) do
		if SERVER then
			local call_id = tostring( prefix .. v )
			util.AddNetworkString( call_id )
			self:logconsole( 6, 'Registered netlib [%s]', call_id )
		end
	end

	hook.Call( prefix .. 'calls.loaded' )

end

/*
*	ip / port
*	
*	This area simply includes functions and operations related 
*	to the internal functionality of the script. They should 
*	not need to be modified for any reason.
*/

function base.getip( )
	local hostip = GetConVar( 'hostip' ):GetString( )
	hostip = tonumber( hostip )
	if ( hostip and isnumber( hostip ) ) then
		local ip = { }
		ip[ 1 ] = bit.rshift( bit.band( hostip, 0xFF000000 ), 24 )
		ip[ 2 ] = bit.rshift( bit.band( hostip, 0x00FF0000 ), 16 )
		ip[ 3 ] = bit.rshift( bit.band( hostip, 0x0000FF00 ), 8 )
		ip[ 4 ] = bit.band( hostip, 0x000000FF )
		return table.concat( ip, '.' )
	else
		hostip = game.GetIPAddress( )
		local e = string.Explode( ':', hostip )
		return e[ 1 ]
	end
end

function base.getport( )
	local hostport = GetConVar( 'hostport' ):GetInt( )
	if hostport and hostport ~= 0 then
		return hostport
	else
		local ip = game.GetIPAddress( )
		local e = string.Explode( ':', ip )
		hostport = e[ 2 ]
		return hostport
	end
end

/*
*	concommand :: version
* 
*	simply outputs the version of rlib running.
*/

function base:version( )
	if script and version then
		local ver_output = 'running ' .. script .. ' v' .. version
		if IsValid( ply ) then
			ply:ChatPrint( ver_output )
			debugger:push( 1, ver_output )
		else
			print( ver_output )
		end
	end
end
concommand.Add( prefix .. 'version', base.version )