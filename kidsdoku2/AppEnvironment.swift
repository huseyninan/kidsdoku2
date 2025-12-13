//
//  AppEnvironment.swift
//  kidsdoku2
//
//  Created by hinan on 17.11.2025.
//

import SwiftUI
import RevenueCat
import Combine

/// App-wide environment object for managing global state
@MainActor
class AppEnvironment: ObservableObject {
    /// Whether the user has an active premium subscription
    @Published var isPremium: Bool = false
    
    /// Whether the app is currently loading subscription status
    @Published var isLoadingSubscription: Bool = true
    
    /// Grid visibility settings
    @AppStorage("show3x3Grid") var show3x3Grid: Bool = true
    @AppStorage("show4x4Grid") var show4x4Grid: Bool = true
    @AppStorage("show6x6Grid") var show6x6Grid: Bool = true
    
    /// Current game theme
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = GameThemeType.storybook.rawValue
    
    /// Published property for the current theme type
    @Published var currentThemeType: GameThemeType = .storybook
    
    /// Get the current theme
    var currentTheme: GameTheme {
        currentThemeType.theme
    }
    
    /// Reference to the sound manager singleton
    let soundManager = SoundManager.shared
    
    /// Reference to the haptic manager singleton
    let hapticManager = HapticManager.shared
    
    init() {
        // Load saved theme
        if let savedTheme = GameThemeType(rawValue: selectedThemeRaw) {
            currentThemeType = savedTheme
        }
        
        Task {
            await checkSubscriptionStatus()
        }
    }
    
    /// Set the current theme
    func setTheme(_ theme: GameThemeType) {
        currentThemeType = theme
        selectedThemeRaw = theme.rawValue
    }
    
    /// Checks the user's subscription status with RevenueCat
    func checkSubscriptionStatus() async {
        isLoadingSubscription = true
        defer { isLoadingSubscription = false }
        
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            isPremium = customerInfo.entitlements["Pro"]?.isActive == true
            print("Subscription status checked: isPremium = \(isPremium)")
        } catch {
            print("Error checking subscription status: \(error.localizedDescription)")
            isPremium = false
        }
    }
    
    /// Call this after a successful purchase to refresh subscription status
    func refreshSubscriptionStatus() {
        Task {
            await checkSubscriptionStatus()
        }
    }
}

