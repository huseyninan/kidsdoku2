# Kidsdoku2 Application Guide

This document explains how the Kidsdoku2 SwiftUI app is put together so you can confidently extend it, ship new content, or hand it to another teammate.

## Concept At A Glance
- Kid-friendly take on Sudoku that swaps digits for illustrated animal, bird, sea, and weather icons stored in `Assets.xcassets`.
- Supports 4×4 (2×2 subgrids) and 6×6 (2×3 subgrids) boards defined by `KidSudokuConfig`.
- Players can pick handcrafted “Quest Log” puzzles or start a randomly generated adventure.
- Animated hints, undo, erase, highlight, and celebratory overlays make it approachable for younger players.

## Main Flow
1. `kidsdoku2App` boots into `ContentView`, which owns a `NavigationStack`.
2. `MainMenuView` shows the fox background hero screen, tutorial modal, and entry points for 4×4 or 6×6 journeys.
3. Selecting a size pushes `PuzzleSelectionView` where puzzles are grouped by `PuzzleDifficulty` (Easy, Normal, Hard) with themed cards plus a “Random Adventure” button.
4. Choosing a premade puzzle or random run loads `GameView`, which hosts the interactive board, palette, helper controls, and feedback banners.
5. Completing a premade board records progress via `PuzzleCompletionManager` so finished puzzles get a checkmark badge in the selector.

## Core Architecture
| Component | Defined In | Purpose |
| --- | --- | --- |
| `SymbolGroup`, `KidSudokuConfig`, `KidSudokuPuzzle`, `KidSudokuCell` | `kidsdoku2/KidSudokuModel.swift` | Describe board dimensions, assign themed symbol sets, and wrap puzzle state. |
| `KidSudokuGenerator` | `kidsdoku2/KidSudokuModel.swift` | Builds solvable puzzles on demand: generate Latin-style board, shuffle rows/columns/symbols, then carve cells while keeping a unique solution. |
| `PremadePuzzleStore` | `kidsdoku2/Models/PremadePuzzleStore.swift` | Holds curated puzzles declared in a readable string DSL (see `PUZZLE_GUIDE.md`). |
| `GameViewModel` | `kidsdoku2/GameViewModel.swift` | Drives gameplay: selection, validation, move history/undo, hints, progress detection, celebratory state, and sound triggers. |
| `PuzzleCompletionManager` | `kidsdoku2/PuzzleCompletionManager.swift` | Persists finished puzzle IDs in `UserDefaults`. |
| `SoundManager` | `kidsdoku2/SoundManager.swift` | Preloads and plays `.wav` feedback clips from `Resources/Sounds`, with a global mute toggle. |

### Data Flow Overview
```
PremadePuzzleStore / KidSudokuGenerator
            ↓
    KidSudokuPuzzle (cells, solution)
            ↓
      GameViewModel (logic, Combine)
            ↓
         GameView (SwiftUI)
```

## Puzzle Systems
- **Random boards** (`KidSudokuGenerator.generatePuzzle`) are ideal for the “Random Adventure” button and future endless modes.
- **Premade boards** use the helper `puzzle(...)` builder to keep inputs compact. Each entry stores the initial grid, solved grid, difficulty, and an identifying emoji used on the selection cards.
- Refer to `PUZZLE_GUIDE.md` for exact formatting rules (periods for blanks, digits for fixed values, validation safeguards).
- `KidSudokuPuzzle` converts those definitions into `KidSudokuCell` structs that the UI consumes, tracking whether a cell is fixed or editable.

## Gameplay Experience
- **Board rendering** (`BoardGridView` inside `GameView`) draws a rounded board, applies dashed sub-grid separators, and highlights selected or matching symbols with the animated `GlowingHighlight`.
- **Palette** shows only the symbols that appear in the puzzle, letting kids tap an emoji to “pick up” that tile before touching empty squares.
- **Controls**: Undo leverages a move stack, Erase clears the current selection, and Hint fills a random empty cell (with sound + banner feedback). All controls animate with `withAnimation` for approachability.
- **Messaging**: `KidSudokuMessage` surfaces playful warnings (“That owl is already there!”), completions, or info prompts.
- **Celebration**: When solver verifies every cell matches `solution`, `showCelebration` triggers an alert and `SoundManager` plays the victory chime. Premade puzzles also notify `PuzzleCompletionManager`.

## Audio, Haptics, and Feedback
- Sound effects live under `kidsdoku2/Resources/Sounds` (`correct_placement.wav`, `incorrect_placement.wav`, `hint.wav`, `victory_sound.wav`).
- `SoundManager` preloads them into `AVAudioPlayer` instances, enforces `mixWithOthers` so background music keeps playing, and exposes a `toggleSound()` action bound to the speaker button in `GameView`.
- Additional tactile feedback (haptics) can be layered later by hooking into the same view-model actions.

## Progress Tracking
- Each finished premade puzzle stores a string key of the form `"{size}-{difficulty}-{number}"` in `UserDefaults`.
- `PuzzleSelectionView` observes `PuzzleCompletionManager.shared` to show green check badges without additional wiring.
- Utility methods (`resetAll`, `resetSize`) already exist if you want to add a Settings reset button.

## Assets & Styling
- Animal, bird, and sea icons are organized within `kidsdoku2/Assets.xcassets/...` and referenced by name through `SymbolGroup`.
- Background art (e.g., `fox_bg`, `splash_bg2`) and the color palette give the app its warm illustrated look.
- SwiftUI’s rounded rectangles, gradients, and drop shadows are used consistently to reinforce the “storybook” aesthetic.

## Building & Running
1. Open `kidsdoku2.xcodeproj` in Xcode 16 (or newer SwiftUI-capable release).
2. Select the `kidsdoku2` scheme and an iOS 17+ simulator or device.
3. Build & run (`⌘R`). Assets and sound resources are bundled automatically via the project file.
4. For SwiftUI previews (`#Preview` blocks), you can iterate quickly on specific views like `GameView`, `MainMenuView`, or `PuzzleSelectionView`.

## Extending the App
- **More board sizes**: Expand `KidSudokuConfig` and `SymbolGroup` to add 8×8 or theme-specific boards, ensuring sub-grid dimensions divide evenly.
- **Daily Challenge mode**: Schedule a fresh `KidSudokuGenerator` puzzle each day and persist it alongside completion stats.
- **Coaching overlays**: Reuse `TutorialView` content inline during gameplay for contextual tips when the player makes repeated mistakes.
- **Settings screen**: Hook the placeholder gear buttons to a view that manages sound, progress reset, or color-blind palettes.
- **Analytics/Telemetry**: Log puzzle completions and hint usage to understand difficulty tuning for future updates.

With this overview plus the `PUZZLE_GUIDE.md`, you should have everything needed to evolve Kidsdoku2’s features, content, and presentation.

