--[[****************************************************************************
  * _NPCScanGold                                                               *
  * _NPCScanGold.Map.lua - Shows rare spawn locations on the world map.        *
  ****************************************************************************]]


local me = select( 2, ... );
local L = me.L;
local Map = CreateFrame( "Frame" );
me.Map = Map;

local PIN_SIZE = 14;
local PIN_TEXTURE = [[Interface\Icons\INV_Misc_Head_Dragon_01]];

local Pins = {}; --- Pool of pin buttons, all parented to the world map.
local PinsUsed = 0;
local NodesByMapFile = {}; --- [ MapFile ] = { [ NpcID ] = Location; ... }
local ZoneToMapFile; --- [ Localized zone name ] = Map file name, built at login.
local LastMapFile;




--- @return X and Y as fractions of the zone map, from a packed location.
local function GetXY ( Location )
	return floor( Location / 10000 ) / 10000, ( Location % 10000 ) / 10000;
end


--- Fills in the localized zone name to map file lookup using the client's own map data.
-- Map file names are the same in every locale, unlike zone names, so they're what
-- pins get grouped by.
local function BuildZoneLookup ()
	ZoneToMapFile = {};

	for ContinentID = 1, select( "#", GetMapContinents() ) do
		local Zones = { GetMapZones( ContinentID ) };
		for ZoneIndex, ZoneName in ipairs( Zones ) do
			SetMapZoom( ContinentID, ZoneIndex );
			ZoneToMapFile[ ZoneName ] = GetMapInfo();
		end
	end
end


--- Groups all rares with known coordinates by the map file they belong to.
local function BuildNodes ()
	local Babble = LibStub( "LibBabble-Zone-3.0" ):GetUnstrictLookupTable();

	for NpcID, Rare in pairs( me.Rares ) do
		if ( Rare.Locations ) then
			local MapFile = ZoneToMapFile[ Babble[ Rare.Zone ] ];
			if ( MapFile ) then -- Instances and unknown zones have no world map
				local Nodes = NodesByMapFile[ MapFile ];
				if ( not Nodes ) then
					Nodes = {};
					NodesByMapFile[ MapFile ] = Nodes;
				end
				for _, Location in ipairs( Rare.Locations ) do
					Nodes[ #Nodes + 1 ] = { NpcID = NpcID; Location = Location; };
				end
			end
		end
	end
end




--- Shows details for the pin's rare when hovered.
function Map:PinOnEnter ()
	local Rare = me.Rares[ self.NpcID ];

	WorldMapTooltip:SetOwner( self, "ANCHOR_RIGHT" );
	WorldMapTooltip:SetText( Rare.Name );
	WorldMapTooltip:AddLine( L.MAP_PIN_LEVEL_FORMAT:format(
		Rare.Elite and ( "%d+" ):format( Rare.Level ) or Rare.Level,
		Rare.Type or UNKNOWN ), nil, nil, nil, true );

	if ( me.TamableIDs[ self.NpcID ] ) then
		WorldMapTooltip:AddLine( L.MAP_PIN_TAMABLE, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b );
	end
	if ( me.TestID( self.NpcID ) ) then
		WorldMapTooltip:AddLine( L.MAP_PIN_CACHED, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b );
	end
	WorldMapTooltip:Show();
end
function Map:PinOnLeave ()
	WorldMapTooltip:Hide();
end


--- @return A pin button from the pool, creating one if needed.
local function PinAcquire ()
	PinsUsed = PinsUsed + 1;
	local Pin = Pins[ PinsUsed ];

	if ( not Pin ) then
		Pin = CreateFrame( "Button", nil, WorldMapButton );
		Pin:SetWidth( PIN_SIZE );
		Pin:SetHeight( PIN_SIZE );
		Pin:SetScript( "OnEnter", Map.PinOnEnter );
		Pin:SetScript( "OnLeave", Map.PinOnLeave );

		local Icon = Pin:CreateTexture( nil, "OVERLAY" );
		Icon:SetAllPoints();
		Icon:SetTexture( PIN_TEXTURE );
		Icon:SetTexCoord( 0.07, 0.93, 0.07, 0.93 ); -- Trims the icon's built-in border

		Pins[ PinsUsed ] = Pin;
	end
	return Pin;
end

--- Redraws all pins for the zone currently shown on the world map.
function Map:Update ()
	for _, Pin in ipairs( Pins ) do
		Pin:Hide();
	end
	PinsUsed = 0;

	if ( not me.Options.MapPins or not ZoneToMapFile ) then
		return;
	end
	local Nodes = NodesByMapFile[ GetMapInfo() or "" ];
	if ( not Nodes ) then
		return;
	end

	local Width, Height = WorldMapButton:GetWidth(), WorldMapButton:GetHeight();
	for _, Node in ipairs( Nodes ) do
		local Pin = PinAcquire();
		local X, Y = GetXY( Node.Location );

		Pin.NpcID = Node.NpcID;
		Pin:ClearAllPoints(); -- Pins get reused for different spots as the map changes
		Pin:SetPoint( "CENTER", WorldMapButton, "TOPLEFT", X * Width, -Y * Height );
		Pin:Show();
	end
end




--- Redraws pins when the map view changes.
function Map:WORLD_MAP_UPDATE ()
	local MapFile = GetMapInfo();
	if ( MapFile ~= LastMapFile ) then
		LastMapFile = MapFile;
		self:Update();
	end
end

--- Builds the zone lookup and pin data once the player's world is loaded.
function Map:PLAYER_LOGIN ()
	self:UnregisterEvent( "PLAYER_LOGIN" );

	BuildZoneLookup();
	BuildNodes();
	SetMapToCurrentZone();

	LastMapFile = nil; -- Forces a redraw on the next map update
	self:RegisterEvent( "WORLD_MAP_UPDATE" );
end


--- Enables or disables the map pins.
-- @return True if changed.
function me.SetMapPins ( Enable )
	if ( not Enable ~= not me.Options.MapPins ) then
		me.Options.MapPins = Enable or nil;

		me.Config.MapPins:SetChecked( Enable );
		Map:Update();
		return true;
	end
end




Map:SetScript( "OnEvent", function ( self, Event, ... )
	if ( self[ Event ] ) then
		return self[ Event ]( self, Event, ... );
	end
end );
Map:RegisterEvent( "PLAYER_LOGIN" );

-- Pins are placed at pixel offsets, so they must be replaced when the map resizes
-- between its windowed and fullscreen modes.
WorldMapFrame:HookScript( "OnSizeChanged", function ()
	Map:Update();
end );
