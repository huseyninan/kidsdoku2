//
//  OnboardingView.swift
//  kidsdoku2
//
//  Created by hinan on 17.12.2025.
//

import SwiftUI

struct OnboardingPage {
    let image: String
    let title: String
    let subtitle: String
    let buttonText: String
}

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0
    
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
        ZStack {
            // Background image - full screen
            Image(pages[currentPage].image)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        withAnimation {
                            hasSeenOnboarding = true
                        }
                    }
                    .foregroundColor(.gray)
                    .padding(.horizontal, 24)
                    .padding(.top, 46)
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.orange : Color.orange.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 24)
                
                // Navigation buttons
                HStack(spacing: 16) {
                    // Back button
                    if currentPage > 0 {
                        Button {
                            withAnimation {
                                currentPage -= 1
                            }
                        } label: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: "chevron.left")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                )
                        }
                    } else {
                        Spacer()
                            .frame(width: 56)
                    }
                    
                    // Main action button
                    Button {
                        withAnimation {
                            if currentPage < pages.count - 1 {
                                currentPage += 1
                            } else {
                                hasSeenOnboarding = true
                            }
                        }
                    } label: {
                        Text(pages[currentPage].buttonText)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color.orange, Color.orange.opacity(0.9)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(28)
                            .shadow(color: Color.orange.opacity(0.3), radius: 8, y: 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 80)
            }
        }
    }
    
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Title
            Text(page.title)
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal, 32)
            
            // Subtitle
            Text(page.subtitle)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
                .lineSpacing(4)
            
            Spacer()
                .frame(height: 60)
        }
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
