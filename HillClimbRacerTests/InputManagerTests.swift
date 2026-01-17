//
//  InputManagerTests.swift
//  HillClimbRacerTests
//
//  Unit tests for InputManager.
//

import XCTest
@testable import HillClimbRacer

final class InputManagerTests: XCTestCase {

    var inputManager: InputManager!

    override func setUpWithError() throws {
        inputManager = InputManager.shared
        inputManager.reset()
    }

    override func tearDownWithError() throws {
        inputManager.reset()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        inputManager.reset()

        XCTAssertFalse(inputManager.isThrottling, "Initially should not be throttling")
        XCTAssertFalse(inputManager.isBraking, "Initially should not be braking")
        XCTAssertEqual(inputManager.accelerometerY, 0, "Initially accelerometer Y should be 0")
    }

    // MARK: - Touch Processing Tests

    func testTouchLeftSideActivatesBrake() {
        inputManager.processTouch(at: 0.25, began: true)

        XCTAssertTrue(inputManager.isBraking, "Left side touch should activate brake")
        XCTAssertFalse(inputManager.isThrottling, "Left side touch should not activate throttle")
    }

    func testTouchRightSideActivatesThrottle() {
        inputManager.processTouch(at: 0.75, began: true)

        XCTAssertTrue(inputManager.isThrottling, "Right side touch should activate throttle")
        XCTAssertFalse(inputManager.isBraking, "Right side touch should not activate brake")
    }

    func testTouchMiddleActivatesThrottle() {
        // 0.5 is on the right side (>= 0.5)
        inputManager.processTouch(at: 0.5, began: true)

        XCTAssertTrue(inputManager.isThrottling, "Middle touch (0.5) should activate throttle")
    }

    func testTouchReleaseDeactivatesControls() {
        // Press throttle
        inputManager.processTouch(at: 0.75, began: true)
        XCTAssertTrue(inputManager.isThrottling)

        // Release
        inputManager.processTouch(at: 0.75, began: false)
        XCTAssertFalse(inputManager.isThrottling, "Releasing touch should deactivate throttle")
    }

    func testTouchBoundaries() {
        // Just under 0.5 (left side)
        inputManager.reset()
        inputManager.processTouch(at: 0.49, began: true)
        XCTAssertTrue(inputManager.isBraking, "0.49 should be left side (brake)")
        XCTAssertFalse(inputManager.isThrottling)

        // Exactly 0.5 (right side)
        inputManager.reset()
        inputManager.processTouch(at: 0.50, began: true)
        XCTAssertTrue(inputManager.isThrottling, "0.50 should be right side (throttle)")
        XCTAssertFalse(inputManager.isBraking)
    }

    func testEdgeTouches() {
        // Left edge
        inputManager.reset()
        inputManager.processTouch(at: 0.0, began: true)
        XCTAssertTrue(inputManager.isBraking, "Left edge (0.0) should be brake")

        // Right edge
        inputManager.reset()
        inputManager.processTouch(at: 1.0, began: true)
        XCTAssertTrue(inputManager.isThrottling, "Right edge (1.0) should be throttle")
    }

    // MARK: - Direct State Setting Tests

    func testDirectThrottleSetting() {
        inputManager.isThrottling = true
        XCTAssertTrue(inputManager.isThrottling)

        inputManager.isThrottling = false
        XCTAssertFalse(inputManager.isThrottling)
    }

    func testDirectBrakeSetting() {
        inputManager.isBraking = true
        XCTAssertTrue(inputManager.isBraking)

        inputManager.isBraking = false
        XCTAssertFalse(inputManager.isBraking)
    }

    // MARK: - Reset Tests

    func testReset() {
        // Set some state
        inputManager.isThrottling = true
        inputManager.isBraking = true

        // Reset
        inputManager.reset()

        XCTAssertFalse(inputManager.isThrottling, "Reset should clear throttling")
        XCTAssertFalse(inputManager.isBraking, "Reset should clear braking")
        XCTAssertEqual(inputManager.accelerometerY, 0, "Reset should clear accelerometer Y")
    }

    // MARK: - Tilt Direction Tests

    func testTiltDirectionNone() {
        // When accelerometerY is near 0, direction should be none
        // Note: We can't directly set accelerometerY, but after reset it should be 0
        inputManager.reset()

        XCTAssertEqual(inputManager.tiltDirection, .none, "Near-zero accelerometer should give none direction")
    }

    // MARK: - Sensitivity Tests

    func testDefaultSensitivity() {
        XCTAssertEqual(inputManager.accelerometerSensitivity, 1.0, "Default sensitivity should be 1.0")
    }

    func testSensitivityCanBeChanged() {
        inputManager.accelerometerSensitivity = 1.5
        XCTAssertEqual(inputManager.accelerometerSensitivity, 1.5)

        inputManager.accelerometerSensitivity = 0.5
        XCTAssertEqual(inputManager.accelerometerSensitivity, 0.5)
    }

    // MARK: - Singleton Tests

    func testSingletonInstance() {
        let instance1 = InputManager.shared
        let instance2 = InputManager.shared

        XCTAssertTrue(instance1 === instance2, "Should return same instance")
    }

    // MARK: - Concurrent Input Tests

    func testSimultaneousThrottleAndBrake() {
        // In real scenarios, both could be pressed at once (one on each side)
        inputManager.processTouch(at: 0.25, began: true)  // Brake
        inputManager.processTouch(at: 0.75, began: true)  // Throttle

        // Both should be active
        XCTAssertTrue(inputManager.isBraking)
        XCTAssertTrue(inputManager.isThrottling)
    }

    func testRapidToggle() {
        // Rapidly toggle throttle
        for _ in 0..<10 {
            inputManager.processTouch(at: 0.75, began: true)
            XCTAssertTrue(inputManager.isThrottling)

            inputManager.processTouch(at: 0.75, began: false)
            XCTAssertFalse(inputManager.isThrottling)
        }
    }

    // MARK: - Accelerometer State Tests

    func testAccelerometerInitiallyDisabled() {
        XCTAssertFalse(inputManager.isAccelerometerEnabled, "Accelerometer should be disabled initially")
    }

    // Note: We can't easily test actual accelerometer functionality in unit tests
    // as it requires device hardware. The following tests what we can.

    func testAccelerometerYInitialValue() {
        inputManager.reset()
        XCTAssertEqual(inputManager.accelerometerY, 0, "Accelerometer Y should be 0 after reset")
    }
}

// MARK: - TiltDirection Tests

final class TiltDirectionTests: XCTestCase {

    func testTiltDirectionCases() {
        // Verify all cases exist
        let none = TiltDirection.none
        let left = TiltDirection.left
        let right = TiltDirection.right

        XCTAssertNotNil(none)
        XCTAssertNotNil(left)
        XCTAssertNotNil(right)
    }
}
