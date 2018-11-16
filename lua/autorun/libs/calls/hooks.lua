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

rlib = rlib or {}
local base = rlib

/*
* Associated hooks
*/

base.c.hooks =
{
	['plysay_initialize'] = { 'playersay.initialize' },
	['plyjoin_initialize'] = { 'playerjoin.initialize' }
}