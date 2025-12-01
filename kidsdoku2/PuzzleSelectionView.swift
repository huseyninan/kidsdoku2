import SwiftUI
import RevenueCatUI

struct DifficultyTheme {
    let name: String
    let backgroundColor: Color
}

struct PuzzleSelectionView: View {
    let size: Int
    @Binding var path: [KidSudokuRoute]
    @ObservedObject private var completionManager = PuzzleCompletionManager.shared
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var cachedPuzzlesByDifficulty: [(PuzzleDifficulty, [PremadePuzzle])] = []
    @State private var basePuzzlesByDifficulty: [PuzzleDifficulty: [PremadePuzzle]] = [:]
    @State private var isLoading = true
    @AppStorage("showEasyDifficulty") private var showEasy = true
    @AppStorage("showNormalDifficulty") private var showNormal = true
    @AppStorage("showHardDifficulty") private var showHard = true
    @AppStorage("hideFinishedPuzzles") private var hideFinishedPuzzles = false
    
    // Static themes dictionary - computed once per size, not on every render
    private static let allThemes: [Int: [PuzzleDifficulty: DifficultyTheme]] = [
        3: [
            .easy: DifficultyTheme(name: String(localized: "Wakey Wakey"), backgroundColor: Color(red: 0.45, green: 0.55, blue: 0.45)),
            .normal: DifficultyTheme(name: String(localized: "Breakfast Time"), backgroundColor: Color(red: 0.35, green: 0.45, blue: 0.60)),
            .hard: DifficultyTheme(name: String(localized: "Garden Path"), backgroundColor: Color(red: 0.30, green: 0.35, blue: 0.50))
        ],
        4: [
            .easy: DifficultyTheme(name: String(localized: "Sunny Meadow"), backgroundColor: Color(red: 0.45, green: 0.55, blue: 0.45)),
            .normal: DifficultyTheme(name: String(localized: "Twisty Trails"), backgroundColor: Color(red: 0.35, green: 0.45, blue: 0.60)),
            .hard: DifficultyTheme(name: String(localized: "Mushroom Grove"), backgroundColor: Color(red: 0.30, green: 0.35, blue: 0.50))
        ],
        6: [
            .easy: DifficultyTheme(name: String(localized: "Echo Cave"), backgroundColor: Color(red: 0.45, green: 0.55, blue: 0.45)),
            .normal: DifficultyTheme(name: String(localized: "Snowy Slopes"), backgroundColor: Color(red: 0.35, green: 0.45, blue: 0.60)),
            .hard: DifficultyTheme(name: String(localized: "Starry Summit"), backgroundColor: Color(red: 0.30, green: 0.35, blue: 0.50))
        ]
    ]
    
    private static let defaultTheme: [PuzzleDifficulty: DifficultyTheme] = [
        .easy: DifficultyTheme(name: String(localized: "Sunny Meadow"), backgroundColor: Color(red: 0.45, green: 0.55, blue: 0.45)),
        .normal: DifficultyTheme(name: String(localized: "Whispering Woods"), backgroundColor: Color(red: 0.35, green: 0.45, blue: 0.60)),
        .hard: DifficultyTheme(name: String(localized: "Crystal Caves"), backgroundColor: Color(red: 0.30, green: 0.35, blue: 0.50))
    ]
    
    private var themes: [PuzzleDifficulty: DifficultyTheme] {
        Self.allThemes[size] ?? Self.defaultTheme
    }
    

    
    var body: some View {
        ZStack {
            Color(red: 0.85, green: 0.88, blue: 0.92)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                    
                    if isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Loading puzzles...")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.45))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(cachedPuzzlesByDifficulty, id: \.0) { difficulty, puzzles in
                                difficultyCard(difficulty: difficulty, puzzles: puzzles)
                            }
                            
//                            randomAdventureButton
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .task {
            await loadPuzzlesAsync()
        }
        .onChange(of: showEasy) {
            updateCachedPuzzles()
        }
        .onChange(of: showNormal) {
            updateCachedPuzzles()
        }
        .onChange(of: showHard) {
            updateCachedPuzzles()
        }
        .onChange(of: hideFinishedPuzzles) {
            updateCachedPuzzles()
        }
        // Update cache when completion data changes (e.g., returning from a completed puzzle)
        .onChange(of: completionManager.completedPuzzles) {
            updateCachedPuzzles()
        }
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
    
    /// Loads puzzles asynchronously on a background thread to avoid main thread hitches
    private func loadPuzzlesAsync() async {
        let currentSize = size
        
        // Load base puzzles from store on background thread (one-time fetch)
        let baseResult = await Task.detached(priority: .userInitiated) {
            var base: [PuzzleDifficulty: [PremadePuzzle]] = [:]
            for difficulty in PuzzleDifficulty.allCases {
                base[difficulty] = PremadePuzzleStore.shared.puzzles(for: currentSize, difficulty: difficulty)
            }
            return base
        }.value
        
        // Cache the base puzzles
        basePuzzlesByDifficulty = baseResult
        
        // Apply current filters
        applyFilters()
        isLoading = false
    }
    
    /// Applies visibility and completion filters to the cached base puzzles
    private func applyFilters() {
        cachedPuzzlesByDifficulty = PuzzleDifficulty.allCases.compactMap { difficulty in
            // Check difficulty visibility
            let shouldShow: Bool
            switch difficulty {
            case .easy: shouldShow = showEasy
            case .normal: shouldShow = showNormal
            case .hard: shouldShow = showHard
            }
            guard shouldShow else { return nil }
            
            // Get from cache (already loaded)
            guard var puzzles = basePuzzlesByDifficulty[difficulty], !puzzles.isEmpty else {
                return nil
            }
            
            // Apply hide-finished filter
            if hideFinishedPuzzles {
                puzzles = puzzles.filter { !completionManager.isCompleted(puzzle: $0) }
            }
            
            return puzzles.isEmpty ? nil : (difficulty, puzzles)
        }
    }
    
    /// Synchronous update for filter changes - uses cached base puzzles
    private func updateCachedPuzzles() {
        // Skip if base cache not yet loaded
        guard !basePuzzlesByDifficulty.isEmpty else { return }
        applyFilters()
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
        let theme = themes[difficulty] ?? DifficultyTheme(name: difficulty.rawValue, backgroundColor: .gray)
        
        return VStack(spacing: 16) {
            Text("\(difficulty.rawValue) - \(theme.name)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
            
            // LazyVGrid for efficient rendering of puzzle grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(puzzles.enumerated()), id: \.element.id) { index, puzzle in
                    PuzzleButtonView(
                        puzzle: puzzle,
                        isPremium: appEnvironment.isPremium,
                        isCompleted: completionManager.isCompleted(puzzle: puzzle),
                        rating: completionManager.rating(for: puzzle),
                        onTap: {
                            path.append(.premadePuzzle(puzzle: puzzle))
                        },
                        onLockedTap: {
                            showPaywall = true
                        }
                    )
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
                    Spacer()
                        .frame(height: 10.0)
                    
                    Text("Choose which difficulty levels to show")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.45))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                    
                    VStack(spacing: 16) {
                        difficultyToggle(
                            title: String(localized: "Easy"),
                            emoji: "🌻",
                            isOn: $showEasy,
                            color: Color(red: 0.45, green: 0.55, blue: 0.45)
                        )
                        
                        difficultyToggle(
                            title: String(localized: "Normal"),
                            emoji: "🌲",
                            isOn: $showNormal,
                            color: Color(red: 0.35, green: 0.45, blue: 0.60)
                        )
                        
                        difficultyToggle(
                            title: String(localized: "Hard"),
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
                            title: String(localized: "Hide Finished"),
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "Done")) {
                        showSettings = false
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
            }
        }
        .presentationDetents([.height(UIDevice.current.userInterfaceIdiom == .pad ? 550 : 500)])
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

// MARK: - Isolated Puzzle Button View
/// Separate view struct to isolate isPremium dependency from parent view.
/// This prevents unnecessary re-renders of the entire grid when unrelated
/// AppEnvironment properties change.
private struct PuzzleButtonView: View, Equatable {
    let puzzle: PremadePuzzle
    let isPremium: Bool
    let isCompleted: Bool
    let rating: Double?
    let onTap: () -> Void
    let onLockedTap: () -> Void
    
    private var isLocked: Bool {
        puzzle.number > 3 && !isPremium
    }
    
    static func == (lhs: PuzzleButtonView, rhs: PuzzleButtonView) -> Bool {
        lhs.puzzle.id == rhs.puzzle.id &&
        lhs.isPremium == rhs.isPremium &&
        lhs.isCompleted == rhs.isCompleted &&
        lhs.rating == rhs.rating
    }
    
    var body: some View {
        Button {
            if isLocked {
                onLockedTap()
            } else {
                onTap()
            }
        } label: {
            content
        }
        .buttonStyle(.plain)
    }
    
    private var content: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(isLocked ? 0.5 : 0.9))
                .frame(height: 100)
            
            // Main content
            VStack(alignment: .leading, spacing: -26) {
                HStack(alignment: .top) {
                    numberBadge
                    Spacer()
                    statusBadge
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
                lockOverlay
            }
            
            // Rating badge
            if !isLocked, let rating = rating {
                VStack {
                    Spacer()
                    PuzzleRankBadge(rating: rating)
                        .padding(.bottom, 12)
                }
            }
        }
    }
    
    private var numberBadge: some View {
        ZStack(alignment: .topLeading) {
            UnevenRoundedRectangle(
                cornerRadii: .init(topLeading: 18, bottomLeading: 0, bottomTrailing: 142, topTrailing: 0),
                style: .continuous
            )
            .fill(Color(red: 0.93, green: 0.90, blue: 0.78))
            .frame(width: 46, height: 46)
            
            Text("\(puzzle.number)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.38, green: 0.34, blue: 0.28))
                .padding(.top, 8)
                .padding(.leading, 12)
        }
    }
    
    @ViewBuilder
    private var statusBadge: some View {
        if isLocked {
            ZStack {
                Circle().fill(Color.white)
                Circle().stroke(Color(red: 0.95, green: 0.77, blue: 0.06), lineWidth: 3)
                Image(systemName: "crown.fill")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.95, green: 0.77, blue: 0.06))
            }
            .frame(width: 34, height: 34)
            .padding(.top, 4)
        } else if isCompleted {
            ZStack {
                Circle().fill(Color.white)
                Circle().stroke(Color(red: 0.24, green: 0.65, blue: 0.33), lineWidth: 3)
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.24, green: 0.65, blue: 0.33))
            }
            .frame(width: 34, height: 34)
            .padding(.top, 4)
        }
    }
    
    private var lockOverlay: some View {
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
            case .legend: return String(localized: "Legend Rank")
            case .hero: return String(localized: "Hero Rank")
            case .pro: return String(localized: "Pro Rank")
            case .apprentice: return String(localized: "Apprentice")
            case .explorer: return String(localized: "Explorer")
            case .dreamer: return String(localized: "Dreamer")
            case .rookie: return String(localized: "Rookie")
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
