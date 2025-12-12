//
//  GameTheme.swift
//  kidsdoku2
//
//  Theme system for customizable game appearance.
//

import SwiftUI

// MARK: - Theme Type Enum

enum GameThemeType: String, CaseIterable, Identifiable {
    case storybook = "storybook"
    case christmas = "christmas"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .storybook:
            return String(localized: "Storybook")
        case .christmas:
            return String(localized: "Christmas")
        }
    }
    
    var theme: GameTheme {
        switch self {
        case .storybook:
            return StorybookTheme()
        case .christmas:
            return ChristmasTheme()
        }
    }
}

// MARK: - Game Theme Protocol

protocol GameTheme {
    // MARK: - Background
    var backgroundImageName: String { get }
    var showRunningFox: Bool { get }
    
    // MARK: - Header Colors
    var badgeTextColor: Color { get }
    var badgeGradientStart: Color { get }
    var badgeGradientEnd: Color { get }
    var badgeBorderColor: Color { get }
    
    var headerCardGradientStart: Color { get }
    var headerCardGradientEnd: Color { get }
    var headerCardBorderColor: Color { get }
    
    var infoChipTextColor: Color { get }
    var infoChipGradientStart: Color { get }
    var infoChipGradientEnd: Color { get }
    
    var progressBarBackground: Color { get }
    var progressBarGradient: [Color] { get }
    
    // MARK: - Board Colors
    var boardMatGradientStart: Color { get }
    var boardMatGradientEnd: Color { get }
    var boardMatBorderGradientStart: Color { get }
    var boardMatBorderGradientEnd: Color { get }
    
    var boardBackgroundColor: Color { get }
    var cellBorderColor: Color { get }
    var fixedCellColor: Color { get }
    var emptyCellColor: Color { get }
    var selectedCellColor: Color { get }
    var subgridLineColor: Color { get }
    
    // MARK: - Palette Colors
    var paletteTitleColor: Color { get }
    var paletteSubtitleColor: Color { get }
    var paletteMatGradientStart: Color { get }
    var paletteMatGradientEnd: Color { get }
    var paletteMatBorderColor: Color { get }
    
    // MARK: - Action Button Colors
    var actionButtonTextColor: Color { get }
    var actionButtonDisabledColor: Color { get }
    
    var undoGradientStart: Color { get }
    var undoGradientEnd: Color { get }
    var eraseGradientStart: Color { get }
    var eraseGradientEnd: Color { get }
    var hintGradientStart: Color { get }
    var hintGradientEnd: Color { get }
    
    // MARK: - Message Banner Colors
    var messageBannerTextColor: Color { get }
    var messageBannerBackgroundStart: Color { get }
    var messageBannerSymbolBackgroundStart: Color { get }
    var messageBannerSymbolBackgroundEnd: Color { get }
    
    // MARK: - Highlight Colors
    var highlightGradientStart: Color { get }
    var highlightGradientEnd: Color { get }
    var highlightGlowColor: Color { get }
}

// MARK: - Default Implementation

extension GameTheme {
    var showRunningFox: Bool { true }
}

// MARK: - Storybook Theme (Default)

struct StorybookTheme: GameTheme {
    // Background
    let backgroundImageName = "gridbg"
    let showRunningFox = true
    
    // Header - Badge
    let badgeTextColor = Color(red: 0.33, green: 0.22, blue: 0.12)
    let badgeGradientStart = Color(red: 0.99, green: 0.94, blue: 0.82)
    let badgeGradientEnd = Color(red: 0.95, green: 0.87, blue: 0.74)
    let badgeBorderColor = Color(red: 0.85, green: 0.67, blue: 0.46)
    
    // Header Card
    let headerCardGradientStart = Color.white.opacity(0.9)
    let headerCardGradientEnd = Color(red: 0.99, green: 0.94, blue: 0.86)
    let headerCardBorderColor = Color(red: 0.91, green: 0.83, blue: 0.7)
    
    // Info Chip
    let infoChipTextColor = Color(red: 0.62, green: 0.34, blue: 0.24)
    let infoChipGradientStart = Color(red: 1.0, green: 0.92, blue: 0.81)
    let infoChipGradientEnd = Color(red: 0.98, green: 0.82, blue: 0.65)
    
    // Progress Bar
    let progressBarBackground = Color.white.opacity(0.6)
    let progressBarGradient: [Color] = [
        Color(red: 0.99, green: 0.78, blue: 0.33),
        Color(red: 0.98, green: 0.6, blue: 0.37),
        Color(red: 0.4, green: 0.7, blue: 0.35)
    ]
    
    // Board Mat
    let boardMatGradientStart = Color(red: 1.0, green: 0.97, blue: 0.92)
    let boardMatGradientEnd = Color.white
    let boardMatBorderGradientStart = Color(red: 0.94, green: 0.83, blue: 0.67)
    let boardMatBorderGradientEnd = Color(red: 0.86, green: 0.68, blue: 0.5)
    
    // Board Grid
    let boardBackgroundColor = Color.white
    let cellBorderColor = Color(red: 0.89, green: 0.84, blue: 0.76)
    let fixedCellColor = Color(red: 0.96, green: 0.94, blue: 0.89)
    let emptyCellColor = Color.white
    let selectedCellColor = Color.red.opacity(0.6)
    let subgridLineColor = Color(red: 0.76, green: 0.65, blue: 0.52)
    
    // Palette
    let paletteTitleColor = Color(red: 0.44, green: 0.3, blue: 0.23)
    let paletteSubtitleColor = Color(red: 0.62, green: 0.47, blue: 0.34)
    let paletteMatGradientStart = Color(red: 1.0, green: 0.97, blue: 0.91)
    let paletteMatGradientEnd = Color(red: 0.96, green: 0.92, blue: 0.84)
    let paletteMatBorderColor = Color(red: 0.91, green: 0.82, blue: 0.69)
    
    // Action Buttons
    let actionButtonTextColor = Color(red: 0.37, green: 0.28, blue: 0.18)
    let actionButtonDisabledColor = Color(.systemGray3)
    
    let undoGradientStart = Color(red: 0.98, green: 0.89, blue: 0.75)
    let undoGradientEnd = Color(red: 0.97, green: 0.78, blue: 0.58)
    let eraseGradientStart = Color(red: 0.95, green: 0.85, blue: 0.95)
    let eraseGradientEnd = Color(red: 0.88, green: 0.7, blue: 0.92)
    let hintGradientStart = Color(red: 1.0, green: 0.93, blue: 0.76)
    let hintGradientEnd = Color(red: 0.99, green: 0.82, blue: 0.64)
    
    // Message Banner
    let messageBannerTextColor = Color(red: 0.37, green: 0.28, blue: 0.18)
    let messageBannerBackgroundStart = Color(red: 1.0, green: 0.97, blue: 0.91)
    let messageBannerSymbolBackgroundStart = Color.white.opacity(0.98)
    let messageBannerSymbolBackgroundEnd = Color(red: 1.0, green: 0.96, blue: 0.9)
    
    // Highlight
    let highlightGradientStart = Color(red: 0.23, green: 0.78, blue: 1.0)
    let highlightGradientEnd = Color(red: 0.0, green: 0.58, blue: 0.93)
    let highlightGlowColor = Color.cyan
}

// MARK: - Christmas Theme

struct ChristmasTheme: GameTheme {
    // Background
    let backgroundImageName = "christmas_bg"
    let showRunningFox = true
    
    // Header - Badge (Festive red and gold)
    let badgeTextColor = Color(red: 0.5, green: 0.15, blue: 0.15)
    let badgeGradientStart = Color(red: 1.0, green: 0.95, blue: 0.85)
    let badgeGradientEnd = Color(red: 0.95, green: 0.85, blue: 0.7)
    let badgeBorderColor = Color(red: 0.85, green: 0.55, blue: 0.2)
    
    // Header Card (Snowy white with gold accent)
    let headerCardGradientStart = Color.white.opacity(0.95)
    let headerCardGradientEnd = Color(red: 0.98, green: 0.96, blue: 0.92)
    let headerCardBorderColor = Color(red: 0.75, green: 0.2, blue: 0.2).opacity(0.5)
    
    // Info Chip (Christmas red)
    let infoChipTextColor = Color(red: 0.6, green: 0.15, blue: 0.15)
    let infoChipGradientStart = Color(red: 1.0, green: 0.95, blue: 0.9)
    let infoChipGradientEnd = Color(red: 1.0, green: 0.85, blue: 0.8)
    
    // Progress Bar (Red to green gradient)
    let progressBarBackground = Color.white.opacity(0.7)
    let progressBarGradient: [Color] = [
        Color(red: 0.85, green: 0.2, blue: 0.2),
        Color(red: 0.95, green: 0.7, blue: 0.2),
        Color(red: 0.2, green: 0.6, blue: 0.3)
    ]
    
    // Board Mat (Snowy white with red border)
    let boardMatGradientStart = Color(red: 1.0, green: 0.99, blue: 0.97)
    let boardMatGradientEnd = Color.white
    let boardMatBorderGradientStart = Color(red: 0.8, green: 0.25, blue: 0.25)
    let boardMatBorderGradientEnd = Color(red: 0.6, green: 0.15, blue: 0.15)
    
    // Board Grid (Snowy theme)
    let boardBackgroundColor = Color.white
    let cellBorderColor = Color(red: 0.85, green: 0.88, blue: 0.9)
    let fixedCellColor = Color(red: 0.95, green: 0.97, blue: 0.98)
    let emptyCellColor = Color.white
    let selectedCellColor = Color(red: 0.85, green: 0.2, blue: 0.2).opacity(0.5)
    let subgridLineColor = Color(red: 0.2, green: 0.5, blue: 0.3)
    
    // Palette (Christmas green and gold)
    let paletteTitleColor = Color(red: 0.15, green: 0.4, blue: 0.2)
    let paletteSubtitleColor = Color(red: 0.5, green: 0.15, blue: 0.15)
    let paletteMatGradientStart = Color(red: 1.0, green: 0.98, blue: 0.95)
    let paletteMatGradientEnd = Color(red: 0.95, green: 0.92, blue: 0.88)
    let paletteMatBorderColor = Color(red: 0.2, green: 0.5, blue: 0.3).opacity(0.6)
    
    // Action Buttons (Christmas themed)
    let actionButtonTextColor = Color(red: 0.3, green: 0.15, blue: 0.1)
    let actionButtonDisabledColor = Color(.systemGray3)
    
    // Undo - Snowy blue
    let undoGradientStart = Color(red: 0.9, green: 0.95, blue: 1.0)
    let undoGradientEnd = Color(red: 0.8, green: 0.9, blue: 0.98)
    // Erase - Christmas red
    let eraseGradientStart = Color(red: 1.0, green: 0.9, blue: 0.9)
    let eraseGradientEnd = Color(red: 0.95, green: 0.75, blue: 0.75)
    // Hint - Christmas gold
    let hintGradientStart = Color(red: 1.0, green: 0.95, blue: 0.8)
    let hintGradientEnd = Color(red: 0.98, green: 0.85, blue: 0.55)
    
    // Message Banner
    let messageBannerTextColor = Color(red: 0.3, green: 0.15, blue: 0.1)
    let messageBannerBackgroundStart = Color(red: 1.0, green: 0.98, blue: 0.95)
    let messageBannerSymbolBackgroundStart = Color.white.opacity(0.98)
    let messageBannerSymbolBackgroundEnd = Color(red: 1.0, green: 0.97, blue: 0.93)
    
    // Highlight (Festive gold glow)
    let highlightGradientStart = Color(red: 1.0, green: 0.85, blue: 0.3)
    let highlightGradientEnd = Color(red: 0.95, green: 0.7, blue: 0.1)
    let highlightGlowColor = Color(red: 1.0, green: 0.85, blue: 0.4)
}

// MARK: - Theme Environment Key

private struct GameThemeKey: EnvironmentKey {
    static let defaultValue: GameTheme = StorybookTheme()
}

extension EnvironmentValues {
    var gameTheme: GameTheme {
        get { self[GameThemeKey.self] }
        set { self[GameThemeKey.self] = newValue }
    }
}

extension View {
    func gameTheme(_ theme: GameTheme) -> some View {
        environment(\.gameTheme, theme)
    }
}

