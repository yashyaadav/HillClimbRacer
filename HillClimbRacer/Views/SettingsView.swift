//
//  SettingsView.swift
//  HillClimbRacer
//
//  Settings screen for audio, controls, and account management.
//

import SwiftUI

struct SettingsView: View {

    @ObservedObject var gameManager = GameManager.shared
    @ObservedObject var gameCenterManager = GameCenterManager.shared
    @ObservedObject var persistence = PersistenceManager.shared

    @State private var showResetConfirmation = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.2, blue: 0.3),
                    Color(red: 0.1, green: 0.15, blue: 0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView

                ScrollView {
                    VStack(spacing: 24) {
                        // Audio Section
                        audioSection

                        // Game Center Section
                        gameCenterSection

                        // Statistics Section
                        statisticsSection

                        // Danger Zone
                        dangerZoneSection

                        // About Section
                        aboutSection
                    }
                    .padding()
                }
            }
        }
        .alert("Reset Progress", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                persistence.resetAllProgress()
            }
        } message: {
            Text("This will delete all your progress including coins, upgrades, and best distances. This action cannot be undone.")
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

            Text("SETTINGS")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Spacer()

            // Spacer for symmetry
            Image(systemName: "chevron.left")
                .font(.title2)
                .foregroundColor(.clear)
        }
        .padding()
    }

    // MARK: - Audio Section

    private var audioSection: some View {
        SettingsSection(title: "Audio", icon: "speaker.wave.3.fill") {
            VStack(spacing: 16) {
                SettingsToggle(
                    title: "Sound Effects",
                    icon: "speaker.fill",
                    isOn: Binding(
                        get: { persistence.isSoundEnabled },
                        set: { persistence.isSoundEnabled = $0 }
                    )
                )

                SettingsToggle(
                    title: "Music",
                    icon: "music.note",
                    isOn: Binding(
                        get: { persistence.isMusicEnabled },
                        set: {
                            persistence.isMusicEnabled = $0
                            if $0 {
                                AudioManager.shared.startMusic()
                            } else {
                                AudioManager.shared.stopMusic()
                            }
                        }
                    )
                )
            }
        }
    }

    // MARK: - Game Center Section

    private var gameCenterSection: some View {
        SettingsSection(title: "Game Center", icon: "gamecontroller.fill") {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: gameCenterManager.isAuthenticated ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(gameCenterManager.isAuthenticated ? .green : .red)

                    Text(gameCenterManager.isAuthenticated ? "Connected" : "Not Connected")
                        .foregroundColor(.white)

                    Spacer()

                    if !gameCenterManager.isAuthenticated {
                        Button("Sign In") {
                            gameCenterManager.authenticate()
                        }
                        .foregroundColor(.blue)
                    } else if let player = gameCenterManager.localPlayer {
                        Text(player.displayName)
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)
                    }
                }

                if gameCenterManager.isAuthenticated {
                    Button(action: {
                        gameCenterManager.showLeaderboards()
                    }) {
                        HStack {
                            Image(systemName: "list.number")
                            Text("View Leaderboards")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }

    // MARK: - Statistics Section

    private var statisticsSection: some View {
        SettingsSection(title: "Statistics", icon: "chart.bar.fill") {
            VStack(spacing: 12) {
                SettingsStatRow(title: "Games Played", value: "\(persistence.gamesPlayed)")
                SettingsStatRow(title: "Best Distance", value: "\(Int(persistence.bestDistance))m")
                SettingsStatRow(title: "Total Coins", value: "\(persistence.totalCoins)")
            }
        }
    }

    // MARK: - Danger Zone Section

    private var dangerZoneSection: some View {
        SettingsSection(title: "Danger Zone", icon: "exclamationmark.triangle.fill", titleColor: .red) {
            Button(action: {
                showResetConfirmation = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Reset All Progress")
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.red.opacity(0.2))
                .cornerRadius(8)
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        SettingsSection(title: "About", icon: "info.circle.fill") {
            VStack(spacing: 12) {
                HStack {
                    Text("Version")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.white)
                }

                HStack {
                    Text("Build")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("1")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    var titleColor: Color = .white
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(titleColor)
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(titleColor)
            }
            .font(.headline)

            content
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
        }
    }
}

// MARK: - Settings Toggle

struct SettingsToggle: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 24)

            Text(title)
                .foregroundColor(.white)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.green)
        }
    }
}

// MARK: - Stat Row

struct SettingsStatRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    SettingsView()
}
