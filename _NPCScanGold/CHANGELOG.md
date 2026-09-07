# Changelog

Todos los cambios relevantes de este proyecto se documentan en este archivo.
El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).

## [1.1.0] - 2026-09-07

### Añadido
- Marcadores en el mapa del mundo con los puntos de aparición conocidos de cada raro, con nombre,
  nivel, tipo, aviso de domesticable y aviso de si ya está en caché (`_NPCScanGold.Map.lua`). No
  necesita HandyNotes ni Cartographer.
- Feed de LibDataBroker (`_NPCScanGold.Broker.lua`): Titan Panel lo recoge como plugin a través de
  su propio puente LDB, con sus opciones de icono y texto, y el mismo objeto alimenta el botón de
  minimapa vía `LibDBIcon-1.0`. Al pasar el ratón lista los raros de la zona actual y cuáles están
  en caché.
- Opciones para mostrar u ocultar los marcadores del mapa y el botón de minimapa, en el panel de
  configuración del addon.

### Cambiado
- La base de datos de raros incluye ahora las coordenadas, el nivel, el tipo de criatura y la marca
  de élite de cada raro, no solo el ID y el continente.

## [1.0.0] - 2026-09-07

### Añadido
- Primera versión: fusión de `_NPCScan` 3.3.5.4 (motor de avisos, caché y overlay) con la base de
  datos de raros de `SilverDragon` (408 criaturas, mapeadas al `WorldID` de continente que ya usa
  `_NPCScan`), en `_NPCScanGold.RaresDB.lua`.
