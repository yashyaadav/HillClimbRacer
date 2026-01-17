//
//  GameState.swift
//  HillClimbRacer
//
//  Observable game state for tracking fuel, coins, distance, and game status.
//  Used by SwiftUI views to display current game information.
//

import Foundation
import Combine

/// Current state of the game during gameplay
class GameState: ObservableObject {

    // MARK: - Published Properties

    /// Current fuel level (0-100)
    @Published var fuel: CGFloat = Constants.Gameplay.startingFuel

    /// Coins collected this run
    @Published var coins: Int = 0

    /// Distance traveled in meters
    @Published var distance: CGFloat = 0

    /// Best distance achieved (persisted)
    @Published var bestDistance: CGFloat = 0

    /// Is the game currently paused?
    @Published var isPaused: Bool = false

    /// Has the game ended?
    @Published var isGameOver: Bool = false

    /// Reason for game over
    @Published var gameOverReason: GameOverReason?

    // MARK: - Computed Properties

    /// Integer distance for display
    var displayDistance: Int {
        Int(distance)
    }

    /// Is fuel critically low?
    var isFuelLow: Bool {
        fuel < 25
    }

    /// Is fuel empty?
    var isFuelEmpty: Bool {
        fuel <= 0
    }

    // MARK: - Methods

    /// Reset state for a new game
    func reset() {
        fuel = Constants.Gameplay.startingFuel
        coins = 0
        distance = 0
        isPaused = false
        isGameOver = false
        gameOverReason = nil
    }

    /// Update distance based on player position
    func updateDistance(playerX: CGFloat) {
        let newDistance = playerX * Constants.Gameplay.distanceMultiplier
        if newDistance > distance {
            distance = newDistance

            // Update best distance
            if distance > bestDistance {
                bestDistance = distance
            }
        }
    }

    /// Deplete fuel over time (velocity-based drain - faster driving uses more fuel)
    func consumeFuel(deltaTime: TimeInterval, isThrottling: Bool, velocity: CGFloat = 0) {
        // Base drain rate
        var drain = Constants.Gameplay.fuelDrainRate * CGFloat(deltaTime)

        // Velocity-based drain (Unity pattern) - up to 2x drain at max speed
        let velocityFactor = min(abs(velocity) / 200.0, 1.0)
        drain *= (1.0 + velocityFactor)

        if isThrottling {
            drain *= Constants.Gameplay.throttleFuelMultiplier
        }

        fuel = max(0, fuel - drain)

        if fuel <= 0 {
            triggerGameOver(reason: .outOfFuel)
        }
    }

    /// Add fuel from fuel can pickup
    func addFuel(_ amount: CGFloat = Constants.Gameplay.fuelCanRefill) {
        fuel = min(100, fuel + amount)
    }

    /// Add coins from pickup
    func addCoins(_ amount: Int = Constants.Gameplay.coinValue) {
        coins += amount
    }

    /// Trigger game over state
    func triggerGameOver(reason: GameOverReason) {
        guard !isGameOver else { return }

        isGameOver = true
        gameOverReason = reason
    }
}

// MARK: - Game Over Reasons

enum GameOverReason {
    case outOfFuel
    case vehicleFlipped
    case fellOffWorld

    var displayMessage: String {
        switch self {
        case .outOfFuel:
            return "Out of Fuel!"
        case .vehicleFlipped:
            return "Vehicle Flipped!"
        case .fellOffWorld:
            return "Fell Off World!"
        }
    }
}
