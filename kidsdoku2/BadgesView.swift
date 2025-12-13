//
//  BadgesView.swift
//  kidsdoku2
//
//  Displays earned badges and achievements
//

import SwiftUI

struct BadgesView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var badgeManager = BadgeManager.shared
    @State private var selectedCategory: BadgeCategory = .quests
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.93, blue: 0.87),
                    Color(red: 0.90, green: 0.88, blue: 0.82)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Category tabs
                categoryTabs
                    .padding(.top, 16)
                
                // Badge grid
                ScrollView {
                    badgeGrid
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(red: 0.5, green: 0.4, blue: 0.35))
                }
                
                Spacer()
                
                // Progress indicator
                HStack(spacing: 6) {
                    Image(systemName: "rosette")
                        .font(.system(size: 18, weight: .semibold))
                    Text("\(badgeManager.earnedBadgesCount())/\(badgeManager.totalBadgesCount())")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundColor(Color(red: 0.7, green: 0.35, blue: 0.3))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.8))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Text("Badges")
                .font(.system(size: 38, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(red: 0.4, green: 0.25, blue: 0.15))
            
            Text("Collect badges by completing quests!")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
    }
    
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(BadgeCategory.allCases, id: \.self) { category in
                    CategoryTab(
                        category: category,
                        isSelected: selectedCategory == category,
                        earnedCount: badgeManager.badges(for: category).filter { badgeManager.hasBadge($0) }.count,
                        totalCount: badgeManager.badges(for: category).count
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                        HapticManager.shared.trigger(.selection)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var badgeGrid: some View {
        let badges = badgeManager.badges(for: selectedCategory)
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
        
        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(badges) { badge in
                BadgeCard(
                    badge: badge,
                    isEarned: badgeManager.hasBadge(badge)
                )
            }
        }
    }
}

// MARK: - Category Tab

struct CategoryTab: View {
    let category: BadgeCategory
    let isSelected: Bool
    let earnedCount: Int
    let totalCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(category.displayName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                
                Text("\(earnedCount)/\(totalCount)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.white.opacity(0.3) : Color.gray.opacity(0.2))
                    )
            }
            .foregroundColor(isSelected ? .white : Color(red: 0.4, green: 0.25, blue: 0.15))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(isSelected 
                        ? Color(red: 0.7, green: 0.35, blue: 0.3)
                        : Color.white.opacity(0.8))
                    .shadow(color: .black.opacity(isSelected ? 0.2 : 0.08), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Badge Card

struct BadgeCard: View {
    let badge: Badge
    let isEarned: Bool
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Badge icon
            ZStack {
                Circle()
                    .fill(
                        isEarned
                            ? LinearGradient(
                                colors: [badge.color.opacity(0.8), badge.color],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: isEarned ? badge.color.opacity(0.4) : .clear, radius: 8, x: 0, y: 4)
                
                if isEarned {
                    Image(systemName: badge.icon)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                // Shine effect for earned badges
                if isEarned {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .clear],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                        .frame(width: 70, height: 70)
                }
            }
            
            // Badge info
            VStack(spacing: 4) {
                Text(badge.displayName)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(isEarned ? Color(red: 0.4, green: 0.25, blue: 0.15) : .gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text(badge.description)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(height: 50)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(isEarned ? 0.9 : 0.6))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    isEarned ? badge.color.opacity(0.3) : Color.clear,
                    lineWidth: 2
                )
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3), value: isPressed)
        .onTapGesture {
            if isEarned {
                isPressed = true
                HapticManager.shared.trigger(.light)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }
    }
}

// MARK: - Badge Earned Overlay

struct BadgeEarnedOverlay: View {
    let badge: Badge
    let onDismiss: () -> Void
    
    @State private var showContent = false
    @State private var showBadge = false
    @State private var showText = false
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(spacing: 24) {
                Text("🎉")
                    .font(.system(size: 60))
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.5)
                
                // Badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [badge.color.opacity(0.8), badge.color],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: badge.color.opacity(0.5), radius: 20, x: 0, y: 8)
                    
                    Image(systemName: badge.icon)
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundColor(.white)
                    
                    // Shine
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .clear],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                        .frame(width: 120, height: 120)
                }
                .opacity(showBadge ? 1 : 0)
                .scaleEffect(showBadge ? 1 : 0.3)
                .rotationEffect(.degrees(showBadge ? 0 : -30))
                
                VStack(spacing: 8) {
                    Text("Badge Earned!")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(badge.displayName)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(badge.color)
                    
                    Text(badge.description)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .opacity(showText ? 1 : 0)
                .offset(y: showText ? 0 : 20)
                
                Button(action: onDismiss) {
                    Text("Awesome!")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(badge.color)
                                .shadow(color: badge.color.opacity(0.4), radius: 8, x: 0, y: 4)
                        )
                }
                .opacity(showText ? 1 : 0)
                .padding(.top, 8)
            }
            .padding(32)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                showContent = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3)) {
                showBadge = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
                showText = true
            }
        }
    }
}

#Preview {
    BadgesView()
}

