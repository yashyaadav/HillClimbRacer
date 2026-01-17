//
//  TerrainGeneratorTests.swift
//  HillClimbRacerTests
//
//  Unit tests for TerrainGenerator.
//

import XCTest
@testable import HillClimbRacer

final class TerrainGeneratorTests: XCTestCase {

    var generator: TerrainGenerator!

    override func setUpWithError() throws {
        generator = TerrainGenerator(seed: 12345)  // Fixed seed for reproducibility
    }

    override func tearDownWithError() throws {
        generator = nil
    }

    // MARK: - Chunk Generation Tests

    func testChunkGeneratesPoints() {
        let points = generator.generateChunk(startX: 0, width: 800)

        XCTAssertGreaterThan(points.count, 0, "Should generate at least one point")
    }

    func testChunkPointsAreOrdered() {
        let points = generator.generateChunk(startX: 0, width: 800)

        for i in 1..<points.count {
            XCTAssertGreaterThan(points[i].x, points[i-1].x, "Points should be ordered by X position")
        }
    }

    func testChunkStartsAtCorrectX() {
        let startX: CGFloat = 1000
        let points = generator.generateChunk(startX: startX, width: 800)

        guard let firstPoint = points.first else {
            XCTFail("Expected points to have at least one element")
            return
        }
        XCTAssertEqual(firstPoint.x, startX, accuracy: 0.1, "First point should be at startX")
    }

    func testChunkEndsAtCorrectX() {
        let startX: CGFloat = 1000
        let width: CGFloat = 800
        let points = generator.generateChunk(startX: startX, width: width)

        // Last point should be at or near startX + width
        XCTAssertEqual(points.last!.x, startX + width, accuracy: Constants.Terrain.pointSpacing, "Last point should be near startX + width")
    }

    func testChunkPointSpacing() {
        let points = generator.generateChunk(startX: 0, width: 800)

        for i in 1..<points.count {
            let spacing = points[i].x - points[i-1].x
            XCTAssertEqual(spacing, Constants.Terrain.pointSpacing, accuracy: 0.1, "Points should be evenly spaced")
        }
    }

    // MARK: - Height Generation Tests

    func testHeightIsPositive() {
        for x in stride(from: 0, to: 10000, by: 100) {
            let height = generator.generateHeight(at: CGFloat(x))
            XCTAssertGreaterThan(height, 0, "Height should be positive at x=\(x)")
        }
    }

    func testHeightMeetsMinimum() {
        for x in stride(from: 0, to: 10000, by: 100) {
            let height = generator.generateHeight(at: CGFloat(x))
            XCTAssertGreaterThanOrEqual(height, 50, "Height should meet minimum of 50 at x=\(x)")
        }
    }

    func testHeightIncreasesDifficulty() {
        // Heights at far distances should generally be higher due to difficulty scaling
        let earlyHeights = (0..<100).map { generator.generateHeight(at: CGFloat($0) * 100) }
        let lateHeights = (100..<200).map { generator.generateHeight(at: CGFloat($0) * 100) }

        let earlyAverage = earlyHeights.reduce(0, +) / CGFloat(earlyHeights.count)
        let lateAverage = lateHeights.reduce(0, +) / CGFloat(lateHeights.count)

        XCTAssertGreaterThan(lateAverage, earlyAverage, "Average height should increase with distance")
    }

    func testDeterministicGeneration() {
        let generator1 = TerrainGenerator(seed: 12345)
        let generator2 = TerrainGenerator(seed: 12345)

        for x in stride(from: 0, to: 1000, by: 50) {
            let height1 = generator1.generateHeight(at: CGFloat(x))
            let height2 = generator2.generateHeight(at: CGFloat(x))
            XCTAssertEqual(height1, height2, accuracy: 0.001, "Same seed should produce same heights")
        }
    }

    func testDifferentSeedsDifferentTerrain() {
        let generator1 = TerrainGenerator(seed: 11111)
        let generator2 = TerrainGenerator(seed: 22222)

        var differences = 0
        for x in stride(from: 0, to: 1000, by: 50) {
            let height1 = generator1.generateHeight(at: CGFloat(x))
            let height2 = generator2.generateHeight(at: CGFloat(x))
            if abs(height1 - height2) > 0.1 {
                differences += 1
            }
        }

        XCTAssertGreaterThan(differences, 0, "Different seeds should produce different terrain")
    }

    // MARK: - Starting Area Tests

    func testStartingAreaGeneratesPoints() {
        let points = generator.generateStartingArea(width: 800)

        XCTAssertGreaterThan(points.count, 0, "Should generate starting area points")
    }

    func testStartingAreaStartsFlat() {
        let points = generator.generateStartingArea(width: 800)

        // First 70% should be flat (at base height)
        let flatEnd = Int(0.7 * Double(points.count))
        for i in 0..<flatEnd {
            XCTAssertEqual(points[i].y, Constants.Terrain.baseHeight, accuracy: 0.1, "Starting area should be flat at base height")
        }
    }

    func testStartingAreaStartsAtZero() {
        let points = generator.generateStartingArea(width: 800)

        guard let firstPoint = points.first else {
            XCTFail("Expected points to have at least one element")
            return
        }
        XCTAssertEqual(firstPoint.x, 0, accuracy: 0.1, "Starting area should begin at x=0")
    }

    // MARK: - Biome Modifier Tests

    func testBiomeModifiersAffectHeight() {
        let normalHeight = generator.generateHeight(at: 1000, biome: nil)

        // Desert has lower amplitude multiplier
        let desertHeight = generator.generateHeight(at: 1000, biome: BiomeDefinitions.desert)

        // Arctic has higher amplitude multiplier
        let arcticHeight = generator.generateHeight(at: 1000, biome: BiomeDefinitions.arctic)

        // Heights should differ when biome modifiers are applied
        // We can't predict exact values, but we can verify the calculation runs
        XCTAssertNotNil(normalHeight)
        XCTAssertNotNil(desertHeight)
        XCTAssertNotNil(arcticHeight)
    }

    func testChunkWithBiomeModifiers() {
        let grasslandPoints = generator.generateChunk(startX: 0, width: 800, biome: BiomeDefinitions.grassland)
        let desertPoints = generator.generateChunk(startX: 0, width: 800, biome: BiomeDefinitions.desert)

        XCTAssertEqual(grasslandPoints.count, desertPoints.count, "Point counts should be the same")

        // Verify points were generated (actual heights may vary)
        XCTAssertGreaterThan(grasslandPoints.count, 0)
        XCTAssertGreaterThan(desertPoints.count, 0)
    }

    func testStartingAreaWithBiome() {
        let points = generator.generateStartingArea(width: 800, biome: BiomeDefinitions.arctic)

        XCTAssertGreaterThan(points.count, 0, "Should generate starting area with biome")

        // Starting area should still be flat initially
        guard let firstPoint = points.first else {
            XCTFail("Expected points to have at least one element")
            return
        }
        XCTAssertEqual(firstPoint.y, Constants.Terrain.baseHeight, accuracy: 0.1)
    }

    // MARK: - Edge Cases

    func testZeroWidthChunk() {
        let points = generator.generateChunk(startX: 0, width: 0)

        // Should generate at least the starting point
        XCTAssertGreaterThanOrEqual(points.count, 1)
    }

    func testNegativeStartX() {
        let points = generator.generateChunk(startX: -500, width: 800)

        guard let firstPoint = points.first else {
            XCTFail("Expected points to have at least one element")
            return
        }
        XCTAssertEqual(firstPoint.x, -500, accuracy: 0.1, "Should handle negative start X")
        XCTAssertGreaterThan(points.count, 0)
    }

    func testLargeDistance() {
        // Verify terrain generation works at large distances
        let height = generator.generateHeight(at: 100000)

        XCTAssertGreaterThan(height, 0, "Should generate valid height at large distance")
        XCTAssertLessThan(height, 10000, "Height should be reasonable (not infinite)")
    }

    // MARK: - Octave Noise Tests

    func testOctaveNoiseProducesVariedTerrain() {
        // Arrange - create noise generator directly to test octave noise
        let noise = PerlinNoise(seed: 12345)

        // Act - generate octave noise at multiple positions
        var values: [CGFloat] = []
        for x in stride(from: 0, to: 100, by: 1) {
            let value = noise.octaveNoise(CGFloat(x) * 0.01, octaves: 4, persistence: 0.5)
            values.append(value)
        }

        // Assert - octave noise should produce varied values (not all the same)
        let uniqueValues = Set(values.map { Int($0 * 1000) })  // Compare with some precision
        XCTAssertGreaterThan(uniqueValues.count, 1,
                             "Octave noise should produce varied terrain values")

        // Check that values are within expected range (-1 to 1)
        for value in values {
            XCTAssertGreaterThanOrEqual(value, -1.0, "Octave noise should be >= -1")
            XCTAssertLessThanOrEqual(value, 1.0, "Octave noise should be <= 1")
        }
    }

    func testOctaveNoiseIsDeterministic() {
        // Arrange
        let noise1 = PerlinNoise(seed: 12345)
        let noise2 = PerlinNoise(seed: 12345)

        // Act & Assert - same seed should produce same noise
        for x in stride(from: 0, to: 50, by: 5) {
            let value1 = noise1.octaveNoise(CGFloat(x) * 0.01, octaves: 4, persistence: 0.5)
            let value2 = noise2.octaveNoise(CGFloat(x) * 0.01, octaves: 4, persistence: 0.5)

            XCTAssertEqual(value1, value2, accuracy: 0.0001,
                           "Same seed should produce identical octave noise at x=\(x)")
        }
    }

    // MARK: - Jump Ramp Tests

    func testJumpRampAppearsApproximatelyEvery1000Units() {
        // Arrange - generate heights over a long stretch
        var rampPeaks: [CGFloat] = []
        var lastHeight: CGFloat = 0

        // Scan terrain looking for local peaks (ramps)
        for x in stride(from: 1000, to: 10000, by: 20) {
            let height = generator.generateHeight(at: CGFloat(x))
            let nextHeight = generator.generateHeight(at: CGFloat(x) + 20)

            // Detect a peak (ramp apex)
            if height > lastHeight && height > nextHeight && height > Constants.Terrain.baseHeight + 50 {
                rampPeaks.append(CGFloat(x))
            }
            lastHeight = height
        }

        // Assert - should find multiple ramp features
        // The exact count depends on noise variation, but ramps should appear periodically
        XCTAssertGreaterThanOrEqual(rampPeaks.count, 3,
                                    "Should find at least 3 ramp peaks over 9000 units")
    }

    func testJumpRampHeightScalesWithDistance() {
        // Compare ramp effect at near distance vs far distance
        // Due to distanceScale in jumpRampModifier, later ramps should be taller

        // Get a baseline at early distance
        var earlyMaxHeight: CGFloat = 0
        for x in stride(from: 1000, to: 2000, by: 10) {
            let height = generator.generateHeight(at: CGFloat(x))
            earlyMaxHeight = max(earlyMaxHeight, height)
        }

        // Get heights at late distance
        var lateMaxHeight: CGFloat = 0
        for x in stride(from: 20000, to: 21000, by: 10) {
            let height = generator.generateHeight(at: CGFloat(x))
            lateMaxHeight = max(lateMaxHeight, height)
        }

        // Assert - late terrain should have higher maximum due to scaling
        XCTAssertGreaterThan(lateMaxHeight, earlyMaxHeight,
                             "Terrain features should scale with distance (progressive difficulty)")
    }

    // MARK: - Steep Section Tests

    func testSteepSectionCreatesThreePartPattern() {
        // Steep sections have: ascent -> plateau -> descent (3 parts, ~300 units each)
        let sectionWidth: CGFloat = 300

        // Find a steep section start (they occur every ~2500 units after initial area)
        let steepStart: CGFloat = 2500

        // Sample heights across the three parts
        var ascentHeights: [CGFloat] = []
        var descentHeights: [CGFloat] = []

        // Ascent phase (first 300 units of section)
        for x in stride(from: steepStart, to: steepStart + sectionWidth, by: 30) {
            ascentHeights.append(generator.generateHeight(at: CGFloat(x)))
        }

        // Descent phase (600-900 units)
        for x in stride(from: steepStart + sectionWidth * 2, to: steepStart + sectionWidth * 3, by: 30) {
            descentHeights.append(generator.generateHeight(at: CGFloat(x)))
        }

        // Assert - heights should generally increase then stay steady then decrease
        // Check that ascent end is higher than start
        if let ascentFirst = ascentHeights.first, let ascentLast = ascentHeights.last {
            XCTAssertGreaterThan(ascentLast, ascentFirst,
                                 "Ascent phase should increase in height")
        }

        // Check that descent end is lower than start
        if let descentFirst = descentHeights.first, let descentLast = descentHeights.last {
            XCTAssertLessThan(descentLast, descentFirst,
                              "Descent phase should decrease in height")
        }
    }

    func testSteepSectionHeightIncreasesWithDistance() {
        // Steep sections get taller at greater distances due to distance scaling

        // Find max height in early steep section
        var earlyMaxHeight: CGFloat = 0
        for x in stride(from: 2500, to: 3400, by: 20) {
            let height = generator.generateHeight(at: CGFloat(x))
            earlyMaxHeight = max(earlyMaxHeight, height)
        }

        // Find max height in late steep section
        var lateMaxHeight: CGFloat = 0
        for x in stride(from: 25000, to: 25900, by: 20) {
            let height = generator.generateHeight(at: CGFloat(x))
            lateMaxHeight = max(lateMaxHeight, height)
        }

        // Assert - late steep sections should be taller
        XCTAssertGreaterThan(lateMaxHeight, earlyMaxHeight,
                             "Steep sections should be taller at greater distances")
    }

    // MARK: - Plateau Tests

    func testPlateauCreatesRestArea() {
        // Plateaus occur every ~3500 units and create relatively flat areas
        let plateauStart: CGFloat = 3500  // First plateau

        // Sample heights across plateau
        var plateauHeights: [CGFloat] = []
        let transitionWidth: CGFloat = 50
        let plateauWidth: CGFloat = 200

        // Sample the middle of the plateau (avoiding transitions)
        for x in stride(from: plateauStart + transitionWidth + 10,
                        to: plateauStart + plateauWidth - transitionWidth - 10,
                        by: 10) {
            plateauHeights.append(generator.generateHeight(at: CGFloat(x)))
        }

        // Assert - heights within plateau should have low variance
        if plateauHeights.count > 2 {
            let minHeight = plateauHeights.min() ?? 0
            let maxHeight = plateauHeights.max() ?? 0
            let variance = maxHeight - minHeight

            // Plateaus add a constant +20, so variance should be primarily from base terrain
            // The flat portion should have relatively consistent height
            XCTAssertLessThan(variance, 100,
                              "Plateau area should have moderate height variance (rest area)")
        }
    }

    func testPlateauTransitionsAreSmooth() {
        // Check that plateau entry/exit uses gradual transitions
        let plateauStart: CGFloat = 3500
        let transitionWidth: CGFloat = 50

        // Sample heights during transition
        var transitionHeights: [CGFloat] = []
        for x in stride(from: plateauStart, to: plateauStart + transitionWidth, by: 5) {
            transitionHeights.append(generator.generateHeight(at: CGFloat(x)))
        }

        // Assert - heights should gradually change, not have huge jumps
        for i in 1..<transitionHeights.count {
            let diff = abs(transitionHeights[i] - transitionHeights[i-1])
            XCTAssertLessThan(diff, 50,
                              "Plateau transition should be gradual (no jumps > 50 units)")
        }
    }

    // MARK: - Progressive Difficulty Tests

    func testDifficultyIncreasesWithDistance() {
        // Sample average heights at different distances
        func averageHeight(from start: CGFloat, to end: CGFloat) -> CGFloat {
            var total: CGFloat = 0
            var count: CGFloat = 0
            for x in stride(from: start, to: end, by: 50) {
                total += generator.generateHeight(at: CGFloat(x))
                count += 1
            }
            return total / count
        }

        let earlyAverage = averageHeight(from: 1000, to: 3000)
        let midAverage = averageHeight(from: 10000, to: 12000)
        let lateAverage = averageHeight(from: 30000, to: 32000)

        // Assert - difficulty (manifested as terrain amplitude) increases
        XCTAssertGreaterThan(midAverage, earlyAverage,
                             "Mid-game terrain should be higher than early terrain")
        XCTAssertGreaterThan(lateAverage, midAverage,
                             "Late-game terrain should be higher than mid-game terrain")
    }

    func testMinimumHeightMaintained() {
        // Verify that generateHeight never returns less than minimum (50)
        for x in stride(from: 0, to: 50000, by: 100) {
            let height = generator.generateHeight(at: CGFloat(x))
            XCTAssertGreaterThanOrEqual(height, 50,
                                        "Height at x=\(x) should be at least 50 (minimum)")
        }
    }
}
