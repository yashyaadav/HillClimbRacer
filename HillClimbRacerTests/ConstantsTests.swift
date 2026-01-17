//
//  ConstantsTests.swift
//  HillClimbRacerTests
//
//  Unit tests for game constants and upgrade calculations.
//

import XCTest
@testable import HillClimbRacer

final class ConstantsTests: XCTestCase {

    // MARK: - Screen Constants

    func testDesignDimensions() {
        XCTAssertGreaterThan(Constants.designWidth, 0, "Design width should be positive")
        XCTAssertGreaterThan(Constants.designHeight, 0, "Design height should be positive")
    }

    // MARK: - Physics Constants

    func testGravity() {
        XCTAssertLessThan(Constants.gravity, 0, "Gravity should be negative (downward)")
    }

    func testPhysicsScale() {
        XCTAssertGreaterThan(Constants.physicsScale, 0, "Physics scale should be positive")
    }

    // MARK: - Vehicle Constants

    func testVehiclePhysics() {
        XCTAssertGreaterThan(Constants.Vehicle.chassisDensity, 0, "Chassis density should be positive")
        XCTAssertGreaterThan(Constants.Vehicle.wheelFriction, 0, "Wheel friction should be positive")
        XCTAssertLessThanOrEqual(Constants.Vehicle.wheelFriction, 1, "Wheel friction should be <= 1")
    }

    func testSuspensionConstants() {
        XCTAssertGreaterThan(Constants.Vehicle.suspensionDamping, 0, "Damping should be positive")
        XCTAssertGreaterThan(Constants.Vehicle.suspensionFrequency, 0, "Frequency should be positive")
        XCTAssertGreaterThan(Constants.Vehicle.suspensionUpperLimit, Constants.Vehicle.suspensionLowerLimit, "Upper limit should be greater than lower")
    }

    func testPowerValues() {
        XCTAssertGreaterThan(Constants.Vehicle.forwardPower, 0, "Forward power should be positive")
        XCTAssertLessThan(Constants.Vehicle.backwardPower, 0, "Backward power should be negative")
        XCTAssertGreaterThan(Constants.Vehicle.maxForwardSpeed, 0, "Max forward speed should be positive")
        XCTAssertLessThan(Constants.Vehicle.maxBackwardSpeed, 0, "Max backward speed should be negative")
    }

    // MARK: - Terrain Constants

    func testTerrainChunkSize() {
        XCTAssertGreaterThan(Constants.Terrain.chunkWidth, 0, "Chunk width should be positive")
        XCTAssertGreaterThan(Constants.Terrain.pointSpacing, 0, "Point spacing should be positive")
    }

    func testTerrainGeneration() {
        XCTAssertGreaterThan(Constants.Terrain.largeHillAmplitude, Constants.Terrain.mediumHillAmplitude, "Large hills should be bigger than medium")
        XCTAssertGreaterThan(Constants.Terrain.mediumHillAmplitude, Constants.Terrain.noiseAmplitude, "Medium hills should be bigger than noise")
    }

    // MARK: - Gameplay Constants

    func testFuelConstants() {
        XCTAssertGreaterThan(Constants.Gameplay.startingFuel, 0, "Starting fuel should be positive")
        XCTAssertGreaterThan(Constants.Gameplay.fuelDrainRate, 0, "Fuel drain rate should be positive")
        XCTAssertGreaterThan(Constants.Gameplay.throttleFuelMultiplier, 1, "Throttle should use more fuel than idle")
        XCTAssertGreaterThan(Constants.Gameplay.fuelCanRefill, 0, "Fuel can refill should be positive")
    }

    func testFuelDrainRateIs2Point5() {
        // Verify exact fuel drain rate value for balance tuning
        XCTAssertEqual(Constants.Gameplay.fuelDrainRate, 2.5,
                       "Fuel drain rate should be exactly 2.5 per second")
    }

    func testThrottleFuelMultiplierIs1Point5() {
        // Verify exact throttle multiplier value for balance tuning
        XCTAssertEqual(Constants.Gameplay.throttleFuelMultiplier, 1.5,
                       "Throttle fuel multiplier should be exactly 1.5")
    }

    func testCoinValue() {
        XCTAssertGreaterThan(Constants.Gameplay.coinValue, 0, "Coin value should be positive")
    }

    // MARK: - Upgrade Constants

    func testMaxLevel() {
        XCTAssertGreaterThan(Constants.Upgrades.maxLevel, 1, "Max level should be greater than 1")
    }

    func testBaseCost() {
        XCTAssertGreaterThan(Constants.Upgrades.baseCost, 0, "Base cost should be positive")
    }

    func testUpgradeMultipliers() {
        XCTAssertGreaterThan(Constants.Upgrades.enginePowerPerLevel, 0, "Engine power per level should be positive")
        XCTAssertGreaterThan(Constants.Upgrades.maxSpeedPerLevel, 0, "Max speed per level should be positive")
        XCTAssertGreaterThan(Constants.Upgrades.fuelCapacityPerLevel, 0, "Fuel capacity per level should be positive")
        XCTAssertGreaterThan(Constants.Upgrades.fuelEfficiencyPerLevel, 0, "Fuel efficiency per level should be positive")
        XCTAssertGreaterThan(Constants.Upgrades.tireGripPerLevel, 0, "Tire grip per level should be positive")
        XCTAssertGreaterThan(Constants.Upgrades.suspensionStiffnessPerLevel, 0, "Suspension stiffness per level should be positive")
    }

    func testCostCalculation() {
        let level1Cost = Constants.Upgrades.cost(forLevel: 1)
        let level2Cost = Constants.Upgrades.cost(forLevel: 2)

        XCTAssertEqual(level1Cost, Constants.Upgrades.baseCost * 1, "Level 1 cost should be base cost")
        XCTAssertEqual(level2Cost, Constants.Upgrades.baseCost * 2, "Level 2 cost should be 2x base cost")
    }

    func testTotalCostCalculation() {
        let totalTo1 = Constants.Upgrades.totalCost(toLevel: 1)
        XCTAssertEqual(totalTo1, 0, "Total cost to level 1 should be 0")

        let totalTo2 = Constants.Upgrades.totalCost(toLevel: 2)
        XCTAssertEqual(totalTo2, Constants.Upgrades.baseCost, "Total cost to level 2 should be base cost")

        let totalTo3 = Constants.Upgrades.totalCost(toLevel: 3)
        XCTAssertEqual(totalTo3, Constants.Upgrades.baseCost * 3, "Total cost to level 3 should be 3x base cost")
    }

    // MARK: - Z Position Constants

    func testZPositionOrdering() {
        XCTAssertLessThan(Constants.ZPosition.background, Constants.ZPosition.terrain, "Background should be behind terrain")
        XCTAssertLessThan(Constants.ZPosition.terrain, Constants.ZPosition.collectibles, "Terrain should be behind collectibles")
        XCTAssertLessThan(Constants.ZPosition.collectibles, Constants.ZPosition.vehicle, "Collectibles should be behind vehicle")
        XCTAssertLessThan(Constants.ZPosition.vehicle, Constants.ZPosition.hud, "Vehicle should be behind HUD")
    }

    // MARK: - Camera Constants

    func testCameraZoom() {
        XCTAssertGreaterThan(Constants.Camera.defaultZoom, 0, "Default zoom should be positive")
        XCTAssertGreaterThan(Constants.Camera.phoneZoom, Constants.Camera.defaultZoom, "Phone zoom should be more than default")
    }

    // MARK: - Spawning Constants

    func testSpawningIntervals() {
        XCTAssertGreaterThan(Constants.Spawning.coinInterval, 0, "Coin interval should be positive")
        XCTAssertGreaterThan(Constants.Spawning.fuelInterval, 0, "Fuel interval should be positive")
        XCTAssertGreaterThan(Constants.Spawning.fuelInterval, Constants.Spawning.coinInterval, "Fuel should spawn less frequently than coins")
    }
}
