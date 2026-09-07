--[[****************************************************************************
  * _NPCScanGold by Saiket                                                         *
  * Locales/Locale-zhCN.lua - Localized string constants (zh-CN).              *
  ****************************************************************************]]


if ( GetLocale() ~= "zhCN" ) then
	return;
end


-- See http://wow.curseforge.com/addons/npcscan/localization/zhCN/
local _NPCScanGold = select( 2, ... );
_NPCScanGold.L.NPCs = setmetatable( {
	[ 18684 ] = "独行者布罗加斯",
	[ 33776 ] = "古德利亚",
}, { __index = _NPCScanGold.L.NPCs; } );