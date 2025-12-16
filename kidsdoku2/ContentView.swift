//
//  ContentView.swift
//  kidsdoku2
//
//  Created by hinan on 30.10.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var path: [KidSudokuRoute] = []
    @Binding var deepLinkProduct: String?
    @EnvironmentObject var appEnvironment: AppEnvironment

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
                    case .premadePuzzle(let puzzle):
                        GameView(config: puzzle.config, premadePuzzle: puzzle)
                    case .settings:
                        SettingsView()
                    }
                }
                .onChange(of: deepLinkProduct) { _, newValue in
                    handleDeepLink(newValue)
                }
                .onAppear {
                    handleDeepLink(deepLinkProduct)
                }
        }
    }
    
    private func handleDeepLink(_ product: String?) {
        guard let product = product else { return }
        
        if product == "christmas" {
            appEnvironment.setTheme(.christmas)
            path = [.puzzleSelection(size: 4)]
        }
        
        deepLinkProduct = nil
    }
}

#Preview {
    ContentView(deepLinkProduct: .constant(nil))
        .environmentObject(AppEnvironment())
}
