//
//  GameCenterManager.swift
//  HillClimbRacer
//
//  Handles Game Center authentication and leaderboard integration.
//

import GameKit
import SwiftUI

class GameCenterManager: NSObject, ObservableObject {

    // MARK: - Singleton

    static let shared = GameCenterManager()

    // MARK: - Published Properties

    @Published var isAuthenticated = false
    @Published var localPlayer: GKLocalPlayer?
    @Published var authenticationError: String?

    // MARK: - Leaderboard IDs

    enum LeaderboardID: String {
        case bestDistanceJeep = "best_distance_jeep"
        case bestDistanceMotorcycle = "best_distance_motorcycle"
        case bestDistanceMonster = "best_distance_monster"
        case bestDistanceOverall = "best_distance_overall"
        case totalCoinsCollected = "total_coins_collected"

        static func forVehicle(_ vehicleId: String) -> LeaderboardID {
            switch vehicleId {
            case "jeep": return .bestDistanceJeep
            case "motorcycle": return .bestDistanceMotorcycle
            case "monster_truck": return .bestDistanceMonster
            default: return .bestDistanceOverall
            }
        }
    }

    // MARK: - Initialization

    private override init() {
        super.init()
    }

    // MARK: - Authentication

    /// Authenticate the local player with Game Center
    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.authenticationError = error.localizedDescription
                    self?.isAuthenticated = false
                    print("Game Center auth error: \(error.localizedDescription)")
                    return
                }

                if let viewController = viewController {
                    // Present authentication view controller
                    NotificationCenter.default.post(
                        name: .presentGameCenterAuth,
                        object: viewController
                    )
                    return
                }

                if GKLocalPlayer.local.isAuthenticated {
                    self?.isAuthenticated = true
                    self?.localPlayer = GKLocalPlayer.local
                    self?.authenticationError = nil
                    print("Game Center authenticated: \(GKLocalPlayer.local.displayName)")
                } else {
                    self?.isAuthenticated = false
                    self?.localPlayer = nil
                }
            }
        }
    }

    // MARK: - Score Submission

    /// Submit a distance score for a specific vehicle
    func submitDistance(_ distance: Int, vehicleId: String) {
        guard isAuthenticated else {
            print("Cannot submit score: not authenticated")
            return
        }

        let vehicleLeaderboard = LeaderboardID.forVehicle(vehicleId)

        // Submit to vehicle-specific leaderboard
        submitScore(distance, to: vehicleLeaderboard)

        // Also submit to overall leaderboard
        submitScore(distance, to: .bestDistanceOverall)
    }

    /// Submit total coins collected
    func submitTotalCoins(_ coins: Int) {
        guard isAuthenticated else { return }
        submitScore(coins, to: .totalCoinsCollected)
    }

    private func submitScore(_ score: Int, to leaderboard: LeaderboardID) {
        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [leaderboard.rawValue]
        ) { error in
            if let error = error {
                print("Failed to submit score to \(leaderboard.rawValue): \(error.localizedDescription)")
            } else {
                print("Score \(score) submitted to \(leaderboard.rawValue)")
            }
        }
    }

    // MARK: - Leaderboard Display

    /// Show the Game Center leaderboards UI
    func showLeaderboards() {
        guard isAuthenticated else {
            print("Cannot show leaderboards: not authenticated")
            return
        }

        let gcViewController = GKGameCenterViewController(state: .leaderboards)
        gcViewController.gameCenterDelegate = self

        NotificationCenter.default.post(
            name: .presentGameCenterLeaderboards,
            object: gcViewController
        )
    }

    /// Show a specific leaderboard
    func showLeaderboard(_ leaderboardID: LeaderboardID) {
        guard isAuthenticated else { return }

        let gcViewController = GKGameCenterViewController(
            leaderboardID: leaderboardID.rawValue,
            playerScope: .global,
            timeScope: .allTime
        )
        gcViewController.gameCenterDelegate = self

        NotificationCenter.default.post(
            name: .presentGameCenterLeaderboards,
            object: gcViewController
        )
    }

    // MARK: - Fetch Scores

    /// Fetch the local player's best score for a leaderboard
    func fetchBestScore(for leaderboard: LeaderboardID, completion: @escaping (Int?) -> Void) {
        guard isAuthenticated else {
            completion(nil)
            return
        }

        GKLeaderboard.loadLeaderboards(IDs: [leaderboard.rawValue]) { leaderboards, error in
            guard let leaderboard = leaderboards?.first, error == nil else {
                completion(nil)
                return
            }

            leaderboard.loadEntries(
                for: [GKLocalPlayer.local],
                timeScope: .allTime
            ) { localEntry, _, error in
                DispatchQueue.main.async {
                    if let entry = localEntry {
                        completion(entry.score)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
}

// MARK: - GKGameCenterControllerDelegate

extension GameCenterManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let presentGameCenterAuth = Notification.Name("presentGameCenterAuth")
    static let presentGameCenterLeaderboards = Notification.Name("presentGameCenterLeaderboards")
}
