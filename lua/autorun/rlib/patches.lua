/*
*   @package        rlib
*   @author         Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      (C) 2020 - 2020
*   @since          3.0.0
*   @website        https://rlib.io
*   @docs           https://docs.rlib.io
*   @file           patches.lua
* 
*   MIT License
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT 
*   LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
*   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
*   WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/*
*   standard tables and localization
*/

rlib                    = rlib or { }
local base              = rlib
local mf                = base.manifest
local pf                = mf.prefix

/*
*   [ ulib ] :: 1 :: fix playerauth
*
*   hook module that overwrites the default gmod hooks will cause ulib to error out
*   in the file server/ucl.lua.
*
*   this ensures that the hook still exists at server startup
*   see ulib part 2 for the other half
*/

local function __ulib_restore_playerauth( )
    if ULib then return end

    local SteamIDs = { }

    -- Load the users file
    local UsersKV = util.KeyValuesToTable( file.Read( 'settings/users.txt', 'GAME' ) )

    -- Extract the data into the SteamIDs table
    for key, tab in pairs( UsersKV ) do
        for name, steamid in pairs( tab ) do
            SteamIDs[ steamid ]         = { }
            SteamIDs[ steamid ].name    = name
            SteamIDs[ steamid ].group   = key
        end
    end

    local function __gmod_playerauth( pl )

        local steamid = pl:SteamID( )

        if game.SinglePlayer( ) or pl:IsListenServerHost( ) then
            pl:SetUserGroup( 'superadmin' )
            return
        end

        if SteamIDs[ steamid ] == nil then
            pl:SetUserGroup( 'user' )
            return
        end

        if pl.IsFullyAuthenticated and not pl:IsFullyAuthenticated( ) then
            pl:ChatPrint( string.format( "Hey '%s' - Your SteamID wasn't fully authenticated, so your usergroup has not been set to '%s.'", SteamIDs[ steamid ].name, SteamIDs[ steamid ].group ) )
            pl:ChatPrint( 'Try restarting Steam.' )
            return
        end

        pl:SetUserGroup( SteamIDs[ steamid ].group )
        pl:ChatPrint(string.format( "Hey '%s' - You're in the '%s' group on this server.", SteamIDs[ steamid ].name, SteamIDs[ steamid ].group ) )

    end
    hook.Add( 'PlayerInitialSpawn', 'PlayerAuthSpawn', __gmod_playerauth )

end
hook.Add( 'Initialize', 'rlib_symlink_ulib_playerauth', __ulib_restore_playerauth )

/*
*   [ ulib ] :: 2 :: fix playerauth
*
*   hook module that overwrites the default gmod hooks will cause ulib to error out
*   in the file server/ucl.lua.
*
*   this fix re-adds the PlayerInitialSpawn / PlayerAuthSpawn hook
*/

local function _authspawn( ) end
hook.Add( 'PlayerInitialSpawn',  'PlayerAuthSpawn', _authspawn )