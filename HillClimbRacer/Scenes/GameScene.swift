//
//  GameScene.swift
//  HillClimbRacer
//
//  Main gameplay scene - handles physics world setup, vehicle creation,
//  terrain, input handling, and camera following.
//

import SpriteKit

class GameScene: SKScene {

    // MARK: - Properties

    /// The player's vehicle
    private var vehicle: Vehicle!

    /// Camera node for following the vehicle
    private var cameraNode: SKCameraNode!

    /// Terrain manager for infinite terrain
    private(set) var terrainManager: TerrainManager!

    /// Reference to game manager
    private let gameManager = GameManager.shared

    /// Reference to input manager
    private let inputManager = InputManager.shared

    // MARK: - Input State

    private var isThrottling = false
    private var isBraking = false
    private var isTiltingLeft = false
    private var isTiltingRight = false

    // MARK: - Sky Color Animation

    private var currentSkyColor: SKColor?
    private var targetSkyColor: SKColor?

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
    }

    // MARK: - Setup

    private func setupScene() {
        setupPhysicsWorld()
        setupCamera()
        setupTerrain()

        // Set initial sky color from biome
        currentSkyColor = terrainManager.currentBiome.skyColor
        backgroundColor = currentSkyColor ?? SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)

        setupVehicle()
        setupCameraConstraints()
        setupGameManager()
    }

    private func setupPhysicsWorld() {
        physicsWorld.gravity = CGVector(dx: 0, dy: Constants.gravity)
        physicsWorld.contactDelegate = self
    }

    private func setupCamera() {
        cameraNode = SKCameraNode()
        addChild(cameraNode)
        camera = cameraNode

        // Adjust zoom for device type
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            cameraNode.xScale = Constants.Camera.phoneZoom
            cameraNode.yScale = Constants.Camera.phoneZoom
        }
        #endif
    }

    private func setupTerrain() {
        terrainManager = TerrainManager(scene: self)
        terrainManager.generateInitialTerrain()
    }

    private func setupVehicle() {
        // Spawn vehicle above the terrain start
        let spawnPosition = CGPoint(x: 200, y: Constants.Terrain.baseHeight + 150)

        vehicle = Vehicle(position: spawnPosition)
        addChild(vehicle)

        // Add all vehicle joints to the physics world
        for joint in vehicle.allJoints {
            physicsWorld.add(joint)
        }
    }

    private func setupCameraConstraints() {
        // Make camera follow the vehicle chassis with some lead distance
        let zeroDistance = SKRange(constantValue: 0)
        let followConstraint = SKConstraint.distance(zeroDistance, to: vehicle.chassis)
        cameraNode.constraints = [followConstraint]
    }

    private func setupGameManager() {
        gameManager.configure(scene: self, terrainManager: terrainManager)
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        // Handle accelerometer tilt
        handleAccelerometerInput()

        // Handle continuous input
        if isThrottling || inputManager.isThrottling {
            vehicle.moveForward()
        }
        if isBraking || inputManager.isBraking {
            vehicle.applyBrake()
        }
        if isTiltingLeft {
            vehicle.tiltLeft()
        }
        if isTiltingRight {
            vehicle.tiltRight()
        }

        // Update terrain chunks based on vehicle position
        terrainManager.update(playerX: vehicle.chassis.position.x)

        // Safety check: force terrain generation if player is approaching edge
        if vehicle.chassis.position.x > terrainManager.lastGeneratedX - 800 {
            terrainManager.update(playerX: vehicle.chassis.position.x + 1000)
        }

        // Update sky color based on biome transitions
        updateSkyColor()

        // Update game manager (pass velocity for fuel consumption and speed calculation)
        let velocityX = vehicle.chassis.physicsBody?.velocity.dx ?? 0
        let velocityY = vehicle.chassis.physicsBody?.velocity.dy ?? 0
        gameManager.update(
            currentTime: currentTime,
            playerX: vehicle.chassis.position.x,
            isThrottling: isThrottling || inputManager.isThrottling,
            velocity: velocityX,
            velocityY: velocityY
        )

        // Check game over conditions
        checkGameOverConditions()
    }

    // MARK: - Game Over Checks

    private func checkGameOverConditions() {
        // Check if vehicle is flipped
        gameManager.checkVehicleFlipped(rotation: vehicle.chassis.zRotation)

        // Check if vehicle fell off the world
        gameManager.checkFellOffWorld(y: vehicle.chassis.position.y)
    }

    // MARK: - Sky Color Updates

    private func updateSkyColor() {
        let playerX = vehicle.chassis.position.x
        let newSkyColor = terrainManager.currentSkyColor(at: playerX)

        // Smoothly transition sky color
        if currentSkyColor != newSkyColor {
            targetSkyColor = newSkyColor

            // Animate sky color change
            let colorAction = SKAction.customAction(withDuration: 0.5) { [weak self] _, elapsedTime in
                guard let self = self,
                      let current = self.currentSkyColor,
                      let target = self.targetSkyColor else { return }

                let progress = elapsedTime / 0.5
                let interpolated = self.interpolateColor(from: current, to: target, t: progress)
                self.backgroundColor = interpolated
            }

            run(colorAction) { [weak self] in
                self?.currentSkyColor = self?.targetSkyColor
            }
        }
    }

    private func interpolateColor(from: SKColor, to: SKColor, t: CGFloat) -> SKColor {
        var fromR: CGFloat = 0, fromG: CGFloat = 0, fromB: CGFloat = 0, fromA: CGFloat = 0
        var toR: CGFloat = 0, toG: CGFloat = 0, toB: CGFloat = 0, toA: CGFloat = 0

        from.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
        to.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)

        let r = fromR + (toR - fromR) * t
        let g = fromG + (toG - fromG) * t
        let b = fromB + (toB - fromB) * t
        let a = fromA + (toA - fromA) * t

        return SKColor(red: r, green: g, blue: b, alpha: a)
    }

    // MARK: - Accelerometer

    private func handleAccelerometerInput() {
        switch inputManager.tiltDirection {
        case .left:
            isTiltingLeft = true
            isTiltingRight = false
        case .right:
            isTiltingLeft = false
            isTiltingRight = true
        case .none:
            // Only clear if no keyboard/button input
            if !isTiltingLeft && !isTiltingRight {
                isTiltingLeft = false
                isTiltingRight = false
            }
        }
    }
}

// MARK: - Touch Input (iOS)

#if os(iOS)
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            handleTouch(touch, isPressed: true)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Could handle drag gestures here
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            handleTouch(touch, isPressed: false)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Reset all inputs on cancel
        isThrottling = false
        isBraking = false
        isTiltingLeft = false
        isTiltingRight = false
        inputManager.reset()
    }

    private func handleTouch(_ touch: UITouch, isPressed: Bool) {
        let location = touch.location(in: view)
        guard let viewSize = view?.bounds.size else { return }

        let halfWidth = viewSize.width / 2

        // Left side of screen = brake, right side = throttle
        if location.x < halfWidth {
            isBraking = isPressed
        } else {
            isThrottling = isPressed
        }

        // Also update input manager
        inputManager.processTouch(at: location.x / viewSize.width, began: isPressed)
    }
}
#endif

// MARK: - Keyboard Input (macOS)

#if os(macOS)
extension GameScene {

    override func keyDown(with event: NSEvent) {
        handleKey(event.keyCode, isPressed: true)
    }

    override func keyUp(with event: NSEvent) {
        handleKey(event.keyCode, isPressed: false)
    }

    private func handleKey(_ keyCode: UInt16, isPressed: Bool) {
        switch keyCode {
        case 123: // Left arrow
            isBraking = isPressed
        case 124: // Right arrow
            isThrottling = isPressed
        case 126: // Up arrow
            isTiltingLeft = isPressed
        case 125: // Down arrow
            isTiltingRight = isPressed
        default:
            break
        }
    }
}
#endif

// MARK: - Physics Contact Delegate

extension GameScene: SKPhysicsContactDelegate {

    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        // Handle coin collection
        if collision == PhysicsCategory.chassis | PhysicsCategory.coin {
            handleCoinCollection(contact)
        }

        // Handle fuel can collection
        if collision == PhysicsCategory.chassis | PhysicsCategory.fuelCan {
            handleFuelCollection(contact)
        }
    }

    private func handleCoinCollection(_ contact: SKPhysicsContact) {
        let coinNode: SKNode?
        if contact.bodyA.categoryBitMask == PhysicsCategory.coin {
            coinNode = contact.bodyA.node
        } else {
            coinNode = contact.bodyB.node
        }

        guard let coin = coinNode as? CoinNode else { return }

        // Update game state
        gameManager.collectCoin()

        // Play collection animation and remove
        coin.collect()

        // Play sound
        AudioManager.shared.playSound(.coinCollect, in: self)
    }

    private func handleFuelCollection(_ contact: SKPhysicsContact) {
        let fuelNode: SKNode?
        if contact.bodyA.categoryBitMask == PhysicsCategory.fuelCan {
            fuelNode = contact.bodyA.node
        } else {
            fuelNode = contact.bodyB.node
        }

        guard let fuelCan = fuelNode as? FuelCanNode else { return }

        // Update game state
        gameManager.collectFuel(amount: fuelCan.fuelAmount)

        // Play collection animation and remove
        fuelCan.collect()

        // Play sound
        AudioManager.shared.playSound(.fuelCollect, in: self)
    }
}
