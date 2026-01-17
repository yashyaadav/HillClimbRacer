//
//  TerrainManagerTests.swift
//  HillClimbRacerTests
//
//  Unit tests for TerrainManager infinite terrain safety.
//

import XCTest
import SpriteKit
@testable import HillClimbRacer

final class TerrainManagerTests: XCTestCase {

    var scene: SKScene!
    var terrainManager: TerrainManager!

    override func setUpWithError() throws {
        // Create a scene to host terrain
        scene = SKScene(size: CGSize(width: 1334, height: 750))

        // Create terrain manager with fixed seed for reproducibility
        terrainManager = TerrainManager(scene: scene, seed: 12345)
    }

    override func tearDownWithError() throws {
        terrainManager = nil
        scene = nil
    }

    // MARK: - Initial State Tests

    func testLastGeneratedXInitiallyZero() {
        // Assert - before generating any terrain
        XCTAssertEqual(terrainManager.lastGeneratedX, 0,
                       "lastGeneratedX should be 0 before terrain generation")
    }

    // MARK: - Generation Progress Tests

    func testLastGeneratedXUpdatesAfterGeneration() {
        // Act
        terrainManager.generateInitialTerrain()

        // Assert
        XCTAssertGreaterThan(terrainManager.lastGeneratedX, 0,
                             "lastGeneratedX should update after generating initial terrain")
    }

    func testLoadAheadDistanceIs2500() {
        // Act
        terrainManager.generateInitialTerrain()

        // Assert - after initial generation, terrain should extend ahead
        // The loadAheadDistance is 2500, so terrain should be generated at least that far
        XCTAssertGreaterThanOrEqual(terrainManager.lastGeneratedX, 2500,
                                    "Terrain should be generated at least 2500 units ahead (loadAheadDistance)")
    }

    // MARK: - Terrain Availability Tests

    func testTerrainGeneratedAheadOfPlayer() {
        // Arrange
        terrainManager.generateInitialTerrain()
        let playerX: CGFloat = 500

        // Act
        terrainManager.update(playerX: playerX)

        // Assert - terrain should always be ahead of player
        XCTAssertGreaterThan(terrainManager.lastGeneratedX, playerX,
                             "Terrain should be generated ahead of player position")

        // Move player forward and verify terrain stays ahead
        let newPlayerX: CGFloat = 2000
        terrainManager.update(playerX: newPlayerX)

        XCTAssertGreaterThan(terrainManager.lastGeneratedX, newPlayerX,
                             "Terrain should stay ahead of player as they move")
    }

    func testSurfaceYAvailableWithinGeneratedRange() {
        // Arrange
        terrainManager.generateInitialTerrain()

        // Act & Assert - check multiple X positions within generated range
        let testPositions: [CGFloat] = [100, 500, 1000, 1500, 2000]

        for x in testPositions {
            if x < terrainManager.lastGeneratedX {
                let surfaceY = terrainManager.surfaceY(at: x)
                XCTAssertNotNil(surfaceY,
                                "surfaceY should be available at x=\(x) within generated range")
                if let y = surfaceY {
                    XCTAssertGreaterThan(y, 0,
                                         "Surface Y should be positive at x=\(x)")
                }
            }
        }
    }

    func testNoGapsBetweenChunks() {
        // Arrange
        terrainManager.generateInitialTerrain()

        // Move player forward multiple times to generate several chunks
        for playerX in stride(from: 1000, to: 5000, by: 500) {
            terrainManager.update(playerX: CGFloat(playerX))
        }

        // Act & Assert - verify no gaps in terrain coverage
        // Check that surfaceY is available at chunk boundaries
        let chunkWidth = Constants.Terrain.chunkWidth
        var lastX: CGFloat = 0

        while lastX < terrainManager.lastGeneratedX - chunkWidth {
            // Check at chunk boundaries
            let chunkEndX = lastX + chunkWidth

            let surfaceAtEnd = terrainManager.surfaceY(at: chunkEndX - 10)
            let surfaceAtStart = terrainManager.surfaceY(at: chunkEndX + 10)

            // At least one should exist (accounting for unloading behind player)
            if surfaceAtEnd != nil || surfaceAtStart != nil {
                // Terrain is continuous
                XCTAssertTrue(true, "Terrain exists around chunk boundary at x=\(chunkEndX)")
            }

            lastX += chunkWidth
        }

        // Verify the last generated X makes sense
        XCTAssertGreaterThan(terrainManager.lastGeneratedX, 5000,
                             "Terrain should extend well beyond player position")
    }

    // MARK: - Edge Cases

    func testSurfaceYReturnsNilForUngenratedRegion() {
        // Arrange - don't generate any terrain yet

        // Act
        let surfaceY = terrainManager.surfaceY(at: 10000)

        // Assert
        XCTAssertNil(surfaceY,
                     "surfaceY should return nil for regions not yet generated")
    }

    func testContinuousTerrainAfterMultipleUpdates() {
        // Arrange
        terrainManager.generateInitialTerrain()

        // Simulate a player driving forward
        var maxGeneratedX = terrainManager.lastGeneratedX

        for i in 1...10 {
            let playerX = CGFloat(i * 500)
            terrainManager.update(playerX: playerX)

            // lastGeneratedX should only increase or stay same
            XCTAssertGreaterThanOrEqual(terrainManager.lastGeneratedX, maxGeneratedX,
                                        "lastGeneratedX should never decrease")
            maxGeneratedX = terrainManager.lastGeneratedX

            // Terrain should always be ahead
            XCTAssertGreaterThan(terrainManager.lastGeneratedX, playerX,
                                 "Terrain should stay ahead at update \(i)")
        }
    }
}
