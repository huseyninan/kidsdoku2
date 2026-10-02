//
//  SnowfallView.swift
//  kidsdoku2
//
//  Beautiful animated snowfall effect for Christmas theme.
//

import SwiftUI

// MARK: - Snowflake Model

private struct Snowflake {
    /// Horizontal position as a fraction of the view width, so resizes are handled.
    let xFraction: Double
    /// Initial progress through one fall cycle (0...1).
    let startOffset: Double
    let size: CGFloat
    let opacity: Double
    let speed: Double
    let wobbleAmount: CGFloat
    let wobbleSpeed: Double
    let rotationSpeed: Double
    let type: SnowflakeType
    
    enum SnowflakeType: CaseIterable {
        case circle
        case star
        case crystal
    }
}

// MARK: - Configuration Constants

private enum SnowfallConfig {
    static let snowflakeCount = 30
    static let frameRate: Double = 15
    static let frameDuration: TimeInterval = 1.0 / frameRate
    static let offScreenBuffer: CGFloat = 20
    static let respawnShift: Double = 0.618034
    static let sizeRange: ClosedRange<CGFloat> = 4...12
    static let opacityRange: ClosedRange<Double> = 0.4...0.9
    // Points per second
    static let speedRange: ClosedRange<Double> = 60...160
    static let wobbleAmountRange: ClosedRange<CGFloat> = 10...30
    static let wobbleSpeedRange: ClosedRange<Double> = 1...3
    static let rotationSpeedRange: ClosedRange<Double> = 0.3...1.5
}

// MARK: - Snowfall View

struct SnowfallView: View {
    /// Generated once and shared; positions are derived from time, so no per-frame state.
    private static let snowflakes: [Snowflake] = (0..<SnowfallConfig.snowflakeCount).map { _ in
        Snowflake(
            xFraction: Double.random(in: 0...1),
            startOffset: Double.random(in: 0...1),
            size: CGFloat.random(in: SnowfallConfig.sizeRange),
            opacity: Double.random(in: SnowfallConfig.opacityRange),
            speed: Double.random(in: SnowfallConfig.speedRange),
            wobbleAmount: CGFloat.random(in: SnowfallConfig.wobbleAmountRange),
            wobbleSpeed: Double.random(in: SnowfallConfig.wobbleSpeedRange),
            rotationSpeed: Double.random(in: SnowfallConfig.rotationSpeedRange),
            type: Snowflake.SnowflakeType.allCases.randomElement() ?? .circle
        )
    }
    
    var body: some View {
        // TimelineView redraws only the Canvas at the capped frame rate and pauses
        // automatically when the view is off screen or the app is in the background.
        TimelineView(.animation(minimumInterval: SnowfallConfig.frameDuration)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let travel = Double(size.height + SnowfallConfig.offScreenBuffer * 2)
                guard travel > 0 else { return }
                
                for flake in Self.snowflakes {
                    let distance = flake.startOffset * travel + flake.speed * time
                    let cycle = (distance / travel).rounded(.down)
                    let currentY = CGFloat(distance - cycle * travel) - SnowfallConfig.offScreenBuffer
                    // Shift each new pass horizontally so a respawned flake doesn't reuse its column.
                    let xFraction = (flake.xFraction + cycle * SnowfallConfig.respawnShift).truncatingRemainder(dividingBy: 1)
                    let baseX = CGFloat(xFraction) * size.width
                    let wobble = sin(time * flake.wobbleSpeed + Double(baseX)) * Double(flake.wobbleAmount)
                    let currentX = baseX + CGFloat(wobble)
                    
                    context.opacity = flake.opacity
                    
                    switch flake.type {
                    case .circle:
                        drawCircleSnowflake(context: &context, x: currentX, y: currentY, size: flake.size)
                    case .star:
                        drawStarSnowflake(context: &context, x: currentX, y: currentY, size: flake.size, rotation: time * flake.rotationSpeed)
                    case .crystal:
                        drawCrystalSnowflake(context: &context, x: currentX, y: currentY, size: flake.size, rotation: time * flake.rotationSpeed)
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    // MARK: - Snowflake Drawing
    
    private func drawCircleSnowflake(context: inout GraphicsContext, x: CGFloat, y: CGFloat, size: CGFloat) {
        let rect = CGRect(x: x - size/2, y: y - size/2, width: size, height: size)
        
        // Outer glow
        context.fill(
            Circle().path(in: rect.insetBy(dx: -2, dy: -2)),
            with: .color(.white.opacity(0.3))
        )
        
        // Main snowflake
        context.fill(
            Circle().path(in: rect),
            with: .linearGradient(
                Gradient(colors: [.white, Color(white: 0.95)]),
                startPoint: CGPoint(x: rect.minX, y: rect.minY),
                endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
            )
        )
    }
    
    private func drawStarSnowflake(context: inout GraphicsContext, x: CGFloat, y: CGFloat, size: CGFloat, rotation: Double) {
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: x, y: y)
        transform = transform.rotated(by: rotation)
        
        context.transform = transform
        
        // Draw 6-pointed star
        let path = Path { p in
            let points = 6
            let innerRadius = size * 0.3
            let outerRadius = size * 0.5
            
            for i in 0..<points * 2 {
                let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
                let angle = Double(i) * .pi / Double(points) - .pi / 2
                let px = cos(angle) * radius
                let py = sin(angle) * radius
                
                if i == 0 {
                    p.move(to: CGPoint(x: px, y: py))
                } else {
                    p.addLine(to: CGPoint(x: px, y: py))
                }
            }
            p.closeSubpath()
        }
        
        context.fill(path, with: .color(.white))
        context.transform = .identity
    }
    
    private func drawCrystalSnowflake(context: inout GraphicsContext, x: CGFloat, y: CGFloat, size: CGFloat, rotation: Double) {
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: x, y: y)
        transform = transform.rotated(by: rotation)
        
        context.transform = transform
        
        // Draw 6 crystal arms
        let path = Path { p in
            for i in 0..<6 {
                let angle = Double(i) * .pi / 3
                let endX = cos(angle) * size * 0.5
                let endY = sin(angle) * size * 0.5
                
                // Main arm
                p.move(to: .zero)
                p.addLine(to: CGPoint(x: endX, y: endY))
                
                // Small branches
                let branchLength = size * 0.15
                let branchPoint = 0.6
                let midX = endX * branchPoint
                let midY = endY * branchPoint
                
                let perpAngle1 = angle + .pi / 3
                let perpAngle2 = angle - .pi / 3
                
                p.move(to: CGPoint(x: midX, y: midY))
                p.addLine(to: CGPoint(x: midX + cos(perpAngle1) * branchLength, y: midY + sin(perpAngle1) * branchLength))
                
                p.move(to: CGPoint(x: midX, y: midY))
                p.addLine(to: CGPoint(x: midX + cos(perpAngle2) * branchLength, y: midY + sin(perpAngle2) * branchLength))
            }
        }
        
        context.stroke(path, with: .color(.white), lineWidth: size * 0.08)
        
        // Center dot
        let centerSize = size * 0.12
        context.fill(
            Circle().path(in: CGRect(x: -centerSize/2, y: -centerSize/2, width: centerSize, height: centerSize)),
            with: .color(.white)
        )
        
        context.transform = .identity
    }
}

#Preview {
    ZStack {
        Color.blue.opacity(0.3)
        SnowfallView()
    }
}

