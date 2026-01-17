//
//  PauseMenuView.swift
//  HillClimbRacer
//
//  Pause menu overlay with resume, restart, and quit options.
//

import SwiftUI

struct PauseMenuView: View {

    @ObservedObject var gameManager = GameManager.shared

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("PAUSED")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.white)

                Spacer()
                    .frame(height: 20)

                VStack(spacing: 16) {
                    MenuButton(title: "RESUME", color: .green) {
                        gameManager.resumeGame()
                    }

                    MenuButton(title: "RESTART", color: .orange) {
                        gameManager.restartGame()
                    }

                    MenuButton(title: "QUIT", color: .red) {
                        gameManager.returnToMenu()
                    }
                }
            }
            .padding(40)
        }
    }
}

#Preview {
    PauseMenuView()
}
