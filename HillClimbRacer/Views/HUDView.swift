//
//  HUDView.swift
//  HillClimbRacer
//
//  SwiftUI overlay showing game information: fuel, coins, distance.
//  This is a placeholder that will be expanded in Phase 5.
//

import SwiftUI

struct HUDView: View {

    // MARK: - State (will be connected to GameState in Phase 4)

    @State private var fuel: CGFloat = 100.0
    @State private var coins: Int = 0
    @State private var distance: Int = 0

    var body: some View {
        VStack {
            // Top HUD bar
            HStack(alignment: .top, spacing: 20) {
                // Fuel gauge
                VStack(alignment: .leading, spacing: 4) {
                    Text("FUEL")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    FuelGaugeView(fuel: fuel)
                }

                Spacer()

                // Coins
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text("$")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        )

                    Text("\(coins)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                Spacer()

                // Distance
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(distance)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("meters")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            Spacer()

            // Control hints (will be replaced with actual touch zones)
            HStack {
                Text("BRAKE")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity)

                Text("GAS")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Fuel Gauge

struct FuelGaugeView: View {
    let fuel: CGFloat
    @State private var isPulsing = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.black.opacity(0.5))

                // Fuel level
                RoundedRectangle(cornerRadius: 4)
                    .fill(fuelColor)
                    .frame(width: geometry.size.width * (fuel / 100.0))
            }
        }
        .frame(width: 100, height: 16)
        // Pulsing effect when fuel is critically low (< 20%) - Unity pattern
        .opacity(isLowFuel ? (isPulsing ? 0.4 : 1.0) : 1.0)
        .animation(isLowFuel ? .easeInOut(duration: 0.3).repeatForever(autoreverses: true) : .default, value: isPulsing)
        .onAppear { isPulsing = true }
        .onChange(of: fuel) { isPulsing = true }
    }

    private var isLowFuel: Bool {
        fuel < 20
    }

    private var fuelColor: Color {
        if fuel > 50 {
            return .green
        } else if fuel > 25 {
            return .yellow
        } else {
            return .red
        }
    }
}

#Preview {
    HUDView()
        .background(Color.blue)
}
