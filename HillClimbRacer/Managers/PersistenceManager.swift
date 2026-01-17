//
//  PersistenceManager.swift
//  HillClimbRacer
//
//  Handles saving and loading game data using UserDefaults.
//

import Foundation
import CoreGraphics

class PersistenceManager: ObservableObject {

    // MARK: - Singleton

    static let shared = PersistenceManager()

    // MARK: - Keys

    private enum Keys {
        static let totalCoins = "totalCoins"
        static let bestDistance = "bestDistance"
        static let engineLevel = "engineLevel"
        static let fuelLevel = "fuelLevel"
        static let tiresLevel = "tiresLevel"
        static let suspensionLevel = "suspensionLevel"
        static let soundEnabled = "soundEnabled"
        static let musicEnabled = "musicEnabled"
        static let gamesPlayed = "gamesPlayed"

        // Vehicle-related keys
        static let selectedVehicle = "selectedVehicle"
        static let unlockedVehicles = "unlockedVehicles"
        static let vehicleUpgrades = "vehicleUpgrades"  // [vehicleId: [upgradeType: level]]
        static let vehicleBestDistances = "vehicleBestDistances"  // [vehicleId: distance]

        // Level-related keys
        static let levelProgress = "levelProgress"  // [levelId: LevelProgress]
    }

    // MARK: - Properties

    private let defaults = UserDefaults.standard

    // MARK: - Initialization

    private init() {
        // Set default values if not already set
        registerDefaults()
    }

    private func registerDefaults() {
        let defaultValues: [String: Any] = [
            Keys.totalCoins: 0,
            Keys.bestDistance: 0.0,
            Keys.engineLevel: 1,
            Keys.fuelLevel: 1,
            Keys.tiresLevel: 1,
            Keys.suspensionLevel: 1,
            Keys.soundEnabled: true,
            Keys.musicEnabled: true,
            Keys.gamesPlayed: 0,
            Keys.selectedVehicle: "jeep",
            Keys.unlockedVehicles: ["jeep"]
        ]
        defaults.register(defaults: defaultValues)
    }

    // MARK: - Coins

    var totalCoins: Int {
        get { defaults.integer(forKey: Keys.totalCoins) }
        set { defaults.set(newValue, forKey: Keys.totalCoins) }
    }

    func addCoins(_ amount: Int) {
        totalCoins += amount
    }

    func spendCoins(_ amount: Int) -> Bool {
        guard totalCoins >= amount else { return false }
        totalCoins -= amount
        return true
    }

    // MARK: - Best Distance

    var bestDistance: CGFloat {
        get { CGFloat(defaults.double(forKey: Keys.bestDistance)) }
        set { defaults.set(Double(newValue), forKey: Keys.bestDistance) }
    }

    func updateBestDistance(_ distance: CGFloat) {
        if distance > bestDistance {
            bestDistance = distance
        }
    }

    // MARK: - Upgrade Levels

    var engineLevel: Int {
        get { defaults.integer(forKey: Keys.engineLevel) }
        set { defaults.set(newValue, forKey: Keys.engineLevel) }
    }

    var fuelLevel: Int {
        get { defaults.integer(forKey: Keys.fuelLevel) }
        set { defaults.set(newValue, forKey: Keys.fuelLevel) }
    }

    var tiresLevel: Int {
        get { defaults.integer(forKey: Keys.tiresLevel) }
        set { defaults.set(newValue, forKey: Keys.tiresLevel) }
    }

    var suspensionLevel: Int {
        get { defaults.integer(forKey: Keys.suspensionLevel) }
        set { defaults.set(newValue, forKey: Keys.suspensionLevel) }
    }

    // MARK: - Settings

    var isSoundEnabled: Bool {
        get { defaults.bool(forKey: Keys.soundEnabled) }
        set { defaults.set(newValue, forKey: Keys.soundEnabled) }
    }

    var isMusicEnabled: Bool {
        get { defaults.bool(forKey: Keys.musicEnabled) }
        set { defaults.set(newValue, forKey: Keys.musicEnabled) }
    }

    // MARK: - Statistics

    var gamesPlayed: Int {
        get { defaults.integer(forKey: Keys.gamesPlayed) }
        set { defaults.set(newValue, forKey: Keys.gamesPlayed) }
    }

    func incrementGamesPlayed() {
        gamesPlayed += 1
    }

    // MARK: - Vehicle Selection

    var selectedVehicleId: String {
        get { defaults.string(forKey: Keys.selectedVehicle) ?? "jeep" }
        set { defaults.set(newValue, forKey: Keys.selectedVehicle) }
    }

    var selectedVehicle: VehicleConfig {
        VehicleDefinitions.vehicle(withId: selectedVehicleId) ?? VehicleDefinitions.defaultVehicle
    }

    // MARK: - Unlocked Vehicles

    var unlockedVehicleIds: [String] {
        get { defaults.stringArray(forKey: Keys.unlockedVehicles) ?? ["jeep"] }
        set { defaults.set(newValue, forKey: Keys.unlockedVehicles) }
    }

    func isVehicleUnlocked(_ vehicleId: String) -> Bool {
        unlockedVehicleIds.contains(vehicleId)
    }

    func unlockVehicle(_ vehicleId: String) -> Bool {
        guard let vehicle = VehicleDefinitions.vehicle(withId: vehicleId) else { return false }
        guard !isVehicleUnlocked(vehicleId) else { return true }  // Already unlocked
        guard spendCoins(vehicle.unlockCost) else { return false }  // Not enough coins

        var unlocked = unlockedVehicleIds
        unlocked.append(vehicleId)
        unlockedVehicleIds = unlocked
        return true
    }

    // MARK: - Per-Vehicle Upgrades

    private var vehicleUpgradesDict: [String: [String: Int]] {
        get {
            (defaults.dictionary(forKey: Keys.vehicleUpgrades) as? [String: [String: Int]]) ?? [:]
        }
        set {
            defaults.set(newValue, forKey: Keys.vehicleUpgrades)
        }
    }

    func upgradeLevel(for vehicleId: String, upgradeType: UpgradeType) -> Int {
        vehicleUpgradesDict[vehicleId]?[upgradeType.rawValue] ?? 1
    }

    func setUpgradeLevel(_ level: Int, for vehicleId: String, upgradeType: UpgradeType) {
        var upgrades = vehicleUpgradesDict
        if upgrades[vehicleId] == nil {
            upgrades[vehicleId] = [:]
        }
        upgrades[vehicleId]?[upgradeType.rawValue] = level
        vehicleUpgradesDict = upgrades
    }

    func upgradeVehicle(_ vehicleId: String, upgradeType: UpgradeType) -> Bool {
        let currentLevel = upgradeLevel(for: vehicleId, upgradeType: upgradeType)
        guard currentLevel < Constants.Upgrades.maxLevel else { return false }

        let cost = Constants.Upgrades.cost(forLevel: currentLevel)
        guard spendCoins(cost) else { return false }

        setUpgradeLevel(currentLevel + 1, for: vehicleId, upgradeType: upgradeType)
        return true
    }

    /// Get the current vehicle config with upgrades applied
    func configuredVehicle(for vehicleId: String) -> VehicleConfig? {
        guard let baseConfig = VehicleDefinitions.vehicle(withId: vehicleId) else { return nil }

        return baseConfig.withUpgrades(
            engineLevel: upgradeLevel(for: vehicleId, upgradeType: .engine),
            fuelLevel: upgradeLevel(for: vehicleId, upgradeType: .fuel),
            tiresLevel: upgradeLevel(for: vehicleId, upgradeType: .tires),
            suspensionLevel: upgradeLevel(for: vehicleId, upgradeType: .suspension)
        )
    }

    // MARK: - Per-Vehicle Best Distances

    private var vehicleBestDistancesDict: [String: Double] {
        get {
            (defaults.dictionary(forKey: Keys.vehicleBestDistances) as? [String: Double]) ?? [:]
        }
        set {
            defaults.set(newValue, forKey: Keys.vehicleBestDistances)
        }
    }

    func bestDistance(for vehicleId: String) -> CGFloat {
        CGFloat(vehicleBestDistancesDict[vehicleId] ?? 0)
    }

    func updateBestDistance(_ distance: CGFloat, for vehicleId: String) {
        let currentBest = bestDistance(for: vehicleId)
        if distance > currentBest {
            var distances = vehicleBestDistancesDict
            distances[vehicleId] = Double(distance)
            vehicleBestDistancesDict = distances

            // Also update overall best distance
            if distance > bestDistance {
                bestDistance = distance
            }
        }
    }

    // MARK: - Level Progress

    /// Load all level progress from storage
    func loadLevelProgress() -> [String: LevelProgress] {
        guard let data = defaults.data(forKey: Keys.levelProgress),
              let decoded = try? JSONDecoder().decode([String: LevelProgress].self, from: data) else {
            return [:]
        }
        return decoded
    }

    /// Save level progress to storage
    func saveLevelProgress(_ progress: [String: LevelProgress]) {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        defaults.set(data, forKey: Keys.levelProgress)
    }

    /// Get progress for a specific level
    func levelProgress(for levelId: String) -> LevelProgress? {
        let allProgress = loadLevelProgress()
        return allProgress[levelId]
    }

    /// Update progress for a specific level
    func updateLevelProgress(_ progress: LevelProgress) {
        var allProgress = loadLevelProgress()
        allProgress[progress.levelId] = progress
        saveLevelProgress(allProgress)
    }

    // MARK: - Reset

    /// Reset all progress (for debugging or user request)
    func resetAllProgress() {
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        registerDefaults()
    }

    // MARK: - Save Data Structure

    /// Get all save data as a dictionary (for backup/export)
    func exportSaveData() -> [String: Any] {
        return [
            Keys.totalCoins: totalCoins,
            Keys.bestDistance: bestDistance,
            Keys.engineLevel: engineLevel,
            Keys.fuelLevel: fuelLevel,
            Keys.tiresLevel: tiresLevel,
            Keys.suspensionLevel: suspensionLevel,
            Keys.soundEnabled: isSoundEnabled,
            Keys.musicEnabled: isMusicEnabled,
            Keys.gamesPlayed: gamesPlayed
        ]
    }

    /// Import save data from a dictionary (for restore)
    func importSaveData(_ data: [String: Any]) {
        if let coins = data[Keys.totalCoins] as? Int {
            totalCoins = coins
        }
        if let distance = data[Keys.bestDistance] as? Double {
            bestDistance = CGFloat(distance)
        }
        if let level = data[Keys.engineLevel] as? Int {
            engineLevel = level
        }
        if let level = data[Keys.fuelLevel] as? Int {
            fuelLevel = level
        }
        if let level = data[Keys.tiresLevel] as? Int {
            tiresLevel = level
        }
        if let level = data[Keys.suspensionLevel] as? Int {
            suspensionLevel = level
        }
        if let enabled = data[Keys.soundEnabled] as? Bool {
            isSoundEnabled = enabled
        }
        if let enabled = data[Keys.musicEnabled] as? Bool {
            isMusicEnabled = enabled
        }
        if let games = data[Keys.gamesPlayed] as? Int {
            gamesPlayed = games
        }
    }
}
