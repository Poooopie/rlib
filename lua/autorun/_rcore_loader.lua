/*
*   @package     rcore
*   @author      Richard [http://steamcommunity.com/profiles/76561198135875727]
* 
*   BY MODIFYING THIS FILE -- YOU UNDERSTAND THAT THE ABOVE MENTIONED AUTHORS CANNOT BE HELD RESPONSIBLE
*   FOR ANY ISSUES THAT ARISE FROM MAKING ANY ADJUSTMENTS TO THIS SCRIPT. YOU UNDERSTAND THAT THE ABOVE 
*   MENTIONED AUTHOR CAN ALSO NOT BE HELD RESPONSIBLE FOR ANY DAMAGES THAT MAY OCCUR TO YOUR SERVER AS A 
*   RESULT OF THIS SCRIPT AND ANY OTHER SCRIPT NOT BEING COMPATIBLE WITH ONE ANOTHER.
*/

/*
*   data tables
*/

rcore = rcore or { }
rcore.sys = rcore.sys or { }

/*
*   start autoloader
*/

function rcore:autoloader_exec( )

	/*
	*	core information
	*/

	local base				= rcore
	base.script				= base.script or { }
	base.script.name		= 'rlib-core'
	base.script.folder		= 'rlib'
	base.script.modpath		= 'modules'
	base.script.prefix		= 'rcore.'
	base.script.id			= '1'
	base.script.owner		= '76561198135875727'
	base.script.author		= 'Richard'
	base.script.build		= '1.0.0'
	base.script.released	= 'November 13, 2018'
	base.script.website		= 'https://iamrichardt.com/'
	base.script.github		= 'https://github.com/IAMRichardT/rlib/'

	/*
	*	workshops
	*	
	*	A list of steam workshop collection ids that are associated to this script. On server boot, these 
	*	workshops will be mounted to the server both server and client-side. 
	*	
	*	If you wish to disable steam workshop mounting, DO NOT DO IT FROM THIS TABLE.
	*	Go to the provided config file in /sh/ and simply set the Workshop property to FALSE.
	*/

	base.script.workshops = { }

	/*
	*	fonts
	*	
	*	A list of the custom fonts used for this script. These will be used within the Resources section 
	*	in order to ensure the proper fonts are added to the server.
	*	
	*	@ex font.ttf
	*/

	base.script.fonts = { }

	/*
	*	fastdl
	*	
	*	List of folders which will include materials, resources, sounds
	*	that will be included using resource.AddFile
	*/

	base.script.resources =
	{
		'materials',
		'sound',
		'resource',
	}

	/*
	*	materials
	*	
	*	This is a table of materials that are to be loaded with the script related to UI.
	*	Anything that can be modified via a config file will not show up here and uses 
	*	a different method. These are simply materials that have no reason to be changed.
	*	
	*	@ex { 'mat_name', 'path/to/material.png' }
	*/

	base.script.materials = { }

	/*
	*	Checks to see if rlib is available and initializes it if so. The script will fail
	*	if rlib is not available.
	*/

	if not rlib then
		base.sys.starttime  = SysTime( )
		base.sys.mloadtime  = 0
		base.sys.modules    = { total = 0, registered = 0, err = 0, disabled = 0 }
		MsgC( Color( 255, 255, 0 ), '[' .. base.script.name .. '] Initializing rlib.\n' )
		local rlib_loader = 'autorun/libs/rlib_loader.lua'
		if file.Exists( rlib_loader, 'LUA' ) then
			if SERVER then
				AddCSLuaFile( rlib_loader )
			end
			include( rlib_loader )
			rlib:autoloader_exec( base )
		else
			MsgC( Color( 255, 0, 0 ), '\n\n-----------------------------------------------------------------------------\n' )
			MsgC( Color( 255, 0, 0 ), 'FATAL ERROR \n' )
			MsgC( Color( 255, 0, 0 ), '[' .. base.script.name .. '] cannot run without rlib being installed. \n' )
			MsgC( Color( 255, 0, 0 ), '-----------------------------------------------------------------------------\n\n' )
			return
		end
	end

	/*
	*	core tables
	*/

	base.modules  = { }
	base.settings = base.settings or { }
	base.language = base.language or { }
	base.database = base.database or { }

	/*
	*   localized paths
	*/

	local script    = base.script
	local prefix    = script.prefix
	local path_home = script.folder
	local path_lib  = base.path
	local settings  = base.settings

	local priority_loader =
	{
		{ file = 'sh_config', scope = 2, seg = path_home },
		{ file = 'sh_init', scope = 2, seg = path_home },
		{ file = 'sv_init', scope = 1, seg = path_home },
		{ file = 'cl_init', scope = 3, seg = path_home },
	}

	for _, v in pairs( priority_loader ) do

		if not v.file then continue end
		if not v.seg then v.seg = path_home end

		local path_priority = v.seg .. '/' .. v.file .. '.lua'

		if not v.scope then
			MsgC( Color( 255, 0, 0 ), '[' .. rlib.manifest.name .. '] [L] ERR: ' .. path_priority .. ' :: [Missing Scope]\n' )
			continue
		end

		if v.scope == 1 then
			if SERVER then include( path_priority ) end
			if settings.debug then
				MsgC( Color( 255, 255, 0 ), '[' .. rlib.manifest.name .. '] [L-SV] ' .. path_priority .. '\n' )
			end
		elseif v.scope == 2 then
			include( path_priority )
			if SERVER then AddCSLuaFile( path_priority ) end
			if settings.debug then
				MsgC( Color( 255, 255, 0 ), '[' .. rlib.manifest.name .. '] [L-SH] ' .. path_priority .. '\n' )
			end
		elseif v.scope == 3 then
			if SERVER then
				AddCSLuaFile( path_priority )
			else
				include( path_priority )
			end
			if settings.debug then
				MsgC( Color( 255, 255, 0), '[' .. rlib.manifest.name .. '] [L-CL] ' .. path_priority .. '\n' )
			end
		end
	end

	/*
	*	recursive autoloader
	*	
	*	Do not modify the following code. It will go through each folder recursively and add any
	*	files required for this system to function properly.
	*	
	*	The scope of a file will be determined by the prefix that the file starts with.
	*	
	*	prefix scope
	*		sv_ = server
	*		sh_ = shared
	*		cl_ = client
	* 
	*	Having a file named sv_helloworld.lua will set the scope to be accessible via server only.
	*	
	*	ENSURE that you do NOT set sensitive data as shared. If your file includes passwords or 
	*	anything that is sensitive in data (such as MySQL auth info); use sv_ (server) ONLY.
	*/

	if SERVER then

		local pathbase = script.folder .. '/'
		local files, dirs = file.Find( pathbase .. '*', 'LUA' )

		for k, v in pairs( files ) do
			include( pathbase .. v )
		end

		/*
		*	recursive autoloader : serverside shared
		*/

		for _, dir in SortedPairs( dirs, true ) do
			if dir == '.' or dir == '..' then continue end
			if dir == 'modules' then continue end
			local path_recur = pathbase .. dir
			for _, File in SortedPairs( file.Find( path_recur .. '/sh_*.lua', 'LUA' ), true ) do
				local path_inc = path_recur .. '/' .. File
				AddCSLuaFile( path_inc )
				include( path_inc )
				if settings.debug then
					MsgC( Color( 255, 255, 0 ), '[' .. rlib.manifest.name .. '] [L-SH] ' .. File .. '\n' )
				end
			end
			local sub_file, sub_dir = file.Find( path_recur .. '/' .. '*', 'LUA')
			for l, m in pairs( sub_dir ) do
				for _, SubFile in SortedPairs( file.Find( path_recur .. '/' .. m .. '/sh_*.lua', 'LUA' ), true ) do
					local path_inc = path_recur .. '/' .. m .. '/' .. SubFile
					AddCSLuaFile( path_inc )
					include( path_inc )
					if settings.debug then
						MsgC( Color( 255, 255, 0), '[' .. rlib.manifest.name .. '] [L-SH] ' .. SubFile .. '\n' )
					end
				end
			end
		end

		/*
		*   recursive autoloader : serverside server
		*/

		for _, dir in SortedPairs( dirs, true ) do
			if dir == '.' or dir == '..' then continue end
			if dir == 'modules' then continue end
			local path_recur = pathbase .. dir
			for _, File in SortedPairs( file.Find( path_recur .. '/sv_*.lua', 'LUA' ), true ) do
				include( path_recur .. '/' .. File )
				if settings.debug then
					MsgC( Color( 255, 255, 0 ), '[' .. rlib.manifest.name .. '] [L-SV] ' .. File .. '\n' )
				end
			end
			local sub_file, sub_dir = file.Find( path_recur .. '/' .. '*', 'LUA' )
			for l, m in pairs( sub_dir ) do
				for _, SubFile in SortedPairs(file.Find( path_recur .. '/' .. m .. '/sv_*.lua', 'LUA' ), true ) do
					include( path_recur .. '/' .. m .. '/' .. SubFile )
					if settings.debug then
						MsgC( Color( 255, 255, 0 ), '[' .. rlib.manifest.name .. '] [L-SV] ' .. SubFile .. '\n' )
					end
				end
			end
		end

		/*
		*   recursive autoloader : serverside client
		*/

		for _, dir in SortedPairs( dirs, true ) do
			if dir == '.' or dir == '..' then continue end
			if dir == 'modules' then continue end
			local path_recur = pathbase .. dir
			for _, File in SortedPairs( file.Find( path_recur .. '/cl_*.lua', 'LUA' ), true ) do
				AddCSLuaFile( path_recur .. '/' .. File )
				if settings.debug then
					MsgC( Color( 255, 255, 0 ), '[' .. rlib.manifest.name .. '] [L-CL] ' .. File .. '\n')
				end
			end
			local sub_file, sub_dir = file.Find( path_recur .. '/' .. '*', 'LUA')
			for l, m in pairs( sub_dir ) do
				for _, SubFile in SortedPairs( file.Find( path_recur .. '/' .. m .. '/cl_*.lua', 'LUA' ), true ) do
					AddCSLuaFile( path_recur .. '/' .. m .. '/' .. SubFile )
					if settings.debug then
						MsgC( Color( 255, 255, 0), '[' .. rlib.manifest.name .. '] [L-CL] ' .. SubFile .. '\n' )
					end
				end
			end
		end

	end

	if CLIENT then

		local pathbase = script.folder .. '/'
		local _, dirs = file.Find( pathbase .. '*', 'LUA' )

		/*
		*   recursive autoloader : clientside shared
		*/

		for _, dir in SortedPairs( dirs, true ) do
			if dir == '.' or dir == '..' then continue end
			if dir == 'modules' then continue end
			for _, File in SortedPairs( file.Find( pathbase .. dir .. '/sh_*.lua', 'LUA' ), true ) do
				include( pathbase .. dir .. '/' .. File )
				if settings.debug then
					MsgC( Color( 255, 255, 0 ), '[' .. rlib.manifest.name .. '] [L-SH] ' .. File .. '\n')
				end
			end
			local sub_file, sub_dir = file.Find( pathbase .. dir .. '/' .. '*', 'LUA' )
			for l, m in pairs( sub_dir ) do
				for _, SubFile in SortedPairs( file.Find( pathbase .. dir .. '/' .. m .. '/sh_*.lua', 'LUA' ), true ) do
					include( pathbase .. dir .. '/' .. m .. '/' .. SubFile )
					if settings.debug then
						MsgC( Color( 255, 255, 0 ), '[' .. rlib.manifest.name .. '] [L-SH] ' .. SubFile .. '\n' )
					end
				end
			end
		end

		/*
		*   recursive autoloader : clientside client
		*/

		for _, dir in SortedPairs( dirs, true ) do
			if dir == '.' or dir == '..' then continue end
			if dir == 'modules' then continue end
			for _, File in SortedPairs( file.Find( pathbase .. dir .. '/cl_*.lua', 'LUA' ), true ) do
				include( pathbase .. dir .. '/' .. File )
				if settings.debug then
					MsgC( Color( 255, 255, 0 ), '[' .. rlib.manifest.name .. '] [L-CL] ' .. File .. '\n' )
				end
			end
			local sub_file, sub_dir = file.Find( pathbase .. dir .. '/' .. '*', 'LUA' )
			for l, m in pairs( sub_dir ) do
				for _, SubFile in SortedPairs( file.Find( pathbase .. dir .. '/' .. m .. '/cl_*.lua', 'LUA' ), true ) do
					include( pathbase .. dir .. '/' .. m .. '/' .. SubFile )
					if settings.debug then
						MsgC( Color( 255, 255, 0 ), '[' .. rlib.manifest.name .. '] [L-CL] ' .. SubFile .. '\n')
					end
				end
			end
		end

	end

	/*
	*	workshop
	*	
	*	determines if the script should handle content related to the script 
	*	via Steam Workshop or FastDL.
	*/

	if SERVER and base.settings.useresources then

		local path_base = script.folder or ''

		for v in rlib.h.getdata( base.script.resources ) do
			local r_path = v .. '/' .. path_base
			if v == 'resource' then
				r_path = v .. '/fonts'
			end
			local r_files, r_dirs = file.Find( r_path .. '/*', 'GAME' )

			for _, File in SortedPairs( r_files ) do
				local r_path_inc = r_path .. '/' .. File
				resource.AddFile( r_path_inc )
				if settings.debug then
					MsgC( Color( 255, 255, 0 ), '[' .. rlib.manifest.name .. '] [M] ' .. r_path_inc .. '\n' )
				end
			end

			for _, d in pairs( r_dirs ) do
				local r_subpath = r_path .. '/' .. d
				local r_subfiles, r_subdirs = file.Find( r_subpath .. '/*', 'GAME' )
				for _, subfile in SortedPairs( r_subfiles ) do
					local r_path_subinc = r_subpath .. '/' .. subfile
					resource.AddFile( r_path_subinc )
					if settings.debug then
						MsgC( Color( 255, 255, 0 ), '[' .. rlib.manifest.name .. '] [M] ' .. r_path_subinc .. '\n' )
					end
				end
			end

		end

	end

	if base.settings.useworkshop and script.workshops then
		for k, v in pairs( script.workshops ) do
			if SERVER then
				resource.AddWorkshop( v )
				MsgC( Color( 0, 255, 255 ), '[' .. rlib.manifest.name .. '] [M] Workshop: ' .. v .. '\n')
			else
				if CLIENT then
					steamworks.FileInfo( v, function( res )
						if res and res.fileid then
							steamworks.Download( res.fileid, true, function( name )
								game.MountGMA( name or '' )
								local size = res.size / 1024
								MsgC( Color(0, 255, 255), '[' .. rlib.manifest.name .. '] [M] Workshop: ' .. res.title .. ' ( ' .. math.Round(size) .. 'KB )\n')
							end )
						end
					end )
				end
			end
		end
	end

	rlib.sys.uptime     = CurTime( )
	rlib.sys.utime      = CurTime( )

	if CLIENT then
		rlib.sys.materials_load( script.materials, script.name )
	end

	hook.Call( 'rlib.initialize.post' )

end

/*
*   exec rcore
*/

rcore:autoloader_exec( )