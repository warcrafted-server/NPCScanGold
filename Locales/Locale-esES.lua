--[[****************************************************************************
  * _NPCScanGold by Saiket                                                         *
  * Locales/Locale-esES.lua - Localized string constants (es-ES/es-MX).        *
  ****************************************************************************]]


if ( GetLocale() ~= "esES" and GetLocale() ~= "esMX" ) then
	return;
end


-- See http://wow.curseforge.com/addons/npcscan/localization/esES/
local _NPCScanGold = select( 2, ... );
_NPCScanGold.L.NPCs = setmetatable( {
	[ 18684 ] = "Bro'Gaz sin Clan",
	[ 32491 ] = "Protodraco Tiempo Perdido",
	[ 33776 ] = "Gondria",
	[ 35189 ] = "Skoll",
	[ 38453 ] = "Arcturis",
}, { __index = _NPCScanGold.L.NPCs; } );