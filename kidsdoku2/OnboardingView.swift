//
//  OnboardingView.swift
//  kidsdoku2
//
//  Created by hinan on 17.12.2025.
//

import SwiftUI

// MARK: - Models

struct OnboardingPage: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let subtitle: String
    let buttonText: String
}

// MARK: - Constants & Theme

private enum OnboardingTheme {
    static let primaryColor = Color.orange
    static let dotInactive = Color.orange.opacity(0.3)
    static let buttonGradient = LinearGradient(
        colors: [Color.orange, Color.orange.opacity(0.9)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    enum Layout {
        static let horizontalPadding: CGFloat = 24
        static let buttonHeight: CGFloat = 56
        static let cornerRadius: CGFloat = 28
    }
}

// MARK: - Main View

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0
    
    // Using a reliable data source
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "onboarding_1",
            title: "Hey there, Puzzle Champion! 🎉",
            subtitle: "Welcome to KidsDoku. I'm here to show you how easy and fun Sudoku can be.",
            buttonText: "Let's Go!"
        ),
        OnboardingPage(
            image: "onboarding_2",
            title: "Simple & Fun to Play ✨",
            subtitle: "No math required! Just tap to place the right characters on the grid to solve the puzzle.",
            buttonText: "Show Me How"
        ),
        OnboardingPage(
            image: "onboarding_3",
            title: "Easy Symbols, Optionally Numbers! ✨",
            subtitle: "Learn faster by using pictures! Start with foxes and frogs, then switch to numbers when you feel like a pro.",
            buttonText: "Cool! What's Next?"
        ),
        OnboardingPage(
            image: "onboarding_4",
            title: "Watch Your Skills Grow! 🏆",
            subtitle: "Every puzzle makes you smarter. Track your wins and see how fast you improve!",
            buttonText: "Amazing!"
        ),
        OnboardingPage(
            image: "onboarding_5",
            title: "Ready, Set, Go! 🚀",
            subtitle: "Join thousands of kids already having fun with puzzles. Your adventure starts now!",
            buttonText: "START NOW! 🐾"
        )
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: Page Content
            // We move the image INSIDE the tab view content so it slides with the text.
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                    // Ensure the full page area is touchable/swipable
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea() // Allows images to stretch full screen
            
            // MARK: Overlay Controls (Skip, Dots, Buttons)
            VStack(spacing: 0) {
                // Top "Skip" Button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(.subheadline.bold()) // Better readability
                    .foregroundColor(.white)   // White often contrasts better on full screen generic images, or use a background capsule
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule()) // Ensures visibility on any background
                    .padding(.trailing, OnboardingTheme.Layout.horizontalPadding)
                }
                .padding(.top, 10) // Fallback for no safe area, but generally respecting safe area is automatic in ZStack usually
                
                Spacer()
                
                // Bottom Area
                VStack(spacing: 24) {
                    
                    // Page Indicators
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? OnboardingTheme.primaryColor : OnboardingTheme.dotInactive)
                                .frame(width: 8, height: 8)
                                .animation(.spring(), value: currentPage) // Smooth dot transition
                        }
                    }
                    
                    // Navigation Buttons
                    HStack(spacing: 16) {
                        // Back Button
                        if currentPage > 0 {
                            Button {
                                changePage(by: -1)
                            } label: {
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: OnboardingTheme.Layout.buttonHeight, height: OnboardingTheme.Layout.buttonHeight)
                                    .overlay(
                                        Image(systemName: "chevron.left")
                                            .font(.title3.bold())
                                            .foregroundColor(.gray)
                                    )
                                    .shadow(radius: 5)
                            }
                            .transition(.scale.combined(with: .opacity))
                        } else {
                            // Spacer to keep layout consistent
                            Spacer()
                                .frame(width: OnboardingTheme.Layout.buttonHeight)
                        }
                        
                        // Main Action Button (Next / Finish)
                        Button {
                            handleNextButton()
                        } label: {
                            Text(pages[currentPage].buttonText)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: OnboardingTheme.Layout.buttonHeight)
                                .background(OnboardingTheme.buttonGradient)
                                .cornerRadius(OnboardingTheme.Layout.cornerRadius)
                                .shadow(color: OnboardingTheme.primaryColor.opacity(0.3), radius: 8, y: 4)
                        }
                        .id("MainButton_\(currentPage)") // Triggers a slight rebuild/animation if needed, or simply helps identifying views
                    }
                }
                .padding(.horizontal, OnboardingTheme.Layout.horizontalPadding)
                .padding(.bottom, 20) // Bottom safe area padding usually handled, but this adds breathing room
            }
        }
    }
    
    // MARK: - Helpers
    
    private func changePage(by value: Int) {
        withAnimation {
            currentPage += value
        }
    }
    
    private func handleNextButton() {
        withAnimation {
            if currentPage < pages.count - 1 {
                currentPage += 1
            } else {
                completeOnboarding()
            }
        }
    }
    
    private func completeOnboarding() {
        withAnimation {
            hasSeenOnboarding = true
        }
    }
}

// MARK: - Page View Component

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        ZStack {
            // 1. Background Image
            Image(page.image)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.1)) // Slight dim for text readability
            
            // 2. Content
            VStack(spacing: 24) {
                Spacer()
                
                // Title
                Text(page.title)
                    .font(.system(size: 28, weight: .bold)) // Consider converting to relative size for Dynamic Type
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white) // White usually looks better on full screen photos
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1) // Shadow for readability
                    .padding(.horizontal, 32)
                
                // Subtitle
                Text(page.subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 40)
                    .padding(.bottom, 80)
                    .lineSpacing(4)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    
                // Spacer for the bottom controls area
                Spacer()
                    .frame(height: 160) // Reserve space for buttons/dots
            }
        }
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
