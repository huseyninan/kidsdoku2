import SwiftUI

/// Centralized device-specific sizing configuration
enum DeviceSizing {
    static let isIPad = UIDevice.current.userInterfaceIdiom == .pad
    
    // MARK: - Header
    
    static let headerSpacing: CGFloat = isIPad ? 15 : 10
    static let progressBarHeight: CGFloat = isIPad ? 12 : 8
    static let progressBarMaxWidth: CGFloat = isIPad ? 140 : 100
    static let headerVerticalPadding: CGFloat = isIPad ? 12 : 8
    static let headerHorizontalPadding: CGFloat = isIPad ? 18 : 12
    static let badgeScale: CGFloat = isIPad ? 1.2 : 1.0
    static let settingsButtonScale: CGFloat = isIPad ? 1.3 : 1.0
    
    // MARK: - Palette
    
    static let paletteButtonSize: CGFloat = isIPad ? 72 : 52
    
    // MARK: - Board Layout
    
    static let estimatedHeaderHeight: CGFloat = isIPad ? 70 : 60
    static let estimatedPaletteHeight: CGFloat = isIPad ? 120 : 100
    static let estimatedButtonsHeight: CGFloat = isIPad ? 60 : 50
    static let maxGridSize: CGFloat = isIPad ? 550 : .infinity
    static let boardInset: CGFloat = 35
    static let minimumBoardSize: CGFloat = 200
    
    // MARK: - Board Size Calculation
    
    static func computeBoardSize(
        availableWidth: CGFloat,
        availableHeight: CGFloat,
        bottomSafeArea: CGFloat
    ) -> CGFloat {
        let verticalPadding: CGFloat = 8 + max(bottomSafeArea, 12) + 24 // top + bottom + spacing
        
        let adjustedHeight = availableHeight - estimatedHeaderHeight - estimatedPaletteHeight - estimatedButtonsHeight - verticalPadding
        let adjustedWidth = availableWidth - 20 // horizontal padding
        
        let rawSide = min(adjustedWidth, adjustedHeight)
        let candidate = max(minimumBoardSize, rawSide - boardInset)
        
        return min(candidate, rawSide, maxGridSize)
    }
}

