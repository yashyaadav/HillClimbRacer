//
//  LevelDefinitions.swift
//  HillClimbRacer
//
//  Predefined levels for the game including tutorial and challenge levels.
//

import Foundation

/// Collection of all available levels in the game
enum LevelDefinitions {

    // MARK: - Level Instances

    /// Level 1: Green Start (Tutorial) - Easy grassland level
    static let greenStart = Level(
        id: "green_start",
        name: "Green Start",
        description: "Learn the basics on gentle hills",
        biome: BiomeDefinitions.grassland,
        targetDistance: 1500,
        unlockCost: 0,  // Free (tutorial)
        difficulty: 1,
        isEndless: false,
        starThresholds: StarThresholds(oneStar: 500, twoStar: 1000, threeStar: 1500)
    )

    /// Level 2: Desert Dunes - Medium difficulty desert level
    static let desertDunes = Level(
        id: "desert_dunes",
        name: "Desert Dunes",
        description: "Navigate sandy waves and dunes",
        biome: BiomeDefinitions.desert,
        targetDistance: 2000,
        unlockCost: 100,
        difficulty: 2,
        isEndless: false,
        starThresholds: StarThresholds(oneStar: 700, twoStar: 1400, threeStar: 2000)
    )

    /// Level 3: Frozen Peaks - Harder arctic level
    static let frozenPeaks = Level(
        id: "frozen_peaks",
        name: "Frozen Peaks",
        description: "Conquer icy mountains and steep slopes",
        biome: BiomeDefinitions.arctic,
        targetDistance: 2500,
        unlockCost: 250,
        difficulty: 3,
        isEndless: false,
        starThresholds: StarThresholds(oneStar: 800, twoStar: 1600, threeStar: 2500)
    )

    /// Level 4: Deep Forest - Challenging forest level
    static let deepForest = Level(
        id: "deep_forest",
        name: "Deep Forest",
        description: "Brave the dark and treacherous woods",
        biome: BiomeDefinitions.forest,
        targetDistance: 3000,
        unlockCost: 500,
        difficulty: 4,
        isEndless: false,
        starThresholds: StarThresholds(oneStar: 1000, twoStar: 2000, threeStar: 3000)
    )

    /// Level 5: Endless Adventure - Infinite mode with biome transitions
    static let endlessAdventure = Level(
        id: "endless_adventure",
        name: "Endless Adventure",
        description: "How far can you go? All biomes, no limits!",
        biome: nil,  // nil = uses biome transitions
        targetDistance: nil,  // nil = endless
        unlockCost: 0,  // Free (main mode)
        difficulty: 3,
        isEndless: true,
        starThresholds: StarThresholds(oneStar: 2000, twoStar: 5000, threeStar: 10000)
    )

    // MARK: - Level Access

    /// All levels in order (for display)
    static let all: [Level] = [
        greenStart,
        desertDunes,
        frozenPeaks,
        deepForest,
        endlessAdventure
    ]

    /// Story mode levels (excludes endless)
    static let storyLevels: [Level] = [
        greenStart,
        desertDunes,
        frozenPeaks,
        deepForest
    ]

    /// Get level by ID
    static func level(withId id: String) -> Level? {
        all.first { $0.id == id }
    }

    /// Default level (tutorial)
    static var defaultLevel: Level {
        greenStart
    }

    /// Get the next level after the given one
    static func nextLevel(after current: Level) -> Level? {
        guard let currentIndex = storyLevels.firstIndex(where: { $0.id == current.id }) else {
            return nil
        }
        let nextIndex = currentIndex + 1
        if nextIndex < storyLevels.count {
            return storyLevels[nextIndex]
        }
        return nil
    }

    /// Check if a level should be unlocked based on previous level completion
    static func shouldUnlock(_ level: Level, previousLevelCompleted: Bool) -> Bool {
        // First level is always unlocked
        if level.id == greenStart.id || level.id == endlessAdventure.id {
            return true
        }

        // Other levels require previous level to be completed
        return previousLevelCompleted
    }

    // MARK: - Level Statistics

    /// Total stars available in story mode
    static var totalStoryStars: Int {
        storyLevels.count * 3  // 3 stars per level
    }

    /// Count of story levels
    static var storyLevelCount: Int {
        storyLevels.count
    }
}
