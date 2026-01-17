//
//  ChassisNode.swift
//  HillClimbRacer
//
//  The main body of the vehicle with optional texture support.
//
//  Expected texture asset names (for when you add them):
//  - "jeep_chassis", "jeep_chassis@2x", "jeep_chassis@3x"
//  - "motorcycle_chassis", "motorcycle_chassis@2x", "motorcycle_chassis@3x"
//  - "monstertruck_chassis", "monstertruck_chassis@2x", "monstertruck_chassis@3x"
//

import SpriteKit

/// The main body of the vehicle
class ChassisNode: SKSpriteNode {

    // MARK: - Properties

    private let chassisSize: CGSize

    /// Whether this node is using a texture or fallback color
    private(set) var isUsingTexture: Bool = false

    // MARK: - Initialization

    /// Initialize with optional texture name, falling back to color if texture not found
    init(
        size: CGSize = CGSize(width: 200, height: 60),
        color: SKColor = .red,
        textureName: String? = nil
    ) {
        self.chassisSize = size

        // Try to load texture if name provided
        var loadedTexture: SKTexture?
        if let name = textureName {
            loadedTexture = ChassisNode.loadTexture(named: name)
        }

        if let texture = loadedTexture {
            // Use texture
            super.init(texture: texture, color: .white, size: size)
            self.isUsingTexture = true
        } else {
            // Fallback to color
            super.init(texture: nil, color: color, size: size)
            self.isUsingTexture = false
        }

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

    // MARK: - Texture Loading

    /// Attempt to load a texture, returning nil if not found
    private static func loadTexture(named name: String) -> SKTexture? {
        // Check if the image exists in the asset catalog
        guard UIImage(named: name) != nil else {
            return nil
        }
        return SKTexture(imageNamed: name)
    }

    /// Update the chassis texture at runtime
    func updateTexture(named name: String) {
        if let texture = ChassisNode.loadTexture(named: name) {
            self.texture = texture
            self.isUsingTexture = true
        }
    }
}
