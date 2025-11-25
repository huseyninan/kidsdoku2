import SwiftUI
import RevenueCatUI

struct MainMenuView: View {
    @Binding var path: [KidSudokuRoute]
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var isShowingTutorial = false
    @State private var isShowingSheet = false

    var body: some View {
        ZStack {
            // Fox background image
            Image("fox_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Push content below safe area
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 40)
                    .ignoresSafeArea(.all, edges: .top)
                
                // Header buttons
                HStack {
                    // Tutorial button in top left
                    Button(action: {
                        isShowingTutorial = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 24))
                            Text("How to Play")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    if !appEnvironment.isPremium {
                        Button(action: {
                            isShowingSheet.toggle()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 16))
                                Text("Go Premium")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.95, green: 0.77, blue: 0.06),
                                                Color(red: 0.85, green: 0.55, blue: 0.0)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .strokeBorder(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 1.0, green: 0.95, blue: 0.7),
                                                        Color(red: 0.95, green: 0.85, blue: 0.5)
                                                    ],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                    .shadow(color: Color(red: 0.85, green: 0.55, blue: 0.0).opacity(0.4), radius: 8, x: 0, y: 4)
                            )
                        }
                        .padding(.trailing, 8)
                    }
                    
                    // Settings button in top right
                    Button(action: {
                        path.append(.settings)
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.top, 10)
                
                Spacer()
                    .frame(height: 50)

                // Quest Buttons
                VStack(spacing: 24) {
                    if appEnvironment.show3x3Grid {
                        questButton(
                            title: String(localized: "Start Journey: 3x3"),
                            subtitle: String(localized: "Tiny Tales")
                        ) {
                            path.append(.puzzleSelection(size: 3))
                        }
                    }

                    if appEnvironment.show4x4Grid {
                        questButton(
                            title: String(localized: "Start Journey: 4x4"),
                            subtitle: String(localized: "Fable Adventures")
                        ) {
                            path.append(.puzzleSelection(size: 4))
                        }
                    }

                    if appEnvironment.show6x6Grid {
                        questButton(
                            title: String(localized: "Start Journey: 6x6"),
                            subtitle: String(localized: "Kingdom Chronicles")
                        ) {
                            path.append(.puzzleSelection(size: 6))
                        }
                    }
                }
                .padding(.horizontal, 32)

                Spacer()

                // Quest Log Title Card
                Text("Let's Play!")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 0, style: .continuous)
                            .fill(                                Color(red: 0.85, green: 0.75, blue: 0.6))
                            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                    )
            }
        }
        .fullScreenCover(isPresented: $isShowingTutorial) {
            TutorialView()
        }
        .sheet(isPresented: $isShowingSheet) {
            PaywallView()
                .onPurchaseCompleted { customerInfo in
                    appEnvironment.refreshSubscriptionStatus()
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
        .environmentObject(AppEnvironment())
}

