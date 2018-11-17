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
*   @package    gmsv_spew
*   @author     ManWithHat
*   @source     https://github.com/ManWithHat/gmsv_spew
*/

/*
*   standard tables and localization
*/

rlib = rlib or { }

local base      = rlib
local env       = _G
local prefix    = base.manifest.prefix

/*
*   tables
*/

base.spew = base.spew or { }
local spew = base.spew

/*
*   spew :: enabler
* 
*   Determines if the spew module will load at all. If you experience issues with the module
*   or if you cannot install a .DLL to your server; then turn this off.
* 
*   this is used moreso for the developer, really not needed by servers in production
*   
*   @type     boolean
*/

spew.enabled = false

/*
*   spew :: toggle hook destroy
* 
*   if enabled, will destroy the spew hook when the first players connect to the server after
*   the server starts up. Will stop cleaning console at this point until restarted or enabled
*   using the concommand.
*
*   @type     boolean
*/

spew.destroyinit = true

/*
*   spew :: check loaded
*
*   decides if spew has been loaded onto the server yet or not. You should not change this
*   value manually and should always start out false.
*   
*   @type     boolean
*/

spew.loaded = false

/*
*   spew :: enable
*
*   allows for the spew module to be enabled which cleans up
*   unwanted console prints.
*/

function spew.enable( )

    if CLIENT then return end

    local is_loaded = false

    if not spew.enabled then
        base:logconsole( 2, 'Spew module disabled via config setting' )
        return
    end

    if spew.enabled and not is_loaded then
        spew.loaded = pcall( env.require, 'spew' )
    end

    if spew.enabled and spew.loaded and not is_loaded then
        is_loaded = true
    end

    if is_loaded then
        local filter_text =
        {
            [ 'unknown' ]           = true,
            [ 'invalid command' ]   = true,
        }
        hook.Add( 'ShouldSpew', prefix .. 'spew.enabled', function( msg, mtype, clr, lvl, grp )
            local is_found = false
            for k, v in pairs( filter_text ) do
                if string.match( string.lower( msg ), k ) then
                    is_found = true
                end
            end
            if mtype == 0 and not is_found then return true end
            return false
        end )
    else
        base:logconsole( 2, 'Module spew not loaded -- possibly missing library dll' )
        return
    end

    base:logconsole( 4, 'Spew module enabled' )
end
concommand.Add( 'spew.enable', spew.enable )

/*
*   spew :: disable
*
*   disables the spew module and returns the console to normal.
*/

function spew.disable( )
    hook.Remove( 'ShouldSpew', prefix .. 'spew.enabled' )
    base:logconsole( 4, 'Spew module disabled' )
end
concommand.Add( 'spew.disable', spew.disable )

/*
*   spew :: initialized :: destroy hook
*
*   destroys the spew hook after its not need anymore.
*   we just needed it when the server first started.
*/

function spew.initialize( )
    timer.Simple( 3, function( )
        if spew.destroyinit then
            hook.Remove( 'ShouldSpew', prefix .. 'spew.enabled' )
            if spew.enabled then
                base:logconsole( 6, 'Spew hook destroyed' )
            end
        end
    end )
end
hook.Add( 'Initialize', prefix .. 'spew.initialize', function( ) spew.initialize( ) end )

/*
*   spew :: execute
*/

spew.enable( )