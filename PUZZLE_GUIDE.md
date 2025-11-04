# How to Add New Puzzles

The `PremadePuzzleStore` has been refactored to make adding new puzzles quick and easy!

## Quick Start

Adding a new puzzle is now as simple as:

```swift
puzzle(4, 4, .easy, "🌟",
    initial:  """
              1...
              ..2.
              .3..
              ...0
              """,
    solution: """
              1023
              3021
              2310
              0132
              """)
```

## Format Guide

### String Notation
- Use `.` for empty cells (to be filled by player)
- Use digits `0-5` for pre-filled cells
- Each row on a new line
- Keep rows aligned for readability

### 4x4 Example

```swift
// For a 4x4 puzzle, use digits 0-3
puzzle(1, 4, .normal, "🎯",
    initial:  """
              0..3
              ..0.
              .1..
              2..1
              """,
    solution: """
              0213
              3102
              1320
              2031
              """)
```

### 6x6 Example

```swift
// For a 6x6 puzzle, use digits 0-5
puzzle(1, 6, .hard, "🌈",
    initial:  """
              ......
              ...2..
              ..4...
              ...1..
              ..3...
              ......
              """,
    solution: """
              315024
              041253
              524310
              402135
              153402
              230541
              """)
```

## Parameters

1. **Number**: The puzzle number within its difficulty level (1, 2, 3, ...)
2. **Size**: Board size (4 or 6)
3. **Difficulty**: `.easy`, `.normal`, or `.hard`
4. **Emoji**: A fun emoji to represent this puzzle (e.g., "☀️", "🌻", "💎")
5. **Initial**: The starting board with some empty cells
6. **Solution**: The complete solved board

## Where to Add

Open `kidsdoku2/Models/PremadePuzzleStore.swift`:
- For 4x4 puzzles: Add to `fourByFourPuzzles` array
- For 6x6 puzzles: Add to `sixBySixPuzzles` array

## Before vs After

### Before (Old Format) ❌
```swift
PremadePuzzle(
    number: 1,
    size: 4,
    difficulty: .easy,
    config: .fourByFour,
    initialBoard: [
        [0, nil, nil, 3],
        [nil, nil, 0, nil],
        [nil, 1, nil, nil],
        [2, nil, nil, 1]
    ],
    solutionBoard: [
        [0, 2, 1, 3],
        [3, 1, 0, 2],
        [1, 3, 2, 0],
        [2, 0, 3, 1]
    ],
    emoji: "☀️"
)
```

### After (New Format) ✅
```swift
puzzle(1, 4, .easy, "☀️",
    initial:  """
              0..3
              ..0.
              .1..
              2..1
              """,
    solution: """
              0213
              3102
              1320
              2031
              """)
```

## Validation

The helper function automatically validates:
- ✅ Correct number of rows and columns
- ✅ Valid characters (digits and dots only)
- ✅ Board size matches the specified size

If there's an error, you'll get a clear assertion failure message.

## Tips

1. **Visual clarity**: The string format makes it easy to see the puzzle layout at a glance
2. **Copy-paste friendly**: Easy to copy puzzle patterns from other sources
3. **Less error-prone**: No more mixing up brackets and commas
4. **Fast to write**: 60%+ less code per puzzle!

Happy puzzle creating! 🎯

