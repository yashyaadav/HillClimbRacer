//
//  TerrainGenerator.swift
//  HillClimbRacer
//
//  Generates procedural terrain points using layered sine waves and Perlin noise.
//  Enhanced with jump ramps, steep sections, plateaus, and progressive difficulty.
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

    // Feature parameters
    private let rampInterval: CGFloat = 1000    // Jump ramps every ~1000 units
    private let rampWidth: CGFloat = 80         // Width of jump ramp
    private let rampHeight: CGFloat = 60        // Max height of jump ramp
    private let steepSectionInterval: CGFloat = 2500  // Steep sections every ~2500 units
    private let plateauInterval: CGFloat = 3500       // Plateaus every ~3500 units

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
    func generateChunk(startX: CGFloat, width: CGFloat, biome: Biome? = nil) -> [CGPoint] {
        var points: [CGPoint] = []

        var x = startX
        while x <= startX + width {
            let y = generateHeight(at: x, biome: biome)
            points.append(CGPoint(x: x, y: y))
            x += pointSpacing
        }

        return points
    }

    /// Generate the Y height at a specific X position with optional biome modifiers
    func generateHeight(at x: CGFloat, biome: Biome? = nil) -> CGFloat {
        // Skip features in starting area
        guard x > 800 else {
            return baseHeight
        }

        var y = baseHeight

        // Get biome modifiers (default to 1.0 if no biome)
        let amplitudeMultiplier = biome?.hillAmplitudeMultiplier ?? 1.0
        let frequencyMultiplier = biome?.hillFrequencyMultiplier ?? 1.0
        let noiseMultiplier = biome?.noiseAmplitudeMultiplier ?? 1.0

        // Progressive difficulty - increase amplitude and frequency with distance
        let distanceFactor = min(x / 10000, 2.0)  // Cap at 2x
        let progressiveAmplitude = 1.0 + distanceFactor * 0.5
        let progressiveFrequency = 1.0 + distanceFactor * 0.3

        // Large rolling hills (modified by biome and distance)
        y += sin(x * largeHillFrequency * frequencyMultiplier * progressiveFrequency) *
             largeHillAmplitude * amplitudeMultiplier * progressiveAmplitude

        // Medium variation with phase offset for variety
        y += sin(x * mediumHillFrequency * frequencyMultiplier * progressiveFrequency + 1.5) *
             mediumHillAmplitude * amplitudeMultiplier * progressiveAmplitude

        // Small hills layer for additional variation
        y += sin(x * 0.008 * frequencyMultiplier) * 40 * amplitudeMultiplier

        // Use octave noise instead of simple noise for more natural detail
        let octaveNoiseValue = noise.octaveNoise(x * noiseFrequency, octaves: 4, persistence: 0.5)
        y += octaveNoiseValue * noiseAmplitude * noiseMultiplier * progressiveAmplitude * 1.5

        // Add occasional steep sections
        y += steepSectionModifier(at: x) * amplitudeMultiplier

        // Add occasional plateaus
        y += plateauModifier(at: x)

        // Add jump ramps
        y += jumpRampModifier(at: x) * amplitudeMultiplier

        // Gradual overall difficulty increase
        let difficultyMultiplier = 1.0 + (x / difficultyScale)
        y *= difficultyMultiplier

        // Ensure minimum height
        y = max(y, 50)

        return y
    }

    /// Generate a flat starting area for the player
    func generateStartingArea(width: CGFloat, biome: Biome? = nil) -> [CGPoint] {
        var points: [CGPoint] = []

        var x: CGFloat = 0
        while x <= width {
            // Flat ground with slight transition at the end
            var y = baseHeight
            if x > width * 0.7 {
                // Smooth transition to regular terrain
                let t = (x - width * 0.7) / (width * 0.3)
                let targetY = generateHeight(at: x, biome: biome)
                y = baseHeight + t * (targetY - baseHeight)
            }
            points.append(CGPoint(x: x, y: y))
            x += pointSpacing
        }

        return points
    }

    // MARK: - Terrain Feature Modifiers

    /// Add jump ramp modifier - creates periodic ramps for jumping
    private func jumpRampModifier(at x: CGFloat) -> CGFloat {
        // Use noise to add some randomness to ramp positions
        let noiseOffset = noise.noise(x * 0.001) * 200
        let effectiveInterval = rampInterval + noiseOffset
        guard effectiveInterval > 0 else { return 0 }

        let rampPosition = x.truncatingRemainder(dividingBy: effectiveInterval)

        // Check if we're in a ramp zone
        if rampPosition < rampWidth {
            // Smooth ramp shape using sine curve
            let t = rampPosition / rampWidth
            let rampShape = sin(t * .pi)  // Goes 0 -> 1 -> 0

            // Scale ramp height with distance for bigger jumps later
            let distanceScale = 1.0 + min(x / 15000, 1.0)

            return rampShape * rampHeight * distanceScale
        }

        return 0
    }

    /// Add steep section modifier - creates challenging uphill/downhill sections
    private func steepSectionModifier(at x: CGFloat) -> CGFloat {
        let sectionPosition = x.truncatingRemainder(dividingBy: steepSectionInterval)
        let steepWidth: CGFloat = 300

        // Check if we're in a steep section
        if sectionPosition < steepWidth {
            let t = sectionPosition / steepWidth
            // Create an S-curve for steep section
            let steepHeight: CGFloat = 100 * (1.0 + min(x / 20000, 1.0))

            // Smoothstep for gradual entry and exit
            let smoothT = t * t * (3 - 2 * t)
            return smoothT * steepHeight
        } else if sectionPosition < steepWidth * 2 {
            // Plateau at top of steep section
            let steepHeight: CGFloat = 100 * (1.0 + min(x / 20000, 1.0))
            return steepHeight
        } else if sectionPosition < steepWidth * 3 {
            // Descent from steep section
            let t = (sectionPosition - steepWidth * 2) / steepWidth
            let steepHeight: CGFloat = 100 * (1.0 + min(x / 20000, 1.0))
            let smoothT = 1 - (t * t * (3 - 2 * t))
            return smoothT * steepHeight
        }

        return 0
    }

    /// Add plateau modifier - creates flat rest areas
    private func plateauModifier(at x: CGFloat) -> CGFloat {
        let sectionPosition = x.truncatingRemainder(dividingBy: plateauInterval)
        let plateauWidth: CGFloat = 200
        let transitionWidth: CGFloat = 50

        // Check if we're approaching, in, or leaving a plateau
        if sectionPosition < transitionWidth {
            // Smoothly rise to plateau
            let t = sectionPosition / transitionWidth
            return t * t * 20  // Gradual rise
        } else if sectionPosition < plateauWidth - transitionWidth {
            // Flat plateau area (suppress other features slightly)
            return 20
        } else if sectionPosition < plateauWidth {
            // Smoothly descend from plateau
            let t = (sectionPosition - (plateauWidth - transitionWidth)) / transitionWidth
            return (1 - t * t) * 20
        }

        return 0
    }
}
