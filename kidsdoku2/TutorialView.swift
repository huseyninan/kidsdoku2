import SwiftUI

struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background color
            Color(red: 0.95, green: 0.93, blue: 0.87)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("🎓")
                            .font(.system(size: 64))
                        
                        Text("How to Play")
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                        
                        Text("Sudoku is Fun!")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(red: 0.7, green: 0.35, blue: 0.3))
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    
                    // What is Sudoku section
                    tutorialCard(
                        emoji: "🎮",
                        title: "What is Sudoku?",
                        description: "Sudoku is a fun puzzle game where you fill empty boxes with emojis! In our 4×4 game, you use 4 different emojis.",
                        backgroundColor: Color(red: 0.45, green: 0.55, blue: 0.75)
                    )
                    
                    // The Goal section
                    tutorialCard(
                        emoji: "🎯",
                        title: "The Goal",
                        description: "Place each emoji exactly once in every row, column, and 2×2 box!",
                        backgroundColor: Color(red: 0.55, green: 0.65, blue: 0.45)
                    )
                    
                    // Rule 1: Rows
                    ruleCard(
                        number: 1,
                        emoji: "➡️",
                        title: "Each ROW (→)",
                        description: "must have all 4 different emojis",
                        exampleView: rowExampleView(),
                        backgroundColor: Color(red: 0.85, green: 0.55, blue: 0.45)
                    )
                    
                    // Rule 2: Columns
                    ruleCard(
                        number: 2,
                        emoji: "⬇️",
                        title: "Each COLUMN (↓)",
                        description: "must have all 4 different emojis",
                        exampleView: columnExampleView(),
                        backgroundColor: Color(red: 0.65, green: 0.45, blue: 0.75)
                    )
                    
                    // Rule 3: Boxes
                    ruleCard(
                        number: 3,
                        emoji: "⬜️",
                        title: "Each 2×2 BOX",
                        description: "must have all 4 different emojis",
                        exampleView: boxExampleView(),
                        backgroundColor: Color(red: 0.45, green: 0.65, blue: 0.65)
                    )
                    
                    // Ready to play button
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Text("🚀")
                                .font(.system(size: 32))
                            
                            Text("Ready to Play!")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.35, green: 0.22, blue: 0.12),
                                            Color(red: 0.45, green: 0.28, blue: 0.15)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                                        .strokeBorder(
                                            Color(red: 0.85, green: 0.75, blue: 0.6),
                                            lineWidth: 3
                                        )
                                )
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 6)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helper Views
    
    private func tutorialCard(emoji: String, title: String, description: String, backgroundColor: Color) -> some View {
        VStack(spacing: 16) {
            Text(emoji)
                .font(.system(size: 56))
            
            Text(title)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.95))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(backgroundColor)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
    }
    
    private func ruleCard(number: Int, emoji: String, title: String, description: String, exampleView: some View, backgroundColor: Color) -> some View {
        VStack(spacing: 20) {
            // Rule header
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.3))
                        .frame(width: 56, height: 56)
                    
                    Text("\(number)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(emoji)
                            .font(.system(size: 24))
                        Text(title)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    
                    Text(description)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.95))
                }
                
                Spacer()
            }
            
            // Example
            exampleView
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.white.opacity(0.25))
                )
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(backgroundColor)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Example Views
    
    private func rowExampleView() -> some View {
        VStack(spacing: 12) {
            Text("Example Row:")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            
            HStack(spacing: 8) {
                exampleCell(emoji: "🐶")
                exampleCell(emoji: "🐱")
                exampleCell(emoji: "🐸")
                exampleCell(emoji: "🦊")
            }
            
            Text("All 4 different! ✓")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        }
    }
    
    private func columnExampleView() -> some View {
        VStack(spacing: 12) {
            Text("Example Column:")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            
            VStack(spacing: 8) {
                exampleCell(emoji: "🐶")
                exampleCell(emoji: "🐱")
                exampleCell(emoji: "🐸")
                exampleCell(emoji: "🦊")
            }
            
            Text("All 4 different! ✓")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        }
    }
    
    private func boxExampleView() -> some View {
        VStack(spacing: 12) {
            Text("Example 2×2 Box:")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    exampleCell(emoji: "🐶")
                    exampleCell(emoji: "🐱")
                }
                HStack(spacing: 8) {
                    exampleCell(emoji: "🐸")
                    exampleCell(emoji: "🦊")
                }
            }
            
            Text("All 4 different! ✓")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        }
    }
    
    private func exampleCell(emoji: String) -> some View {
        Text(emoji)
            .font(.system(size: 36))
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 2)
            )
    }
}

#Preview {
    NavigationStack {
        TutorialView()
    }
}

