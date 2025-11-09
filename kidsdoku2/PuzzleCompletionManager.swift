//
//  PuzzleCompletionManager.swift
//  kidsdoku2
//
//  Created to track puzzle completion status
//

import Combine
import Foundation

/// Manages puzzle completion tracking using UserDefaults
class PuzzleCompletionManager: ObservableObject {
    static let shared = PuzzleCompletionManager()
    
    @Published private(set) var completedPuzzles: Set<String> = []
    
    private let userDefaultsKey = "completedPuzzles"
    
    private init() {
        loadCompletedPuzzles()
    }
    
    /// Mark a puzzle as completed
    func markCompleted(puzzle: PremadePuzzle) {
        let key = puzzleKey(size: puzzle.size, difficulty: puzzle.difficulty, number: puzzle.number)
        completedPuzzles.insert(key)
        saveCompletedPuzzles()
    }
    
    /// Check if a puzzle is completed
    func isCompleted(puzzle: PremadePuzzle) -> Bool {
        let key = puzzleKey(size: puzzle.size, difficulty: puzzle.difficulty, number: puzzle.number)
        return completedPuzzles.contains(key)
    }
    
    /// Reset all completion data
    func resetAll() {
        completedPuzzles.removeAll()
        saveCompletedPuzzles()
    }
    
    /// Reset completion data for a specific size
    func resetSize(_ size: Int) {
        completedPuzzles = completedPuzzles.filter { !$0.hasPrefix("\(size)-") }
        saveCompletedPuzzles()
    }
    
    // MARK: - Private Helpers
    
    private func puzzleKey(size: Int, difficulty: PuzzleDifficulty, number: Int) -> String {
        return "\(size)-\(difficulty.rawValue)-\(number)"
    }
    
    private func loadCompletedPuzzles() {
        if let data = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] {
            completedPuzzles = Set(data)
        }
    }
    
    private func saveCompletedPuzzles() {
        UserDefaults.standard.set(Array(completedPuzzles), forKey: userDefaultsKey)
    }
}

