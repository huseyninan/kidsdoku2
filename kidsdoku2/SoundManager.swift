import AVFoundation
import Combine
import SwiftUI

final class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    /// Number of pre-loaded players per sound for overlapping playback
    private let playersPerSound = 3
    
    /// Audio player pools - each sound has multiple players for zero-latency playback
    /// Access is thread-safe via NSLock
    private var playerPools: [String: [AVAudioPlayer]] = [:]
    private var playerIndices: [String: Int] = [:]
    private let lock = NSLock()
    
    @AppStorage("soundEnabled") var isSoundEnabled: Bool = true
    @Published var volume: Float = 0.05
    
    enum SoundEffect: String {
        case correctPlacement = "correct_placement"
        case incorrectPlacement = "incorrect_placement"
        case victory = "victory_sound"
        case hint = "hint"
        
        var fileName: String {
            return self.rawValue
        }
    }
    
    private init() {
        setupAudioSession()
        preloadSounds()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("⚠️ Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    private func preloadSounds() {
        for sound in [SoundEffect.correctPlacement, .incorrectPlacement, .victory, .hint] {
            guard let url = findSoundURL(for: sound) else {
                print("⚠️ Sound file not found: \(sound.fileName)")
                continue
            }
            
            var players: [AVAudioPlayer] = []
            for _ in 0..<playersPerSound {
                if let player = createPlayer(from: url) {
                    players.append(player)
                }
            }
            
            if !players.isEmpty {
                playerPools[sound.rawValue] = players
                playerIndices[sound.rawValue] = 0
                print("✅ Loaded \(players.count) players for: \(sound.fileName)")
            }
        }
    }
    
    private func findSoundURL(for sound: SoundEffect) -> URL? {
        let extensions = ["wav", "mp3", "m4a"]
        for ext in extensions {
            if let url = Bundle.main.url(forResource: sound.fileName, withExtension: ext) {
                return url
            }
        }
        return nil
    }
    
    private func createPlayer(from url: URL) -> AVAudioPlayer? {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            return player
        } catch {
            print("⚠️ Error creating player: \(error.localizedDescription)")
            return nil
        }
    }
    
    func play(_ sound: SoundEffect, volume: Float = 1.0) {
        guard isSoundEnabled else { return }
        
        let currentVolume = self.volume
        
        lock.lock()
        defer { lock.unlock() }
        
        guard let players = playerPools[sound.rawValue],
              !players.isEmpty,
              var index = playerIndices[sound.rawValue] else {
            print("⚠️ Sound player not found for: \(sound.fileName)")
            return
        }
        
        // Round-robin through players for overlapping sounds
        let player = players[index]
        index = (index + 1) % players.count
        playerIndices[sound.rawValue] = index
        
        player.volume = volume * currentVolume
        player.currentTime = 0
        player.play()
    }
    
    @MainActor
    func toggleSound() {
        isSoundEnabled.toggle()
    }
    
    func setVolume(_ volume: Float, for sound: SoundEffect) {
        let currentVolume = self.volume
        
        lock.lock()
        defer { lock.unlock() }
        
        playerPools[sound.rawValue]?.forEach { $0.volume = volume * currentVolume }
    }
}

