//
//  PerlinNoise.swift
//  HillClimbRacer
//
//  Simple 1D Perlin noise implementation for terrain generation.
//

import Foundation

/// Generates smooth pseudo-random noise values
class PerlinNoise {

    // MARK: - Properties

    private let seed: Int
    private let permutation: [Int]

    // MARK: - Initialization

    init(seed: Int = 0) {
        self.seed = seed

        // Create permutation table
        var p = Array(0..<256)
        p.shuffle()
        permutation = p + p  // Double it for overflow handling
    }

    // MARK: - Public Methods

    /// Get noise value at position x (returns value between -1 and 1)
    func noise(_ x: CGFloat) -> CGFloat {
        let xi = Int(floor(x)) & 255
        let xf = x - floor(x)

        let u = fade(xf)

        let a = permutation[xi]
        let b = permutation[xi + 1]

        let gradA = grad(hash: a, x: xf)
        let gradB = grad(hash: b, x: xf - 1)

        return lerp(a: gradA, b: gradB, t: u)
    }

    /// Get layered noise with multiple octaves for more natural terrain
    func octaveNoise(_ x: CGFloat, octaves: Int = 4, persistence: CGFloat = 0.5) -> CGFloat {
        var total: CGFloat = 0
        var frequency: CGFloat = 1
        var amplitude: CGFloat = 1
        var maxValue: CGFloat = 0

        for _ in 0..<octaves {
            total += noise(x * frequency) * amplitude
            maxValue += amplitude
            amplitude *= persistence
            frequency *= 2
        }

        return total / maxValue
    }

    // MARK: - Private Methods

    private func fade(_ t: CGFloat) -> CGFloat {
        // 6t^5 - 15t^4 + 10t^3 (smoothstep)
        t * t * t * (t * (t * 6 - 15) + 10)
    }

    private func lerp(a: CGFloat, b: CGFloat, t: CGFloat) -> CGFloat {
        a + t * (b - a)
    }

    private func grad(hash: Int, x: CGFloat) -> CGFloat {
        // Use hash to determine gradient direction
        (hash & 1) == 0 ? x : -x
    }
}
