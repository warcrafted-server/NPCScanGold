--[[****************************************************************************
  * _NPCScanGold                                                               *
  * _NPCScanGold.Live.lua - Detects rares that are actually near you.          *
  * _NPCScan's own scan can only catch an NPC the moment its name enters the   *
  * client cache, so rares that are already cached never alert again.  This    *
  * watches units the way SilverDragon did instead, which the cache doesn't    *
  * affect.                                                                    *
  ****************************************************************************]]


local me = select( 2, ... );
local L = me.L;
local Live = CreateFrame( "Frame" );
me.Live = Live;

local ALERT_COOLDOWN = 300; --- Seconds before the same NPC may alert again.
local SCAN_INTERVAL = 0.5;

local GROUP_UNITS = { "targettarget", "party1target", "party2target", "party3target", "party4target" };

local LastAlert = {}; --- [ NpcID ] = GetTime() of its last alert, from any scan.
local NamesToIDs = {}; --- [ Localized name ] = NpcID.  Nameplates only give us a name.




--- @return NpcID encoded in a unit's GUID, or nil for players and their pets.
local function GetUnitNpcID ( UnitID )
	local GUID = UnitGUID( UnitID );
	if ( GUID ) then
		return tonumber( GUID:sub( 8, 12 ), 16 );
	end
end


--- Fires _NPCScan's usual found alert unless this NPC alerted recently.
local function Alert ( NpcID, Name )
	local Last = LastAlert[ NpcID ];
	if ( Last and GetTime() - Last < ALERT_COOLDOWN ) then
		return;
	end

	-- No tamable warning here: pets are filtered out before this point, so anything
	-- that gets this far is the real mob.
	me.Print( L.FOUND_FORMAT:format( Name ), GREEN_FONT_COLOR );
	me.Button:SetNPC( NpcID, Name );
end


--- Alerts if the given unit is a live rare.
local function ProcessUnit ( UnitID )
	if ( not UnitExists( UnitID ) or UnitPlayerControlled( UnitID ) ) then -- Skips hunter pets
		return;
	end
	local Classification = UnitClassification( UnitID );
	if ( Classification ~= "rare" and Classification ~= "rareelite" ) then
		return;
	end
	if ( not UnitIsVisible( UnitID ) or UnitIsDead( UnitID ) ) then
		return;
	end

	local NpcID, Name = GetUnitNpcID( UnitID ), UnitName( UnitID );
	if ( NpcID and Name ) then
		NamesToIDs[ Name ] = NpcID;
		Alert( NpcID, Name );
	end
end




local ScanNameplates;
do
	local Nameplates = {}; --- [ Nameplate frame ] = Its name fontstring.

	--- Recognizes a nameplate by the regions Blizzard builds it from.
	-- Nameplates are the unnamed frames directly under WorldFrame.
	local function AddIfNameplate ( Frame )
		if ( Frame:GetObjectType() ~= "Frame" or Frame:GetName() or Nameplates[ Frame ] ) then
			return;
		end

		local Name, Border, Glow;
		for Index = 1, Frame:GetNumRegions() do
			local Region = select( Index, Frame:GetRegions() );
			local RegionType = Region and Region:GetObjectType();
			if ( RegionType == "FontString" ) then
				local Point, _, RelativePoint = Region:GetPoint();
				if ( Point == "BOTTOM" and RelativePoint == "CENTER" ) then
					Name = Region;
				end
			elseif ( RegionType == "Texture" ) then
				local Texture = Region:GetTexture();
				if ( Texture == [[Interface\Tooltips\Nameplate-Border]] ) then
					Border = Region;
				elseif ( Texture == [[Interface\Tooltips\Nameplate-Glow]] ) then
					Glow = Region;
				end
			end
		end

		if ( Name and Border and Glow ) then
			Nameplates[ Frame ] = Name;
		end
	end

	local WorldChildren = 0;
	--- Alerts for rares shown on a nameplate, which needs no target or mouseover.
	function ScanNameplates ()
		if ( GetCVar( "nameplateShowEnemies" ) ~= "1" ) then
			return;
		end
		if ( WorldChildren ~= WorldFrame:GetNumChildren() ) then
			WorldChildren = WorldFrame:GetNumChildren();
			for Index = 1, WorldChildren do
				AddIfNameplate( select( Index, WorldFrame:GetChildren() ) );
			end
		end

		for Frame, NameRegion in pairs( Nameplates ) do
			if ( Frame:IsVisible() ) then
				local Name = NameRegion:GetText();
				local NpcID = Name and NamesToIDs[ Name ];
				if ( NpcID ) then
					Alert( NpcID, Name );
				end
			end
		end
	end
end




function Live:PLAYER_TARGET_CHANGED ()
	ProcessUnit( "target" );
end
function Live:UPDATE_MOUSEOVER_UNIT ()
	ProcessUnit( "mouseover" );
end

--- Learns the localized names of the rares already in the client cache.
-- Nameplates only expose a name, and cached rares are exactly the ones this
-- module has to cover, so their names are the ones worth resolving.
function Live:PLAYER_LOGIN ()
	self:UnregisterEvent( "PLAYER_LOGIN" );

	for NpcID in pairs( me.Rares ) do
		local Name = me.TestID( NpcID );
		if ( Name ) then
			NamesToIDs[ Name ] = NpcID;
		end
	end
end


local NextScan = 0;
--- Polls group targets and nameplates, which fire no events of their own.
function Live:OnUpdate ( Elapsed )
	NextScan = NextScan - Elapsed;
	if ( NextScan <= 0 ) then
		NextScan = SCAN_INTERVAL;

		for _, UnitID in ipairs( GROUP_UNITS ) do
			ProcessUnit( UnitID );
		end
		ScanNameplates();
	end
end


--- Enables or disables scanning for rares near you.
-- @return True if changed.
function me.SetLiveScan ( Enable )
	if ( not Enable ~= not me.Options.LiveScan ) then
		me.Options.LiveScan = Enable or nil;

		me.Config.LiveScan:SetChecked( Enable );
		if ( Enable ) then
			Live:RegisterEvent( "PLAYER_TARGET_CHANGED" );
			Live:RegisterEvent( "UPDATE_MOUSEOVER_UNIT" );
			Live:Show();
		else
			Live:UnregisterEvent( "PLAYER_TARGET_CHANGED" );
			Live:UnregisterEvent( "UPDATE_MOUSEOVER_UNIT" );
			Live:Hide();
		end
		return true;
	end
end




do
	local SetNPC = me.Button.SetNPC;
	--- Keeps every alert on the same cooldown, wherever it came from.
	function me.Button:SetNPC ( ID, Name )
		if ( tonumber( ID ) ) then
			LastAlert[ tonumber( ID ) ] = GetTime();
		end
		return SetNPC( self, ID, Name );
	end
end


Live:Hide();
Live:SetScript( "OnUpdate", Live.OnUpdate );
Live:SetScript( "OnEvent", function ( self, Event, ... )
	if ( self[ Event ] ) then
		return self[ Event ]( self, Event, ... );
	end
end );
Live:RegisterEvent( "PLAYER_LOGIN" );
