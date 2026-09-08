# Changelog

Todos los cambios relevantes de este proyecto se documentan en este archivo.
El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).

## [1.2.0] - 2026-09-07

### Añadido
- Detección en vivo al estilo SilverDragon (`_NPCScanGold.Live.lua`): vigila tu objetivo, el ratón
  por encima, los objetivos de tu grupo y los nameplates cercanos, y avisa de cualquier mob de
  clasificación raro o raro élite. No depende de la caché del cliente, así que también avisa de
  raros que ya estaban cacheados y que el escaneo normal de `_NPCScan` no puede detectar. Filtra
  mascotas de cazador (`UnitPlayerControlled`) y mobs muertos.
- Opción para activar o desactivar la detección en vivo, en el panel de configuración.

### Notas
- Los avisos comparten un tiempo de espera de 5 minutos por criatura, venga el aviso del escaneo
  por caché o de la detección en vivo, para no duplicarlos.
- La detección en vivo no se limita a las 408 criaturas de la base de datos: avisa de cualquier mob
  con clasificación de raro, esté o no en la lista.

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
