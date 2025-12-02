import AVFoundation
import Combine
import SwiftUI

final class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    /// Serial queue for all audio operations - ensures thread safety for AVAudioPlayer
    private let audioQueue = DispatchQueue(label: "com.kidsdoku.audio", qos: .userInteractive)
    
    /// Audio players dictionary - only accessed from audioQueue
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
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
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("⚠️ Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    private func preloadSounds() {
        // Preload sounds synchronously on the audio queue to ensure thread safety
        audioQueue.sync {
            for sound in [SoundEffect.correctPlacement, .incorrectPlacement, .victory, .hint] {
                guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: "wav") else {
                    print("⚠️ Sound file not found: \(sound.fileName).wav")
                    // Try with different extensions
                    if let mp3Url = Bundle.main.url(forResource: sound.fileName, withExtension: "mp3") {
                        loadSoundUnsafe(from: mp3Url, for: sound)
                    } else if let m4aUrl = Bundle.main.url(forResource: sound.fileName, withExtension: "m4a") {
                        loadSoundUnsafe(from: m4aUrl, for: sound)
                    }
                    continue
                }
                
                loadSoundUnsafe(from: url, for: sound)
            }
        }
    }
    
    /// Loads a sound - must be called from audioQueue
    private func loadSoundUnsafe(from url: URL, for sound: SoundEffect) {
        dispatchPrecondition(condition: .onQueue(audioQueue))
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            audioPlayers[sound.rawValue] = player
            print("✅ Loaded sound: \(sound.fileName)")
        } catch {
            print("⚠️ Error loading sound \(sound.fileName): \(error.localizedDescription)")
        }
    }
    
    func play(_ sound: SoundEffect, volume: Float = 1.0) {
        guard isSoundEnabled else { return }
        
        // Capture volume value before dispatching to avoid accessing published property from background
        let currentVolume = self.volume
        
        // Play audio on serial queue to ensure thread safety
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard let player = self.audioPlayers[sound.rawValue] else {
                print("⚠️ Sound player not found for: \(sound.fileName)")
                return
            }
            
            player.volume = volume * currentVolume
            player.currentTime = 0
            
            // Stop any currently playing instance of this sound
            if player.isPlaying {
                player.stop()
                player.currentTime = 0
            }
            
            player.play()
            
            if !player.isPlaying {
                print("⚠️ Failed to play sound: \(sound.fileName)")
            }
        }
    }
    
    @MainActor
    func toggleSound() {
        isSoundEnabled.toggle()
    }
    
    func setVolume(_ volume: Float, for sound: SoundEffect) {
        // Capture volume value before dispatching
        let currentVolume = self.volume
        
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            self.audioPlayers[sound.rawValue]?.volume = volume * currentVolume
        }
    }
}

