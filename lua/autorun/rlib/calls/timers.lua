/*
*   @package        : rlib
*   @author         : Richard [http://steamcommunity.com/profiles/76561198135875727]
*   @copyright      : (c) 2018 - 2020
*   @since          : 1.0.0
*   @website        : https://rlib.io
*   @docs           : https://docs.rlib.io
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

rlib                        = rlib or { }
local base                  = rlib

/*
*   associated timers
*/

base.c.timers =
{
    [ '__lib_noroot_notice' ]                   = { '__lib.noroot.notice' },
    [ '__gm_initialize' ]                       = { '__gm.initialize' },
    [ '__gm_initialize_setup' ]                 = { '__gm.initialize.setup' },
    [ '__gm_initialize_udm' ]                   = { '__gm.initialize.udm' },
    [ 'rlib_about_run' ]                        = { 'rlib.about.run' },
    [ 'rlib_udm_notice' ]                       = { 'rlib.udm.notice' },
    [ 'rlib_udm_check' ]                        = { 'rlib.udm.check' },
    [ 'rlib_debug_delay' ]                      = { 'rlib.debug.delay' },
    [ 'rlib_rdo_rendermode' ]                   = { 'rlib.rdo.rendermode' },
    [ 'rlib_rdo_initialize' ]                   = { 'rlib.rdo.initialize' },
    [ 'rlib_pl_spawn' ]                         = { 'rlib.pl.spawn' },
    [ 'rlib_debug_doclean' ]                    = { 'rlib.debug.doclean' },
    [ 'rlib_cmd_srv_restart' ]                  = { 'rlib.cmd.srv.restart' },
    [ 'rlib_cmd_srv_restart_wait' ]             = { 'rlib.cmd.srv.restart.wait' },
    [ 'rlib_cmd_srv_restart_wait_s1' ]          = { 'rlib.cmd.srv.restart.wait.s1' },
    [ 'rlib_cmd_srv_restart_wait_s2' ]          = { 'rlib.cmd.srv.restart.wait.s2' },
    [ 'rlib_cmd_srv_restart_wait_s3_p1' ]       = { 'rlib.cmd.srv.restart.wait.s3.p1' },
    [ 'rlib_cmd_srv_restart_wait_s3_p2' ]       = { 'rlib.cmd.srv.restart.wait.s3.p2' },
    [ 'rlib_about_indic_l1_r1' ]                = { 'rlib.about.indic.l1.r1' },
    [ 'rlib_about_indic_l1_r2' ]                = { 'rlib.about.indic.l1.r2' },
    [ 'rlib_about_indic_l2_r1' ]                = { 'rlib.about.indic.l2.r1' },
    [ 'rlib_about_indic_l2_r2' ]                = { 'rlib.about.indic.l2.r2' },
    [ 'rlib_spew_run' ]                         = { 'rlib.spew.run' },
    [ 'rcore_modules_validate' ]                = { 'rcore.modules.validate' },
}