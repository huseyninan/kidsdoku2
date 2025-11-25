//
//  SettingsView.swift
//  kidsdoku2
//
//  Settings screen with audio controls, progress management, and app info
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appEnvironment: AppEnvironment
    @ObservedObject var soundManager = SoundManager.shared
    @ObservedObject var completionManager = PuzzleCompletionManager.shared
    @ObservedObject var hapticManager = HapticManager.shared
    
    @State private var showResetAlert = false
    @State private var resetType: ResetType?
    @State private var showAbout = false
    @State private var showPrivacyPolicy = false
    
    enum ResetType {
        case all
        case size3x3
        case size4x4
        case size6x6
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.93, blue: 0.87),
                    Color(red: 0.90, green: 0.88, blue: 0.82)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Title
                    Text("Settings")
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                        .padding(.top, 8)
                    
                    VStack(spacing: 20) {
                        // Audio & Feedback Section
                        SettingsSection(
                            icon: "speaker.wave.3.fill",
                            title: String(localized: "Audio & Feedback")
                        ) {
                            SettingsToggle(
                                icon: "speaker.2.fill",
                                title: String(localized: "Sound Effects"),
                                subtitle: String(localized: "Play sounds during gameplay"),
                                isOn: $soundManager.isSoundEnabled
                            )
                            
                            SettingsToggle(
                                icon: "hand.tap.fill",
                                title: String(localized: "Haptic Feedback"),
                                subtitle: String(localized: "Vibration feedback for interactions"),
                                isOn: $hapticManager.isHapticsEnabled
                            )
                        }
                        
                        // Grid Visibility Section
                        SettingsSection(
                            icon: "square.grid.3x3.fill",
                            title: String(localized: "Grid Sizes")
                        ) {
                            SettingsToggle(
                                icon: "square.grid.3x3",
                                title: String(localized: "Show 3x3 Grid"),
                                subtitle: String(localized: "Tiny Tales"),
                                isOn: $appEnvironment.show3x3Grid
                            )
                            
                            SettingsToggle(
                                icon: "square.grid.4x3.fill",
                                title: String(localized: "Show 4x4 Grid"),
                                subtitle: String(localized: "Fable Adventures"),
                                isOn: $appEnvironment.show4x4Grid
                            )
                            
                            SettingsToggle(
                                icon: "square.grid.3x3.fill",
                                title: String(localized: "Show 6x6 Grid"),
                                subtitle: String(localized: "Kingdom Chronicles"),
                                isOn: $appEnvironment.show6x6Grid
                            )
                        }
                        
                        // Progress Management Section
                        SettingsSection(
                            icon: "chart.bar.fill",
                            title: String(localized: "Progress Management")
                        ) {
                            if appEnvironment.show3x3Grid {
                                SettingsButton(
                                    icon: "arrow.counterclockwise",
                                    title: String(localized: "Reset 3x3 Progress"),
                                    subtitle: String(localized: "Clear all completed 3x3 puzzles"),
                                    color: .orange
                                ) {
                                    resetType = .size3x3
                                    showResetAlert = true
                                }
                            }
                            
                            if appEnvironment.show4x4Grid {
                                SettingsButton(
                                    icon: "arrow.counterclockwise",
                                    title: String(localized: "Reset 4x4 Progress"),
                                    subtitle: String(localized: "Clear all completed 4x4 puzzles"),
                                    color: .orange
                                ) {
                                    resetType = .size4x4
                                    showResetAlert = true
                                }
                            }
                            
                            if appEnvironment.show6x6Grid {
                                SettingsButton(
                                    icon: "arrow.counterclockwise",
                                    title: String(localized: "Reset 6x6 Progress"),
                                    subtitle: String(localized: "Clear all completed 6x6 puzzles"),
                                    color: .orange
                                ) {
                                    resetType = .size6x6
                                    showResetAlert = true
                                }
                            }
                            
                            SettingsButton(
                                icon: "trash.fill",
                                title: String(localized: "Reset All Progress"),
                                subtitle: String(localized: "Clear all game progress"),
                                color: .red
                            ) {
                                resetType = .all
                                showResetAlert = true
                            }
                        }
                        
                        // About & Info Section
                        SettingsSection(
                            icon: "info.circle.fill",
                            title: String(localized: "Information")
                        ) {
                            SettingsButton(
                                icon: "heart.fill",
                                title: String(localized: "About"),
                                subtitle: String(localized: "App info and credits"),
                                color: Color(red: 0.7, green: 0.35, blue: 0.3)
                            ) {
                                showAbout = true
                            }
                            
                            SettingsButton(
                                icon: "hand.raised.fill",
                                title: String(localized: "Privacy Policy"),
                                subtitle: String(localized: "How we protect your data"),
                                color: Color(red: 0.45, green: 0.55, blue: 0.65)
                            ) {
                                showPrivacyPolicy = true
                            }
                        }
                        
                        // Version info
                        Text("Version 1.0.0")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                            .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .alert(String(localized: "Reset Progress?"), isPresented: $showResetAlert) {
            Button(String(localized: "Cancel"), role: .cancel) { }
            Button(String(localized: "Reset"), role: .destructive) {
                performReset()
            }
        } message: {
            Text(resetAlertMessage)
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
    }
    
    private var resetAlertMessage: String {
        switch resetType {
        case .all:
            return String(localized: "This will clear all your puzzle progress. This action cannot be undone.")
        case .size3x3:
            return String(localized: "This will clear all your 3x3 puzzle progress. This action cannot be undone.")
        case .size4x4:
            return String(localized: "This will clear all your 4x4 puzzle progress. This action cannot be undone.")
        case .size6x6:
            return String(localized: "This will clear all your 6x6 puzzle progress. This action cannot be undone.")
        case .none:
            return ""
        }
    }
    
    private func performReset() {
        switch resetType {
        case .all:
            completionManager.resetAll()
        case .size3x3:
            completionManager.resetSize(3)
        case .size4x4:
            completionManager.resetSize(4)
        case .size6x6:
            completionManager.resetSize(6)
        case .none:
            break
        }
        
        // Play feedback sound if enabled
        if soundManager.isSoundEnabled {
            soundManager.play(.incorrectPlacement, volume: 0.5)
        }
    }
}

// MARK: - Settings Section Container
struct SettingsSection<Content: View>: View {
    let icon: String
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(red: 0.7, green: 0.35, blue: 0.3))
                
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            VStack(spacing: 12) {
                content
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.7))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Settings Toggle
struct SettingsToggle: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(red: 0.45, green: 0.28, blue: 0.15))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(red: 0.7, green: 0.35, blue: 0.3))
                .onChange(of: isOn) { _ in
                    HapticManager.shared.trigger(.selection)
                }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(red: 0.98, green: 0.97, blue: 0.95))
        )
    }
}

// MARK: - Settings Button
struct SettingsButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.trigger(.light)
            action()
        }) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0.98, green: 0.97, blue: 0.95))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - About View
struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.93, blue: 0.87),
                        Color(red: 0.90, green: 0.88, blue: 0.82)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Image("fox_bg")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            .padding(.top, 20)
                        
                        Text("KidsDoku")
                            .font(.system(size: 42, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                        
                        Text("Version 1.0.0")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            AboutSection(
                                icon: "paintbrush.fill",
                                title: String(localized: "Design & Development"),
                                content: String(localized: "Created with love for young puzzle enthusiasts")
                            )
                            
                            AboutSection(
                                icon: "photo.fill",
                                title: String(localized: "Illustrations"),
                                content: String(localized: "Featuring adorable animals, birds, and sea creatures")
                            )
                            
                            AboutSection(
                                icon: "music.note",
                                title: String(localized: "Sound Design"),
                                content: String(localized: "Engaging audio feedback to enhance the learning experience")
                            )
                            
                            AboutSection(
                                icon: "sparkles",
                                title: String(localized: "Mission"),
                                content: String(localized: "To make learning logical thinking fun and engaging for children through interactive puzzles")
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        Text("© 2025 KidsDoku. All rights reserved.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                            .padding(.top, 16)
                            .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "Done")) {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.7, green: 0.35, blue: 0.3))
                }
            }
        }
    }
}

struct AboutSection: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(Color(red: 0.7, green: 0.35, blue: 0.3))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                
                Text(content)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.7))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.93, blue: 0.87),
                        Color(red: 0.90, green: 0.88, blue: 0.82)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(red: 0.7, green: 0.35, blue: 0.3))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                        
                        Text("Privacy Policy")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                            .frame(maxWidth: .infinity)
                        
                        PrivacySection(
                            title: String(localized: "Your Privacy Matters"),
                            content: String(localized: "KidsDoku is designed with children's privacy and safety as our top priority.")
                        )
                        
                        PrivacySection(
                            title: String(localized: "Data Collection"),
                            content: String(localized: "We do NOT collect, store, or share any personal information. All game progress is stored locally on your device.")
                        )
                        
                        PrivacySection(
                            title: String(localized: "No Third-Party Services"),
                            content: String(localized: "This app does not use any analytics, advertising, or third-party tracking services.")
                        )
                        
                        PrivacySection(
                            title: String(localized: "Offline First"),
                            content: String(localized: "KidsDoku works completely offline. No internet connection is required or used during gameplay.")
                        )
                        
                        PrivacySection(
                            title: String(localized: "Parental Control"),
                            content: String(localized: "Parents maintain full control over app data through device settings and can reset all progress at any time through the Settings menu.")
                        )
                        
                        Text("Last Updated: November 2025")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 16)
                            .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "Done")) {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.7, green: 0.35, blue: 0.3))
                }
            }
        }
    }
}

struct PrivacySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
            
            Text(content)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Color.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.7))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppEnvironment())
}

