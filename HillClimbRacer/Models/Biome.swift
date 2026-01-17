//
//  Biome.swift
//  HillClimbRacer
//
//  Defines a terrain biome with colors and terrain generation modifiers.
//

import SpriteKit
import SwiftUI

/// Represents a terrain biome with visual and gameplay properties
struct Biome: Identifiable, Equatable {

    // MARK: - Properties

    /// Unique identifier for this biome
    let id: String

    /// Display name for the biome
    let name: String

    /// Sky color for this biome
    let skyColor: SKColor

    /// Terrain fill color (ground/dirt)
    let terrainFillColor: SKColor

    /// Terrain stroke color (grass/snow on top)
    let terrainStrokeColor: SKColor

    // MARK: - Terrain Generation Modifiers

    /// Multiplier for hill amplitude (1.0 = normal, >1.0 = steeper)
    let hillAmplitudeMultiplier: CGFloat

    /// Multiplier for hill frequency (1.0 = normal, >1.0 = more waves)
    let hillFrequencyMultiplier: CGFloat

    /// Multiplier for noise amplitude (surface roughness)
    let noiseAmplitudeMultiplier: CGFloat

    // MARK: - Visual Effects

    /// Whether this biome has weather particles (rain, snow, etc.)
    let hasWeatherParticles: Bool

    /// Type of weather particles, if any
    let weatherType: WeatherType

    // MARK: - Initialization

    init(
        id: String,
        name: String,
        skyColor: SKColor,
        terrainFillColor: SKColor,
        terrainStrokeColor: SKColor,
        hillAmplitudeMultiplier: CGFloat = 1.0,
        hillFrequencyMultiplier: CGFloat = 1.0,
        noiseAmplitudeMultiplier: CGFloat = 1.0,
        hasWeatherParticles: Bool = false,
        weatherType: WeatherType = .none
    ) {
        self.id = id
        self.name = name
        self.skyColor = skyColor
        self.terrainFillColor = terrainFillColor
        self.terrainStrokeColor = terrainStrokeColor
        self.hillAmplitudeMultiplier = hillAmplitudeMultiplier
        self.hillFrequencyMultiplier = hillFrequencyMultiplier
        self.noiseAmplitudeMultiplier = noiseAmplitudeMultiplier
        self.hasWeatherParticles = hasWeatherParticles
        self.weatherType = weatherType
    }

    // MARK: - SwiftUI Colors

    var skySwiftUIColor: Color {
        Color(skyColor)
    }

    var terrainFillSwiftUIColor: Color {
        Color(terrainFillColor)
    }

    var terrainStrokeSwiftUIColor: Color {
        Color(terrainStrokeColor)
    }

    // MARK: - Equatable

    static func == (lhs: Biome, rhs: Biome) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Weather Type

enum WeatherType: String, CaseIterable {
    case none
    case rain
    case snow
    case sandstorm
    case leaves

    var particleFileName: String? {
        switch self {
        case .none:
            return nil
        case .rain:
            return "RainParticle"
        case .snow:
            return "SnowParticle"
        case .sandstorm:
            return "SandParticle"
        case .leaves:
            return "LeavesParticle"
        }
    }
}

// MARK: - Biome Transition

/// Represents a transition between two biomes
struct BiomeTransition {
    let fromBiome: Biome
    let toBiome: Biome
    let startX: CGFloat
    let endX: CGFloat

    /// Get the interpolated sky color at a given X position
    func interpolatedSkyColor(at x: CGFloat) -> SKColor {
        let t = progress(at: x)
        return interpolateColor(from: fromBiome.skyColor, to: toBiome.skyColor, t: t)
    }

    /// Get the interpolated terrain fill color at a given X position
    func interpolatedFillColor(at x: CGFloat) -> SKColor {
        let t = progress(at: x)
        return interpolateColor(from: fromBiome.terrainFillColor, to: toBiome.terrainFillColor, t: t)
    }

    /// Get the interpolated terrain stroke color at a given X position
    func interpolatedStrokeColor(at x: CGFloat) -> SKColor {
        let t = progress(at: x)
        return interpolateColor(from: fromBiome.terrainStrokeColor, to: toBiome.terrainStrokeColor, t: t)
    }

    /// Get the transition progress (0-1) at a given X position
    func progress(at x: CGFloat) -> CGFloat {
        guard endX > startX else { return 1.0 }
        return max(0, min(1, (x - startX) / (endX - startX)))
    }

    /// Interpolate between two colors
    private func interpolateColor(from: SKColor, to: SKColor, t: CGFloat) -> SKColor {
        var fromR: CGFloat = 0, fromG: CGFloat = 0, fromB: CGFloat = 0, fromA: CGFloat = 0
        var toR: CGFloat = 0, toG: CGFloat = 0, toB: CGFloat = 0, toA: CGFloat = 0

        from.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
        to.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)

        let r = fromR + (toR - fromR) * t
        let g = fromG + (toG - fromG) * t
        let b = fromB + (toB - fromB) * t
        let a = fromA + (toA - fromA) * t

        return SKColor(red: r, green: g, blue: b, alpha: a)
    }
}
