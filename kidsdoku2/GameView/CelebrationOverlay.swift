import SwiftUI

struct CelebrationOverlay: View {
    let rating: Double
    let mistakeCount: Int
    let hintCount: Int
    let onDismiss: () -> Void
    
    @State private var showCard = false
    @State private var animateBadge = false
    
    private var perfectGame: Bool {
        mistakeCount == 0 && hintCount == 0
    }
    
    private var subtitle: String {
        if perfectGame {
            return String(localized: "Flawless logic! Not a single hint or mistake.")
        } else if mistakeCount == 0 {
            return String(localized: "Brilliant thinking with just a nudge from hints.")
        } else if hintCount == 0 {
            return String(localized: "You stayed determined and solved it all by yourself!")
        } else {
            return String(localized: "Every puzzle teaches something new. Ready for the next one?")
        }
    }
    
    private var formattedRating: String {
        String(format: "%.1f", rating)
    }
    
    private var metrics: [(icon: String, title: String, value: String)] {
        [
            ("star.fill", String(localized: "Stars"), formattedRating),
            ("xmark.circle.fill", String(localized: "Mistakes"), mistakeCount == 0 ? String(localized: "None") : "\(mistakeCount)"),
            ("lightbulb.fill", String(localized: "Hints"), hintCount == 0 ? String(localized: "None") : "\(hintCount)")
        ]
    }
    
    var body: some View {
        ZStack {
            CelebrationBackdrop()
                .ignoresSafeArea()
                .transition(.opacity)
            
            VStack {
                Spacer()
                celebrationCard
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.05)) {
                showCard = true
            }
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                animateBadge = true
            }
        }
    }
    
    private var celebrationCard: some View {
        VStack(spacing: 24) {
            badge
            
            VStack(spacing: 6) {
                Text(perfectGame ? String(localized: "Storybook Hero!") : String(localized: "Puzzle Complete!"))
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.98, green: 0.74, blue: 0.3),
                                Color(red: 0.96, green: 0.38, blue: 0.57)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(subtitle)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.38, green: 0.28, blue: 0.2))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                StarRatingView(rating: rating)
                    .scaleEffect(1.1)
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.93, blue: 0.74),
                                Color(red: 1.0, green: 0.8, blue: 0.76)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 6)
                    .overlay(
                        Capsule()
                            .fill(Color.white.opacity(0.45))
                            .frame(width: 40, height: 2)
                            .offset(x: -40)
                    )
                    .opacity(0.5)
            }
            
            HStack(spacing: 12) {
                ForEach(metrics, id: \.title) { metric in
                    CelebrationMetric(icon: metric.icon, title: metric.title, value: metric.value)
                }
            }
            
            Button(action: onDismiss) {
                Text(String(localized: "Play Again"))
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.28, green: 0.67, blue: 0.96),
                                        Color(red: 0.49, green: 0.9, blue: 0.87)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.35), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 6)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.top, 4)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(Color.white.opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.89, blue: 0.63),
                            Color(red: 0.97, green: 0.69, blue: 0.81)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 5
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                .blur(radius: 1)
        )
        .shadow(color: Color.black.opacity(0.25), radius: 30, x: 0, y: 18)
        .scaleEffect(showCard ? 1 : 0.85)
        .opacity(showCard ? 1 : 0)
    }
    
    private var badge: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.85, blue: 0.46),
                            Color(red: 1.0, green: 0.63, blue: 0.46)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 110, height: 110)
                .shadow(color: Color.yellow.opacity(0.35), radius: 15, x: 0, y: 5)
            
            Image(systemName: perfectGame ? "crown.fill" : "sparkles")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.white.opacity(0.4), radius: 6, x: 0, y: 2)
        }
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.55), lineWidth: 4)
        )
        .scaleEffect(animateBadge ? 1.03 : 0.97)
    }
}

struct CelebrationMetric: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.98, green: 0.72, blue: 0.3),
                            Color(red: 0.92, green: 0.35, blue: 0.59)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(red: 0.49, green: 0.36, blue: 0.25))
            
            Text(value)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.18))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 4)
    }
}

struct CelebrationBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.26, blue: 0.16),
                    Color(red: 0.06, green: 0.38, blue: 0.22),
                    Color(red: 0.08, green: 0.5, blue: 0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            RadialGradient(
                colors: [
                    Color(red: 0.77, green: 0.93, blue: 0.62).opacity(0.6),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 420
            )
            .blendMode(.screen)
            
            CelebrationSparkles()
                .blur(radius: 0.5)
            
            Color.black.opacity(0.25)
        }
    }
}

struct CelebrationSparkles: View {
    private struct Sparkle: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let color: Color
        let delay: Double
    }
    
    @State private var glow = false
    
    private let sparkles: [Sparkle] = [
        Sparkle(x: 0.18, y: 0.22, size: 6, color: Color.cyan.opacity(0.8), delay: 0.0),
        Sparkle(x: 0.4, y: 0.15, size: 5, color: Color.white.opacity(0.9), delay: 0.2),
        Sparkle(x: 0.72, y: 0.18, size: 7, color: Color.pink.opacity(0.7), delay: 0.4),
        Sparkle(x: 0.9, y: 0.32, size: 5, color: Color.orange.opacity(0.8), delay: 0.6),
        Sparkle(x: 0.13, y: 0.55, size: 8, color: Color.blue.opacity(0.5), delay: 0.1),
        Sparkle(x: 0.32, y: 0.68, size: 5, color: Color.green.opacity(0.6), delay: 0.5),
        Sparkle(x: 0.58, y: 0.62, size: 8, color: Color.yellow.opacity(0.7), delay: 0.3),
        Sparkle(x: 0.84, y: 0.78, size: 6, color: Color.purple.opacity(0.7), delay: 0.7),
        Sparkle(x: 0.23, y: 0.86, size: 4, color: Color.white.opacity(0.6), delay: 0.9),
        Sparkle(x: 0.65, y: 0.88, size: 5, color: Color.cyan.opacity(0.8), delay: 0.2)
    ]
    
    var body: some View {
        GeometryReader { geo in
            ForEach(sparkles) { sparkle in
                Circle()
                    .fill(sparkle.color)
                    .frame(width: sparkle.size, height: sparkle.size)
                    .position(
                        x: sparkle.x * geo.size.width,
                        y: sparkle.y * geo.size.height
                    )
                    .scaleEffect(glow ? 1.4 : 0.7, anchor: .center)
                    .animation(
                        .easeInOut(duration: 1.8)
                            .repeatForever(autoreverses: true)
                            .delay(sparkle.delay),
                        value: glow
                    )
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            glow = true
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct StarRatingView: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                starView(for: index)
            }
        }
    }
    
    private func starView(for index: Int) -> some View {
        let starValue = rating - Double(index)
        
        return Group {
            if starValue >= 1.0 {
                // Full star
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            } else if starValue >= 0.5 {
                // Half star
                Image(systemName: "star.leadinghalf.filled")
                    .foregroundColor(.yellow)
            } else {
                // Empty star
                Image(systemName: "star")
                    .foregroundColor(.gray)
            }
        }
        .font(.system(size: 40))
    }
}

