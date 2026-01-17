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

    // MARK: - Initialization

    private init() {}

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
        startGame()
    }

    func returnToMenu() {
        InputManager.shared.stopAccelerometer()
        currentScreen = .mainMenu
    }

    // MARK: - Update

    func update(currentTime: TimeInterval, playerX: CGFloat, isThrottling: Bool, velocity: CGFloat = 0) {
        guard !gameState.isGameOver && !gameState.isPaused else { return }

        // Calculate delta time
        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update distance
        gameState.updateDistance(playerX: playerX)

        // Consume fuel (velocity-based - faster driving uses more fuel)
        gameState.consumeFuel(deltaTime: deltaTime, isThrottling: isThrottling, velocity: velocity)

        // Check for game over conditions
        if gameState.isFuelEmpty {
            endGame(reason: .outOfFuel)
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
}
