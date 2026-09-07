--[[****************************************************************************
  * _NPCScanGold                                                               *
  * _NPCScanGold.Broker.lua - LibDataBroker feed and minimap button.           *
  * Titan Panel picks the feed up through its own LDB bridge, so the same      *
  * object drives both the Titan plugin and the minimap button.                *
  ****************************************************************************]]


local AddOnName, me = ...;
local L = me.L;
local Broker = CreateFrame( "Frame" );
me.Broker = Broker;

local BROKER_ICON = [[Interface\Icons\INV_Misc_Head_Dragon_01]];

local LDB = LibStub( "LibDataBroker-1.1", true );
local DBIcon = LibStub( "LibDBIcon-1.0", true );
local DataObject;




--- Lists the rares of the current zone, and which of them are already cached.
local function AddZoneRares ( Tooltip )
	local Babble = LibStub( "LibBabble-Zone-3.0" ):GetUnstrictLookupTable();
	local ZoneName = GetZoneText();
	local Count = 0;

	for NpcID, Rare in pairs( me.Rares ) do
		if ( Babble[ Rare.Zone ] == ZoneName ) then
			Count = Count + 1;
			local Cached = me.TestID( NpcID );
			Tooltip:AddDoubleLine( Rare.Name,
				Cached and L.BROKER_CACHED or L.BROKER_SCANNING,
				nil, nil, nil,
				Cached and RED_FONT_COLOR.r or GREEN_FONT_COLOR.r,
				Cached and RED_FONT_COLOR.g or GREEN_FONT_COLOR.g,
				Cached and RED_FONT_COLOR.b or GREEN_FONT_COLOR.b );
		end
	end

	if ( Count == 0 ) then
		Tooltip:AddLine( L.BROKER_ZONE_EMPTY );
	end
end


--- Builds the tooltip shown by the minimap button and by Titan Panel.
local function OnTooltipShow ( Tooltip )
	Tooltip:AddLine( L.CONFIG_TITLE );
	Tooltip:AddLine( GetZoneText(), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b );
	AddZoneRares( Tooltip );
	Tooltip:AddLine( L.BROKER_HINT, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b );
end


--- Opens the options pane, or the search pane when right clicked.
local function OnClick ( _, Button )
	if ( Button == "RightButton" ) then
		InterfaceOptionsFrame_OpenToCategory( me.Config.Search );
	else
		InterfaceOptionsFrame_OpenToCategory( me.Config );
	end
end




--- Enables or disables the minimap button.
-- @return True if changed.
function me.SetMinimapIcon ( Enable )
	if ( not Enable ~= not me.Options.MinimapIcon ) then
		me.Options.MinimapIcon = Enable or nil;

		me.Config.MinimapIcon:SetChecked( Enable );
		-- Set before registering too: LibDBIcon reads "hide" when the button is created
		me.Options.MinimapIconSettings.hide = not Enable or nil;

		if ( DBIcon and DBIcon:IsRegistered( AddOnName ) ) then
			if ( Enable ) then
				DBIcon:Show( AddOnName );
			else
				DBIcon:Hide( AddOnName );
			end
		end
		return true;
	end
end


do
	local SetNPC = me.Button.SetNPC;
	--- Shows the last found rare as the feed's text.
	function me.Button:SetNPC ( NpcID, Name )
		if ( DataObject ) then
			DataObject.text = Name;
		end
		return SetNPC( self, NpcID, Name );
	end
end


--- Registers the feed once saved settings are available.
function Broker:PLAYER_LOGIN ()
	self:UnregisterEvent( "PLAYER_LOGIN" );

	if ( not LDB ) then
		return;
	end
	DataObject = LDB:NewDataObject( AddOnName, {
		type = "data source";
		label = L.CONFIG_TITLE;
		text = L.BROKER_NONE_FOUND;
		icon = BROKER_ICON;
		tocname = AddOnName;
		OnClick = OnClick;
		OnTooltipShow = OnTooltipShow;
	} );

	if ( DBIcon ) then
		DBIcon:Register( AddOnName, DataObject, me.Options.MinimapIconSettings );
	end
end




Broker:SetScript( "OnEvent", function ( self, Event, ... )
	if ( self[ Event ] ) then
		return self[ Event ]( self, Event, ... );
	end
end );
Broker:RegisterEvent( "PLAYER_LOGIN" );
