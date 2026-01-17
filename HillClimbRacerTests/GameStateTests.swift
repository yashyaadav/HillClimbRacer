//
//  GameStateTests.swift
//  HillClimbRacerTests
//
//  Unit tests for GameState model.
//

import XCTest
@testable import HillClimbRacer

final class GameStateTests: XCTestCase {

    var gameState: GameState!

    override func setUpWithError() throws {
        gameState = GameState()
    }

    override func tearDownWithError() throws {
        gameState = nil
    }

    // MARK: - Initial State Tests

    func testInitialFuel() {
        XCTAssertEqual(gameState.fuel, 100.0, "Initial fuel should be 100")
    }

    func testInitialCoins() {
        XCTAssertEqual(gameState.coins, 0, "Initial coins should be 0")
    }

    func testInitialDistance() {
        XCTAssertEqual(gameState.distance, 0.0, "Initial distance should be 0")
    }

    func testInitialGameOverState() {
        XCTAssertFalse(gameState.isGameOver, "Game should not be over initially")
    }

    func testInitialPauseState() {
        XCTAssertFalse(gameState.isPaused, "Game should not be paused initially")
    }

    // MARK: - Fuel Tests

    func testFuelConsumption() {
        gameState.consumeFuel(deltaTime: 1.0, isThrottling: false)
        XCTAssertLessThan(gameState.fuel, 100.0, "Fuel should decrease after consumption")
    }

    func testFuelConsumptionWithThrottle() {
        let fuelBefore = gameState.fuel
        gameState.consumeFuel(deltaTime: 1.0, isThrottling: true)
        let fuelAfter = gameState.fuel

        // Reset and test without throttle
        gameState.reset()
        gameState.consumeFuel(deltaTime: 1.0, isThrottling: false)
        let fuelWithoutThrottle = gameState.fuel

        XCTAssertLessThan(fuelAfter, fuelWithoutThrottle, "Throttling should consume more fuel")
    }

    func testAddFuel() {
        gameState.consumeFuel(deltaTime: 5.0, isThrottling: true)
        let fuelAfterConsumption = gameState.fuel

        gameState.addFuel(30)
        XCTAssertGreaterThan(gameState.fuel, fuelAfterConsumption, "Fuel should increase after adding")
    }

    func testFuelCannotExceedMax() {
        gameState.addFuel(200)
        XCTAssertEqual(gameState.fuel, 100.0, "Fuel should not exceed 100")
    }

    func testFuelCannotGoBelowZero() {
        for _ in 0..<100 {
            gameState.consumeFuel(deltaTime: 1.0, isThrottling: true)
        }
        XCTAssertGreaterThanOrEqual(gameState.fuel, 0, "Fuel should not go below 0")
    }

    func testIsFuelLow() {
        gameState.fuel = 25
        XCTAssertTrue(gameState.isFuelLow, "Fuel should be considered low at 25%")

        gameState.fuel = 50
        XCTAssertFalse(gameState.isFuelLow, "Fuel should not be considered low at 50%")
    }

    func testIsFuelEmpty() {
        gameState.fuel = 0
        XCTAssertTrue(gameState.isFuelEmpty, "Fuel should be empty at 0")

        gameState.fuel = 1
        XCTAssertFalse(gameState.isFuelEmpty, "Fuel should not be empty at 1")
    }

    // MARK: - Coin Tests

    func testAddCoins() {
        gameState.addCoins()
        XCTAssertEqual(gameState.coins, 1, "Coins should increase by 1")
    }

    func testAddMultipleCoins() {
        for _ in 0..<10 {
            gameState.addCoins()
        }
        XCTAssertEqual(gameState.coins, 10, "Coins should equal 10 after adding 10 times")
    }

    // MARK: - Distance Tests

    func testUpdateDistance() {
        gameState.updateDistance(playerX: 1000)
        XCTAssertGreaterThan(gameState.distance, 0, "Distance should increase with player movement")
    }

    func testDisplayDistance() {
        gameState.distance = 150.5
        XCTAssertEqual(gameState.displayDistance, 150, "Display distance should be integer")
    }

    // MARK: - Game Over Tests

    func testGameOverOutOfFuel() {
        gameState.triggerGameOver(reason: .outOfFuel)
        XCTAssertTrue(gameState.isGameOver, "Game should be over")
        XCTAssertEqual(gameState.gameOverReason, .outOfFuel, "Reason should be out of fuel")
    }

    func testGameOverVehicleFlipped() {
        gameState.triggerGameOver(reason: .vehicleFlipped)
        XCTAssertTrue(gameState.isGameOver, "Game should be over")
        XCTAssertEqual(gameState.gameOverReason, .vehicleFlipped, "Reason should be vehicle flipped")
    }

    func testGameOverFellOffWorld() {
        gameState.triggerGameOver(reason: .fellOffWorld)
        XCTAssertTrue(gameState.isGameOver, "Game should be over")
        XCTAssertEqual(gameState.gameOverReason, .fellOffWorld, "Reason should be fell off world")
    }

    // MARK: - Reset Tests

    func testReset() {
        // Modify state
        gameState.fuel = 50
        gameState.coins = 100
        gameState.distance = 500
        gameState.triggerGameOver(reason: .outOfFuel)

        // Reset
        gameState.reset()

        // Verify reset
        XCTAssertEqual(gameState.fuel, 100.0, "Fuel should reset to 100")
        XCTAssertEqual(gameState.coins, 0, "Coins should reset to 0")
        XCTAssertEqual(gameState.distance, 0, "Distance should reset to 0")
        XCTAssertFalse(gameState.isGameOver, "Game over should be false")
        XCTAssertFalse(gameState.isPaused, "Paused should be false")
    }
}
