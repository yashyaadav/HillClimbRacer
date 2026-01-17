//
//  Vehicle.swift
//  HillClimbRacer
//
//  Container for the complete vehicle: chassis, wheels, and suspension joints.
//  Uses impulse-based movement for physics-driven gameplay.
//

import SpriteKit

class Vehicle: SKNode {

    // MARK: - Properties

    /// The main body of the vehicle
    let chassis: ChassisNode

    /// Front and rear wheels
    let frontWheel: WheelNode
    let rearWheel: WheelNode

    /// Front and rear suspension systems
    private let frontSuspension: WheelSuspension
    private let rearSuspension: WheelSuspension

    /// The vehicle configuration
    let config: VehicleConfig

    /// All physics joints that need to be added to the physics world
    var allJoints: [SKPhysicsJoint] {
        frontSuspension.allJoints + rearSuspension.allJoints
    }

    // MARK: - Engine Configuration

    private let forwardPower: CGFloat
    private let backwardPower: CGFloat
    private let maxForwardSpeed: CGFloat
    private let maxBackwardSpeed: CGFloat
    private let tiltForce: CGFloat

    // MARK: - Initialization

    /// Initialize vehicle with a VehicleConfig
    convenience init(position: CGPoint, config: VehicleConfig) {
        self.init(
            position: position,
            config: config,
            chassisSize: config.chassisSize,
            wheelRadius: config.wheelRadius,
            wheelBase: config.wheelBase,
            suspensionConfig: config.suspensionConfig,
            chassisColor: config.chassisColor.skColor,
            wheelColor: config.wheelColor.skColor,
            enginePower: config.enginePower,
            maxSpeed: config.maxSpeed,
            tiltForce: config.tiltForce
        )
    }

    /// Initialize with default configuration (backwards compatibility)
    convenience init(
        position: CGPoint,
        chassisSize: CGSize = CGSize(width: 200, height: 60),
        wheelRadius: CGFloat = 30,
        wheelBase: CGFloat = 140,
        suspensionConfig: SuspensionConfig = .default
    ) {
        self.init(
            position: position,
            config: VehicleDefinitions.defaultVehicle,
            chassisSize: chassisSize,
            wheelRadius: wheelRadius,
            wheelBase: wheelBase,
            suspensionConfig: suspensionConfig,
            chassisColor: .red,
            wheelColor: .darkGray,
            enginePower: Constants.Vehicle.forwardPower,
            maxSpeed: Constants.Vehicle.maxForwardSpeed,
            tiltForce: Constants.Vehicle.tiltForce
        )
    }

    /// Full initializer with all parameters
    private init(
        position: CGPoint,
        config: VehicleConfig,
        chassisSize: CGSize,
        wheelRadius: CGFloat,
        wheelBase: CGFloat,
        suspensionConfig: SuspensionConfig,
        chassisColor: SKColor,
        wheelColor: SKColor,
        enginePower: CGFloat,
        maxSpeed: CGFloat,
        tiltForce: CGFloat
    ) {
        self.config = config

        // Create chassis
        chassis = ChassisNode(size: chassisSize, color: chassisColor)
        chassis.position = position

        // Calculate wheel positions relative to chassis
        let wheelY = position.y - chassisSize.height / 2 - wheelRadius - 20
        let frontWheelPos = CGPoint(x: position.x + wheelBase / 2, y: wheelY)
        let rearWheelPos = CGPoint(x: position.x - wheelBase / 2, y: wheelY)

        // Create wheels
        frontWheel = WheelNode(radius: wheelRadius, color: wheelColor, isBreakable: false)
        frontWheel.position = frontWheelPos

        rearWheel = WheelNode(radius: wheelRadius, color: wheelColor, isBreakable: true)
        rearWheel.position = rearWheelPos

        // Suspension attach points (where suspension connects to chassis)
        let frontAttach = CGPoint(x: wheelBase / 2, y: -chassisSize.height / 2)
        let rearAttach = CGPoint(x: -wheelBase / 2, y: -chassisSize.height / 2)

        // Create suspension systems
        guard let front = WheelSuspension(
            chassis: chassis,
            wheel: frontWheel,
            attachPoint: frontAttach,
            config: suspensionConfig
        ),
        let rear = WheelSuspension(
            chassis: chassis,
            wheel: rearWheel,
            attachPoint: rearAttach,
            config: suspensionConfig
        ) else {
            fatalError("Failed to create suspension systems")
        }

        frontSuspension = front
        rearSuspension = rear

        // Engine configuration from parameters
        self.forwardPower = enginePower
        self.backwardPower = -enginePower * 0.3  // Backward is 30% of forward
        self.maxForwardSpeed = maxSpeed
        self.maxBackwardSpeed = -maxSpeed * 0.6  // Max backward is 60% of forward
        self.tiltForce = tiltForce

        super.init()

        // Add all nodes as children
        addChild(chassis)
        addChild(frontWheel)
        addChild(rearWheel)
        addChild(frontSuspension.shockPost)
        addChild(rearSuspension.shockPost)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Movement Controls

    /// Apply forward thrust to the wheels
    func moveForward() {
        let chassisAngle = chassis.zRotation.toDegrees

        // Only apply thrust when vehicle isn't flipped too far
        guard chassisAngle > -Constants.Vehicle.maxTiltAngle,
              chassisAngle < Constants.Vehicle.maxTiltAngle else {
            return
        }

        let impulse = CGVector(dx: forwardPower, dy: 0)
        let angularImpulse: CGFloat = -0.01  // Spin wheels forward

        applyToWheels(impulse: impulse, angularImpulse: angularImpulse)
        limitSpeed()
    }

    /// Apply reverse thrust to the wheels
    func moveBackward() {
        let chassisAngle = chassis.zRotation.toDegrees

        guard chassisAngle > -Constants.Vehicle.maxTiltAngle,
              chassisAngle < Constants.Vehicle.maxTiltAngle else {
            return
        }

        let impulse = CGVector(dx: backwardPower, dy: 0)
        let angularImpulse: CGFloat = 0.01  // Spin wheels backward

        applyToWheels(impulse: impulse, angularImpulse: angularImpulse)
        limitSpeed()
    }

    /// Apply brakes to stop the vehicle
    func applyBrake() {
        // Only brake the rear wheel (like a real vehicle)
        if rearWheel.isBreakable {
            rearWheel.physicsBody?.angularVelocity = 0
            rearWheel.physicsBody?.velocity = .zero
        }
    }

    /// Tilt the vehicle left (nose up) - used for mid-air control
    func tiltLeft() {
        let point = CGPoint(
            x: -(chassis.size.width / 2 - 60),
            y: chassis.size.height / 4
        )
        applyTilt(at: point)
    }

    /// Tilt the vehicle right (nose down) - used for mid-air control
    func tiltRight() {
        let point = CGPoint(
            x: chassis.size.width / 2 - 60,
            y: chassis.size.height / 4
        )
        applyTilt(at: point)
    }

    // MARK: - Private Methods

    private func applyToWheels(impulse: CGVector, angularImpulse: CGFloat) {
        for wheel in [frontWheel, rearWheel] {
            wheel.physicsBody?.applyImpulse(impulse)
            wheel.physicsBody?.applyAngularImpulse(angularImpulse)
        }
    }

    private func limitSpeed() {
        for wheel in [frontWheel, rearWheel] {
            guard let velocity = wheel.physicsBody?.velocity else { continue }

            // Limit forward speed
            if velocity.dx > maxForwardSpeed {
                wheel.physicsBody?.velocity.dx = maxForwardSpeed
            }

            // Limit backward speed
            if velocity.dx < maxBackwardSpeed {
                wheel.physicsBody?.velocity.dx = maxBackwardSpeed
            }
        }
    }

    private func applyTilt(at localPoint: CGPoint) {
        // Convert local point to scene coordinates
        let convertedPoint = chassis.convert(localPoint, to: self)

        // Calculate force direction perpendicular to chassis
        let angle = chassis.zRotation - .pi / 2
        let forceX = cos(angle) * tiltForce
        let forceY = sin(angle) * tiltForce

        chassis.physicsBody?.applyForce(
            CGVector(dx: forceX, dy: forceY),
            at: convertedPoint
        )
    }
}

// MARK: - Angle Conversion Extension

extension CGFloat {
    /// Convert radians to degrees
    var toDegrees: CGFloat {
        self * 180.0 / .pi
    }

    /// Convert degrees to radians
    var toRadians: CGFloat {
        self * .pi / 180.0
    }
}
