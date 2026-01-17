//
//  GarageView.swift
//  HillClimbRacer
//
//  Vehicle selection and upgrade screen.
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

            VStack(spacing: 16) {
                // Header
                headerView

                // Vehicle carousel
                vehicleCarousel

                // Vehicle info
                vehicleInfoView

                // Upgrade section (only for unlocked vehicles)
                if persistence.isVehicleUnlocked(selectedVehicle.id) {
                    upgradeSection
                }

                Spacer()
            }
            .padding(.top)
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

            // Coins display
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 20, height: 20)
                Text("\(persistence.totalCoins)")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Vehicle Carousel

    private var vehicleCarousel: some View {
        HStack(spacing: 20) {
            // Previous button
            Button(action: {
                withAnimation {
                    selectedVehicleIndex = (selectedVehicleIndex - 1 + vehicles.count) % vehicles.count
                }
            }) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title)
                    .foregroundColor(.white.opacity(0.7))
            }

            // Vehicle preview
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 140)

                VStack {
                    // Vehicle visual
                    vehiclePreview(for: selectedVehicle)

                    // Lock icon for locked vehicles
                    if !persistence.isVehicleUnlocked(selectedVehicle.id) {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                            Text("\(selectedVehicle.unlockCost)")
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 12, height: 12)
                        }
                        .foregroundColor(.orange)
                        .font(.caption)
                    }
                }
            }
            .frame(maxWidth: .infinity)

            // Next button
            Button(action: {
                withAnimation {
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

    private func vehiclePreview(for vehicle: VehicleConfig) -> some View {
        HStack(spacing: vehicle.wheelBase / 5) {
            // Rear wheel
            Circle()
                .fill(vehicle.wheelColor.color)
                .frame(width: vehicle.wheelRadius * 1.5, height: vehicle.wheelRadius * 1.5)

            // Chassis
            RoundedRectangle(cornerRadius: 6)
                .fill(vehicle.chassisColor.color)
                .frame(width: vehicle.chassisSize.width * 0.6, height: vehicle.chassisSize.height * 0.6)
                .offset(y: -10)

            // Front wheel
            Circle()
                .fill(vehicle.wheelColor.color)
                .frame(width: vehicle.wheelRadius * 1.5, height: vehicle.wheelRadius * 1.5)
        }
    }

    // MARK: - Vehicle Info

    private var vehicleInfoView: some View {
        VStack(spacing: 8) {
            Text(selectedVehicle.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(selectedVehicle.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            // Stats bars
            VStack(spacing: 6) {
                let stats = selectedVehicle.normalizedStats
                StatBar(label: "Speed", value: stats.speed, color: .red)
                StatBar(label: "Power", value: stats.power, color: .orange)
                StatBar(label: "Fuel", value: stats.fuel, color: .green)
                StatBar(label: "Handling", value: stats.handling, color: .blue)
            }
            .padding(.horizontal, 40)
            .padding(.top, 8)

            // Select/Unlock button
            if persistence.isVehicleUnlocked(selectedVehicle.id) {
                if persistence.selectedVehicleId == selectedVehicle.id {
                    Text("SELECTED")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.vertical, 8)
                } else {
                    Button(action: {
                        persistence.selectedVehicleId = selectedVehicle.id
                    }) {
                        Text("SELECT")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
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
                    HStack {
                        Image(systemName: "lock.open.fill")
                        Text("UNLOCK")
                        Text("\(selectedVehicle.unlockCost)")
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 12, height: 12)
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // MARK: - Upgrade Section

    private var upgradeSection: some View {
        VStack(spacing: 12) {
            // Upgrade category tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(UpgradeType.allCases, id: \.self) { upgrade in
                        UpgradeCategoryButton(
                            upgrade: upgrade,
                            isSelected: selectedUpgrade == upgrade,
                            level: persistence.upgradeLevel(for: selectedVehicle.id, upgradeType: upgrade)
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
                onUpgrade: { success in
                    if !success {
                        showInsufficientFundsAlert = true
                    }
                }
            )
        }
    }
}

// MARK: - Stat Bar

struct StatBar: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 60, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .cornerRadius(4)

                    Rectangle()
                        .fill(color)
                        .cornerRadius(4)
                        .frame(width: geo.size.width * CGFloat(value) / 100)
                }
            }
            .frame(height: 8)

            Text("\(value)")
                .font(.caption)
                .foregroundColor(.white)
                .frame(width: 30, alignment: .trailing)
        }
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
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: upgrade.icon)
                    .font(.title3)

                Text(upgrade.rawValue)
                    .font(.caption2)

                // Level indicator
                HStack(spacing: 2) {
                    ForEach(1...Constants.Upgrades.maxLevel, id: \.self) { lvl in
                        Circle()
                            .fill(lvl <= level ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            .foregroundColor(isSelected ? .yellow : .white)
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.yellow.opacity(0.2) : Color.white.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

// MARK: - Upgrade Detail View

struct UpgradeDetailView: View {
    let upgradeType: UpgradeType
    let vehicleId: String
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
        VStack(spacing: 12) {
            Text(upgradeType.description)
                .foregroundColor(.white.opacity(0.7))
                .font(.caption)

            // Level indicator
            HStack(spacing: 8) {
                ForEach(1...maxLevel, id: \.self) { level in
                    Rectangle()
                        .fill(level <= currentLevel ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 36, height: 16)
                        .cornerRadius(4)
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

                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 14, height: 14)

                        Text("\(upgradeCost)")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(canAfford ? Color.green : Color.gray)
                    .cornerRadius(8)
                }
                .disabled(!canAfford)
            } else {
                Text("MAX LEVEL")
                    .foregroundColor(.yellow)
                    .fontWeight(.bold)
                    .padding(.vertical, 10)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    GarageView()
}
