import SwiftUI

struct SymbolTokenView: View {
    enum DisplayContext {
        case grid
        case palette
        
        var cornerRadiusScale: CGFloat {
            switch self {
            case .grid:
                return 0.28
            case .palette:
                return 0.35
            }
        }
        
        var contentPaddingScale: CGFloat {
            switch self {
            case .grid:
                return 0.01
            case .palette:
                return 0.01
            }
        }
    }
    
    let symbolIndex: Int
    let symbolName: String
    let showNumbers: Bool
    let size: CGFloat
    let context: DisplayContext
    var isSelected: Bool = false
    
    @State private var glowPhase: CGFloat = 0
    
    private var glowAnimation: Animation {
        .easeInOut(duration: 1.6).repeatForever(autoreverses: true)
    }
    
    private var numberText: String {
        "\(symbolIndex)"
    }
    
    private var selectionBorderColor: Color {
        isSelected ? SymbolColorPalette.badgeColor(for: symbolIndex) : Color.white.opacity(0.25)
    }
    
    var body: some View {
        let gradient = SymbolColorPalette.gradient(for: symbolIndex)
        let cornerRadius = size * context.cornerRadiusScale
        let padding = size * context.contentPaddingScale
        let highlightStrength = max(0, min(1, isSelected ? glowPhase : 0))
        let hasHighlight = highlightStrength > 0
        
        return ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // Wash overlay - always shown but varies with highlight
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.white.opacity(0.45 * (1 - highlightStrength)))
                )
                .overlay {
                    // Selection overlays - only rendered when highlighted
                    if hasHighlight {
                        selectionOverlays(cornerRadius: cornerRadius, gradient: gradient, highlightStrength: highlightStrength)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            selectionBorderColor.opacity(0.5 + 0.4 * highlightStrength),
                            lineWidth: size * (0.04 + 0.05 * highlightStrength)
                        )
                        .shadow(
                            color: selectionBorderColor.opacity(0.2 + 0.35 * highlightStrength),
                            radius: size * (0.03 + 0.08 * highlightStrength),
                            x: 0,
                            y: size * 0.04
                        )
                )
                .shadow(color: Color.black.opacity(0.12), radius: size * 0.12, x: 0, y: size * 0.08)
            
            Group {
                if showNumbers || symbolName.isEmpty {
                    Text(numberText)
                        .font(.system(size: size * 0.55, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                } else {
                    Image(symbolName)
                        .resizable()
                        .scaledToFit()
                        .padding(padding)
                        .shadow(color: Color.black.opacity(0.18), radius: size * 0.08, x: 0, y: size * 0.04)
                }
            }
            .frame(width: size * 0.88, height: size * 0.88)
        }
        .frame(width: size, height: size)
        .overlay(alignment: .bottomTrailing) {
            if !showNumbers {
                numberBadge
                    .offset(x: -size * 0.01, y: -size * 0.01)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Symbol \(numberText)"))
        .onAppear {
            updateGlowAnimation(isSelected)
        }
        .onChange(of: isSelected) { _, newValue in
            updateGlowAnimation(newValue)
        }
    }
    
    @ViewBuilder
    private func selectionOverlays(cornerRadius: CGFloat, gradient: [Color], highlightStrength: CGFloat) -> some View {
        // Vivid overlay - adds color intensity when selected
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: gradient.map { $0.opacity(0.2 * highlightStrength) },
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        
        // Pulse overlay - glowing effect when selected
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.35 + 0.25 * highlightStrength),
                        selectionBorderColor.opacity(0.2 + 0.35 * highlightStrength)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blendMode(.plusLighter)
            .opacity(0.5 + 0.3 * highlightStrength)
            .scaleEffect(1 + 0.05 * highlightStrength)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var numberBadge: some View {
        Text(numberText)
            .font(.system(size: size * 0.2, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, size * 0.08)
            .padding(.vertical, size * 0.02)
            .background(
                Capsule()
                    .fill(SymbolColorPalette.badgeColor(for: symbolIndex))
            )
            .shadow(color: Color.black.opacity(0.28), radius: size * 0.1, x: 0, y: 1)
    }
    
    private func updateGlowAnimation(_ active: Bool) {
        if active {
            glowPhase = 0
            DispatchQueue.main.async {
                withAnimation(glowAnimation) {
                    glowPhase = 1
                }
            }
        } else {
            withAnimation(.easeOut(duration: 0.25)) {
                glowPhase = 0
            }
        }
    }
}

enum SymbolColorPalette {
    private static let gradients: [[Color]] = [
        [Color(red: 1.0, green: 0.74, blue: 0.47), Color(red: 0.98, green: 0.51, blue: 0.27)],
        [Color(red: 0.38, green: 0.8, blue: 0.81), Color(red: 0.12, green: 0.6, blue: 0.73)],
        [Color(red: 0.76, green: 0.62, blue: 0.98), Color(red: 0.53, green: 0.4, blue: 0.89)],
        [Color(red: 0.57, green: 0.86, blue: 0.58), Color(red: 0.27, green: 0.64, blue: 0.39)],
        [Color(red: 1.0, green: 0.74, blue: 0.47), Color(red: 0.98, green: 0.51, blue: 0.27)],
        [Color(red: 0.37, green: 0.66, blue: 0.98), Color(red: 0.18, green: 0.43, blue: 0.88)],
        [Color(red: 1.0, green: 0.6, blue: 0.77), Color(red: 0.91, green: 0.33, blue: 0.58)],
        [Color(red: 0.99, green: 0.86, blue: 0.47), Color(red: 0.99, green: 0.69, blue: 0.3)],
        [Color(red: 0.37, green: 0.66, blue: 0.98), Color(red: 0.18, green: 0.43, blue: 0.88)],
        [Color(red: 0.96, green: 0.8, blue: 0.45), Color(red: 0.85, green: 0.53, blue: 0.25)],
        [Color(red: 0.52, green: 0.84, blue: 0.94), Color(red: 0.29, green: 0.63, blue: 0.86)],
        [Color(red: 0.99, green: 0.7, blue: 0.54), Color(red: 0.97, green: 0.48, blue: 0.43)]
    ]
    
    static func gradient(for index: Int) -> [Color] {
        let safeIndex = index % gradients.count
        return gradients[safeIndex]
    }
    
    static func badgeColor(for index: Int) -> Color {
        gradient(for: index).last ?? .orange
    }
}

