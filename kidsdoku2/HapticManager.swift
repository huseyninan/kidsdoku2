//
//  HapticManager.swift
//  kidsdoku2
//
//  Manages haptic feedback throughout the app
//

import Combine
import SwiftUI
import UIKit

@MainActor
final class HapticManager: ObservableObject {
    static let shared = HapticManager()
    
    @AppStorage("hapticsEnabled") var isHapticsEnabled: Bool = true
    
    // Pre-initialized generators for better performance
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private init() {
        // Prepare all generators on initialization
        prepareAllGenerators()
    }
    
    enum HapticType {
        case light
        case medium
        case heavy
        case success
        case warning
        case error
        case selection
    }
    
    /// Prepares all haptic generators for immediate use
    private func prepareAllGenerators() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    func trigger(_ type: HapticType) {
        guard isHapticsEnabled else { return }
        
        switch type {
        case .light:
            lightGenerator.impactOccurred()
            lightGenerator.prepare() // Prepare for next use
            
        case .medium:
            mediumGenerator.impactOccurred()
            mediumGenerator.prepare()
            
        case .heavy:
            heavyGenerator.impactOccurred()
            heavyGenerator.prepare()
            
        case .success:
            notificationGenerator.notificationOccurred(.success)
            notificationGenerator.prepare()
            
        case .warning:
            notificationGenerator.notificationOccurred(.warning)
            notificationGenerator.prepare()
            
        case .error:
            notificationGenerator.notificationOccurred(.error)
            notificationGenerator.prepare()
            
        case .selection:
            selectionGenerator.selectionChanged()
            selectionGenerator.prepare()
        }
    }
}

