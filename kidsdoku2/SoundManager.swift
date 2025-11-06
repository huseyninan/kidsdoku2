import AVFoundation
import SwiftUI
import Combine

@MainActor
class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    @Published var isSoundEnabled: Bool = true
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    private init() {
        setupSounds()
    }
    
    private func setupSounds() {
        // Using system sounds as fallback
        // You can replace these with custom sound files later
    }
    
    // MARK: - Play Sound Methods
    
    func playTapSound() {
        guard isSoundEnabled else { return }
        // Light, cheerful tap sound
        playSystemSound(id: 1104) // Tock sound
    }
    
    func playSelectSound() {
        guard isSoundEnabled else { return }
        // Soft selection sound
        playSystemSound(id: 1105) // Tock sound (alternate)
    }
    
    func playCorrectPlacementSound() {
        guard isSoundEnabled else { return }
        // Happy, positive sound for correct placement
        playSystemSound(id: 1103) // Text Tone - Note sound (cheerful)
    }
    
    func playErrorSound() {
        guard isSoundEnabled else { return }
        // Gentle error sound - not harsh or scary for kids
        playSystemSound(id: 1053) // Tweet sound (soft)
    }
    
    func playEraseSound() {
        guard isSoundEnabled else { return }
        // Whoosh/swipe sound
        playSystemSound(id: 1155) // Shake sound (gentle)
    }
    
    func playCelebrationSound() {
        guard isSoundEnabled else { return }
        // Victory sound for puzzle completion
        playSystemSound(id: 1025) // Fanfare/Success sound
        
        // Add a second sound for extra celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.playSystemSound(id: 1106) // Another cheerful tone
        }
    }
    
    func playHighlightSound() {
        guard isSoundEnabled else { return }
        // Very soft sound for highlighting matching values
        playSystemSound(id: 1057) // Very gentle tick
    }
    
    // MARK: - System Sound Helper
    
    private func playSystemSound(id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }
    
    // MARK: - Haptic Feedback
    
    func playHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        guard isSoundEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func playSuccessHaptic() {
        guard isSoundEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func playWarningHaptic() {
        guard isSoundEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    // MARK: - Toggle Sound
    
    func toggleSound() {
        isSoundEnabled.toggle()
        if isSoundEnabled {
            playTapSound() // Give feedback that sound is now on
        }
    }
}

