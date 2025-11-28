import SwiftUI
import RevenueCatUI

struct MainMenuView: View {
    @Binding var path: [KidSudokuRoute]
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var isShowingTutorial = false
    @State private var isShowingSheet = false

    var body: some View {
        ZStack {
            // Fox background image
            GeometryReader { geo in
                Image("fox_bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
            }
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                Color.clear
                    .frame(height: isRegularWidth ? 70 : 0)
                    .ignoresSafeArea(.all, edges: .top)
                
                headerSection
                    .frame(maxWidth: isRegularWidth ? 680 : .infinity)
                    .padding(.horizontal, 10.0)
                
                Color.clear
                    .frame(height: isRegularWidth ? 50 : 24)

                questButtonsSection
                    .padding(.horizontal, isRegularWidth ? 80 : 32)
                    .frame(maxWidth: isRegularWidth ? 680 : .infinity)

                Spacer()
                
                footerSection
                    .frame(maxWidth: .infinity)
            }
            .edgesIgnoringSafeArea(.bottom)
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
    
    private var headerSection: some View {
        HStack {
            Button(action: {
                isShowingTutorial = true
            }) {
                HStack(spacing: 4) {
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
            
            Button(action: {
                path.append(.settings)
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }

    @ViewBuilder
    private var questButtonsSection: some View {
        if questOptions.isEmpty {
            EmptyView()
        } else {
            VStack(spacing: 24) {
                ForEach(questOptions) { option in
                    questButton(
                        title: option.title,
                        subtitle: option.subtitle
                    ) {
                        path.append(.puzzleSelection(size: option.size))
                    }
                }
            }
        }
    }
    
    private var footerSection: some View {
        Text("Let's Play!")
            .font(.system(size: 30, weight: .heavy, design: .rounded))
            .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 40)
            .background(
                RoundedRectangle(cornerRadius: 0, style: .continuous)
                    .fill(Color(red: 0.85, green: 0.75, blue: 0.6))
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
            )
    }
    
    private var questOptions: [QuestOption] {
        var options: [QuestOption] = []
        
        if appEnvironment.show3x3Grid {
            options.append(
                QuestOption(
                    size: 3,
                    title: String(localized: "Start Journey: 3x3"),
                    subtitle: String(localized: "Tiny Tales")
                )
            )
        }
        
        if appEnvironment.show4x4Grid {
            options.append(
                QuestOption(
                    size: 4,
                    title: String(localized: "Start Journey: 4x4"),
                    subtitle: String(localized: "Fable Adventures")
                )
            )
        }
        
        if appEnvironment.show6x6Grid {
            options.append(
                QuestOption(
                    size: 6,
                    title: String(localized: "Start Journey: 6x6"),
                    subtitle: String(localized: "Kingdom Chronicles")
                )
            )
        }
        
        return options
    }
    
    private var regularWidthColumns: [GridItem] {
        let columnCount = questOptions.count > 1 ? 2 : 1
        return Array(repeating: GridItem(.flexible(), spacing: 24), count: columnCount)
    }
    
    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }
    
    private struct QuestOption: Identifiable {
        let size: Int
        let title: String
        let subtitle: String
        
        var id: Int { size }
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

