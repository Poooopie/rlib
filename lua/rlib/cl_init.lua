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

local base = rcore
local prefix = base.script.prefix

/*
*	Localized cmd func
*   
*   @source lua\autorun\libs\calls
*   @param type string
*   @param ... mixed
*/

local function call( t, ... )
	return rlib:call( t, ... )
end

/*
*   CORE :: Localized translation func
* 
*   Translates a string id into human readable text.
*   
*   @source lua\rcore\language
*   @ex lang('text_string_id_here')
*/

local function lang( ... )
	return base:translate( ... )
end

/*
*   CORE :: Localized shortcuts
* 
* 		base.h			= helpers
* 		base.d			= draw/design
* 		base.c			= calls
* 		base.p			= panels
*		base.p.ind 		= panels ind
*		base.i			= interface
*		base.s			= storage
*/

local helper 	= base.h
local design 	= base.d
local pnl 		= base.p
local interface = base.i
local storage 	= base.s

/*
*	Network Library
*	Sends a message directly to the player
*/

net.Receive( 'rlib.chatmsg', function( len )
	local msg = net.ReadTable( )
	chat.AddText( unpack( msg ) )
end )

net.Receive( 'rlib.chatconsole', function( len )
	local msg = net.ReadTable( )
	table.insert( msg, '\n' )
	MsgC( Color( 255, 255, 255 ), unpack( msg ) )
end )