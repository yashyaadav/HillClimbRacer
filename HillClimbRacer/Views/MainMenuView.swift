//
//  MainMenuView.swift
//  HillClimbRacer
//
//  Main menu screen with animated background, vehicle preview, and menu options.
//

import SwiftUI

struct MainMenuView: View {

    @ObservedObject var gameManager = GameManager.shared
    @ObservedObject var gameCenterManager = GameCenterManager.shared
    @ObservedObject var persistence = PersistenceManager.shared

    @State private var titleOffset: CGFloat = -20
    @State private var titleOpacity: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated background
                AnimatedBackgroundView()

                // Content overlay
                VStack(spacing: 20) {
                    Spacer()
                        .frame(height: geometry.size.height * 0.08)

                    // Animated title
                    VStack(spacing: 4) {
                        Text("HILL CLIMB")
                            .font(.system(size: min(geometry.size.width * 0.12, 52), weight: .black))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color(white: 0.9)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .black.opacity(0.4), radius: 4, x: 2, y: 3)
                            .shadow(color: .blue.opacity(0.3), radius: 8)

                        Text("RACER")
                            .font(.system(size: min(geometry.size.width * 0.09, 40), weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .black.opacity(0.4), radius: 4, x: 2, y: 3)
                            .shadow(color: .orange.opacity(0.4), radius: 6)
                    }
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)

                    // Vehicle preview section
                    if let vehicle = VehicleDefinitions.vehicle(withId: persistence.selectedVehicleId) {
                        VehiclePreviewCard(vehicle: vehicle)
                            .padding(.horizontal, 40)
                    }

                    Spacer()

                    // Menu buttons with enhanced styling
                    VStack(spacing: 14) {
                        EnhancedMenuButton(title: "PLAY", color: .green, icon: "play.fill") {
                            gameManager.startGame()
                        }

                        EnhancedMenuButton(title: "GARAGE", color: .orange, icon: "car.fill") {
                            gameManager.currentScreen = .garage
                        }

                        HStack(spacing: 16) {
                            SmallMenuButton(title: "SETTINGS", icon: "gearshape.fill", color: .blue) {
                                gameManager.currentScreen = .settings
                            }

                            SmallMenuButton(
                                title: "RANKS",
                                icon: "trophy.fill",
                                color: gameCenterManager.isAuthenticated ? .purple : .gray
                            ) {
                                if gameCenterManager.isAuthenticated {
                                    gameCenterManager.showLeaderboards()
                                } else {
                                    gameCenterManager.authenticate()
                                }
                            }
                        }
                    }

                    Spacer()
                        .frame(height: 10)

                    // Stats display
                    StatsDisplayView(
                        bestDistance: persistence.bestDistance,
                        totalCoins: persistence.totalCoins
                    )

                    // Game Center status
                    GameCenterStatusView(isAuthenticated: gameCenterManager.isAuthenticated)

                    Spacer()
                        .frame(height: geometry.safeAreaInsets.bottom + 20)
                }
            }
        }
        .onAppear {
            // Animate title entrance
            withAnimation(.easeOut(duration: 0.8)) {
                titleOffset = 0
                titleOpacity = 1
            }

            // Authenticate Game Center on app launch
            if !gameCenterManager.isAuthenticated {
                gameCenterManager.authenticate()
            }

            // Start menu music
            AudioManager.shared.startMenuMusic()
        }
    }
}

// MARK: - Animated Background View

struct AnimatedBackgroundView: View {
    @State private var cloudOffset: CGFloat = 0
    @State private var hillOffset: CGFloat = 0
    @State private var sunRotation: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sky gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.4, green: 0.7, blue: 1.0),
                        Color(red: 0.2, green: 0.5, blue: 0.9),
                        Color(red: 0.15, green: 0.4, blue: 0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Sun with rays
                SunView(rotation: sunRotation)
                    .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.15)

                // Clouds layer (back)
                CloudsLayer(offset: cloudOffset, speed: 0.5, yPosition: geometry.size.height * 0.12)
                    .opacity(0.6)

                // Clouds layer (front)
                CloudsLayer(offset: cloudOffset * 1.5, speed: 0.8, yPosition: geometry.size.height * 0.22)

                // Background hills (far)
                HillsLayer(
                    offset: hillOffset * 0.3,
                    height: geometry.size.height * 0.25,
                    yPosition: geometry.size.height * 0.7,
                    color: Color(red: 0.3, green: 0.5, blue: 0.3)
                )

                // Foreground hills
                HillsLayer(
                    offset: hillOffset * 0.6,
                    height: geometry.size.height * 0.35,
                    yPosition: geometry.size.height * 0.8,
                    color: Color(red: 0.4, green: 0.65, blue: 0.35)
                )

                // Ground
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.35, green: 0.55, blue: 0.25),
                                Color(red: 0.25, green: 0.45, blue: 0.2)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: geometry.size.height * 0.15)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - geometry.size.height * 0.075)
            }
        }
        .onAppear {
            // Animate clouds
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                cloudOffset = 400
            }

            // Animate hills (slower)
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                hillOffset = 200
            }

            // Animate sun rotation
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                sunRotation = 360
            }
        }
    }
}

// MARK: - Sun View

struct SunView: View {
    let rotation: Double

    var body: some View {
        ZStack {
            // Sun rays
            ForEach(0..<12) { i in
                Rectangle()
                    .fill(Color.yellow.opacity(0.4))
                    .frame(width: 4, height: 30)
                    .offset(y: -50)
                    .rotationEffect(.degrees(Double(i) * 30 + rotation))
            }

            // Sun body
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.yellow, .orange.opacity(0.9)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 35
                    )
                )
                .frame(width: 70, height: 70)
                .shadow(color: .yellow.opacity(0.5), radius: 20)
        }
    }
}

// MARK: - Clouds Layer

struct CloudsLayer: View {
    let offset: CGFloat
    let speed: CGFloat
    let yPosition: CGFloat

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 100) {
                ForEach(0..<5) { i in
                    CloudShape(scale: CGFloat.random(in: 0.6...1.2))
                        .offset(x: CGFloat(i) * 180 - offset.truncatingRemainder(dividingBy: 900))
                }
            }
            .position(x: geometry.size.width / 2, y: yPosition)
        }
    }
}

struct CloudShape: View {
    let scale: CGFloat

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.white.opacity(0.9))
                .frame(width: 60 * scale, height: 30 * scale)

            Ellipse()
                .fill(Color.white.opacity(0.9))
                .frame(width: 40 * scale, height: 25 * scale)
                .offset(x: -25 * scale, y: 5 * scale)

            Ellipse()
                .fill(Color.white.opacity(0.9))
                .frame(width: 45 * scale, height: 28 * scale)
                .offset(x: 20 * scale, y: 3 * scale)
        }
    }
}

// MARK: - Hills Layer

struct HillsLayer: View {
    let offset: CGFloat
    let height: CGFloat
    let yPosition: CGFloat
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            HillWave(amplitude: height * 0.4, frequency: 0.005, phase: offset)
                .fill(color)
                .frame(height: height)
                .position(x: geometry.size.width / 2, y: yPosition)
        }
    }
}

struct HillWave: Shape {
    let amplitude: CGFloat
    let frequency: CGFloat
    let phase: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: 0, y: rect.height))

        for x in stride(from: 0, through: rect.width, by: 2) {
            let y = amplitude * sin((x + phase) * frequency * .pi * 2) + rect.height * 0.5
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()

        return path
    }
}

// MARK: - Vehicle Preview Card

struct VehiclePreviewCard: View {
    let vehicle: VehicleConfig
    @State private var bounceOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 8) {
            // Vehicle preview using the enhanced preview from GarageView
            ZStack {
                // Ground line
                Rectangle()
                    .fill(Color.brown.opacity(0.6))
                    .frame(height: 4)
                    .offset(y: 25)

                // Vehicle
                HStack(spacing: vehicle.wheelBase / 6) {
                    // Rear wheel
                    WheelPreview(radius: vehicle.wheelRadius * 0.9, color: vehicle.wheelColor.color)

                    // Chassis
                    ChassisPreview(
                        size: CGSize(width: vehicle.chassisSize.width * 0.4, height: vehicle.chassisSize.height * 0.4),
                        color: vehicle.chassisColor.color
                    )
                    .offset(y: -5)

                    // Front wheel
                    WheelPreview(radius: vehicle.wheelRadius * 0.9, color: vehicle.wheelColor.color)
                }
                .offset(y: bounceOffset)
            }
            .frame(height: 60)

            // Vehicle name
            Text(vehicle.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.2))
                .shadow(color: .black.opacity(0.2), radius: 4)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                bounceOffset = -5
            }
        }
    }
}

struct WheelPreview: View {
    let radius: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: radius, height: radius)
                .shadow(color: .black.opacity(0.3), radius: 2, y: 1)

            Circle()
                .fill(Color.gray.opacity(0.8))
                .frame(width: radius * 0.4, height: radius * 0.4)
        }
    }
}

struct ChassisPreview: View {
    let size: CGSize
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size.height * 0.15)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.95), color, color.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size.width, height: size.height)
                .shadow(color: .black.opacity(0.3), radius: 3, y: 2)

            // Window
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.blue.opacity(0.5))
                .frame(width: size.width * 0.3, height: size.height * 0.35)
                .offset(x: size.width * 0.1, y: -size.height * 0.1)
        }
    }
}

// MARK: - Enhanced Menu Button

struct EnhancedMenuButton: View {
    let title: String
    let color: Color
    let icon: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            AudioManager.shared.playSound(.buttonTap)
            action()
        }) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .frame(width: 200, height: 52)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: color.opacity(0.5), radius: 6, x: 0, y: 4)
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Legacy Menu Button (kept for compatibility)

struct MenuButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        EnhancedMenuButton(title: title, color: color, icon: "play.fill", action: action)
    }
}

// MARK: - Small Menu Button

struct SmallMenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            AudioManager.shared.playSound(.buttonTap)
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(width: 90, height: 60)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.25), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            )
            .shadow(color: color.opacity(0.5), radius: 3, x: 0, y: 3)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Stats Display View

struct StatsDisplayView: View {
    let bestDistance: CGFloat
    let totalCoins: Int

    var body: some View {
        HStack(spacing: 20) {
            if bestDistance > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "flag.checkered")
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(Int(bestDistance))m")
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.9))
                }
            }

            HStack(spacing: 4) {
                CoinIcon(size: 18)
                Text("\(totalCoins)")
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .font(.subheadline)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.2))
        )
    }
}

// MARK: - Game Center Status View

struct GameCenterStatusView: View {
    let isAuthenticated: Bool

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isAuthenticated ? Color.green : Color.red.opacity(0.7))
                .frame(width: 8, height: 8)
            Text(isAuthenticated ? "Game Center Connected" : "Game Center Offline")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
    }
}

#Preview {
    MainMenuView()
}
