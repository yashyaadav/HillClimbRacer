//
//  GameManager.swift
//  HillClimbRacer
//
//  Central game manager handling state transitions, spawning, and game flow.
//

import SpriteKit
import Combine

class GameManager: ObservableObject {

    // MARK: - Singleton

    static let shared = GameManager()

    // MARK: - Published Properties

    @Published var gameState = GameState()
    @Published var currentScreen: GameScreen = .mainMenu

    /// Currently selected/playing level
    @Published var currentLevel: Level?

    /// Last level result (for showing completion screen)
    @Published var lastLevelResult: LevelResult?

    // MARK: - Properties

    private weak var scene: GameScene?
    private weak var terrainManager: TerrainManager?

    /// Track last update time for delta calculation
    private var lastUpdateTime: TimeInterval = 0

    /// Spawn tracking
    private var lastCoinSpawnX: CGFloat = 0
    private var lastFuelSpawnX: CGFloat = 0

    /// Spawn intervals
    private let coinSpawnInterval: CGFloat = 150  // Every 150 units
    private let fuelSpawnInterval: CGFloat = 500  // Every 500 units

    /// Level progress storage
    private var levelProgressCache: [String: LevelProgress] = [:]

    // MARK: - Initialization

    private init() {
        loadLevelProgress()
    }

    // MARK: - Configuration

    func configure(scene: GameScene, terrainManager: TerrainManager) {
        self.scene = scene
        self.terrainManager = terrainManager
    }

    // MARK: - Game Flow

    func startGame() {
        gameState.reset()
        currentScreen = .gameplay
        lastUpdateTime = 0
        lastCoinSpawnX = 200
        lastFuelSpawnX = 200

        InputManager.shared.startAccelerometer()
    }

    func pauseGame() {
        gameState.isPaused = true
        scene?.isPaused = true
    }

    func resumeGame() {
        gameState.isPaused = false
        scene?.isPaused = false
    }

    func endGame(reason: GameOverReason) {
        gameState.triggerGameOver(reason: reason)
        InputManager.shared.stopAccelerometer()
        currentScreen = .gameOver
    }

    func restartGame() {
        if let level = currentLevel {
            startLevel(level)
        } else {
            startGame()
        }
    }

    func returnToMenu() {
        InputManager.shared.stopAccelerometer()
        currentLevel = nil
        currentScreen = .mainMenu
    }

    // MARK: - Level System

    /// Start a specific level
    func startLevel(_ level: Level) {
        currentLevel = level
        gameState.reset()
        currentScreen = .gameplay
        lastUpdateTime = 0
        lastCoinSpawnX = 200
        lastFuelSpawnX = 200

        InputManager.shared.startAccelerometer()

        // Increment play count
        var progress = progress(for: level)
        progress.timesPlayed += 1
        levelProgressCache[level.id] = progress
        saveLevelProgress()
    }

    /// Restart the current level
    func restartLevel() {
        if let level = currentLevel {
            startLevel(level)
        }
    }

    /// End a level run and calculate results
    func endLevel(reason: GameOverReason) {
        guard let level = currentLevel else {
            endGame(reason: reason)
            return
        }

        gameState.triggerGameOver(reason: reason)
        InputManager.shared.stopAccelerometer()

        // Calculate results
        let distance = gameState.distance
        let coins = gameState.coins
        let starsEarned = level.starsEarned(for: distance)
        let isLevelComplete = level.isCompleted(distance: distance)

        // Get existing progress
        var progress = progress(for: level)
        let isNewRecord = distance > progress.bestDistance

        // Update progress
        progress.update(distance: distance, stars: starsEarned)
        if isLevelComplete && !progress.isCompleted {
            progress.isCompleted = true

            // Unlock next level
            if let nextLevel = LevelDefinitions.nextLevel(after: level) {
                unlockLevel(nextLevel)
            }
        }
        levelProgressCache[level.id] = progress
        saveLevelProgress()

        // Create result
        lastLevelResult = LevelResult(
            level: level,
            distance: distance,
            coins: coins,
            starsEarned: starsEarned,
            isNewRecord: isNewRecord,
            isLevelComplete: isLevelComplete
        )

        // Award coins
        let totalCoins = coins + (isLevelComplete ? starsEarned * 10 : 0)
        PersistenceManager.shared.addCoins(totalCoins)

        currentScreen = .levelComplete
    }

    /// Get progress for a level
    func progress(for level: Level) -> LevelProgress {
        if let cached = levelProgressCache[level.id] {
            return cached
        }

        // Create new progress
        var progress = LevelProgress(levelId: level.id)
        progress.isUnlocked = level.isFree || level.id == LevelDefinitions.endlessAdventure.id

        levelProgressCache[level.id] = progress
        return progress
    }

    /// Unlock a level
    func unlockLevel(_ level: Level) {
        var progress = progress(for: level)

        if !progress.isUnlocked {
            if level.unlockCost > 0 {
                guard PersistenceManager.shared.spendCoins(level.unlockCost) else { return }
            }
            progress.isUnlocked = true
            levelProgressCache[level.id] = progress
            saveLevelProgress()
        }
    }

    /// Total stars earned across all levels
    var totalStarsEarned: Int {
        LevelDefinitions.storyLevels.reduce(0) { total, level in
            total + progress(for: level).starsEarned
        }
    }

    // MARK: - Level Progress Persistence

    private func loadLevelProgress() {
        levelProgressCache = PersistenceManager.shared.loadLevelProgress()

        // Ensure first level and endless mode are unlocked
        var firstLevelProgress = progress(for: LevelDefinitions.greenStart)
        firstLevelProgress.isUnlocked = true
        levelProgressCache[LevelDefinitions.greenStart.id] = firstLevelProgress

        var endlessProgress = progress(for: LevelDefinitions.endlessAdventure)
        endlessProgress.isUnlocked = true
        levelProgressCache[LevelDefinitions.endlessAdventure.id] = endlessProgress
    }

    private func saveLevelProgress() {
        PersistenceManager.shared.saveLevelProgress(levelProgressCache)
    }

    // MARK: - Update

    func update(currentTime: TimeInterval, playerX: CGFloat, isThrottling: Bool, velocity: CGFloat = 0, velocityY: CGFloat = 0) {
        guard !gameState.isGameOver && !gameState.isPaused else { return }

        // Calculate delta time
        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update distance
        gameState.updateDistance(playerX: playerX)

        // Update speed display
        gameState.updateSpeed(velocityX: velocity, velocityY: velocityY)

        // Consume fuel (velocity-based - faster driving uses more fuel)
        gameState.consumeFuel(deltaTime: deltaTime, isThrottling: isThrottling, velocity: velocity)

        // Check for game over conditions
        if gameState.isFuelEmpty {
            if currentLevel != nil {
                endLevel(reason: .outOfFuel)
            } else {
                endGame(reason: .outOfFuel)
            }
        }

        // Check for level completion
        if let level = currentLevel,
           let target = level.targetDistance,
           gameState.distance >= target {
            // Level completed!
            endLevel(reason: .outOfFuel)  // Using this as a placeholder, could add a "completed" reason
        }

        // Spawn collectibles
        spawnCollectibles(playerX: playerX)
    }

    // MARK: - Collectible Spawning

    private func spawnCollectibles(playerX: CGFloat) {
        guard let scene = scene, let terrainManager = terrainManager else { return }

        // Spawn coins
        while lastCoinSpawnX < playerX + 800 {
            lastCoinSpawnX += coinSpawnInterval

            // Random offset
            let xOffset = CGFloat.random(in: -30...30)
            let x = lastCoinSpawnX + xOffset

            if let y = terrainManager.surfaceY(at: x) {
                let coinY = y + 80 + CGFloat.random(in: 0...40)
                let coin = CoinNode(position: CGPoint(x: x, y: coinY))
                scene.addChild(coin)
            }
        }

        // Spawn fuel cans (less frequently)
        while lastFuelSpawnX < playerX + 800 {
            lastFuelSpawnX += fuelSpawnInterval

            let x = lastFuelSpawnX + CGFloat.random(in: -20...20)

            if let y = terrainManager.surfaceY(at: x) {
                let fuelY = y + 60
                let fuelCan = FuelCanNode(position: CGPoint(x: x, y: fuelY))
                scene.addChild(fuelCan)
            }
        }
    }

    // MARK: - Collectible Handling

    func collectCoin() {
        gameState.addCoins()
    }

    func collectFuel(amount: CGFloat) {
        gameState.addFuel(amount)
    }

    // MARK: - Vehicle State Checking

    func checkVehicleFlipped(rotation: CGFloat) {
        // Check if vehicle is upside down (rotation > 120 degrees)
        let degrees = abs(rotation * 180 / .pi)
        if degrees > 120 {
            endGame(reason: .vehicleFlipped)
        }
    }

    func checkFellOffWorld(y: CGFloat) {
        // Check if vehicle fell below the world
        if y < -200 {
            endGame(reason: .fellOffWorld)
        }
    }
}

// MARK: - Game Screen

enum GameScreen {
    case mainMenu
    case gameplay
    case paused
    case gameOver
    case garage
    case settings
    case levelSelect
    case levelComplete
}
