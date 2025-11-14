import SwiftUI

struct MainMenuView: View {
    @Binding var path: [KidSudokuRoute]

    var body: some View {
        ZStack {
            // Fox background image
            Image("fox_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Tutorial and Settings buttons in top bar
                HStack {
                    // Tutorial button on the left
                    Button(action: {
                        path.append(.tutorial)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 24))
                            Text("How to Play")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.25))
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 16)
                    
                    Spacer()
                    
                    // Settings button on the right
                    Button(action: {
                        // Settings action
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                
                Spacer()
                    .frame(height: 60)
                
                // Quest Log Title Card
                VStack(spacing: 8) {
                    Text("Quest Log")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                    
                    Text("Welcome! Choose your")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.7, green: 0.35, blue: 0.3))
                    
                    Text("adventure!")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.7, green: 0.35, blue: 0.3))
                }
                .padding(.vertical, 32)
                .padding(.horizontal, 40)
                .background(
                    RoundedRectangle(cornerRadius: 35, style: .continuous)
                        .fill(Color(red: 0.95, green: 0.93, blue: 0.87))
                        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                )
                .padding(.horizontal, 24)
                
                Spacer()
                    .frame(height: 50)

                // Quest Buttons
                VStack(spacing: 24) {
                    questButton(
                        title: "Path Unlocked: 4x4",
                        subtitle: "Easy Journey"
                    ) {
                        path.append(.puzzleSelection(size: 4))
                    }

                    questButton(
                        title: "Path Unlocked: 6x6",
                        subtitle: "Brave Expedition"
                    ) {
                        path.append(.puzzleSelection(size: 6))
                    }
                }
                .padding(.horizontal, 32)

                Spacer()
            }
        }
    }

    private func questButton(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.75))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
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
    }
}

#Preview {
    MainMenuView(path: .constant([]))
}

