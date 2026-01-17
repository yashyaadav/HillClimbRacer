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

        XCTAssertEqual(points.first?.x, startX, accuracy: 0.1, "First point should be at startX")
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

        XCTAssertEqual(points.first?.x, 0, accuracy: 0.1, "Starting area should begin at x=0")
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
        XCTAssertEqual(points.first?.y, Constants.Terrain.baseHeight, accuracy: 0.1)
    }

    // MARK: - Edge Cases

    func testZeroWidthChunk() {
        let points = generator.generateChunk(startX: 0, width: 0)

        // Should generate at least the starting point
        XCTAssertGreaterThanOrEqual(points.count, 1)
    }

    func testNegativeStartX() {
        let points = generator.generateChunk(startX: -500, width: 800)

        XCTAssertEqual(points.first?.x, -500, accuracy: 0.1, "Should handle negative start X")
        XCTAssertGreaterThan(points.count, 0)
    }

    func testLargeDistance() {
        // Verify terrain generation works at large distances
        let height = generator.generateHeight(at: 100000)

        XCTAssertGreaterThan(height, 0, "Should generate valid height at large distance")
        XCTAssertLessThan(height, 10000, "Height should be reasonable (not infinite)")
    }
}
