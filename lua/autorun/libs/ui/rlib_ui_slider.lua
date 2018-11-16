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

local base			= rlib
local prefix		= base.manifest.prefix
local script		= base.manifest.name
local version		= base.manifest.build
local settings		= base.settings
local debugger		= base.debug
local helper		= base.h
local design		= base.d

local PANEL = { }

AccessorFunc( PANEL, 'm_iMin', 'Min' )
AccessorFunc( PANEL, 'm_iMax', 'Max' )
AccessorFunc( PANEL, 'm_iRange', 'Range' )
AccessorFunc( PANEL, 'm_iValue', 'Value' )
AccessorFunc( PANEL, 'm_iDecimals', 'Decimals' )
AccessorFunc( PANEL, 'm_fFloatValue', 'FloatValue' )

function PANEL:Init( )
	self:SetMin( 2 )
	self:SetMax( 10 )
	self:SetDecimals( 0 )

	local minVal = self:GetMin( )

	self.Dragging = true
	self.Knob.Depressed = true

	self:SetValue(minVal)
	self:SetSlideX(self:GetFraction( ))

	self.Dragging = false
	self.Knob.Depressed = false
	self.Knob:SetSize( 10, 14 )

	function self.Knob:Paint( w, h )
		draw.RoundedBox( 4, 1, 2, w - 2, h - 5, Color( 255, 255, 255, 255 ) )
	end

end

function PANEL:SetMinMax( minVal, maxVal )
	self:SetMin( minVal )
	self:SetMax( maxVal )
end

function PANEL:SetValue(value)
	value = math.Round(math.Clamp(tonumber(value) or 0, self:GetMin( ), self:GetMax( )), self.m_iDecimals)

	self.m_iValue = value

	self:SetFloatValue(value)
	self:OnValueChanged(value)
	self:SetSlideX(self:GetFraction( ))
end

function PANEL:GetFraction( )
	return (self:GetFloatValue( ) -self:GetMin( )) / self:GetRange( )
end

function PANEL:GetRange( )
	return (self:GetMax( ) - self:GetMin( ))
end

function PANEL:TranslateValues(x, y)
	self:SetValue( self:GetMin( ) + ( x * self:GetRange( ) ) )
	return self:GetFraction( ), y
end

function PANEL:OnValueChanged(value) end

function PANEL:Paint( w, h )
	local csetBarColor = helper:cvar_color( 'classes_sui_sliderbar_color', Color( 255, 255, 255, 255 ) )
	design.obox( 0, 8, w, 2, Color(0, 0, 0, 0), csetBarColor )
end

function PANEL:PaintOver( w, h )
	if (self.Hovered or self.Knob.Hovered or self.Knob.Depressed) then
		surface.DisableClipping(true)
		draw.SimpleText( self:GetValue( ), 'classes_ui_slider', self.Knob.x + self.Knob:GetWide( ) / 2, self.Knob.y - 7, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		surface.DisableClipping(false)
	end
end

derma.DefineControl( 'rlib.ui.slider', 'rlib slider', PANEL, 'DSlider' )