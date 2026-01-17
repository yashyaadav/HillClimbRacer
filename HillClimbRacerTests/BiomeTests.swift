//
//  BiomeTests.swift
//  HillClimbRacerTests
//
//  Unit tests for Biome and BiomeDefinitions.
//

import XCTest
@testable import HillClimbRacer

final class BiomeTests: XCTestCase {

    // MARK: - Biome Properties Tests

    func testBiomeHasUniqueIds() {
        let ids = BiomeDefinitions.all.map { $0.id }
        let uniqueIds = Set(ids)
        XCTAssertEqual(ids.count, uniqueIds.count, "All biomes should have unique IDs")
    }

    func testBiomeHasNonEmptyNames() {
        for biome in BiomeDefinitions.all {
            XCTAssertFalse(biome.name.isEmpty, "Biome \(biome.id) should have a non-empty name")
        }
    }

    func testBiomeColorsAreValid() {
        for biome in BiomeDefinitions.all {
            // Just verify colors can be accessed without crashing
            _ = biome.skyColor
            _ = biome.terrainFillColor
            _ = biome.terrainStrokeColor
            _ = biome.skySwiftUIColor
            _ = biome.terrainFillSwiftUIColor
            _ = biome.terrainStrokeSwiftUIColor
        }
    }

    func testBiomeModifiersArePositive() {
        for biome in BiomeDefinitions.all {
            XCTAssertGreaterThan(biome.hillAmplitudeMultiplier, 0, "Hill amplitude multiplier should be positive for \(biome.id)")
            XCTAssertGreaterThan(biome.hillFrequencyMultiplier, 0, "Hill frequency multiplier should be positive for \(biome.id)")
            XCTAssertGreaterThan(biome.noiseAmplitudeMultiplier, 0, "Noise amplitude multiplier should be positive for \(biome.id)")
        }
    }

    // MARK: - BiomeDefinitions Tests

    func testAllBiomesExist() {
        XCTAssertEqual(BiomeDefinitions.all.count, 4, "Should have 4 biomes defined")
    }

    func testDefaultBiome() {
        let defaultBiome = BiomeDefinitions.defaultBiome
        XCTAssertEqual(defaultBiome.id, "grassland", "Default biome should be grassland")
    }

    func testBiomeLookupById() {
        let grassland = BiomeDefinitions.biome(withId: "grassland")
        XCTAssertNotNil(grassland, "Should find grassland biome by ID")
        XCTAssertEqual(grassland?.name, "Grassland")

        let desert = BiomeDefinitions.biome(withId: "desert")
        XCTAssertNotNil(desert, "Should find desert biome by ID")

        let arctic = BiomeDefinitions.biome(withId: "arctic")
        XCTAssertNotNil(arctic, "Should find arctic biome by ID")

        let forest = BiomeDefinitions.biome(withId: "forest")
        XCTAssertNotNil(forest, "Should find forest biome by ID")

        let invalid = BiomeDefinitions.biome(withId: "invalid")
        XCTAssertNil(invalid, "Should return nil for invalid biome ID")
    }

    func testRandomBiome() {
        let random = BiomeDefinitions.randomBiome()
        XCTAssertTrue(BiomeDefinitions.all.contains(where: { $0.id == random.id }), "Random biome should be one of the defined biomes")
    }

    func testRandomBiomeExcluding() {
        let grassland = BiomeDefinitions.grassland
        for _ in 0..<10 {
            let random = BiomeDefinitions.randomBiome(excluding: grassland)
            XCTAssertNotEqual(random.id, grassland.id, "Random biome should exclude specified biome")
        }
    }

    func testNextBiome() {
        let grassland = BiomeDefinitions.grassland
        let nextAfterGrassland = BiomeDefinitions.nextBiome(after: grassland)
        XCTAssertNotEqual(nextAfterGrassland.id, grassland.id, "Next biome should be different")
    }

    func testEndlessSequence() {
        XCTAssertEqual(BiomeDefinitions.endlessSequence.count, 4, "Endless sequence should have 4 biomes")
    }

    func testBiomeForEndlessMode() {
        let biome0 = BiomeDefinitions.biomeForEndlessMode(at: 0)
        XCTAssertNotNil(biome0, "Should return a biome for position 0")

        let biome5000 = BiomeDefinitions.biomeForEndlessMode(at: 5000)
        XCTAssertNotNil(biome5000, "Should return a biome for position 5000")

        // Verify biome cycling
        let biome20000 = BiomeDefinitions.biomeForEndlessMode(at: 20000)
        let biome0Again = BiomeDefinitions.biomeForEndlessMode(at: 0)
        XCTAssertEqual(biome20000.id, biome0Again.id, "Biomes should cycle after going through all")
    }

    // MARK: - BiomeTransition Tests

    func testBiomeTransitionProgress() {
        let transition = BiomeTransition(
            fromBiome: BiomeDefinitions.grassland,
            toBiome: BiomeDefinitions.desert,
            startX: 4500,
            endX: 5000
        )

        XCTAssertEqual(transition.progress(at: 4500), 0, accuracy: 0.01, "Progress should be 0 at start")
        XCTAssertEqual(transition.progress(at: 4750), 0.5, accuracy: 0.01, "Progress should be 0.5 at midpoint")
        XCTAssertEqual(transition.progress(at: 5000), 1, accuracy: 0.01, "Progress should be 1 at end")
    }

    func testBiomeTransitionClampedProgress() {
        let transition = BiomeTransition(
            fromBiome: BiomeDefinitions.grassland,
            toBiome: BiomeDefinitions.desert,
            startX: 1000,
            endX: 1500
        )

        XCTAssertEqual(transition.progress(at: 500), 0, accuracy: 0.01, "Progress should be clamped to 0 before start")
        XCTAssertEqual(transition.progress(at: 2000), 1, accuracy: 0.01, "Progress should be clamped to 1 after end")
    }

    func testBiomeTransitionInterpolatedColors() {
        let transition = BiomeTransition(
            fromBiome: BiomeDefinitions.grassland,
            toBiome: BiomeDefinitions.desert,
            startX: 0,
            endX: 1000
        )

        // Colors at start should match fromBiome
        _ = transition.interpolatedSkyColor(at: 0)
        _ = transition.interpolatedFillColor(at: 0)
        _ = transition.interpolatedStrokeColor(at: 0)

        // Colors at end should match toBiome
        _ = transition.interpolatedSkyColor(at: 1000)
        _ = transition.interpolatedFillColor(at: 1000)
        _ = transition.interpolatedStrokeColor(at: 1000)

        // Just verify these don't crash - actual color values would require color component comparison
    }

    // MARK: - Biome Equality Tests

    func testBiomeEquality() {
        let grassland1 = BiomeDefinitions.grassland
        let grassland2 = BiomeDefinitions.biome(withId: "grassland")!

        XCTAssertEqual(grassland1, grassland2, "Same biomes should be equal")

        let desert = BiomeDefinitions.desert
        XCTAssertNotEqual(grassland1, desert, "Different biomes should not be equal")
    }

    // MARK: - Weather Type Tests

    func testWeatherTypes() {
        XCTAssertNil(WeatherType.none.particleFileName, "None weather should have no particle file")
        XCTAssertNotNil(WeatherType.rain.particleFileName, "Rain should have a particle file name")
        XCTAssertNotNil(WeatherType.snow.particleFileName, "Snow should have a particle file name")
        XCTAssertNotNil(WeatherType.sandstorm.particleFileName, "Sandstorm should have a particle file name")
        XCTAssertNotNil(WeatherType.leaves.particleFileName, "Leaves should have a particle file name")
    }

    func testBiomeWeatherConfiguration() {
        XCTAssertFalse(BiomeDefinitions.grassland.hasWeatherParticles, "Grassland should not have weather particles")
        XCTAssertTrue(BiomeDefinitions.desert.hasWeatherParticles, "Desert should have weather particles")
        XCTAssertTrue(BiomeDefinitions.arctic.hasWeatherParticles, "Arctic should have weather particles")
        XCTAssertTrue(BiomeDefinitions.forest.hasWeatherParticles, "Forest should have weather particles")

        XCTAssertEqual(BiomeDefinitions.desert.weatherType, .sandstorm, "Desert should have sandstorm weather")
        XCTAssertEqual(BiomeDefinitions.arctic.weatherType, .snow, "Arctic should have snow weather")
        XCTAssertEqual(BiomeDefinitions.forest.weatherType, .rain, "Forest should have rain weather")
    }
}
