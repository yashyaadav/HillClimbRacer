//
//  VehicleConfig.swift
//  HillClimbRacer
//
//  Data model for vehicle configurations with distinct physics characteristics.
//

import CoreGraphics
import SpriteKit
import SwiftUI

struct VehicleConfig: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String

    // Physics properties (base values, modified by upgrades)
    let chassisMass: CGFloat
    let chassisSize: CGSize
    let wheelRadius: CGFloat
    let wheelBase: CGFloat
    let enginePower: CGFloat
    let maxSpeed: CGFloat
    let fuelCapacity: CGFloat
    let fuelEfficiency: CGFloat  // multiplier for drain rate (higher = more fuel use)
    let suspensionStiffness: CGFloat
    let suspensionDamping: CGFloat
    let tiltForce: CGFloat

    // Visual properties
    let chassisColor: VehicleColor
    let wheelColor: VehicleColor

    // Unlock requirements
    let unlockCost: Int
    let isUnlockedByDefault: Bool

    // Computed properties for physics setup
    var suspensionConfig: SuspensionConfig {
        SuspensionConfig(
            frequency: suspensionStiffness,
            damping: suspensionDamping,
            suspensionTravel: 65.0,
            lowerLimit: 0.1
        )
    }
}

// MARK: - Vehicle Color (Codable wrapper for CGColor)

struct VehicleColor: Codable, Equatable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat

    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    static let red = VehicleColor(red: 0.9, green: 0.2, blue: 0.2)
    static let blue = VehicleColor(red: 0.2, green: 0.4, blue: 0.9)
    static let green = VehicleColor(red: 0.2, green: 0.7, blue: 0.3)
    static let orange = VehicleColor(red: 1.0, green: 0.5, blue: 0.0)
    static let darkGray = VehicleColor(red: 0.3, green: 0.3, blue: 0.3)
    static let black = VehicleColor(red: 0.1, green: 0.1, blue: 0.1)

    /// Convert to SKColor for SpriteKit rendering
    var skColor: SKColor {
        SKColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// Convert to SwiftUI Color
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}

// MARK: - Upgrade Multipliers

extension VehicleConfig {

    /// Apply upgrade multipliers to create modified config
    func withUpgrades(
        engineLevel: Int,
        fuelLevel: Int,
        tiresLevel: Int,
        suspensionLevel: Int
    ) -> VehicleConfig {
        let engineMultiplier = 1.0 + (CGFloat(engineLevel - 1) * Constants.Upgrades.enginePowerPerLevel)
        let speedMultiplier = 1.0 + (CGFloat(engineLevel - 1) * Constants.Upgrades.maxSpeedPerLevel)
        let fuelMultiplier = 1.0 + (CGFloat(fuelLevel - 1) * Constants.Upgrades.fuelCapacityPerLevel)
        let efficiencyMultiplier = 1.0 - (CGFloat(fuelLevel - 1) * Constants.Upgrades.fuelEfficiencyPerLevel)
        let gripMultiplier = 1.0 + (CGFloat(tiresLevel - 1) * Constants.Upgrades.tireGripPerLevel)
        let suspensionMultiplier = 1.0 + (CGFloat(suspensionLevel - 1) * Constants.Upgrades.suspensionStiffnessPerLevel)

        return VehicleConfig(
            id: id,
            name: name,
            description: description,
            chassisMass: chassisMass,
            chassisSize: chassisSize,
            wheelRadius: wheelRadius * (1.0 + (CGFloat(tiresLevel - 1) * 0.02)), // Slightly larger tires
            wheelBase: wheelBase,
            enginePower: enginePower * engineMultiplier,
            maxSpeed: maxSpeed * speedMultiplier,
            fuelCapacity: fuelCapacity * fuelMultiplier,
            fuelEfficiency: fuelEfficiency * efficiencyMultiplier,
            suspensionStiffness: suspensionStiffness * suspensionMultiplier,
            suspensionDamping: suspensionDamping * (1.0 + (CGFloat(suspensionLevel - 1) * 0.1)),
            tiltForce: tiltForce,
            chassisColor: chassisColor,
            wheelColor: wheelColor,
            unlockCost: unlockCost,
            isUnlockedByDefault: isUnlockedByDefault
        )
    }
}
