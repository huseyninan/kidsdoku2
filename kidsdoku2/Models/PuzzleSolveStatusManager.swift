import Foundation

/// Thread-safe manager for tracking solved puzzle IDs with in-memory caching.
final class PuzzleSolveStatusManager {
    static let shared = PuzzleSolveStatusManager()
    
    private let userDefaults = UserDefaults.standard
    private let solvedPuzzlesKey = "solvedPuzzles"
    private let migrationVersionKey = "puzzleIdMigrationVersion"
    private let legacyCompletedPuzzlesKey = "completedPuzzles"
    private let currentMigrationVersion = 1
    
    /// In-memory cache to avoid repeated JSON decoding
    private var cachedSolvedPuzzleIds: Set<String>?
    
    /// Serial queue for thread-safe read-modify-write operations
    private let queue = DispatchQueue(label: "com.kidsdoku.puzzleSolveStatusManager")
    
    private init() {
        migrateOldPuzzleIds()
    }
    
    /// Migrates old puzzle IDs (without theme prefix) to new format or removes them
    private func migrateOldPuzzleIds() {
        let savedVersion = userDefaults.integer(forKey: migrationVersionKey)
        guard savedVersion < currentMigrationVersion else { return }
        
        // Migration from version 0: migrate from legacy key to new key
        if savedVersion == 0 {
            if let data = userDefaults.array(forKey: legacyCompletedPuzzlesKey) as? [String] {
                persistToDisk(Set(data))
            }
        }
        
        userDefaults.set(currentMigrationVersion, forKey: migrationVersionKey)
    }
    
    // MARK: - Private Helpers
    
    /// Loads puzzle IDs from disk (called only when cache is empty)
    private func loadFromDisk() -> Set<String> {
        guard let data = userDefaults.data(forKey: solvedPuzzlesKey) else {
            return []
        }
        do {
            return try JSONDecoder().decode(Set<String>.self, from: data)
        } catch {
            print("PuzzleSolveStatusManager: Failed to decode solved puzzles: \(error)")
            return []
        }
    }
    
    /// Persists puzzle IDs to disk and updates cache
    private func persistToDisk(_ ids: Set<String>) {
        do {
            let encoded = try JSONEncoder().encode(ids)
            userDefaults.set(encoded, forKey: solvedPuzzlesKey)
            cachedSolvedPuzzleIds = ids
        } catch {
            print("PuzzleSolveStatusManager: Failed to encode solved puzzles: \(error)")
        }
    }
    
    /// Thread-safe access to the cached puzzle IDs
    private func getSolvedIds() -> Set<String> {
        return queue.sync {
            if let cached = cachedSolvedPuzzleIds {
                return cached
            }
            let loaded = loadFromDisk()
            cachedSolvedPuzzleIds = loaded
            return loaded
        }
    }
    
    /// Thread-safe mutation of puzzle IDs
    private func mutateSolvedIds(_ mutation: (inout Set<String>) -> Void) {
        queue.sync {
            var ids = cachedSolvedPuzzleIds ?? loadFromDisk()
            mutation(&ids)
            persistToDisk(ids)
        }
    }
    
    // MARK: - Public API
    
    func markAsSolved(puzzleId: String) {
        mutateSolvedIds { $0.insert(puzzleId) }
    }
    
    func markAsUnsolved(puzzleId: String) {
        mutateSolvedIds { $0.remove(puzzleId) }
    }
    
    func isSolved(puzzleId: String) -> Bool {
        return getSolvedIds().contains(puzzleId)
    }
    
    func getSolvedPuzzleIds() -> Set<String> {
        return getSolvedIds()
    }
    
    func getSolvedCount(for size: Int, difficulty: PuzzleDifficulty, theme: GameThemeType? = nil) -> Int {
        let ids = getSolvedIds()
        if let theme = theme {
            let prefix = "\(theme.rawValue)-\(size)-\(difficulty.rawValue.lowercased())-"
            return ids.filter { $0.hasPrefix(prefix) }.count
        } else {
            // Count across all themes
            let pattern = "-\(size)-\(difficulty.rawValue.lowercased())-"
            return ids.filter { $0.contains(pattern) }.count
        }
    }
    
    func getSolvedCount(for size: Int, theme: GameThemeType? = nil) -> Int {
        let ids = getSolvedIds()
        if let theme = theme {
            let prefix = "\(theme.rawValue)-\(size)-"
            return ids.filter { $0.hasPrefix(prefix) }.count
        } else {
            // Count across all themes
            let pattern = "-\(size)-"
            return ids.filter { $0.contains(pattern) }.count
        }
    }
    
    func getTotalSolvedCount() -> Int {
        return getSolvedIds().count
    }
    
    func clearAll() {
        mutateSolvedIds { $0.removeAll() }
    }
    
    /// Force migration (useful for debugging)
    func forceMigration() {
        queue.sync {
            cachedSolvedPuzzleIds = nil
        }
        userDefaults.set(0, forKey: migrationVersionKey)
        migrateOldPuzzleIds()
    }
}
