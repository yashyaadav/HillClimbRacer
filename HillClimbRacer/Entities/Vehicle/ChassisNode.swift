//
//  ChassisNode.swift
//  HillClimbRacer
//

import SpriteKit

/// The main body of the vehicle
class ChassisNode: SKSpriteNode {

    // MARK: - Properties

    private let chassisSize: CGSize

    // MARK: - Initialization

    init(size: CGSize = CGSize(width: 200, height: 60), color: SKColor = .red) {
        self.chassisSize = size
        super.init(texture: nil, color: color, size: size)

        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupPhysics() {
        // Create a rectangular physics body for the chassis
        physicsBody = SKPhysicsBody(rectangleOf: chassisSize)
        physicsBody?.categoryBitMask = PhysicsCategory.chassis
        physicsBody?.collisionBitMask = PhysicsCategory.chassisCollision
        physicsBody?.contactTestBitMask = PhysicsCategory.chassisContact

        physicsBody?.density = Constants.Vehicle.chassisDensity
        physicsBody?.friction = 0.2
        physicsBody?.restitution = 0.1
        physicsBody?.allowsRotation = true
        physicsBody?.linearDamping = 0.1
        physicsBody?.angularDamping = 0.5

        zPosition = Constants.ZPosition.vehicle
    }
}
