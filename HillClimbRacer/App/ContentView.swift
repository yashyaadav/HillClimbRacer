//
//  ContentView.swift
//  HillClimbRacer
//

import SwiftUI
import SpriteKit
import GameKit

struct ContentView: View {

    @StateObject private var gameManager = GameManager.shared
    @State private var gameScene: GameScene?
    @State private var gameCenterVC: UIViewController?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                switch gameManager.currentScreen {
                case .mainMenu:
                    MainMenuView()

                case .gameplay, .paused, .gameOver:
                    // SpriteKit game scene
                    if let scene = gameScene {
                        SpriteView(scene: scene)
                            .ignoresSafeArea()
                    }

                    // SwiftUI HUD overlay (only during gameplay)
                    if gameManager.currentScreen == .gameplay {
                        GameplayOverlay()
                    }

                    // Pause menu overlay
                    if gameManager.currentScreen == .paused {
                        PauseMenuView()
                    }

                    // Game over overlay
                    if gameManager.currentScreen == .gameOver {
                        GameOverView()
                    }

                case .garage:
                    GarageView()

                case .settings:
                    SettingsView()
                }
            }
            .onAppear {
                createGameScene(size: geometry.size)
            }
            .onChange(of: gameManager.currentScreen) { _, newScreen in
                if newScreen == .gameplay && gameScene == nil {
                    createGameScene(size: geometry.size)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .presentGameCenterAuth)) { notification in
                if let vc = notification.object as? UIViewController {
                    presentViewController(vc)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .presentGameCenterLeaderboards)) { notification in
                if let vc = notification.object as? UIViewController {
                    presentViewController(vc)
                }
            }
        }
    }

    private func createGameScene(size: CGSize) {
        let scene = GameScene(size: size)
        scene.scaleMode = .resizeFill
        gameScene = scene
    }

    private func presentViewController(_ viewController: UIViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }

        // Find the topmost presented view controller
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        topVC.present(viewController, animated: true)
    }
}

// MARK: - Gameplay Overlay

struct GameplayOverlay: View {

    @ObservedObject var gameManager = GameManager.shared

    var body: some View {
        VStack {
            // Top HUD
            HStack(alignment: .top, spacing: 20) {
                // Fuel gauge
                VStack(alignment: .leading, spacing: 4) {
                    Text("FUEL")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    FuelGaugeView(fuel: gameManager.gameState.fuel)
                }

                Spacer()

                // Pause button
                Button(action: {
                    gameManager.pauseGame()
                    gameManager.currentScreen = .paused
                }) {
                    Image(systemName: "pause.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }

                Spacer()

                // Coins
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text("$")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        )

                    Text("\(gameManager.gameState.coins)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                Spacer()

                // Distance
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(gameManager.gameState.displayDistance)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("meters")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            Spacer()

            // Control hints
            HStack {
                Text("BRAKE")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.3))
                    .frame(maxWidth: .infinity)

                Text("GAS")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.3))
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    ContentView()
}
