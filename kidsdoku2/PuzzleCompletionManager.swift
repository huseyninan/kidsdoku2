//
//  PuzzleCompletionManager.swift
//  kidsdoku2
//
//  Created to track puzzle completion status
//

import Combine
import Foundation

/// Manages puzzle completion tracking using UserDefaults
/// Thread-safe singleton that ensures all mutations happen on the main thread
@MainActor
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
        
        // Migration from version 0: add "storybook-" prefix to puzzleRatings keys
        if savedVersion == 0 {
            var migratedRatings: [String: Double] = [:]
            for (key, value) in puzzleRatings {
                if !key.hasPrefix("storybook-") && !key.hasPrefix("christmas-") {
                    migratedRatings["storybook-\(key)".lowercased()] = value
                } else {
                    migratedRatings[key] = value
                }
            }
            puzzleRatings = migratedRatings
        }
        
        // Filter out old-format rating IDs
        let validRatings = puzzleRatings.filter { key, _ in
            // New format: "theme-size-difficulty-number"
            let components = key.split(separator: "-")
            return components.count == 4 && (key.hasPrefix("christmas-") || key.hasPrefix("storybook-"))
        }
        
        puzzleRatings = validRatings
        savePuzzleRatings()
        
        // Migration from version 0: add "storybook-" prefix to completedPuzzles
        if savedVersion == 0 {
            var migratedCompleted: Set<String> = []
            for id in completedPuzzles {
                if !id.hasPrefix("storybook-") && !id.hasPrefix("christmas-") {
                    migratedCompleted.insert("storybook-\(id)".lowercased())
                } else {
                    migratedCompleted.insert(id)
                }
            }
            completedPuzzles = migratedCompleted
        }
        
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
    /// FIX: Now uses puzzle.id directly for consistent key format with ratings
    func markCompleted(puzzle: PremadePuzzle) {
        completedPuzzles.insert(puzzle.id)
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
    /// FIX: Now uses puzzle.id directly for consistent key format with ratings
    func isCompleted(puzzle: PremadePuzzle) -> Bool {
        return completedPuzzles.contains(puzzle.id)
    }
    
    /// Reset all completion data
    func resetAll() {
        completedPuzzles.removeAll()
        puzzleRatings.removeAll()
        saveCompletedPuzzles()
        savePuzzleRatings()
    }
    
    /// Reset completion data for a specific size
    /// FIX: Updated filter to match theme-prefixed ID format (e.g., "storybook-4-Easy-1")
    func resetSize(_ size: Int) {
        completedPuzzles = completedPuzzles.filter { id in
            !id.contains("-\(size)-")
        }
        puzzleRatings = puzzleRatings.filter { key, _ in
            !key.contains("-\(size)-")
        }
        saveCompletedPuzzles()
        savePuzzleRatings()
    }
    
    // MARK: - Private Helpers
    
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

