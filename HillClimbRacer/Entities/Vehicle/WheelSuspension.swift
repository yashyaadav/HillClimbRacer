//
//  WheelSuspension.swift
//  HillClimbRacer
//
//  Three-joint suspension system:
//  1. Sliding Joint - constrains vertical movement (shock absorber travel)
//  2. Spring Joint - provides elastic suspension behavior
//  3. Pin Joint - attaches wheel to shock post, allows wheel rotation
//

import SpriteKit

/// Represents the complete suspension assembly for one wheel
struct WheelSuspension {

    // MARK: - Properties

    /// The shock absorber post that slides vertically
    let shockPost: SKSpriteNode

    /// Constrains the shock post to move only vertically relative to chassis
    let slideJoint: SKPhysicsJointSliding

    /// Provides the spring/bounce behavior between chassis and wheel
    let springJoint: SKPhysicsJointSpring

    /// Attaches the wheel to the shock post, allowing wheel rotation
    let pinJoint: SKPhysicsJointPin

    /// All joints for easy addition to physics world
    var allJoints: [SKPhysicsJoint] {
        [slideJoint, springJoint, pinJoint]
    }

    // MARK: - Initialization

    /// Creates a suspension system connecting a wheel to a chassis
    /// - Parameters:
    ///   - chassis: The vehicle chassis node
    ///   - wheel: The wheel node to attach
    ///   - attachPoint: Position relative to chassis center where suspension attaches
    ///   - config: Suspension configuration parameters
    init?(chassis: ChassisNode, wheel: WheelNode, attachPoint: CGPoint, config: SuspensionConfig = .default) {
        guard let chassisBody = chassis.physicsBody,
              let wheelBody = wheel.physicsBody else {
            return nil
        }

        // Create the shock post (invisible connector between chassis and wheel)
        let postSize = CGSize(width: 12, height: config.suspensionTravel)
        shockPost = SKSpriteNode(color: .clear, size: postSize)
        shockPost.position = CGPoint(
            x: attachPoint.x,
            y: attachPoint.y - config.suspensionTravel / 2
        )

        // Set up shock post physics
        shockPost.physicsBody = SKPhysicsBody(rectangleOf: postSize)
        shockPost.physicsBody?.categoryBitMask = PhysicsCategory.none
        shockPost.physicsBody?.collisionBitMask = PhysicsCategory.none
        shockPost.physicsBody?.mass = 0.1
        shockPost.physicsBody?.allowsRotation = false

        guard let postBody = shockPost.physicsBody else {
            return nil
        }

        // 1. SLIDING JOINT - Constrains shock post to move only vertically
        slideJoint = SKPhysicsJointSliding.joint(
            withBodyA: chassisBody,
            bodyB: postBody,
            anchor: shockPost.position,
            axis: CGVector(dx: 0, dy: 1)  // Vertical axis only
        )
        slideJoint.shouldEnableLimits = true
        slideJoint.lowerDistanceLimit = config.lowerLimit
        slideJoint.upperDistanceLimit = config.suspensionTravel

        // 2. SPRING JOINT - Provides elastic suspension between chassis and wheel
        let springAnchorOnChassis = CGPoint(
            x: attachPoint.x,
            y: attachPoint.y - 10  // Slightly below attach point
        )
        springJoint = SKPhysicsJointSpring.joint(
            withBodyA: chassisBody,
            bodyB: wheelBody,
            anchorA: springAnchorOnChassis,
            anchorB: wheel.position
        )
        springJoint.frequency = config.frequency  // Hz - higher = stiffer
        springJoint.damping = config.damping      // 0-1 - higher = less bouncy

        // 3. PIN JOINT - Attaches wheel to shock post, allows wheel to rotate
        pinJoint = SKPhysicsJointPin.joint(
            withBodyA: postBody,
            bodyB: wheelBody,
            anchor: wheel.position
        )
    }
}

// MARK: - Suspension Configuration

/// Configuration parameters for suspension behavior
struct SuspensionConfig {
    /// Spring frequency in Hz - higher values = stiffer suspension
    let frequency: CGFloat

    /// Spring damping (0-1) - higher values = less bouncy
    let damping: CGFloat

    /// Total suspension travel distance
    let suspensionTravel: CGFloat

    /// Minimum compression limit
    let lowerLimit: CGFloat

    /// Default configuration with balanced settings
    static let `default` = SuspensionConfig(
        frequency: Constants.Vehicle.suspensionFrequency,
        damping: Constants.Vehicle.suspensionDamping,
        suspensionTravel: Constants.Vehicle.suspensionUpperLimit,
        lowerLimit: Constants.Vehicle.suspensionLowerLimit
    )

    /// Stiffer suspension for rough terrain
    static let stiff = SuspensionConfig(
        frequency: 6.0,
        damping: 0.7,
        suspensionTravel: 50.0,
        lowerLimit: 0.1
    )

    /// Soft suspension for smoother ride
    static let soft = SuspensionConfig(
        frequency: 3.0,
        damping: 0.3,
        suspensionTravel: 80.0,
        lowerLimit: 0.1
    )
}
