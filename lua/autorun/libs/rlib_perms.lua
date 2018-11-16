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

local base      = rlib
local settings  = base.settings
local prefix 	= base.manifest.prefix

base.permissions =
{
	[ 'rlib_root' ] =
	{
		id = 'rlib_root',
		category = 'rLib',
		description = 'Allows for complete access to rlib',
		accesslvl = 'superadmin'
	},
	[ 'rlib_debug' ] =
	{
		id = 'rlib_debug',
		category = 'rLib',
		description = 'Allows usage of debugger tools',
		accesslvl = 'superadmin'
	},
	[ 'rlib_forcerehash' ] =
	{
		id = 'rlib_forcerehash',
		category = 'rLib',
		description = 'Forces a complete rehash of the entire server file-structure',
		accesslvl = 'superadmin'
	},
}