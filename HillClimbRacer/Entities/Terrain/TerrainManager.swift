//
//  TerrainManager.swift
//  HillClimbRacer
//
//  Manages terrain chunk streaming - loads chunks ahead of player,
//  unloads chunks behind to maintain performance.
//

import SpriteKit

class TerrainManager {

    // MARK: - Properties

    private weak var scene: SKScene?
    private let generator: TerrainGenerator

    /// Currently loaded terrain chunks
    private var chunks: [TerrainChunk] = []

    /// Width of each terrain chunk
    private let chunkWidth: CGFloat

    /// How far ahead to generate terrain
    private let loadAheadDistance: CGFloat = 1500

    /// How far behind to keep terrain before unloading
    private let unloadBehindDistance: CGFloat = 800

    /// Track the furthest X we've generated
    private var generatedUpToX: CGFloat = 0

    // MARK: - Initialization

    init(scene: SKScene, seed: Int = Int.random(in: 0...10000)) {
        self.scene = scene
        self.generator = TerrainGenerator(seed: seed)
        self.chunkWidth = Constants.Terrain.chunkWidth
    }

    // MARK: - Public Methods

    /// Generate initial terrain chunks around the spawn point
    func generateInitialTerrain() {
        // Generate flat starting area
        let startingPoints = generator.generateStartingArea(width: chunkWidth)
        let startChunk = TerrainChunk(startX: 0, points: startingPoints)
        addChunk(startChunk)
        generatedUpToX = chunkWidth

        // Generate a few chunks ahead
        generateChunksUpTo(x: loadAheadDistance)
    }

    /// Update terrain based on player position - load ahead, unload behind
    func update(playerX: CGFloat) {
        // Generate new chunks if player is approaching the edge
        let targetX = playerX + loadAheadDistance
        if targetX > generatedUpToX {
            generateChunksUpTo(x: targetX)
        }

        // Unload old chunks that are far behind the player
        let unloadThreshold = playerX - unloadBehindDistance
        unloadChunksBefore(x: unloadThreshold)
    }

    /// Get the terrain surface Y position at a given X
    func surfaceY(at x: CGFloat) -> CGFloat? {
        for chunk in chunks {
            if let y = chunk.surfaceY(at: x) {
                return y
            }
        }
        return nil
    }

    // MARK: - Private Methods

    private func generateChunksUpTo(x: CGFloat) {
        while generatedUpToX < x {
            let points = generator.generateChunk(startX: generatedUpToX, width: chunkWidth)
            let chunk = TerrainChunk(startX: generatedUpToX, points: points)
            addChunk(chunk)
            generatedUpToX += chunkWidth
        }
    }

    private func addChunk(_ chunk: TerrainChunk) {
        chunks.append(chunk)
        scene?.addChild(chunk)
    }

    private func unloadChunksBefore(x: CGFloat) {
        chunks.removeAll { chunk in
            if chunk.endX < x {
                chunk.removeFromParent()
                return true
            }
            return false
        }
    }
}
