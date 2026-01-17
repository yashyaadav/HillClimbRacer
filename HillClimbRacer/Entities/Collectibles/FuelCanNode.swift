//
//  FuelCanNode.swift
//  HillClimbRacer
//
//  Collectible fuel can that refills the vehicle's fuel tank.
//  Enhanced with detailed can shape, fuel level indicator, and glow effects.
//

import SpriteKit

class FuelCanNode: SKNode {

    // MARK: - Properties

    static let size = CGSize(width: 32, height: 44)

    /// Amount of fuel this can provides
    let fuelAmount: CGFloat

    /// Main body shape
    private var bodyNode: SKShapeNode?

    /// Glow effect node
    private var glowNode: SKShapeNode?

    // MARK: - Initialization

    init(position: CGPoint, fuelAmount: CGFloat = Constants.Gameplay.fuelCanRefill) {
        self.fuelAmount = fuelAmount

        super.init()

        self.position = position
        zPosition = Constants.ZPosition.collectibles

        setupEnhancedVisuals()
        setupPhysics()
        setupEnhancedAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Visual Setup

    private func setupEnhancedVisuals() {
        let width = Self.size.width
        let height = Self.size.height

        // Glow effect (behind everything)
        let glowPath = CGMutablePath()
        glowPath.addRoundedRect(
            in: CGRect(x: -width / 2 - 4, y: -height / 2 - 4, width: width + 8, height: height + 8),
            cornerWidth: 6,
            cornerHeight: 6
        )
        let glow = SKShapeNode(path: glowPath)
        glow.fillColor = SKColor.green.withAlphaComponent(0.3)
        glow.strokeColor = .clear
        glow.zPosition = -1
        addChild(glow)
        glowNode = glow

        // Main body with gradient effect (darker at bottom)
        let bodyPath = CGMutablePath()
        bodyPath.addRoundedRect(
            in: CGRect(x: -width / 2, y: -height / 2, width: width, height: height),
            cornerWidth: 4,
            cornerHeight: 4
        )

        let body = SKShapeNode(path: bodyPath)
        body.fillColor = SKColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0)  // Deep red
        body.strokeColor = SKColor(red: 0.6, green: 0.05, blue: 0.05, alpha: 1.0)  // Darker red border
        body.lineWidth = 2
        addChild(body)
        bodyNode = body

        // Left highlight strip (simulates 3D)
        let highlightPath = CGMutablePath()
        highlightPath.addRoundedRect(
            in: CGRect(x: -width / 2 + 2, y: -height / 2 + 4, width: 6, height: height - 8),
            cornerWidth: 2,
            cornerHeight: 2
        )
        let highlight = SKShapeNode(path: highlightPath)
        highlight.fillColor = SKColor.white.withAlphaComponent(0.3)
        highlight.strokeColor = .clear
        addChild(highlight)

        // Right shadow strip
        let shadowPath = CGMutablePath()
        shadowPath.addRoundedRect(
            in: CGRect(x: width / 2 - 8, y: -height / 2 + 4, width: 6, height: height - 8),
            cornerWidth: 2,
            cornerHeight: 2
        )
        let shadow = SKShapeNode(path: shadowPath)
        shadow.fillColor = SKColor.black.withAlphaComponent(0.2)
        shadow.strokeColor = .clear
        addChild(shadow)

        // Fuel level indicator (green liquid inside)
        let fuelLevelPath = CGMutablePath()
        let fuelHeight = height * 0.6
        fuelLevelPath.addRoundedRect(
            in: CGRect(x: -width / 2 + 4, y: -height / 2 + 4, width: width - 8, height: fuelHeight),
            cornerWidth: 2,
            cornerHeight: 2
        )
        let fuelLevel = SKShapeNode(path: fuelLevelPath)
        fuelLevel.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 0.8)  // Green fuel
        fuelLevel.strokeColor = .clear
        addChild(fuelLevel)

        // Cap on top
        let capWidth: CGFloat = 14
        let capHeight: CGFloat = 10
        let capPath = CGMutablePath()
        capPath.addRoundedRect(
            in: CGRect(x: -capWidth / 2, y: height / 2 - 2, width: capWidth, height: capHeight),
            cornerWidth: 2,
            cornerHeight: 2
        )
        let cap = SKShapeNode(path: capPath)
        cap.fillColor = SKColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)  // Dark gray
        cap.strokeColor = SKColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        cap.lineWidth = 1
        addChild(cap)

        // Cap highlight
        let capHighlight = SKShapeNode(rectOf: CGSize(width: capWidth - 4, height: 2))
        capHighlight.position = CGPoint(x: 0, y: height / 2 + capHeight - 5)
        capHighlight.fillColor = SKColor.white.withAlphaComponent(0.3)
        capHighlight.strokeColor = .clear
        addChild(capHighlight)

        // Handle on the side
        let handlePath = CGMutablePath()
        handlePath.move(to: CGPoint(x: width / 2, y: height / 4))
        handlePath.addCurve(
            to: CGPoint(x: width / 2, y: -height / 6),
            control1: CGPoint(x: width / 2 + 10, y: height / 4),
            control2: CGPoint(x: width / 2 + 10, y: -height / 6)
        )
        let handle = SKShapeNode(path: handlePath)
        handle.strokeColor = SKColor(red: 0.6, green: 0.05, blue: 0.05, alpha: 1.0)
        handle.lineWidth = 4
        handle.lineCap = .round
        addChild(handle)

        // "FUEL" label
        let label = SKLabelNode(text: "F")
        label.fontName = "Arial-BoldMT"
        label.fontSize = 16
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 5)
        addChild(label)

        // Small plus sign to indicate refill
        let plusLabel = SKLabelNode(text: "+")
        plusLabel.fontName = "Arial-BoldMT"
        plusLabel.fontSize = 12
        plusLabel.fontColor = SKColor.green
        plusLabel.verticalAlignmentMode = .center
        plusLabel.horizontalAlignmentMode = .center
        plusLabel.position = CGPoint(x: 8, y: 12)
        addChild(plusLabel)
    }

    // MARK: - Physics

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: Self.size)
        physicsBody?.categoryBitMask = PhysicsCategory.fuelCan
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.chassis

        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
    }

    // MARK: - Animation

    private func setupEnhancedAnimation() {
        // Gentle hover animation
        let moveUp = SKAction.moveBy(x: 0, y: 5, duration: 0.7)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = moveUp.reversed()
        let hover = SKAction.sequence([moveUp, moveDown])
        run(SKAction.repeatForever(hover), withKey: "hover")

        // Pulsing glow effect
        if let glow = glowNode {
            let glowUp = SKAction.group([
                SKAction.fadeAlpha(to: 0.5, duration: 0.5),
                SKAction.scale(to: 1.1, duration: 0.5)
            ])
            let glowDown = SKAction.group([
                SKAction.fadeAlpha(to: 0.2, duration: 0.5),
                SKAction.scale(to: 1.0, duration: 0.5)
            ])
            let pulse = SKAction.sequence([glowUp, glowDown])
            glow.run(SKAction.repeatForever(pulse))
        }

        // Subtle rotation wobble
        let rotateLeft = SKAction.rotate(toAngle: -0.05, duration: 1.0)
        rotateLeft.timingMode = .easeInEaseOut
        let rotateRight = SKAction.rotate(toAngle: 0.05, duration: 1.0)
        rotateRight.timingMode = .easeInEaseOut
        let wobble = SKAction.sequence([rotateLeft, rotateRight])
        run(SKAction.repeatForever(wobble), withKey: "wobble")
    }

    // MARK: - Collection

    /// Animate and remove when collected
    func collect() {
        removeAllActions()

        // Green particles burst
        emitFuelParticles()

        // Scale up with shake, then float up and fade
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.15)
        let shake1 = SKAction.rotate(byAngle: 0.1, duration: 0.05)
        let shake2 = SKAction.rotate(byAngle: -0.2, duration: 0.1)
        let shake3 = SKAction.rotate(byAngle: 0.1, duration: 0.05)
        let shakeSequence = SKAction.sequence([shake1, shake2, shake3])

        let floatUp = SKAction.moveBy(x: 0, y: 60, duration: 0.4)
        floatUp.timingMode = .easeOut
        let fadeOut = SKAction.fadeOut(withDuration: 0.35)
        let scaleDown = SKAction.scale(to: 0.6, duration: 0.4)

        let group = SKAction.group([
            SKAction.sequence([scaleUp, shakeSequence]),
            SKAction.sequence([SKAction.wait(forDuration: 0.2), floatUp]),
            SKAction.sequence([SKAction.wait(forDuration: 0.1), fadeOut]),
            SKAction.sequence([SKAction.wait(forDuration: 0.2), scaleDown])
        ])
        let remove = SKAction.removeFromParent()

        run(SKAction.sequence([group, remove]))
    }

    private func emitFuelParticles() {
        for _ in 0..<12 {
            let particle = SKShapeNode(circleOfRadius: 4)
            particle.fillColor = SKColor(red: 0.2, green: 0.9, blue: 0.3, alpha: 1.0)
            particle.strokeColor = .clear
            particle.glowWidth = 2
            particle.zPosition = 2
            addChild(particle)

            // Random direction
            let angle = CGFloat.random(in: 0...(.pi * 2))
            let speed = CGFloat.random(in: 30...60)
            let distance = speed * 0.5

            let move = SKAction.moveBy(
                x: cos(angle) * distance,
                y: sin(angle) * distance,
                duration: 0.5
            )
            move.timingMode = .easeOut

            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let scale = SKAction.scale(to: 0.2, duration: 0.5)
            let group = SKAction.group([move, fadeOut, scale])
            let remove = SKAction.removeFromParent()

            particle.run(SKAction.sequence([group, remove]))
        }
    }
}
