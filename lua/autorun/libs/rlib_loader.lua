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
*   define some required vars
*/

rlib = rlib or { }
rlib.manifest = rlib.manifest or { }

function rlib:autoloader_exec( parent )

	/*
	*   base definitions
	*/

	local base      		= rlib
	local manifest			= base.manifest or { }
	manifest.name       	= 'rlib'
	manifest.build      	= '1.0.0'
	manifest.released		= 1541898099
	manifest.author			= 'Richard'
	manifest.prefix			= 'rlib.'
	manifest.folder			= 'autorun/libs'
	manifest.repo			= 'https://raw.githubusercontent.com/IAMRichardT/rlib/master/'

	/*
	*   this table lists developers who should have access to the
	*	debugging features. this doesnt give any special permissions
	*	that one person should not have, but is primarily used for
	*	advanced issues submitted via gms tickets and ensures that
	*	the built-in developer console doesnt pop up for people
	*	and annoy them.
	*	
	*	@ref	cc_debug_enable
	*			debugger_console
	*/

	manifest.developers	=
	{
		'76561198135875727',
		'76561198321991757'
	}

	/*
	*   keep track of scripts controlled by rlib
	*/

	base.scripts = base.scripts or { }
	base.parent, base.scripts[ parent ] = parent, parent

	/*
	*   these tables are associated to rlib and should be touched under any circumstance. 
	*   if you decide to modify and/or remove these, issues will arise and I am not going 
	*   to help you if that is the case.
	* 
	*   Numerous aspects of this script rely on these tables.
	*/

	base.settings   = base.settings or { }

	/*
	*	table index
	* 
	* 		base.h			= helpers
	* 		base.d			= draw/design
	* 		base.c			= calls
	* 		base.p			= panels
	*		base.p.ind 		= panels ind
	*		base.i			= interface
	*		base.s			= storage
	*		base.sys		= system
	*		base.m			= materials
	*		base.l			= languages
	*		base.u			= utils
	*		base.o			= owners
	*		base.e			= externals
	*/

	base.h          = base.h or { }
	base.d          = base.d or { }
	base.c          = base.c or { }
	base.p          = base.p or { }
	base.p.ind    	= base.p.ind or { }
	base.i          = base.i or { }
	base.s          = base.s or { }
	base.m          = base.m or { }
	base.l          = base.l or { }
	base.u			= base.u or { }
	base.o			= base.o or { }
	base.e			= base.e or { }

	base.sys        = base.sys or { }		-- system
	base.calc       = base.calc or { }     	-- calc
	base.debug		= base.debug or { }		-- debugger

	/*
	*   calls
	* 
	*   These are definition types used within this script and should never be modified.
	*   Changing the names within this table will not simply change the name, but many 
	*   parts of the library rely on these being named properly.
	*/

	parent.script.calls =
	{
		'hooks',
		'timers',
		'commands',
		'net',
	}

	/*
	*	console output
	*/

	local toConsole_Header =
	{
		'\n\n',
		[[.................................................................... ]],
	}

	local toConsole_Body =
	{
		[[[title]........... ]] .. base.manifest.name .. [[ ]],
		[[[build]........... v]] .. base.manifest.build .. [[ ]],
		[[[released]........ ]] .. base.manifest.released .. [[ ]],
		[[[author].......... ]] .. base.manifest.author .. [[ ]],
		[[[website]......... ]] .. base.manifest.repo .. [[ ]],
	}

	local toConsole_Confirm =
	{
		[[
Copyright (c) 2018 Richard (IAMRichardT) - All rights reserved.
rlib ('the software') may not be used or redistributed under 
any circumstance without the explicit consent of its developer.

Seeing this message means that rlib and its core are properly
loaded and are now ready to install additional modules.
		]],
	}

	local toConsole_Footer =
	{
		[[.................................................................... ]],
	}

	for _, i in ipairs( toConsole_Header ) do
		MsgC( Color( 255, 255, 0 ), i .. '\n' )
	end

	for _, i in ipairs( toConsole_Body ) do
		MsgC( Color( 255, 255, 255 ), i .. '\n' )
	end

	for _, i in ipairs( toConsole_Footer ) do
		MsgC( Color( 255, 255, 0 ), i .. '\n' )
	end

	for _, i in ipairs( toConsole_Confirm ) do
		MsgC( Color( 255, 255, 255 ), '\n' .. i .. '\n' )
	end

	for _, i in ipairs( toConsole_Footer ) do
		MsgC( Color( 255, 255, 0 ), i .. '\n' )
	end

	/*
	*   localization
	*/

	local settings  = base.settings
	local script    = base.script
	local prefix    = base.manifest.prefix
	local path_lib  = base.manifest.folder

	/*
	*   load calls
	*/

	for _, v in pairs( parent.script.calls ) do
		if SERVER then
			AddCSLuaFile( path_lib .. '/calls/' .. v .. '.lua' )
		end
		include( path_lib .. '/calls/' .. v .. '.lua' )
	end

	/*
	*   load priority libraries
	* 
	*   Do not modify these under any circumstance. We need certain stuff to load
	*   first before the recursive loader does its job. It's always nice to have
	*   a little more control.
	*   
	*   File names for the priority system dont matter and do not have to follow 
	*   the prefix setup (sv_ sh_ cl_) since they are being defined in the string
	*   itself.
	* 
	*   scope
	*       1 = server
	*       2 = shared
	*       3 = client
	*/

	local priority_loader =
	{
		{ file = 'rlib_config', scope = 2, seg = path_lib },
		{ file = 'rlib_perms', scope = 2, seg = path_lib },
		{ file = 'rlib_core_sv', scope = 1, seg = path_lib },
		{ file = 'rlib_core_sh', scope = 2, seg = path_lib },
		{ file = 'rlib_core_cl', scope = 3, seg = path_lib },
		{ file = 'rlib_spew', scope = 1, seg = path_lib },
		{ file = 'rlib_lang', scope = 2, seg = path_lib },
		{ file = 'ui/rlib_ui', scope = 3, seg = path_lib },
		{ file = 'ui/rlib_ui_base', scope = 3, seg = path_lib },
		{ file = 'ui/rlib_ui_line', scope = 3, seg = path_lib },
		{ file = 'ui/rlib_ui_dlist', scope = 3, seg = path_lib },
		{ file = 'ui/rlib_ui_spanel', scope = 3, seg = path_lib },
		{ file = 'ui/rlib_ui_sbar', scope = 3, seg = path_lib },
		{ file = 'ui/rlib_ui_slider', scope = 3, seg = path_lib },
		{ file = 'ui/rlib_ui_cbox', scope = 3, seg = path_lib },
		{ file = 'ui/rlib_ui_dev_settings', scope = 3, seg = path_lib },
	}

	for _, v in pairs( priority_loader ) do

		if not v.file then continue end
		if not v.seg then v.seg = path_lib end

		local path_priority = v.seg .. '/' .. v.file .. '.lua'

		if not v.scope then
			MsgC( Color( 255, 0, 0 ), '[' .. base.name .. '] [L] ERR: ' .. path_priority .. ' :: [Missing Scope]\n' )
			continue
		end

		if v.scope == 1 then
			if SERVER then include( path_priority ) end
			if settings.debug then
				MsgC( Color( 255, 255, 0 ), '[' .. base.manifest.name .. '] [L-SV] ' .. path_priority .. '\n' )
			end
		elseif v.scope == 2 then
			include( path_priority )
			if SERVER then AddCSLuaFile( path_priority ) end
			if settings.debug then
				MsgC( Color( 255, 255, 0 ), '[' .. base.manifest.name .. '] [L-SH] ' .. path_priority .. '\n' )
			end
		elseif v.scope == 3 then
			if SERVER then
				AddCSLuaFile( path_priority )
			else
				include( path_priority )
			end
			if settings.debug then
				MsgC( Color( 255, 255, 0), '[' .. base.manifest.name .. '] [L-CL] ' .. path_priority .. '\n' )
			end
		end
	end

	/*
	*   setup calls
	*/

	_G.calls = { }

	/*
	*   returns the associated call
	*   
	*   call using localized function in file that you
	*   require fetching needed calls.
	*   
	*   @param str type
	*   @param str id
	*   @return mix ( str || boolean )
	*/

	function base:call( t, s, ... )

		if not t or t == '' then
			self:logconsole( 2, 'Did not specify valid call type for [ %s ]', 'base:call()' )
			local response = ''
			local cnt_calls, cnt_curr = table.Count( _G.calls ), 0
			for k, v in pairs ( _G.calls ) do
				response = response .. k
				cnt_curr = cnt_curr + 1
				if cnt_curr < cnt_calls then
					response = response .. ', '
				end
			end
			self:logconsole( 2, 'Valid types are [ %s ]', response )
			return false
		end

		if not s then
			self:logconsole( 2, 'No valid id provided for [ %s ]', t )
			return false
		end

		local data = _G.calls[t]
		if not data then
			self:logconsole( 2, 'Could not find specified call type [%s]', t )
			return false
		end
		if t == 'commands' then
			local ret = string.format( s, ... )
			if data[s] then
				ret = string.format( data[s], ... )
			end
			return ret
		else
			local ret = string.format( prefix .. s, ... )
			if data[s] then
				ret = string.format( prefix .. data[s], ... )
			end
			return ret
		end


	end

	/*
	*   executes function register_calls()
	*/

	base:register_calls( parent, base.c )

end