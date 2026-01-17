//
//  Level.swift
//  HillClimbRacer
//
//  Defines a game level with biome, length, difficulty, and progression.
//

import Foundation

/// Represents a playable level in the game
struct Level: Identifiable, Equatable {

    // MARK: - Properties

    /// Unique identifier for this level
    let id: String

    /// Display name for the level
    let name: String

    /// Description of the level
    let description: String

    /// The biome this level uses (nil for endless mode with transitions)
    let biome: Biome?

    /// Target distance to complete the level (nil for endless mode)
    let targetDistance: CGFloat?

    /// Unlock cost in coins (0 = free)
    let unlockCost: Int

    /// Difficulty rating (1-5)
    let difficulty: Int

    /// Whether this is the endless/adventure mode
    let isEndless: Bool

    // MARK: - Star Thresholds

    /// Distance thresholds for earning stars (1, 2, 3 stars)
    let starThresholds: StarThresholds

    // MARK: - Computed Properties

    /// Is this level free to play?
    var isFree: Bool {
        unlockCost == 0
    }

    /// Display string for target distance
    var targetDistanceDisplay: String {
        if let target = targetDistance {
            return "\(Int(target))m"
        }
        return "Endless"
    }

    /// Display string for difficulty
    var difficultyDisplay: String {
        String(repeating: "*", count: difficulty)
    }

    // MARK: - Initialization

    init(
        id: String,
        name: String,
        description: String,
        biome: Biome?,
        targetDistance: CGFloat?,
        unlockCost: Int = 0,
        difficulty: Int = 1,
        isEndless: Bool = false,
        starThresholds: StarThresholds = StarThresholds.default
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.biome = biome
        self.targetDistance = targetDistance
        self.unlockCost = unlockCost
        self.difficulty = max(1, min(5, difficulty))
        self.isEndless = isEndless
        self.starThresholds = starThresholds
    }

    // MARK: - Star Calculation

    /// Calculate stars earned for a given distance
    func starsEarned(for distance: CGFloat) -> Int {
        if distance >= starThresholds.threeStar {
            return 3
        } else if distance >= starThresholds.twoStar {
            return 2
        } else if distance >= starThresholds.oneStar {
            return 1
        }
        return 0
    }

    /// Check if level is completed (reached target distance)
    func isCompleted(distance: CGFloat) -> Bool {
        guard let target = targetDistance else {
            return false  // Endless mode is never "completed"
        }
        return distance >= target
    }

    // MARK: - Equatable

    static func == (lhs: Level, rhs: Level) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Star Thresholds

struct StarThresholds {
    let oneStar: CGFloat
    let twoStar: CGFloat
    let threeStar: CGFloat

    static let `default` = StarThresholds(
        oneStar: 500,
        twoStar: 1000,
        threeStar: 1500
    )

    init(oneStar: CGFloat, twoStar: CGFloat, threeStar: CGFloat) {
        self.oneStar = oneStar
        self.twoStar = twoStar
        self.threeStar = threeStar
    }

    /// Create thresholds based on target distance
    static func forTarget(_ target: CGFloat) -> StarThresholds {
        StarThresholds(
            oneStar: target * 0.5,
            twoStar: target * 0.75,
            threeStar: target
        )
    }
}

// MARK: - Level Progress

/// Tracks player progress on a specific level
struct LevelProgress: Codable, Equatable {
    let levelId: String
    var isUnlocked: Bool
    var isCompleted: Bool
    var bestDistance: CGFloat
    var starsEarned: Int
    var timesPlayed: Int

    init(levelId: String, isUnlocked: Bool = false) {
        self.levelId = levelId
        self.isUnlocked = isUnlocked
        self.isCompleted = false
        self.bestDistance = 0
        self.starsEarned = 0
        self.timesPlayed = 0
    }

    mutating func update(distance: CGFloat, stars: Int) {
        if distance > bestDistance {
            bestDistance = distance
        }
        if stars > starsEarned {
            starsEarned = stars
        }
        timesPlayed += 1
    }
}

// MARK: - Level Result

/// Result of completing/ending a level run
struct LevelResult {
    let level: Level
    let distance: CGFloat
    let coins: Int
    let starsEarned: Int
    let isNewRecord: Bool
    let isLevelComplete: Bool

    /// Bonus coins for completing level
    var completionBonus: Int {
        guard isLevelComplete else { return 0 }
        return starsEarned * 10
    }

    /// Total coins earned (collected + bonus)
    var totalCoins: Int {
        coins + completionBonus
    }
}
