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
    @Published private(set) var puzzleRatings: [String: Double] = [:]
    
    private let userDefaultsKey = "completedPuzzles"
    private let ratingsKey = "puzzleRatings"
    
    private init() {
        loadCompletedPuzzles()
        loadPuzzleRatings()
    }
    
    /// Mark a puzzle as completed
    func markCompleted(puzzle: PremadePuzzle) {
        let key = puzzleKey(size: puzzle.size, difficulty: puzzle.difficulty, number: puzzle.number)
        completedPuzzles.insert(key)
        saveCompletedPuzzles()
    }
    
    /// Store the earned rating for a puzzle
    func setRating(_ rating: Double, for puzzle: PremadePuzzle) {
        let key = puzzleKey(size: puzzle.size, difficulty: puzzle.difficulty, number: puzzle.number)
        puzzleRatings[key] = rating
        savePuzzleRatings()
    }
    
    /// Retrieve the saved rating for a puzzle, if any
    func rating(for puzzle: PremadePuzzle) -> Double? {
        let key = puzzleKey(size: puzzle.size, difficulty: puzzle.difficulty, number: puzzle.number)
        return puzzleRatings[key]
    }
    
    /// Check if a puzzle is completed
    func isCompleted(puzzle: PremadePuzzle) -> Bool {
        let key = puzzleKey(size: puzzle.size, difficulty: puzzle.difficulty, number: puzzle.number)
        return completedPuzzles.contains(key)
    }
    
    /// Reset all completion data
    func resetAll() {
        completedPuzzles.removeAll()
        puzzleRatings.removeAll()
        saveCompletedPuzzles()
        savePuzzleRatings()
    }
    
    /// Reset completion data for a specific size
    func resetSize(_ size: Int) {
        completedPuzzles = completedPuzzles.filter { !$0.hasPrefix("\(size)-") }
        puzzleRatings = puzzleRatings.filter { !$0.key.hasPrefix("\(size)-") }
        saveCompletedPuzzles()
        savePuzzleRatings()
    }
    
    /// Check if all Christmas quest puzzles are completed
    func areAllChristmasPuzzlesCompleted() -> Bool {
        let store = PremadePuzzleStore.shared
        
        // Get all Christmas puzzles for each size
        let christmasPuzzles3x3 = store.puzzles(for: 3, themeType: .christmas)
        let christmasPuzzles4x4 = store.puzzles(for: 4, themeType: .christmas)
        let christmasPuzzles6x6 = store.puzzles(for: 6, themeType: .christmas)
        
        let allChristmasPuzzles = christmasPuzzles3x3 + christmasPuzzles4x4 + christmasPuzzles6x6
        
        // If no Christmas puzzles exist, consider it not completed
        guard !allChristmasPuzzles.isEmpty else { return false }
        
        // Check if all Christmas puzzles are completed
        return allChristmasPuzzles.allSatisfy { isCompleted(puzzle: $0) }
    }
    
    /// Get the Christmas puzzle completion progress (completed/total)
    func christmasPuzzleProgress() -> (completed: Int, total: Int) {
        let store = PremadePuzzleStore.shared
        
        let christmasPuzzles3x3 = store.puzzles(for: 3, themeType: .christmas)
        let christmasPuzzles4x4 = store.puzzles(for: 4, themeType: .christmas)
        let christmasPuzzles6x6 = store.puzzles(for: 6, themeType: .christmas)
        
        let allChristmasPuzzles = christmasPuzzles3x3 + christmasPuzzles4x4 + christmasPuzzles6x6
        let completedCount = allChristmasPuzzles.filter { isCompleted(puzzle: $0) }.count
        
        return (completedCount, allChristmasPuzzles.count)
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

    private func loadPuzzleRatings() {
        if let storedRatings = UserDefaults.standard.dictionary(forKey: ratingsKey) as? [String: Double] {
            puzzleRatings = storedRatings
        }
    }
    
    private func saveCompletedPuzzles() {
        UserDefaults.standard.set(Array(completedPuzzles), forKey: userDefaultsKey)
    }

    private func savePuzzleRatings() {
        UserDefaults.standard.set(puzzleRatings, forKey: ratingsKey)
    }
}

