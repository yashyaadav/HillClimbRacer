//
//  GameOverView.swift
//  HillClimbRacer
//
//  Game over screen showing stats and retry/menu options.
//

import SwiftUI

struct GameOverView: View {

    @ObservedObject var gameManager = GameManager.shared

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Game Over text
                Text("GAME OVER")
                    .font(.system(size: 42, weight: .black))
                    .foregroundColor(.red)

                // Reason
                if let reason = gameManager.gameState.gameOverReason {
                    Text(reason.displayMessage)
                        .font(.title2)
                        .foregroundColor(.white)
                }

                Spacer()
                    .frame(height: 20)

                // Stats
                VStack(spacing: 16) {
                    StatRow(label: "Distance", value: "\(gameManager.gameState.displayDistance)m")
                    StatRow(label: "Coins", value: "\(gameManager.gameState.coins)")

                    if gameManager.gameState.distance >= gameManager.gameState.bestDistance {
                        Text("NEW BEST!")
                            .font(.headline)
                            .foregroundColor(.yellow)
                            .padding(.top, 8)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)

                Spacer()
                    .frame(height: 30)

                // Buttons
                HStack(spacing: 20) {
                    MenuButton(title: "RETRY", color: .green) {
                        gameManager.restartGame()
                    }

                    MenuButton(title: "MENU", color: .gray) {
                        gameManager.returnToMenu()
                    }
                }
            }
            .padding(40)
        }
    }
}

// MARK: - Stat Row

private struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))

            Spacer()

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(width: 200)
    }
}

#Preview {
    GameOverView()
}
