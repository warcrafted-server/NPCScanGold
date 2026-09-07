--[[****************************************************************************
  * _NPCScanGold by Saiket                                                         *
  * Locales/Locale-deDE.lua - Localized string constants (de-DE).              *
  ****************************************************************************]]


if ( GetLocale() ~= "deDE" ) then
	return;
end


-- See http://wow.curseforge.com/addons/npcscan/localization/deDE/
local _NPCScanGold = select( 2, ... );
_NPCScanGold.L.NPCs = setmetatable( {
	[ 18684 ] = "Bro'Gaz der Klanlose",
	[ 32491 ] = "Zeitverlorener Protodrache",
	[ 33776 ] = "Gondria",
	[ 35189 ] = "Skoll",
	[ 38453 ] = "Arcturis",
}, { __index = _NPCScanGold.L.NPCs; } );