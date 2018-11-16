/*
* 	@package	rlib
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

rlib = rlib or { }
local base = rlib

/*
*	associated network libs
*/

base.c.net =
{
	[ 'rlib_debug_console' ]		= { 'rlib.debug.console' },
	[ 'rlib_debug_ui' ]				= { 'rlib.debug.ui' },
	[ 'rlib_chatmsg' ]				= { 'rlib.chatmsg' },
	[ 'rlib_chatconsole' ]			= { 'rlib.chatconsole' }
}