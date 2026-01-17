//
//  WheelNode.swift
//  HillClimbRacer
//

import SpriteKit

/// A wheel node with circular physics for the vehicle
class WheelNode: SKShapeNode {

    // MARK: - Properties

    let radius: CGFloat
    let isBreakable: Bool

    // MARK: - Initialization

    init(radius: CGFloat = 30, color: SKColor = .darkGray, isBreakable: Bool = true) {
        self.radius = radius
        self.isBreakable = isBreakable
        super.init()

        // Draw a circle
        let path = CGMutablePath()
        path.addEllipse(in: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2))
        self.path = path

        self.fillColor = color
        self.strokeColor = .black
        self.lineWidth = 2

        // Add a spoke line to visualize rotation
        let spokePath = CGMutablePath()
        spokePath.move(to: .zero)
        spokePath.addLine(to: CGPoint(x: radius * 0.8, y: 0))
        let spoke = SKShapeNode(path: spokePath)
        spoke.strokeColor = .white
        spoke.lineWidth = 3
        addChild(spoke)

        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupPhysics() {
        // Create circular physics body
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.categoryBitMask = PhysicsCategory.wheel
        physicsBody?.collisionBitMask = PhysicsCategory.wheelCollision
        physicsBody?.contactTestBitMask = PhysicsCategory.none

        physicsBody?.friction = Constants.Vehicle.wheelFriction
        physicsBody?.restitution = Constants.Vehicle.wheelRestitution
        physicsBody?.allowsRotation = true
        physicsBody?.linearDamping = 0.1
        physicsBody?.angularDamping = 0.1

        // Use precise collision detection for smoother terrain interaction
        physicsBody?.usesPreciseCollisionDetection = true

        zPosition = Constants.ZPosition.vehicle + 1
    }
}
