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
surface.CreateFont( prefix .. 'devcon.trash', { font = 'Roboto', size = 24, weight = 800, antialias = true } )
surface.CreateFont( prefix .. 'devcon.copy', { font = 'Roboto', size = 20, weight = 100, antialias = true } )
surface.CreateFont( prefix .. 'devcon.title', { font = 'Roboto Light', size = 16, weight = 600, antialias = true } )
surface.CreateFont( prefix .. 'devcon.logger', { font = 'Roboto Light', size = 16, weight = 600, antialias = true } )
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
	local pnl_w, pnl_h	= 500, 345
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
		helper:panel_center( self, 0.3, 1 )
	else
		helper:panel_center( self )
	end

	/*
	*   settings :: titlebar
	*/

	self.lblTitle = vgui.Create( 'DLabel', self )
	self.lblTitle:SetText('')
	self.lblTitle:SetFont( prefix .. 'devcon.title' )
	self.lblTitle:SetColor( Color( 255, 255, 255, self.Alpha ) )
	self.lblTitle.Paint = function( s, w, h )
		draw.SimpleText( 'Console :: Settings', prefix .. 'devcon.title', 3, h / 2, Color( 237, 237, 237, self.Alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end

	/*
	*   settings :: close button
	*/

	self.btnClose = vgui.Create( 'DButton', self )
	self.btnClose:SetText( '' )
	self.btnClose.Paint = function( s, w, h )
		draw.SimpleText( '-', prefix .. 'devcon.ico', w / 2, h / 2 + 4, Color( 237, 237, 237, self.Alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	self.btnClose.DoClick = function( s )
		--self:ActionHide( )
		self:Remove( )
	end

	/*
	*   console :: primary container
	*/

	self.p_parent = vgui.Create( 'DPanel', self )
	self.p_parent:Dock( FILL )
	self.p_parent:DockMargin( 0, 10, 0, 0 )
	self.p_parent.Paint = function( s, w, h ) end

	/*
	*   console :: body
	*/

	self.p_body = vgui.Create( 'DPanel', self.p_parent )
	self.p_body:Dock( FILL )
	self.p_body.Paint = function( s, w, h ) end

	/*
	*   console :: body :: scroll panel
	*/

	self.dsp_ctl_content = vgui.Create( 'rlib.ui.scrollpanel', self.p_body )
    self.dsp_ctl_content:Dock( FILL )

	for k, v in pairs( ply_settings ) do

		if not v.is_visible then continue end

			local ConfigType 	= v.stype
			local ConfigName 	= tostring( k )

			/*
			*   type checkbox
			*/

			if ConfigType == 'checkbox' then
				local getConvar = GetConVar( v.id )
				self.p_item_container = vgui.Create( 'DPanel', self.dsp_ctl_content )
				self.p_item_container:Dock( TOP )
				self.p_item_container:DockMargin( 12, 5, 12, 0 )
				self.p_item_container:SetTall( 20 )
				self.p_item_container.Paint = function( s, w, h ) end

				self.settingName = vgui.Create( 'DLabel', self.p_item_container )
				self.settingName:Dock( FILL )
				self.settingName:DockMargin( 0, 0, 0, 0 )
				self.settingName:SetFont( prefix .. 'devcon.setting.label' )
				self.settingName:SetText( v.name )
				self.settingName:SizeToContents( )

				local valueMod = vgui.Create( 'rlib.ui.toggle', self.p_item_container )
				valueMod:Dock( RIGHT )
				valueMod.enabled = getConvar:GetBool( ) or false
				valueMod.onOptionChanged = function( s )
					getConvar:SetBool( valueMod.enabled )
				end

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

vgui.Register( 'rlib.devconsole.settings', PANEL, 'DFrame' )