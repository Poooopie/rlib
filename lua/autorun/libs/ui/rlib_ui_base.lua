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

local base		= rlib
local prefix	= base.manifest.prefix
local settings  = base.settings
local helper	= base.h
local design	= base.d
local debugger	= base.debug

/*
*	fonts
*/

surface.CreateFont( prefix .. 'devcon.ico', { font = 'Roboto', size = 24, weight = 800, antialias = true } )
surface.CreateFont( prefix .. 'devcon.gear', { font = 'Roboto', size = 32, weight = 800, antialias = true } )
surface.CreateFont( prefix .. 'devcon.clear', { font = 'Roboto', size = 24, weight = 200, antialias = true } )
surface.CreateFont( prefix .. 'devcon.copy', { font = 'Roboto', size = 20, weight = 100, antialias = true } )
surface.CreateFont( prefix .. 'devcon.title', { font = 'Roboto Light', size = 16, weight = 600, antialias = true } )
surface.CreateFont( prefix .. 'devcon.logger', { font = 'Roboto', size = 13, weight = 400, antialias = true } )
surface.CreateFont( prefix .. 'devcon.textfield', { font = 'Roboto Light', size = 14, weight = 600, antialias = true } )
surface.CreateFont( prefix .. 'devcon.setting.label', { font = 'Roboto', size = 13, weight = 100, antialias = true } )

/*
*	settings :: ignore blocks
*	
*	types to not treat as a convar
*/

settings.ignoreblocks = { 'category', 'spacer', 'padding', 'desc' }

/*
*	settings :: storage
*	
*	settings to utilize for client
*/

debugger.settings =
{
	{ sid = 1, stype = 'checkbox', is_visible = true, id = 'devcon_displaymsgs', name = 'Display new messages', desc = 'enable dev console', default = 1 },
	{ sid = 2, stype = 'checkbox', is_visible = true, id = 'devcon_animations_enabled', name = 'Animations enabled', desc = 'spawn console center', default = 1 },
	{ sid = 3, stype = 'checkbox', is_visible = true, id = 'devcon_timestamps', name = 'Show timestamps', desc = 'show timestamp in logs', default = 0 },
}

/*
*	settings :: setup
*	
*	create all the required settings
*/

local ply_settings = { }
local function settings_setup( )
	if not debugger.settings or not istable( debugger.settings ) then return end

	for k, v in helper:sortbykey( debugger.settings ) do
		ply_settings[#ply_settings + 1] = v
	end

	table.sort( ply_settings, function( a, b ) return a.sid < b.sid end )

	for k, v in pairs( ply_settings ) do
		if table.HasValue( settings.ignoreblocks, v.stype ) then continue end
		rlib.setup_properties( v.stype, v.id, v.default, v.values )
	end
end
settings_setup( )

/*
*	panel
*/

local PANEL = { }

/*
*	accessorfunc
*/

AccessorFunc( PANEL, 'm_bDraggable', 'Draggable', FORCE_BOOL )

/*
*   initialize
*/

function PANEL:Init( )

	local sc_w, sc_h	= helper.scalesimple( 0.85, 0.85, 0.90 ), helper.scalesimple( 0.85, 0.85, 0.90 )
	local pnl_w, pnl_h	= settings.debugger_ui_w, settings.debugger_ui_h
	local ui_w, ui_h	= sc_w * pnl_w, sc_h * pnl_h

	/*
	*   console :: initialize
	*/

	self:SetPaintShadow( true )
	self:SetSize( ui_w, ui_h )
	self:MakePopup( )
	self:SetTitle( '' )
	self:SetSizable( true )
	self:ShowCloseButton( false )
	self:DockPadding( 2, 34, 2, 3 )
	self.Alpha = 255
	self.is_visible = true

	if helper:cvar_bool( 'devcon_animations_enabled' ) then
		self:SetPos( ScrW( ) - ui_w - 20, ScrH( ) + ui_h )
		self:MoveTo( ScrW( ) - ui_w - 20, ScrH( ) - ui_h - 20, 0.4, 0, -1 )
	else
		self:SetPos( ScrW( ) - ui_w - 20, ScrH( ) - ui_h - 20 )
	end

	/*
	*   console :: titlebar
	*/

	self.lblTitle = vgui.Create( 'DLabel', self )
	self.lblTitle:SetText('')
	self.lblTitle:SetFont( prefix .. 'devcon.title' )
	self.lblTitle:SetColor( Color( 255, 255, 255, self.Alpha ) )
	self.lblTitle.Paint = function( s, w, h )
		draw.SimpleText( 'rlib developer console', prefix .. 'devcon.title', 3, h / 2, Color( 237, 237, 237, self.Alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end

	/*
	*   console :: close button
	*/

	self.b_close = vgui.Create( 'DButton', self )
	self.b_close:SetText( '' )
	self.b_close.DoClick = function( s )
		self:ActionHide( )
		-- self:Destroy( )
	end
	self.b_close.Paint = function( s, w, h )
		draw.SimpleText( '-', prefix .. 'devcon.ico', w / 2, h / 2 + 4, Color( 237, 237, 237, self.Alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	/*
	*   console :: primary container
	*/

	self.p_parent = vgui.Create( 'DPanel', self )
	self.p_parent:Dock( FILL )
	self.p_parent:DockMargin( 0, 0, 0, 0 )
	self.p_parent.Paint = function( s, w, h ) end

	/*
	*   console :: body
	*/

	self.p_body = vgui.Create( 'DPanel', self.p_parent )
	self.p_body:Dock( FILL )
	self.p_body:DockMargin( 0, 5, 0, 0 )
	self.p_body.Paint = function( s, w, h ) end

	/*
	*   console :: body :: scroll panel
	*/

	self.dsp_content = vgui.Create( 'rlib.ui.scrollpanel', self.p_body )
	self.dsp_content:Dock( FILL )

	/*
	*   console :: bottom
	*/

	self.p_parent_btm = vgui.Create( 'DPanel', self.p_parent )
	self.p_parent_btm:Dock( BOTTOM )
	self.p_parent_btm:DockMargin( 0, 0, 0, 0 )
	self.p_parent_btm:SetTall( 30 )
	self.p_parent_btm.Paint = function( s, w, h ) end

	/*
	*   console :: bottom left
	*/

	self.p_btm_l = vgui.Create( 'DPanel', self.p_parent_btm )
	self.p_btm_l:Dock( FILL )
	self.p_btm_l:DockMargin( 6, 4, 3, 4 )
	self.p_btm_l.Paint = function( s, w, h ) end

	/*
	*   console :: bottom right
	*/

	self.p_btm_r = vgui.Create( 'DPanel', self.p_parent_btm )
	self.p_btm_r:Dock( RIGHT )
	self.p_btm_r:DockMargin( 4, 4, 4, 4 )
	self.p_btm_r:SetWide( 50 )
	self.p_btm_r.Paint = function( s, w, h )
		draw.RoundedBox( 2, 0, 0, w, h, Color( 45, 45, 45, self.Alpha ) )
	end

	/*
	*   console :: dtxt_input textentry
	*/

	self.dtxt_input = vgui.Create( 'DTextEntry', self.p_btm_l )
	self.dtxt_input:Dock(FILL)
	self.dtxt_input:DockPadding( 7, 3, 7, 3 )
	self.dtxt_input:SetPaintBackgroundEnabled( false )
	self.dtxt_input:SetCursorColor( Color( 200, 200, 200, 255 ) )
	self.dtxt_input:SetTextColor( Color( 200, 200, 200, 255 ) )
	self.dtxt_input:SetHighlightColor( Color( 25, 25, 25, 255 ) )
	self.dtxt_input.OnEnter = function( ) self:ActionEnter( ) end
	self.dtxt_input.PerformLayout = function( s, w, h )
		gamemode.Call( 'ChatTextChanged', self.dtxt_input:GetValue( ) )
	end
	self.dtxt_input.Paint = function( s, w, h )
		draw.RoundedBox( 6, 0, 0, w, h, Color( 35, 35, 35, self.Alpha ) )
		s:DrawTextEntryText( s:GetTextColor( ), s:GetHighlightColor( ), s:GetCursorColor( ) )
	end
	self.dtxt_input:RequestFocus( )

	/*
	*   console :: bottom right :: inner
	*/

	self.p_btm_r_inner = vgui.Create( 'DPanel', self.p_btm_r )
	self.p_btm_r_inner:Dock( FILL )
	self.p_btm_r_inner:DockMargin( 2, 1, 2, 1 )
	self.p_btm_r_inner.Paint = function( s, w, h ) end

	/*
	*   console :: bottom right :: clear button
	*/

	self.b_clr = vgui.Create( 'DButton', self.p_btm_r_inner )
	self.b_clr:Dock( LEFT )
	self.b_clr:DockMargin( 0, 0, 2, 0 )
	self.b_clr:SetText( '' )
	self.b_clr:SetSize( 20, 20 )
	self.b_clr.Paint = function( s, w, h )
		draw.RoundedBox( 6, 0, 0, w, h, Color( 61, 94, 191, self.Alpha ) )
		draw.SimpleText( 'x', prefix .. 'devcon.clear', w / 2, h / 2 - 1, Color( 255, 255, 255, self.Alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.b_clr.DoClick = function( )
		self:ActionClear( )
	end

	/*
	*   console :: bottom right :: settings button
	*/

	self.b_settings = vgui.Create( 'DButton', self.p_btm_r_inner )
	self.b_settings:Dock( LEFT )
	self.b_settings:DockMargin( 2, 0, 2, 0 )
	self.b_settings:SetText( '' )
	self.b_settings:SetSize( 20, 20 )
	self.b_settings.Paint = function( s, w, h )
		draw.RoundedBox( 6, 0, 0, w, h, Color( 61, 94, 191, self.Alpha ) )
		draw.SimpleText( '⚙', prefix .. 'devcon.gear', w / 2, h / 2 - 4, Color( 255, 255, 255, self.Alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	self.b_settings.DoClick = function( )
		if helper:panel_visible( self.settings ) then
			helper:panel_destroy( self.settings )
		else
			local entry = vgui.Create( 'rlib.devconsole.settings' )
		end
	end

end

/*
*   GetTitle
*/

function PANEL:GetTitle( )
	return self.lblTitle:GetText( )
end

/*
*   SetTitle
*/

function PANEL:SetTitle( strTitle )
	self.lblTitle:SetText( strTitle )
end

/*
*   Think
*/

local key_dothink = 0
function PANEL:Think( )
	self.BaseClass.Think( self )

	if not self.is_visible then self:MoveToBack( ) end
	if input.IsKeyDown( KEY_ESCAPE ) or gui.IsGameUIVisible( ) then self:ActionHide( ) end

	/*
	*   keyup and keydown dtxt_input detection for history
	*/

	if input.IsKeyDown( 88 ) or input.IsKeyDown( 90 ) then

		if key_dothink > CurTime( ) then return end

		local ply				= LocalPlayer( )
		ply.debugger_history 	= ply.debugger_history or { }
		ply.debugger_index		= ply.debugger_index or 0

		local cnt_history		= #ply.debugger_history

		/*
		*   keyup
		*	
		*	@ref http://wiki.garrysmod.com/page/Enums/KEY
		*/

		if input.IsKeyDown( 88 ) then

			if ( ply.debugger_index < 1 ) then
				ply.debugger_index = 1
			elseif ( ply.debugger_index == 1 ) or ( ply.debugger_index < cnt_history ) then
				ply.debugger_index = ply.debugger_index + 1
			elseif ( ply.debugger_index >= cnt_history ) then
				ply.debugger_index = cnt_history
			end

		/*
		*   keydown
		*	
		*	@ref http://wiki.garrysmod.com/page/Enums/KEY
		*/

		elseif input.IsKeyDown( 90 ) then

			if ( ply.debugger_index < 1 ) then
				ply.debugger_index = 1
			elseif ( ply.debugger_index > 1 ) or ( ply.debugger_index <= cnt_history ) then
				ply.debugger_index = ply.debugger_index - 1
			elseif ( ply.debugger_index >= cnt_history ) then
				ply.debugger_index = cnt_history
			end

		end

		/*
		*   find next key in history table and set textentry
		*/

		local history = ply.debugger_history[ ply.debugger_index ]
		if history then
			self.dtxt_input:RequestFocus( )
			self.dtxt_input:SetText( history )
			self.dtxt_input:SetCaretPos( string.len( self.dtxt_input:GetValue( ) ) )
		end

		key_dothink = CurTime( ) + 0.3

	end

	local mousex = math.Clamp( gui.MouseX( ), 1, ScrW( ) - 1 )
	local mousey = math.Clamp( gui.MouseY( ), 1, ScrH( ) - 1 )

	if self.Dragging then
		local x = mousex - self.Dragging[ 1 ]
		local y = mousey - self.Dragging[ 2 ]

		if self:GetScreenLock( ) then
			x = math.Clamp( x, 0, ScrW( ) - self:GetWide( ) )
			y = math.Clamp( y, 0, ScrH( ) - self:GetTall( ) )
		end

		self:SetPos( x, y )
	end

	if self.Sizing then
		local x = mousex - self.Sizing[ 1 ]
		local y = mousey - self.Sizing[ 2 ]
		local px, py = self:GetPos()

		if ( x < self.m_iMinWidth ) then x = self.m_iMinWidth elseif ( x > ScrW() - px and self:GetScreenLock() ) then x = ScrW() - px end
		if ( y < self.m_iMinHeight ) then y = self.m_iMinHeight elseif ( y > ScrH() - py and self:GetScreenLock() ) then y = ScrH() - py end

		self:SetSize( x, y )
		self:SetCursor( 'sizenwse' )
		return
	end

	if ( self.Hovered and self.m_bSizable and mousex > ( self.x + self:GetWide() - 20 ) and mousey > ( self.y + self:GetTall() - 20 ) ) then
		self:SetCursor( 'sizenwse' )
		return
	end

	if ( self.Hovered and self:GetDraggable( ) and mousey < ( self.y + 24 ) ) then
		self:SetCursor( 'sizeall' )
		return
	end

	self:SetCursor( 'arrow' )

	if IsValid( self ) and ( ply.devconres_w ~= ScrW( ) or ply.devconres_h ~= ScrH( ) ) then
		ply.devconres_w = ScrW( )
		ply.devconres_h = ScrH( )

		local sc_w, sc_h	= helper.scalesimple( 0.85, 0.85, 0.90 ), helper.scalesimple( 0.85, 0.85, 0.90 )
		local pnl_w, pnl_h	= settings.debugger_ui_w, settings.debugger_ui_h
		local ui_w, ui_h	= sc_w * pnl_w, sc_h * pnl_h

		self:SetPos( ScrW( ) - ui_w - 20, ScrH( ) - ui_h - 20 )
	end

	if self.y < 0 then self:SetPos( self.x, 0 ) end

end

/*
*   OnMousePressed
*/

function PANEL:OnMousePressed( )
	if ( self.m_bSizable and gui.MouseX( ) > ( self.x + self:GetWide( ) - 20 ) and gui.MouseY( ) > ( self.y + self:GetTall( ) - 20 ) ) then
		self.Sizing =
		{
			gui.MouseX() - self:GetWide( ),
			gui.MouseY() - self:GetTall( )
		}
		self:MouseCapture( true )
		return
	end

	if ( self:GetDraggable( ) and gui.MouseY( ) < ( self.y + 24 ) ) then
		self.Dragging =
		{
			gui.MouseX( ) - self.x,
			gui.MouseY( ) - self.y
		}
		self:MouseCapture( true )
		return
	end
end

/*
*   OnMouseReleased
*/

function PANEL:OnMouseReleased( )
	self.Dragging = nil
	self.Sizing = nil
	self:MouseCapture( false )
end

/*
*   PerformLayout
*/

function PANEL:PerformLayout( )
	local titlePush = 0
	self.BaseClass.PerformLayout( self )

	self.lblTitle:SetPos( 11 + titlePush, 7 )
	self.lblTitle:SetSize( self:GetWide() - 25 - titlePush, 20 )
end

/*
*   Paint
*/

function PANEL:Paint( w, h )
	draw.RoundedBox( 4, 0, 0, w, h, Color( 45, 45, 45, self.Alpha ) )
	draw.RoundedBoxEx( 4, 2, 2, w - 4, 34 - 4, Color( 36, 36, 36, self.Alpha ), true, true, false, false )
end

/*
*   AddEntry
*/

function PANEL:AddEntry( mtype, ... )
	local entry = vgui.Create( 'rlib.devconsole.entry', self.dsp_content )
	entry:HandleSetup( mtype, ... )

	local y		= self.dsp_content.pnlCanvas:GetTall( )
	local w, h	= entry:GetSize( )

	y = y + h * 0.5
	y = y - self.dsp_content:GetTall( ) * 0.5

	self.dsp_content.VBar:AnimateTo( y, 0.5, 0, 0.5 )
end

/*
*   AddHistory
*/

function PANEL:AddHistory( command )
	local ply				= LocalPlayer( )
	ply.debugger_history 	= ply.debugger_history or { }

	table.insert( LocalPlayer( ).debugger_history, command )
end

/*
*   Clear History Index
*/

function PANEL:ClearHistoryIndex( )
	local ply = LocalPlayer( )
	ply.debugger_index = 0
end

/*
*   ActionEnter
*/

function PANEL:ActionEnter( )

	local cmd			= self.dtxt_input:GetValue( )
	local cmd_filter	= string.Trim( cmd )
	local cmd_len		= string.len( cmd_filter )
	local is_console	= false
	local is_say		= false
	local is_executed	= false

	/*
	*   required minimum command length
	*/

	if cmd_len < 1 then
		debugger:push( 2, 'invalid command' )
		self.dtxt_input:RequestFocus( )
		return false
	end

	/*
	*   check for gmod console command prefix
	*	strip prefix from command if present
	*/

	if string.sub( cmd_filter, 1, 1 ) == settings.debugger_gcon_prefix then
		is_console = true
		cmd_filter = string.sub( cmd_filter, 2 )
	end

	/*
	*   check for gmod say prefix
	*	strip prefix from command if present
	*/

	if string.sub( cmd_filter, 1, 1 ) == settings.debugger_say_prefix then
		is_say = true
		cmd_filter = string.sub( cmd_filter, 2 )
	end

	/*
	*   create command arguments
	*/

	local args		= string.Explode( ' ', cmd_filter )
	local cmd_base	= args and args[ 1 ]

	/*
	*   is console command
	*/

	if not is_executed and is_console then
		local concmd = table.concat( args, ' ' )
		LocalPlayer( ):ConCommand( concmd )

		debugger:push( 0, Color( 200, 50, 50 ), 'executed concommand: ', Color( 255, 255, 255 ), concmd )
		self:AddHistory( cmd_filter )
		is_executed = true
	end

	/*
	*   is say command
	*/

	if not is_executed and is_say then
		local concmd = table.concat( args, ' ' )
		if string.len( cmd_filter ) < 2 then
			debugger:push( 2, 'too few characters' )
			return false
		end

		LocalPlayer( ):ConCommand( 'say ' .. concmd )

		debugger:push( 0, Color( 50, 200, 50 ), 'executed say: ', Color( 255, 255, 255 ), concmd )
		self:AddHistory( cmd_filter )
		is_executed = true
	end

	/*
	*   is integrated rlib command
	*/

	if not is_executed and not is_console and ( settings.debugger_binds[cmd_base] and settings.debugger_binds[ cmd_base ].func ) then
		helper:table_rmindex( args, 1 )
		settings.debugger_binds[ cmd_base ].func( self, args )
		self:AddHistory( cmd_filter )
		is_executed = true
	end

	self.dtxt_input:SetText( '' )
	self.dtxt_input:RequestFocus( )

end

/*
*   ActionClear
*/

function PANEL:ActionClear( )
	self.dtxt_input:SetText( '' )
	self.dtxt_input:RequestFocus( )
end

/*
*   ActionHide
*/

function PANEL:ActionHide( )
	self.is_visible = false

	self:SetState( )
	self:ClearHistoryIndex( )
	self:SetMouseInputEnabled( false )
	self:SetKeyboardInputEnabled( false )
end

/*
*   ActionShow
*/

function PANEL:ActionShow( )
	self.is_visible = true
	self:SetState( )
	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( true )
	self.dtxt_input:RequestFocus( )
end

/*
*   SetState
*/

function PANEL:SetState( )
	self.Alpha = self.is_visible and 255 or 0
	if IsValid( self.b_close ) then self.b_close:SetAlpha( self.Alpha ) end
	if IsValid( self.dtxt_input ) then self.dtxt_input:SetAlpha( self.Alpha ) end
	if IsValid( self.b_settings ) then self.b_settings:SetAlpha( self.Alpha ) end
end

/*
*   Destroy
*/

function PANEL:Destroy( )
	self:ClearHistoryIndex( )
	helper:panel_destroy( self, true, true )
end

/*
*   SetVisible
*/

function PANEL:SetVisible( bVisible )
	if bVisible then
		helper:panel_restore( self, true, true )
	else
		helper:panel_hide( self, true, true )
	end
end

vgui.Register( 'rlib.devconsole', PANEL, 'DFrame' )