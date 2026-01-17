//
//  WheelNode.swift
//  HillClimbRacer
//
//  A wheel node with circular physics and optional texture support.
//
//  Expected texture asset names (for when you add them):
//  - "jeep_wheel", "jeep_wheel@2x", "jeep_wheel@3x"
//  - "motorcycle_wheel", "motorcycle_wheel@2x", "motorcycle_wheel@3x"
//  - "monstertruck_wheel", "monstertruck_wheel@2x", "monstertruck_wheel@3x"
//

import SpriteKit

/// A wheel node with circular physics for the vehicle
class WheelNode: SKNode {

    // MARK: - Properties

    let radius: CGFloat
    let isBreakable: Bool

    /// Whether this node is using a texture or fallback shape
    private(set) var isUsingTexture: Bool = false

    /// The shape node (used when no texture)
    private var shapeNode: SKShapeNode?

    /// The sprite node (used when texture is available)
    private var spriteNode: SKSpriteNode?

    // MARK: - Initialization

    init(
        radius: CGFloat = 30,
        color: SKColor = .darkGray,
        isBreakable: Bool = true,
        textureName: String? = nil
    ) {
        self.radius = radius
        self.isBreakable = isBreakable
        super.init()

        // Try to load texture if name provided
        var loadedTexture: SKTexture?
        if let name = textureName {
            loadedTexture = WheelNode.loadTexture(named: name)
        }

        if let texture = loadedTexture {
            // Use texture via sprite node
            setupWithTexture(texture)
            isUsingTexture = true
        } else {
            // Fallback to shape drawing
            setupWithShape(color: color)
            isUsingTexture = false
        }

        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupWithTexture(_ texture: SKTexture) {
        let sprite = SKSpriteNode(texture: texture)
        sprite.size = CGSize(width: radius * 2, height: radius * 2)
        addChild(sprite)
        spriteNode = sprite
    }

    private func setupWithShape(color: SKColor) {
        // Draw a circle
        let path = CGMutablePath()
        path.addEllipse(in: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2))

        let shape = SKShapeNode(path: path)
        shape.fillColor = color
        shape.strokeColor = .black
        shape.lineWidth = 2
        addChild(shape)
        shapeNode = shape

        // Add a spoke line to visualize rotation
        let spokePath = CGMutablePath()
        spokePath.move(to: .zero)
        spokePath.addLine(to: CGPoint(x: radius * 0.8, y: 0))
        let spoke = SKShapeNode(path: spokePath)
        spoke.strokeColor = .white
        spoke.lineWidth = 3
        addChild(spoke)
    }

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

    // MARK: - Texture Loading

    /// Attempt to load a texture, returning nil if not found
    private static func loadTexture(named name: String) -> SKTexture? {
        guard UIImage(named: name) != nil else {
            return nil
        }
        return SKTexture(imageNamed: name)
    }

    /// Update the wheel texture at runtime
    func updateTexture(named name: String) {
        if let texture = WheelNode.loadTexture(named: name) {
            // Remove existing visuals
            shapeNode?.removeFromParent()
            shapeNode = nil

            if let sprite = spriteNode {
                sprite.texture = texture
            } else {
                setupWithTexture(texture)
            }
            isUsingTexture = true
        }
    }
}
