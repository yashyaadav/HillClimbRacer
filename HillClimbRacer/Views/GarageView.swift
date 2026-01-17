//
//  GarageView.swift
//  HillClimbRacer
//
//  Vehicle selection and upgrade screen with adaptive layout.
//

import SwiftUI

struct GarageView: View {

    @ObservedObject var gameManager = GameManager.shared
    @ObservedObject var persistence = PersistenceManager.shared

    @State private var selectedVehicleIndex: Int = 0
    @State private var selectedUpgrade: UpgradeType = .engine
    @State private var showUnlockAlert = false
    @State private var showInsufficientFundsAlert = false

    private var vehicles: [VehicleConfig] { VehicleDefinitions.all }

    private var selectedVehicle: VehicleConfig {
        vehicles[selectedVehicleIndex]
    }

    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.height < 700
            let spacing: CGFloat = isCompact ? 10 : 16

            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.15, blue: 0.2),
                        Color(red: 0.1, green: 0.1, blue: 0.15)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: spacing) {
                        // Header
                        headerView

                        // Vehicle carousel
                        vehicleCarousel(isCompact: isCompact)

                        // Vehicle info
                        vehicleInfoView(isCompact: isCompact)

                        // Upgrade section (only for unlocked vehicles)
                        if persistence.isVehicleUnlocked(selectedVehicle.id) {
                            upgradeSection(isCompact: isCompact)
                        }

                        // Bottom padding for safe area
                        Spacer()
                            .frame(height: geometry.safeAreaInsets.bottom + 20)
                    }
                    .padding(.top)
                }
            }
        }
        .onAppear {
            // Set initial selection to currently selected vehicle
            if let index = vehicles.firstIndex(where: { $0.id == persistence.selectedVehicleId }) {
                selectedVehicleIndex = index
            }
        }
        .alert("Unlock Vehicle", isPresented: $showUnlockAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Unlock") {
                _ = persistence.unlockVehicle(selectedVehicle.id)
            }
        } message: {
            Text("Unlock \(selectedVehicle.name) for \(selectedVehicle.unlockCost) coins?")
        }
        .alert("Insufficient Coins", isPresented: $showInsufficientFundsAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You need more coins to purchase this upgrade.")
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Button(action: {
                gameManager.currentScreen = .mainMenu
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Spacer()

            Text("GARAGE")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Spacer()

            // Coins display with metal style
            HStack(spacing: 4) {
                CoinIcon(size: 20)
                Text("\(persistence.totalCoins)")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Vehicle Carousel

    private func vehicleCarousel(isCompact: Bool) -> some View {
        let height: CGFloat = isCompact ? 120 : 160

        return HStack(spacing: 20) {
            // Previous button
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    selectedVehicleIndex = (selectedVehicleIndex - 1 + vehicles.count) % vehicles.count
                }
            }) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title)
                    .foregroundColor(.white.opacity(0.7))
            }

            // Vehicle preview
            ZStack {
                // Background with subtle glow
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: selectedVehicle.chassisColor.color.opacity(0.3), radius: 10)

                VStack(spacing: 8) {
                    // Enhanced vehicle visual
                    EnhancedVehiclePreview(vehicle: selectedVehicle, scale: isCompact ? 0.8 : 1.0)

                    // Lock icon for locked vehicles
                    if !persistence.isVehicleUnlocked(selectedVehicle.id) {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                            Text("\(selectedVehicle.unlockCost)")
                            CoinIcon(size: 12)
                        }
                        .foregroundColor(.orange)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)
                    }
                }
            }
            .frame(height: height)
            .frame(maxWidth: .infinity)

            // Next button
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    selectedVehicleIndex = (selectedVehicleIndex + 1) % vehicles.count
                }
            }) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Vehicle Info

    private func vehicleInfoView(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 6 : 8) {
            Text(selectedVehicle.name)
                .font(isCompact ? .title3 : .title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(selectedVehicle.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Stats bars
            VStack(spacing: isCompact ? 4 : 6) {
                let stats = selectedVehicle.normalizedStats
                EnhancedStatBar(label: "Speed", value: stats.speed, color: .red, icon: "speedometer")
                EnhancedStatBar(label: "Power", value: stats.power, color: .orange, icon: "bolt.fill")
                EnhancedStatBar(label: "Fuel", value: stats.fuel, color: .green, icon: "fuelpump.fill")
                EnhancedStatBar(label: "Handling", value: stats.handling, color: .blue, icon: "steeringwheel")
            }
            .padding(.horizontal, isCompact ? 20 : 40)
            .padding(.top, isCompact ? 4 : 8)

            // Select/Unlock button
            actionButton
        }
        .padding(isCompact ? 12 : 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var actionButton: some View {
        Group {
            if persistence.isVehicleUnlocked(selectedVehicle.id) {
                if persistence.selectedVehicleId == selectedVehicle.id {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("SELECTED")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                    .padding(.vertical, 8)
                } else {
                    Button(action: {
                        persistence.selectedVehicleId = selectedVehicle.id
                        AudioManager.shared.playSound(.buttonTap)
                    }) {
                        Text("SELECT")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(10)
                            .shadow(color: Color.blue.opacity(0.4), radius: 4, y: 2)
                    }
                }
            } else {
                Button(action: {
                    if persistence.totalCoins >= selectedVehicle.unlockCost {
                        showUnlockAlert = true
                    } else {
                        showInsufficientFundsAlert = true
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.open.fill")
                        Text("UNLOCK")
                        Text("\(selectedVehicle.unlockCost)")
                        CoinIcon(size: 14)
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [Color.orange, Color.orange.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(10)
                    .shadow(color: Color.orange.opacity(0.4), radius: 4, y: 2)
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Upgrade Section

    private func upgradeSection(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 8 : 12) {
            // Upgrade category tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: isCompact ? 8 : 12) {
                    ForEach(UpgradeType.allCases, id: \.self) { upgrade in
                        UpgradeCategoryButton(
                            upgrade: upgrade,
                            isSelected: selectedUpgrade == upgrade,
                            level: persistence.upgradeLevel(for: selectedVehicle.id, upgradeType: upgrade),
                            isCompact: isCompact
                        ) {
                            selectedUpgrade = upgrade
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Upgrade details
            UpgradeDetailView(
                upgradeType: selectedUpgrade,
                vehicleId: selectedVehicle.id,
                isCompact: isCompact,
                onUpgrade: { success in
                    if !success {
                        showInsufficientFundsAlert = true
                    }
                }
            )
        }
    }
}

// MARK: - Enhanced Vehicle Preview

struct EnhancedVehiclePreview: View {
    let vehicle: VehicleConfig
    var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Shadow underneath
            Ellipse()
                .fill(Color.black.opacity(0.3))
                .frame(width: 100 * scale, height: 15 * scale)
                .offset(y: 30 * scale)
                .blur(radius: 5)

            HStack(spacing: vehicle.wheelBase / 5 * scale) {
                // Rear wheel with detail
                WheelView(
                    radius: vehicle.wheelRadius * 1.3 * scale,
                    color: vehicle.wheelColor.color,
                    hubColor: Color.gray
                )

                // Enhanced chassis
                ChassisView(
                    size: CGSize(
                        width: vehicle.chassisSize.width * 0.55 * scale,
                        height: vehicle.chassisSize.height * 0.55 * scale
                    ),
                    color: vehicle.chassisColor.color,
                    vehicleType: vehicle.id
                )
                .offset(y: -8 * scale)

                // Front wheel with detail
                WheelView(
                    radius: vehicle.wheelRadius * 1.3 * scale,
                    color: vehicle.wheelColor.color,
                    hubColor: Color.gray
                )
            }
        }
    }
}

// MARK: - Wheel View with Details

struct WheelView: View {
    let radius: CGFloat
    let color: Color
    let hubColor: Color

    var body: some View {
        ZStack {
            // Tire
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color, color.opacity(0.7)],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
                .frame(width: radius, height: radius)
                .shadow(color: .black.opacity(0.4), radius: 3, y: 2)

            // Tire tread pattern (ring)
            Circle()
                .stroke(color.opacity(0.6), lineWidth: radius * 0.15)
                .frame(width: radius * 0.85, height: radius * 0.85)

            // Hub cap
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.9), hubColor],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: radius * 0.4
                    )
                )
                .frame(width: radius * 0.45, height: radius * 0.45)

            // Hub highlight
            Circle()
                .fill(Color.white.opacity(0.4))
                .frame(width: radius * 0.2, height: radius * 0.2)
                .offset(x: -radius * 0.08, y: -radius * 0.08)

            // Spokes (simplified)
            ForEach(0..<5) { i in
                Rectangle()
                    .fill(hubColor.opacity(0.7))
                    .frame(width: 2, height: radius * 0.3)
                    .offset(y: -radius * 0.15)
                    .rotationEffect(.degrees(Double(i) * 72))
            }
        }
    }
}

// MARK: - Chassis View with Details

struct ChassisView: View {
    let size: CGSize
    let color: Color
    let vehicleType: String

    var body: some View {
        ZStack {
            // Main body with gradient
            RoundedRectangle(cornerRadius: size.height * 0.2)
                .fill(
                    LinearGradient(
                        colors: [
                            color.opacity(0.95),
                            color,
                            color.opacity(0.8)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size.width, height: size.height)
                .shadow(color: .black.opacity(0.3), radius: 4, y: 3)

            // Top highlight
            RoundedRectangle(cornerRadius: size.height * 0.2)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.4), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .frame(width: size.width, height: size.height)

            // Window (dark area)
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size.width * 0.35, height: size.height * 0.4)
                .offset(x: size.width * 0.1, y: -size.height * 0.15)

            // Headlight
            Circle()
                .fill(Color.yellow.opacity(0.9))
                .frame(width: size.width * 0.08, height: size.width * 0.08)
                .offset(x: size.width * 0.4, y: size.height * 0.1)
                .shadow(color: .yellow.opacity(0.5), radius: 3)

            // Taillight
            Circle()
                .fill(Color.red.opacity(0.9))
                .frame(width: size.width * 0.06, height: size.width * 0.06)
                .offset(x: -size.width * 0.4, y: size.height * 0.1)
        }
    }
}

// MARK: - Coin Icon

struct CoinIcon: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.yellow, Color.orange],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size
                    )
                )
                .frame(width: size, height: size)

            Circle()
                .stroke(Color.orange.opacity(0.6), lineWidth: size * 0.1)
                .frame(width: size * 0.7, height: size * 0.7)

            Text("$")
                .font(.system(size: size * 0.5, weight: .bold))
                .foregroundColor(Color.orange.opacity(0.8))
        }
    }
}

// MARK: - Enhanced Stat Bar

struct EnhancedStatBar: View {
    let label: String
    let value: Int
    let color: Color
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
                .frame(width: 16)

            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 55, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.15))

                    // Fill with gradient
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(value) / 100)
                        .shadow(color: color.opacity(0.5), radius: 2)
                }
            }
            .frame(height: 8)

            Text("\(value)")
                .font(.caption)
                .foregroundColor(.white)
                .frame(width: 28, alignment: .trailing)
        }
    }
}

// MARK: - Stat Bar (Legacy compatibility)

struct StatBar: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        EnhancedStatBar(label: label, value: value, color: color, icon: "circle.fill")
    }
}

// MARK: - Upgrade Types

enum UpgradeType: String, CaseIterable {
    case engine = "Engine"
    case fuel = "Fuel Tank"
    case tires = "Tires"
    case suspension = "Suspension"

    var icon: String {
        switch self {
        case .engine: return "bolt.fill"
        case .fuel: return "fuelpump.fill"
        case .tires: return "circle.fill"
        case .suspension: return "arrow.up.arrow.down"
        }
    }

    var description: String {
        switch self {
        case .engine: return "Increase power and top speed"
        case .fuel: return "Larger fuel tank capacity"
        case .tires: return "Better grip and traction"
        case .suspension: return "Improved stability"
        }
    }
}

// MARK: - Upgrade Category Button

struct UpgradeCategoryButton: View {
    let upgrade: UpgradeType
    let isSelected: Bool
    let level: Int
    var isCompact: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: isCompact ? 4 : 6) {
                Image(systemName: upgrade.icon)
                    .font(isCompact ? .body : .title3)

                Text(upgrade.rawValue)
                    .font(.caption2)
                    .lineLimit(1)

                // Level indicator
                HStack(spacing: 2) {
                    ForEach(1...Constants.Upgrades.maxLevel, id: \.self) { lvl in
                        Circle()
                            .fill(lvl <= level ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: isCompact ? 5 : 6, height: isCompact ? 5 : 6)
                    }
                }
            }
            .foregroundColor(isSelected ? .yellow : .white)
            .frame(width: isCompact ? 70 : 80, height: isCompact ? 70 : 80)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.yellow.opacity(0.2) : Color.white.opacity(0.1))
                    .shadow(color: isSelected ? Color.yellow.opacity(0.3) : Color.clear, radius: 4)
            )
        }
    }
}

// MARK: - Upgrade Detail View

struct UpgradeDetailView: View {
    let upgradeType: UpgradeType
    let vehicleId: String
    var isCompact: Bool = false
    let onUpgrade: (Bool) -> Void

    @ObservedObject private var persistence = PersistenceManager.shared

    private var currentLevel: Int {
        persistence.upgradeLevel(for: vehicleId, upgradeType: upgradeType)
    }

    private var maxLevel: Int {
        Constants.Upgrades.maxLevel
    }

    private var upgradeCost: Int {
        Constants.Upgrades.cost(forLevel: currentLevel)
    }

    private var canAfford: Bool {
        persistence.totalCoins >= upgradeCost
    }

    var body: some View {
        VStack(spacing: isCompact ? 8 : 12) {
            Text(upgradeType.description)
                .foregroundColor(.white.opacity(0.7))
                .font(.caption)

            // Level indicator with progress bar style
            HStack(spacing: isCompact ? 6 : 8) {
                ForEach(1...maxLevel, id: \.self) { level in
                    Rectangle()
                        .fill(
                            level <= currentLevel
                                ? LinearGradient(colors: [.green, .green.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: isCompact ? 30 : 36, height: isCompact ? 14 : 16)
                        .cornerRadius(4)
                        .shadow(color: level <= currentLevel ? Color.green.opacity(0.3) : Color.clear, radius: 2)
                }
            }

            Text("Level \(currentLevel)/\(maxLevel)")
                .foregroundColor(.white)
                .font(.subheadline)

            // Upgrade button
            if currentLevel < maxLevel {
                Button(action: {
                    let success = persistence.upgradeVehicle(vehicleId, upgradeType: upgradeType)
                    if success {
                        AudioManager.shared.playSound(.upgrade)
                    }
                    onUpgrade(success)
                }) {
                    HStack(spacing: 8) {
                        Text("UPGRADE")
                            .fontWeight(.bold)

                        CoinIcon(size: 16)

                        Text("\(upgradeCost)")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, isCompact ? 16 : 20)
                    .padding(.vertical, isCompact ? 8 : 10)
                    .background(
                        LinearGradient(
                            colors: canAfford ? [.green, .green.opacity(0.7)] : [.gray, .gray.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(8)
                    .shadow(color: canAfford ? Color.green.opacity(0.4) : Color.clear, radius: 4, y: 2)
                }
                .disabled(!canAfford)
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                    Text("MAX LEVEL")
                    Image(systemName: "star.fill")
                }
                .foregroundColor(.yellow)
                .fontWeight(.bold)
                .padding(.vertical, 10)
            }
        }
        .padding(isCompact ? 12 : 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    GarageView()
}
