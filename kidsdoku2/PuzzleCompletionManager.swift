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
    private let ratingsMigrationVersionKey = "ratingsIdMigrationVersion"
    private let currentMigrationVersion = 1
    
    private init() {
        loadCompletedPuzzles()
        loadPuzzleRatings()
        migrateOldRatingIds()
    }
    
    /// Migrates old rating IDs (without theme prefix) to new format or removes them
    private func migrateOldRatingIds() {
        let savedVersion = UserDefaults.standard.integer(forKey: ratingsMigrationVersionKey)
        guard savedVersion < currentMigrationVersion else { return }
        
        // Filter out old-format rating IDs
        let validRatings = puzzleRatings.filter { key, _ in
            // New format: "theme-size-difficulty-number"
            let components = key.split(separator: "-")
            return components.count == 4 && (key.hasPrefix("christmas-") || key.hasPrefix("storybook-"))
        }
        
        puzzleRatings = validRatings
        savePuzzleRatings()
        
        // Also clear old completedPuzzles (they use old format keys)
        let validCompleted = completedPuzzles.filter { id in
            let components = id.split(separator: "-")
            return components.count == 4 && (id.hasPrefix("christmas-") || id.hasPrefix("storybook-"))
        }
        
        completedPuzzles = validCompleted
        saveCompletedPuzzles()
        
        UserDefaults.standard.set(currentMigrationVersion, forKey: ratingsMigrationVersionKey)
    }
    
    /// Mark a puzzle as completed
    func markCompleted(puzzle: PremadePuzzle) {
        let key = puzzleKey(size: puzzle.size, difficulty: puzzle.difficulty, number: puzzle.number)
        completedPuzzles.insert(key)
        saveCompletedPuzzles()
    }
    
    /// Store the earned rating for a puzzle
    func setRating(_ rating: Double, for puzzle: PremadePuzzle) {
        puzzleRatings[puzzle.id] = rating
        savePuzzleRatings()
    }
    
    /// Retrieve the saved rating for a puzzle, if any
    func rating(for puzzle: PremadePuzzle) -> Double? {
        return puzzleRatings[puzzle.id]
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

