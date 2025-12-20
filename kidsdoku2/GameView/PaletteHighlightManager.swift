import SwiftUI

/// Manages the palette highlight state and behavior
@Observable
class PaletteHighlightManager {
    private(set) var showHighlight: Bool = true
    
    func hideHighlight() {
        showHighlight = false
    }
    
    func resetHighlight() {
        showHighlight = true
    }
}

/// Component that handles palette highlight display and interaction
struct PaletteHighlightComponent: View {
    @Bindable var highlightManager: PaletteHighlightManager
    
    var body: some View {
        if highlightManager.showHighlight {
            PaletteHighlightTip()
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}
