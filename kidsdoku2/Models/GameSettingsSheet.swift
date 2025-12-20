//
//  GameSettingsSheet.swift
//  kidsdoku2
//
//  Created by Assistant on 26.11.2025.
//

import SwiftUI

struct GameSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appEnvironment: AppEnvironment
    
    @Binding var selectedSymbolGroup: SymbolGroup
    @Binding var showNumbers: Bool
    
    let availableSymbolGroups: [SymbolGroup]
    
    private static let twoColumnGrid = [GridItem(.flexible()), GridItem(.flexible())]
    
    init(selectedSymbolGroup: Binding<SymbolGroup>, showNumbers: Binding<Bool>, themeType: GameThemeType) {
        self._selectedSymbolGroup = selectedSymbolGroup
        self._showNumbers = showNumbers
        switch themeType {
        case .storybook:
            self.availableSymbolGroups = SymbolGroup.puzzleCases
        case .christmas:
            self.availableSymbolGroups = SymbolGroup.christmasCases
        }
    }
    
    var body: some View {
        NavigationStack {
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
                                title: String(localized: "Display Mode")
                            ) {
                                DisplayModeSegmentedPicker(showNumbers: $showNumbers)
                            }
                            
                            // Audio & Feedback Section
                            GameSettingsSection(
                                icon: "speaker.wave.3.fill",
                                title: String(localized: "Audio & Feedback")
                            ) {
                            GameSettingsToggle(
                                icon: appEnvironment.soundManager.isSoundEnabled ? "speaker.2.fill" : "speaker.slash.fill",
                                title: String(localized: "Sound Effects"),
                                subtitle: String(localized: "Play sounds during gameplay"),
                                isOn: Binding(
                                    get: { appEnvironment.soundManager.isSoundEnabled },
                                    set: { appEnvironment.soundManager.isSoundEnabled = $0 }
                                )
                            )
                                
                            GameSettingsToggle(
                                icon: appEnvironment.hapticManager.isHapticsEnabled ? "hand.tap.fill" : "hand.tap",
                                title: String(localized: "Haptic Feedback"),
                                subtitle: String(localized: "Vibration feedback for interactions"),
                                isOn: Binding(
                                    get: { appEnvironment.hapticManager.isHapticsEnabled },
                                    set: { appEnvironment.hapticManager.isHapticsEnabled = $0 }
                                )
                            )
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

private struct DisplayModeSegmentedPicker: View {
    @Binding var showNumbers: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Picture Mode Button
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showNumbers = false
                }
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(
                            !showNumbers 
                            ? Color.white
                            : Color(red: 0.5, green: 0.35, blue: 0.25)
                        )
                    
                    Text("Picture Mode")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(
                            !showNumbers 
                            ? Color.white
                            : Color(red: 0.5, green: 0.35, blue: 0.25)
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            !showNumbers
                            ? LinearGradient(
                                colors: [
                                    Color(red: 0.6, green: 0.4, blue: 0.3),
                                    Color(red: 0.5, green: 0.3, blue: 0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            !showNumbers 
                            ? Color(red: 0.7, green: 0.5, blue: 0.4).opacity(0.3)
                            : Color.clear,
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: Color.black.opacity(!showNumbers ? 0.15 : 0.05),
                    radius: !showNumbers ? 8 : 4,
                    x: 0,
                    y: !showNumbers ? 4 : 2
                )
                .scaleEffect(!showNumbers ? 1.02 : 1.0)
            }
            .buttonStyle(.plain)
            
            // Numbers Mode Button
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showNumbers = true
                }
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "textformat.123")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(
                            showNumbers 
                            ? Color.white
                            : Color(red: 0.5, green: 0.35, blue: 0.25)
                        )
                    
                    Text("Numbers Mode")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(
                            showNumbers 
                            ? Color.white
                            : Color(red: 0.5, green: 0.35, blue: 0.25)
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            showNumbers
                            ? LinearGradient(
                                colors: [
                                    Color(red: 0.6, green: 0.4, blue: 0.3),
                                    Color(red: 0.5, green: 0.3, blue: 0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            showNumbers 
                            ? Color(red: 0.7, green: 0.5, blue: 0.4).opacity(0.3)
                            : Color.clear,
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: Color.black.opacity(showNumbers ? 0.15 : 0.05),
                    radius: showNumbers ? 8 : 4,
                    x: 0,
                    y: showNumbers ? 4 : 2
                )
                .scaleEffect(showNumbers ? 1.02 : 1.0)
            }
            .buttonStyle(.plain)
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
        }
        .padding(.vertical, 8)
    }
}

private struct SymbolGroupCard: View {
    let symbolGroup: SymbolGroup
    let isSelected: Bool
    let onSelect: () -> Void
    
    private let previewSymbols: [String]
    private static let previewLimit = 6
    private static let threeColumnGrid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    init(symbolGroup: SymbolGroup, isSelected: Bool, onSelect: @escaping () -> Void) {
        self.symbolGroup = symbolGroup
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.previewSymbols = Self.makePreviewSymbols(for: symbolGroup)
    }
    
    private static func makePreviewSymbols(for group: SymbolGroup) -> [String] {
        let symbols = group.symbols
        guard !symbols.isEmpty else { return [] }
        
        var uniqueSymbols: [String] = []
        var seen: Set<String> = []
        
        for symbol in symbols.dropFirst() where !symbol.isEmpty {
            if seen.insert(symbol).inserted {
                uniqueSymbols.append(symbol)
            }
            if uniqueSymbols.count == previewLimit {
                return uniqueSymbols
            }
        }
        
        if uniqueSymbols.isEmpty, let fallback = symbols.first {
            uniqueSymbols = [fallback]
        }
        
        return uniqueSymbols
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                // Preview symbols in a mini grid
                LazyVGrid(columns: Self.threeColumnGrid, spacing: 4) {
                    ForEach(previewSymbols.indices, id: \.self) { index in
                        let symbol = previewSymbols[index]
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
        showNumbers: .constant(false),
        themeType: .storybook
    )
    .environmentObject(AppEnvironment())
}
