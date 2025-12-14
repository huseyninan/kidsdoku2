//
//  BadgesView.swift
//  kidsdoku2
//
//  Badges and achievements view
//

import SwiftUI

// MARK: - Badge Model
struct Badge: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: Color
    let gradientColors: [Color]
    let requirement: BadgeRequirement
    var rarity: BadgeRarity = .common
}

enum BadgeRarity: String {
    case common = "Common"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    var starCount: Int {
        switch self {
        case .common: return 1
        case .rare: return 2
        case .epic: return 3
        case .legendary: return 4
        }
    }
}

enum BadgeRequirement {
    case puzzlesCompleted(count: Int)
    case perfectGames(count: Int)
    case gridSize(size: Int, count: Int)
    case totalStars(count: Int)
    case noHints(count: Int)
    case noMistakes(count: Int)
    case christmasTheme(count: Int)
    case streak(days: Int)
}

// MARK: - Badge Section
struct BadgeSection: Identifiable {
    let id: String
    let title: String
    let icon: String
    let color: Color
    let badges: [Badge]
}

// MARK: - Badge Definitions
struct BadgeDefinitions {
    static let sections: [BadgeSection] = [
        // MARK: Seasonal Badges
        BadgeSection(
            id: "seasonal",
            title: String(localized: "Seasonal"),
            icon: "gift.fill",
            color: Color(red: 0.85, green: 0.2, blue: 0.25),
            badges: [
                Badge(
                    id: "christmas_quest",
                    name: String(localized: "Christmas Quest"),
                    description: String(localized: "Complete all Christmas puzzles"),
                    icon: "snowflake",
                    color: Color(red: 0.2, green: 0.6, blue: 0.4),
                    gradientColors: [Color(red: 0.85, green: 0.15, blue: 0.2), Color(red: 0.2, green: 0.55, blue: 0.35)],
                    requirement: .christmasTheme(count: 27),
                    rarity: .legendary
                ),
            ]
        ),
        
        // MARK: Journey Badges
        BadgeSection(
            id: "journey",
            title: String(localized: "Journey"),
            icon: "map.fill",
            color: Color(red: 0.4, green: 0.7, blue: 0.5),
            badges: [
                Badge(
                    id: "first_puzzle",
                    name: String(localized: "First Steps"),
                    description: String(localized: "Complete your first puzzle"),
                    icon: "footprints.fill",
                    color: Color(red: 0.55, green: 0.78, blue: 0.6),
                    gradientColors: [Color(red: 0.6, green: 0.85, blue: 0.65), Color(red: 0.4, green: 0.7, blue: 0.5)],
                    requirement: .puzzlesCompleted(count: 1),
                    rarity: .common
                ),
                Badge(
                    id: "puzzle_explorer",
                    name: String(localized: "Explorer"),
                    description: String(localized: "Complete 5 puzzles"),
                    icon: "binoculars.fill",
                    color: Color(red: 0.4, green: 0.65, blue: 0.85),
                    gradientColors: [Color(red: 0.5, green: 0.75, blue: 0.95), Color(red: 0.3, green: 0.55, blue: 0.75)],
                    requirement: .puzzlesCompleted(count: 5),
                    rarity: .common
                ),
                Badge(
                    id: "puzzle_adventurer",
                    name: String(localized: "Adventurer"),
                    description: String(localized: "Complete 10 puzzles"),
                    icon: "figure.hiking",
                    color: Color(red: 0.35, green: 0.6, blue: 0.85),
                    gradientColors: [Color(red: 0.45, green: 0.7, blue: 0.95), Color(red: 0.25, green: 0.5, blue: 0.75)],
                    requirement: .puzzlesCompleted(count: 10),
                    rarity: .rare
                ),
                Badge(
                    id: "puzzle_master",
                    name: String(localized: "Puzzle Master"),
                    description: String(localized: "Complete 25 puzzles"),
                    icon: "crown.fill",
                    color: Color(red: 0.85, green: 0.55, blue: 0.2),
                    gradientColors: [Color(red: 0.95, green: 0.75, blue: 0.35), Color(red: 0.75, green: 0.45, blue: 0.15)],
                    requirement: .puzzlesCompleted(count: 25),
                    rarity: .epic
                ),
                Badge(
                    id: "puzzle_legend",
                    name: String(localized: "Legend"),
                    description: String(localized: "Complete 50 puzzles"),
                    icon: "trophy.fill",
                    color: Color(red: 0.75, green: 0.35, blue: 0.65),
                    gradientColors: [Color(red: 0.85, green: 0.45, blue: 0.75), Color(red: 0.65, green: 0.25, blue: 0.55)],
                    requirement: .puzzlesCompleted(count: 50),
                    rarity: .legendary
                ),
                Badge(
                    id: "puzzle_champion",
                    name: String(localized: "Champion"),
                    description: String(localized: "Complete 100 puzzles"),
                    icon: "medal.fill",
                    color: Color(red: 1.0, green: 0.75, blue: 0.3),
                    gradientColors: [Color(red: 1.0, green: 0.85, blue: 0.4), Color(red: 0.9, green: 0.6, blue: 0.2)],
                    requirement: .puzzlesCompleted(count: 100),
                    rarity: .legendary
                ),
            ]
        ),
        
        // MARK: Perfection Badges
        BadgeSection(
            id: "perfection",
            title: String(localized: "Perfection"),
            icon: "sparkles",
            color: Color(red: 0.95, green: 0.6, blue: 0.7),
            badges: [
                Badge(
                    id: "perfect_start",
                    name: String(localized: "Perfect Start"),
                    description: String(localized: "Get 3 stars on a puzzle"),
                    icon: "sparkle",
                    color: Color(red: 0.95, green: 0.6, blue: 0.75),
                    gradientColors: [Color(red: 1.0, green: 0.7, blue: 0.85), Color(red: 0.9, green: 0.5, blue: 0.65)],
                    requirement: .perfectGames(count: 1),
                    rarity: .common
                ),
                Badge(
                    id: "shining_star",
                    name: String(localized: "Shining Star"),
                    description: String(localized: "Get 3 stars on 5 puzzles"),
                    icon: "star.circle.fill",
                    color: Color(red: 1.0, green: 0.8, blue: 0.2),
                    gradientColors: [Color(red: 1.0, green: 0.9, blue: 0.4), Color(red: 1.0, green: 0.7, blue: 0.1)],
                    requirement: .perfectGames(count: 5),
                    rarity: .rare
                ),
                Badge(
                    id: "superstar",
                    name: String(localized: "Superstar"),
                    description: String(localized: "Get 3 stars on 15 puzzles"),
                    icon: "star.square.fill",
                    color: Color(red: 0.9, green: 0.45, blue: 0.3),
                    gradientColors: [Color(red: 1.0, green: 0.55, blue: 0.4), Color(red: 0.8, green: 0.35, blue: 0.2)],
                    requirement: .perfectGames(count: 15),
                    rarity: .epic
                ),
                Badge(
                    id: "perfectionist",
                    name: String(localized: "Perfectionist"),
                    description: String(localized: "Get 3 stars on 30 puzzles"),
                    icon: "sparkles",
                    color: Color(red: 0.85, green: 0.4, blue: 0.9),
                    gradientColors: [Color(red: 0.95, green: 0.5, blue: 1.0), Color(red: 0.75, green: 0.3, blue: 0.8)],
                    requirement: .perfectGames(count: 30),
                    rarity: .legendary
                ),
            ]
        ),
        
        // MARK: Grid Master Badges
        BadgeSection(
            id: "grids",
            title: String(localized: "Grid Master"),
            icon: "square.grid.3x3.fill",
            color: Color(red: 0.55, green: 0.5, blue: 0.85),
            badges: [
                Badge(
                    id: "tiny_tales_fan",
                    name: String(localized: "Tiny Tales Fan"),
                    description: String(localized: "Complete 5 puzzles in 3x3"),
                    icon: "square.grid.3x3",
                    color: Color(red: 0.55, green: 0.75, blue: 0.9),
                    gradientColors: [Color(red: 0.65, green: 0.85, blue: 1.0), Color(red: 0.45, green: 0.65, blue: 0.8)],
                    requirement: .gridSize(size: 3, count: 5),
                    rarity: .common
                ),
                Badge(
                    id: "tiny_tales_master",
                    name: String(localized: "Tiny Tales Master"),
                    description: String(localized: "Complete 15 puzzles in 3x3"),
                    icon: "square.grid.3x3.fill",
                    color: Color(red: 0.4, green: 0.65, blue: 0.85),
                    gradientColors: [Color(red: 0.5, green: 0.75, blue: 0.95), Color(red: 0.3, green: 0.55, blue: 0.75)],
                    requirement: .gridSize(size: 3, count: 15),
                    rarity: .rare
                ),
                Badge(
                    id: "fable_hero",
                    name: String(localized: "Fable Hero"),
                    description: String(localized: "Complete 5 puzzles in 4x4"),
                    icon: "square.grid.4x3.fill",
                    color: Color(red: 0.65, green: 0.5, blue: 0.85),
                    gradientColors: [Color(red: 0.75, green: 0.6, blue: 0.95), Color(red: 0.55, green: 0.4, blue: 0.75)],
                    requirement: .gridSize(size: 4, count: 5),
                    rarity: .common
                ),
                Badge(
                    id: "fable_legend",
                    name: String(localized: "Fable Legend"),
                    description: String(localized: "Complete 15 puzzles in 4x4"),
                    icon: "square.grid.4x3.fill",
                    color: Color(red: 0.55, green: 0.4, blue: 0.8),
                    gradientColors: [Color(red: 0.65, green: 0.5, blue: 0.9), Color(red: 0.45, green: 0.3, blue: 0.7)],
                    requirement: .gridSize(size: 4, count: 15),
                    rarity: .rare
                ),
                Badge(
                    id: "kingdom_champion",
                    name: String(localized: "Kingdom Champion"),
                    description: String(localized: "Complete 5 puzzles in 6x6"),
                    icon: "rectangle.grid.3x2.fill",
                    color: Color(red: 0.8, green: 0.5, blue: 0.4),
                    gradientColors: [Color(red: 0.9, green: 0.6, blue: 0.5), Color(red: 0.7, green: 0.4, blue: 0.3)],
                    requirement: .gridSize(size: 6, count: 5),
                    rarity: .rare
                ),
                Badge(
                    id: "kingdom_ruler",
                    name: String(localized: "Kingdom Ruler"),
                    description: String(localized: "Complete 15 puzzles in 6x6"),
                    icon: "crown.fill",
                    color: Color(red: 0.75, green: 0.4, blue: 0.35),
                    gradientColors: [Color(red: 0.85, green: 0.5, blue: 0.45), Color(red: 0.65, green: 0.3, blue: 0.25)],
                    requirement: .gridSize(size: 6, count: 15),
                    rarity: .epic
                ),
            ]
        ),
        
        // MARK: Star Collection Badges
        BadgeSection(
            id: "stars",
            title: String(localized: "Star Collector"),
            icon: "star.fill",
            color: Color(red: 1.0, green: 0.75, blue: 0.3),
            badges: [
                Badge(
                    id: "star_collector",
                    name: String(localized: "Star Collector"),
                    description: String(localized: "Earn 10 stars total"),
                    icon: "star.fill",
                    color: Color(red: 0.45, green: 0.7, blue: 0.5),
                    gradientColors: [Color(red: 0.55, green: 0.8, blue: 0.6), Color(red: 0.35, green: 0.6, blue: 0.4)],
                    requirement: .totalStars(count: 10),
                    rarity: .common
                ),
                Badge(
                    id: "star_hoarder",
                    name: String(localized: "Star Hoarder"),
                    description: String(localized: "Earn 30 stars total"),
                    icon: "star.leadinghalf.filled",
                    color: Color(red: 0.85, green: 0.65, blue: 0.35),
                    gradientColors: [Color(red: 0.95, green: 0.75, blue: 0.45), Color(red: 0.75, green: 0.55, blue: 0.25)],
                    requirement: .totalStars(count: 30),
                    rarity: .rare
                ),
                Badge(
                    id: "star_master",
                    name: String(localized: "Star Master"),
                    description: String(localized: "Earn 75 stars total"),
                    icon: "star.circle.fill",
                    color: Color(red: 0.9, green: 0.55, blue: 0.25),
                    gradientColors: [Color(red: 1.0, green: 0.65, blue: 0.35), Color(red: 0.8, green: 0.45, blue: 0.15)],
                    requirement: .totalStars(count: 75),
                    rarity: .epic
                ),
                Badge(
                    id: "galaxy_master",
                    name: String(localized: "Galaxy Master"),
                    description: String(localized: "Earn 150 stars total"),
                    icon: "moon.stars.fill",
                    color: Color(red: 0.3, green: 0.35, blue: 0.7),
                    gradientColors: [Color(red: 0.4, green: 0.45, blue: 0.8), Color(red: 0.2, green: 0.25, blue: 0.6)],
                    requirement: .totalStars(count: 150),
                    rarity: .legendary
                ),
            ]
        ),
    ]
    
    static var allBadges: [Badge] {
        sections.flatMap { $0.badges }
    }
}

// MARK: - Badges View
struct BadgesView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var completionManager = PuzzleCompletionManager.shared
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.93, blue: 0.87),
                        Color(red: 0.90, green: 0.88, blue: 0.82)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with stats
                        BadgesHeaderView(
                            earnedCount: earnedBadgesCount,
                            totalCount: BadgeDefinitions.allBadges.count
                        )
                        
                        // Badges by Section
                        ForEach(BadgeDefinitions.sections) { section in
                            BadgeSectionView(
                                section: section,
                                columns: columns,
                                isBadgeEarned: isBadgeEarned,
                                badgeProgress: badgeProgress
                            )
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "Done")) {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.7, green: 0.35, blue: 0.3))
                }
            }
        }
    }
    
    private var earnedBadgesCount: Int {
        BadgeDefinitions.allBadges.filter { isBadgeEarned($0) }.count
    }
    
    private func isBadgeEarned(_ badge: Badge) -> Bool {
        let progress = badgeProgress(badge)
        return progress >= 1.0
    }
    
    private func badgeProgress(_ badge: Badge) -> Double {
        let completedCount = completionManager.completedPuzzles.count
        let ratings = completionManager.puzzleRatings
        
        switch badge.requirement {
        case .puzzlesCompleted(let count):
            return min(1.0, Double(completedCount) / Double(count))
            
        case .perfectGames(let count):
            let perfectCount = ratings.values.filter { $0 >= 3.0 }.count
            return min(1.0, Double(perfectCount) / Double(count))
            
        case .gridSize(let size, let count):
            let sizeCompleted = completionManager.completedPuzzles.filter { $0.hasPrefix("\(size)-") }.count
            return min(1.0, Double(sizeCompleted) / Double(count))
            
        case .totalStars(let count):
            let totalStars = ratings.values.reduce(0, +)
            return min(1.0, totalStars / Double(count))
            
        case .noHints(let count):
            return min(1.0, Double(completedCount) / Double(count))
            
        case .noMistakes(let count):
            return min(1.0, Double(completedCount) / Double(count))
            
        case .christmasTheme(let count):
            let uniqueChristmas = Set(
                completionManager.completedPuzzles.filter { $0.contains("christmas-") }
            ).union(
                ratings.keys.filter { $0.hasPrefix("christmas-") }
            ).count
            return min(1.0, Double(uniqueChristmas) / Double(count))
            
        case .streak:
            return 0.0
        }
    }
}

// MARK: - Badge Section View
struct BadgeSectionView: View {
    let section: BadgeSection
    let columns: [GridItem]
    let isBadgeEarned: (Badge) -> Bool
    let badgeProgress: (Badge) -> Double
    
    private var earned: Int {
        section.badges.filter { isBadgeEarned($0) }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [section.color.opacity(0.8), section.color],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: section.icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(section.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                    
                    Text("\(earned) of \(section.badges.count) earned")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.gray)
                }
                
                Spacer()
                
                // Progress circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 3)
                        .frame(width: 32, height: 32)
                    
                    Circle()
                        .trim(from: 0, to: section.badges.isEmpty ? 0 : Double(earned) / Double(section.badges.count))
                        .stroke(section.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 32, height: 32)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(earned)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(section.color)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.6))
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            )
            .padding(.horizontal, 16)
            
            // Badges Grid
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(section.badges) { badge in
                    BadgeCardView(
                        badge: badge,
                        isEarned: isBadgeEarned(badge),
                        progress: badgeProgress(badge)
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Badges Header View
struct BadgesHeaderView: View {
    let earnedCount: Int
    let totalCount: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Text(String(localized: "Badges"))
                .font(.system(size: 42, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
            
            HStack(spacing: 8) {
                Image(systemName: "rosette")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.7, green: 0.35, blue: 0.3))
                
                Text("\(earnedCount) / \(totalCount)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                
                Text(String(localized: "Earned"))
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.gray)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.7))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
        }
        .padding(.top, 8)
    }
}

// MARK: - Badge Card View
struct BadgeCardView: View {
    let badge: Badge
    let isEarned: Bool
    let progress: Double
    
    @State private var animateGlow = false
    
    private var rarityColor: Color {
        switch badge.rarity {
        case .common: return Color(red: 0.6, green: 0.6, blue: 0.6)
        case .rare: return Color(red: 0.3, green: 0.6, blue: 0.9)
        case .epic: return Color(red: 0.7, green: 0.4, blue: 0.9)
        case .legendary: return Color(red: 1.0, green: 0.75, blue: 0.3)
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Badge Icon with hexagon shape
            ZStack {
                // Outer glow for earned badges
                if isEarned {
                    Circle()
                        .fill(badge.color.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .blur(radius: 8)
                        .scaleEffect(animateGlow ? 1.1 : 0.95)
                }
                
                // Badge background
                Circle()
                    .fill(
                        isEarned
                            ? LinearGradient(colors: badge.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.gray.opacity(0.25), Color.gray.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 64, height: 64)
                
                // Inner highlight
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(isEarned ? 0.4 : 0.1), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .frame(width: 64, height: 64)
                
                // Icon
                Image(systemName: badge.icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(isEarned ? .white : Color.gray.opacity(0.4))
                    .shadow(color: isEarned ? Color.black.opacity(0.2) : .clear, radius: 2, x: 0, y: 1)
                
                // Progress ring for unearned
                if !isEarned && progress > 0 {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(colors: badge.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 72, height: 72)
                        .rotationEffect(.degrees(-90))
                }
                
                // Border ring
                Circle()
                    .stroke(
                        isEarned
                            ? LinearGradient(colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 2
                    )
                    .frame(width: 64, height: 64)
            }
            .frame(height: 80)
            
            // Badge name
            Text(badge.name)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(isEarned ? Color(red: 0.35, green: 0.22, blue: 0.12) : Color.gray)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            // Rarity stars
            HStack(spacing: 2) {
                ForEach(0..<badge.rarity.starCount, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 8))
                        .foregroundColor(isEarned ? rarityColor : Color.gray.opacity(0.3))
                }
            }
            
            // Description - always visible
            Text(badge.description)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(isEarned ? Color(red: 0.5, green: 0.4, blue: 0.35) : Color.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(minHeight: 26)
            
            // Progress bar for unearned badges
            if !isEarned {
                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 5)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(colors: badge.gradientColors, startPoint: .leading, endPoint: .trailing)
                                )
                                .frame(width: geo.size.width * progress, height: 5)
                        }
                    }
                    .frame(height: 5)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(badge.color)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    isEarned
                        ? Color.white.opacity(0.95)
                        : Color.white.opacity(0.5)
                )
                .shadow(
                    color: isEarned ? badge.color.opacity(0.2) : Color.black.opacity(0.05),
                    radius: isEarned ? 12 : 6,
                    x: 0,
                    y: isEarned ? 6 : 3
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    isEarned
                        ? LinearGradient(colors: badge.gradientColors.map { $0.opacity(0.6) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: isEarned ? 2 : 1
                )
        )
        .onAppear {
            if isEarned {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    animateGlow = true
                }
            }
        }
    }
}

#Preview {
    BadgesView()
}
