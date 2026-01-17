//
//  InputManager.swift
//  HillClimbRacer
//
//  Unified input handling for touch controls and accelerometer.
//

import Foundation
import CoreMotion

/// Manages all input sources: touch and accelerometer
class InputManager {

    // MARK: - Singleton

    static let shared = InputManager()

    // MARK: - Properties

    private let motionManager = CMMotionManager()

    /// Current accelerometer Y value (tilt left/right)
    private(set) var accelerometerY: Double = 0

    /// Is accelerometer input enabled?
    private(set) var isAccelerometerEnabled = false

    /// Deadzone for accelerometer to prevent jitter
    private let accelerometerDeadzone: Double = 0.05

    /// Sensitivity multiplier for accelerometer
    var accelerometerSensitivity: Double = 1.0

    // MARK: - Input State

    /// Is the throttle (gas) being pressed?
    var isThrottling = false

    /// Is the brake being pressed?
    var isBraking = false

    // MARK: - Initialization

    private init() {}

    // MARK: - Accelerometer

    /// Start receiving accelerometer updates
    func startAccelerometer() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer not available")
            return
        }

        motionManager.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz

        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else { return }

            // Y-axis corresponds to left/right tilt when phone is in landscape
            var y = data.acceleration.y

            // Apply deadzone
            if abs(y) < self.accelerometerDeadzone {
                y = 0
            }

            // Apply sensitivity
            y *= self.accelerometerSensitivity

            // Clamp to -1...1
            self.accelerometerY = max(-1, min(1, y))
        }

        isAccelerometerEnabled = true
    }

    /// Stop receiving accelerometer updates
    func stopAccelerometer() {
        motionManager.stopAccelerometerUpdates()
        isAccelerometerEnabled = false
        accelerometerY = 0
    }

    // MARK: - Touch Processing

    /// Process a touch at the given screen position
    func processTouch(at normalizedX: CGFloat, began: Bool) {
        // Left half of screen = brake, right half = throttle
        if normalizedX < 0.5 {
            isBraking = began
        } else {
            isThrottling = began
        }
    }

    /// Reset all input states
    func reset() {
        isThrottling = false
        isBraking = false
        accelerometerY = 0
    }
}

// MARK: - Tilt Direction

extension InputManager {

    /// Get the current tilt direction based on accelerometer
    var tiltDirection: TiltDirection {
        if accelerometerY < -0.1 {
            return .left
        } else if accelerometerY > 0.1 {
            return .right
        }
        return .none
    }
}

enum TiltDirection {
    case none
    case left   // Tilt phone left (nose up)
    case right  // Tilt phone right (nose down)
}
