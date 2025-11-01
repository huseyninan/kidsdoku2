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
                    case .puzzleSelection(let size):
                        PuzzleSelectionView(size: size, path: $path)
                    
                    case .game(let size, let puzzleId):
                        if let config = KidSudokuConfig.configuration(for: size) {
                            if let puzzleId = puzzleId {
                                // Load predefined puzzle
                                let puzzles = PredefinedPuzzles.puzzles(for: size)
                                if let puzzle = puzzles.first(where: { $0.id == puzzleId }) {
                                    GameView(config: config, predefinedPuzzle: puzzle)
                                } else {
                                    Text("Puzzle not found")
                                }
                            } else {
                                // Generate random puzzle
                                GameView(config: config, predefinedPuzzle: nil)
                            }
                        } else {
                            Text("Puzzle not available")
                        }
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
