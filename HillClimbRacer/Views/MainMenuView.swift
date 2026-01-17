//
//  MainMenuView.swift
//  HillClimbRacer
//
//  Main menu screen with Play, Garage, Settings, and Leaderboards options.
//

import SwiftUI

struct MainMenuView: View {

    @ObservedObject var gameManager = GameManager.shared
    @ObservedObject var gameCenterManager = GameCenterManager.shared
    @ObservedObject var persistence = PersistenceManager.shared

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.5, blue: 0.8),
                    Color(red: 0.1, green: 0.3, blue: 0.6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Title
                VStack(spacing: 8) {
                    Text("HILL CLIMB")
                        .font(.system(size: 48, weight: .black))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)

                    Text("RACER")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.yellow)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
                }

                // Selected vehicle indicator
                if let vehicle = VehicleDefinitions.vehicle(withId: persistence.selectedVehicleId) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(vehicle.chassisColor.color)
                            .frame(width: 12, height: 12)
                        Text(vehicle.name)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                Spacer()

                // Menu buttons
                VStack(spacing: 16) {
                    MenuButton(title: "PLAY", color: .green) {
                        gameManager.startGame()
                    }

                    MenuButton(title: "GARAGE", color: .orange) {
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

                // Stats display
                VStack(spacing: 8) {
                    if persistence.bestDistance > 0 {
                        Text("Best: \(Int(persistence.bestDistance))m")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 16, height: 16)
                        Text("\(persistence.totalCoins)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                // Game Center status
                HStack(spacing: 6) {
                    Circle()
                        .fill(gameCenterManager.isAuthenticated ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(gameCenterManager.isAuthenticated ? "Game Center Connected" : "Game Center Offline")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()
                    .frame(height: 30)
            }
        }
        .onAppear {
            // Authenticate Game Center on app launch
            if !gameCenterManager.isAuthenticated {
                gameCenterManager.authenticate()
            }

            // Start menu music
            AudioManager.shared.startMenuMusic()
        }
    }
}

// MARK: - Menu Button

struct MenuButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            AudioManager.shared.playSound(.buttonTap)
            action()
        }) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(color)
                .cornerRadius(12)
                .shadow(color: color.opacity(0.5), radius: 4, x: 0, y: 4)
        }
    }
}

// MARK: - Small Menu Button

struct SmallMenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

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
            .background(color)
            .cornerRadius(10)
            .shadow(color: color.opacity(0.5), radius: 3, x: 0, y: 3)
        }
    }
}

#Preview {
    MainMenuView()
}
