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
                    case .catalog(let size):
                        if let config = KidSudokuConfig.configuration(for: size) {
                            PuzzleSelectionView(size: size, path: $path)
                                .navigationTitle("Select Puzzle")
                        } else {
                            Text("Puzzle size not available")
                        }
                    case .game(let size):
                        if let config = KidSudokuConfig.configuration(for: size) {
                            GameView(config: config)
                        } else {
                            Text("Puzzle not available")
                        }
                    case .gameSeed(let size, let seed):
                        if let config = KidSudokuConfig.configuration(for: size) {
                            GameView(config: config, seed: seed)
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
