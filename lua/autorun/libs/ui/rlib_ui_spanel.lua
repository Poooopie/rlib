/*
*	@package     rlib
*	@author      Richard [http://steamcommunity.com/profiles/76561198135875727]
*	
*	BY MODIFYING THIS FILE -- YOU UNDERSTAND THAT THE ABOVE MENTIONED AUTHORS CANNOT BE HELD RESPONSIBLE
*	FOR ANY ISSUES THAT ARISE FROM MAKING ANY ADJUSTMENTS TO THIS SCRIPT. YOU UNDERSTAND THAT THE ABOVE 
*	MENTIONED AUTHOR CAN ALSO NOT BE HELD RESPONSIBLE FOR ANY DAMAGES THAT MAY OCCUR TO YOUR SERVER AS A 
*	RESULT OF THIS SCRIPT AND ANY OTHER SCRIPT NOT BEING COMPATIBLE WITH ONE ANOTHER.
*/

/*
*	standard tables and localization
*/

rlib = rlib or { }

local base		= rlib
local prefix	= base.manifest.prefix
local script	= base.manifest.name
local version	= base.manifest.build
local settings	= base.settings
local debugger	= base.debug

local PANEL = { }

AccessorFunc( PANEL, 'Padding', 'Padding' )
AccessorFunc( PANEL, 'pnlCanvas', 'Canvas' )

function PANEL:Init( )

	self.pnlCanvas = vgui.Create( 'Panel', self )
	self.pnlCanvas.OnMousePressed = function( self, code ) self:GetParent( ):OnMousePressed( code ) end
	self.pnlCanvas:SetMouseInputEnabled( true )
	self.pnlCanvas.PerformLayout = function( s )
		self:PerformLayout( )
		self:InvalidateParent( )
	end
	self.Alpha = 255

	self.VBar = vgui.Create( 'rlib.ui.scrollbar', self )
	self.VBar:Dock( RIGHT )
	self.VBar:SetWide( 25 )
	self.VBar:DockMargin( 0, 0, 6, 0 )

	self:SetPadding( 0 )
	self:SetMouseInputEnabled( true )

	-- This turns off the engine drawing
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )
	self:SetPaintBackground( false )

end

function PANEL:AddItem( pnl )
	pnl:SetParent( self:GetCanvas( ) )
end

function PANEL:OnChildAdded( child )
	self:AddItem( child )
end

function PANEL:SizeToContents( )
	self:SetSize( self.pnlCanvas:GetSize( ) )
end

function PANEL:GetVBar( )
	return self.VBar
end

function PANEL:GetCanvas( )
	return self.pnlCanvas
end

function PANEL:InnerWidth( )
	return self:GetCanvas( ):GetWide( )
end

function PANEL:Rebuild( )

	self:GetCanvas( ):SizeToChildren( false, true )

	if ( self.m_bNoSizing and self:GetCanvas( ):GetTall( ) < self:GetTall( ) ) then
		self:GetCanvas( ):SetPos( 0, ( self:GetTall( ) - self:GetCanvas( ):GetTall( ) ) * 0.5 )
	end

end

function PANEL:OnMouseWheeled( dlta )
	return self.VBar:OnMouseWheeled( dlta )
end

function PANEL:OnVScroll( iOffset )
	self.pnlCanvas:SetPos( 0, iOffset )
end

function PANEL:ScrollToChild( panel )
	self:PerformLayout( )

	local x, y = self.pnlCanvas:GetChildPosition( panel )
	local w, h = panel:GetSize()

	y = y + h * 0.5
	y = y - self:GetTall() * 0.5

	self.VBar:AnimateTo( y, 0.5, 0, 0.5 )
end

function PANEL:PerformLayout( )
	local Tall = self.pnlCanvas:GetTall( )
	local Wide = self:GetWide( )
	local YPos = 0

	self:Rebuild( )

	self.VBar:SetUp( self:GetTall( ), self.pnlCanvas:GetTall( ) )
	YPos = self.VBar:GetOffset( )

	if ( self.VBar.Enabled ) then Wide = Wide - self.VBar:GetWide() end

	self.pnlCanvas:SetPos( 0, YPos )
	self.pnlCanvas:SetWide( Wide )

	self:Rebuild( )

	if Tall ~= self.pnlCanvas:GetTall( ) then
		self.VBar:SetScroll( self.VBar:GetScroll( ) )
	end
end

function PANEL:Think( )
	if IsValid( debugger.inf ) then
		self.Alpha = debugger.inf.is_visible and 255 or 0
	end
end

function PANEL:Clear( )
	return self.pnlCanvas:Clear( )
end

derma.DefineControl( 'rlib.ui.scrollpanel', 'rlib scrollpanel', PANEL, 'DPanel' )
