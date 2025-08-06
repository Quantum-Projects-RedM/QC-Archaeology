# QC-Archaeology

RedM archaeology script with interactive book system and minigame mechanics.

## Features

- Archaeological site discovery with minigame
- Interactive book with page turning animations and sound
- React-based NUI system
- Persistent data storage with RSGCore

## Technical Stack

- **Backend**: CfxLua for RedM
- **Frontend**: React 18 with Webpack 5
- **UI**: Turn.js for book animations

## Installation

1. Download and extract to your resources folder
2. Install items to inventory and import SQL (see INSTALLATION folder)
3. Add `ensure QC-Archaeology` to server.cfg
4. Build NUI assets:
   ```bash
   cd html
   npm install
   npm run build
   ```
5. Restart server

## Dependencies

- RSGCore Framework
- MySQL database
- Node.js (for building NUI)
