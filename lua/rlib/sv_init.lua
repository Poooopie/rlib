/*
* 	@package	rcore
* 	@author		Richard [http://steamcommunity.com/profiles/76561198135875727]
* 
* 	BY MODIFYING THIS FILE -- YOU UNDERSTAND THAT THE ABOVE MENTIONED AUTHORS CANNOT BE HELD RESPONSIBLE
* 	FOR ANY ISSUES THAT ARISE FROM MAKING ANY ADJUSTMENTS TO THIS SCRIPT. YOU UNDERSTAND THAT THE ABOVE 
* 	MENTIONED AUTHOR CAN ALSO NOT BE HELD RESPONSIBLE FOR ANY DAMAGES THAT MAY OCCUR TO YOUR SERVER AS A 
* 	RESULT OF THIS SCRIPT AND ANY OTHER SCRIPT NOT BEING COMPATIBLE WITH ONE ANOTHER.
*/

/*
*	standard tables and localization
*/

rcore = rcore or { }

local base			= rcore
local prefix		= base.script.prefix
local settings		= base.settings
local helper		= rlib.h
local calc			= rlib.calc

/*
*   CORE :: Localized cmd func
*   
*   @source lua\autorun\libs\calls
*   @param type string
*   @param ... mixed
*   @ex call( 'net', 'initialize' )
*   @ex call( 'hooks', 'initialize' )
*/

local function call( t, ... )
	return rlib:call( t, ... )
end

/*
* 	initialize modules
* 
* 	tracks the number of enabled modules as well as the disabled ones.
*/

function base:server_initialize( )

	if not settings.debug_stats then return end

	rlib:logconsole( 0 )
	rlib:logconsole( 1, '[%s] to start server', rlib.calc.benchtime( SysTime( ) ) )
	rlib:logconsole( 1, '[%i] tickrate', math.Round( 1 / engine.TickInterval( ) ) )
	rlib:logconsole( 0 )

end
hook.Add( 'InitPostEntity', prefix .. 'server.initialize', base.server_initialize )

/*
* 	console commands
* 
* 	various tasks that can be completed via console commands
*	note that most of these require you to have root permissions with
*	rlib otherwise you wont be able to return the requested info.
*/

/*
*   concommand :: reload rcore
*/

function base:autoloader_reload( ply, cmd, args )

	if not rlib:is_dev( ply ) then return end
	self:autoloader_exec( )

	helper:gmsg( ply, false, rlib.settings.cmsg_color_category, '[' .. rlib.settings.cmsg_private_tag .. '] ', rlib.settings.cmsg_color_subcategory, '[ ' .. rlib.manifest.name .. ' ]', rlib.settings.cmsg_color_message, ' Successfully reloaded ', rlib.settings.cmsg_color_target, self.script.name )

end
concommand.Add( prefix .. 'reload', function( ply, cmd, args ) base:autoloader_reload( ply, cmd, args ) end )

/*
*   concommand :: check oort
* 
*   displays the current uptime of the server
*/

function base:concmd_oort( ply, cmd, args, str )

	if not rlib:is_dev( ply ) then return end

	local has_oort = oort and 'enabled' or 'disabled'
	helper:gmsg( ply, false, rlib.settings.cmsg_color_category, '[' .. rlib.settings.cmsg_private_tag .. '] ', rlib.settings.cmsg_color_subcategory, '[ ' .. rlib.manifest.name .. ' ]', rlib.settings.cmsg_color_message, ' Oort Engine ', rlib.settings.cmsg_color_target, '[' .. has_oort .. ']' )

end
concommand.Add( rlib.manifest.prefix .. 'oort', function( ply, cmd, args, str ) base:concmd_oort( ply, cmd, args, str ) end )

/*
*   concommand :: uptime
* 
*   displays the current uptime of the server
*/

function base:concmd_uptime( ply, cmd, args, str )

	if not rlib:is_dev( ply ) then return end

	local uptime = calc.secs_to_abbrev( SysTime( ) - base.sys.starttime )
	helper:gmsg( ply, false, rlib.settings.cmsg_color_category, '[' .. rlib.settings.cmsg_private_tag .. '] ', rlib.settings.cmsg_color_subcategory, '[ ' .. rlib.manifest.name .. ' ]', rlib.settings.cmsg_color_message, ' Uptime ', rlib.settings.cmsg_color_target, tostring( uptime ) )

end
concommand.Add( rlib.manifest.prefix .. 'uptime', function( ply, cmd, args, str ) base:concmd_uptime( ply, cmd, args, str ) end )

/*
*   concommand :: list modules
* 
*   prints all currently running modules on server in console
*/

function base:concmd_modules( ply, cmd, args, str )

	if not rlib:is_dev( ply ) and not rlib:is_root( ply ) then return end

	local output = '\n\n[' .. base.script.name .. '] Active Modules\n\n'
	output = output .. string.format( '%-70s', '--------------------------------------------------------------------------------------------\n' )
	local c1_lbl = string.format( '%-20s',    'Module'      )
	local c2_lbl = string.format( '%-15s',    'Version'     )
	local c3_lbl = string.format( '%-15s',    'Author'      )
	local c4_lbl = string.format( '%-20s',    'Description' )
	local c5_lbl = string.format( '%-70s',    '--------------------------------------------------------------------------------------------' )
	output = output .. c1_lbl .. ' ' .. c2_lbl .. ' ' .. c3_lbl .. ' ' .. c4_lbl .. '\n' .. c5_lbl .. '\n'

	helper:toconsole( ply, output )

	for v in helper.getdata( base.modules ) do

		local c1_data, c2_data, c3_data, output_data = '', '', '', ''
		c1_data = string.format( '%-20s',   tostring( rlib:truncate( v.name, 20, '...' ) or 'err' ) )
		c2_data = string.format( '%-15s',   tostring( v.version or 'err' ) )
		c3_data = string.format( '%-15s',   tostring( v.author or 'err' ) )
		c4_data = string.format( '%-20s',   tostring( rlib:truncate( v.desc, 40, '...' ) or 'err' ) )

		output_data = output_data .. c1_data .. ' ' .. c2_data .. ' ' .. c3_data .. ' ' .. c4_data .. ' '

		helper:toconsole( ply, Color( 255, 255, 0 ), output_data )

	end

	helper:toconsole( ply, '\n--------------------------------------------------------------------------------------------' )

end
concommand.Add( prefix .. 'modules', function( ply, cmd, args, str ) base:concmd_modules( ply, cmd, args, str ) end )