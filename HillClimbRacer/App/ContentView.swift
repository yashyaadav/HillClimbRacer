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

                case .gameplay, .paused, .gameOver, .levelComplete:
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

                    // Level complete overlay
                    if gameManager.currentScreen == .levelComplete,
                       let result = gameManager.lastLevelResult {
                        LevelCompleteView(result: result)
                    }

                case .garage:
                    GarageView()

                case .settings:
                    SettingsView()

                case .levelSelect:
                    LevelSelectView()
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
    @State private var isMusicEnabled = AudioManager.shared.isMusicEnabled
    @State private var coinAnimationTrigger = false

    var body: some View {
        VStack {
            // Top HUD
            HStack(alignment: .top, spacing: 12) {
                // Fuel gauge
                VStack(alignment: .leading, spacing: 4) {
                    Text("FUEL")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    FuelGaugeView(fuel: gameManager.gameState.fuel)
                }

                Spacer()

                // Music toggle button
                Button(action: {
                    isMusicEnabled.toggle()
                    AudioManager.shared.isMusicEnabled = isMusicEnabled
                    if isMusicEnabled {
                        AudioManager.shared.startGameplayMusic()
                    } else {
                        AudioManager.shared.stopMusic()
                    }
                }) {
                    Image(systemName: isMusicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }

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

                // Coins with animation
                CoinDisplayView(coins: gameManager.gameState.coins)

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

                // Speed display
                SpeedometerView(speed: gameManager.gameState.currentSpeed)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            Spacer()

            // Interactive control buttons
            ControlButtonsView()
        }
    }
}

// MARK: - Coin Display with Animation

struct CoinDisplayView: View {
    let coins: Int
    @State private var previousCoins: Int = 0
    @State private var showPlusOne = false
    @State private var coinScale: CGFloat = 1.0

    var body: some View {
        HStack(spacing: 8) {
            // Coin icon with gradient and glow
            ZStack {
                // Glow effect
                Circle()
                    .fill(Color.yellow.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .blur(radius: 4)

                // Coin
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.yellow, .orange, .yellow]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text("$")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    )
                    .shadow(color: .orange.opacity(0.5), radius: 2, x: 0, y: 1)
            }
            .scaleEffect(coinScale)

            // Coin count
            Text("\(coins)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3), value: coins)

            // +1 popup
            if showPlusOne {
                Text("+1")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
        }
        .onChange(of: coins) { oldValue, newValue in
            if newValue > oldValue {
                // Animate coin collection
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    coinScale = 1.3
                }
                withAnimation(.spring(response: 0.2).delay(0.1)) {
                    coinScale = 1.0
                }

                // Show +1 popup
                withAnimation(.easeOut(duration: 0.2)) {
                    showPlusOne = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeIn(duration: 0.2)) {
                        showPlusOne = false
                    }
                }
            }
            previousCoins = newValue
        }
    }
}

#Preview {
    ContentView()
}
