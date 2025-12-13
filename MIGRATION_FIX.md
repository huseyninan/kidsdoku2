# Quick Fix for Theme-Specific Puzzle Tracking

## The Problem
Old puzzle data uses the format: `"4-easy-1"`
New puzzle data uses the format: `"christmas-4-easy-1"` or `"storybook-4-easy-1"`

The old format causes Christmas and Storybook puzzles to share the same ID.

## Immediate Solution (Choose One)

### Option 1: Restart the App
1. **Force quit the app completely** (swipe up from app switcher)
2. **Relaunch the app**
3. The migration will run automatically and clear old-format IDs

### Option 2: Clear Data Programmatically
Add this button to your settings or debug menu:

```swift
Button("Reset Puzzle Progress") {
    PuzzleSolveStatusManager.shared.forceMigration()
    PuzzleCompletionManager.shared.resetAll()
}
```

### Option 3: Clear UserDefaults Manually (Xcode)
In Xcode, before running:
```swift
// Add this temporarily in AppDelegate or first view
UserDefaults.standard.removeObject(forKey: "solvedPuzzles")
UserDefaults.standard.removeObject(forKey: "completedPuzzles")
UserDefaults.standard.removeObject(forKey: "puzzleRatings")
```

## What the Fix Does

**New Puzzle IDs:**
- Christmas puzzles: `"christmas-4-easy-1"`
- Storybook puzzles: `"storybook-4-easy-1"`

**Migration clears:**
- Any IDs without 4 components (old format)
- Any IDs not starting with "christmas-" or "storybook-"

## After Migration
Once migration runs, Christmas and Storybook puzzles will track separately.

**Note:** You may lose existing puzzle progress, but this ensures clean state going forward.
