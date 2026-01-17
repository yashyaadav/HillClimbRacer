//
//  VehicleConfigTests.swift
//  HillClimbRacerTests
//
//  Unit tests for VehicleConfig and VehicleDefinitions.
//

import XCTest
@testable import HillClimbRacer

final class VehicleConfigTests: XCTestCase {

    // MARK: - Vehicle Definitions Tests

    func testAllVehiclesExist() {
        XCTAssertEqual(VehicleDefinitions.all.count, 3, "Should have 3 vehicles defined")
    }

    func testJeepIsDefault() {
        let defaultVehicle = VehicleDefinitions.defaultVehicle
        XCTAssertEqual(defaultVehicle.id, "jeep", "Default vehicle should be jeep")
    }

    func testJeepIsUnlockedByDefault() {
        let jeep = VehicleDefinitions.jeep
        XCTAssertTrue(jeep.isUnlockedByDefault, "Jeep should be unlocked by default")
        XCTAssertEqual(jeep.unlockCost, 0, "Jeep should be free")
    }

    func testMotorcycleIsLocked() {
        let motorcycle = VehicleDefinitions.motorcycle
        XCTAssertFalse(motorcycle.isUnlockedByDefault, "Motorcycle should be locked")
        XCTAssertGreaterThan(motorcycle.unlockCost, 0, "Motorcycle should have unlock cost")
    }

    func testMonsterTruckIsLocked() {
        let monsterTruck = VehicleDefinitions.monsterTruck
        XCTAssertFalse(monsterTruck.isUnlockedByDefault, "Monster truck should be locked")
        XCTAssertGreaterThan(monsterTruck.unlockCost, 0, "Monster truck should have unlock cost")
    }

    func testVehicleLookupById() {
        let jeep = VehicleDefinitions.vehicle(withId: "jeep")
        XCTAssertNotNil(jeep, "Should find jeep by ID")
        XCTAssertEqual(jeep?.name, "Hill Jeep")

        let motorcycle = VehicleDefinitions.vehicle(withId: "motorcycle")
        XCTAssertNotNil(motorcycle, "Should find motorcycle by ID")

        let monster = VehicleDefinitions.vehicle(withId: "monster_truck")
        XCTAssertNotNil(monster, "Should find monster truck by ID")

        let invalid = VehicleDefinitions.vehicle(withId: "invalid_id")
        XCTAssertNil(invalid, "Should return nil for invalid ID")
    }

    // MARK: - Vehicle Config Properties Tests

    func testVehicleConfigHasValidProperties() {
        for vehicle in VehicleDefinitions.all {
            XCTAssertFalse(vehicle.id.isEmpty, "\(vehicle.name) should have ID")
            XCTAssertFalse(vehicle.name.isEmpty, "Vehicle should have name")
            XCTAssertFalse(vehicle.description.isEmpty, "\(vehicle.name) should have description")

            XCTAssertGreaterThan(vehicle.chassisMass, 0, "\(vehicle.name) mass should be positive")
            XCTAssertGreaterThan(vehicle.chassisSize.width, 0, "\(vehicle.name) width should be positive")
            XCTAssertGreaterThan(vehicle.chassisSize.height, 0, "\(vehicle.name) height should be positive")
            XCTAssertGreaterThan(vehicle.wheelRadius, 0, "\(vehicle.name) wheel radius should be positive")
            XCTAssertGreaterThan(vehicle.enginePower, 0, "\(vehicle.name) engine power should be positive")
            XCTAssertGreaterThan(vehicle.maxSpeed, 0, "\(vehicle.name) max speed should be positive")
            XCTAssertGreaterThan(vehicle.fuelCapacity, 0, "\(vehicle.name) fuel capacity should be positive")
            XCTAssertGreaterThan(vehicle.fuelEfficiency, 0, "\(vehicle.name) fuel efficiency should be positive")
        }
    }

    // MARK: - Vehicle Stats Tests

    func testNormalizedStatsAreInRange() {
        for vehicle in VehicleDefinitions.all {
            let stats = vehicle.normalizedStats

            XCTAssertGreaterThanOrEqual(stats.speed, 0, "\(vehicle.name) speed should be >= 0")
            XCTAssertLessThanOrEqual(stats.speed, 100, "\(vehicle.name) speed should be <= 100")

            XCTAssertGreaterThanOrEqual(stats.power, 0, "\(vehicle.name) power should be >= 0")
            XCTAssertLessThanOrEqual(stats.power, 100, "\(vehicle.name) power should be <= 100")

            XCTAssertGreaterThanOrEqual(stats.fuel, 0, "\(vehicle.name) fuel should be >= 0")
            XCTAssertLessThanOrEqual(stats.fuel, 100, "\(vehicle.name) fuel should be <= 100")

            XCTAssertGreaterThanOrEqual(stats.handling, 0, "\(vehicle.name) handling should be >= 0")
            XCTAssertLessThanOrEqual(stats.handling, 100, "\(vehicle.name) handling should be <= 100")
        }
    }

    // MARK: - Upgrade Multiplier Tests

    func testUpgradesIncreaseStats() {
        let baseConfig = VehicleDefinitions.jeep

        let upgradedConfig = baseConfig.withUpgrades(
            engineLevel: 3,
            fuelLevel: 3,
            tiresLevel: 3,
            suspensionLevel: 3
        )

        XCTAssertGreaterThan(upgradedConfig.enginePower, baseConfig.enginePower, "Upgraded engine should have more power")
        XCTAssertGreaterThan(upgradedConfig.maxSpeed, baseConfig.maxSpeed, "Upgraded should have higher max speed")
        XCTAssertGreaterThan(upgradedConfig.fuelCapacity, baseConfig.fuelCapacity, "Upgraded should have more fuel capacity")
        XCTAssertLessThan(upgradedConfig.fuelEfficiency, baseConfig.fuelEfficiency, "Upgraded should use less fuel (lower efficiency value)")
    }

    func testLevel1UpgradesNoChange() {
        let baseConfig = VehicleDefinitions.jeep

        let sameConfig = baseConfig.withUpgrades(
            engineLevel: 1,
            fuelLevel: 1,
            tiresLevel: 1,
            suspensionLevel: 1
        )

        XCTAssertEqual(sameConfig.enginePower, baseConfig.enginePower, "Level 1 should not change engine power")
        XCTAssertEqual(sameConfig.maxSpeed, baseConfig.maxSpeed, "Level 1 should not change max speed")
        XCTAssertEqual(sameConfig.fuelCapacity, baseConfig.fuelCapacity, "Level 1 should not change fuel capacity")
    }

    // MARK: - VehicleColor Tests

    func testVehicleColorConversion() {
        let color = VehicleColor(red: 0.5, green: 0.6, blue: 0.7, alpha: 1.0)

        XCTAssertEqual(color.red, 0.5)
        XCTAssertEqual(color.green, 0.6)
        XCTAssertEqual(color.blue, 0.7)
        XCTAssertEqual(color.alpha, 1.0)

        // Test SKColor conversion
        let skColor = color.skColor
        XCTAssertNotNil(skColor, "Should convert to SKColor")
    }

    func testVehicleColorPresets() {
        XCTAssertEqual(VehicleColor.red.red, 0.9)
        XCTAssertEqual(VehicleColor.blue.blue, 0.9)
        XCTAssertEqual(VehicleColor.green.green, 0.7)
    }

    // MARK: - Suspension Config Tests

    func testSuspensionConfigGeneration() {
        let jeep = VehicleDefinitions.jeep
        let suspensionConfig = jeep.suspensionConfig

        XCTAssertEqual(suspensionConfig.frequency, jeep.suspensionStiffness, "Frequency should match stiffness")
        XCTAssertEqual(suspensionConfig.damping, jeep.suspensionDamping, "Damping should match")
        XCTAssertGreaterThan(suspensionConfig.suspensionTravel, 0, "Travel should be positive")
    }
}
