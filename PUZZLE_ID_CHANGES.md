# Puzzle ID System Changes

## What Changed

Each puzzle now has a **stable, unique ID** that never changes, making puzzle tracking reliable and consistent.

## ID Format

```
"size-difficulty-number"
```

### Examples:
- `"3-Easy-1"` - 3x3 grid, Easy difficulty, puzzle #1
- `"4-Normal-5"` - 4x4 grid, Normal difficulty, puzzle #5
- `"6-Hard-9"` - 6x6 grid, Hard difficulty, puzzle #9

## Benefits

✅ **Consistent Tracking**: Same puzzle always has the same ID  
✅ **Simple Storage**: IDs are used directly in UserDefaults  
✅ **Easy Debugging**: IDs are human-readable  
✅ **Backward Compatible**: Format matches existing saved data  

## Files Modified

1. **KidSudokuModel.swift**
   - Changed `PremadePuzzle.id` from `UUID()` to `String`

2. **PremadePuzzleStore.swift**
   - Generate stable ID when creating puzzles: `"\(size)-\(difficulty.rawValue)-\(number)"`

3. **PuzzleCompletionManager.swift**
   - Simplified to use `puzzle.id` directly
   - Removed `puzzleKey()` helper function

4. **PuzzleSelectionView.swift**
   - Use `puzzle.id` instead of manually constructing keys

## Usage

```swift
// Mark puzzle as completed
PuzzleCompletionManager.shared.markCompleted(puzzle: puzzle)

// Check if completed
if PuzzleCompletionManager.shared.isCompleted(puzzle: puzzle) {
    // Show completion badge
}

// Save rating
PuzzleCompletionManager.shared.setRating(3.0, for: puzzle)

// Get rating
if let rating = PuzzleCompletionManager.shared.rating(for: puzzle) {
    // Display stars
}
```

## Data Format

All puzzle completion data is stored in UserDefaults:

- **Completed Puzzles**: Array of puzzle IDs
- **Ratings**: Dictionary mapping puzzle ID → rating value
