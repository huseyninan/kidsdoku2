import SwiftUI

struct StorybookBadge: View {
    let text: String
    @Environment(\.gameTheme) private var theme
    
    var body: some View {
        Text(text)
            .font(.system(size: 15, weight: .heavy, design: .rounded))
            .foregroundStyle(theme.badgeTextColor)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                theme.badgeGradientStart,
                                theme.badgeGradientEnd
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                Capsule()
                    .stroke(theme.badgeBorderColor, lineWidth: 1)
            )
    }
}

struct StorybookIconCircle: View {
    let systemName: String
    let gradient: [Color]
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 30, height: 30)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct StorybookInfoChip: View {
    let icon: String
    let text: String
    @Environment(\.gameTheme) private var theme
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(text)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
        .foregroundStyle(theme.infoChipTextColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule().fill(
                LinearGradient(
                    colors: [
                        theme.infoChipGradientStart,
                        theme.infoChipGradientEnd
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        )
    }
}

struct StorybookProgressBar: View {
    let progress: Double
    @Environment(\.gameTheme) private var theme
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.progressBarBackground)
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: theme.progressBarGradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(12, geo.size.width * progress))
            }
        }
    }
}

struct StorybookMiniBoardPreview: View {
    let symbols: [String]
    
    private var previewSymbols: [String] {
        guard !symbols.isEmpty else { return Array(repeating: "", count: 9) }
        return (0..<9).map { symbols[$0 % symbols.count] }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.85))
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 3)
            
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                .foregroundColor(Color(red: 0.94, green: 0.75, blue: 0.57))
            
            VStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { col in
                            let index = row * 3 + col
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(red: 0.98, green: 0.95, blue: 0.9))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color(red: 0.93, green: 0.85, blue: 0.74), lineWidth: 1)
                                    )
                                if index < previewSymbols.count, !previewSymbols[index].isEmpty {
                                    Image(previewSymbols[index])
                                        .resizable()
                                        .scaledToFit()
                                        .padding(4)
                                }
                            }
                        }
                    }
                }
            }
            .padding(8)
        }
        .frame(width: 104, height: 104)
    }
}

struct StorybookHeaderCard: View {
    @Environment(\.gameTheme) private var theme
    
    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        theme.headerCardGradientStart,
                        theme.headerCardGradientEnd
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(theme.headerCardBorderColor, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 6)
    }
}

struct StorybookPaletteMat: View {
    @Environment(\.gameTheme) private var theme
    
    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        theme.paletteMatGradientStart,
                        theme.paletteMatGradientEnd
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(theme.paletteMatBorderColor, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

struct StorybookBoardMat: View {
    let size: CGFloat
    @Environment(\.gameTheme) private var theme
    
    var body: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        theme.boardMatGradientStart,
                        theme.boardMatGradientEnd
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size + 30, height: size + 30)
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                theme.boardMatBorderGradientStart,
                                theme.boardMatBorderGradientEnd
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 3, dash: [10, 6])
                    )
            )
    }
}

struct StorybookActionButton: View {
    let title: String
    let icon: String
    let isEnabled: Bool
    let gradient: [Color]
    let action: () -> Void
    @Environment(\.gameTheme) private var theme
    
    private var resolvedGradient: [Color] {
        guard gradient.count >= 2 else {
            return [Color.white, Color.white.opacity(0.95)]
        }
        return gradient
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isEnabled ? theme.actionButtonTextColor : theme.actionButtonDisabledColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: resolvedGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 4)
            .opacity(isEnabled ? 1 : 0.6)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
