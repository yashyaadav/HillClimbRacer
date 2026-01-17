//
//  LevelTests.swift
//  HillClimbRacerTests
//
//  Unit tests for Level, LevelDefinitions, and LevelProgress.
//

import XCTest
@testable import HillClimbRacer

final class LevelTests: XCTestCase {

    // MARK: - Level Properties Tests

    func testLevelHasUniqueIds() {
        let ids = LevelDefinitions.all.map { $0.id }
        let uniqueIds = Set(ids)
        XCTAssertEqual(ids.count, uniqueIds.count, "All levels should have unique IDs")
    }

    func testLevelHasNonEmptyNames() {
        for level in LevelDefinitions.all {
            XCTAssertFalse(level.name.isEmpty, "Level \(level.id) should have a non-empty name")
            XCTAssertFalse(level.description.isEmpty, "Level \(level.id) should have a non-empty description")
        }
    }

    func testLevelDifficultyRange() {
        for level in LevelDefinitions.all {
            XCTAssertGreaterThanOrEqual(level.difficulty, 1, "Difficulty should be at least 1 for \(level.id)")
            XCTAssertLessThanOrEqual(level.difficulty, 5, "Difficulty should be at most 5 for \(level.id)")
        }
    }

    func testLevelUnlockCosts() {
        for level in LevelDefinitions.all {
            XCTAssertGreaterThanOrEqual(level.unlockCost, 0, "Unlock cost should not be negative for \(level.id)")
        }
    }

    // MARK: - LevelDefinitions Tests

    func testAllLevelsExist() {
        XCTAssertEqual(LevelDefinitions.all.count, 5, "Should have 5 levels defined (4 story + 1 endless)")
    }

    func testStoryLevelsExist() {
        XCTAssertEqual(LevelDefinitions.storyLevels.count, 4, "Should have 4 story levels")
    }

    func testDefaultLevel() {
        let defaultLevel = LevelDefinitions.defaultLevel
        XCTAssertEqual(defaultLevel.id, "green_start", "Default level should be Green Start")
    }

    func testLevelLookupById() {
        let greenStart = LevelDefinitions.level(withId: "green_start")
        XCTAssertNotNil(greenStart, "Should find Green Start by ID")
        XCTAssertEqual(greenStart?.name, "Green Start")

        let desertDunes = LevelDefinitions.level(withId: "desert_dunes")
        XCTAssertNotNil(desertDunes, "Should find Desert Dunes by ID")

        let frozenPeaks = LevelDefinitions.level(withId: "frozen_peaks")
        XCTAssertNotNil(frozenPeaks, "Should find Frozen Peaks by ID")

        let deepForest = LevelDefinitions.level(withId: "deep_forest")
        XCTAssertNotNil(deepForest, "Should find Deep Forest by ID")

        let endless = LevelDefinitions.level(withId: "endless_adventure")
        XCTAssertNotNil(endless, "Should find Endless Adventure by ID")

        let invalid = LevelDefinitions.level(withId: "invalid")
        XCTAssertNil(invalid, "Should return nil for invalid level ID")
    }

    func testNextLevel() {
        let greenStart = LevelDefinitions.greenStart
        let nextAfterGreen = LevelDefinitions.nextLevel(after: greenStart)
        XCTAssertNotNil(nextAfterGreen, "Should have a next level after Green Start")
        XCTAssertEqual(nextAfterGreen?.id, "desert_dunes", "Next level after Green Start should be Desert Dunes")

        let deepForest = LevelDefinitions.deepForest
        let nextAfterForest = LevelDefinitions.nextLevel(after: deepForest)
        XCTAssertNil(nextAfterForest, "Should have no next level after Deep Forest (last story level)")

        let endless = LevelDefinitions.endlessAdventure
        let nextAfterEndless = LevelDefinitions.nextLevel(after: endless)
        XCTAssertNil(nextAfterEndless, "Should have no next level after Endless (not in story sequence)")
    }

    func testFirstLevelIsFree() {
        XCTAssertTrue(LevelDefinitions.greenStart.isFree, "First level should be free")
        XCTAssertEqual(LevelDefinitions.greenStart.unlockCost, 0, "First level unlock cost should be 0")
    }

    func testEndlessLevelIsFree() {
        XCTAssertTrue(LevelDefinitions.endlessAdventure.isFree, "Endless mode should be free")
        XCTAssertEqual(LevelDefinitions.endlessAdventure.unlockCost, 0, "Endless mode unlock cost should be 0")
    }

    func testEndlessLevelProperties() {
        let endless = LevelDefinitions.endlessAdventure
        XCTAssertTrue(endless.isEndless, "Endless Adventure should be marked as endless")
        XCTAssertNil(endless.targetDistance, "Endless Adventure should have no target distance")
        XCTAssertNil(endless.biome, "Endless Adventure should have no fixed biome")
    }

    func testTotalStoryStars() {
        XCTAssertEqual(LevelDefinitions.totalStoryStars, 12, "Total story stars should be 12 (4 levels x 3 stars)")
    }

    // MARK: - Star Thresholds Tests

    func testStarThresholdsOrdering() {
        for level in LevelDefinitions.all {
            let thresholds = level.starThresholds
            XCTAssertLessThan(thresholds.oneStar, thresholds.twoStar, "1-star threshold should be less than 2-star for \(level.id)")
            XCTAssertLessThan(thresholds.twoStar, thresholds.threeStar, "2-star threshold should be less than 3-star for \(level.id)")
        }
    }

    func testStarsEarned() {
        let level = LevelDefinitions.greenStart

        XCTAssertEqual(level.starsEarned(for: 0), 0, "0 distance should earn 0 stars")
        XCTAssertEqual(level.starsEarned(for: 100), 0, "100m should earn 0 stars")
        XCTAssertEqual(level.starsEarned(for: 500), 1, "500m should earn 1 star")
        XCTAssertEqual(level.starsEarned(for: 750), 1, "750m should earn 1 star")
        XCTAssertEqual(level.starsEarned(for: 1000), 2, "1000m should earn 2 stars")
        XCTAssertEqual(level.starsEarned(for: 1200), 2, "1200m should earn 2 stars")
        XCTAssertEqual(level.starsEarned(for: 1500), 3, "1500m should earn 3 stars")
        XCTAssertEqual(level.starsEarned(for: 2000), 3, "2000m should still earn 3 stars (max)")
    }

    func testStarThresholdsForTarget() {
        let thresholds = StarThresholds.forTarget(1000)

        XCTAssertEqual(thresholds.oneStar, 500, "1-star should be 50% of target")
        XCTAssertEqual(thresholds.twoStar, 750, "2-star should be 75% of target")
        XCTAssertEqual(thresholds.threeStar, 1000, "3-star should be 100% of target")
    }

    // MARK: - Level Completion Tests

    func testLevelCompletion() {
        let level = LevelDefinitions.greenStart

        XCTAssertFalse(level.isCompleted(distance: 0), "0 distance should not complete level")
        XCTAssertFalse(level.isCompleted(distance: 1000), "1000m should not complete 1500m level")
        XCTAssertTrue(level.isCompleted(distance: 1500), "1500m should complete 1500m level")
        XCTAssertTrue(level.isCompleted(distance: 2000), "2000m should complete 1500m level")
    }

    func testEndlessLevelNeverCompletes() {
        let endless = LevelDefinitions.endlessAdventure

        XCTAssertFalse(endless.isCompleted(distance: 0), "Endless mode should never be completed at 0")
        XCTAssertFalse(endless.isCompleted(distance: 10000), "Endless mode should never be completed at 10000")
        XCTAssertFalse(endless.isCompleted(distance: 1000000), "Endless mode should never be completed at any distance")
    }

    // MARK: - Level Progress Tests

    func testLevelProgressInitialization() {
        let progress = LevelProgress(levelId: "test_level")

        XCTAssertEqual(progress.levelId, "test_level")
        XCTAssertFalse(progress.isUnlocked)
        XCTAssertFalse(progress.isCompleted)
        XCTAssertEqual(progress.bestDistance, 0)
        XCTAssertEqual(progress.starsEarned, 0)
        XCTAssertEqual(progress.timesPlayed, 0)
    }

    func testLevelProgressUpdate() {
        var progress = LevelProgress(levelId: "test_level", isUnlocked: true)

        progress.update(distance: 500, stars: 1)
        XCTAssertEqual(progress.bestDistance, 500)
        XCTAssertEqual(progress.starsEarned, 1)
        XCTAssertEqual(progress.timesPlayed, 1)

        // Update with better result
        progress.update(distance: 1000, stars: 2)
        XCTAssertEqual(progress.bestDistance, 1000, "Best distance should update to higher value")
        XCTAssertEqual(progress.starsEarned, 2, "Stars should update to higher value")
        XCTAssertEqual(progress.timesPlayed, 2)

        // Update with worse result
        progress.update(distance: 300, stars: 0)
        XCTAssertEqual(progress.bestDistance, 1000, "Best distance should not decrease")
        XCTAssertEqual(progress.starsEarned, 2, "Stars should not decrease")
        XCTAssertEqual(progress.timesPlayed, 3, "Times played should still increment")
    }

    // MARK: - Level Result Tests

    func testLevelResultCompletionBonus() {
        let level = LevelDefinitions.greenStart

        let incompleteResult = LevelResult(
            level: level,
            distance: 500,
            coins: 10,
            starsEarned: 1,
            isNewRecord: true,
            isLevelComplete: false
        )
        XCTAssertEqual(incompleteResult.completionBonus, 0, "Incomplete level should have no bonus")
        XCTAssertEqual(incompleteResult.totalCoins, 10, "Total coins should equal collected coins")

        let completeResult = LevelResult(
            level: level,
            distance: 1500,
            coins: 25,
            starsEarned: 3,
            isNewRecord: true,
            isLevelComplete: true
        )
        XCTAssertEqual(completeResult.completionBonus, 30, "3 stars should give 30 bonus coins")
        XCTAssertEqual(completeResult.totalCoins, 55, "Total coins should include bonus")
    }

    // MARK: - Level Equality Tests

    func testLevelEquality() {
        let greenStart1 = LevelDefinitions.greenStart
        let greenStart2 = LevelDefinitions.level(withId: "green_start")!

        XCTAssertEqual(greenStart1, greenStart2, "Same levels should be equal")

        let desert = LevelDefinitions.desertDunes
        XCTAssertNotEqual(greenStart1, desert, "Different levels should not be equal")
    }

    // MARK: - Display Properties Tests

    func testTargetDistanceDisplay() {
        XCTAssertEqual(LevelDefinitions.greenStart.targetDistanceDisplay, "1500m")
        XCTAssertEqual(LevelDefinitions.desertDunes.targetDistanceDisplay, "2000m")
        XCTAssertEqual(LevelDefinitions.endlessAdventure.targetDistanceDisplay, "Endless")
    }

    func testDifficultyDisplay() {
        XCTAssertEqual(LevelDefinitions.greenStart.difficultyDisplay, "*")
        XCTAssertEqual(LevelDefinitions.desertDunes.difficultyDisplay, "**")
        XCTAssertEqual(LevelDefinitions.frozenPeaks.difficultyDisplay, "***")
        XCTAssertEqual(LevelDefinitions.deepForest.difficultyDisplay, "****")
    }

    // MARK: - Level Biome Association Tests

    func testStoryLevelsHaveBiomes() {
        for level in LevelDefinitions.storyLevels {
            XCTAssertNotNil(level.biome, "Story level \(level.id) should have a biome")
        }
    }

    func testLevelBiomeAssociations() {
        XCTAssertEqual(LevelDefinitions.greenStart.biome?.id, "grassland")
        XCTAssertEqual(LevelDefinitions.desertDunes.biome?.id, "desert")
        XCTAssertEqual(LevelDefinitions.frozenPeaks.biome?.id, "arctic")
        XCTAssertEqual(LevelDefinitions.deepForest.biome?.id, "forest")
    }
}
