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

local base = rlib
local prefix = base.manifest.prefix
local folder = base.manifest.folder

/*
*	pulls the proper translation for a specified string
*/

function base:translate( mod, str, ... )
	local lang = mod and mod.settings.lang or 'en'
	return string.format( mod.language[ lang ][ str ] or str, ... )
end
