//
//  SnowfallView.swift
//  kidsdoku2
//
//  Beautiful animated snowfall effect for Christmas theme.
//

import SwiftUI
import Combine

// MARK: - Snowflake Model

private struct Snowflake: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
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

// MARK: - Snowfall View

struct SnowfallView: View {
    @State private var snowflakes: [Snowflake] = []
    @State private var animationTime: Double = 0
    
    private let snowflakeCount = 50
    private let timer = Timer.publish(every: 1/30, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                for flake in snowflakes {
                    let wobble = sin(animationTime * flake.wobbleSpeed + Double(flake.x)) * Double(flake.wobbleAmount)
                    let currentX = flake.x + CGFloat(wobble)
                    let currentY = flake.y
                    
                    context.opacity = flake.opacity
                    
                    switch flake.type {
                    case .circle:
                        drawCircleSnowflake(context: &context, x: currentX, y: currentY, size: flake.size)
                    case .star:
                        drawStarSnowflake(context: &context, x: currentX, y: currentY, size: flake.size, rotation: animationTime * flake.rotationSpeed)
                    case .crystal:
                        drawCrystalSnowflake(context: &context, x: currentX, y: currentY, size: flake.size, rotation: animationTime * flake.rotationSpeed)
                    }
                }
            }
            .onAppear {
                initializeSnowflakes(in: geometry.size)
            }
            .onReceive(timer) { _ in
                updateSnowflakes(in: geometry.size)
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
    
    // MARK: - Animation Logic
    
    private func initializeSnowflakes(in size: CGSize) {
        snowflakes = (0..<snowflakeCount).map { _ in
            createSnowflake(in: size, startAtTop: false)
        }
    }
    
    private func createSnowflake(in size: CGSize, startAtTop: Bool) -> Snowflake {
        let flakeSize = CGFloat.random(in: 4...12)
        return Snowflake(
            x: CGFloat.random(in: 0...size.width),
            y: startAtTop ? -20 : CGFloat.random(in: -20...size.height),
            size: flakeSize,
            opacity: Double.random(in: 0.4...0.9),
            speed: Double.random(in: 30...80),
            wobbleAmount: CGFloat.random(in: 10...30),
            wobbleSpeed: Double.random(in: 1...3),
            rotationSpeed: Double.random(in: 0.3...1.5),
            type: Snowflake.SnowflakeType.allCases.randomElement() ?? .circle
        )
    }
    
    private func updateSnowflakes(in size: CGSize) {
        animationTime += 1/30
        
        for i in snowflakes.indices {
            snowflakes[i].y += CGFloat(snowflakes[i].speed / 30)
            
            // Reset snowflake when it goes off screen
            if snowflakes[i].y > size.height + 20 {
                snowflakes[i] = createSnowflake(in: size, startAtTop: true)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.blue.opacity(0.3)
        SnowfallView()
    }
}

