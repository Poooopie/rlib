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
AccessorFunc( PANEL, 'm_HideButtons', 'HideButtons' )

function PANEL:Init( )

	self.Offset		= 0
	self.Scroll		= 0
	self.CanvasSize = 1
	self.BarSize	= 1

	self.btnUp = vgui.Create( 'DButton', self )
	self.btnUp:SetText( '' )
	self.btnUp.DoClick = function( s ) s:GetParent():AddScroll( -1 ) end

	self.btnDown = vgui.Create( 'DButton', self )
	self.btnDown:SetText( '' )
	self.btnDown.DoClick = function( s ) s:GetParent():AddScroll( 1 ) end

	self.btnGrip = vgui.Create( 'DScrollBarGrip', self )

	self:SetSize( 15, 15 )
	self:SetHideButtons( false )

	self.Paint = function( s, w, h )
		draw.RoundedBox( 4, 12, 10, 4, h - 20, Color( 35, 35, 35, self.Alpha ) )
	end
	self.btnUp.Paint = function( s, w, h ) end
	self.btnDown.Paint = function( s, w, h ) end
	self.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 4, 0, 0, 20, h, Color( 76, 158, 73, self.Alpha ) )
	end

end

function PANEL:SetEnabled( b )

	if not b then
		self.Offset = 0
		self:SetScroll( 0 )
		self.HasChanged = true
	end

	self:SetMouseInputEnabled( b )
	self:SetVisible( b )
	if self.Enabled ~= b then

		self:GetParent( ):InvalidateLayout( )

		if self:GetParent( ).OnScrollbarAppear then
			self:GetParent( ):OnScrollbarAppear( )
		end

	end

	self.Enabled = b

end

function PANEL:Value( )
	return self.Pos
end

function PANEL:BarScale()
	if self.BarSize == 0 then return 1 end
	return self.BarSize / ( self.CanvasSize + self.BarSize )
end

function PANEL:SetUp( _barsize_, _canvassize_ )
	self.BarSize = _barsize_
	self.CanvasSize = math.max( _canvassize_ - _barsize_, 1 )

	self:SetEnabled( _canvassize_ > _barsize_ )
	self:InvalidateLayout()
end

function PANEL:OnMouseWheeled( dlta )
	if not self:IsVisible( ) then return false end

	return self:AddScroll( dlta * -2 )
end

function PANEL:AddScroll( dlta )
	local OldScroll = self:GetScroll( )

	dlta = dlta * 25
	self:SetScroll( self:GetScroll( ) + dlta )

	return OldScroll ~= self:GetScroll( )
end

function PANEL:SetScroll( scrll )
	if not self.Enabled then self.Scroll = 0 return end

	self.Scroll = math.Clamp( scrll, 0, self.CanvasSize )
	self:InvalidateLayout( )

	local func = self:GetParent( ).OnVScroll
	if func then
		func( self:GetParent( ), self:GetOffset( ) )
	else
		self:GetParent( ):InvalidateLayout( )
	end
end

function PANEL:AnimateTo( scrll, length, delay, ease )
	local anim = self:NewAnimation( length, delay, ease )
	anim.StartPos = self.Scroll
	anim.TargetPos = scrll
	anim.Think = function( anim, pnl, fraction )
		pnl:SetScroll( Lerp( fraction, anim.StartPos, anim.TargetPos ) )
	end
end

function PANEL:GetScroll( )
	if not self.Enabled then self.Scroll = 0 end
	return self.Scroll
end

function PANEL:GetOffset( )
	if not self.Enabled then return 0 end
	return self.Scroll * -1
end

function PANEL:Think( )
	if IsValid( debugger.inf ) then
		self.Alpha = debugger.inf.is_visible and 255 or 0
	end
end

function PANEL:Paint( w, h )
	derma.SkinHook( 'Paint', 'VScrollBar', self, w, h )
	return true
end

function PANEL:OnMousePressed( )
	local x, y = self:CursorPos( )
	local PageSize = self.BarSize

	if y > self.btnGrip.y then
		self:SetScroll( self:GetScroll( ) + PageSize )
	else
		self:SetScroll( self:GetScroll( ) - PageSize )
	end
end

function PANEL:OnMouseReleased()
	self.Dragging = false
	self.DraggingCanvas = nil
	self:MouseCapture( false )
	self.btnGrip.Depressed = false
end

function PANEL:OnCursorMoved( x, y )

	if not self.Enabled then return end
	if not self.Dragging then return end

	local x, y = self:ScreenToLocal( 0, gui.MouseY() )

	y = y - self.btnUp:GetTall( )
	y = y - self.HoldPos

	local BtnHeight = self:GetWide( )
	if self:GetHideButtons( ) then BtnHeight = 0 end

	local TrackSize = self:GetTall( ) - BtnHeight * 2 - self.btnGrip:GetTall( )

	y = y / TrackSize

	self:SetScroll( y * self.CanvasSize )

end

function PANEL:Grip()
	if not self.Enabled then return end
	if self.BarSize == 0 then return end

	self:MouseCapture( true )
	self.Dragging = true

	local x, y = self.btnGrip:ScreenToLocal( 0, gui.MouseY() )
	self.HoldPos = y

	self.btnGrip.Depressed = true
end

function PANEL:PerformLayout( )

	local Wide = self:GetWide( )
	local BtnHeight = Wide

	if self:GetHideButtons( ) then BtnHeight = 0 end

	local Scroll = self:GetScroll( ) / self.CanvasSize
	local BarSize = 20
	local Track = self:GetTall( ) - ( BtnHeight * 2 ) - BarSize

	Track = Track + 1

	Scroll = Scroll * Track

	self.btnGrip:SetPos( 4, BtnHeight + Scroll )
	self.btnGrip:SetSize( Wide, BarSize )

	if ( BtnHeight > 0 ) then
		self.btnUp:SetPos( 4, 0, Wide, Wide )
		self.btnUp:SetSize( Wide, BtnHeight )

		self.btnDown:SetPos( 4, self:GetTall( ) - BtnHeight )
		self.btnDown:SetSize( Wide, BtnHeight )

		self.btnUp:SetVisible( true )
		self.btnDown:SetVisible( true )
	else
		self.btnUp:SetVisible( false )
		self.btnDown:SetVisible( false )
		self.btnDown:SetSize( Wide, BtnHeight )
		self.btnUp:SetSize( Wide, BtnHeight )
	end

end

derma.DefineControl( 'rlib.ui.scrollbar', 'rlib scrollbar', PANEL, 'Panel' )
