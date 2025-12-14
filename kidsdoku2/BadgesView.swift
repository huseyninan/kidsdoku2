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
}

enum BadgeRequirement {
    case puzzlesCompleted(count: Int)
    case perfectGames(count: Int)
    case gridSize(size: Int, count: Int)
    case totalStars(count: Int)
    case noHints(count: Int)
    case noMistakes(count: Int)
    case christmasTheme(count: Int)
}

// MARK: - Badge Section
struct BadgeSection: Identifiable {
    let id: String
    let title: String
    let icon: String
    let badges: [Badge]
}

// MARK: - Badge Definitions
struct BadgeDefinitions {
    static let sections: [BadgeSection] = [
        BadgeSection(
            id: "seasonal",
            title: String(localized: "Seasonal"),
            icon: "gift.fill",
            badges: [
                Badge(
                    id: "christmas_quest",
                    name: String(localized: "Christmas Quest"),
                    description: String(localized: "Complete all Christmas puzzles"),
                    icon: "snowflake",
                    color: Color(red: 0.2, green: 0.6, blue: 0.4),
                    gradientColors: [Color(red: 0.85, green: 0.15, blue: 0.2), Color(red: 0.2, green: 0.55, blue: 0.35)],
                    requirement: .christmasTheme(count: 27)
                ),
            ]
        ),
        BadgeSection(
            id: "journey",
            title: String(localized: "Journey"),
            icon: "figure.walk",
            badges: [
                Badge(
                    id: "first_puzzle",
                    name: String(localized: "First Steps"),
                    description: String(localized: "Complete your first puzzle"),
                    icon: "star.fill",
                    color: Color(red: 0.98, green: 0.74, blue: 0.3),
                    gradientColors: [Color(red: 1.0, green: 0.85, blue: 0.46), Color(red: 1.0, green: 0.63, blue: 0.46)],
                    requirement: .puzzlesCompleted(count: 1)
                ),
                Badge(
                    id: "puzzle_explorer",
                    name: String(localized: "Puzzle Explorer"),
                    description: String(localized: "Complete 5 puzzles"),
                    icon: "map.fill",
                    color: Color(red: 0.4, green: 0.75, blue: 0.55),
                    gradientColors: [Color(red: 0.5, green: 0.85, blue: 0.65), Color(red: 0.3, green: 0.65, blue: 0.45)],
                    requirement: .puzzlesCompleted(count: 5)
                ),
                Badge(
                    id: "puzzle_adventurer",
                    name: String(localized: "Adventurer"),
                    description: String(localized: "Complete 10 puzzles"),
                    icon: "figure.walk",
                    color: Color(red: 0.35, green: 0.6, blue: 0.85),
                    gradientColors: [Color(red: 0.45, green: 0.7, blue: 0.95), Color(red: 0.25, green: 0.5, blue: 0.75)],
                    requirement: .puzzlesCompleted(count: 10)
                ),
                Badge(
                    id: "puzzle_master",
                    name: String(localized: "Puzzle Master"),
                    description: String(localized: "Complete 25 puzzles"),
                    icon: "crown.fill",
                    color: Color(red: 0.85, green: 0.55, blue: 0.2),
                    gradientColors: [Color(red: 0.95, green: 0.75, blue: 0.35), Color(red: 0.75, green: 0.45, blue: 0.15)],
                    requirement: .puzzlesCompleted(count: 25)
                ),
                Badge(
                    id: "puzzle_legend",
                    name: String(localized: "Legend"),
                    description: String(localized: "Complete 50 puzzles"),
                    icon: "trophy.fill",
                    color: Color(red: 0.75, green: 0.35, blue: 0.65),
                    gradientColors: [Color(red: 0.85, green: 0.45, blue: 0.75), Color(red: 0.65, green: 0.25, blue: 0.55)],
                    requirement: .puzzlesCompleted(count: 50)
                ),
            ]
        ),
        BadgeSection(
            id: "perfection",
            title: String(localized: "Perfection"),
            icon: "sparkles",
            badges: [
                Badge(
                    id: "perfect_start",
                    name: String(localized: "Perfect Start"),
                    description: String(localized: "Complete a puzzle with 3 stars"),
                    icon: "sparkles",
                    color: Color(red: 0.95, green: 0.6, blue: 0.75),
                    gradientColors: [Color(red: 1.0, green: 0.7, blue: 0.85), Color(red: 0.9, green: 0.5, blue: 0.65)],
                    requirement: .perfectGames(count: 1)
                ),
                Badge(
                    id: "shining_star",
                    name: String(localized: "Shining Star"),
                    description: String(localized: "Get 3 stars on 5 puzzles"),
                    icon: "star.circle.fill",
                    color: Color(red: 1.0, green: 0.8, blue: 0.2),
                    gradientColors: [Color(red: 1.0, green: 0.9, blue: 0.4), Color(red: 1.0, green: 0.7, blue: 0.1)],
                    requirement: .perfectGames(count: 5)
                ),
                Badge(
                    id: "superstar",
                    name: String(localized: "Superstar"),
                    description: String(localized: "Get 3 stars on 15 puzzles"),
                    icon: "star.square.fill",
                    color: Color(red: 0.9, green: 0.45, blue: 0.3),
                    gradientColors: [Color(red: 1.0, green: 0.55, blue: 0.4), Color(red: 0.8, green: 0.35, blue: 0.2)],
                    requirement: .perfectGames(count: 15)
                ),
            ]
        ),
        BadgeSection(
            id: "grids",
            title: String(localized: "Grid Master"),
            icon: "square.grid.3x3.fill",
            badges: [
                Badge(
                    id: "tiny_tales_fan",
                    name: String(localized: "Tiny Tales Fan"),
                    description: String(localized: "Complete 5 puzzles in 3x3 grid"),
                    icon: "square.grid.3x3",
                    color: Color(red: 0.55, green: 0.75, blue: 0.9),
                    gradientColors: [Color(red: 0.65, green: 0.85, blue: 1.0), Color(red: 0.45, green: 0.65, blue: 0.8)],
                    requirement: .gridSize(size: 3, count: 5)
                ),
                Badge(
                    id: "fable_hero",
                    name: String(localized: "Fable Hero"),
                    description: String(localized: "Complete 5 puzzles in 4x4 grid"),
                    icon: "square.grid.4x3.fill",
                    color: Color(red: 0.65, green: 0.5, blue: 0.85),
                    gradientColors: [Color(red: 0.75, green: 0.6, blue: 0.95), Color(red: 0.55, green: 0.4, blue: 0.75)],
                    requirement: .gridSize(size: 4, count: 5)
                ),
                Badge(
                    id: "kingdom_champion",
                    name: String(localized: "Kingdom Champion"),
                    description: String(localized: "Complete 5 puzzles in 6x6 grid"),
                    icon: "square.grid.3x3.fill",
                    color: Color(red: 0.8, green: 0.5, blue: 0.4),
                    gradientColors: [Color(red: 0.9, green: 0.6, blue: 0.5), Color(red: 0.7, green: 0.4, blue: 0.3)],
                    requirement: .gridSize(size: 6, count: 5)
                ),
            ]
        ),
        BadgeSection(
            id: "stars",
            title: String(localized: "Star Collector"),
            icon: "star.fill",
            badges: [
                Badge(
                    id: "star_collector",
                    name: String(localized: "Star Collector"),
                    description: String(localized: "Earn a total of 10 stars"),
                    icon: "star.leadinghalf.filled",
                    color: Color(red: 0.45, green: 0.7, blue: 0.5),
                    gradientColors: [Color(red: 0.55, green: 0.8, blue: 0.6), Color(red: 0.35, green: 0.6, blue: 0.4)],
                    requirement: .totalStars(count: 10)
                ),
                Badge(
                    id: "star_hoarder",
                    name: String(localized: "Star Hoarder"),
                    description: String(localized: "Earn a total of 30 stars"),
                    icon: "stars.fill",
                    color: Color(red: 0.85, green: 0.65, blue: 0.35),
                    gradientColors: [Color(red: 0.95, green: 0.75, blue: 0.45), Color(red: 0.75, green: 0.55, blue: 0.25)],
                    requirement: .totalStars(count: 30)
                ),
                Badge(
                    id: "galaxy_master",
                    name: String(localized: "Galaxy Master"),
                    description: String(localized: "Earn a total of 75 stars"),
                    icon: "moon.stars.fill",
                    color: Color(red: 0.3, green: 0.35, blue: 0.7),
                    gradientColors: [Color(red: 0.4, green: 0.45, blue: 0.8), Color(red: 0.2, green: 0.25, blue: 0.6)],
                    requirement: .totalStars(count: 75)
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
            let christmasCompleted = completionManager.completedPuzzles.filter { $0.contains("christmas-") }.count
            + ratings.keys.filter { $0.hasPrefix("christmas-") }.count
            let uniqueChristmas = Set(
                completionManager.completedPuzzles.filter { $0.contains("christmas-") }
            ).union(
                ratings.keys.filter { $0.hasPrefix("christmas-") }
            ).count
            return min(1.0, Double(uniqueChristmas) / Double(count))
        }
    }
}

// MARK: - Badge Section View
struct BadgeSectionView: View {
    let section: BadgeSection
    let columns: [GridItem]
    let isBadgeEarned: (Badge) -> Bool
    let badgeProgress: (Badge) -> Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack(spacing: 10) {
                Image(systemName: section.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(red: 0.7, green: 0.35, blue: 0.3))
                
                Text(section.title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
                
                Spacer()
                
                // Section progress
                let earned = section.badges.filter { isBadgeEarned($0) }.count
                Text("\(earned)/\(section.badges.count)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.gray)
            }
            .padding(.horizontal, 24)
            
            // Badges Grid
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(section.badges) { badge in
                    BadgeCardView(
                        badge: badge,
                        isEarned: isBadgeEarned(badge),
                        progress: badgeProgress(badge)
                    )
                }
            }
            .padding(.horizontal, 20)
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
    
    @State private var animateBadge = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Badge Icon
            ZStack {
                Circle()
                    .fill(
                        isEarned
                            ? LinearGradient(colors: badge.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: isEarned ? badge.color.opacity(0.4) : Color.clear, radius: 10, x: 0, y: 4)
                
                Image(systemName: badge.icon)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(isEarned ? .white : Color.gray.opacity(0.5))
                
                if !isEarned {
                    // Progress ring
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(colors: badge.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 78, height: 78)
                        .rotationEffect(.degrees(-90))
                }
            }
            .overlay(
                Circle()
                    .stroke(isEarned ? Color.white.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 3)
                    .frame(width: 70, height: 70)
            )
            .scaleEffect(animateBadge && isEarned ? 1.05 : 1.0)
            
            // Badge Info
            VStack(spacing: 4) {
                Text(badge.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(isEarned ? Color(red: 0.4, green: 0.25, blue: 0.15) : Color.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text(badge.description)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            
            // Progress indicator for unearned badges
            if !isEarned {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(badge.color)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(isEarned ? 0.9 : 0.6))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    isEarned
                        ? LinearGradient(colors: badge.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.clear, Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 2
                )
        )
        .onAppear {
            if isEarned {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    animateBadge = true
                }
            }
        }
    }
}

#Preview {
    BadgesView()
}
