//
//  PersistenceManagerTests.swift
//  HillClimbRacerTests
//
//  Unit tests for PersistenceManager.
//

import XCTest
@testable import HillClimbRacer

final class PersistenceManagerTests: XCTestCase {

    var persistence: PersistenceManager!

    override func setUpWithError() throws {
        persistence = PersistenceManager.shared
        persistence.resetAllProgress()
    }

    override func tearDownWithError() throws {
        persistence.resetAllProgress()
    }

    // MARK: - Coin Tests

    func testInitialCoins() {
        XCTAssertEqual(persistence.totalCoins, 0, "Initial coins should be 0")
    }

    func testAddCoins() {
        persistence.addCoins(100)
        XCTAssertEqual(persistence.totalCoins, 100, "Total coins should be 100")
    }

    func testSpendCoins() {
        persistence.addCoins(100)
        let success = persistence.spendCoins(50)
        XCTAssertTrue(success, "Should successfully spend coins")
        XCTAssertEqual(persistence.totalCoins, 50, "Remaining coins should be 50")
    }

    func testSpendCoinsInsufficientFunds() {
        persistence.addCoins(30)
        let success = persistence.spendCoins(50)
        XCTAssertFalse(success, "Should fail to spend more than available")
        XCTAssertEqual(persistence.totalCoins, 30, "Coins should remain unchanged")
    }

    // MARK: - Best Distance Tests

    func testInitialBestDistance() {
        XCTAssertEqual(persistence.bestDistance, 0, "Initial best distance should be 0")
    }

    func testUpdateBestDistance() {
        persistence.updateBestDistance(100)
        XCTAssertEqual(persistence.bestDistance, 100, "Best distance should be 100")
    }

    func testBestDistanceOnlyUpdatesIfBetter() {
        persistence.updateBestDistance(100)
        persistence.updateBestDistance(50)
        XCTAssertEqual(persistence.bestDistance, 100, "Best distance should remain 100")

        persistence.updateBestDistance(150)
        XCTAssertEqual(persistence.bestDistance, 150, "Best distance should update to 150")
    }

    // MARK: - Settings Tests

    func testSoundEnabledDefault() {
        XCTAssertTrue(persistence.isSoundEnabled, "Sound should be enabled by default")
    }

    func testMusicEnabledDefault() {
        XCTAssertTrue(persistence.isMusicEnabled, "Music should be enabled by default")
    }

    func testToggleSound() {
        persistence.isSoundEnabled = false
        XCTAssertFalse(persistence.isSoundEnabled, "Sound should be disabled")

        persistence.isSoundEnabled = true
        XCTAssertTrue(persistence.isSoundEnabled, "Sound should be enabled")
    }

    // MARK: - Vehicle Selection Tests

    func testDefaultSelectedVehicle() {
        XCTAssertEqual(persistence.selectedVehicleId, "jeep", "Default vehicle should be jeep")
    }

    func testChangeSelectedVehicle() {
        persistence.selectedVehicleId = "motorcycle"
        XCTAssertEqual(persistence.selectedVehicleId, "motorcycle", "Selected vehicle should change")
    }

    // MARK: - Vehicle Unlock Tests

    func testDefaultUnlockedVehicles() {
        let unlocked = persistence.unlockedVehicleIds
        XCTAssertTrue(unlocked.contains("jeep"), "Jeep should be unlocked by default")
    }

    func testIsVehicleUnlocked() {
        XCTAssertTrue(persistence.isVehicleUnlocked("jeep"), "Jeep should be unlocked")
        XCTAssertFalse(persistence.isVehicleUnlocked("motorcycle"), "Motorcycle should be locked")
    }

    func testUnlockVehicle() {
        persistence.addCoins(1000)
        let success = persistence.unlockVehicle("motorcycle")
        XCTAssertTrue(success, "Should successfully unlock motorcycle")
        XCTAssertTrue(persistence.isVehicleUnlocked("motorcycle"), "Motorcycle should now be unlocked")
    }

    func testUnlockVehicleInsufficientCoins() {
        persistence.addCoins(100)
        let success = persistence.unlockVehicle("monster_truck") // Costs 1000
        XCTAssertFalse(success, "Should fail to unlock without enough coins")
        XCTAssertFalse(persistence.isVehicleUnlocked("monster_truck"), "Monster truck should remain locked")
    }

    func testUnlockAlreadyUnlockedVehicle() {
        let success = persistence.unlockVehicle("jeep")
        XCTAssertTrue(success, "Should return true for already unlocked vehicle")
    }

    // MARK: - Upgrade Tests

    func testInitialUpgradeLevel() {
        let level = persistence.upgradeLevel(for: "jeep", upgradeType: .engine)
        XCTAssertEqual(level, 1, "Initial upgrade level should be 1")
    }

    func testUpgradeVehicle() {
        persistence.addCoins(500)
        let success = persistence.upgradeVehicle("jeep", upgradeType: .engine)
        XCTAssertTrue(success, "Should successfully upgrade")

        let newLevel = persistence.upgradeLevel(for: "jeep", upgradeType: .engine)
        XCTAssertEqual(newLevel, 2, "Level should increase to 2")
    }

    func testUpgradeVehicleInsufficientCoins() {
        let success = persistence.upgradeVehicle("jeep", upgradeType: .engine)
        XCTAssertFalse(success, "Should fail without coins")

        let level = persistence.upgradeLevel(for: "jeep", upgradeType: .engine)
        XCTAssertEqual(level, 1, "Level should remain at 1")
    }

    func testUpgradeMaxLevel() {
        persistence.addCoins(10000)

        // Upgrade to max
        for _ in 1..<Constants.Upgrades.maxLevel {
            _ = persistence.upgradeVehicle("jeep", upgradeType: .engine)
        }

        let level = persistence.upgradeLevel(for: "jeep", upgradeType: .engine)
        XCTAssertEqual(level, Constants.Upgrades.maxLevel, "Should be at max level")

        // Try to upgrade beyond max
        let success = persistence.upgradeVehicle("jeep", upgradeType: .engine)
        XCTAssertFalse(success, "Should not upgrade beyond max")
    }

    // MARK: - Per-Vehicle Best Distance Tests

    func testPerVehicleBestDistance() {
        persistence.updateBestDistance(100, for: "jeep")
        XCTAssertEqual(persistence.bestDistance(for: "jeep"), 100, "Jeep best should be 100")
        XCTAssertEqual(persistence.bestDistance(for: "motorcycle"), 0, "Motorcycle best should be 0")
    }

    // MARK: - Reset Tests

    func testResetAllProgress() {
        // Modify state
        persistence.addCoins(1000)
        persistence.updateBestDistance(500)
        persistence.isSoundEnabled = false

        // Reset
        persistence.resetAllProgress()

        // Verify
        XCTAssertEqual(persistence.totalCoins, 0, "Coins should reset to 0")
        XCTAssertEqual(persistence.bestDistance, 0, "Best distance should reset to 0")
        XCTAssertTrue(persistence.isSoundEnabled, "Sound should be re-enabled")
    }

    // MARK: - Games Played Tests

    func testGamesPlayed() {
        XCTAssertEqual(persistence.gamesPlayed, 0, "Initial games played should be 0")

        persistence.incrementGamesPlayed()
        XCTAssertEqual(persistence.gamesPlayed, 1, "Games played should be 1")

        persistence.incrementGamesPlayed()
        XCTAssertEqual(persistence.gamesPlayed, 2, "Games played should be 2")
    }
}
