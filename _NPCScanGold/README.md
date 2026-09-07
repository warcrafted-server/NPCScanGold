# _NPCScanGold

Addon para World of Warcraft: Wrath of the Lich King (3.3.5a, client build 12340) que fusiona
**[_NPCScan](http://sites.google.com/site/wowsaiket/Add-Ons/NPCScan)** (Saiket) con la base de
datos de raros de **[SilverDragon](https://www.curseforge.com/wow/addons/silver-dragon)** (Kemayo).

Mantiene el motor original de `_NPCScan` (avisos visuales y sonoros, memoria caché de mobs ya
encontrados, integración con addons de overlay de mapa) y le inyecta los ~400 IDs de criaturas
raras que `SilverDragon` cubre en todo WotLK (Kalimdor, Reinos del Este, Outland y Northrend), de
forma que `_NPCScan` también las vigila sin tener que añadirlas a mano una por una.

## Origen y diseño

- **Motor (avisos, caché, overlay, UI de configuración):** código de `_NPCScan` sin cambios
  funcionales, solo renombrado internamente (`_NPCScan` → `_NPCScanGold`, SavedVariables propias)
  para que pueda funcionar como addon independiente sin colisionar con una instalación de
  `_NPCScan` original.
- **Base de datos de raros:** extraída de `SilverDragon_Data/defaults.lua` (408 criaturas).
  `_NPCScan` solo distingue por continente, no por subzona, así que cada zona de `SilverDragon` se
  ha mapeado a su `WorldID` de `_NPCScan` (1 Kalimdor, 2 Reinos del Este, 3 Outland, 4 Northrend;
  las mazmorras se identifican por el nombre de la instancia). Ver `_NPCScanGold.RaresDB.lua`.
- Los 5 raros que `_NPCScan` ya traía de serie (ligados a logros) se respetan tal cual; la base de
  datos importada solo rellena el resto.
- Código 100% compatible con la API de la 3.3.5a: no se ha añadido ninguna llamada nueva a la API,
  solo tablas de datos estáticas y un bucle de fusión en Lua puro.

## Instalación

Copia la carpeta `_NPCScanGold` de este repositorio (la que contiene `_NPCScanGold.toc`) dentro de
`World of Warcraft/Interface/AddOns/`, de forma que quede como
`Interface/AddOns/_NPCScanGold/_NPCScanGold.toc`. El nombre de la carpeta tiene que coincidir
exactamente con el del `.toc`; si copias el repositorio entero (renombrado `NPCScanGold` al
clonarlo) el addon no aparecerá en el juego.

## Créditos

- **Saiket** — _NPCScan original.
- **Kemayo** — SilverDragon y su base de datos de raros.
