//
//  PetalFallView.swift
//  kidsdoku2
//
//  Animated cherry blossom petal fall effect for Spring theme.
//

import SwiftUI
import Combine

// MARK: - Petal Model

private struct Petal: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let opacity: Double
    let speed: Double
    let wobbleAmount: CGFloat
    let wobbleSpeed: Double
    let rotationSpeed: Double
    let type: PetalType

    enum PetalType: CaseIterable {
        case round
        case elongated
        case blossom
    }
}

// MARK: - Configuration Constants

private enum PetalFallConfig {
    static let petalCount = 35
    static let frameRate: Double = 30
    static let frameDuration: TimeInterval = 1.0 / frameRate
    static let offScreenBuffer: CGFloat = 20
    static let sizeRange: ClosedRange<CGFloat> = 6...16
    static let opacityRange: ClosedRange<Double> = 0.45...0.85
    static let speedRange: ClosedRange<Double> = 22...60
    static let wobbleAmountRange: ClosedRange<CGFloat> = 18...45
    static let wobbleSpeedRange: ClosedRange<Double> = 0.5...1.8
    static let rotationSpeedRange: ClosedRange<Double> = 0.4...1.2
}

// MARK: - Petal Fall View

struct PetalFallView: View {
    @State private var petals: [Petal] = []
    @State private var animationTime: Double = 0
    @State private var isAnimating = false
    @State private var timerCancellable: AnyCancellable?

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                for petal in petals {
                    let wobble = sin(animationTime * petal.wobbleSpeed + Double(petal.x) * 0.05) * Double(petal.wobbleAmount)
                    let currentX = petal.x + CGFloat(wobble)
                    let currentY = petal.y

                    context.opacity = petal.opacity

                    let rotation = animationTime * petal.rotationSpeed

                    switch petal.type {
                    case .round:
                        drawRoundPetal(context: &context, x: currentX, y: currentY, size: petal.size, rotation: rotation)
                    case .elongated:
                        drawElongatedPetal(context: &context, x: currentX, y: currentY, size: petal.size, rotation: rotation)
                    case .blossom:
                        drawBlossomPetal(context: &context, x: currentX, y: currentY, size: petal.size, rotation: rotation)
                    }
                }
            }
            .onAppear {
                startAnimation(in: geometry.size)
            }
            .onDisappear {
                stopAnimation()
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Animation Lifecycle

    private func startAnimation(in size: CGSize) {
        guard !isAnimating else { return }
        isAnimating = true
        initializePetals(in: size)

        timerCancellable = Timer.publish(every: PetalFallConfig.frameDuration, on: .main, in: .common)
            .autoconnect()
            .sink { [size] _ in
                updatePetals(in: size)
            }
    }

    private func stopAnimation() {
        isAnimating = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    // MARK: - Petal Drawing

    private func drawRoundPetal(context: inout GraphicsContext, x: CGFloat, y: CGFloat, size: CGFloat, rotation: Double) {
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: x, y: y)
        transform = transform.rotated(by: rotation)

        context.transform = transform

        // Teardrop/oval petal shape
        let path = Path { p in
            let w = size * 0.55
            let h = size * 0.9
            p.move(to: CGPoint(x: 0, y: -h / 2))
            p.addCurve(
                to: CGPoint(x: 0, y: h / 2),
                control1: CGPoint(x: w, y: -h / 4),
                control2: CGPoint(x: w, y: h / 4)
            )
            p.addCurve(
                to: CGPoint(x: 0, y: -h / 2),
                control1: CGPoint(x: -w, y: h / 4),
                control2: CGPoint(x: -w, y: -h / 4)
            )
        }

        // Soft pink fill with lighter center
        context.fill(
            path,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 1.0, green: 0.92, blue: 0.94),
                    Color(red: 0.98, green: 0.76, blue: 0.84)
                ]),
                startPoint: CGPoint(x: 0, y: -size / 2),
                endPoint: CGPoint(x: 0, y: size / 2)
            )
        )

        context.transform = .identity
    }

    private func drawElongatedPetal(context: inout GraphicsContext, x: CGFloat, y: CGFloat, size: CGFloat, rotation: Double) {
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: x, y: y)
        transform = transform.rotated(by: rotation)

        context.transform = transform

        let path = Path { p in
            let w = size * 0.30
            let h = size * 1.1
            p.move(to: CGPoint(x: 0, y: -h / 2))
            p.addCurve(
                to: CGPoint(x: 0, y: h / 2),
                control1: CGPoint(x: w, y: -h / 6),
                control2: CGPoint(x: w * 0.8, y: h / 3)
            )
            p.addCurve(
                to: CGPoint(x: 0, y: -h / 2),
                control1: CGPoint(x: -w * 0.8, y: h / 3),
                control2: CGPoint(x: -w, y: -h / 6)
            )
        }

        context.fill(
            path,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 1.0, green: 0.88, blue: 0.92),
                    Color(red: 0.96, green: 0.72, blue: 0.80)
                ]),
                startPoint: CGPoint(x: 0, y: -size / 2),
                endPoint: CGPoint(x: 0, y: size / 2)
            )
        )

        context.transform = .identity
    }

    private func drawBlossomPetal(context: inout GraphicsContext, x: CGFloat, y: CGFloat, size: CGFloat, rotation: Double) {
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: x, y: y)
        transform = transform.rotated(by: rotation)

        context.transform = transform

        // 5-petal tiny blossom
        let petalCount = 5
        let outerR: CGFloat = size * 0.48
        let innerR: CGFloat = size * 0.18

        let path = Path { p in
            let petalCountDouble = Double(petalCount)
            // Start at the valley just before petal 0 so each iteration
            // draws cleanly: prevValley → tip → nextValley with no backtracking.
            let startAngle = -.pi / 2 - .pi / petalCountDouble
            p.move(to: CGPoint(x: CGFloat(cos(startAngle)) * innerR,
                               y: CGFloat(sin(startAngle)) * innerR))

            for i in 0..<petalCount {
                let angle = Double(i) * (2 * .pi / petalCountDouble) - .pi / 2
                let nextAngle = angle + .pi / petalCountDouble

                let c1X = CGFloat(cos(angle - 0.4)) * outerR * 0.85
                let c1Y = CGFloat(sin(angle - 0.4)) * outerR * 0.85
                let c2X = CGFloat(cos(angle + 0.4)) * outerR * 0.85
                let c2Y = CGFloat(sin(angle + 0.4)) * outerR * 0.85

                // Curve outward to the petal tip
                p.addCurve(
                    to: CGPoint(x: CGFloat(cos(angle)) * outerR,
                                y: CGFloat(sin(angle)) * outerR),
                    control1: CGPoint(x: c1X, y: c1Y),
                    control2: CGPoint(x: c1X, y: c1Y)
                )

                // Curve inward to the next valley
                p.addCurve(
                    to: CGPoint(x: CGFloat(cos(nextAngle)) * innerR,
                                y: CGFloat(sin(nextAngle)) * innerR),
                    control1: CGPoint(x: c2X, y: c2Y),
                    control2: CGPoint(x: c2X, y: c2Y)
                )
            }
            p.closeSubpath()
        }

        let fillColor = Color(red: 1.0, green: 0.86, blue: 0.91)
        context.fill(path, with: .color(fillColor))

        // Small yellow center dot
        let centerSize: CGFloat = size * 0.18
        let centerRect = CGRect(x: -centerSize / 2, y: -centerSize / 2, width: centerSize, height: centerSize)
        let centerPath = Circle().path(in: centerRect)
        let centerColor = Color(red: 1.0, green: 0.90, blue: 0.55)
        context.fill(centerPath, with: .color(centerColor))

        context.transform = .identity
    }

    // MARK: - Animation Logic

    private func initializePetals(in size: CGSize) {
        petals = (0..<PetalFallConfig.petalCount).map { _ in
            createPetal(in: size, startAtTop: false)
        }
    }

    private func createPetal(in size: CGSize, startAtTop: Bool) -> Petal {
        Petal(
            x: CGFloat.random(in: 0...size.width),
            y: startAtTop ? -PetalFallConfig.offScreenBuffer : CGFloat.random(in: -PetalFallConfig.offScreenBuffer...size.height),
            size: CGFloat.random(in: PetalFallConfig.sizeRange),
            opacity: Double.random(in: PetalFallConfig.opacityRange),
            speed: Double.random(in: PetalFallConfig.speedRange),
            wobbleAmount: CGFloat.random(in: PetalFallConfig.wobbleAmountRange),
            wobbleSpeed: Double.random(in: PetalFallConfig.wobbleSpeedRange),
            rotationSpeed: Double.random(in: PetalFallConfig.rotationSpeedRange) * (Bool.random() ? 1 : -1),
            type: Petal.PetalType.allCases.randomElement() ?? .round
        )
    }

    private func updatePetals(in size: CGSize) {
        animationTime += PetalFallConfig.frameDuration

        for i in petals.indices {
            petals[i].y += CGFloat(petals[i].speed * PetalFallConfig.frameDuration)

            if petals[i].y > size.height + PetalFallConfig.offScreenBuffer {
                petals[i] = createPetal(in: size, startAtTop: true)
            }
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.94, green: 0.90, blue: 0.95)
        PetalFallView()
    }
}
