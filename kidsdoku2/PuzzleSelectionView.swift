import SwiftUI
import RevenueCatUI

struct DifficultyTheme {
    let name: String
    let backgroundColor: Color
    
    static func theme(for difficulty: PuzzleDifficulty) -> Color {
        switch difficulty {
        case .easy: return Theme.Colors.difficultyEasy
        case .normal: return Theme.Colors.difficultyNormal
        case .hard: return Theme.Colors.difficultyHard
        }
    }
}

/// Wrapper struct to cache puzzle completion status and rating
/// Avoids redundant lookups during filtering and rendering
struct PuzzleWithStatus: Identifiable {
    let puzzle: PremadePuzzle
    let isCompleted: Bool
    let rating: Double?
    
    var id: UUID { puzzle.id }
}

struct PuzzleSelectionView: View {
    let size: Int
    @Binding var path: [KidSudokuRoute]
    @ObservedObject private var completionManager = PuzzleCompletionManager.shared
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var showParentalGate = false
    @State private var cachedPuzzlesByDifficulty: [(PuzzleDifficulty, [PuzzleWithStatus])] = []
    @State private var isLoading = true
    @State private var isPad = UIDevice.current.userInterfaceIdiom == .pad
    @AppStorage("showEasyDifficulty") private var showEasy = true
    @AppStorage("showNormalDifficulty") private var showNormal = true
    @AppStorage("showHardDifficulty") private var showHard = true
    @AppStorage("hideFinishedPuzzles") private var hideFinishedPuzzles = false
    
    // Combined filter state to avoid race conditions from multiple onChange handlers
    private var filterState: FilterState {
        FilterState(showEasy: showEasy, showNormal: showNormal, showHard: showHard, hideFinished: hideFinishedPuzzles)
    }
    
    private struct FilterState: Equatable {
        let showEasy: Bool
        let showNormal: Bool
        let showHard: Bool
        let hideFinished: Bool
    }
    
    // Cached themes - localized once on initialization to avoid repeated allocations
    private static let allThemes: [Int: [PuzzleDifficulty: DifficultyTheme]] = {
        [
            3: [
                .easy: DifficultyTheme(name: String(localized: "Wakey Wakey"), backgroundColor: Theme.Colors.difficultyEasy),
                .normal: DifficultyTheme(name: String(localized: "Breakfast Time"), backgroundColor: Theme.Colors.difficultyNormal),
                .hard: DifficultyTheme(name: String(localized: "Garden Path"), backgroundColor: Theme.Colors.difficultyHard)
            ],
            4: [
                .easy: DifficultyTheme(name: String(localized: "Sunny Meadow"), backgroundColor: Theme.Colors.difficultyEasy),
                .normal: DifficultyTheme(name: String(localized: "Twisty Trails"), backgroundColor: Theme.Colors.difficultyNormal),
                .hard: DifficultyTheme(name: String(localized: "Mushroom Grove"), backgroundColor: Theme.Colors.difficultyHard)
            ],
            6: [
                .easy: DifficultyTheme(name: String(localized: "Echo Cave"), backgroundColor: Theme.Colors.difficultyEasy),
                .normal: DifficultyTheme(name: String(localized: "Snowy Slopes"), backgroundColor: Theme.Colors.difficultyNormal),
                .hard: DifficultyTheme(name: String(localized: "Starry Summit"), backgroundColor: Theme.Colors.difficultyHard)
            ]
        ]
    }()
    
    private static let defaultTheme: [PuzzleDifficulty: DifficultyTheme] = {
        [
            .easy: DifficultyTheme(name: String(localized: "Sunny Meadow"), backgroundColor: Theme.Colors.difficultyEasy),
            .normal: DifficultyTheme(name: String(localized: "Whispering Woods"), backgroundColor: Theme.Colors.difficultyNormal),
            .hard: DifficultyTheme(name: String(localized: "Crystal Caves"), backgroundColor: Theme.Colors.difficultyHard)
        ]
    }()
    
    // Cached themes for this specific size - computed once, not on every render
    private let themes: [PuzzleDifficulty: DifficultyTheme]
    
    init(size: Int, path: Binding<[KidSudokuRoute]>) {
        self.size = size
        self._path = path
        self.themes = Self.allThemes[size] ?? Self.defaultTheme
    }
    
    var body: some View {
        ZStack {
            Theme.Colors.puzzleSelectionBackground
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
                                .foregroundStyle(Theme.Colors.puzzleLoadingText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(cachedPuzzlesByDifficulty, id: \.0) { difficulty, puzzles in
                                difficultyCard(difficulty: difficulty, puzzles: puzzles)
                            }
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
        // Single onChange handler to avoid race conditions from multiple simultaneous filter updates
        .onChange(of: filterState) { _, _ in
            updateCachedPuzzles()
        }
        // Update cache when completion data changes for this board size only
        .onChange(of: completionManager.completedPuzzles) { oldValue, newValue in
            // Efficient check: only update if a puzzle for the current size was affected
            // Uses symmetricDifference to find changes without filtering entire sets
            let sizePrefix = "\(size)-"
            let changes = oldValue.symmetricDifference(newValue)
            let hasRelevantChange = changes.contains { $0.hasPrefix(sizePrefix) }
            
            if hasRelevantChange {
                updateCachedPuzzles()
            }
        }
        .sheet(isPresented: $showSettings) {
            difficultySettingsView
        }
        .fullScreenCover(isPresented: $showParentalGate) {
            ParentalGateView {
                showPaywall = true
            }
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
        let result = await computeFilteredPuzzles()
        cachedPuzzlesByDifficulty = result
        isLoading = false
    }
    
    /// Computes filtered puzzles on a background thread
    private func computeFilteredPuzzles() async -> [(PuzzleDifficulty, [PuzzleWithStatus])] {
        // Capture values for background processing
        let completedSet = completionManager.completedPuzzles
        let ratingsDict = completionManager.puzzleRatings
        let currentSize = size
        let currentShowEasy = showEasy
        let currentShowNormal = showNormal
        let currentShowHard = showHard
        let currentHideFinished = hideFinishedPuzzles
        
        return await Task.detached(priority: .userInitiated) {
            PuzzleDifficulty.allCases.compactMap { difficulty in
                // Check difficulty visibility first
                let shouldShow: Bool
                switch difficulty {
                case .easy: shouldShow = currentShowEasy
                case .normal: shouldShow = currentShowNormal
                case .hard: shouldShow = currentShowHard
                }
                guard shouldShow else { return nil }
                
                let puzzles = PremadePuzzleStore.shared.puzzles(for: currentSize, difficulty: difficulty)
                guard !puzzles.isEmpty else { return nil }
                
                var puzzlesWithStatus = puzzles.map { puzzle in
                    let key = "\(puzzle.size)-\(puzzle.difficulty.rawValue)-\(puzzle.number)"
                    return PuzzleWithStatus(
                        puzzle: puzzle,
                        isCompleted: completedSet.contains(key),
                        rating: ratingsDict[key]
                    )
                }
                
                if currentHideFinished {
                    puzzlesWithStatus = puzzlesWithStatus.filter { !$0.isCompleted }
                }
                
                return puzzlesWithStatus.isEmpty ? nil : (difficulty, puzzlesWithStatus)
            }
        }.value
    }
    
    /// Synchronous update for filter changes (runs on main thread for responsiveness)
    private func updateCachedPuzzles() {
        guard !isLoading else { return }
        // Capture completion data once to avoid repeated property access
        let completedSet = completionManager.completedPuzzles
        let ratingsDict = completionManager.puzzleRatings
        let currentSize = size
        
        cachedPuzzlesByDifficulty = PuzzleDifficulty.allCases.compactMap { difficulty in
            let shouldShow: Bool
            switch difficulty {
            case .easy: shouldShow = showEasy
            case .normal: shouldShow = showNormal
            case .hard: shouldShow = showHard
            }
            guard shouldShow else { return nil }
            
            let puzzles = PremadePuzzleStore.shared.puzzles(for: currentSize, difficulty: difficulty)
            guard !puzzles.isEmpty else { return nil }
            
            var puzzlesWithStatus = puzzles.map { puzzle in
                let key = "\(puzzle.size)-\(puzzle.difficulty.rawValue)-\(puzzle.number)"
                return PuzzleWithStatus(
                    puzzle: puzzle,
                    isCompleted: completedSet.contains(key),
                    rating: ratingsDict[key]
                )
            }
            
            if hideFinishedPuzzles {
                puzzlesWithStatus = puzzlesWithStatus.filter { !$0.isCompleted }
            }
            
            return puzzlesWithStatus.isEmpty ? nil : (difficulty, puzzlesWithStatus)
        }
    }
    
    private func handlePuzzleTap(_ puzzle: PremadePuzzle) {
        let isLocked = puzzle.number > 3 && !appEnvironment.isPremium
        if isLocked {
            showParentalGate = true
        } else {
            path.append(.premadePuzzle(puzzle: puzzle))
        }
    }
    
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("🦉")
                .font(.system(size: 44))
            
            Text("Choose Your Adventure")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Colors.puzzleHeaderText)
            
            Spacer()
            
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Theme.Colors.puzzleSettingsIcon)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
    
    private func difficultyCard(difficulty: PuzzleDifficulty, puzzles: [PuzzleWithStatus]) -> some View {
        let theme = themes[difficulty] ?? DifficultyTheme(name: difficulty.rawValue, backgroundColor: .gray)
        
        return VStack(spacing: 16) {
            Text("\(difficulty.rawValue) - \(theme.name)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
            
            // LazyVGrid with adaptive columns for responsive layout
            // Minimum 100pt ensures buttons remain usable on small screens
            // Adapts to 2-4 columns depending on device width
            let columns = [GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 16)]
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(puzzles) { puzzleWithStatus in
                    PuzzleButtonView(
                        puzzle: puzzleWithStatus.puzzle,
                        isPremium: appEnvironment.isPremium,
                        isCompleted: puzzleWithStatus.isCompleted,
                        rating: puzzleWithStatus.rating
                    )
                    .onTapGesture {
                        handlePuzzleTap(puzzleWithStatus.puzzle)
                    }
                }
            }
            .drawingGroup() // Optimize rendering by rasterizing the grid
            .padding(.horizontal, 12)
            .padding(.bottom, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: Theme.Layout.puzzleCardCornerRadius, style: .continuous)
                .fill(theme.backgroundColor)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    private var difficultySettingsView: some View {
        ZStack {
            Theme.Colors.puzzleSettingsBackground
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header with Done button
                HStack {
                    Spacer()
                    Button(String(localized: "Done")) {
                        showSettings = false
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.blue)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                Text("Choose which difficulty levels to show")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.Colors.puzzleSettingsText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                
                VStack(spacing: 16) {
                    difficultyToggle(
                        title: String(localized: "Easy"),
                        emoji: "🌻",
                        isOn: $showEasy,
                        color: Theme.Colors.difficultyEasy
                    )
                    
                    difficultyToggle(
                        title: String(localized: "Normal"),
                        emoji: "🌲",
                        isOn: $showNormal,
                        color: Theme.Colors.difficultyNormal
                    )
                    
                    difficultyToggle(
                        title: String(localized: "Hard"),
                        emoji: "💎",
                        isOn: $showHard,
                        color: Theme.Colors.difficultyHard
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
                        color: Theme.Colors.puzzleToggleHideFinished
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .presentationDetents([.height(isPad ? Theme.Layout.puzzleSettingsSheetHeightPad : Theme.Layout.puzzleSettingsSheetHeightPhone)])
        .presentationDragIndicator(.visible)
    }
    
    private func difficultyToggle(title: String, emoji: String, isOn: Binding<Bool>, color: Color) -> some View {
        HStack(spacing: 16) {
            Text(emoji)
                .font(.system(size: 36))
            
            Text(title)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.Colors.puzzleSettingsTitle)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(color)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: Theme.Layout.puzzleSettingsCornerRadius, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
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
        content
    }
    
    private var content: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: Theme.Layout.puzzleButtonCornerRadius, style: .continuous)
                .fill(Theme.Colors.puzzleButtonBackground.opacity(isLocked ? 0.5 : 0.9))
                .frame(height: Theme.Layout.puzzleButtonHeight)
            
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
            .fill(Theme.Colors.puzzleButtonBadge)
            .frame(width: 46, height: 46)
            
            Text("\(puzzle.number)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.Colors.puzzleButtonBadgeText)
                .padding(.top, 8)
                .padding(.leading, 12)
        }
    }
    
    @ViewBuilder
    private var statusBadge: some View {
        if isLocked {
            ZStack {
                Circle().fill(Color.white)
                Circle().stroke(Theme.Colors.premiumGold, lineWidth: 3)
                Image(systemName: "crown.fill")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Colors.premiumGold)
            }
            .frame(width: 34, height: 34)
            .padding(.top, 4)
        } else if isCompleted {
            ZStack {
                Circle().fill(Color.white)
                Circle().stroke(Theme.Colors.puzzleCompletedBorder, lineWidth: 3)
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.Colors.puzzleCompletedIcon)
            }
            .frame(width: 34, height: 34)
            .padding(.top, 4)
        }
    }
    
    private var lockOverlay: some View {
        ZStack {
            Circle()
                .fill(Theme.Colors.puzzleLockOverlay)
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
        .shadow(color: rankTier.shadowColor, radius: 4, x: 0, y: 2)
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
