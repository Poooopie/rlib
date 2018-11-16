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
surface.CreateFont( prefix .. 'devcon.setting.label', { font = 'Roboto Condensed', size = 15, weight = 100, antialias = true } )

/*
*   initialize
*/

local PANEL = { }


function PANEL:Init( )
	self:SetSize( 40, 15 )
	self:SetCursor( 'hand' )
	self.enabled = false
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 8, 0, 0, w, h, Color( 54, 54, 58 ) )

	if self.enabled then
		surface.SetDrawColor( Color( 103, 136, 214 ) )
		draw.NoTexture( )
		design.circle( w - 10, 10, 7, 25 )
	else
		surface.SetDrawColor( Color( 214, 103, 144 ) )
		draw.NoTexture( )
		design.circle( 10, 10, 7, 25 )
	end
end

function PANEL:OnMousePressed( )
	surface.PlaySound( 'ui/buttonclick.wav' )

	self.enabled = not self.enabled
	self:onOptionChanged( )
end

function PANEL:onOptionChanged( ) end

derma.DefineControl( 'rlib.ui.toggle', 'rlib toggle', PANEL, 'EditablePanel' )