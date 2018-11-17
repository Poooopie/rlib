/*
*   @package    rcore
*   @module     Base
*   @author     Richard [http://steamcommunity.com/profiles/76561198135875727]
*
*   BY MODIFYING THIS FILE -- YOU UNDERSTAND THAT THE ABOVE MENTIONED AUTHORS CANNOT BE HELD RESPONSIBLE
*   FOR ANY ISSUES THAT ARISE FROM MAKING ANY ADJUSTMENTS TO THIS SCRIPT. YOU UNDERSTAND THAT THE ABOVE 
*   MENTIONED AUTHOR CAN ALSO NOT BE HELD RESPONSIBLE FOR ANY DAMAGES THAT MAY OCCUR TO YOUR SERVER AS A 
*   RESULT OF THIS SCRIPT AND ANY OTHER SCRIPT NOT BEING COMPATIBLE WITH ONE ANOTHER.
*/

/*
*   standard tables and localization
*/

rcore = rcore or { }

/*
*   modules
*/
local base          = rcore
local mod, prefix   = base:modules_load( 'base', true )
local settings      = base:modules_settings( mod )

/*
*   rlib declarations
*/

local helper = rlib.h