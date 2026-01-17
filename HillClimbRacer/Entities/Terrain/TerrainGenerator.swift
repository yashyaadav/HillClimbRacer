//
//  TerrainGenerator.swift
//  HillClimbRacer
//
//  Generates procedural terrain points using layered sine waves and Perlin noise.
//

import CoreGraphics

class TerrainGenerator {

    // MARK: - Properties

    private let noise: PerlinNoise
    private let baseHeight: CGFloat
    private let pointSpacing: CGFloat

    // Hill parameters
    private let largeHillAmplitude: CGFloat
    private let largeHillFrequency: CGFloat
    private let mediumHillAmplitude: CGFloat
    private let mediumHillFrequency: CGFloat
    private let noiseAmplitude: CGFloat
    private let noiseFrequency: CGFloat

    // Difficulty scaling
    private let difficultyScale: CGFloat

    // MARK: - Initialization

    init(seed: Int = Int.random(in: 0...10000)) {
        noise = PerlinNoise(seed: seed)
        baseHeight = Constants.Terrain.baseHeight
        pointSpacing = Constants.Terrain.pointSpacing

        largeHillAmplitude = Constants.Terrain.largeHillAmplitude
        largeHillFrequency = Constants.Terrain.largeHillFrequency
        mediumHillAmplitude = Constants.Terrain.mediumHillAmplitude
        mediumHillFrequency = Constants.Terrain.mediumHillFrequency
        noiseAmplitude = Constants.Terrain.noiseAmplitude
        noiseFrequency = Constants.Terrain.noiseFrequency
        difficultyScale = Constants.Terrain.difficultyScale
    }

    // MARK: - Public Methods

    /// Generate terrain points for a chunk starting at the given X position
    func generateChunk(startX: CGFloat, width: CGFloat) -> [CGPoint] {
        var points: [CGPoint] = []

        var x = startX
        while x <= startX + width {
            let y = generateHeight(at: x)
            points.append(CGPoint(x: x, y: y))
            x += pointSpacing
        }

        return points
    }

    /// Generate the Y height at a specific X position
    func generateHeight(at x: CGFloat) -> CGFloat {
        var y = baseHeight

        // Large rolling hills
        y += sin(x * largeHillFrequency) * largeHillAmplitude

        // Medium variation
        y += sin(x * mediumHillFrequency) * mediumHillAmplitude

        // Fine detail from Perlin noise
        y += noise.noise(x * noiseFrequency) * noiseAmplitude

        // Gradual difficulty increase (hills get bigger as you go further)
        let difficultyMultiplier = 1.0 + (x / difficultyScale)
        y *= difficultyMultiplier

        // Ensure minimum height
        y = max(y, 50)

        return y
    }

    /// Generate a flat starting area for the player
    func generateStartingArea(width: CGFloat) -> [CGPoint] {
        var points: [CGPoint] = []

        var x: CGFloat = 0
        while x <= width {
            // Flat ground with slight transition at the end
            var y = baseHeight
            if x > width * 0.7 {
                // Smooth transition to regular terrain
                let t = (x - width * 0.7) / (width * 0.3)
                let targetY = generateHeight(at: x)
                y = baseHeight + t * (targetY - baseHeight)
            }
            points.append(CGPoint(x: x, y: y))
            x += pointSpacing
        }

        return points
    }
}
