//
//  CoinNode.swift
//  HillClimbRacer
//
//  Collectible coin that awards points when touched by the vehicle.
//

import SpriteKit

class CoinNode: SKShapeNode {

    // MARK: - Properties

    static let radius: CGFloat = 20

    // MARK: - Initialization

    init(position: CGPoint) {
        super.init()

        // Create circular coin shape
        let path = CGMutablePath()
        path.addEllipse(in: CGRect(
            x: -Self.radius,
            y: -Self.radius,
            width: Self.radius * 2,
            height: Self.radius * 2
        ))
        self.path = path

        // Golden appearance
        fillColor = .yellow
        strokeColor = .orange
        lineWidth = 3

        // Add dollar sign
        let label = SKLabelNode(text: "$")
        label.fontName = "Arial-BoldMT"
        label.fontSize = 20
        label.fontColor = .orange
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        addChild(label)

        self.position = position
        zPosition = Constants.ZPosition.collectibles

        setupPhysics()
        setupAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}
