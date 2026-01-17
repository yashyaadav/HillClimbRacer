//
//  LevelCompleteView.swift
//  HillClimbRacer
//
//  Shown when a level is completed, displaying results and stars earned.
//

import SwiftUI

struct LevelCompleteView: View {

    @ObservedObject var gameManager = GameManager.shared
    let result: LevelResult

    @State private var showStars = false
    @State private var starAnimationIndex = 0
    @State private var showStats = false
    @State private var showButtons = false

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Title
                Text(result.isLevelComplete ? "LEVEL COMPLETE!" : "GAME OVER")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(result.isLevelComplete ? .yellow : .white)

                // Level name
                Text(result.level.name)
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))

                // Stars earned
                HStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { index in
                        StarAnimationView(
                            isEarned: index < result.starsEarned,
                            isVisible: showStars && starAnimationIndex > index,
                            delay: Double(index) * 0.3
                        )
                    }
                }
                .padding(.vertical, 20)
                .onAppear {
                    animateStars()
                }

                // Stats panel
                if showStats {
                    VStack(spacing: 16) {
                        StatRow(label: "Distance", value: "\(Int(result.distance))m", isNew: result.isNewRecord)
                        StatRow(label: "Coins Collected", value: "\(result.coins)")
                        if result.completionBonus > 0 {
                            StatRow(label: "Completion Bonus", value: "+\(result.completionBonus)", highlight: true)
                        }
                        Divider().background(Color.white.opacity(0.3))
                        StatRow(label: "Total Coins", value: "\(result.totalCoins)", highlight: true)
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal, 40)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer()

                // Action buttons
                if showButtons {
                    VStack(spacing: 12) {
                        // Retry button
                        Button(action: {
                            gameManager.restartLevel()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("RETRY")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.orange)
                            .cornerRadius(12)
                        }

                        // Next level button (if completed and there's a next level)
                        if result.isLevelComplete, let nextLevel = LevelDefinitions.nextLevel(after: result.level) {
                            Button(action: {
                                gameManager.startLevel(nextLevel)
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right")
                                    Text("NEXT LEVEL")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                        }

                        // Level select button
                        Button(action: {
                            gameManager.currentScreen = .levelSelect
                        }) {
                            HStack {
                                Image(systemName: "list.bullet")
                                Text("LEVEL SELECT")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                        }

                        // Main menu button
                        Button(action: {
                            gameManager.returnToMenu()
                        }) {
                            Text("MAIN MENU")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
    }

    private func animateStars() {
        // Animate stars appearing one by one
        withAnimation(.easeOut(duration: 0.3)) {
            showStars = true
        }

        for i in 0..<result.starsEarned {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4 + 0.3) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    starAnimationIndex = i + 1
                }
            }
        }

        // Show stats after stars
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(result.starsEarned) * 0.4 + 0.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                showStats = true
            }
        }

        // Show buttons last
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(result.starsEarned) * 0.4 + 0.8) {
            withAnimation(.easeOut(duration: 0.3)) {
                showButtons = true
            }
        }
    }
}

// MARK: - Star Animation View

struct StarAnimationView: View {
    let isEarned: Bool
    let isVisible: Bool
    let delay: Double

    @State private var scale: CGFloat = 0.3
    @State private var rotation: Double = -30

    var body: some View {
        Image(systemName: isEarned ? "star.fill" : "star")
            .font(.system(size: 50))
            .foregroundColor(isEarned ? .yellow : .gray.opacity(0.5))
            .scaleEffect(isVisible ? 1.0 : 0.3)
            .rotationEffect(.degrees(isVisible ? 0 : -30))
            .opacity(isVisible ? 1.0 : 0.3)
            .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(delay), value: isVisible)
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let label: String
    let value: String
    var isNew: Bool = false
    var highlight: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.white.opacity(0.7))

            Spacer()

            HStack(spacing: 4) {
                if isNew {
                    Text("NEW!")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
                Text(value)
                    .fontWeight(highlight ? .bold : .regular)
                    .foregroundColor(highlight ? .yellow : .white)
            }
        }
        .font(.body)
    }
}

#Preview {
    LevelCompleteView(
        result: LevelResult(
            level: LevelDefinitions.greenStart,
            distance: 1200,
            coins: 25,
            starsEarned: 2,
            isNewRecord: true,
            isLevelComplete: true
        )
    )
}
