//
//  Constants.swift
//  HillClimbRacer
//

import CoreGraphics

/// Game-wide constants
enum Constants {

    // MARK: - Screen

    static let designWidth: CGFloat = 1334
    static let designHeight: CGFloat = 750

    // MARK: - Physics

    static let gravity: CGFloat = -9.8
    static let physicsScale: CGFloat = 150.0  // pixels per meter

    // MARK: - Vehicle Defaults

    enum Vehicle {
        static let chassisDensity: CGFloat = 2.0
        static let wheelFriction: CGFloat = 0.9
        static let wheelRestitution: CGFloat = 0.3

        static let suspensionDamping: CGFloat = 0.5
        static let suspensionFrequency: CGFloat = 4.5
        static let suspensionLowerLimit: CGFloat = 0.1
        static let suspensionUpperLimit: CGFloat = 65.0

        static let forwardPower: CGFloat = 35.0
        static let backwardPower: CGFloat = -10.0
        static let maxForwardSpeed: CGFloat = 750.0
        static let maxBackwardSpeed: CGFloat = -450.0

        static let tiltForce: CGFloat = 2000.0
        static let maxTiltAngle: CGFloat = 70.0  // degrees
    }

    // MARK: - Terrain

    enum Terrain {
        static let chunkWidth: CGFloat = 800.0
        static let pointSpacing: CGFloat = 20.0
        static let baseHeight: CGFloat = 300.0
        static let groundDepth: CGFloat = 500.0

        // Hill generation parameters
        static let largeHillAmplitude: CGFloat = 150.0
        static let largeHillFrequency: CGFloat = 0.002
        static let mediumHillAmplitude: CGFloat = 60.0
        static let mediumHillFrequency: CGFloat = 0.005
        static let noiseAmplitude: CGFloat = 30.0
        static let noiseFrequency: CGFloat = 0.01

        // Difficulty scaling
        static let difficultyScale: CGFloat = 50000.0
    }

    // MARK: - Gameplay

    enum Gameplay {
        static let startingFuel: CGFloat = 100.0
        static let fuelDrainRate: CGFloat = 2.5      // per second (increased for noticeable drain)
        static let throttleFuelMultiplier: CGFloat = 1.5  // reduced to balance with higher base rate
        static let fuelCanRefill: CGFloat = 30.0

        static let coinValue: Int = 1
        static let distanceMultiplier: CGFloat = 0.1  // meters to score
    }

    // MARK: - Camera

    enum Camera {
        static let defaultZoom: CGFloat = 1.0
        static let phoneZoom: CGFloat = 1.5
        static let leadOffset: CGFloat = 200.0  // look ahead
    }

    // MARK: - Z Positions

    enum ZPosition {
        static let background: CGFloat = -100
        static let terrain: CGFloat = 0
        static let collectibles: CGFloat = 5
        static let vehicle: CGFloat = 10
        static let particles: CGFloat = 15
        static let hud: CGFloat = 100
    }

    // MARK: - Upgrades

    enum Upgrades {
        static let maxLevel: Int = 5

        // Cost multiplier per level (level 1 = base cost, level 2 = base * 2, etc.)
        static let baseCost: Int = 100

        // Per-level improvements (multipliers)
        static let enginePowerPerLevel: CGFloat = 0.15      // +15% per level
        static let maxSpeedPerLevel: CGFloat = 0.08         // +8% per level
        static let fuelCapacityPerLevel: CGFloat = 0.20     // +20% per level
        static let fuelEfficiencyPerLevel: CGFloat = 0.10   // -10% fuel usage per level
        static let tireGripPerLevel: CGFloat = 0.10         // +10% per level
        static let suspensionStiffnessPerLevel: CGFloat = 0.12  // +12% per level

        /// Calculate upgrade cost for a given level
        static func cost(forLevel level: Int) -> Int {
            return baseCost * level
        }

        /// Calculate total cost to upgrade from level 1 to target level
        static func totalCost(toLevel level: Int) -> Int {
            guard level > 1 else { return 0 }
            return (1..<level).reduce(0) { $0 + cost(forLevel: $1) }
        }
    }

    // MARK: - Spawning

    enum Spawning {
        static let coinInterval: CGFloat = 150.0
        static let fuelInterval: CGFloat = 500.0
        static let spawnAheadDistance: CGFloat = 800.0
    }
}
