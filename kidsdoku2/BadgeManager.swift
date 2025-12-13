//
//  BadgeManager.swift
//  kidsdoku2
//
//  Manages badge/achievement tracking for quests and puzzle completion
//

import SwiftUI
import Combine

// MARK: - Badge Definition

enum Badge: String, CaseIterable, Identifiable {
    // Quest Completion Badges
    case christmasQuestComplete = "christmas_quest_complete"
    case tinyTalesComplete = "tiny_tales_complete"
    case fableAdventuresComplete = "fable_adventures_complete"
    case kingdomChroniclesComplete = "kingdom_chronicles_complete"
    
    // Milestone Badges
    case firstPuzzle = "first_puzzle"
    case puzzleMaster10 = "puzzle_master_10"
    case puzzleMaster25 = "puzzle_master_25"
    case puzzleMaster50 = "puzzle_master_50"
    case puzzleMaster100 = "puzzle_master_100"
    
    // Difficulty Badges
    case easyExplorer = "easy_explorer"
    case normalNavigator = "normal_navigator"
    case hardHero = "hard_hero"
    
    // Perfect Score Badges
    case perfectStar = "perfect_star"
    case starCollector10 = "star_collector_10"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .christmasQuestComplete:
            return String(localized: "Holiday Hero")
        case .tinyTalesComplete:
            return String(localized: "Tale Teller")
        case .fableAdventuresComplete:
            return String(localized: "Fable Master")
        case .kingdomChroniclesComplete:
            return String(localized: "Chronicle Champion")
        case .firstPuzzle:
            return String(localized: "First Steps")
        case .puzzleMaster10:
            return String(localized: "Rising Star")
        case .puzzleMaster25:
            return String(localized: "Puzzle Pro")
        case .puzzleMaster50:
            return String(localized: "Puzzle Expert")
        case .puzzleMaster100:
            return String(localized: "Puzzle Legend")
        case .easyExplorer:
            return String(localized: "Easy Explorer")
        case .normalNavigator:
            return String(localized: "Normal Navigator")
        case .hardHero:
            return String(localized: "Hard Hero")
        case .perfectStar:
            return String(localized: "Perfect Star")
        case .starCollector10:
            return String(localized: "Star Collector")
        }
    }
    
    var description: String {
        switch self {
        case .christmasQuestComplete:
            return String(localized: "Complete all Christmas Quest puzzles")
        case .tinyTalesComplete:
            return String(localized: "Complete all 3x3 Tiny Tales puzzles")
        case .fableAdventuresComplete:
            return String(localized: "Complete all 4x4 Fable Adventures puzzles")
        case .kingdomChroniclesComplete:
            return String(localized: "Complete all 6x6 Kingdom Chronicles puzzles")
        case .firstPuzzle:
            return String(localized: "Complete your first puzzle")
        case .puzzleMaster10:
            return String(localized: "Complete 10 puzzles")
        case .puzzleMaster25:
            return String(localized: "Complete 25 puzzles")
        case .puzzleMaster50:
            return String(localized: "Complete 50 puzzles")
        case .puzzleMaster100:
            return String(localized: "Complete 100 puzzles")
        case .easyExplorer:
            return String(localized: "Complete 5 Easy puzzles")
        case .normalNavigator:
            return String(localized: "Complete 5 Normal puzzles")
        case .hardHero:
            return String(localized: "Complete 5 Hard puzzles")
        case .perfectStar:
            return String(localized: "Earn your first 3-star rating")
        case .starCollector10:
            return String(localized: "Earn 10 three-star ratings")
        }
    }
    
    var icon: String {
        switch self {
        case .christmasQuestComplete:
            return "snowflake"
        case .tinyTalesComplete:
            return "book.fill"
        case .fableAdventuresComplete:
            return "sparkles"
        case .kingdomChroniclesComplete:
            return "crown.fill"
        case .firstPuzzle:
            return "flag.fill"
        case .puzzleMaster10:
            return "star.fill"
        case .puzzleMaster25:
            return "star.circle.fill"
        case .puzzleMaster50:
            return "medal.fill"
        case .puzzleMaster100:
            return "trophy.fill"
        case .easyExplorer:
            return "leaf.fill"
        case .normalNavigator:
            return "compass.drawing"
        case .hardHero:
            return "flame.fill"
        case .perfectStar:
            return "star.leadinghalf.filled"
        case .starCollector10:
            return "stars.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .christmasQuestComplete:
            return Color(red: 0.2, green: 0.5, blue: 0.35) // Christmas green
        case .tinyTalesComplete:
            return Color(red: 0.45, green: 0.55, blue: 0.45) // Forest green
        case .fableAdventuresComplete:
            return Color(red: 0.35, green: 0.45, blue: 0.60) // Blue
        case .kingdomChroniclesComplete:
            return Color(red: 0.55, green: 0.35, blue: 0.60) // Purple
        case .firstPuzzle:
            return Color(red: 0.4, green: 0.7, blue: 0.4) // Light green
        case .puzzleMaster10:
            return Color(red: 0.95, green: 0.77, blue: 0.06) // Gold
        case .puzzleMaster25:
            return Color(red: 0.9, green: 0.6, blue: 0.1) // Orange gold
        case .puzzleMaster50:
            return Color(red: 0.85, green: 0.5, blue: 0.2) // Bronze
        case .puzzleMaster100:
            return Color(red: 0.7, green: 0.35, blue: 0.3) // Ruby
        case .easyExplorer:
            return Color(red: 0.45, green: 0.55, blue: 0.45) // Green
        case .normalNavigator:
            return Color(red: 0.35, green: 0.45, blue: 0.60) // Blue
        case .hardHero:
            return Color(red: 0.85, green: 0.35, blue: 0.25) // Red
        case .perfectStar:
            return Color(red: 0.95, green: 0.8, blue: 0.2) // Bright gold
        case .starCollector10:
            return Color(red: 0.9, green: 0.7, blue: 0.1) // Deep gold
        }
    }
    
    var category: BadgeCategory {
        switch self {
        case .christmasQuestComplete:
            return .quests
        case .tinyTalesComplete, .fableAdventuresComplete, .kingdomChroniclesComplete:
            return .quests
        case .firstPuzzle, .puzzleMaster10, .puzzleMaster25, .puzzleMaster50, .puzzleMaster100:
            return .milestones
        case .easyExplorer, .normalNavigator, .hardHero:
            return .difficulty
        case .perfectStar, .starCollector10:
            return .stars
        }
    }
}

enum BadgeCategory: String, CaseIterable {
    case quests = "Quests"
    case milestones = "Milestones"
    case difficulty = "Difficulty"
    case stars = "Stars"
    
    var displayName: String {
        switch self {
        case .quests:
            return String(localized: "Quest Badges")
        case .milestones:
            return String(localized: "Milestone Badges")
        case .difficulty:
            return String(localized: "Difficulty Badges")
        case .stars:
            return String(localized: "Star Badges")
        }
    }
    
    var icon: String {
        switch self {
        case .quests:
            return "map.fill"
        case .milestones:
            return "flag.checkered"
        case .difficulty:
            return "chart.bar.fill"
        case .stars:
            return "star.fill"
        }
    }
}

// MARK: - Badge Manager

class BadgeManager: ObservableObject {
    static let shared = BadgeManager()
    
    @Published private(set) var earnedBadges: Set<String> = []
    @Published private(set) var newlyEarnedBadge: Badge?
    
    private let userDefaultsKey = "earnedBadges"
    
    private init() {
        loadBadges()
    }
    
    // MARK: - Public Interface
    
    func hasBadge(_ badge: Badge) -> Bool {
        earnedBadges.contains(badge.rawValue)
    }
    
    func earnBadge(_ badge: Badge) {
        guard !hasBadge(badge) else { return }
        earnedBadges.insert(badge.rawValue)
        saveBadges()
        newlyEarnedBadge = badge
        
        // Play celebration sound
        HapticManager.shared.trigger(.success)
    }
    
    func clearNewBadgeNotification() {
        newlyEarnedBadge = nil
    }
    
    func earnedBadgesCount() -> Int {
        earnedBadges.count
    }
    
    func totalBadgesCount() -> Int {
        Badge.allCases.count
    }
    
    func badges(for category: BadgeCategory) -> [Badge] {
        Badge.allCases.filter { $0.category == category }
    }
    
    // MARK: - Badge Checking Logic
    
    func checkAndAwardBadges() {
        let completionManager = PuzzleCompletionManager.shared
        let completedCount = completionManager.completedPuzzles.count
        
        // First puzzle badge
        if completedCount >= 1 {
            earnBadge(.firstPuzzle)
        }
        
        // Milestone badges
        if completedCount >= 10 {
            earnBadge(.puzzleMaster10)
        }
        if completedCount >= 25 {
            earnBadge(.puzzleMaster25)
        }
        if completedCount >= 50 {
            earnBadge(.puzzleMaster50)
        }
        if completedCount >= 100 {
            earnBadge(.puzzleMaster100)
        }
        
        // Christmas Quest badge
        if completionManager.areAllChristmasPuzzlesCompleted() {
            earnBadge(.christmasQuestComplete)
        }
        
        // Quest completion badges (check all puzzles for each size)
        checkQuestCompletionBadges()
        
        // Difficulty badges
        checkDifficultyBadges()
        
        // Star badges
        checkStarBadges()
    }
    
    private func checkQuestCompletionBadges() {
        let store = PremadePuzzleStore.shared
        let completionManager = PuzzleCompletionManager.shared
        
        // 3x3 Tiny Tales
        let puzzles3x3 = store.puzzles(for: 3)
        if !puzzles3x3.isEmpty && puzzles3x3.allSatisfy({ completionManager.isCompleted(puzzle: $0) }) {
            earnBadge(.tinyTalesComplete)
        }
        
        // 4x4 Fable Adventures
        let puzzles4x4 = store.puzzles(for: 4)
        if !puzzles4x4.isEmpty && puzzles4x4.allSatisfy({ completionManager.isCompleted(puzzle: $0) }) {
            earnBadge(.fableAdventuresComplete)
        }
        
        // 6x6 Kingdom Chronicles
        let puzzles6x6 = store.puzzles(for: 6)
        if !puzzles6x6.isEmpty && puzzles6x6.allSatisfy({ completionManager.isCompleted(puzzle: $0) }) {
            earnBadge(.kingdomChroniclesComplete)
        }
    }
    
    private func checkDifficultyBadges() {
        let completionManager = PuzzleCompletionManager.shared
        
        var easyCount = 0
        var normalCount = 0
        var hardCount = 0
        
        for key in completionManager.completedPuzzles {
            if key.contains("-easy-") {
                easyCount += 1
            } else if key.contains("-normal-") {
                normalCount += 1
            } else if key.contains("-hard-") {
                hardCount += 1
            }
        }
        
        if easyCount >= 5 {
            earnBadge(.easyExplorer)
        }
        if normalCount >= 5 {
            earnBadge(.normalNavigator)
        }
        if hardCount >= 5 {
            earnBadge(.hardHero)
        }
    }
    
    private func checkStarBadges() {
        let completionManager = PuzzleCompletionManager.shared
        
        var perfectCount = 0
        for (_, rating) in completionManager.puzzleRatings {
            if rating >= 3.0 {
                perfectCount += 1
            }
        }
        
        if perfectCount >= 1 {
            earnBadge(.perfectStar)
        }
        if perfectCount >= 10 {
            earnBadge(.starCollector10)
        }
    }
    
    func resetBadges() {
        earnedBadges.removeAll()
        saveBadges()
    }
    
    // MARK: - Persistence
    
    private func loadBadges() {
        if let data = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] {
            earnedBadges = Set(data)
        }
    }
    
    private func saveBadges() {
        UserDefaults.standard.set(Array(earnedBadges), forKey: userDefaultsKey)
    }
}

