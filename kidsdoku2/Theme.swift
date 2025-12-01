//
//  Theme.swift
//  kidsdoku2
//
//  Centralized theme for colors, layout constants, and button styles.
//

import SwiftUI

// MARK: - Theme

enum Theme {
    
    // MARK: - Colors
    
    enum Colors {
        // Premium button gradient
        static let premiumGold = Color(red: 0.95, green: 0.77, blue: 0.06)
        static let premiumGoldDark = Color(red: 0.85, green: 0.55, blue: 0.0)
        
        // Premium button border gradient
        static let premiumBorderLight = Color(red: 1.0, green: 0.95, blue: 0.7)
        static let premiumBorder = Color(red: 0.95, green: 0.85, blue: 0.5)
        
        // Footer
        static let footerText = Color(red: 0.4, green: 0.25, blue: 0.15)
        static let footerBackground = Color(red: 0.85, green: 0.75, blue: 0.6)
        
        // Quest button gradient
        static let questButtonDark = Color(red: 0.35, green: 0.22, blue: 0.12)
        static let questButtonLight = Color(red: 0.45, green: 0.28, blue: 0.15)
        static let questSubtitle = Color(red: 0.9, green: 0.85, blue: 0.75)
        
        // Shared
        static let overlayBackground = Color.black.opacity(0.3)
        static let overlayBorder = Color.white.opacity(0.5)
        
        // Puzzle Selection
        static let puzzleSelectionBackground = Color(red: 0.85, green: 0.88, blue: 0.92)
        static let puzzleHeaderText = Color(red: 0.3, green: 0.3, blue: 0.35)
        static let puzzleSettingsIcon = Color(red: 0.5, green: 0.5, blue: 0.55)
        static let puzzleLoadingText = Color(red: 0.4, green: 0.4, blue: 0.45)
        static let puzzleSettingsBackground = Color(red: 0.85, green: 0.88, blue: 0.92)
        static let puzzleSettingsText = Color(red: 0.4, green: 0.4, blue: 0.45)
        static let puzzleSettingsTitle = Color(red: 0.3, green: 0.3, blue: 0.35)
        static let puzzleToggleHideFinished = Color(red: 0.24, green: 0.65, blue: 0.33)
        
        // Difficulty Colors
        static let difficultyEasy = Color(red: 0.45, green: 0.55, blue: 0.45)
        static let difficultyNormal = Color(red: 0.35, green: 0.45, blue: 0.60)
        static let difficultyHard = Color(red: 0.30, green: 0.35, blue: 0.50)
        
        // Puzzle Button
        static let puzzleButtonBackground = Color.white
        static let puzzleButtonBadge = Color(red: 0.93, green: 0.90, blue: 0.78)
        static let puzzleButtonBadgeText = Color(red: 0.38, green: 0.34, blue: 0.28)
        static let puzzleCompletedBorder = Color(red: 0.24, green: 0.65, blue: 0.33)
        static let puzzleCompletedIcon = Color(red: 0.24, green: 0.65, blue: 0.33)
        static let puzzleLockOverlay = Color.black.opacity(0.7)
        
        // Game View
        static let gamePaletteTitle = Color(red: 0.44, green: 0.3, blue: 0.23)
        static let gamePaletteSubtitle = Color(red: 0.62, green: 0.47, blue: 0.34)
        
        // Game Settings Button Gradient
        static let gameSettingsGradientStart = Color(red: 0.7, green: 0.5, blue: 0.9)
        static let gameSettingsGradientEnd = Color(red: 0.6, green: 0.4, blue: 0.8)
        
        // Game Action Button Gradients
        static let undoGradientStart = Color(red: 0.98, green: 0.89, blue: 0.75)
        static let undoGradientEnd = Color(red: 0.97, green: 0.78, blue: 0.58)
        static let eraseGradientStart = Color(red: 0.95, green: 0.85, blue: 0.95)
        static let eraseGradientEnd = Color(red: 0.88, green: 0.7, blue: 0.92)
        static let hintGradientStart = Color(red: 1.0, green: 0.93, blue: 0.76)
        static let hintGradientEnd = Color(red: 0.99, green: 0.82, blue: 0.64)
    }
    
    // MARK: - Layout
    
    enum Layout {
        // Content width
        static let maxContentWidth: CGFloat = 680
        
        // Spacing
        static let regularTopSpacing: CGFloat = 70
        static let regularButtonSpacing: CGFloat = 50
        static let compactButtonSpacing: CGFloat = 24
        static let questButtonSpacing: CGFloat = 24
        
        // Horizontal padding
        static let headerHorizontalPadding: CGFloat = 10
        static let regularHorizontalPadding: CGFloat = 80
        static let compactHorizontalPadding: CGFloat = 32
        
        // Footer
        static let footerVerticalPadding: CGFloat = 12
        static let footerHorizontalPadding: CGFloat = 40
        
        // Corner radii
        static let smallCornerRadius: CGFloat = 20
        static let largeCornerRadius: CGFloat = 30
        
        // Puzzle Selection
        static let puzzleCardCornerRadius: CGFloat = 24
        static let puzzleButtonCornerRadius: CGFloat = 20
        static let puzzleButtonHeight: CGFloat = 100
        static let puzzleSettingsCornerRadius: CGFloat = 16
        static let puzzleSettingsSheetHeightPad: CGFloat = 600
        static let puzzleSettingsSheetHeightPhone: CGFloat = 550
    }
}

// MARK: - Button Styles

struct PremiumButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: Theme.Layout.smallCornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [Theme.Colors.premiumGold, Theme.Colors.premiumGoldDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Layout.smallCornerRadius)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Theme.Colors.premiumBorderLight, Theme.Colors.premiumBorder],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: Theme.Colors.premiumGoldDark.opacity(0.4), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct QuestButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: Theme.Layout.largeCornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Theme.Colors.questButtonDark, Theme.Colors.questButtonLight],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Layout.largeCornerRadius, style: .continuous)
                            .strokeBorder(Theme.Colors.footerBackground, lineWidth: 3)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 6)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct OverlayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: Theme.Layout.smallCornerRadius)
                    .fill(Theme.Colors.overlayBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Layout.smallCornerRadius)
                            .strokeBorder(Theme.Colors.overlayBorder, lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

