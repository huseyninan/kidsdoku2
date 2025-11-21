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

