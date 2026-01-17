# Hill Climb Racer: Implementation Guide

This document outlines the implementation completed based on the development plan, what steps require manual user action, and how to test the various features.

---

## Summary of Implemented Features

### 1. Multiple Vehicle System
**Files Created:**
- `HillClimbRacer/Models/VehicleConfig.swift` - Data model for vehicle configurations
- `HillClimbRacer/Models/VehicleDefinitions.swift` - Three predefined vehicles

**Vehicles Implemented:**
| Vehicle | Description | Unlock Cost |
|---------|-------------|-------------|
| Hill Jeep | Balanced all-rounder (default) | Free |
| Dirt Bike | Fast but unstable | 500 coins |
| Monster Truck | Heavy and powerful | 1000 coins |

**Files Modified:**
- `Vehicle.swift` - Now accepts `VehicleConfig` for customization
- `PersistenceManager.swift` - Vehicle selection, unlocks, per-vehicle upgrades

### 2. Working Upgrade System
**Files Modified:**
- `Constants.swift` - Added upgrade constants and multipliers
- `GarageView.swift` - Complete rewrite with vehicle carousel and working upgrades
- `PersistenceManager.swift` - Per-vehicle upgrade tracking

**Upgrade Categories:**
- Engine (power + speed)
- Fuel Tank (capacity + efficiency)
- Tires (grip)
- Suspension (stiffness + damping)

### 3. Game Center Integration
**Files Created:**
- `HillClimbRacer/Managers/GameCenterManager.swift` - Complete Game Center manager

**Leaderboard IDs (to configure in App Store Connect):**
- `best_distance_jeep`
- `best_distance_motorcycle`
- `best_distance_monster`
- `best_distance_overall`
- `total_coins_collected`

### 4. Settings Screen
**Files Created:**
- `HillClimbRacer/Views/SettingsView.swift` - Complete settings UI

**Features:**
- Sound effects toggle
- Music toggle
- Game Center status/sign-in
- Statistics display
- Reset progress (with confirmation)

### 5. Audio System Improvements
**Files Modified:**
- `AudioManager.swift` - Actual audio loading implementation with graceful fallback

### 6. Updated UI
**Files Modified:**
- `MainMenuView.swift` - Settings and Leaderboards buttons, vehicle indicator
- `ContentView.swift` - Settings screen routing, Game Center presentation

### 7. CI/CD Improvements
**Files Modified:**
- `.github/workflows/ios-build.yml` - Updated to macOS 15/Xcode 16, removed `|| true`, added code coverage

### 8. Test Infrastructure
**Files Created:**
- `HillClimbRacerTests/GameStateTests.swift`
- `HillClimbRacerTests/VehicleConfigTests.swift`
- `HillClimbRacerTests/PersistenceManagerTests.swift`
- `HillClimbRacerTests/ConstantsTests.swift`

---

## Manual Steps Required by User

### Phase 1: Audio Files (Required for Audio to Work)

The audio system is implemented but requires actual audio files. Create the following directory and add audio files:

```
HillClimbRacer/Resources/Audio/
```

**Required Sound Effects (.wav format):**
| File | Description |
|------|-------------|
| `engine_idle.wav` | Engine idle loop |
| `engine_rev.wav` | Engine rev (speed-dependent) |
| `coin_collect.wav` | Coin pickup sound |
| `fuel_collect.wav` | Fuel can pickup |
| `crash.wav` | Crash/collision |
| `jump.wav` | Airborne sound |
| `land.wav` | Landing impact |
| `game_over.wav` | Game over jingle |
| `button_tap.wav` | UI button feedback |
| `upgrade.wav` | Upgrade success |

**Required Music (.mp3 format):**
| File | Description |
|------|-------------|
| `menu_music.mp3` | Main menu background |
| `gameplay_music.mp3` | In-game music |

**Recommended Sources (royalty-free):**
- [Freesound.org](https://freesound.org) - CC0 licensed sounds
- [OpenGameArt.org](https://opengameart.org) - Game-specific assets
- [Incompetech](https://incompetech.com) - Kevin MacLeod music

**After adding files:**
1. Open Xcode project
2. Right-click on Resources folder > Add Files to "HillClimbRacer"
3. Select your Audio folder
4. Ensure "Copy items if needed" is checked
5. Ensure target membership includes HillClimbRacer

### Phase 2: Game Center Setup (Required for Leaderboards)

1. **Enable Game Center Capability in Xcode:**
   - Open project in Xcode
   - Select HillClimbRacer target
   - Go to "Signing & Capabilities"
   - Click "+ Capability"
   - Add "Game Center"

2. **Configure in App Store Connect:**
   - Log in to [App Store Connect](https://appstoreconnect.apple.com)
   - Create app record (if not exists)
   - Go to Features > Game Center
   - Add Leaderboards:
     - ID: `best_distance_jeep`, Name: "Best Distance (Jeep)"
     - ID: `best_distance_motorcycle`, Name: "Best Distance (Dirt Bike)"
     - ID: `best_distance_monster`, Name: "Best Distance (Monster Truck)"
     - ID: `best_distance_overall`, Name: "Best Distance (Any Vehicle)"
     - ID: `total_coins_collected`, Name: "Total Coins Collected"
   - Score Format: Integer (ascending, higher is better)

### Phase 3: Xcode Project Configuration

1. **Add new files to Xcode project:**
   The following files were created and need to be added to the Xcode project:
   - `Models/VehicleConfig.swift`
   - `Models/VehicleDefinitions.swift`
   - `Managers/GameCenterManager.swift`
   - `Views/SettingsView.swift`

   In Xcode: File > Add Files to "HillClimbRacer"...

2. **Add test files to test target:**
   - `HillClimbRacerTests/GameStateTests.swift`
   - `HillClimbRacerTests/VehicleConfigTests.swift`
   - `HillClimbRacerTests/PersistenceManagerTests.swift`
   - `HillClimbRacerTests/ConstantsTests.swift`

---

## Testing Guide

### Running Unit Tests

```bash
# From terminal
cd /Users/asy/dev/games/HillClimbRacer
xcodebuild test \
  -project HillClimbRacer.xcodeproj \
  -scheme HillClimbRacer \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -configuration Debug
```

Or in Xcode: Product > Test (Cmd+U)

### Manual Testing Checklist

#### Main Menu
- [ ] Title displays correctly
- [ ] Selected vehicle name appears below title
- [ ] PLAY button starts gameplay
- [ ] GARAGE button opens garage
- [ ] SETTINGS button opens settings
- [ ] RANKS button shows leaderboards (if authenticated) or prompts sign-in
- [ ] Best distance displays if > 0
- [ ] Total coins display
- [ ] Game Center status indicator shows correct state

#### Garage
- [ ] Back button returns to menu
- [ ] Coins display in header
- [ ] Vehicle carousel allows switching between 3 vehicles
- [ ] Locked vehicles show lock icon and cost
- [ ] Unlocked vehicles show stats and SELECT button
- [ ] Selected vehicle shows "SELECTED" label
- [ ] UNLOCK button works when sufficient coins
- [ ] UNLOCK shows alert when insufficient coins
- [ ] Upgrade tabs show current level indicators
- [ ] Upgrade button deducts coins and increases level
- [ ] MAX LEVEL shown when fully upgraded
- [ ] Upgrades are per-vehicle (switch vehicle and check)

#### Settings
- [ ] Back button returns to menu
- [ ] Sound toggle works
- [ ] Music toggle works (and starts/stops music)
- [ ] Game Center status shows connected/offline
- [ ] Sign In button appears when offline
- [ ] View Leaderboards button works when connected
- [ ] Statistics show correct values
- [ ] Reset Progress shows confirmation
- [ ] Reset Progress actually resets data

#### Gameplay
- [ ] Selected vehicle loads with correct appearance
- [ ] Upgraded vehicle has improved stats (compare level 1 vs 5)
- [ ] Fuel gauge shows correctly
- [ ] Coins counter increments on collection
- [ ] Distance counter increments while moving
- [ ] Pause button pauses game
- [ ] Game over triggers correctly (fuel empty, flipped, fell)
- [ ] Audio plays (if files added)

#### Game Over
- [ ] Shows reason for game over
- [ ] Shows final distance and coins
- [ ] Shows "NEW BEST" if applicable
- [ ] Retry restarts game
- [ ] Menu returns to main menu
- [ ] Score submitted to Game Center (if connected)

---

## File Structure After Implementation

```
HillClimbRacer/
├── App/
│   ├── HillClimbRacerApp.swift
│   └── ContentView.swift (updated)
├── Scenes/
│   └── GameScene.swift
├── Entities/
│   ├── Vehicle/
│   │   ├── Vehicle.swift (updated)
│   │   ├── ChassisNode.swift
│   │   ├── WheelNode.swift
│   │   └── WheelSuspension.swift
│   ├── Collectibles/
│   └── Terrain/
├── Managers/
│   ├── GameManager.swift (updated)
│   ├── AudioManager.swift (updated)
│   ├── InputManager.swift
│   ├── PersistenceManager.swift (updated)
│   └── GameCenterManager.swift (new)
├── Models/
│   ├── GameState.swift
│   ├── VehicleConfig.swift (new)
│   └── VehicleDefinitions.swift (new)
├── Views/
│   ├── MainMenuView.swift (updated)
│   ├── GarageView.swift (updated)
│   ├── GameOverView.swift
│   ├── PauseMenuView.swift
│   ├── SettingsView.swift (new)
│   └── HUDView.swift
├── Utilities/
│   ├── Constants.swift (updated)
│   └── PerlinNoise.swift
└── Resources/
    └── Audio/ (to be created by user)
        ├── engine_idle.wav
        ├── coin_collect.wav
        └── ...

HillClimbRacerTests/
├── GameStateTests.swift (new)
├── VehicleConfigTests.swift (new)
├── PersistenceManagerTests.swift (new)
└── ConstantsTests.swift (new)

.github/workflows/
└── ios-build.yml (updated)
```

---

## Known Limitations

1. **Audio Files Not Included** - You must source and add your own audio files
2. **Game Center Requires Apple Developer Account** - Leaderboards need App Store Connect setup
3. **TestFlight** - Requires Apple Developer Program membership ($99/year)

---

## Next Steps (Post-Implementation)

1. Source and add audio files
2. Enable Game Center capability
3. Configure leaderboards in App Store Connect
4. Add new files to Xcode project
5. Run tests to verify everything works
6. Test on physical device
7. Begin TestFlight beta testing

---

## Troubleshooting

### Build Errors After Adding Files

If you see "Use of unresolved identifier" errors:
1. Ensure files are added to correct target
2. Check file membership in File Inspector (right panel)
3. Clean build folder: Product > Clean Build Folder (Cmd+Shift+K)

### Game Center Not Working

1. Verify capability is enabled in Xcode
2. Check you're signed into Game Center on device/simulator
3. Leaderboards require App Store Connect configuration
4. Test accounts work better than production for development

### Audio Not Playing

1. Verify files are in correct location
2. Check file names match exactly (case-sensitive)
3. Verify files are added to bundle (check Build Phases > Copy Bundle Resources)
4. Check console for error messages

---

## Support

If you encounter issues:
1. Check the console log for error messages
2. Verify all files are added to Xcode project
3. Run unit tests to validate core functionality
4. Clean and rebuild project
