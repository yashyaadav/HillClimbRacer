//
//  AudioManager.swift
//  HillClimbRacer
//
//  Handles all audio playback including engine sounds, effects, and music.
//

import AVFoundation
import SpriteKit

class AudioManager {

    // MARK: - Singleton

    static let shared = AudioManager()

    // MARK: - Properties

    private var enginePlayer: AVAudioPlayer?
    private var musicPlayer: AVAudioPlayer?
    private var sfxPlayers: [AVAudioPlayer] = []

    /// Current engine pitch (0.5 - 2.0, based on speed)
    private var enginePitch: Float = 1.0

    /// Master volume (0.0 - 1.0)
    var masterVolume: Float = 1.0 {
        didSet {
            updateVolumes()
        }
    }

    /// Sound effects volume
    var sfxVolume: Float = 1.0 {
        didSet {
            updateVolumes()
        }
    }

    /// Music volume
    var musicVolume: Float = 0.5 {
        didSet {
            musicPlayer?.volume = musicVolume * masterVolume
        }
    }

    /// Is sound enabled? (synced with PersistenceManager)
    var isSoundEnabled: Bool {
        get { PersistenceManager.shared.isSoundEnabled }
        set { PersistenceManager.shared.isSoundEnabled = newValue }
    }

    /// Is music enabled? (synced with PersistenceManager)
    var isMusicEnabled: Bool {
        get { PersistenceManager.shared.isMusicEnabled }
        set { PersistenceManager.shared.isMusicEnabled = newValue }
    }

    // MARK: - Initialization

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Engine Sound

    /// Start the engine sound loop
    func startEngine() {
        guard isSoundEnabled else { return }

        guard let url = Bundle.main.url(forResource: "engine_idle", withExtension: "wav") else {
            print("Engine sound file not found - engine_idle.wav")
            return
        }

        do {
            enginePlayer = try AVAudioPlayer(contentsOf: url)
            enginePlayer?.numberOfLoops = -1  // Loop forever
            enginePlayer?.enableRate = true
            enginePlayer?.volume = sfxVolume * masterVolume
            enginePlayer?.play()
        } catch {
            print("Failed to load engine sound: \(error)")
        }
    }

    /// Stop the engine sound
    func stopEngine() {
        enginePlayer?.stop()
        enginePlayer = nil
    }

    /// Update engine pitch based on vehicle speed
    func updateEnginePitch(speedRatio: Float) {
        // Map speed ratio (0-1) to pitch (0.8 - 1.5)
        let pitch = 0.8 + (speedRatio * 0.7)
        enginePitch = pitch
        enginePlayer?.rate = pitch
    }

    // MARK: - Sound Effects

    /// Play a sound effect
    func playSound(_ sound: GameSound, in scene: SKScene? = nil) {
        guard isSoundEnabled else { return }

        // Try using SpriteKit's built-in audio for positional sounds
        if let scene = scene, Bundle.main.url(forResource: sound.name, withExtension: "wav") != nil {
            let action = SKAction.playSoundFileNamed(sound.filename, waitForCompletion: false)
            scene.run(action)
        } else {
            // Fallback to AVAudioPlayer for non-positional sounds
            playSoundEffect(sound)
        }
    }

    private func playSoundEffect(_ sound: GameSound) {
        guard let url = Bundle.main.url(forResource: sound.name, withExtension: "wav") else {
            print("Sound file not found: \(sound.filename)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = sfxVolume * masterVolume
            player.play()

            // Keep reference to prevent deallocation
            sfxPlayers.append(player)

            // Clean up finished players
            sfxPlayers.removeAll { !$0.isPlaying }
        } catch {
            print("Failed to play sound \(sound.filename): \(error)")
        }
    }

    // MARK: - Music

    /// Start background music
    func startMusic() {
        guard isMusicEnabled else { return }

        // Try different music files
        let musicFiles = ["gameplay_music", "menu_music", "background_music"]
        var musicUrl: URL?

        for filename in musicFiles {
            if let url = Bundle.main.url(forResource: filename, withExtension: "mp3") {
                musicUrl = url
                break
            }
        }

        guard let url = musicUrl else {
            print("No music file found")
            return
        }

        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1  // Loop forever
            musicPlayer?.volume = musicVolume * masterVolume
            musicPlayer?.play()
        } catch {
            print("Failed to load music: \(error)")
        }
    }

    /// Start menu music specifically
    func startMenuMusic() {
        guard isMusicEnabled else { return }

        guard let url = Bundle.main.url(forResource: "menu_music", withExtension: "mp3") else {
            // Fallback to generic music
            startMusic()
            return
        }

        do {
            musicPlayer?.stop()
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.volume = musicVolume * masterVolume
            musicPlayer?.play()
        } catch {
            print("Failed to load menu music: \(error)")
        }
    }

    /// Start gameplay music specifically
    func startGameplayMusic() {
        guard isMusicEnabled else { return }

        guard let url = Bundle.main.url(forResource: "gameplay_music", withExtension: "mp3") else {
            // Fallback to generic music
            startMusic()
            return
        }

        do {
            musicPlayer?.stop()
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.volume = musicVolume * masterVolume
            musicPlayer?.play()
        } catch {
            print("Failed to load gameplay music: \(error)")
        }
    }

    /// Stop background music
    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }

    /// Pause/resume music
    func pauseMusic(_ paused: Bool) {
        if paused {
            musicPlayer?.pause()
        } else if isMusicEnabled {
            musicPlayer?.play()
        }
    }

    // MARK: - Helpers

    private func updateVolumes() {
        enginePlayer?.volume = sfxVolume * masterVolume
        musicPlayer?.volume = musicVolume * masterVolume
    }

    /// Preload all audio files for faster playback
    func preloadAudio() {
        // Preload sound effects
        for sound in GameSound.allCases {
            if let url = Bundle.main.url(forResource: sound.name, withExtension: "wav") {
                _ = try? AVAudioPlayer(contentsOf: url)
            }
        }
    }
}

// MARK: - Game Sounds

enum GameSound: String, CaseIterable {
    case coinCollect = "coin_collect"
    case fuelCollect = "fuel_collect"
    case crash = "crash"
    case jump = "jump"
    case land = "land"
    case buttonTap = "button_tap"
    case gameOver = "game_over"
    case upgrade = "upgrade"
    case engineIdle = "engine_idle"
    case engineRev = "engine_rev"

    var name: String {
        rawValue
    }

    var filename: String {
        "\(rawValue).wav"
    }
}
