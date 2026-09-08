# _NPCScanGold

*[English version](README.md)*

Addon para World of Warcraft: Wrath of the Lich King (3.3.5a, client build 12340) que fusiona
**[_NPCScan](http://sites.google.com/site/wowsaiket/Add-Ons/NPCScan)** (Saiket) con la base de
datos de raros de **[SilverDragon](https://www.curseforge.com/wow/addons/silver-dragon)** (Kemayo).

Mantiene el motor original de `_NPCScan` (avisos visuales y sonoros, memoria caché de mobs ya
encontrados, integración con addons de overlay de mapa) y le inyecta los ~400 IDs de criaturas
raras que `SilverDragon` cubre en todo WotLK (Kalimdor, Reinos del Este, Outland y Northrend), de
forma que `_NPCScan` también las vigila sin tener que añadirlas a mano una por una.

## Características

- **Doble detección.** El motor de `_NPCScan` avisa en cuanto el nombre de la criatura entra en la
  caché del cliente, que da mucho alcance pero solo funciona una vez por caché. En paralelo, una
  detección en vivo al estilo SilverDragon vigila tu objetivo, el ratón por encima, los objetivos
  del grupo y los nameplates, y esa sí avisa de raros ya cacheados. Cada una se activa por
  separado.
- **Base de datos completa:** 408 raros de todo WotLK activos desde el primer momento. La detección
  en vivo además avisa de cualquier mob con clasificación de raro, esté o no en la lista.
- **Marcadores en el mapa del mundo:** los puntos de aparición conocidos de cada raro, con nombre,
  nivel, tipo, si es domesticable y si ya está en caché al pasar el ratón por encima. Sin
  dependencias externas (no hace falta HandyNotes ni Cartographer).
- **Botón de minimapa** activable o desactivable desde las opciones.
- **Compatible con Titan Panel** y con cualquier otra barra que muestre fuentes LibDataBroker: el
  addon publica un feed LDB, y el puente LDB que trae Titan Panel lo convierte en un plugin más, con
  sus opciones habituales de mostrar icono y/o texto. Se añade y se quita desde el menú de plugins
  de Titan como cualquier otro.

## Configuración

Todo se configura desde `Interfaz → Accesorios → _NPCScan Gold` (o con `/npcscan`):

| Opción | Qué hace |
| --- | --- |
| Recordatorios de caché | Avisa al entrar de qué raros ya están en caché y no se pueden escanear. |
| Avisar de raros cercanos | Detección en vivo: avisa de raros que tengas delante aunque estén cacheados. |
| Marcadores en el mapa | Muestra u oculta los puntos de aparición en el mapa del mundo. |
| Botón de minimapa | Muestra u oculta el botón junto al minimapa. |
| Sonido de aviso | Elige el sonido de alerta (admite sonidos de addons `SharedMedia`). |
| Silencio | Activa el sonido del juego brevemente para el aviso aunque lo tengas silenciado. |

La pestaña `Búsqueda` mantiene la lista de NPCs vigilados, donde se pueden añadir o quitar raros
concretos.

## Sobre la caché del cliente

El escaneo original de `_NPCScan` detecta a un raro en el momento en que su nombre entra en la
caché de criaturas del cliente (`Cache/WDB`). Una vez que un raro está cacheado, ese método ya no
puede volver a detectarlo: el addon lo saca de la lista de escaneo y lo enseña en el aviso de
"ya en caché" al conectarte (`/npcscan cache` lista los que están así).

Ningún addon puede vaciar esa caché, ni entera ni por criatura: hay que borrar la carpeta
`Cache/WDB` con el juego cerrado. Para no depender de eso está la detección en vivo, que no mira la
caché y avisa igualmente cuando el raro está delante de ti.

## Origen y diseño

- **Motor (avisos, caché, overlay, UI de configuración):** código de `_NPCScan` sin cambios
  funcionales, solo renombrado internamente (`_NPCScan` → `_NPCScanGold`, SavedVariables propias)
  para que pueda funcionar como addon independiente sin colisionar con una instalación de
  `_NPCScan` original.
- **Base de datos de raros:** extraída de `SilverDragon_Data/defaults.lua` (408 criaturas, con sus
  coordenadas). `_NPCScan` solo distingue por continente, no por subzona, así que cada zona de
  `SilverDragon` se ha mapeado a su `WorldID` de `_NPCScan` (1 Kalimdor, 2 Reinos del Este,
  3 Outland, 4 Northrend; las mazmorras se identifican por el nombre de la instancia).
  Ver `_NPCScanGold.RaresDB.lua`.
- Los 5 raros que `_NPCScan` ya traía de serie (ligados a logros) se respetan tal cual; la base de
  datos importada solo rellena el resto.
- **Marcadores del mapa:** los puntos se agrupan por fichero de mapa (`GetMapInfo()`), que es igual
  en todos los idiomas. La correspondencia entre el nombre de zona en inglés de la base de datos y
  el fichero de mapa se construye al entrar, traduciendo con `LibBabble-Zone-3.0` y recorriendo los
  mapas del propio cliente, así que funciona en cualquier localización.
- **Titan Panel:** no se registra un plugin nativo de Titan; se publica un objeto LibDataBroker y es
  el puente `LDBToTitan.lua` que incluye Titan Panel el que lo convierte en plugin. El mismo objeto
  alimenta el botón de minimapa a través de `LibDBIcon-1.0`, de modo que hay una sola fuente de
  datos para las dos cosas.
- Código 100% compatible con la API de la 3.3.5a: no se usa ninguna función posterior a la 3.3.5
  (mapas con `SetMapZoom`/`GetMapInfo`, marcadores anclados a `WorldMapButton`, sin `C_Map` ni
  `C_Timer`).

## Instalación

Copia este repositorio (la carpeta que contiene `_NPCScanGold.toc`) dentro de
`World of Warcraft/Interface/AddOns/`, de forma que quede como
`Interface/AddOns/_NPCScanGold/_NPCScanGold.toc`. El nombre de la carpeta tiene que coincidir
exactamente con el del `.toc`.

## Créditos

- **Saiket** — _NPCScan original.
- **Kemayo** — SilverDragon y su base de datos de raros.
- Bibliotecas embebidas: LibStub, CallbackHandler-1.0, AceEvent-3.0, LibSharedMedia-3.0,
  LibTextTable-1.0, LibDataBroker-1.1, LibDBIcon-1.0 y LibBabble-Zone-3.0.
