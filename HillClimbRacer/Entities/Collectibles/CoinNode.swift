//
//  CoinNode.swift
//  HillClimbRacer
//
//  Collectible coin that awards points when touched by the vehicle.
//
//  Expected texture asset name (for when you add it):
//  - "coin", "coin@2x", "coin@3x"
//

import SpriteKit

class CoinNode: SKNode {

    // MARK: - Properties

    static let radius: CGFloat = 20

    /// Whether this node is using a texture or fallback shape
    private(set) var isUsingTexture: Bool = false

    /// The shape node (used when no texture)
    private var shapeNode: SKShapeNode?

    /// The sprite node (used when texture is available)
    private var spriteNode: SKSpriteNode?

    // MARK: - Initialization

    init(position: CGPoint, textureName: String = "coin") {
        super.init()

        // Try to load texture
        let loadedTexture = CoinNode.loadTexture(named: textureName)

        if let texture = loadedTexture {
            // Use texture via sprite node
            setupWithTexture(texture)
            isUsingTexture = true
        } else {
            // Fallback to shape drawing
            setupWithShape()
            isUsingTexture = false
        }

        self.position = position
        zPosition = Constants.ZPosition.collectibles

        setupPhysics()
        setupAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Visual Setup

    private func setupWithTexture(_ texture: SKTexture) {
        let sprite = SKSpriteNode(texture: texture)
        sprite.size = CGSize(width: Self.radius * 2, height: Self.radius * 2)
        addChild(sprite)
        spriteNode = sprite
    }

    private func setupWithShape() {
        // Create circular coin shape
        let path = CGMutablePath()
        path.addEllipse(in: CGRect(
            x: -Self.radius,
            y: -Self.radius,
            width: Self.radius * 2,
            height: Self.radius * 2
        ))

        let shape = SKShapeNode(path: path)
        shape.fillColor = .yellow
        shape.strokeColor = .orange
        shape.lineWidth = 3
        addChild(shape)
        shapeNode = shape

        // Add dollar sign
        let label = SKLabelNode(text: "$")
        label.fontName = "Arial-BoldMT"
        label.fontSize = 20
        label.fontColor = .orange
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        addChild(label)
    }

    // MARK: - Setup

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: Self.radius)
        physicsBody?.categoryBitMask = PhysicsCategory.coin
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.chassis

        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
    }

    private func setupAnimation() {
        // Gentle float animation
        let moveUp = SKAction.moveBy(x: 0, y: 5, duration: 0.5)
        let moveDown = moveUp.reversed()
        let float = SKAction.sequence([moveUp, moveDown])
        run(SKAction.repeatForever(float))

        // Subtle rotation
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 4)
        run(SKAction.repeatForever(rotate))
    }

    // MARK: - Collection

    /// Animate and remove when collected (float up + fade out pattern from Unity)
    func collect() {
        removeAllActions()

        // Float up + fade out (Unity-style animation)
        let floatUp = SKAction.moveBy(x: 0, y: 50, duration: 0.5)
        floatUp.timingMode = .easeOut
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let group = SKAction.group([floatUp, fadeOut])
        let remove = SKAction.removeFromParent()

        run(SKAction.sequence([group, remove]))
    }

    // MARK: - Texture Loading

    /// Attempt to load a texture, returning nil if not found
    private static func loadTexture(named name: String) -> SKTexture? {
        guard UIImage(named: name) != nil else {
            return nil
        }
        return SKTexture(imageNamed: name)
    }
}
