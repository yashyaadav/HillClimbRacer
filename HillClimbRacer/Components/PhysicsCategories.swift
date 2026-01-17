//
//  PhysicsCategories.swift
//  HillClimbRacer
//

import Foundation

/// Physics collision bitmasks for SpriteKit physics bodies
struct PhysicsCategory {
    static let none:       UInt32 = 0
    static let chassis:    UInt32 = 0b1       // 1
    static let wheel:      UInt32 = 0b10      // 2
    static let terrain:    UInt32 = 0b100     // 4
    static let coin:       UInt32 = 0b1000    // 8
    static let fuelCan:    UInt32 = 0b10000   // 16
    static let boundary:   UInt32 = 0b100000  // 32

    /// Everything the chassis can collide with
    static let chassisCollision: UInt32 = terrain | boundary

    /// Everything wheels can collide with
    static let wheelCollision: UInt32 = terrain

    /// What the chassis detects contact with (for game logic)
    static let chassisContact: UInt32 = coin | fuelCan | terrain
}
