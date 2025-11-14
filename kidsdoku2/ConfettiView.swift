import SwiftUI

struct ConfettiView: View {
    @State private var animate = false
    let particleCount: Int = 150
    
    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { index in
                ConfettiParticle(animate: animate)
                    .offset(x: CGFloat.random(in: -150...150))
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiParticle: View {
    let animate: Bool
    
    @State private var yOffset: CGFloat = 400
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.3
    
    let peakY: CGFloat = CGFloat.random(in: -300...(-100))
    let finalY: CGFloat = CGFloat.random(in: 800...1000)
    let finalX: CGFloat = CGFloat.random(in: -200...200)
    let rotations: Double = Double.random(in: 2...5)
    let upDuration: Double = Double.random(in: 0.6...0.9)
    let downDuration: Double = Double.random(in: 2.0...3.0)
    let delay: Double = Double.random(in: 0...0.5)
    let size: CGFloat = CGFloat.random(in: 20...40)
    let starType: Int = Int.random(in: 0...2)
    
    var starColor: Color {
        switch starType {
        case 0: return .yellow
        case 1: return .orange
        default: return Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
        }
    }
    
    var body: some View {
        Image(systemName: "star.fill")
            .font(.system(size: size))
            .foregroundColor(starColor)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(x: xOffset, y: yOffset)
            .shadow(color: starColor.opacity(0.6), radius: 4)
            .onChange(of: animate) { newValue in
                if newValue {
                    // First phase: shoot up
                    withAnimation(
                        .easeOut(duration: upDuration)
                        .delay(delay)
                    ) {
                        yOffset = peakY
                        xOffset = finalX * 0.3
                        opacity = 1
                        scale = 1
                        rotation = 180 * rotations * 0.3
                    }
                    
                    // Second phase: fall down
                    withAnimation(
                        .easeIn(duration: downDuration)
                        .delay(delay + upDuration)
                    ) {
                        yOffset = finalY
                        xOffset = finalX
                        rotation = 360 * rotations
                        opacity = 0
                        scale = 0.3
                    }
                }
            }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
        ConfettiView()
    }
}

