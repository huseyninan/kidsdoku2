import SwiftUI
import RevenueCatUI

struct DifficultyTheme {
    let name: String
    let backgroundColor: Color
    let emoji: String
}

struct PuzzleSelectionView: View {
    let size: Int
    @Binding var path: [KidSudokuRoute]
    @ObservedObject private var completionManager = PuzzleCompletionManager.shared
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    @State private var showSettings = false
    @State private var showPaywall = false
    @AppStorage("showEasyDifficulty") private var showEasy = true
    @AppStorage("showNormalDifficulty") private var showNormal = true
    @AppStorage("showHardDifficulty") private var showHard = true
    @AppStorage("hideFinishedPuzzles") private var hideFinishedPuzzles = false
    
    private var themes: [PuzzleDifficulty: DifficultyTheme] {
        switch size {
        case 3:
            return [
                .easy: DifficultyTheme(name: "Wakey Wakey", backgroundColor: Color(red: 0.45, green: 0.55, blue: 0.45), emoji: "🌻"),
                .normal: DifficultyTheme(name: "Breakfast Time", backgroundColor: Color(red: 0.35, green: 0.45, blue: 0.60), emoji: "🌲"),
                .hard: DifficultyTheme(name: "Garden Path", backgroundColor: Color(red: 0.30, green: 0.35, blue: 0.50), emoji: "💎")
            ]
        case 4:
            return [
                .easy: DifficultyTheme(name: "Sunny Meadow", backgroundColor: Color(red: 0.45, green: 0.55, blue: 0.45), emoji: "🌻"),
                .normal: DifficultyTheme(name: "Twisty Trails", backgroundColor: Color(red: 0.35, green: 0.45, blue: 0.60), emoji: "🌲"),
                .hard: DifficultyTheme(name: "Mushroom Grove", backgroundColor: Color(red: 0.30, green: 0.35, blue: 0.50), emoji: "💎")
            ]
        case 6:
            return [
                .easy: DifficultyTheme(name: "Echo Cave", backgroundColor: Color(red: 0.45, green: 0.55, blue: 0.45), emoji: "🌻"),
                .normal: DifficultyTheme(name: "Snowy Slopes", backgroundColor: Color(red: 0.35, green: 0.45, blue: 0.60), emoji: "🌲"),
                .hard: DifficultyTheme(name: "Starry Summit", backgroundColor: Color(red: 0.30, green: 0.35, blue: 0.50), emoji: "💎")
            ]
        default:
            return [
                .easy: DifficultyTheme(name: "Sunny Meadow", backgroundColor: Color(red: 0.45, green: 0.55, blue: 0.45), emoji: "🌻"),
                .normal: DifficultyTheme(name: "Whispering Woods", backgroundColor: Color(red: 0.35, green: 0.45, blue: 0.60), emoji: "🌲"),
                .hard: DifficultyTheme(name: "Crystal Caves", backgroundColor: Color(red: 0.30, green: 0.35, blue: 0.50), emoji: "💎")
            ]
        }
    }
    
    private var puzzlesByDifficulty: [(PuzzleDifficulty, [PremadePuzzle])] {
        PuzzleDifficulty.allCases.compactMap { difficulty in
            // Check if this difficulty should be shown based on settings
            let shouldShow: Bool
            switch difficulty {
            case .easy: shouldShow = showEasy
            case .normal: shouldShow = showNormal
            case .hard: shouldShow = showHard
            }
            
            guard shouldShow else { return nil }
            
            var filteredPuzzles = PremadePuzzleStore.shared.puzzles(for: size, difficulty: difficulty)
            
            // Filter out completed puzzles if the setting is enabled
            if hideFinishedPuzzles {
                filteredPuzzles = filteredPuzzles.filter { !completionManager.isCompleted(puzzle: $0) }
            }
            
            return filteredPuzzles.isEmpty ? nil : (difficulty, filteredPuzzles)
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.85, green: 0.88, blue: 0.92)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                    
                    VStack(spacing: 12) {
                        ForEach(puzzlesByDifficulty, id: \.0) { difficulty, puzzles in
                            difficultyCard(difficulty: difficulty, puzzles: puzzles)
                        }
                        
                        randomAdventureButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .sheet(isPresented: $showSettings) {
            difficultySettingsView
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .onPurchaseCompleted { customerInfo in
                    print("Purchase completed: \(customerInfo)")
                    appEnvironment.refreshSubscriptionStatus()
                }
        }
    }
    
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("🦉")
                .font(.system(size: 44))
            
            Text("Choose Your Adventure")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.3, green: 0.3, blue: 0.35))
            
            Spacer()
            
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
    
    private func difficultyCard(difficulty: PuzzleDifficulty, puzzles: [PremadePuzzle]) -> some View {
        let theme = themes[difficulty] ?? DifficultyTheme(name: difficulty.rawValue, backgroundColor: .gray, emoji: "")
        
        return VStack(spacing: 16) {
            Text("\(difficulty.rawValue) - \(theme.name)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(0..<puzzles.count, id: \.self) { index in
                    if index < puzzles.count {
                        puzzleButton(puzzle: puzzles[index], index: index, theme: theme)
                    } else {
                        emptyPuzzleSlot(number: index + 1, theme: theme)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(theme.backgroundColor)
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
    }
    
    private func puzzleButton(puzzle: PremadePuzzle, index: Int, theme: DifficultyTheme) -> some View {
        let isLocked = index > 2 && !appEnvironment.isPremium
        
        return Button {
            if isLocked {
                showPaywall = true
            } else {
                path.append(.premadePuzzle(puzzle: puzzle))
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(isLocked ? 0.5 : 0.9))
                    .frame(height: 100)
                
                VStack(alignment: .leading, spacing: -26) {
                    HStack(alignment: .top) {
                        numberBadge(
                            number: puzzle.number,
                            backgroundColor: Color(red: 0.93, green: 0.90, blue: 0.78),
                            textColor: Color(red: 0.38, green: 0.34, blue: 0.28)
                        )
                        
                        Spacer()
                        
                        if isLocked {
                            lockBadge
                                .padding(.top, 4)
                        } else if completionManager.isCompleted(puzzle: puzzle) {
                            completionBadge
                                .padding(.top, 4)
                        }
                    }
                    .padding(.leading, -12)
                                        
                    Image(puzzle.displayEmoji)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .opacity(isLocked ? 0.3 : 1.0)
                }
                .padding(12)
                
                // Lock overlay
                if isLocked {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.7))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            if !isLocked, let rating = completionManager.rating(for: puzzle) {
                PuzzleRankBadge(rating: rating)
                    .padding(.bottom, 12)
            }
        }
    }
    
    private func emptyPuzzleSlot(number: Int, theme: DifficultyTheme) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.2))
                .frame(height: 100)
            
            VStack(alignment: .leading, spacing: 0) {
                numberBadge(
                    number: number,
                    backgroundColor: Color.white.opacity(0.22),
                    textColor: Color.white.opacity(0.65)
                )
                
                Spacer()
            }
            .padding(12)
        }
    }
    
    private func numberBadge(number: Int, backgroundColor: Color, textColor: Color) -> some View {
        ZStack(alignment: .topLeading) {
            UnevenRoundedRectangle(
                cornerRadii: .init(topLeading: 18, bottomLeading: 0, bottomTrailing: 142, topTrailing: 0),
                style: .continuous
            )
            .fill(backgroundColor)
            .frame(width: 46, height: 46)
            
            Text("\(number)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(textColor)
                .padding(.top, 8)
                .padding(.leading, 12)
        }
    }
    
    private var completionBadge: some View {
        ZStack {
            Circle()
                .fill(Color.white)
            
            Circle()
                .stroke(Color(red: 0.24, green: 0.65, blue: 0.33), lineWidth: 3)
            
            Image(systemName: "checkmark")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.24, green: 0.65, blue: 0.33))
        }
        .frame(width: 34, height: 34)
    }
    
    private var lockBadge: some View {
        ZStack {
            Circle()
                .fill(Color.white)
            
            Circle()
                .stroke(Color(red: 0.95, green: 0.77, blue: 0.06), lineWidth: 3)
            
            Image(systemName: "crown.fill")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.95, green: 0.77, blue: 0.06))
        }
        .frame(width: 34, height: 34)
    }
    
    private var randomAdventureButton: some View {
        Button {
            path.append(.game(size: size))
        } label: {
            HStack(spacing: 12) {
                Text("🍃")
                    .font(.system(size: 32))
                
                Text("Random\nAdventure")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(red: 0.65, green: 0.35, blue: 0.35))
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var difficultySettingsView: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.85, green: 0.88, blue: 0.92)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Choose which difficulty levels to show")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.45))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                    
                    VStack(spacing: 16) {
                        difficultyToggle(
                            title: "Easy",
                            emoji: "🌻",
                            isOn: $showEasy,
                            color: Color(red: 0.45, green: 0.55, blue: 0.45)
                        )
                        
                        difficultyToggle(
                            title: "Normal",
                            emoji: "🌲",
                            isOn: $showNormal,
                            color: Color(red: 0.35, green: 0.45, blue: 0.60)
                        )
                        
                        difficultyToggle(
                            title: "Hard",
                            emoji: "💎",
                            isOn: $showHard,
                            color: Color(red: 0.30, green: 0.35, blue: 0.50)
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 16) {
                        difficultyToggle(
                            title: "Hide Finished",
                            emoji: "✅",
                            isOn: $hideFinishedPuzzles,
                            color: Color(red: 0.24, green: 0.65, blue: 0.33)
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 16)
            }
            .navigationTitle("Difficulty Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showSettings = false
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func difficultyToggle(title: String, emoji: String, isOn: Binding<Bool>, color: Color) -> some View {
        HStack(spacing: 16) {
            Text(emoji)
                .font(.system(size: 36))
            
            Text(title)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(red: 0.3, green: 0.3, blue: 0.35))
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(color)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

private struct PuzzleRankBadge: View {
    let rating: Double
    
    var body: some View {
        HStack {
            MiniStarRatingView(rating: rating, size: 14)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
        .padding(.horizontal, 12)
        .background(
            UnevenRoundedRectangle(
                cornerRadii: .init(topLeading: 0, bottomLeading: 142, bottomTrailing: 142, topTrailing: 0),
                style: .continuous
            )
            .fill(rankTier.gradient)
            .overlay(
                UnevenRoundedRectangle(
                    cornerRadii: .init(topLeading: 0, bottomLeading: 142, bottomTrailing: 142, topTrailing: 0),
                    style: .continuous
                )
                .stroke(Color.white.opacity(0.45), lineWidth: 1)
            )
        )
        .shadow(color: rankTier.shadowColor, radius: 8, x: 0, y: 4)
    }
    
    private var rankTier: RankTier {
        switch rating {
        case 2.75...:
            return .legend
        case 2.25...:
            return .hero
        case 1.75...:
            return .pro
        case 1.25...:
            return .apprentice
        case 0.75...:
            return .explorer
        case 0.25...:
            return .dreamer
        default:
            return .rookie
        }
    }
    
    private enum RankTier {
        case legend, hero, pro, apprentice, explorer, dreamer, rookie
        
        var title: String {
            switch self {
            case .legend: return "Legend Rank"
            case .hero: return "Hero Rank"
            case .pro: return "Pro Rank"
            case .apprentice: return "Apprentice"
            case .explorer: return "Explorer"
            case .dreamer: return "Dreamer"
            case .rookie: return "Rookie"
            }
        }
        
        var gradient: LinearGradient {
            switch self {
            case .legend:
                return LinearGradient(
                    colors: [
                        Color.purple.opacity(0.75),
                        Color.blue.opacity(0.75)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .hero:
                return LinearGradient(
                    colors: [
                        Color.orange.opacity(0.75),
                        Color.pink.opacity(0.75)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .pro:
                return LinearGradient(
                    colors: [
                        Color.green.opacity(0.75),
                        Color.teal.opacity(0.75)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .apprentice:
                return LinearGradient(
                    colors: [
                        Color.mint.opacity(0.75),
                        Color.cyan.opacity(0.75)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .explorer:
                return LinearGradient(
                    colors: [
                        Color.blue.opacity(0.7),
                        Color.indigo.opacity(0.7)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .dreamer:
                return LinearGradient(
                    colors: [
                        Color.gray.opacity(0.55),
                        Color.blue.opacity(0.45)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .rookie:
                return LinearGradient(
                    colors: [
                        Color.gray.opacity(0.4),
                        Color.gray.opacity(0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        
        var shadowColor: Color {
            switch self {
            case .legend: return Color.purple.opacity(0.4)
            case .hero: return Color.orange.opacity(0.4)
            case .pro: return Color.green.opacity(0.4)
            case .apprentice: return Color.mint.opacity(0.4)
            case .explorer: return Color.blue.opacity(0.4)
            case .dreamer: return Color.blue.opacity(0.25)
            case .rookie: return Color.black.opacity(0.2)
            }
        }
    }
}

private struct MiniStarRatingView: View {
    let rating: Double
    let size: CGFloat
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { index in
                starView(for: index)
            }
        }
    }
    
    private func starView(for index: Int) -> some View {
        let starValue = rating - Double(index)
        let symbolName: String
        if starValue >= 1.0 {
            symbolName = "star.fill"
        } else if starValue >= 0.5 {
            symbolName = "star.leadinghalf.filled"
        } else {
            symbolName = "star"
        }
        
        let color: Color = starValue >= 0.5 ? .yellow : .white.opacity(0.45)
        
        return Image(systemName: symbolName)
            .font(.system(size: size))
            .foregroundColor(color)
    }
}

#Preview {
    NavigationStack {
        PuzzleSelectionView(size: 4, path: .constant([]))
            .environmentObject(AppEnvironment())
    }
}
