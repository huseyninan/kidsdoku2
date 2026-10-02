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
    
    var id: String { puzzle.id }
}

// MARK: - Section Types for grouping puzzles

/// Represents a section for displaying puzzles - either by difficulty or grid size
enum PuzzleSectionType: Hashable {
    case difficulty(PuzzleDifficulty)
    case gridSize(Int)
    
    var displayName: String {
        switch self {
        case .difficulty(let difficulty):
            return difficulty.rawValue
        case .gridSize(let size):
            return "\(size)×\(size)"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .difficulty(let difficulty):
            switch difficulty {
            case .easy: return 0
            case .normal: return 1
            case .hard: return 2
            }
        case .gridSize(let size):
            return size
        }
    }
}

struct PuzzleSelectionView: View {
    let size: Int
    @Binding var path: [KidSudokuRoute]
    @ObservedObject private var completionManager = PuzzleCompletionManager.shared
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var showParentalGate = false
    @State private var cachedPuzzleSections: [(PuzzleSectionType, [PuzzleWithStatus])] = []
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
    
    // Cached names for grid size sections (Christmas theme)
    private static let gridSizeNames: [Int: String] = {
        [
            3: String(localized: "Starter Gifts"),
            4: String(localized: "Santa's Workshop"),
            6: String(localized: "North Pole Challenge")
        ]
    }()
    
    // Cached themes for this specific size - computed once, not on every render
    private let themes: [PuzzleDifficulty: DifficultyTheme]
    
    // Current game theme for color access
    private var gameTheme: GameTheme {
        appEnvironment.currentTheme
    }
    
    /// Whether to group puzzles by grid size (Christmas) or difficulty (Storybook)
    private var groupBySize: Bool {
        gameTheme.groupPuzzlesBySize
    }
    
    init(size: Int, path: Binding<[KidSudokuRoute]>) {
        self.size = size
        self._path = path
        self.themes = Self.allThemes[size] ?? Self.defaultTheme
    }
    
    var body: some View {
        ZStack {
            gameTheme.puzzleSelectionBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                    
                    if isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(gameTheme.puzzleLoadingText)
                            Text("Loading puzzles...")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(gameTheme.puzzleLoadingText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(cachedPuzzleSections, id: \.0) { sectionType, puzzles in
                                sectionCard(sectionType: sectionType, puzzles: puzzles)
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
        // Update cache when solve status changes
        .onChange(of: PuzzleCompletionManager.shared.getSolvedPuzzleIds()) { oldValue, newValue in
            // For size-based grouping, check all sizes; for difficulty-based, check current size only
            let hasRelevantChange: Bool
            if groupBySize {
                // Check if any puzzle completion changed
                hasRelevantChange = oldValue != newValue
            } else {
                // IDs look like "theme-size-difficulty-number"
                let sizePattern = "-\(size)-"
                let changes = oldValue.symmetricDifference(newValue)
                hasRelevantChange = changes.contains { $0.contains(sizePattern) }
            }
            
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
        cachedPuzzleSections = result
        isLoading = false
    }
    
    /// Computes filtered puzzles on a background thread
    private func computeFilteredPuzzles() async -> [(PuzzleSectionType, [PuzzleWithStatus])] {
        let input = currentSectionInput()
        return await Task.detached(priority: .userInitiated) {
            Self.buildSections(input)
        }.value
    }
    
    /// Synchronous update for filter changes (runs on main thread for responsiveness)
    private func updateCachedPuzzles() {
        guard !isLoading else { return }
        cachedPuzzleSections = Self.buildSections(currentSectionInput())
    }
    
    /// Snapshot of everything section building needs, so it can run off the main thread
    /// without touching shared state.
    private struct SectionInput {
        let completedSet: Set<String>
        let ratings: [String: Double]
        let size: Int
        let showEasy: Bool
        let showNormal: Bool
        let showHard: Bool
        let hideFinished: Bool
        let themeType: GameThemeType
        let groupBySize: Bool
    }
    
    private func currentSectionInput() -> SectionInput {
        SectionInput(
            completedSet: completionManager.completedPuzzles,
            ratings: completionManager.puzzleRatings,
            size: size,
            showEasy: showEasy,
            showNormal: showNormal,
            showHard: showHard,
            hideFinished: hideFinishedPuzzles,
            themeType: appEnvironment.currentThemeType,
            groupBySize: gameTheme.groupPuzzlesBySize
        )
    }
    
    private static func buildSections(_ input: SectionInput) -> [(PuzzleSectionType, [PuzzleWithStatus])] {
        func withStatus(_ puzzles: [PremadePuzzle]) -> [PuzzleWithStatus] {
            let all = puzzles.map { puzzle in
                PuzzleWithStatus(
                    puzzle: puzzle,
                    isCompleted: input.completedSet.contains(puzzle.id),
                    rating: input.ratings[puzzle.id]
                )
            }
            return input.hideFinished ? all.filter { !$0.isCompleted } : all
        }
        
        if input.groupBySize {
            // Christmas/Spring themes: Group by grid size (3x3, 4x4, 6x6)
            return [3, 4, 6].compactMap { gridSize in
                let puzzles = withStatus(PremadePuzzleStore.shared.puzzles(for: gridSize, themeType: input.themeType))
                return puzzles.isEmpty ? nil : (PuzzleSectionType.gridSize(gridSize), puzzles)
            }
        } else {
            // Storybook theme: Group by difficulty (Easy, Normal, Hard)
            return PuzzleDifficulty.allCases.compactMap { difficulty in
                let shouldShow: Bool
                switch difficulty {
                case .easy: shouldShow = input.showEasy
                case .normal: shouldShow = input.showNormal
                case .hard: shouldShow = input.showHard
                }
                guard shouldShow else { return nil }
                
                let puzzles = withStatus(PremadePuzzleStore.shared.puzzles(for: input.size, difficulty: difficulty, themeType: input.themeType))
                return puzzles.isEmpty ? nil : (PuzzleSectionType.difficulty(difficulty), puzzles)
            }
        }
    }
    
    private func handlePuzzleTap(_ puzzle: PremadePuzzle) {
        let isLocked = puzzle.number > gameTheme.freePuzzlesPerSection && !appEnvironment.isPremium
        if isLocked {
            showParentalGate = true
        } else {
            path.append(.premadePuzzle(puzzle: puzzle))
        }
    }
    
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(gameTheme.puzzleHeaderEmoji)
                .font(.system(size: 44))
            
            Text("Choose Your Adventure")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(gameTheme.puzzleHeaderText)
            
            Spacer()
            
            if !groupBySize {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(gameTheme.puzzleSettingsIcon)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
    
    private func sectionCard(sectionType: PuzzleSectionType, puzzles: [PuzzleWithStatus]) -> some View {
        let sectionColor = sectionColor(for: sectionType)
        let sectionTitle = sectionTitle(for: sectionType)
        let buttonColors = PuzzleButtonColors(theme: gameTheme)
        
        return VStack(spacing: 16) {
            Text(sectionTitle)
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
                        rating: puzzleWithStatus.rating,
                        colors: buttonColors,
                        freePuzzlesPerSection: gameTheme.freePuzzlesPerSection
                    )
                    .onTapGesture {
                        handlePuzzleTap(puzzleWithStatus.puzzle)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: Theme.Layout.puzzleCardCornerRadius, style: .continuous)
                .fill(sectionColor)
                .shadow(color: gameTheme.puzzleCardShadow, radius: 4, x: 0, y: 2)
        )
    }
    
    /// Returns the title for a section
    private func sectionTitle(for sectionType: PuzzleSectionType) -> String {
        switch sectionType {
        case .difficulty(let difficulty):
            let theme = themes[difficulty] ?? DifficultyTheme(name: difficulty.rawValue, backgroundColor: .gray)
            return "\(difficulty.rawValue) - \(theme.name)"
        case .gridSize(let gridSize):
            let sizeName = Self.gridSizeNames[gridSize] ?? "\(gridSize)×\(gridSize)"
            return "\(gridSize)×\(gridSize) - \(sizeName)"
        }
    }
    
    /// Returns theme-aware section color
    private func sectionColor(for sectionType: PuzzleSectionType) -> Color {
        switch sectionType {
        case .difficulty(let difficulty):
            switch difficulty {
            case .easy: return gameTheme.difficultyEasy
            case .normal: return gameTheme.difficultyNormal
            case .hard: return gameTheme.difficultyHard
            }
        case .gridSize(let gridSize):
            switch gridSize {
            case 3: return gameTheme.gridSize3x3Color
            case 4: return gameTheme.gridSize4x4Color
            case 6: return gameTheme.gridSize6x6Color
            default: return gameTheme.difficultyNormal
            }
        }
    }
    
    private var difficultySettingsView: some View {
        ZStack {
            gameTheme.puzzleSettingsBackground
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header with Done button
                HStack {
                    Spacer()
                    Button(String(localized: "Done")) {
                        showSettings = false
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(gameTheme.puzzleSettingsDoneButton)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                Text("Choose which difficulty levels to show")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(gameTheme.puzzleSettingsText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                
                VStack(spacing: 16) {
                    difficultyToggle(
                        title: String(localized: "Easy"),
                        emoji: "🌻",
                        isOn: $showEasy,
                        color: gameTheme.difficultyEasy
                    )
                    
                    difficultyToggle(
                        title: String(localized: "Normal"),
                        emoji: "🌲",
                        isOn: $showNormal,
                        color: gameTheme.difficultyNormal
                    )
                    
                    difficultyToggle(
                        title: String(localized: "Hard"),
                        emoji: "💎",
                        isOn: $showHard,
                        color: gameTheme.difficultyHard
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
                        color: gameTheme.puzzleToggleHideFinished
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
                .foregroundStyle(gameTheme.puzzleSettingsTitle)
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
                .fill(gameTheme.puzzleButtonBackground)
                .shadow(color: gameTheme.puzzleSettingsCardShadow, radius: 3, x: 0, y: 1)
        )
    }
}

// MARK: - Isolated Puzzle Button View
/// Separate view struct to isolate isPremium dependency from parent view.
/// This prevents unnecessary re-renders of the entire grid when unrelated
/// AppEnvironment properties change.
/// The theme colors a puzzle button needs. Unlike the `GameTheme` existential this is
/// Equatable, so SwiftUI can skip re-rendering buttons whose inputs didn't change.
private struct PuzzleButtonColors: Equatable {
    let puzzleButtonBackground: Color
    let puzzleButtonBackgroundLocked: Double
    let puzzleButtonBadge: Color
    let puzzleButtonBadgeText: Color
    let puzzleCompletedBorder: Color
    let puzzleCompletedIcon: Color
    let puzzleLockOverlay: Color
    
    init(theme: GameTheme) {
        puzzleButtonBackground = theme.puzzleButtonBackground
        puzzleButtonBackgroundLocked = theme.puzzleButtonBackgroundLocked
        puzzleButtonBadge = theme.puzzleButtonBadge
        puzzleButtonBadgeText = theme.puzzleButtonBadgeText
        puzzleCompletedBorder = theme.puzzleCompletedBorder
        puzzleCompletedIcon = theme.puzzleCompletedIcon
        puzzleLockOverlay = theme.puzzleLockOverlay
    }
}

private struct PuzzleButtonView: View {
    let puzzle: PremadePuzzle
    let isPremium: Bool
    let isCompleted: Bool
    let rating: Double?
    let colors: PuzzleButtonColors
    let freePuzzlesPerSection: Int
    
    private var isLocked: Bool {
        puzzle.number > freePuzzlesPerSection && !isPremium
    }
    
    var body: some View {
        content
    }
    
    private var content: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: Theme.Layout.puzzleButtonCornerRadius, style: .continuous)
                .fill(colors.puzzleButtonBackground.opacity(isLocked ? colors.puzzleButtonBackgroundLocked : 0.9))
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
            .fill(colors.puzzleButtonBadge)
            .frame(width: 46, height: 46)
            
            Text("\(puzzle.number)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(colors.puzzleButtonBadgeText)
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
                Circle().stroke(colors.puzzleCompletedBorder, lineWidth: 3)
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(colors.puzzleCompletedIcon)
            }
            .frame(width: 34, height: 34)
            .padding(.top, 4)
        }
    }
    
    private var lockOverlay: some View {
        ZStack {
            Circle()
                .fill(colors.puzzleLockOverlay)
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
