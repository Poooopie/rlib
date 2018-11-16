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
*	panel
*/

local PANEL = { }

/*
*	initialize
*/

function PANEL:Init( )

	self.Name 				= ''
	self.Ply 				= nil
	self.Col 				= nil
	self.fade_reversed 		= false
	self.fade_expired 		= false
	self.fade_timer 		= CurTime( ) + ( settings.debugger_fadetime or 7 )

	self:SetSize( self:GetParent( ):GetWide( ), 10 )
	self:Dock( TOP )
	self:DockMargin( 5, 0, 5, 0 )
	self:LerpPositions( 1, true )

	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.7 )

	self.response = vgui.Create( 'RichText', self )
	self.response:SetPos( 0, 0 )
	self.response:SetWide( self:GetParent( ):GetWide( ) - 10 )
	self.response:InsertColorChange( 255, 255, 255, 255 )

end

/*
*	paint
*/

function PANEL:Paint( w, h )

end

/*
*	preform layout
*/

function PANEL:PerformLayout( )
	self.response:SetFontInternal( prefix .. 'devcon.logger' )
	self.response:SetVerticalScrollbarEnabled( false )
	self.response:SetToFullHeight( )
	self.response:SetWide( self:GetParent( ):GetWide( ) - 64 )

	self:SizeToChildren( false, true )
	self:InvalidateParent( )
end

/*
*	think
*/

function PANEL:Think( )

	if debugger.inf.is_visible then
		self.fade_reversed = false
	else
		self.fade_reversed = true
	end

	if self.fade_reversed then
		if self.fade_expired then
			self:SetAlpha( 0 )
			return
		end

		if self.fade_timer and self.fade_timer <= CurTime( ) then
			self:AlphaTo( 0, 1.5, 0, function( ) self.fade_expired = true end )
		end
	else
		self:SetAlpha( 255 )
	end
end

/*
*	handle setup
*/

function PANEL:HandleSetup( mtype, data )

	if helper:cvar_bool( 'devcon_timestamps' ) then
		self.response:InsertColorChange( 215, 215, 215, 255 )
		self.response:AppendText( '[' .. settings.debugger_timeformat .. '] ' )
	end

	for k, v in ipairs( data ) do
		if mtype and mtype > 0 then
			local data_mtype	= '[' .. rlib:ucfirst( helper._debugTitles[mtype] ) .. '] '
			local data_mcolor	= helper._debuggerColors[mtype]

			self.response:InsertColorChange( data_mcolor.r, data_mcolor.g, data_mcolor.b, 255 )
			self.response:AppendText( data_mtype )
			self.response:InsertColorChange( 255, 255, 255, 255 )
		end
		if IsColor( v ) then
			local data_mcolor = v
			self.response:InsertColorChange( data_mcolor.r, data_mcolor.g, data_mcolor.b, data_mcolor.a )
		elseif isstring( v ) then
			self.response:AppendText( v )
		end
	end

	if not IsValid( self.Ply ) then
		self.Col = Color( 210, 210, 210 )
		self:InvalidateLayout( )
	end
end

vgui.Register('rlib.devconsole.entry', PANEL, 'DPanel')