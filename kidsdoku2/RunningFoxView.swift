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
    let foxFrames = ["fox_running1", "fox_running2", "fox_running3"]
    
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
                    async let frames: () = animateFrames()
                    await runFoxLoop()
                    await frames
                }
        }
    }
    
    private func animateFrames() async {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
            currentFrame = (currentFrame + 1) % foxFrames.count
        }
    }
    
    private func runFoxLoop() async {
        while !Task.isCancelled {
            // 1. Start moving
            withAnimation(.linear(duration: travelDuration)) {
                isRunning = true
            }
            
            // 2. Wait for travel to complete
            try? await Task.sleep(nanoseconds: UInt64(travelDuration * 1_000_000_000))
            
            // 3. Wait 5 seconds
            try? await Task.sleep(nanoseconds: UInt64(pauseDuration * 1_000_000_000))
            
            // 4. Reset position instantly
            withAnimation(.none) {
                isRunning = false
            }
            
            // 5. Small delay to ensure reset is registered before starting next run
            try? await Task.sleep(nanoseconds: 150_000_000) // 0.15s
        }
    }
}

#Preview {
    RunningFoxView()
}
