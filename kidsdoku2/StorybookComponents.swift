import SwiftUI

struct StorybookBadge: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 15, weight: .heavy, design: .rounded))
            .foregroundStyle(Color(red: 0.33, green: 0.22, blue: 0.12))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.99, green: 0.94, blue: 0.82),
                                Color(red: 0.95, green: 0.87, blue: 0.74)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                Capsule()
                    .stroke(Color(red: 0.85, green: 0.67, blue: 0.46), lineWidth: 1)
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
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(text)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
        .foregroundStyle(Color(red: 0.62, green: 0.34, blue: 0.24))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule().fill(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.92, blue: 0.81),
                        Color(red: 0.98, green: 0.82, blue: 0.65)
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
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.6))
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.99, green: 0.78, blue: 0.33),
                                Color(red: 0.98, green: 0.6, blue: 0.37),
                                Color(red: 0.4, green: 0.7, blue: 0.35)
                            ],
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
    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.9),
                        Color(red: 0.99, green: 0.94, blue: 0.86)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color(red: 0.91, green: 0.83, blue: 0.7), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 6)
    }
}

struct StorybookPaletteMat: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.97, blue: 0.91),
                        Color(red: 0.96, green: 0.92, blue: 0.84)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color(red: 0.91, green: 0.82, blue: 0.69), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

struct StorybookBoardMat: View {
    let size: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.97, blue: 0.92),
                        Color.white
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
                                Color(red: 0.94, green: 0.83, blue: 0.67),
                                Color(red: 0.86, green: 0.68, blue: 0.5)
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
            .foregroundColor(isEnabled ? Color(red: 0.37, green: 0.28, blue: 0.18) : Color(.systemGray3))
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

