//
//  CoinNode.swift
//  HillClimbRacer
//
//  Collectible coin that awards points when touched by the vehicle.
//  Enhanced with golden shine, sparkle effects, and 3D rotation illusion.
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

    /// Inner highlight for 3D effect
    private var highlightNode: SKShapeNode?

    /// Sparkle emitter
    private var sparkleEmitter: SKEmitterNode?

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
            // Fallback to enhanced shape drawing
            setupWithEnhancedShape()
            isUsingTexture = false
        }

        self.position = position
        zPosition = Constants.ZPosition.collectibles

        setupPhysics()
        setupEnhancedAnimation()
        setupSparkle()
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

    private func setupWithEnhancedShape() {
        // Outer golden ring
        let outerPath = CGMutablePath()
        outerPath.addEllipse(in: CGRect(
            x: -Self.radius,
            y: -Self.radius,
            width: Self.radius * 2,
            height: Self.radius * 2
        ))

        let outerShape = SKShapeNode(path: outerPath)
        outerShape.fillColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)  // Gold
        outerShape.strokeColor = SKColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.0)  // Darker gold
        outerShape.lineWidth = 3
        outerShape.glowWidth = 2
        addChild(outerShape)
        shapeNode = outerShape

        // Inner circle for depth
        let innerPath = CGMutablePath()
        let innerRadius = Self.radius * 0.7
        innerPath.addEllipse(in: CGRect(
            x: -innerRadius,
            y: -innerRadius,
            width: innerRadius * 2,
            height: innerRadius * 2
        ))

        let innerShape = SKShapeNode(path: innerPath)
        innerShape.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.4, alpha: 1.0)  // Lighter gold
        innerShape.strokeColor = SKColor(red: 0.9, green: 0.75, blue: 0.0, alpha: 0.5)
        innerShape.lineWidth = 1
        addChild(innerShape)

        // Highlight/shine effect (top-left arc)
        let highlightPath = CGMutablePath()
        highlightPath.addArc(
            center: CGPoint(x: -Self.radius * 0.3, y: Self.radius * 0.3),
            radius: Self.radius * 0.25,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        )

        let highlight = SKShapeNode(path: highlightPath)
        highlight.fillColor = SKColor.white.withAlphaComponent(0.6)
        highlight.strokeColor = .clear
        addChild(highlight)
        highlightNode = highlight

        // Dollar sign with shadow
        let shadowLabel = SKLabelNode(text: "$")
        shadowLabel.fontName = "Arial-BoldMT"
        shadowLabel.fontSize = 20
        shadowLabel.fontColor = SKColor(red: 0.7, green: 0.5, blue: 0.0, alpha: 0.5)
        shadowLabel.verticalAlignmentMode = .center
        shadowLabel.horizontalAlignmentMode = .center
        shadowLabel.position = CGPoint(x: 1, y: -1)
        addChild(shadowLabel)

        let label = SKLabelNode(text: "$")
        label.fontName = "Arial-BoldMT"
        label.fontSize = 20
        label.fontColor = SKColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.0)
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

    private func setupEnhancedAnimation() {
        // Gentle float animation
        let moveUp = SKAction.moveBy(x: 0, y: 6, duration: 0.6)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = moveUp.reversed()
        let float = SKAction.sequence([moveUp, moveDown])
        run(SKAction.repeatForever(float), withKey: "float")

        // 3D rotation illusion (scale X oscillation)
        let scaleDown = SKAction.scaleX(to: 0.3, duration: 0.4)
        scaleDown.timingMode = .easeInEaseOut
        let scaleUp = SKAction.scaleX(to: 1.0, duration: 0.4)
        scaleUp.timingMode = .easeInEaseOut
        let rotate3D = SKAction.sequence([scaleDown, scaleUp])
        run(SKAction.repeatForever(rotate3D), withKey: "rotate3D")

        // Shine pulse
        if let highlight = highlightNode {
            let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.8)
            let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 0.8)
            let pulse = SKAction.sequence([fadeOut, fadeIn])
            highlight.run(SKAction.repeatForever(pulse))
        }
    }

    private func setupSparkle() {
        // Create occasional sparkle particles around the coin
        let sparkleAction = SKAction.run { [weak self] in
            self?.emitSparkle()
        }
        let wait = SKAction.wait(forDuration: 0.8, withRange: 0.4)
        let sequence = SKAction.sequence([sparkleAction, wait])
        run(SKAction.repeatForever(sequence), withKey: "sparkle")
    }

    private func emitSparkle() {
        let sparkle = SKShapeNode(circleOfRadius: 3)
        sparkle.fillColor = .white
        sparkle.strokeColor = .clear
        sparkle.glowWidth = 2
        sparkle.alpha = 0

        // Random position around coin edge
        let angle = CGFloat.random(in: 0...(.pi * 2))
        let distance = Self.radius * 0.8
        sparkle.position = CGPoint(
            x: cos(angle) * distance,
            y: sin(angle) * distance
        )
        sparkle.zPosition = 1
        addChild(sparkle)

        // Animate sparkle
        let fadeIn = SKAction.fadeIn(withDuration: 0.15)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scale = SKAction.scale(to: 0.2, duration: 0.45)
        let move = SKAction.moveBy(
            x: cos(angle) * 10,
            y: sin(angle) * 10,
            duration: 0.45
        )
        let group = SKAction.group([
            SKAction.sequence([fadeIn, fadeOut]),
            scale,
            move
        ])
        let remove = SKAction.removeFromParent()
        sparkle.run(SKAction.sequence([group, remove]))
    }

    // MARK: - Collection

    /// Animate and remove when collected
    func collect() {
        removeAllActions()

        // Burst of sparkles
        for _ in 0..<8 {
            emitSparkle()
        }

        // Scale up, spin, fade out
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let spin = SKAction.rotate(byAngle: .pi * 2, duration: 0.3)
        let floatUp = SKAction.moveBy(x: 0, y: 60, duration: 0.4)
        floatUp.timingMode = .easeOut
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)

        let group = SKAction.group([
            SKAction.sequence([scaleUp, SKAction.scale(to: 0.5, duration: 0.2)]),
            spin,
            floatUp,
            SKAction.sequence([SKAction.wait(forDuration: 0.1), fadeOut])
        ])
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
