//
//  VehicleDefinitions.swift
//  HillClimbRacer
//
//  Predefined vehicle configurations with distinct characteristics.
//

import CoreGraphics

enum VehicleDefinitions {

    // MARK: - Jeep (Default Vehicle)

    /// Balanced all-rounder, unlocked by default
    static let jeep = VehicleConfig(
        id: "jeep",
        name: "Hill Jeep",
        description: "Reliable all-terrain vehicle. Great for beginners.",
        chassisMass: 2.0,
        chassisSize: CGSize(width: 120, height: 40),
        wheelRadius: 25,
        wheelBase: 100,
        enginePower: 50,
        maxSpeed: 750,
        fuelCapacity: 100,
        fuelEfficiency: 1.0,
        suspensionStiffness: 4.5,
        suspensionDamping: 0.5,
        tiltForce: 2000,
        chassisColor: .red,
        wheelColor: .darkGray,
        unlockCost: 0,
        isUnlockedByDefault: true
    )

    // MARK: - Motorcycle (Fast & Tippy)

    /// Fast but unstable, requires skill to control
    static let motorcycle = VehicleConfig(
        id: "motorcycle",
        name: "Dirt Bike",
        description: "Fast but unstable. Master the art of balance.",
        chassisMass: 0.8,
        chassisSize: CGSize(width: 80, height: 30),
        wheelRadius: 20,
        wheelBase: 70,
        enginePower: 40,
        maxSpeed: 900,
        fuelCapacity: 60,
        fuelEfficiency: 0.7,  // Uses less fuel
        suspensionStiffness: 6.0,
        suspensionDamping: 0.3,
        tiltForce: 1500,
        chassisColor: .blue,
        wheelColor: .black,
        unlockCost: 500,
        isUnlockedByDefault: false
    )

    // MARK: - Monster Truck (Heavy & Powerful)

    /// Heavy and powerful, great for rough terrain
    static let monsterTruck = VehicleConfig(
        id: "monster_truck",
        name: "Monster Truck",
        description: "Heavy and powerful. Crushes anything in its path.",
        chassisMass: 4.0,
        chassisSize: CGSize(width: 150, height: 60),
        wheelRadius: 40,
        wheelBase: 130,
        enginePower: 80,
        maxSpeed: 600,
        fuelCapacity: 150,
        fuelEfficiency: 1.5,  // Uses more fuel
        suspensionStiffness: 3.5,
        suspensionDamping: 0.7,
        tiltForce: 3000,
        chassisColor: .green,
        wheelColor: .darkGray,
        unlockCost: 1000,
        isUnlockedByDefault: false
    )

    // MARK: - All Vehicles

    /// All available vehicles in order
    static let all: [VehicleConfig] = [jeep, motorcycle, monsterTruck]

    /// Get vehicle by ID
    static func vehicle(withId id: String) -> VehicleConfig? {
        all.first { $0.id == id }
    }

    /// Default vehicle
    static var defaultVehicle: VehicleConfig {
        jeep
    }
}

// MARK: - Vehicle Stats Display

extension VehicleConfig {

    /// Normalized stats for UI display (0-100 scale)
    var normalizedStats: VehicleStats {
        VehicleStats(
            speed: normalize(maxSpeed, min: 500, max: 1000),
            power: normalize(enginePower, min: 30, max: 100),
            fuel: normalize(fuelCapacity, min: 50, max: 200),
            handling: normalize(tiltForce, min: 1000, max: 3500),
            stability: normalize(chassisMass, min: 0.5, max: 5.0)
        )
    }

    private func normalize(_ value: CGFloat, min: CGFloat, max: CGFloat) -> Int {
        let clamped = Swift.min(Swift.max(value, min), max)
        return Int((clamped - min) / (max - min) * 100)
    }
}

struct VehicleStats {
    let speed: Int
    let power: Int
    let fuel: Int
    let handling: Int
    let stability: Int
}
