# Hill Climb Racer - Claude Code Guidelines

## Project Overview
A 2D physics-based driving game for iOS inspired by Hill Climb Racing, built with SpriteKit + Swift.

## Tech Stack
- **Language**: Swift 5.9+
- **Framework**: SpriteKit (physics, rendering)
- **UI**: SwiftUI (menus, HUD overlay)
- **Target**: iOS 17+
- **IDE**: Xcode 15+

## Project Structure

```
HillClimbRacer/
├── App/                    # App entry point and main views
├── Scenes/                 # SpriteKit scenes (GameScene, MenuScene, etc.)
├── Entities/
│   ├── Vehicle/            # Vehicle, chassis, wheels, suspension
│   ├── Collectibles/       # Coins, fuel cans
│   └── Terrain/            # Terrain generation and management
├── Components/             # Reusable components (physics, camera)
├── Managers/               # Game state, audio, input, persistence
├── Models/                 # Data models (GameState, VehicleConfig)
├── Views/                  # SwiftUI views (HUD, menus)
├── Extensions/             # Swift extensions
├── Utilities/              # Constants, helpers (PerlinNoise)
└── Resources/              # Assets, sounds, particles
```

## Key Concepts

### Physics System
- Uses SpriteKit's built-in physics (Box2D-based)
- Three-joint suspension: Sliding (vertical constraint) + Spring (elasticity) + Pin (wheel attachment)
- Impulse-based movement (not direct velocity manipulation)
- Physics categories use bitmasks for collision filtering

### Terrain Generation
- Procedural using layered sine waves + Perlin noise
- Chunk-based streaming for performance
- Edge chain physics bodies for terrain collision

### Controls
- Left screen half: Brake
- Right screen half: Gas/Throttle
- Accelerometer: Mid-air tilt control

## Coding Standards

### Naming Conventions
- Classes/Structs: PascalCase (e.g., `TerrainChunk`, `GameScene`)
- Functions/Properties: camelCase (e.g., `moveForward()`, `currentFuel`)
- Constants: camelCase with `static let` (e.g., `static let maxSpeed: CGFloat = 750`)
- Physics categories: Use struct with static properties

### Physics Categories
```swift
struct PhysicsCategory {
    static let none:    UInt32 = 0
    static let chassis: UInt32 = 0b1
    static let wheel:   UInt32 = 0b10
    static let terrain: UInt32 = 0b100
    static let coin:    UInt32 = 0b1000
    static let fuelCan: UInt32 = 0b10000
}
```

### File Organization
- One primary type per file
- Related extensions can be in the same file
- Group related functionality with `// MARK: -` comments

## Build & Run

```bash
# Build for iOS Simulator
xcodebuild build \
  -project HillClimbRacer.xcodeproj \
  -scheme HillClimbRacer \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.2'

# Run tests
xcodebuild test \
  -project HillClimbRacer.xcodeproj \
  -scheme HillClimbRacer \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.2'
```

## Reference Implementation
Local reference: `/Users/asy/dev/games/physics-vehicle/`
- `WheelSuspension.swift` - Three-joint suspension system
- `Vehicle.swift` - Impulse-based movement
- `JeepWheelSuspensionBuilder.swift` - Starter parameter values

## Physics Parameters (Starting Values)

| Component | Parameter | Value |
|-----------|-----------|-------|
| Chassis | density | 2.0 |
| Wheel | friction | 0.9 |
| Wheel | restitution | 0.3 |
| Spring | frequency | 4.5 Hz |
| Spring | damping | 0.5 |
| Slide | lowerLimit | 0.1 |
| Slide | upperLimit | 65.0 |
| Engine | forwardPower | 35 |
| Engine | maxForwardSpeed | 750 |
| Engine | maxBackwardSpeed | -450 |
