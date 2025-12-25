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

private enum DeviceType {
    case iPhone
    case iPad
    
    static var current: DeviceType {
        return UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
    }
}

private enum OnboardingTheme {
    static let primaryColor = Color.orange
    static let dotInactive = Color.orange.opacity(0.3)
    static let buttonGradient = LinearGradient(
        colors: [Color.orange, Color.orange.opacity(0.9)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    enum Layout {
        static var horizontalPadding: CGFloat {
            DeviceType.current == .iPad ? 48 : 24
        }
        static var buttonHeight: CGFloat {
            DeviceType.current == .iPad ? 72 : 56
        }
        static var cornerRadius: CGFloat {
            DeviceType.current == .iPad ? 36 : 28
        }
        static var dotSize: CGFloat {
            DeviceType.current == .iPad ? 12 : 8
        }
        static var titleFontSize: CGFloat {
            DeviceType.current == .iPad ? 42 : 28
        }
        static var bodyFontSize: CGFloat {
            DeviceType.current == .iPad ? 20 : 17
        }
        static var contentHorizontalPadding: CGFloat {
            DeviceType.current == .iPad ? 80 : 32
        }
        static var contentBottomPadding: CGFloat {
            DeviceType.current == .iPad ? 120 : 80
        }
        static var bottomControlsHeight: CGFloat {
            DeviceType.current == .iPad ? 220 : 160
        }
        static var controlsSpacing: CGFloat {
            DeviceType.current == .iPad ? 32 : 24
        }
        static var buttonSpacing: CGFloat {
            DeviceType.current == .iPad ? 24 : 16
        }
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
            title: String(localized: "Hey there, Puzzle Champion! 🎉"),
            subtitle: String(localized: "Welcome to KidsDoku. I'm here to show you how easy and fun Sudoku can be."),
            buttonText: String(localized: "Let's Go!")
        ),
        OnboardingPage(
            image: "onboarding_2",
            title: String(localized: "Simple & Fun to Play ✨"),
            subtitle: String(localized: "No math required! Just tap to place the right characters on the grid to solve the puzzle."),
            buttonText: String(localized: "Show Me How")
        ),
        OnboardingPage(
            image: "onboarding_3",
            title: String(localized: "Easy Symbols, Optionally Numbers! ✨"),
            subtitle: String(localized: "Learn faster by using pictures! Start with foxes and frogs, then switch to numbers when you feel like a pro."),
            buttonText: String(localized: "Cool! What's Next?")
        ),
        OnboardingPage(
            image: "onboarding_4",
            title: String(localized: "Watch Your Skills Grow! 🏆"),
            subtitle: String(localized: "Every puzzle makes you smarter. Track your wins and see how fast you improve!"),
            buttonText: String(localized: "Amazing!")
        ),
        OnboardingPage(
            image: "onboarding_5",
            title: String(localized: "Ready, Set, Go! 🚀"),
            subtitle: String(localized: "Join thousands of kids already having fun with puzzles. Your adventure starts now!"),
            buttonText: String(localized: "START NOW! 🐾")
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
                    .font(.system(size: DeviceType.current == .iPad ? 18 : 15, weight: .bold))
                    .foregroundColor(Color(red: 40/255, green: 30/255, blue: 20/255))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule()) // Ensures visibility on any background
                    .padding(.trailing, OnboardingTheme.Layout.horizontalPadding)
                }
                .padding(.top, 10) // Fallback for no safe area, but generally respecting safe area is automatic in ZStack usually
                
                Spacer()
                
                // Bottom Area
                VStack(spacing: OnboardingTheme.Layout.controlsSpacing) {
                    
                    // Page Indicators
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? OnboardingTheme.primaryColor : OnboardingTheme.dotInactive)
                                .frame(width: OnboardingTheme.Layout.dotSize, height: OnboardingTheme.Layout.dotSize)
                                .animation(.spring(), value: currentPage) // Smooth dot transition
                        }
                    }
                    
                    // Navigation Buttons
                    HStack(spacing: OnboardingTheme.Layout.buttonSpacing) {
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
                                .font(.system(size: DeviceType.current == .iPad ? 20 : 17, weight: .semibold))
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
        GeometryReader { geometry in
            ZStack {
                // 1. Background Image
                Image(page.image)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.1)) // Slight dim for text readability
                
                // 2. Content positioned differently for iPad vs iPhone
                if DeviceType.current == .iPad {
                    // iPad: Text at top
                    VStack(spacing: 0) {
                        VStack(spacing: 20) {
                            // Title
                            Text(page.title)
                                .font(.system(size: OnboardingTheme.Layout.titleFontSize, weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 40/255, green: 30/255, blue: 20/255))
                                .padding(.horizontal, OnboardingTheme.Layout.contentHorizontalPadding)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            // Subtitle
                            Text(page.subtitle)
                                .font(.system(size: OnboardingTheme.Layout.bodyFontSize))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 40/255, green: 30/255, blue: 20/255))
                                .padding(.horizontal, OnboardingTheme.Layout.contentHorizontalPadding)
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, geometry.safeAreaInsets.top + 60) // Position at top with safe area
                        
                        Spacer()
                    }
                } else {
                    // iPhone: Text at bottom
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: geometry.size.height * 0.55)
                        
                        VStack(spacing: 16) {
                            // Title
                            Text(page.title)
                                .font(.system(size: OnboardingTheme.Layout.titleFontSize, weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 40/255, green: 30/255, blue: 20/255))
                                .padding(.horizontal, OnboardingTheme.Layout.contentHorizontalPadding)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            // Subtitle
                            Text(page.subtitle)
                                .font(.system(size: OnboardingTheme.Layout.bodyFontSize))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 40/255, green: 30/255, blue: 20/255))
                                .padding(.horizontal, OnboardingTheme.Layout.contentHorizontalPadding)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.bottom, 24)
                        
                        Spacer()
                            .frame(minHeight: OnboardingTheme.Layout.bottomControlsHeight)
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
