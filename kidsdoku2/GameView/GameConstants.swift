import Foundation
import SwiftUI

/// Constants for GameView layout, spacing, and animations
struct GameConstants {
    
    // MARK: - Layout & Spacing
    struct Layout {
        static let mainVStackSpacing: CGFloat = 8
        static let mainHorizontalPadding: CGFloat = 10
        static let mainTopPadding: CGFloat = 8
        static let mainBottomPaddingMin: CGFloat = 12
        
        static let paletteVerticalPadding: CGFloat = 8
        static let paletteHorizontalPadding: CGFloat = 10
        static let paletteButtonSpacing: CGFloat = 8
        
        static let actionButtonSpacing: CGFloat = 12
        static let messageBannerTopPadding: CGFloat = 8
        static let messageBannerHorizontalPadding: CGFloat = 16
    }
    
    // MARK: - Animations
    struct Animation {
        static let cellTapDuration: Double = 0.15
        static let actionButtonDuration: Double = 0.2
        static let paletteSpringResponse: Double = 0.35
        static let paletteSpringDamping: Double = 0.6
    }
    
    // MARK: - Typography
    struct Typography {
        static let paletteTitleSize: CGFloat = 16
        static let paletteSubtitleSize: CGFloat = 12
        static let highlightTipSize: CGFloat = 14
        static let highlightArrowSize: CGFloat = 24
        static let messageBannerTextSize: CGFloat = 16
    }
    
    // MARK: - Visual Effects
    struct Shadow {
        static let paletteButtonRadius: CGFloat = 4
        static let paletteButtonOffset = CGSize(width: 0, height: 3)
        static let paletteButtonOpacity: Double = 0.08
        
        static let highlightTipRadius: CGFloat = 8
        static let highlightTipOffset = CGSize(width: 0, height: 4)
        static let highlightTipOpacity: Double = 0.5
        
        static let highlightArrowRadius: CGFloat = 4
        static let highlightArrowOffset = CGSize(width: 0, height: 2)
        
        static let messageBannerRadius: CGFloat = 14
        static let messageBannerMainRadius: CGFloat = 14
        static let messageBannerMainOffset = CGSize(width: 0, height: 8)
        static let messageBannerSecondaryRadius: CGFloat = 4
        static let messageBannerSecondaryOffset = CGSize(width: 0, height: 1)
        static let messageBannerOpacity: Double = 0.15
    }
    
    // MARK: - Dimensions
    struct Dimensions {
        static let runningFoxHeight: CGFloat = 200
        static let messageBannerIconSize: CGFloat = 36
        static let messageBannerCornerRadius: CGFloat = 24
        static let messageBannerStrokeWidth: CGFloat = 1.2
        static let messageBannerSymbolCornerRadius: CGFloat = 14
        static let messageBannerSymbolPadding: CGFloat = 5
    }
    
    // MARK: - Scale Effects
    struct Scale {
        static let paletteButtonSelected: CGFloat = 1.08
        static let paletteButtonNormal: CGFloat = 1.0
    }
    
    // MARK: - Z-Index
    struct ZIndex {
        static let messageBanner: Double = 100
    }
    
    // MARK: - Positioning
    struct Position {
        static let highlightTipOffset: CGFloat = -80
        static let minSpacerLength: CGFloat = 0
    }
    
    // MARK: - Padding Values
    struct Padding {
        static let highlightTipHorizontal: CGFloat = 12
        static let highlightTipVertical: CGFloat = 6
        static let messageBannerHorizontal: CGFloat = 18
        static let messageBannerVertical: CGFloat = 12
        static let paletteItemSpacing: CGFloat = 4
    }
    
    // MARK: - Opacity Values
    struct Opacity {
        static let messageBannerAccent: Double = 0.7
        static let messageBannerBorder: Double = 0.9
        static let messageBannerBorderAccent: Double = 0.8
        static let messageBannerIconShadow: Double = 0.3
        static let messageBannerMainShadow: Double = 0.35
        static let blueHighlight: Double = 0.5
    }
}
