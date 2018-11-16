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

local base 			= rcore
local prefix 		= base.script.prefix
local settings 		= base.settings
local sys			= base.sys
local helper		= rlib.h
local debugger		= rlib.debug or { }

/*
*	module loader statistics
*/

function base:modules_cstats( )
	rlib.l							= { }
	sys.mloadtime 					= SysTime( )
	sys.modules[ 'total' ]			= 0
	sys.modules[ 'registered' ]		= 0
	sys.modules[ 'err' ]			= 0
	sys.modules[ 'disabled' ]		= 0
end

/*
* 	register module
* 
* 	Registers a module with the gamemode
* 
* 	@param str path
*	@param str mod
*	
*	@ex path => modules/tools, mod => sh_tools_manifest.lua
*/

function base:module_register( path, mod, b_isext )

	if not ( path or mod ) then
		rlib:logconsole( 2, 'Error loading module -- manifest could not be loaded for module' )
		sys.modules[ 'err' ] = sys.modules[ 'err' ] + 1
		return false
	end

	local _ENV 			= { }
	local manifest		= path .. '/' .. mod
	local tmp_id 		= mod:gsub( '.lua', '' )

	if not tmp_id then
		rlib:logconsole( 2, 'Could not find ID for module' )
		sys.modules[ 'err' ] = sys.modules[ 'err' ] + 1
		return false
	end

	_ENV.MODULE = self.modules[ tmp_id ]
	smt = setmetatable( _ENV, { __index = _G } )

	if not smt or ( type( smt ) ~= 'table' ) then
		rlib:logconsole( 6, 'Error occured setting the metatable' )
		sys.modules[ 'err' ] = sys.modules[ 'err' ] + 1
		return false
	else
		if sys.modules[ 'registered' ] <= 0 then
			rlib:logconsole( 6, 'Metatable generated' )
		end
	end

	local module_exec = CompileFile( manifest )
	sys.modules[ 'total' ] = sys.modules[ 'total' ] + 1

	if module_exec and rlib:isfunction( module_exec ) then
		if not smt.MODULE.enabled then
			rlib:logconsole( 6, 'Module disabled [%s]', smt.MODULE.id )
			sys.modules[ 'disabled' ] = sys.modules[ 'disabled' ] + 1
			return false
		end

		debug.setfenv( module_exec, _ENV )
		module_exec( )

		local module_id						= smt.MODULE.id
		self.modules[ module_id ]			= _ENV.MODULE
		self.modules[ module_id ].id		= module_id
		self.modules[ module_id ].loadtime	= CurTime( )
		self.modules[ module_id ].settings	= { }
		self.modules[ tmp_id ]				= nil

		rlib.l[ module_id ] 				= smt.MODULE.language

		sys.modules[ 'registered' ] = sys.modules[ 'registered' ] + 1
		rlib:logconsole( 6, 'Loaded manifest [%s]', mod )

		if smt.MODULE.storage then
			for k, v in pairs( smt.MODULE.storage ) do
				self.modules[ module_id ][ k ] = { }
			end
			helper:garbage( 'module_loader_storage', { smt.MODULE.storage } )
		else
			smt.MODULE.storage = { }
		end

		if smt.MODULE.logging then
			rlib:cdata_create( 'rlib', 'modules', module_id )
		end

		-- Register calls
		if smt.MODULE.calls then
			rlib:register_calls( rcore, smt.MODULE.calls )
		end

		-- load other files in module after good manifest found
		self:autoloader_configs( path, module_id )
		self:autoloader_modules( path, module_id, b_isext )

		-- Register materials
		if smt.MODULE.materials and CLIENT then
			rlib.h.materials_load( smt.MODULE.materials, module_id )
		end

	else

		sys.modules[ 'err' ] = sys.modules[ 'err' ] + 1
		rlib:logconsole( 2, '[%s] has a missing function', mod )

	end

end
hook.Add( prefix .. 'modules.register', prefix .. 'modules.register', function( path, mod ) base:module_register( path, mod ) end )

/*
* 	is valid module
* 
* 	check if the specified module is valid or not
* 
*	@param tbl mod
*	@return bool
*/

function base:ismodule( mod )
	if mod and mod.enabled then
		return true
	end
	return false
end

/*
* 	is valid module (by id)
* 
* 	check if the specified module id is valid or not 
* 
*	@param str mod
*	@return bool
*/

function base:ismodule_id( mod )
	if mod and self.modules[ mod ] and self.modules[ mod ].enabled then
		return true
	end
	return false
end

/*
* 	modules :: has or halt
* 
* 	Checks to see if a module is valid, if not, returns an error the player
*	who utilized a feature associated to failed module.
* 
*	@param str mod
*	@param ent ply
*	@return bool
*/

function base:module_hasorhalt( mod, ply )
	if self:ismodule( mod ) then
		return true
	else
		rlib:logconsole( 2, 'You don\'t have access to this.' )
		if ply then
			if helper:isconsole( ply ) then
				helper:toconsole( ply, Color( 255, 89, 0 ), '[SERVER] ', Color( 255, 255, 25 ), '[ERROR] ', Color( 255, 255, 255 ), ' Module ', Color( 255, 107, 250 ), string.upper( mod ), Color( 255, 255, 255 ), ' has encountered an issue. Contact a server admin.' )
			else
				ply:CMessage( Color( 255, 89, 0 ), '[SERVER] ', Color( 255, 255, 25 ), '[ERROR] ', Color( 255, 255, 255 ), ' Module ', Color( 255, 107, 250 ), string.upper( mod ), Color( 255, 255, 255 ), ' has encountered an issue. Contact a server admin.' )
			end
		end
		return false
	end
end

/*
* 	modules :: autoloader :: configs
* 
* 	Once a valid manifest file has been located, this function 
*	will be called to load all of the other files associated 
*	to the specified module.
* 
* 	@param str mpath
* 	@param str module_id
*/

function base:autoloader_configs( mpath, module_id )
	local files, dirs = file.Find( mpath .. '/' .. '*', 'LUA' )
	for _, File in ipairs( files ) do
		if string.match( File, '.lua' ) and ( string.match( File, 'config' ) or string.match( File, 'cfg' ) ) then
			local Path = mpath .. '/' .. File

			if SERVER then AddCSLuaFile( Path ) end
			include( Path )
			rlib:logconsole( 6, 'Loaded config [%s]', Path )
		end
	end
end

/*
* 	modules :: autoloader :: assocaited files
* 
* 	Loads any files / folders associated to the specified
*	module. This should be done after the manifest and config
*	files have already been registered with the system.
*	
*	Recursive subfolders supported
* 
* 	@param str module
*/

function base:modules_attachfile( mpath, b_isext )

	local pathbase = base.script.modpath
	if b_isext then
		pathbase = mpath
	end

	if SERVER then

		local files, dirs = file.Find( pathbase .. '/*', 'LUA' )

		/*
		*   module autoloader :: serverside -> shared
		*/

		for _, dir in SortedPairs( dirs, true ) do
			if dir ~= mpath then continue end
			if dir == '.' or dir == '..' then continue end
			local path_recur = pathbase .. '/' .. dir
			for _, File in SortedPairs( file.Find( path_recur .. '/sh_*.lua', 'LUA' ), true ) do
				local path_inc = path_recur .. '/' .. File
				AddCSLuaFile( path_inc )
				include( path_inc )
			end
			local sub_file, sub_dir = file.Find( path_recur .. '/' .. '*', 'LUA')
			for l, m in pairs( sub_dir ) do
				for _, SubFile in SortedPairs( file.Find( path_recur .. '/' .. m .. '/sh_*.lua', 'LUA' ), true ) do
					local path_inc = path_recur .. '/' .. m .. '/' .. SubFile
					AddCSLuaFile( path_inc )
					include( path_inc )
				end
			end
		end

		/*
		*   module autoloader :: serverside -> server
		*/

		for _, dir in SortedPairs( dirs, true ) do
			if dir ~= mpath then continue end
			if dir == '.' or dir == '..' then continue end
			local path_recur = pathbase .. '/' .. dir
			for _, File in SortedPairs( file.Find( path_recur .. '/sv_*.lua', 'LUA' ), true ) do
				local path_inc = path_recur .. '/' .. File
				include( path_inc )
			end
			local sub_file, sub_dir = file.Find( path_recur .. '/' .. '*', 'LUA')
			for l, m in pairs( sub_dir ) do
				for _, SubFile in SortedPairs( file.Find( path_recur .. '/' .. m .. '/sv_*.lua', 'LUA' ), true ) do
					local path_inc = path_recur .. '/' .. m .. '/' .. SubFile
					include( path_inc )
				end
			end
		end

		/*
		*   module autoloader :: serverside -> client
		*/

		for _, dir in SortedPairs( dirs, true ) do
			if dir ~= mpath then continue end
			if dir == '.' or dir == '..' then continue end
			local path_recur = pathbase .. '/' .. dir
			for _, File in SortedPairs( file.Find( path_recur .. '/cl_*.lua', 'LUA' ), true ) do
				local path_inc = path_recur .. '/' .. File
				AddCSLuaFile( path_inc )
			end
			local sub_file, sub_dir = file.Find( path_recur .. '/' .. '*', 'LUA')
			for l, m in pairs( sub_dir ) do
				for _, SubFile in SortedPairs( file.Find( path_recur .. '/' .. m .. '/cl_*.lua', 'LUA' ), true ) do
					local path_inc = path_recur .. '/' .. m .. '/' .. SubFile
					AddCSLuaFile( path_inc )
				end
			end
		end

	end

	if CLIENT then

		local files, dirs = file.Find( base.script.modpath .. '/*', 'LUA' )

		/*
		*   module autoloader :: clintside -> shared
		*/

		for _, dir in SortedPairs( dirs, true ) do
			if dir ~= mpath then continue end
			if dir == '.' or dir == '..' then continue end
			local path_recur = pathbase .. '/' .. dir
			for _, File in SortedPairs( file.Find( path_recur .. '/sh_*.lua', 'LUA' ), true ) do
				local path_inc = path_recur .. '/' .. File
				include( path_inc )
			end
			local sub_file, sub_dir = file.Find( path_recur .. '/' .. '*', 'LUA')
			for l, m in pairs( sub_dir ) do
				for _, SubFile in SortedPairs( file.Find( path_recur .. '/' .. m .. '/sh_*.lua', 'LUA' ), true ) do
					local path_inc = path_recur .. '/' .. m .. '/' .. SubFile
					include( path_inc )
				end
			end
		end

		/*
		*   module autoloader :: clintside -> client
		*/

		for _, dir in SortedPairs( dirs, true ) do
			if dir ~= mpath then continue end
			if dir == '.' or dir == '..' then continue end
			local path_recur = pathbase .. '/' .. dir
			for _, File in SortedPairs( file.Find( path_recur .. '/cl_*.lua', 'LUA' ), true ) do
				local path_inc = path_recur .. '/' .. File
				include( path_inc )
			end
			local sub_file, sub_dir = file.Find( path_recur .. '/' .. '*', 'LUA')
			for l, m in pairs( sub_dir ) do
				for _, SubFile in SortedPairs( file.Find( path_recur .. '/' .. m .. '/cl_*.lua', 'LUA' ), true ) do
					local path_inc = path_recur .. '/' .. m .. '/' .. SubFile
					include( path_inc )
				end
			end
		end

	end

end

/*
* 	modules :: autoloader
* 
* 	Once a valid manifest file has been located, this function 
*	will be called to load all of the other files associated 
*	to the specified module.
* 
* 	@param str mpath
* 	@param str module_id
*	
*	@ex mpath => modules/footprints/, module_id => footprints
*/

function base:autoloader_modules( mpath, module_id, b_isext )
	local path, folder = rlib:split_paths( mpath )
	self:modules_attachfile( folder, b_isext )
	rlib:logconsole( 4, 'Registered module [%s]', module_id )
end

/*
* 	modules :: autoloader :: manifest
*	
*	Loads of the modules manifest file and registers
*	the data associated to the specified module.
*/

function base:autoloader_manifest_modules( )

	self:modules_cstats( )
	self.sys.loadpriority = settings.loadpriority or { }

	local folder = self.script.modpath
	local _, dirs = file.Find( folder .. '*', 'LUA' )

	/*
	* 	prioritized loading for certain modules (usually base)
	*	usually configured in `lua\rlib\sh_config.lua`
	*/

	for k, v in pairs( self.sys.loadpriority ) do
		local module_dir = folder .. '/' .. k
		for _, sub_f in SortedPairs( file.Find( module_dir .. '/*.lua', 'LUA' ), true ) do
			if not string.match( sub_f, 'manifest' ) then continue end
			local incfile = module_dir .. '/' .. sub_f
			if incfile then
				if SERVER then AddCSLuaFile( incfile ) end
				include( incfile )
				self:module_register( module_dir, sub_f )
			end
		end
	end

	/*
	*	load the remainder of the modules not included in the module
	*	prioritizer.
	*/

	local sub_file, sub_dir = file.Find( folder .. '/' .. '*', 'LUA' )
	for l, m in pairs( sub_dir ) do
		if self.sys.loadpriority[m] then continue end
		local path_manifest = folder .. '/' .. m
		for _, sub_f in SortedPairs( file.Find( path_manifest .. '/*.lua', 'LUA' ), true ) do
			if not string.match( sub_f, 'manifest' ) then continue end
			local incfile = path_manifest .. '/' .. sub_f
			if incfile then
				if SERVER then AddCSLuaFile( incfile ) end
				include( incfile )
				self:module_register( path_manifest, sub_f )
			end
		end
	end

	/*
	*	garbage cleanup
	*/

	helper:garbage( 'autoloader_manifest_modules', { self.sys.loadpriority, sys.mloadtime } )

end

/*
* 	modules :: autoloader :: externals
*	
*	checks for external modules that
*	may have been installed using the addons
*	folder.
*/

function base:autoloader_ext_modules( )

	local function manifest_search( mpath )

		if mpath == '/' or not mpath then mpath = '' end

		local files, dirs = file.Find( mpath .. '*', 'LUA' )

		for _, dir in pairs( dirs ) do
			manifest_search( mpath .. dir .. '/' )
		end

		for _, subfile in pairs( files ) do
			if not string.match( mpath .. subfile, 'manifest' ) then continue end
			self:module_register( mpath, subfile, true )
		end

	end

	manifest_search( '/' )

end

/*
* 	modules :: prefix
* 
* 	used for various things such as font names, etc.
*	
*	@param tbl mod
*	@param str suffix
*/

function base:modules_prefix( mod, suffix )

	if not mod then
		local trcback = debug.traceback( )
		rlib:logconsole( 6, 'warning: cannot create prefix with missing module in \n[%s]', trcback )
		return
	end
	-- if not suffix then suffix = prefix end
	if not suffix then suffix = '' end

	return suffix .. mod.id .. '.'

end

/*
* 	modules :: settings
* 
* 	returns the module settings
*	
*	@param tbl || str mod
*	@return tbl
*/

function base:modules_settings( mod )
	local is_loaded = false
	if mod then
		if isstring( mod ) then
			if self.modules[ mod ] and self.modules[ mod ].enabled and self.modules[ mod ].settings then
				is_loaded = true
				return self.modules[ mod ].settings
			end
		elseif istable( mod ) then
			if mod.enabled and mod.settings then
				is_loaded = true
				return mod.settings
			end
		end
	end

	if not is_loaded then
		local mod_output = 'unspecified'
		if mod and isstring( mod ) then
			mod_output = mod
		end
		local trcback = debug.traceback( )
		rlib:logconsole( 2, 'error loading requested module settings [%s]\n%s', tostring( mod_output ), trcback )
		return false
	end
end

/*
* 	load module
* 
* 	returns valid data on a particular module and
*	the correct prefix
* 
*	@param str mod
*	@return tbl, str || bool ( false )
*/

function base:modules_load( mod, bPrefix )
	local is_loaded = false
	if mod and self.modules[ mod ] and self.modules[ mod ].enabled then
		if bPrefix then
			return self.modules[ mod ], self:modules_prefix( self.modules[ mod ] )
		else
			return self.modules[ mod ]
		end
		is_loaded = true
	end

	if not is_loaded then
		mod = mod or 'unknown'
		local trcback = debug.traceback( )
		rlib:logconsole( 2, 'error loading requested module [%s]\n%s', mod, trcback )
		return false
	end
end

/*
* 	modules :: logging
* 
* 	log module information to the data folder
*		/rlib/modules/[module_name]/
*	
*	to write a log to another directory not 
*	associated to /rlib/modules => use 
*		rlib :: utils:logging_write( path, mtype, data )
*	
*	files in the directory are created based on the current
*	date. a new file will be made if a log is submitted on a
*	day where no file with that date exists.
*	
*	@usage base:modules_log( 'xp', 1, 'information to log' )
*	@param str path
*	@param str suffix
*/

function base:modules_log( mod, mtype, data, post_debugger )

	if not mod then
		base:logconsole( 2, 'unable to module log, module not specified'  )
		return false
	end

	local module_data
	local is_loaded = false
	if mod then
		if isstring( mod ) then
			if self.modules[ mod ] and self.modules[ mod ].enabled then
				is_loaded = true
				module_data = self.modules[ mod ]
			end
		elseif istable( mod ) then
			if mod.enabled then
				is_loaded = true
				module_data = mod
			end
		end
	end

	if not is_loaded then
		local mod_output = 'unspecified'
		if mod and isstring( mod ) then
			mod_output = mod
		end
		local trcback = debug.traceback( )
		rlib:logconsole( 2, 'error loading module [%s] :: cannot write log\n%s', tostring( mod_output ), trcback )
		return false
	end

	if not module_data.logging then return end
	if not mtype then mtype = 1 end

	local c_type
	if isnumber( mtype ) then
		c_type = '[' .. rlib:ucfirst( helper._debugTitles[mtype] ) .. ']'
	elseif isstring( mtype ) then
		c_type = '[' .. mtype .. ']'
	end

	local f_prefix = os.date( '%m%d%Y' )
	local f_name = 'RL_' .. f_prefix .. '.txt'

	local c_date = '[' .. os.date( '%I:%M:%S' ) .. ']'
	local c_comp = c_date .. ' '  .. c_type ..  ' ' .. data

	rlib:append_file( 'rlib/modules/' .. module_data.id, f_name, c_comp )

	if post_debugger then
		debugger:post_simple( mtype, data )
	end

end

/*
* 	modules :: initialize
* 
* 	start loading all required modules
*/

function base:modules_initialize( )

	hook.Call( prefix .. 'modules.load.pre' )

	self:autoloader_manifest_modules( )

	rlib:logconsole( 0 )
	rlib:calls_load( )
	rlib:logconsole( 0 )

	rlib:logconsole( 1, '[%s] modules found', 		sys.modules[ 'total' ] )
	rlib:logconsole( 1, '[%s] modules registered', 	sys.modules[ 'registered' ] )
	rlib:logconsole( 1, '[%s] modules err', 		sys.modules[ 'err' ] )
	rlib:logconsole( 1, '[%s] modules disabled', 	sys.modules[ 'disabled' ] )
	rlib:logconsole( 1, '[%s] to load modules', 	rlib.calc.benchtime( SysTime( ) - sys.mloadtime ) )

	hook.Call( prefix .. 'modules.load.post', base.modules )

end
hook.Add( 'rlib.initialize.post', prefix .. 'modules.initialize', function( ) base:modules_initialize( ) end )
hook.Add( 'OnReloaded', prefix .. 'modules.onreload', function( ) base:modules_initialize( ) end )

/*
* 	modules :: write data
* 
* 	reports the list of loaded modules to a data file
*/

function base:modules_writedata( )

	if CLIENT then return end

	local mdata	= { }
	mdata.modules = { }
	for k, v in pairs( base.modules ) do
		mdata.modules[ k ] = { }
		mdata.modules[ k ].name = v.name
		mdata.modules[ k ].version = v.version
		mdata.modules[ k ].enabled = v.enabled
	end
	table.sort( mdata, function( a, b ) return a[ 1 ] < b[ 1 ] end )

	file.Write( 'rlib/modules.txt', util.TableToJSON( mdata ) )

	local mdata_manifest = { }
	for k, v in pairs( rlib.manifest ) do
		mdata_manifest[ k ] = v
	end

	file.Write( 'rlib/manifest.txt', util.TableToJSON( mdata_manifest ) )

end
hook.Add( prefix .. 'modules.load.post', prefix .. 'modules.writedata', function( ) base:modules_writedata( ) end )

/*
* 	modules :: register permissions
* 
* 	register permissions for each module
*	
*	@param tbl source
*/

function base:modules_perms_register( source )

	if source and not istable( source ) then
		rlib:logconsole( 2, 'cannot register permissions for modules, bad table [%s]', trcback )
		return
	end

	source = source or base.modules

	for v in helper.getdata( source ) do
		if v.enabled and v.permissions then
			rlib.permissions_initialize( v.permissions )
		end
	end

end
hook.Add( 'PostGamemodeLoaded', prefix .. 'modules.permissions.register', function( ) base:modules_perms_register( ) end )

/*
* 	modules :: storage
* 
* 	will create any required folders needed by the
*	module to store certain data
*	
*	@param tbl source
*/

function base:modules_storage( source )

	if source and not istable( source ) then
		rlib:logconsole( 2, 'cannot manage storage for modules, bad table [%s]', trcback )
		return
	end

	source = source or base.modules

	/*
	* 	modules :: storage :: create data dir
	* 
	* 	creates the requested folders in the data directory
	*	
	*	@param tbl data
	*/

	local function cdatafolder( data, mod_id )
		if not data[ 'parent' ] or not data[ 'sub' ] then
			rlib:logconsole( 2, '[%s] failed to specify new datafolder in manifest', tostring( mod_id ) )
			return
		end

		local fol_parent	= tostring( data[ 'parent' ] )
		local fol_sub		= tostring( data[ 'sub' ] )

		if not file.Exists( fol_parent, 'DATA' ) then
			file.CreateDir( fol_parent )
			rlib:logconsole( 6, '[%s] created datafolder parent [%s]', tostring( mod_id ), fol_parent )
		end
		if not file.Exists( fol_parent .. '/' .. fol_sub, 'DATA' ) then
			file.CreateDir( fol_parent .. '/' .. fol_sub )
			rlib:logconsole( 6, '[%s] created datafolder sub [%s]', tostring( mod_id ), fol_sub )
		end
	end

	for v in helper.getdata( source ) do
		if v.enabled and v.datafolder and istable( v.datafolder ) then
			local count = #v.datafolder
			if count > 0 then
				for d in helper.getdata( v.datafolder ) do
					cdatafolder( d, v.id )
				end
			else
				cdatafolder( v.datafolder, v.id )
			end
		end
	end

end
hook.Add( 'PostGamemodeLoaded', prefix .. 'modules.storage', function( ) base:modules_storage( ) end )

/*
* 	modules :: precache
* 
* 	precache any valid models and sounds assocaited to
*	entities
*	
*	@param tbl source
*/

function base:modules_precache( source )

	if source and not istable( source ) then
		rlib:logconsole( 2, 'cannot find entities for modules, bad table [%s]', trcback )
		return
	end

	source = source or base.modules

	/*
	* 	func precache :: models
	*	
	*	@param str src
	*/

	local function precache_model( src )
		if string.GetExtensionFromFilename( src ) ~= 'mdl' then
			rlib:logconsole( 6, 'precache model skipped for [%s]', src )
			return
		end
		util.PrecacheModel( src )
		rlib:logconsole( 6, 'precache model [%s]', src )
	end

	/*
	* 	func precache :: sounds
	*	
	*	@param str src
	*/

	local function precache_sound( src )
		if string.GetExtensionFromFilename( src ) ~= 'wav' and string.GetExtensionFromFilename( src ) ~= 'mp3' then
			rlib:logconsole( 6, 'precache sound skipped for [%s]', src )
			return
		end
		util.PrecacheSound( src )
		rlib:logconsole( 6, 'precache sound [%s]', src )
	end

	/*
	* 	func precache :: particles
	*	
	*	@param str src
	*/

	local function precache_particles( src )
		PrecacheParticleSystem( src )
		rlib:logconsole( 6, 'precache particle [%s]', src )
	end

	/*
	* 	func precache :: add game particles
	*	
	*	@param str src
	*/

	local function add_particles( src )
		if string.GetExtensionFromFilename( src ) ~= 'pcf' then
			rlib:logconsole( 6, 'particles skipped for [%s]', src )
			return
		end
		game.AddParticles( src )
		rlib:logconsole( 6, 'added particle [%s]', src )
	end

	/*
	* 	precache various items such as sounds, models, particles
	*/

	for v in helper.getdata( source ) do
		if not v.ents and not istable( v.ents ) then continue end
		for m in helper.getdata( v.ents ) do

			/*
			* 	models :: string
			*/

			if m.model and isstring( m.model ) then
				if not util.IsValidModel( m.model ) then continue end
				precache_model( m.model )
			end

			/*
			* 	models :: table
			*/

			if m.model and istable( m.model ) then
				for s in helper.getdata( m.model ) do
					if not isstring( s ) then continue end
					if not util.IsValidModel( s ) then continue end
					precache_model( s )
				end
			end

			/*
			* 	sounds :: string
			*/

			if m.sound and isstring( m.sound ) then
				precache_sound( m.sound )
			end

			/*
			* 	sounds :: table
			*/

			if m.sound and istable( m.sound ) then
				for s in helper.getdata( m.sound ) do
					if not isstring( s ) then continue end
					precache_sound( s )
				end
			end

			/*
			* 	particles :: string
			*/

			if m.particles and istable( m.particles ) then
				for s in helper.getdata( m.particles ) do
					if not isstring( s ) then continue end
					add_particles( s )
				end
			end

			/*
			* 	particles :: table
			*/

			if m.particles_sys and istable( m.particles_sys ) then
				for s in helper.getdata( m.particles_sys ) do
					if not isstring( s ) then continue end
					precache_particles( s )
				end
			end

		end
	end

end
hook.Add( 'PostGamemodeLoaded', prefix .. 'modules.precache', function( ) base:modules_precache( ) end )

/*
* 	modules :: dependency check
* 
* 	check to see if a module has the proper dependencies
*	
*	@param tbl source
*/

function base:modules_dependencies( source )

	if source and not istable( source ) then
		rlib:logconsole( 2, 'cannot check dependency for modules, bad table [%s]', trcback )
		return
	end

	source = source or base.modules

	for v in helper.getdata( source ) do
		if not v.id or not v.enabled then continue end

		if v.dependencies and istable( v.dependencies ) then
			for m in helper.getdata( v.dependencies ) do
				if not m.check then
					rlib:logconsole( 2, '[%s] failed dependency check missing func [%s]', v.id, m.name )
					continue
				end
				local has_depen = m.check( )
				if has_depen then
					rlib:logconsole( 6, '[%s] found dependency [%s]', v.id, m.name )
				else
					rlib:logconsole( 2, '[%s] failed or missing dependency [%s]', v.id, m.name )
				end
			end
		end
	end

end
hook.Add( 'PostGamemodeLoaded', prefix .. 'modules.dependencies', function( ) base:modules_dependencies( ) end )

/*
* 	modules :: register workshops
* 
* 	register each workshop assocaited to a module
*	
*	@assoc modules.load.post
*	@param tbl source
*/

function base:modules_resources( source )

	if source and not istable( source ) then
		rlib:logconsole( 2, 'cannot register workshops for modules, bad table [%s]', trcback )
		return
	end

	source = source or base.modules

	for v in helper.getdata( source ) do

		if not v.id or not v.enabled then continue end

		/*
		* 	workshop resources
		*	determined through the module manifest file.
		*/

		if v.workshopsenabled and v.workshops then
			if not istable( v.workshops ) then continue end
			for m in helper.getdata( v.workshops ) do
				if SERVER then
					rlib:logconsole( 0 )
					resource.AddWorkshop( m )
					rlib:logconsole( 6, 'Mounted workshop [%s] :: [%s]', tostring( v.id ), m )
				elseif CLIENT then
					steamworks.FileInfo( m, function( res )
						if res and res.fileid then
							steamworks.Download( res.fileid, true, function( name )
								game.MountGMA( name or '' )
								local size = res.size / 1024
								rlib:logconsole( 6, 'Mounted workshop [%s] %s :: %i KB', tostring( v.id ), res.title, math.Round( size ) )
							end )
						end
					end )
				end
			end
		end

		/*
		* 	fastdl resources
		*	determined through the module manifest file.
		*/

		if v.fastdl then
			local r_path = base.script.modpath
			local d_path = r_path .. '/' .. v.id .. '/' .. 'resource'
			if file.IsDir( d_path, 'LUA' ) then
				rlib:addfile_recurv( v.id, d_path )
			else
				local lst_folders = { 'materials', 'sound', 'resource' }
				for l, m in pairs( lst_folders ) do
					local module_folder	= v.fastdl_folder or v.id
					local folder = m .. '/' .. module_folder
					rlib:addfile_recurv( v.id, folder, 'GAME' )
				end
			end
			if v.fastdl_fonts and istable( v.fastdl_fonts ) then
				local fastdl_fonts = file.Find( 'resource/fonts/*', 'GAME' )
				if #fastdl_fonts > 0 then
					for _, f in pairs( fastdl_fonts ) do
						if not table.HasValue( v.fastdl_fonts, f ) then continue end
						resource.AddFile( 'resource/fonts/' .. f )
						rlib:logconsole( 6, '[%s] [fastdl] [font] %s', tostring( v.id ), f )
					end
				end
			end
		end

	end

end
hook.Add( prefix .. 'modules.load.post', prefix .. 'modules.workshops.register', function( source ) base:modules_resources( source ) end )