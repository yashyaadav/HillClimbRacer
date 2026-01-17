# Hill Climb Racer

[![iOS Build & Test](https://github.com/yashyaadav/HillClimbRacer/actions/workflows/ios-build.yml/badge.svg)](https://github.com/yashyaadav/HillClimbRacer/actions/workflows/ios-build.yml)

A 2D physics-based racing game for iOS, inspired by Hill Climb Racing. Built with SpriteKit and SwiftUI.

## Features

### Gameplay
- **Physics-based driving** - Realistic vehicle physics with suspension, torque-based movement, and air control
- **Procedural terrain** - Infinite hills generated using Perlin noise with difficulty scaling
- **Fuel system** - Velocity-based fuel consumption (faster = more fuel used)
- **Collectibles** - Coins and fuel cans with float+fade animations

### Biome System
Four unique biomes with distinct visuals and terrain characteristics:
| Biome | Description | Weather |
|-------|-------------|---------|
| **Grassland** | Gentle hills, perfect for beginners | Clear |
| **Desert Dunes** | Sandy waves with flatter terrain | Sandstorm |
| **Frozen Peaks** | Steep icy mountains | Snow |
| **Deep Forest** | Dark, treacherous woods | Rain |

### Level Progression
- **4 Story Levels** - Green Start, Desert Dunes, Frozen Peaks, Deep Forest
- **Endless Mode** - Infinite adventure with biome transitions every 5000m
- **Star Rating** - Earn 1-3 stars based on distance traveled
- **Level Unlocks** - Progress through story mode to unlock new challenges

### Vehicles
| Vehicle | Style | Traits |
|---------|-------|--------|
| **Hill Jeep** | All-rounder | Balanced stats, great for beginners |
| **Dirt Bike** | Speed | Fast but unstable, requires skill |
| **Monster Truck** | Power | Heavy and powerful, crushes terrain |

### UI & Audio
- **SwiftUI menus** - Main menu, pause, game over, garage, level select, and settings
- **HUD** - Speedometer, fuel gauge, distance tracker, coin counter
- **Audio system** - Engine sounds, collision effects, and background music

## Requirements

- iOS 26.0+
- Xcode 17.0+
- Swift 5.9+

## Getting Started

1. Clone the repository:
   ```bash
   git clone git@github.com:yashyaadav/HillClimbRacer.git
   ```

2. Open in Xcode:
   ```bash
   cd HillClimbRacer
   open HillClimbRacer.xcodeproj
   ```

3. Select your target device/simulator and run (⌘R)

## Project Structure

```
HillClimbRacer/
├── App/                    # App entry point (SwiftUI)
├── Scenes/                 # SpriteKit game scenes
├── Entities/
│   ├── Vehicle/            # Car, wheels, chassis, suspension
│   ├── Terrain/            # Procedural terrain generation & chunks
│   └── Collectibles/       # Coins, fuel cans
├── Managers/
│   ├── GameManager         # Game state & flow
│   ├── AudioManager        # Sound effects & music
│   ├── InputManager        # Touch & accelerometer
│   ├── PersistenceManager  # Save data (UserDefaults)
│   └── GameCenterManager   # Leaderboards & achievements
├── Models/
│   ├── GameState           # Current game state
│   ├── Biome               # Biome configuration
│   ├── Level               # Level definitions
│   └── VehicleConfig       # Vehicle stats & properties
├── Views/                  # SwiftUI UI screens
├── Resources/
│   ├── Audio/              # Sound effects & music
│   └── Assets.xcassets/    # Images & colors
└── Utilities/
    ├── Constants           # Game configuration values
    └── PerlinNoise         # Terrain noise generation
```

## Controls

- **Right side of screen** - Gas (accelerate)
- **Left side of screen** - Brake
- **Tilt device** - Balance vehicle in air

## Testing

The project includes comprehensive unit tests:

```bash
# Run tests via Xcode
⌘U

# Or via command line
xcodebuild test -project HillClimbRacer.xcodeproj -scheme HillClimbRacer -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Test coverage includes:
- `TerrainGeneratorTests` - Procedural terrain generation
- `VehicleConfigTests` - Vehicle configuration validation
- `BiomeTests` - Biome definitions and transitions
- `LevelTests` - Level progression logic
- `GameStateTests` - Game state management
- `PersistenceManagerTests` - Save/load functionality
- `InputManagerTests` - Input handling
- `ConstantsTests` - Configuration constants

## CI/CD

GitHub Actions automatically builds and tests on every push to `main` and `develop` branches:
- Runs on macOS 15 with Xcode 17
- Tests on iPhone 17 Pro simulator with iOS 26
- Uploads test results and coverage reports as artifacts

## License

MIT License

## Acknowledgments

- Inspired by [Hill Climb Racing](https://fingersoft.com/games/hill-climb-racing/) by Fingersoft
- Audio assets from various royalty-free sources
