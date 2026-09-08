# _NPCScanGold

*[Versión en castellano](README.es.md)*

Addon for World of Warcraft: Wrath of the Lich King (3.3.5a, client build 12340) that merges
**[_NPCScan](http://sites.google.com/site/wowsaiket/Add-Ons/NPCScan)** (Saiket) with the rare
database from **[SilverDragon](https://www.curseforge.com/wow/addons/silver-dragon)** (Kemayo).

It keeps the original `_NPCScan` engine (visual and audio alerts, client cache tracking,
integration with map overlay addons) and injects the ~400 rare creature IDs that `SilverDragon`
covers across all of WotLK (Kalimdor, Eastern Kingdoms, Outland and Northrend), so `_NPCScan`
watches for them too without having to add them one by one.

## Features

- **Dual detection.** The `_NPCScan` engine alerts as soon as a creature's name enters the
  client cache, which has great reach but only works once per cache. In parallel, a
  SilverDragon-style live detection watches your target, mouseover, group targets and
  nameplates, which does alert on already-cached rares. Each one can be toggled separately.
- **Full database:** 408 rares across all of WotLK, active from the start. Live detection also
  alerts on any mob with a rare classification, whether it's in the list or not.
- **World map markers:** known spawn points for each rare, with name, level, type, whether it's
  tamable, and whether it's already cached, shown on mouseover. No external dependencies (no
  HandyNotes or Cartographer needed).
- **Minimap button** that can be toggled from the options.
- **Titan Panel compatible**, and with any other bar that shows LibDataBroker feeds: the addon
  publishes an LDB feed, and the LDB bridge bundled with Titan Panel turns it into a regular
  plugin, with the usual show icon/text options. It's added and removed from Titan's plugin menu
  like any other.

## Configuration

Everything is configured from `Interface → AddOns → _NPCScan Gold` (or with `/npcscan`):

| Option | What it does |
| --- | --- |
| Cache reminders | Alerts on login about which rares are already cached and can't be scanned. |
| Warn of nearby rares | Live detection: alerts on rares in front of you even if cached. |
| Map markers | Shows or hides spawn points on the world map. |
| Minimap button | Shows or hides the button next to the minimap. |
| Alert sound | Choose the alert sound (supports sounds from `SharedMedia` addons). |
| Unmute | Briefly unmutes game sound for the alert even if you have it muted. |

The `Search` tab keeps the list of watched NPCs, where specific rares can be added or removed.

## About the client cache

`_NPCScan`'s original scanning method detects a rare the moment its name enters the client's
creature cache (`Cache/WDB`). Once a rare is cached, that method can no longer detect it: the
addon removes it from the scan list and shows it in the "already cached" notice on login
(`/npcscan cache` lists those).

No addon can clear that cache, whole or per-creature: you have to delete the `Cache/WDB` folder
with the game closed. To avoid depending on that, there's live detection, which doesn't look at
the cache and still alerts when the rare is right in front of you.

## Origin and design

- **Engine (alerts, cache, overlay, config UI):** `_NPCScan` code with no functional changes,
  only renamed internally (`_NPCScan` → `_NPCScanGold`, its own SavedVariables) so it can run as
  an independent addon without colliding with an original `_NPCScan` install.
- **Rares database:** extracted from `SilverDragon_Data/defaults.lua` (408 creatures, with their
  coordinates). `_NPCScan` only distinguishes by continent, not subzone, so each `SilverDragon`
  zone was mapped to its `_NPCScan` `WorldID` (1 Kalimdor, 2 Eastern Kingdoms, 3 Outland,
  4 Northrend; dungeons are identified by instance name). See `_NPCScanGold.RaresDB.lua`.
- The 5 rares `_NPCScan` already shipped with (tied to achievements) are kept as-is; the
  imported database only fills in the rest.
- **Map markers:** points are grouped by map file (`GetMapInfo()`), which is the same across all
  locales. The mapping between the database's English zone name and the map file is built on
  login, translating with `LibBabble-Zone-3.0` and walking the client's own maps, so it works in
  any locale.
- **Titan Panel:** no native Titan plugin is registered; an LibDataBroker object is published,
  and the `LDBToTitan.lua` bridge bundled with Titan Panel turns it into a plugin. The same
  object feeds the minimap button through `LibDBIcon-1.0`, so there's a single data source for
  both.
- Code is 100% compatible with the 3.3.5a API: no function newer than 3.3.5 is used (maps use
  `SetMapZoom`/`GetMapInfo`, markers anchored to `WorldMapButton`, no `C_Map` or `C_Timer`).

## Installation

Copy this repository (the folder containing `_NPCScanGold.toc`) into
`World of Warcraft/Interface/AddOns/`, so it ends up as
`Interface/AddOns/_NPCScanGold/_NPCScanGold.toc`. The folder name has to match the `.toc` name
exactly.

## Credits

- **Saiket** — original `_NPCScan`.
- **Kemayo** — SilverDragon and its rares database.
- **warcrafted-server** — merged both addons into _NPCScanGold.
- Embedded libraries: LibStub, CallbackHandler-1.0, AceEvent-3.0, LibSharedMedia-3.0,
  LibTextTable-1.0, LibDataBroker-1.1, LibDBIcon-1.0 and LibBabble-Zone-3.0.
