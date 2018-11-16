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

local base      = rcore
local settings  = base.settings

/*
* 	core :: debug mode
* 
* 	Enabled allows for special debug returns to print in console. This helps with diagnosing issues
* 	with the server but should not be left on.
*   
*   You may use the alternative method provided which utilizing a concommand to activate debug
*   mode for approx. 20 minutes. Automatically turns itself off after the timer has expired.
* 
* 	@type 	boolean
*/

	settings.debug = false

/*
* 	core :: debug stats
* 
* 	Prints server and loadtime statistics when everything has finished loading. Helpful for
*   troubleshooting.
* 
* 	@type 	boolean
*/

	settings.debug_stats = true

/*
* 	core :: workshop enabled
* 
* 	Determines if a predefined table of workshop collection ids should be mounted when the server
*   is started and when a client connects. This forces the client to download the workshop and 
*   prevents users from getting missing models, textures, etc.
* 
* 	@source 	autorun\_core_loader.lua
*	@type		boolean
*/

	settings.useworkshop = true

/*
* 	core :: resources enabled
* 
* 	Enabling this will force the script to utilize 'resource.AddFile'
*   Adds the specified files to the files the client should download.
*   This is an alternative to steam workshops and is used as/with FastDL
* 
* 	@source 	autorun\_core_loader.lua
*	@type		boolean
*/

	settings.useresources = true

/*
* 	core :: module priority
* 
* 	This table can list modules that should take priority in loading
*   before other modules are set to be initialized. Usually the only
*   module that needs to go first is the base module since certain
*   config settings may be needed for other scripts.
* 
*	@type		table
*/

	settings.loadpriority =
	{
		[ 'base' ] = true,
	}