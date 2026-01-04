import SwiftUI

// MARK: - Tutorial Step Definition
enum GameTutorialStep: Int, CaseIterable {
    case selectFirstSymbol = 0
    case placeFirstSymbol = 1
    case selectSecondSymbol = 2
    case placeSecondSymbol = 3
    
    var foxMessage: String {
        switch self {
        case .selectFirstSymbol:
            return String(localized: "Ready for an adventure? Pick a magic symbol from Safari Camp to start the quest!")
        case .placeFirstSymbol:
            return String(localized: "Great! Now, tap the empty box in the grid to place it.")
        case .selectSecondSymbol:
            return String(localized: "Awesome! Let's pick a different friend for the next box.")
        case .placeSecondSymbol:
            return String(localized: "You are pro! Place it in last empty spot to complete your first puzzle!")
        }
    }
    
    var focusArea: TutorialFocusArea {
        switch self {
        case .selectFirstSymbol:
            return .paletteItem(index: 1)
        case .placeFirstSymbol:
            return .gridCell(row: 0, col: 0)
        case .selectSecondSymbol:
            return .paletteItem(index: 3)
        case .placeSecondSymbol:
            return .gridCell(row: 1, col: 0)
        }
    }
}

enum TutorialFocusArea: Hashable {
    case paletteItem(index: Int)
    case gridCell(row: Int, col: Int)
}

// MARK: - Tutorial State Manager
@Observable
class GameTutorialManager {
    var isActive: Bool = false
    var currentStep: GameTutorialStep = .selectFirstSymbol
    var focusFrames: [TutorialFocusArea: CGRect] = [:]
    
    func start() {
        isActive = true
        currentStep = .selectFirstSymbol
    }
    
    func advanceToNextStep() {
        guard let nextStep = GameTutorialStep(rawValue: currentStep.rawValue + 1) else {
            complete()
            return
        }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = nextStep
        }
    }
    
    func complete() {
        withAnimation(.easeOut(duration: 0.3)) {
            isActive = false
        }
    }
    
    func registerFrame(_ frame: CGRect, for area: TutorialFocusArea) {
        focusFrames[area] = frame
    }
    
    func shouldHighlight(_ area: TutorialFocusArea) -> Bool {
        guard isActive else { return false }
        return currentStep.focusArea == area
    }
    
    func handleTap(on area: TutorialFocusArea) -> Bool {
        guard isActive, currentStep.focusArea == area else { return false }
        return true
    }
}

// MARK: - Tutorial Overlay View
struct GameTutorialOverlayView: View {
    let tutorialManager: GameTutorialManager
    let onDismiss: () -> Void
    
    @State private var foxBounce = false
    @State private var speechBubbleScale: CGFloat = 0
    
    // Cache the focus frame to avoid repeated dictionary lookups
    private var currentFocusFrame: CGRect {
        tutorialManager.focusFrames[tutorialManager.currentStep.focusArea] ?? .zero
    }
    
    var body: some View {
        let focusFrame = currentFocusFrame // Capture once per body evaluation
        
        GeometryReader { geometry in
            ZStack {
                // Dimming layer with hole punch
                DimmingOverlayWithCutout(
                    cutoutFrame: focusFrame,
                    screenSize: geometry.size
                )
                .allowsHitTesting(false)
                
                // Fox guide with speech bubble
                FoxGuideView(
                    message: tutorialManager.currentStep.foxMessage,
                    foxBounce: foxBounce,
                    speechBubbleScale: speechBubbleScale,
                    position: foxPosition(for: geometry.size)
                )
                .allowsHitTesting(false)
                
                // Skip button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: onDismiss) {
                            HStack(spacing: 4) {
                                Text("Close")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                            }
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.5))
                            )
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 16)
                    }
                    Spacer()
                }
                
                // Step indicator
                VStack {
                    Spacer()
                    StepIndicatorView(
                        currentStep: tutorialManager.currentStep.rawValue,
                        totalSteps: GameTutorialStep.allCases.count
                    )
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2)) {
                speechBubbleScale = 1
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                foxBounce = true
            }
        }
        .onChange(of: tutorialManager.currentStep) { _, _ in
            // Use animation context for both reset and restore to avoid jarring jumps
            withAnimation(.easeOut(duration: 0.1)) {
                speechBubbleScale = 0.8
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.15)) {
                speechBubbleScale = 1
            }
        }
    }
    
    private func foxPosition(for screenSize: CGSize) -> CGPoint {
        let focusFrame = currentFocusFrame
        
        // Position fox on the opposite side of the focus area
        let foxY: CGFloat
        let foxX: CGFloat
        
        if focusFrame.midY > screenSize.height / 2 {
            // Focus is in bottom half, put fox at top
            foxY = min(focusFrame.minY - 120, screenSize.height * 0.25)
        } else {
            // Focus is in top half, put fox at bottom
            foxY = max(focusFrame.maxY + 80, screenSize.height * 0.7)
        }
        
        // Center horizontally with slight offset
        foxX = screenSize.width * 0.5
        
        return CGPoint(x: foxX, y: foxY)
    }
}

// MARK: - Dimming Overlay with Cutout
struct DimmingOverlayWithCutout: View {
    let cutoutFrame: CGRect
    let screenSize: CGSize
    
    var body: some View {
        Canvas { context, size in
            // Fill entire screen with dim color
            let fullRect = CGRect(origin: .zero, size: size)
            context.fill(Path(fullRect), with: .color(.black.opacity(0.6)))
            
            // Cut out the focus area
            if cutoutFrame != .zero {
                let padding: CGFloat = 8
                let cornerRadius: CGFloat = 12
                let cutoutRect = cutoutFrame.insetBy(dx: -padding, dy: -padding)
                let cutoutPath = Path(roundedRect: cutoutRect, cornerRadius: cornerRadius)
                context.blendMode = .destinationOut
                context.fill(cutoutPath, with: .color(.white))
            }
        }
        .drawingGroup() // GPU rasterization for better performance
        .compositingGroup()
        .ignoresSafeArea()
    }
}

// MARK: - Fox Guide View
struct FoxGuideView: View {
    let message: String
    let foxBounce: Bool
    let speechBubbleScale: CGFloat
    let position: CGPoint
    
    var body: some View {
        VStack(spacing: 8) {
            // Speech bubble
            SpeechBubbleView(message: message)
                .scaleEffect(speechBubbleScale)
            
            // Fox character
            Image("bulb_fox")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .scaleEffect(x: -1, y: 1) // Flip to face right
                .offset(y: foxBounce ? -5 : 5)
        }
        .position(position)
    }
}

// MARK: - Speech Bubble View
struct SpeechBubbleView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 0) {
            Text(message)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                )
            
            // Speech bubble tail (shadow removed to reduce render passes)
            Triangle()
                .fill(Color.white)
                .frame(width: 20, height: 12)
                .offset(y: -1)
        }
        .frame(maxWidth: 280)
    }
}

// MARK: - Triangle Shape for Speech Bubble
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX - rect.width/2, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + rect.width/2, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Step Indicator View
struct StepIndicatorView: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Circle()
                    .fill(step == currentStep ? Color.orange : Color.white.opacity(0.5))
                    .frame(width: step == currentStep ? 12 : 8, height: step == currentStep ? 12 : 8)
            }
        }
        // Move animation outside ForEach for better performance
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.4))
        )
    }
}

// MARK: - Focus Highlight Ring
struct TutorialFocusRing: View {
    let isActive: Bool
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.8
    
    var body: some View {
        ZStack {
            if isActive {
                // Outer pulsing ring
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange, lineWidth: 3)
                    .scaleEffect(pulseScale)
                    .opacity(pulseOpacity)
                
                // Inner solid ring
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.orange, lineWidth: 2)
            }
        }
        .onChange(of: isActive, initial: true) { _, newValue in
            if newValue {
                // Start pulsing animation
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    pulseScale = 1.15
                    pulseOpacity = 0.4
                }
            } else {
                // Reset animation state
                pulseScale = 1.0
                pulseOpacity = 0.8
            }
        }
    }
}

// MARK: - Preference Key for Frame Reporting
struct TutorialFramePreferenceKey: PreferenceKey {
    static var defaultValue: [TutorialFocusArea: CGRect] = [:]
    
    static func reduce(value: inout [TutorialFocusArea: CGRect], nextValue: () -> [TutorialFocusArea: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

// MARK: - View Modifier for Tutorial Focus
struct TutorialFocusModifier: ViewModifier {
    let area: TutorialFocusArea
    let tutorialManager: GameTutorialManager
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: TutorialFramePreferenceKey.self,
                            value: [area: geometry.frame(in: .global)]
                        )
                }
            )
            .overlay(
                TutorialFocusRing(isActive: tutorialManager.shouldHighlight(area))
                    .padding(-4)
            )
    }
}

extension View {
    func tutorialFocus(_ area: TutorialFocusArea, manager: GameTutorialManager) -> some View {
        modifier(TutorialFocusModifier(area: area, tutorialManager: manager))
    }
}

#Preview {
    let manager = GameTutorialManager()
    manager.isActive = true
    return GameTutorialOverlayView(tutorialManager: manager, onDismiss: {})
}
