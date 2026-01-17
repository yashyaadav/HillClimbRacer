//
//  TerrainManager.swift
//  HillClimbRacer
//
//  Manages terrain chunk streaming - loads chunks ahead of player,
//  unloads chunks behind to maintain performance.
//

import SpriteKit
import Combine

class TerrainManager: ObservableObject {

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

    // MARK: - Biome Properties

    /// Current active biome
    @Published private(set) var currentBiome: Biome = BiomeDefinitions.defaultBiome

    /// The biome set for this level (nil = endless mode with transitions)
    private var levelBiome: Biome?

    /// Track biome transitions
    private var currentTransition: BiomeTransition?

    /// Distance at which biome transitions occur
    private let biomeLength: CGFloat = BiomeDefinitions.biomeLength

    /// Distance over which transitions occur
    private let transitionDistance: CGFloat = BiomeDefinitions.transitionDistance

    // MARK: - Initialization

    init(scene: SKScene, seed: Int = Int.random(in: 0...10000), biome: Biome? = nil) {
        self.scene = scene
        self.generator = TerrainGenerator(seed: seed)
        self.chunkWidth = Constants.Terrain.chunkWidth
        self.levelBiome = biome
        self.currentBiome = biome ?? BiomeDefinitions.defaultBiome
    }

    // MARK: - Public Methods

    /// Generate initial terrain chunks around the spawn point
    func generateInitialTerrain() {
        // Generate flat starting area with current biome
        let startingPoints = generator.generateStartingArea(width: chunkWidth, biome: currentBiome)
        let startChunk = TerrainChunk(startX: 0, points: startingPoints, biome: currentBiome)
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

        // Update biome transitions in endless mode
        if levelBiome == nil {
            updateBiomeTransition(playerX: playerX)
        }
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

    /// Get the current sky color based on biome and transition
    func currentSkyColor(at playerX: CGFloat) -> SKColor {
        if let transition = currentTransition {
            return transition.interpolatedSkyColor(at: playerX)
        }
        return currentBiome.skyColor
    }

    /// Check if currently in a biome transition
    var isInTransition: Bool {
        currentTransition != nil
    }

    // MARK: - Private Methods

    private func generateChunksUpTo(x: CGFloat) {
        while generatedUpToX < x {
            // Determine biome for this chunk
            let chunkBiome = biomeForPosition(generatedUpToX)

            // Check if we're in a transition zone
            let colors = colorsForChunk(at: generatedUpToX)

            // Generate chunk with biome modifiers
            let points = generator.generateChunk(startX: generatedUpToX, width: chunkWidth, biome: chunkBiome)
            let chunk = TerrainChunk(
                startX: generatedUpToX,
                points: points,
                biome: chunkBiome,
                fillColor: colors.fill,
                strokeColor: colors.stroke
            )
            addChunk(chunk)
            generatedUpToX += chunkWidth
        }
    }

    private func biomeForPosition(_ x: CGFloat) -> Biome {
        // If level has a fixed biome, use it
        if let levelBiome = levelBiome {
            return levelBiome
        }

        // Endless mode: cycle through biomes
        return BiomeDefinitions.biomeForEndlessMode(at: x)
    }

    private func colorsForChunk(at x: CGFloat) -> (fill: SKColor?, stroke: SKColor?) {
        // If in a fixed-biome level, no transition needed
        guard levelBiome == nil else {
            return (nil, nil)
        }

        // Check if we're in a transition zone
        let biomeIndex = Int(x / biomeLength)
        let positionInBiome = x.truncatingRemainder(dividingBy: biomeLength)
        let transitionStart = biomeLength - transitionDistance

        // If we're in the transition zone at the end of a biome
        if positionInBiome > transitionStart {
            let fromBiome = BiomeDefinitions.endlessSequence[biomeIndex % BiomeDefinitions.endlessSequence.count]
            let toBiome = BiomeDefinitions.endlessSequence[(biomeIndex + 1) % BiomeDefinitions.endlessSequence.count]

            let transition = BiomeTransition(
                fromBiome: fromBiome,
                toBiome: toBiome,
                startX: CGFloat(biomeIndex) * biomeLength + transitionStart,
                endX: CGFloat(biomeIndex + 1) * biomeLength
            )

            return (
                transition.interpolatedFillColor(at: x),
                transition.interpolatedStrokeColor(at: x)
            )
        }

        return (nil, nil)
    }

    private func updateBiomeTransition(playerX: CGFloat) {
        let biomeIndex = Int(playerX / biomeLength)
        let positionInBiome = playerX.truncatingRemainder(dividingBy: biomeLength)
        let transitionStart = biomeLength - transitionDistance

        // Update current biome
        let newBiome = BiomeDefinitions.biomeForEndlessMode(at: playerX)
        if newBiome.id != currentBiome.id {
            currentBiome = newBiome
        }

        // Check if we're in a transition zone
        if positionInBiome > transitionStart {
            let fromBiome = BiomeDefinitions.endlessSequence[biomeIndex % BiomeDefinitions.endlessSequence.count]
            let toBiome = BiomeDefinitions.endlessSequence[(biomeIndex + 1) % BiomeDefinitions.endlessSequence.count]

            currentTransition = BiomeTransition(
                fromBiome: fromBiome,
                toBiome: toBiome,
                startX: CGFloat(biomeIndex) * biomeLength + transitionStart,
                endX: CGFloat(biomeIndex + 1) * biomeLength
            )
        } else {
            currentTransition = nil
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
