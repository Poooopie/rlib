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

/*
* 	protection
* 
* 	if enabled, vital code will be called in from the outside protection system. Turning this off may
*	cause numerous parts of the script to fail due to lack of code.
* 
* 	@source 	rlib :: oort
*	@type		boolean
*	@default	true
*/

	settings.protection = true

/*
*	debug mode
*	
*	Enabled allows for special debug returns to print in console. This helps with diagnosing issues
*	with the server
*	
*	You may use the alternative method provided which utilizing a concommand to activate debug
*	mode for approx. 20 minutes. Automatically turns itself off after the timer has expired.
*	
*	@type 		bool
*	@default 	false
*/

	settings.debug = true

/*
*	debug :: interval time
*	
*	determines how often the system checks for updates to rlib
*	in seconds
*	
*	@type 		int
*	@default	1800
*/

	settings.debug_notify_interval = 7

/*
*	debug :: cleanup logs threshold
*	
*	number of files that must reside in the debug folder before a 
*	message is displayed in console to clean the folder.
*	
*	@type 		int
*	@default	100
*/

	settings.debug_clean_threshold = 100

/*
*	updater :: toggle
*	
*	Checks the repo for the most up-to-date version
*	
*	@type 		bool
*	@default 	true
*/

	settings.update_enabled = true

/*
*	updater :: timer
*	
*	determines how often the system checks for updates to rlib
*	in seconds
*	
*	@type 		int
*	@default	1800
*/

	settings.update_timer = 1800

/*
*	debugger :: fade
*	
*	determines how long the ui will fade for when an action occurs
*	
*	@type 		int
*	@default	8
*/

	settings.debugger_fadetime = 7

/*
*	debugger :: gmod say prefix
*	
*	the prefix to start a command out with in order for it to
*	detect it as a 'say' activity.
*	
*	@type 		str
*	@default	'!'
*/

	settings.debugger_say_prefix = '!'

/*
*	debugger :: gmod console prefix
*	
*	the prefix to start a command out with in order for it to
*	detect it as a actual console command which will utilize
*	RunConsoleCommand
*	
*	@type 		str
*	@default	'#'
*/

	settings.debugger_gcon_prefix = '#'

/*
*	debugger :: time format
*	
*	determines how timestamps will appear for messages
*	
*	@type 		func
*	@default	os.date( '%I:%M:%S' )
*/

	settings.debugger_timeformat = os.date( '%I:%M:%S' )

/*
*	debugger :: dimensions
*	
*	determines the size of the rlib dev console
*	
*	@type 		int
*	@default	w = 500, h = 345
*/

	settings.debugger_ui_w = '500'
	settings.debugger_ui_h = '345'

/*
*	debugger :: hotbinds
*	
*	predetermined actions based on keyphrases
*	
*	@type tbl
*/

	settings.debugger_binds =
	{
		[ 'help' ] =
		{
			func = function( ) end
		},
		[ 'version' ] =
		{
			func = function( )
				RunConsoleCommand( 'rlib.version' )
			end
		},
		[ 'exit' ] =
		{
			func = function( s )
				if IsValid( s ) then s:Remove( ) end
			end
		},
	}


/*
* 	cmessage :: tag
* 
* 	cmessages allow for user input interaction when a player types something in chat. 
*   The tag is what will appear at the front of every message, like the gamemode name
*   or module name.
*
*   @example
*       < [category] [subcategory]: message >
*       < [Gamemode Name] [Immunity]: Feature has been disabled >
* 
* 	@type 	string
*/

	settings.cmsg_tag = 'rlib'

/*
* 	cmessage :: private msg tag
* 
* 	cmessages allow for user input interaction when a player types something in chat. 
*   This tag lets the player know that the message they have received is a private message.
*
*   @example
*       < [PRIVATE] [subcategory]: message >
*       < [PRIVATE] [Immunity]: Feature has been disabled >
* 
* 	@type 	string
*/

	settings.cmsg_private_tag = 'PRIVATE'

/*
* 	cmessage :: server msg tag
* 
* 	cmessages allow for user input interaction when a player types something in chat. 
*   This tag lets the player know that the message they have received is a private message.
*
*   @example
*       < [PRIVATE] [subcategory]: message >
*       < [PRIVATE] [Immunity]: Feature has been disabled >
* 
* 	@type 	string
*/

	settings.cmsg_server_tag = 'SERVER'

/*
* 	cmessage :: color variants
* 
* 	cmessages allow for user input interaction when a player types something in chat. These 
*   can be either private messages or public broadcasted messages sent to everyone. They attempt
*   to inform the player about an action based on the command they enter in chat, which color
*   variants to separate data so it is more easily readable to the player.
*   
*   @example
*       < [category] [subcategory]: message >
*       < [Gamemode Name] [Immunity]: Feature has been disabled >
*       
*   cmsg_color_categry      =>  Gamemode or Module name
*   cmsg_color_subcategry   =>  Feature name
*   cmsg_color_message      =>  Standard text of a message
*   cmsg_color_target       =>  First set of data
*   cmsg_color_target_sec   =>  Second set of data
*   cmsg_color_target_tri   =>  Third set of data
* 
* 	@type color table
*/

	settings.cmsg_color_category        = Color( 255, 89, 0 )       -- red / orange
	settings.cmsg_color_subcategory     = Color( 255, 255, 25 )     -- yellow
	settings.cmsg_color_message         = Color( 255, 255, 255 )    -- white
	settings.cmsg_color_target          = Color( 25, 200, 25 )      -- green
	settings.cmsg_color_target_sec      = Color( 180, 20, 20 )      -- dark red
	settings.cmsg_color_target_tri      = Color( 13, 134, 255 )     -- blue
	settings.cmsg_color_alt             = Color( 255, 107, 250 )    -- pink