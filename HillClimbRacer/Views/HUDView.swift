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

    private let gaugeWidth: CGFloat = 120
    private let gaugeHeight: CGFloat = 20

    var body: some View {
        HStack(spacing: 8) {
            // Fuel pump icon
            Image(systemName: "fuelpump.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(fuelColor)

            // Gauge container
            ZStack(alignment: .leading) {
                // Background with tick marks
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.black.opacity(0.5))

                        // Fuel level with gradient
                        RoundedRectangle(cornerRadius: 4)
                            .fill(fuelGradient)
                            .frame(width: max(0, geometry.size.width * (fuel / 100.0)))

                        // Tick marks
                        HStack(spacing: 0) {
                            ForEach(0..<5) { i in
                                Spacer()
                                if i < 4 {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.3))
                                        .frame(width: 1, height: geometry.size.height * 0.4)
                                }
                            }
                        }

                        // Gauge border
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                    }
                }
                .frame(width: gaugeWidth, height: gaugeHeight)
            }

            // Percentage text
            Text("\(Int(fuel))%")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 35, alignment: .trailing)
        }
        // Pulsing effect when fuel is critically low (< 20%)
        .opacity(isLowFuel ? (isPulsing ? 0.5 : 1.0) : 1.0)
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

    private var fuelGradient: LinearGradient {
        let baseColor = fuelColor
        return LinearGradient(
            gradient: Gradient(colors: [
                baseColor.opacity(0.8),
                baseColor,
                baseColor.opacity(0.9)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    HUDView()
        .background(Color.blue)
}
