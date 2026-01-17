//
//  BiomeDefinitions.swift
//  HillClimbRacer
//
//  Predefined biome configurations for different terrain themes.
//

import SpriteKit

/// Collection of all available biomes in the game
enum BiomeDefinitions {

    // MARK: - Biome Instances

    /// Grassland - Default starting biome with gentle hills
    static let grassland = Biome(
        id: "grassland",
        name: "Grassland",
        skyColor: SKColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0),  // Light blue
        terrainFillColor: SKColor(red: 0.4, green: 0.26, blue: 0.13, alpha: 1.0),  // Brown dirt
        terrainStrokeColor: SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0),  // Green grass
        hillAmplitudeMultiplier: 1.0,
        hillFrequencyMultiplier: 1.0,
        noiseAmplitudeMultiplier: 1.0,
        hasWeatherParticles: false,
        weatherType: .none
    )

    /// Desert - Sandy terrain with flatter, more wavy hills
    static let desert = Biome(
        id: "desert",
        name: "Desert Dunes",
        skyColor: SKColor(red: 0.95, green: 0.85, blue: 0.6, alpha: 1.0),  // Sandy yellow
        terrainFillColor: SKColor(red: 0.82, green: 0.7, blue: 0.45, alpha: 1.0),  // Tan sand
        terrainStrokeColor: SKColor(red: 0.9, green: 0.8, blue: 0.55, alpha: 1.0),  // Light tan
        hillAmplitudeMultiplier: 0.7,  // Flatter
        hillFrequencyMultiplier: 1.3,  // More waves (dunes)
        noiseAmplitudeMultiplier: 0.8,
        hasWeatherParticles: true,
        weatherType: .sandstorm
    )

    /// Arctic - Snowy terrain with steeper, icy hills
    static let arctic = Biome(
        id: "arctic",
        name: "Frozen Peaks",
        skyColor: SKColor(red: 0.75, green: 0.85, blue: 0.95, alpha: 1.0),  // Pale blue
        terrainFillColor: SKColor(red: 0.85, green: 0.88, blue: 0.92, alpha: 1.0),  // White/gray ice
        terrainStrokeColor: SKColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0),  // White snow
        hillAmplitudeMultiplier: 1.3,  // Steeper peaks
        hillFrequencyMultiplier: 0.9,
        noiseAmplitudeMultiplier: 1.4,  // More rugged
        hasWeatherParticles: true,
        weatherType: .snow
    )

    /// Forest - Dense woodland with dark, steep terrain
    static let forest = Biome(
        id: "forest",
        name: "Deep Forest",
        skyColor: SKColor(red: 0.25, green: 0.4, blue: 0.3, alpha: 1.0),  // Dark green tint
        terrainFillColor: SKColor(red: 0.25, green: 0.18, blue: 0.1, alpha: 1.0),  // Dark brown
        terrainStrokeColor: SKColor(red: 0.15, green: 0.35, blue: 0.15, alpha: 1.0),  // Dark green
        hillAmplitudeMultiplier: 1.25,  // Steeper
        hillFrequencyMultiplier: 1.1,
        noiseAmplitudeMultiplier: 1.2,
        hasWeatherParticles: true,
        weatherType: .rain
    )

    // MARK: - Biome Access

    /// All available biomes in order
    static let all: [Biome] = [grassland, desert, arctic, forest]

    /// Get biome by ID
    static func biome(withId id: String) -> Biome? {
        all.first { $0.id == id }
    }

    /// Default biome (grassland)
    static var defaultBiome: Biome {
        grassland
    }

    /// Get a random biome (excluding the provided one)
    static func randomBiome(excluding: Biome? = nil) -> Biome {
        let available = excluding != nil ? all.filter { $0.id != excluding?.id } : all
        return available.randomElement() ?? grassland
    }

    // MARK: - Biome Sequence for Endless Mode

    /// Biome sequence for endless mode (cycles through all biomes)
    static let endlessSequence: [Biome] = [grassland, desert, arctic, forest]

    /// Get the biome for a given X position in endless mode
    static func biomeForEndlessMode(at x: CGFloat) -> Biome {
        let biomeLength: CGFloat = 5000  // Change biome every 5000 units
        let index = Int(x / biomeLength) % endlessSequence.count
        return endlessSequence[index]
    }

    /// Get the next biome in the sequence
    static func nextBiome(after current: Biome) -> Biome {
        guard let currentIndex = endlessSequence.firstIndex(where: { $0.id == current.id }) else {
            return grassland
        }
        let nextIndex = (currentIndex + 1) % endlessSequence.count
        return endlessSequence[nextIndex]
    }

    // MARK: - Biome Transition Configuration

    /// Distance over which biome transitions occur
    static let transitionDistance: CGFloat = 500

    /// Distance between biome changes in endless mode
    static let biomeLength: CGFloat = 5000
}
