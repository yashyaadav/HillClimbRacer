//
//  FuelCanNode.swift
//  HillClimbRacer
//
//  Collectible fuel can that refills the vehicle's fuel tank.
//

import SpriteKit

class FuelCanNode: SKSpriteNode {

    // MARK: - Properties

    static let size = CGSize(width: 30, height: 40)

    /// Amount of fuel this can provides
    let fuelAmount: CGFloat

    // MARK: - Initialization

    init(position: CGPoint, fuelAmount: CGFloat = Constants.Gameplay.fuelCanRefill) {
        self.fuelAmount = fuelAmount

        // Create simple rectangular fuel can
        super.init(texture: nil, color: .red, size: Self.size)

        self.position = position
        zPosition = Constants.ZPosition.collectibles

        addDecoration()
        setupPhysics()
        setupAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func addDecoration() {
        // Add "F" label for fuel
        let label = SKLabelNode(text: "F")
        label.fontName = "Arial-BoldMT"
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        addChild(label)

        // Add cap on top
        let cap = SKSpriteNode(color: .darkGray, size: CGSize(width: 15, height: 8))
        cap.position = CGPoint(x: 0, y: Self.size.height / 2 + 2)
        addChild(cap)
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: Self.size)
        physicsBody?.categoryBitMask = PhysicsCategory.fuelCan
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.chassis

        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
    }

    private func setupAnimation() {
        // Pulsing glow effect
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        run(SKAction.repeatForever(pulse))
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
