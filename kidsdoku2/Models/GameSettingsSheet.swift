//
//  GameSettingsSheet.swift
//  kidsdoku2
//
//  Created by Assistant on 26.11.2025.
//

import SwiftUI

struct GameSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var soundManager = SoundManager.shared
    @ObservedObject var hapticManager = HapticManager.shared
    
    @Binding var selectedSymbolGroup: SymbolGroup
    @Binding var showNumbers: Bool
    
    let availableSymbolGroups: [SymbolGroup]
    
    init(selectedSymbolGroup: Binding<SymbolGroup>, showNumbers: Binding<Bool>) {
        self._selectedSymbolGroup = selectedSymbolGroup
        self._showNumbers = showNumbers
        self.availableSymbolGroups = SymbolGroup.puzzleCases
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.95, blue: 0.89),
                        Color(red: 0.94, green: 0.91, blue: 0.85)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        Text("Game Settings")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                            .padding(.top, 8)
                        
                        VStack(spacing: 20) {
                            // Display Mode Section
                            GameSettingsSection(
                                icon: "eye.fill",
                                title: "Display Mode"
                            ) {
                                GameSettingsToggle(
                                    icon: showNumbers ? "textformat.123" : "photo.fill",
                                    title: showNumbers ? "Numbers Mode" : "Picture Mode",
                                    subtitle: showNumbers ? "Show numbers instead of pictures" : "Show pictures instead of numbers",
                                    isOn: $showNumbers
                                ) {
                                    hapticManager.trigger(.selection)
                                    soundManager.play(.correctPlacement, volume: 0.4)
                                }
                            }
                            
                            // Symbol Group Section (only shown when not in numbers mode)
                            if !showNumbers {
                                GameSettingsSection(
                                    icon: "photo.on.rectangle.angled",
                                    title: "Picture Theme"
                                ) {
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                        ForEach(availableSymbolGroups, id: \.id) { group in
                                            SymbolGroupCard(
                                                symbolGroup: group,
                                                isSelected: selectedSymbolGroup == group,
                                                onSelect: {
                                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                        selectedSymbolGroup = group
                                                    }
                                                    hapticManager.trigger(.selection)
                                                    soundManager.play(.correctPlacement, volume: 0.3)
                                                }
                                            )
                                        }
                                    }
                                }
                            }
                            
                            // Audio & Feedback Section
                            GameSettingsSection(
                                icon: "speaker.wave.3.fill",
                                title: "Audio & Feedback"
                            ) {
                                GameSettingsToggle(
                                    icon: soundManager.isSoundEnabled ? "speaker.2.fill" : "speaker.slash.fill",
                                    title: "Sound Effects",
                                    subtitle: "Play sounds during gameplay",
                                    isOn: $soundManager.isSoundEnabled
                                ) {
                                    hapticManager.trigger(.selection)
                                    if soundManager.isSoundEnabled {
                                        soundManager.play(.correctPlacement, volume: 0.4)
                                    }
                                }
                                
                                GameSettingsToggle(
                                    icon: hapticManager.isHapticsEnabled ? "hand.tap.fill" : "hand.tap",
                                    title: "Haptic Feedback",
                                    subtitle: "Vibration feedback for interactions",
                                    isOn: $hapticManager.isHapticsEnabled
                                ) {
                                    if hapticManager.isHapticsEnabled {
                                        hapticManager.trigger(.selection)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                }
            }
        }
    }
}

private struct GameSettingsSection<Content: View>: View {
    let icon: String
    let title: String
    let content: Content
    
    init(icon: String, title: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(red: 0.5, green: 0.3, blue: 0.2))
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
            }
            
            content
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.8))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

private struct GameSettingsToggle: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let onToggle: (() -> Void)?
    
    init(icon: String, title: String, subtitle: String, isOn: Binding<Bool>, onToggle: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
        self.onToggle = onToggle
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.6, green: 0.4, blue: 0.3),
                            Color(red: 0.5, green: 0.3, blue: 0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.3, green: 0.2, blue: 0.1))
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 0.6, green: 0.5, blue: 0.4))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(StorybookToggleStyle())
                .onChange(of: isOn) { _ in
                    onToggle?()
                }
        }
        .padding(.vertical, 8)
    }
}

private struct SymbolGroupCard: View {
    let symbolGroup: SymbolGroup
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                // Preview symbols in a mini grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 4) {
                    ForEach(Array(symbolGroup.symbols.dropFirst().prefix(6).enumerated()), id: \.offset) { _, symbol in
                        Image(symbol)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white.opacity(0.3))
                            )
                    }
                }
                .frame(height: 60)
                
                Text(symbolGroup.paletteTitle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isSelected ? [
                                Color(red: 1.0, green: 0.92, blue: 0.78),
                                Color(red: 0.98, green: 0.88, blue: 0.72)
                            ] : [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                isSelected ? Color(red: 0.85, green: 0.65, blue: 0.45) : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(color: Color.black.opacity(isSelected ? 0.1 : 0.05), radius: isSelected ? 8 : 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

private struct StorybookToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    configuration.isOn
                        ? LinearGradient(
                            colors: [Color(red: 0.4, green: 0.8, blue: 0.4), Color(red: 0.3, green: 0.7, blue: 0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color(red: 0.85, green: 0.85, blue: 0.85), Color(red: 0.75, green: 0.75, blue: 0.75)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                )
                .frame(width: 50, height: 30)
                .overlay {
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .frame(width: 26, height: 26)
                        .offset(x: configuration.isOn ? 10 : -10)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isOn)
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GameSettingsSheet(
        selectedSymbolGroup: .constant(.animals),
        showNumbers: .constant(false)
    )
}
