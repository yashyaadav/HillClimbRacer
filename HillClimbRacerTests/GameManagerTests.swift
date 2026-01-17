//
//  GameManagerTests.swift
//  HillClimbRacerTests
//
//  Unit tests for GameManager coin persistence and game flow.
//

import XCTest
@testable import HillClimbRacer

final class GameManagerTests: XCTestCase {

    var gameManager: GameManager!
    var initialTotalCoins: Int!

    override func setUpWithError() throws {
        gameManager = GameManager.shared
        // Store initial coin count to restore later
        initialTotalCoins = PersistenceManager.shared.totalCoins
        // Reset to a known state
        PersistenceManager.shared.totalCoins = 0
        PersistenceManager.shared.bestDistance = 0
        gameManager.gameState.reset()
    }

    override func tearDownWithError() throws {
        // Restore original coin count
        PersistenceManager.shared.totalCoins = initialTotalCoins
        gameManager.gameState.reset()
        gameManager = nil
    }

    // MARK: - Coin Persistence Tests

    func testEndGamePersistsCoinsToStorage() {
        // Arrange
        let coinsToCollect = 5
        for _ in 0..<coinsToCollect {
            gameManager.collectCoin()
        }
        let coinsBefore = PersistenceManager.shared.totalCoins

        // Act
        gameManager.endGame(reason: .outOfFuel)

        // Assert
        let coinsAfter = PersistenceManager.shared.totalCoins
        XCTAssertEqual(coinsAfter, coinsBefore + coinsToCollect,
                       "Coins should be added to persistent storage")
    }

    func testEndGamePersistsZeroCoins() {
        // Arrange - ensure no coins collected
        let coinsBefore = PersistenceManager.shared.totalCoins
        XCTAssertEqual(gameManager.gameState.coins, 0, "Should start with 0 coins")

        // Act
        gameManager.endGame(reason: .vehicleFlipped)

        // Assert
        let coinsAfter = PersistenceManager.shared.totalCoins
        XCTAssertEqual(coinsAfter, coinsBefore, "Zero coins should not corrupt storage")
    }

    func testEndGameAccumulatesCoins() {
        // Arrange - play multiple "games"
        for _ in 0..<3 {
            gameManager.collectCoin()
        }
        gameManager.endGame(reason: .outOfFuel)
        let coinsAfterFirstGame = PersistenceManager.shared.totalCoins

        // Reset game state for second game
        gameManager.gameState.reset()

        for _ in 0..<5 {
            gameManager.collectCoin()
        }
        gameManager.endGame(reason: .outOfFuel)

        // Assert
        let coinsAfterSecondGame = PersistenceManager.shared.totalCoins
        XCTAssertEqual(coinsAfterSecondGame, coinsAfterFirstGame + 5,
                       "Coins should accumulate across multiple games")
    }

    // MARK: - Best Distance Tests

    func testEndGameUpdatesBestDistance() {
        // Arrange
        PersistenceManager.shared.bestDistance = 100
        gameManager.gameState.distance = 200

        // Act
        gameManager.endGame(reason: .outOfFuel)

        // Assert
        XCTAssertEqual(PersistenceManager.shared.bestDistance, 200,
                       "Best distance should update when exceeded")
    }

    func testEndGameDoesNotLowerBestDistance() {
        // Arrange
        PersistenceManager.shared.bestDistance = 500
        gameManager.gameState.distance = 100

        // Act
        gameManager.endGame(reason: .outOfFuel)

        // Assert
        XCTAssertEqual(PersistenceManager.shared.bestDistance, 500,
                       "Shorter runs should not overwrite best distance")
    }

    // MARK: - Game State Transition Tests

    func testEndGameSetsGameOverState() {
        // Arrange
        XCTAssertFalse(gameManager.gameState.isGameOver, "Should not be game over initially")

        // Act
        gameManager.endGame(reason: .fellOffWorld)

        // Assert
        XCTAssertTrue(gameManager.gameState.isGameOver, "Game should be over after endGame")
        XCTAssertEqual(gameManager.gameState.gameOverReason, .fellOffWorld,
                       "Game over reason should match")
        XCTAssertEqual(gameManager.currentScreen, .gameOver,
                       "Current screen should be game over")
    }

    func testStartGameResetsState() {
        // Arrange - set up dirty state
        gameManager.gameState.fuel = 25
        gameManager.gameState.coins = 50
        gameManager.gameState.distance = 1000
        gameManager.gameState.triggerGameOver(reason: .outOfFuel)

        // Act
        gameManager.startGame()

        // Assert
        XCTAssertEqual(gameManager.gameState.fuel, Constants.Gameplay.startingFuel,
                       "Fuel should reset to starting value")
        XCTAssertEqual(gameManager.gameState.coins, 0,
                       "Coins should reset to 0")
        XCTAssertEqual(gameManager.gameState.distance, 0,
                       "Distance should reset to 0")
        XCTAssertFalse(gameManager.gameState.isGameOver,
                       "Game over should be false after restart")
        XCTAssertEqual(gameManager.currentScreen, .gameplay,
                       "Screen should be gameplay after start")
    }
}
