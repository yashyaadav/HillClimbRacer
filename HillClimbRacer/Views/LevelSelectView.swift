//
//  LevelSelectView.swift
//  HillClimbRacer
//
//  Level selection screen with grid of level cards.
//

import SwiftUI

struct LevelSelectView: View {

    @ObservedObject var gameManager = GameManager.shared
    @State private var selectedLevel: Level?

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.3),
                    Color(red: 0.2, green: 0.3, blue: 0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: {
                        gameManager.currentScreen = .mainMenu
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("SELECT LEVEL")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Spacer()

                    // Total stars display
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(gameManager.totalStarsEarned)/\(LevelDefinitions.totalStoryStars)")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // Level Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(LevelDefinitions.all) { level in
                            LevelCardView(
                                level: level,
                                progress: gameManager.progress(for: level),
                                isSelected: selectedLevel?.id == level.id
                            ) {
                                selectLevel(level)
                            }
                        }
                    }
                    .padding()
                }

                // Play button
                if let selected = selectedLevel {
                    PlayLevelButton(level: selected, progress: gameManager.progress(for: selected)) {
                        startLevel(selected)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
    }

    private func selectLevel(_ level: Level) {
        withAnimation(.spring(response: 0.3)) {
            if selectedLevel?.id == level.id {
                selectedLevel = nil
            } else {
                selectedLevel = level
            }
        }
    }

    private func startLevel(_ level: Level) {
        let progress = gameManager.progress(for: level)

        // Check if level needs to be unlocked
        if !progress.isUnlocked && level.unlockCost > 0 {
            // Try to unlock
            if PersistenceManager.shared.totalCoins >= level.unlockCost {
                gameManager.unlockLevel(level)
            }
            return
        }

        // Start the level
        gameManager.startLevel(level)
    }
}

// MARK: - Level Card View

struct LevelCardView: View {
    let level: Level
    let progress: LevelProgress
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Level preview/icon
                ZStack {
                    // Biome color background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(biomeGradient)
                        .frame(height: 80)

                    // Lock overlay if not unlocked
                    if !progress.isUnlocked && level.unlockCost > 0 {
                        Color.black.opacity(0.5)
                            .cornerRadius(12)

                        VStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                            HStack(spacing: 2) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.yellow)
                                Text("\(level.unlockCost)")
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .font(.caption)
                        }
                    } else {
                        // Biome icon
                        Image(systemName: biomeIcon)
                            .font(.largeTitle)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    // Endless badge
                    if level.isEndless {
                        VStack {
                            HStack {
                                Spacer()
                                Text("ENDLESS")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.purple)
                                    .cornerRadius(4)
                            }
                            Spacer()
                        }
                        .padding(6)
                    }
                }

                // Level info
                VStack(spacing: 4) {
                    Text(level.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)

                    // Stars
                    StarsView(earned: progress.starsEarned, total: 3)

                    // Target distance
                    Text(level.targetDistanceDisplay)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isSelected ? 0.2 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(isSelected ? Color.yellow : Color.clear, lineWidth: 3)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var biomeGradient: LinearGradient {
        let color = level.biome?.skySwiftUIColor ?? Color.purple
        return LinearGradient(
            gradient: Gradient(colors: [color.opacity(0.8), color]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var biomeIcon: String {
        switch level.biome?.id {
        case "grassland": return "leaf.fill"
        case "desert": return "sun.max.fill"
        case "arctic": return "snowflake"
        case "forest": return "tree.fill"
        default: return "infinity"
        }
    }
}

// MARK: - Stars View

struct StarsView: View {
    let earned: Int
    let total: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<total, id: \.self) { index in
                Image(systemName: index < earned ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundColor(index < earned ? .yellow : .gray)
            }
        }
    }
}

// MARK: - Play Level Button

struct PlayLevelButton: View {
    let level: Level
    let progress: LevelProgress
    let onPlay: () -> Void

    var body: some View {
        Button(action: onPlay) {
            HStack(spacing: 12) {
                if !progress.isUnlocked && level.unlockCost > 0 {
                    // Unlock button
                    Image(systemName: "lock.open.fill")
                    Text("UNLOCK FOR \(level.unlockCost)")
                } else {
                    // Play button
                    Image(systemName: "play.fill")
                    Text("PLAY \(level.name.uppercased())")
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(buttonGradient)
            )
        }
    }

    private var buttonGradient: LinearGradient {
        let colors: [Color] = progress.isUnlocked || level.unlockCost == 0
            ? [.green, .green.opacity(0.7)]
            : [.orange, .orange.opacity(0.7)]

        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview {
    LevelSelectView()
}
