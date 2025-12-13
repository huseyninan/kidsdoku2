import Foundation

final class PuzzleSolveStatusManager {
    static let shared = PuzzleSolveStatusManager()
    
    private let userDefaults = UserDefaults.standard
    private let solvedPuzzlesKey = "solvedPuzzles"
    private let migrationVersionKey = "puzzleIdMigrationVersion"
    private let currentMigrationVersion = 1
    
    private init() {
        migrateOldPuzzleIds()
    }
    
    /// Migrates old puzzle IDs (without theme prefix) to new format or removes them
    private func migrateOldPuzzleIds() {
        let savedVersion = userDefaults.integer(forKey: migrationVersionKey)
        guard savedVersion < currentMigrationVersion else { return }
        
        // Clear all old-format puzzle IDs (they don't have theme prefix)
        // User will need to re-solve puzzles, but this ensures clean state
        let oldIds = solvedPuzzleIds
        let validIds = oldIds.filter { id in
            // New format: "theme-size-difficulty-number"
            // Old format: "size-difficulty-number"
            let components = id.split(separator: "-")
            return components.count == 4 && (id.hasPrefix("christmas-") || id.hasPrefix("storybook-"))
        }
        
        solvedPuzzleIds = validIds
        userDefaults.set(currentMigrationVersion, forKey: migrationVersionKey)
    }
    
    private var solvedPuzzleIds: Set<String> {
        get {
            if let data = userDefaults.data(forKey: solvedPuzzlesKey),
               let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
                return decoded
            }
            return []
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                userDefaults.set(encoded, forKey: solvedPuzzlesKey)
            }
        }
    }
    
    func markAsSolved(puzzleId: String) {
        var solved = solvedPuzzleIds
        solved.insert(puzzleId)
        solvedPuzzleIds = solved
    }
    
    func markAsUnsolved(puzzleId: String) {
        var solved = solvedPuzzleIds
        solved.remove(puzzleId)
        solvedPuzzleIds = solved
    }
    
    func isSolved(puzzleId: String) -> Bool {
        return solvedPuzzleIds.contains(puzzleId)
    }
    
    func getSolvedPuzzleIds() -> Set<String> {
        return solvedPuzzleIds
    }
    
    func getSolvedCount(for size: Int, difficulty: PuzzleDifficulty, theme: GameThemeType? = nil) -> Int {
        if let theme = theme {
            let prefix = "\(theme.rawValue)-\(size)-\(difficulty.rawValue.lowercased())-"
            return solvedPuzzleIds.filter { $0.hasPrefix(prefix) }.count
        } else {
            // Count across all themes
            let pattern = "-\(size)-\(difficulty.rawValue.lowercased())-"
            return solvedPuzzleIds.filter { $0.contains(pattern) }.count
        }
    }
    
    func getSolvedCount(for size: Int, theme: GameThemeType? = nil) -> Int {
        if let theme = theme {
            let prefix = "\(theme.rawValue)-\(size)-"
            return solvedPuzzleIds.filter { $0.hasPrefix(prefix) }.count
        } else {
            // Count across all themes
            let pattern = "-\(size)-"
            return solvedPuzzleIds.filter { $0.contains(pattern) }.count
        }
    }
    
    func getTotalSolvedCount() -> Int {
        return solvedPuzzleIds.count
    }
    
    func clearAll() {
        solvedPuzzleIds = []
    }
    
    /// Force migration (useful for debugging)
    func forceMigration() {
        userDefaults.set(0, forKey: migrationVersionKey)
        migrateOldPuzzleIds()
    }
}
