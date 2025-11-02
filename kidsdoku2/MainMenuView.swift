import SwiftUI

struct MainMenuView: View {
    @Binding var path: [KidSudokuRoute]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemTeal), Color(.systemGreen)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Text("Sudoku for Kids")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Choose your puzzle size to begin")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                }

                VStack(spacing: 20) {
                    menuButton(title: "4x4", subtitle: "Perfect for beginners", color: .orange) {
                        path.append(.puzzleSelection(size: 4))
                    }

                    menuButton(title: "6x6", subtitle: "Ready for a challenge", color: .purple) {
                        path.append(.puzzleSelection(size: 6))
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                Text("Have fun solving with adorable icons!")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding()
        }
    }

    private func menuButton(title: String, subtitle: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                    Text(subtitle)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                }
                Spacer()
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 30, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 8)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainMenuView(path: .constant([]))
}

