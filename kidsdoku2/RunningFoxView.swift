//
//  RunningFoxView.swift
//  kidsdoku2
//
//  Created by hinan on 23.11.2025.
//

import SwiftUI

struct RunningFoxView: View {
    @State private var isRunning = false
    @State private var currentFrame = 0
    let foxFrames = ["fox_running1", "fox_running2", "fox_running3", "fox_running4"]
    
    private let travelDuration: Double = 8.0
    private let pauseDuration: Double = 5.0
    
    var body: some View {
        GeometryReader { geometry in
            Image(foxFrames[currentFrame])
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
                .offset(x: isRunning ? geometry.size.width + 300 : -300)
                .task {
                    await runFoxLoop()
                }
        }
    }
    
    private func runFoxLoop() async {
        while !Task.isCancelled {
            do {
                // 1. Start moving and begin frame animation
                withAnimation(.linear(duration: travelDuration)) {
                    isRunning = true
                }
                
                // 2. Animate frames only while fox is travelling across screen
                let frameInterval: UInt64 = 100_000_000 // 0.1s = 10 FPS
                let travelNano = UInt64(travelDuration * 1_000_000_000)
                let frameCount = Int(travelDuration / 0.1)
                for _ in 0..<frameCount {
                    guard !Task.isCancelled else { return }
                    try await Task.sleep(nanoseconds: frameInterval)
                    currentFrame = (currentFrame + 1) % foxFrames.count
                }
                
                // 3. Fox is off screen — pause without any frame updates
                try await Task.sleep(nanoseconds: UInt64(pauseDuration * 1_000_000_000))
                
                // 4. Reset position instantly before next run
                withAnimation(.none) {
                    isRunning = false
                }
                
                // 5. Small delay to ensure reset is registered before starting next run
                try await Task.sleep(nanoseconds: 150_000_000) // 0.15s
            } catch {
                break  // Task cancelled
            }
        }
    }
}

#Preview {
    RunningFoxView()
}
