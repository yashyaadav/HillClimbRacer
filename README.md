# Hill Climb Racer

A 2D physics-based racing game for iOS, inspired by Hill Climb Racing. Built with SpriteKit and SwiftUI.

## Features

- **Physics-based gameplay** - Realistic vehicle physics with suspension, torque-based movement
- **Procedural terrain** - Infinite hills generated using Perlin noise
- **Fuel system** - Velocity-based fuel consumption (faster = more fuel used)
- **Collectibles** - Coins and fuel cans with float+fade animations
- **Audio system** - Engine sounds, collision effects, and background music
- **SwiftUI menus** - Main menu, pause, game over, garage, and settings screens

## Screenshots

*Coming soon*

## Requirements

- iOS 16.0+
- Xcode 15.0+
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
├── App/                    # App entry point
├── Scenes/                 # SpriteKit game scenes
├── Entities/
│   ├── Vehicle/            # Car, wheels, suspension
│   ├── Terrain/            # Procedural terrain generation
│   └── Collectibles/       # Coins, fuel cans
├── Managers/
│   ├── GameManager         # Game state & flow
│   ├── AudioManager        # Sound effects & music
│   ├── InputManager        # Touch & accelerometer
│   └── PersistenceManager  # Save data
├── Views/                  # SwiftUI UI screens
├── Models/                 # Data models
├── Resources/
│   ├── Audio/              # Sound effects & music
│   └── Assets.xcassets/    # Images & colors
└── Utilities/              # Constants, helpers
```

## Controls

- **Right side of screen** - Gas (accelerate)
- **Left side of screen** - Brake
- **Tilt device** - Balance vehicle in air

## Audio

The game includes 12 audio files:
- Engine idle/rev sounds
- Coin and fuel pickup effects
- Crash, jump, and landing sounds
- Menu and gameplay background music

## License

MIT License

## Acknowledgments

- Inspired by [Hill Climb Racing](https://fingersoft.com/games/hill-climb-racing/) by Fingersoft
- Audio assets from various royalty-free sources
