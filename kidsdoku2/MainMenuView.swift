import SwiftUI
import RevenueCatUI

struct MainMenuView: View {
    @Binding var path: [KidSudokuRoute]
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var isShowingTutorial = false
    @State private var isShowingSheet = false
    @State private var isShowingParentalGate = false

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
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top spacing for regular width devices
                if isRegularWidth {
                    Spacer()
                        .frame(height: Theme.Layout.regularTopSpacing)
                }
                
                headerSection
                    .frame(maxWidth: isRegularWidth ? Theme.Layout.maxContentWidth : .infinity)
                    .padding(.horizontal, Theme.Layout.headerHorizontalPadding)
                
                Spacer()
                    .frame(height: isRegularWidth ? Theme.Layout.regularButtonSpacing : Theme.Layout.compactButtonSpacing)

                questButtonsSection
                    .padding(.horizontal, isRegularWidth ? Theme.Layout.regularHorizontalPadding : Theme.Layout.compactHorizontalPadding)
                    .frame(maxWidth: isRegularWidth ? Theme.Layout.maxContentWidth : .infinity)

                Spacer()
                
                footerSection
                    .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .fullScreenCover(isPresented: $isShowingTutorial) {
            TutorialView()
        }
        .fullScreenCover(isPresented: $isShowingParentalGate) {
            ParentalGateView {
                isShowingSheet = true
            }
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
                    Text(String(localized: "How to Play"))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
            .buttonStyle(OverlayButtonStyle())
            
            Spacer()
            
            if !appEnvironment.isPremium {
                Button(action: {
                    isShowingParentalGate = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 16))
                        Text(String(localized: "Go Premium"))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                }
                .buttonStyle(PremiumButtonStyle())
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
            .accessibilityLabel(String(localized: "Settings"))
        }
    }

    @ViewBuilder
    private var questButtonsSection: some View {
        VStack(spacing: Theme.Layout.questButtonSpacing) {
            // Christmas Quest Button
            christmasQuestButton
            
            // Regular quest options - use the theme selected in Settings
            if !questOptions.isEmpty {
                ForEach(questOptions) { option in
                    questButton(
                        title: option.title,
                        subtitle: option.subtitle
                    ) {
                        // Use current theme from Settings (don't override)
                        // Christmas theme is only forced for Christmas Quest
                        let size = option.size
                        path.append(.puzzleSelection(size: size))
                    }
                }
            }
        }
    }
    
    private var christmasQuestButton: some View {
        Button(action: {
            path.append(.puzzleSelection(size: 4, themeOverride: .christmas))
        }) {
            ZStack {
                // Background image
                Image("chrismas_banner")
                    .resizable()
                    .scaledToFit()
                
                // Content overlay
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "Christmas Quest"))
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text(String(localized: "Holiday Magic"))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(red: 1.0, green: 0.9, blue: 0.75))
                    }
                    .padding(.bottom, 22)
                    .padding(.leading, 22)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .buttonStyle(ChristmasQuestButtonStyle())
    }
    
    private var footerSection: some View {
        Text(String(localized: "Let's Play!"))
            .font(.system(size: 30, weight: .heavy, design: .rounded))
            .foregroundStyle(Theme.Colors.footerText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Layout.footerVerticalPadding)
            .padding(.horizontal, Theme.Layout.footerHorizontalPadding)
            .background(
                Rectangle()
                    .fill(Theme.Colors.footerBackground)
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
                    .foregroundStyle(Theme.Colors.questSubtitle)
            }
        }
        .buttonStyle(QuestButtonStyle())
    }
}

#Preview {
    MainMenuView(path: .constant([]))
        .environmentObject(AppEnvironment())
}
