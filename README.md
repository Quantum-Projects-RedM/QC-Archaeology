# QC-Archaeology

An immersive archaeology system for RedM servers using RSG-Core framework with excavation sites, interactive minigames, and a collectible discovery book.

![Version](https://img.shields.io/badge/version-1.0.1-blue.svg)
![Framework](https://img.shields.io/badge/framework-RSG--Core-green.svg)

## Features

- **30+ Dig Sites**: Excavation locations across the entire map with unique fossils and artifacts
- **Interactive Minigame**: Skill-based excavation minigame for uncovering artifacts
- **Archaeology Book**: 30-page collectible book that fills as you discover new sites
- **Advanced Sites**: Special large-scale excavations (Mammoth, Whale fossils)
- **Dynamic Spawning**: Hourly cron job activates random dig sites
- **Reward System**: Common and rare items with configurable chance rates (5-97%)

## Dependencies

- [rsg-core](https://github.com/Rexshack-RedM/rsg-core)
- [ox_lib](https://github.com/overextended/ox_lib)
- [oxmysql](https://github.com/overextended/oxmysql)

## Installation

1. Extract to your resources folder
2. Execute `INSTALLATION/QC_Archaeology.sql` in your database
3. Add items from `INSTALLATION/items.txt` to `rsg-core/shared/items.lua`
4. Add images from `INSTALLATION/IMAGES/` to your inventory script
5. Configure `config.lua` as needed
6. Add `ensure QC-Archaeology` to server.cfg

**Important**: Dig sites spawn on an hourly schedule. First sites will appear after the cron job runs.

## Quick Start

1. Visit an Archaeology Hub (2 locations on the map)
2. Purchase an archaeology brush and book
3. Wait for dig sites to spawn (hourly at :00)
4. Travel to active dig sites and use your brush
5. Complete the minigame to excavate artifacts
6. Collect fossils and fill your archaeology book

## Configuration

Key settings in `config.lua`:
```lua
Config.arcsiteCronJob = '0 * * * *'     -- Hourly site spawns
Config.RareItemChance = 5               -- 5% chance for rare finds
Config.ArchaeologyBrush = 'archeology_brush'  -- Required tool
Config.arcsiteTime = 1500               -- Dig duration (ms)
```

## Support

**Discord**: [Quantum Projects](https://discord.gg/kJ8ZrGM8TS)
**Developer**: Artmines

---

**Version**: 1.0.1 | **Framework**: RSG-Core
