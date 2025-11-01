//
//  ContentView.swift
//  kidsdoku2
//
//  Created by hinan on 30.10.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var path: [KidSudokuRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            MainMenuView(path: $path)
                .navigationDestination(for: KidSudokuRoute.self) { route in
                    switch route {
                    case .game(let size):
                        if let config = KidSudokuConfig.configuration(for: size) {
                            GameView(config: config)
                        } else {
                            Text("Puzzle not available")
                        }
                    case .puzzleSelection(let size):
                        PuzzleSelectionView(size: size, path: $path)
                    case .puzzle(let config, let puzzleData):
                        GameView(config: config, puzzleData: puzzleData)
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
