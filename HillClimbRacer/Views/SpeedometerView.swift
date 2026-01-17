//
//  SpeedometerView.swift
//  HillClimbRacer
//
//  Digital speedometer display with color-coded bar indicator.
//

import SwiftUI

/// Digital speedometer showing current vehicle speed
struct SpeedometerView: View {

    let speed: CGFloat
    let maxSpeed: CGFloat

    init(speed: CGFloat, maxSpeed: CGFloat = 150) {
        self.speed = speed
        self.maxSpeed = maxSpeed
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // Speed value
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(Int(speed))")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(speedColor)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.1), value: Int(speed))

                Text("km/h")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.7))
            }

            // Speed bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.black.opacity(0.4))

                    // Speed level
                    RoundedRectangle(cornerRadius: 3)
                        .fill(speedGradient)
                        .frame(width: max(0, geometry.size.width * min(speedRatio, 1.0)))
                        .animation(.easeInOut(duration: 0.15), value: speedRatio)

                    // Border
                    RoundedRectangle(cornerRadius: 3)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                }
            }
            .frame(width: 60, height: 6)
        }
    }

    private var speedRatio: CGFloat {
        min(abs(speed) / maxSpeed, 1.0)
    }

    private var speedColor: Color {
        if speedRatio > 0.8 {
            return .red
        } else if speedRatio > 0.5 {
            return .orange
        } else {
            return .white
        }
    }

    private var speedGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [.green, .yellow, .orange, .red]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - RPM Gauge (Optional)

struct RPMGaugeView: View {

    let rpm: CGFloat
    let maxRPM: CGFloat

    init(rpm: CGFloat, maxRPM: CGFloat = 8000) {
        self.rpm = rpm
        self.maxRPM = maxRPM
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            // RPM value
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(Int(rpm / 100) * 100)")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(rpmColor)

                Text("RPM")
                    .font(.system(size: 8))
                    .foregroundColor(.white.opacity(0.6))
            }

            // RPM bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.black.opacity(0.4))

                    RoundedRectangle(cornerRadius: 2)
                        .fill(rpmGradient)
                        .frame(width: max(0, geometry.size.width * rpmRatio))
                        .animation(.easeInOut(duration: 0.1), value: rpmRatio)
                }
            }
            .frame(width: 50, height: 4)
        }
    }

    private var rpmRatio: CGFloat {
        min(rpm / maxRPM, 1.0)
    }

    private var rpmColor: Color {
        if rpmRatio > 0.85 {
            return .red
        } else if rpmRatio > 0.7 {
            return .orange
        } else {
            return .white.opacity(0.8)
        }
    }

    private var rpmGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [.cyan, .green, .yellow, .red]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()

        VStack(spacing: 20) {
            SpeedometerView(speed: 45)
            SpeedometerView(speed: 85)
            SpeedometerView(speed: 120)
            SpeedometerView(speed: 145)

            Divider()

            RPMGaugeView(rpm: 3500)
            RPMGaugeView(rpm: 6000)
            RPMGaugeView(rpm: 7500)
        }
        .padding()
    }
}
