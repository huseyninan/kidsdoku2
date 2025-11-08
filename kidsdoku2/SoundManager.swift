import AVFoundation
import Combine

@MainActor
final class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    @Published var isSoundEnabled: Bool = true
    
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
        // Preload all sounds
        preloadSounds()
    }
    
    private func preloadSounds() {
        for sound in [SoundEffect.correctPlacement, .incorrectPlacement, .victory, .hint] {
            guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: "wav") else {
                print("⚠️ Sound file not found: \(sound.fileName).wav")
                continue
            }
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                audioPlayers[sound.rawValue] = player
            } catch {
                print("⚠️ Error loading sound \(sound.fileName): \(error.localizedDescription)")
            }
        }
    }
    
    func play(_ sound: SoundEffect, volume: Float = 1.0) {
        guard isSoundEnabled else { return }
        
        guard let player = audioPlayers[sound.rawValue] else {
            print("⚠️ Sound player not found for: \(sound.fileName)")
            return
        }
        
        player.volume = volume
        player.currentTime = 0
        player.play()
    }
    
    func toggleSound() {
        isSoundEnabled.toggle()
    }
    
    func setVolume(_ volume: Float, for sound: SoundEffect) {
        audioPlayers[sound.rawValue]?.volume = volume
    }
}

