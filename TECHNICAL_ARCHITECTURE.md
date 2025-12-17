# Kidsdoku2 Technical Architecture

## Overview
Kidsdoku2 is a SwiftUI-based iOS application that provides a kid-friendly Sudoku experience with visual symbols instead of numbers. The app features 3×3, 4×4, and 6×6 puzzle boards with multiple difficulty levels, progress tracking, and premium features via RevenueCat.

## Technology Stack

### Core Frameworks
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for state management
- **AVFoundation**: Audio playback for sound effects
- **UIKit**: Haptic feedback integration
- **RevenueCat**: In-app purchase and subscription management
- **Firebase Analytics**: User behavior tracking

### Minimum Requirements
- iOS 17.0+
- Xcode 16+
- Swift 5.9+

---

## Architecture Pattern

### MVVM (Model-View-ViewModel)
The app follows the MVVM pattern with SwiftUI's reactive bindings:

```
Model (Data Layer)
    ↓
ViewModel (Business Logic)
    ↓
View (UI Layer)
```

### Key Components

#### 1. **App Entry Point**
- **File**: `kidsdoku2App.swift`
- **Purpose**: App initialization, RevenueCat configuration, Firebase setup
- **Key Features**:
  - Configures RevenueCat with API key
  - Sets up Firebase via AppDelegate
  - Injects `AppEnvironment` as environment object

#### 2. **Environment Management**
- **File**: `AppEnvironment.swift`
- **Pattern**: Singleton + ObservableObject
- **Responsibilities**:
  - Premium subscription status (`isPremium`)
  - Grid visibility settings (3×3, 4×4, 6×6)
  - Global manager references (Sound, Haptic)
  - RevenueCat integration

#### 3. **Navigation**
- **Pattern**: NavigationStack with enum-based routing
- **Route Definition**: `KidSudokuRoute` enum
  ```swift
  enum KidSudokuRoute {
      case game(size: Int)
      case puzzleSelection(size: Int)
      case premadePuzzle(puzzle: PremadePuzzle)
      case settings
  }
  ```

---

## Data Models

### Core Models (`KidSudokuModel.swift`)

#### 1. **SymbolGroup**
- **Type**: Enum with 12 cases
- **Purpose**: Defines themed symbol sets (animals, birds, sea creatures, weather, numbers)
- **Key Properties**:
  - `symbols: [String]` - Asset names for each symbol
  - `paletteTitle: String` - Localized display name
  - `puzzleCases` - Available groups for puzzles

#### 2. **KidSudokuConfig**
- **Type**: Struct
- **Purpose**: Board configuration and rules
- **Properties**:
  ```swift
  let size: Int              // Board dimension (3, 4, or 6)
  let subgridRows: Int       // Subgrid height
  let subgridCols: Int       // Subgrid width
  let symbolGroup: SymbolGroup
  ```
- **Presets**: `.threeByThree`, `.fourByFour`, `.sixBySix`

#### 3. **KidSudokuCell**
- **Type**: Struct (Identifiable, Equatable)
- **Purpose**: Individual cell state
- **Properties**:
  ```swift
  let id: Int
  let position: KidSudokuPosition
  var value: Int?           // Current value (nil = empty)
  let solution: Int         // Correct answer
  let isFixed: Bool         // Pre-filled cell?
  ```

#### 4. **KidSudokuPuzzle**
- **Type**: Struct
- **Purpose**: Complete puzzle state
- **Properties**:
  ```swift
  let config: KidSudokuConfig
  private(set) var cells: [KidSudokuCell]
  let solution: [[Int]]
  ```

#### 5. **PremadePuzzle**
- **Type**: Struct (Hashable, Identifiable)
- **Purpose**: Handcrafted puzzle definition
- **Properties**:
  ```swift
  let number: Int
  let size: Int
  let difficulty: PuzzleDifficulty
  let config: KidSudokuConfig
  let initialBoard: [[Int?]]
  let solutionBoard: [[Int]]
  ```

---

## View Models

### GameViewModel (`GameView/GameViewModel.swift`)

**Responsibility**: Game logic, validation, state management

#### Published Properties
```swift
@Published private(set) var puzzle: KidSudokuPuzzle
@Published var selectedPosition: KidSudokuPosition?
@Published var message: KidSudokuMessage?
@Published private(set) var showCelebration: Bool
@Published var highlightedValue: Int?
@Published var selectedPaletteSymbol: Int?
@Published private(set) var mistakeCount: Int
@Published private(set) var hintCount: Int
@Published private(set) var elapsedTime: TimeInterval
@Published var showNumbers: Bool
@Published private(set) var currentConfig: KidSudokuConfig
@Published private(set) var filledCellCount: Int
```

#### Key Methods
- **Puzzle Generation**:
  - `init(config:)` - Random puzzle via async generation
  - `init(config:premadePuzzle:)` - Load premade puzzle
  - `generatePuzzleAsync()` - Background thread generation
  
- **Gameplay**:
  - `didTapCell(_:)` - Handle cell selection/placement
  - `selectPaletteSymbol(_:)` - Symbol selection
  - `placeSymbol(at:)` - Place symbol with validation
  - `removeValue()` - Erase cell value
  - `provideHint()` - Fill random empty cell
  - `undo()` - Revert last move
  
- **Validation**:
  - `isValid(_:at:)` - Check row/column/subgrid rules
  - `checkForCompletion()` - Verify puzzle solved
  
- **Timer**:
  - `startTimer()` - Begin elapsed time tracking
  - `stopTimer()` - Pause timer
  - `formattedTime` - MM:SS display
  
- **Rating**:
  - `calculateStars()` - 0-3 stars based on mistakes/hints

---

## Puzzle Generation Algorithm

### KidSudokuGenerator (`KidSudokuModel.swift`)

#### Step 1: Generate Complete Board
```swift
generateCompleteBoard(config:) -> [[Int]]
```
- Creates a valid Latin square using mathematical pattern
- Formula: `(row * subCols + row / subRows + col) % size`

#### Step 2: Shuffle Board
```swift
shuffleBoard(&board, config:)
```
- **Row Shuffling**: Shuffle within subgrid blocks
- **Column Shuffling**: Shuffle within subgrid blocks
- **Symbol Permutation**: Randomly remap all symbols

#### Step 3: Carve Puzzle
```swift
carvePuzzle(board:solution:config:)
```
- Remove cells while maintaining unique solution
- Target givens:
  - 3×3: 4 cells
  - 4×4: 8 cells
  - 6×6: 14 cells
- Uses backtracking to verify uniqueness

#### Step 4: Build Cells
```swift
buildCells(from:solution:config:) -> [KidSudokuCell]
```
- Convert 2D array to flat cell array
- Mark fixed vs editable cells

---

## Managers (Singletons)

### 1. SoundManager (`SoundManager.swift`)

**Pattern**: Singleton + ObservableObject

**Features**:
- Preloads audio files on init
- Background audio queue for non-blocking playback
- Mix with other audio (`.mixWithOthers`)
- Global mute toggle via `@AppStorage`

**Sound Effects**:
```swift
enum SoundEffect {
    case correctPlacement    // correct_placement.wav
    case incorrectPlacement  // incorrect_placement.wav
    case victory            // victory_sound.wav
    case hint               // hint.wav
}
```

**Usage**:
```swift
SoundManager.shared.play(.correctPlacement, volume: 0.6)
```

### 2. HapticManager (`HapticManager.swift`)

**Pattern**: Singleton + ObservableObject + @MainActor

**Haptic Types**:
```swift
enum HapticType {
    case light, medium, heavy
    case success, warning, error
    case selection
}
```

**Usage**:
```swift
HapticManager.shared.trigger(.success)
```

### 3. PuzzleCompletionManager (`PuzzleCompletionManager.swift`)

**Pattern**: Singleton + ObservableObject

**Data Storage**: UserDefaults

**Published Properties**:
```swift
@Published private(set) var completedPuzzles: Set<String>
@Published private(set) var puzzleRatings: [String: Double]
```

**Key Format**: `"{size}-{difficulty}-{number}"` (e.g., "4-Easy-1")

**Methods**:
- `markCompleted(puzzle:)` - Mark puzzle done
- `setRating(_:for:)` - Store star rating
- `isCompleted(puzzle:)` - Check completion status
- `resetAll()` - Clear all progress
- `resetSize(_:)` - Clear progress for specific size

---

## Views

### 1. MainMenuView (`MainMenuView.swift`)

**Purpose**: App home screen with quest selection

**Key Features**:
- Responsive layout (regular vs compact width)
- Premium button (if not subscribed)
- Tutorial access
- Settings navigation
- Grid visibility based on `AppEnvironment`

**Quest Options**:
- 3×3: "Tiny Tales"
- 4×4: "Fable Adventures"
- 6×6: "Kingdom Chronicles"

### 2. PuzzleSelectionView (`PuzzleSelectionView.swift`)

**Purpose**: Difficulty-based puzzle browser

**Performance Optimizations**:
- **Async Loading**: Puzzles loaded on background thread
- **Cached Status**: Pre-computes completion/rating to avoid repeated lookups
- **Efficient Filtering**: Single `onChange` handler for filter state
- **Symmetric Difference**: Only updates when relevant puzzles change
- **Drawing Group**: Rasterizes grid for better rendering

**Features**:
- Difficulty themes with custom names per size
- Adaptive grid layout (2-4 columns)
- Lock overlay for premium puzzles (>3 per difficulty)
- Completion badges with star ratings
- Settings sheet for difficulty visibility

**Difficulty Themes**:
```swift
3×3: Wakey Wakey, Breakfast Time, Garden Path
4×4: Sunny Meadow, Twisty Trails, Mushroom Grove
6×6: Echo Cave, Snowy Slopes, Starry Summit
```

### 3. GameView (`GameView/GameView.swift`)

**Purpose**: Main gameplay interface

**Layout Structure**:
```
ZStack {
    Background Image
    Running Fox Animation (bottom)
    VStack {
        Header (title, progress, timer, settings)
        Board Section
        Palette Section
        Action Buttons (Undo, Erase, Hint)
    }
    Celebration Overlay (conditional)
    Message Banner (conditional)
}
```

**Key Components**:
- **BoardGridView**: Renders cells with subgrid separators
- **SymbolTokenView**: Displays symbols/numbers
- **StorybookComponents**: Themed UI elements
- **CelebrationOverlay**: Victory screen with rating

**Interaction Flow**:
1. Tap palette symbol → Select symbol
2. Tap empty cell → Place symbol (if valid)
3. Tap filled cell → Highlight matching symbols
4. Invalid placement → Show warning + sound

### 4. BoardGridView (`GameView/BoardGridView.swift`)

**Purpose**: Grid rendering with visual feedback

**Features**:
- Dashed subgrid separators
- Glowing highlights for selected/matching values
- Fixed vs editable cell styling
- Responsive sizing via `DeviceSizing`

### 5. CelebrationOverlay (`GameView/CelebrationOverlay.swift`)

**Purpose**: Victory screen with star rating

**Rating Tiers**:
```swift
0 penalties:   3.0 stars (Perfect!)
1-2:           2.5 stars
3-4:           2.0 stars
5-6:           1.5 stars
7-8:           1.0 stars
9-10:          0.5 stars
11+:           0.0 stars
```

**Rank Badges**:
- Legend (2.75+): Purple/Blue gradient
- Hero (2.25+): Orange/Pink gradient
- Pro (1.75+): Green/Teal gradient
- Apprentice (1.25+): Mint/Cyan gradient
- Explorer (0.75+): Blue/Indigo gradient
- Dreamer (0.25+): Gray/Blue gradient
- Rookie (<0.25): Gray gradient

---

## Theming System

### Theme.swift

**Purpose**: Centralized color palette and layout constants

#### Color Categories
- **Premium**: Gold gradients for premium buttons
- **Quest**: Dark brown gradients for main menu
- **Difficulty**: Green (Easy), Blue (Normal), Dark Blue (Hard)
- **Game Actions**: Unique gradients for Undo/Erase/Hint
- **Puzzle Selection**: Background, text, badge colors

#### Layout Constants
```swift
enum Layout {
    static let maxContentWidth: CGFloat = 680
    static let regularTopSpacing: CGFloat = 70
    static let puzzleCardCornerRadius: CGFloat = 24
    static let puzzleButtonHeight: CGFloat = 100
    // ... more constants
}
```

#### Button Styles
- **PremiumButtonStyle**: Gold gradient with border
- **QuestButtonStyle**: Dark gradient with shadow
- **OverlayButtonStyle**: Semi-transparent overlay

---

## Device Sizing

### DeviceSizing.swift

**Purpose**: Responsive layout calculations

**Key Methods**:
```swift
static func computeBoardSize(
    availableWidth: CGFloat,
    availableHeight: CGFloat,
    bottomSafeArea: CGFloat
) -> CGFloat
```

**Adaptive Properties**:
- Header spacing
- Badge scale
- Button sizes
- Progress bar dimensions

---

## Localization

### String Localization
- **File**: `Resources/Localizable.xcstrings`
- **Usage**: `String(localized: "key")`
- **Coverage**: All user-facing text

### Asset Localization
- **File**: `Resources/InfoPlist.xcstrings`
- **Purpose**: App name, permissions

---

## Persistence

### UserDefaults Keys
```swift
"soundEnabled"           // Bool - Sound toggle
"hapticsEnabled"         // Bool - Haptic toggle
"show3x3Grid"           // Bool - 3×3 visibility
"show4x4Grid"           // Bool - 4×4 visibility
"show6x6Grid"           // Bool - 6×6 visibility
"showEasyDifficulty"    // Bool - Easy filter
"showNormalDifficulty"  // Bool - Normal filter
"showHardDifficulty"    // Bool - Hard filter
"hideFinishedPuzzles"   // Bool - Hide completed
"completedPuzzles"      // [String] - Completed puzzle keys
"puzzleRatings"         // [String: Double] - Star ratings
```

---

## Premium Features (RevenueCat)

### Configuration
- **API Key**: Configured in `kidsdoku2App.init()`
- **Entitlement**: "Pro"
- **Paywall**: RevenueCatUI's `PaywallView`

### Premium Content
- Puzzles 4+ in each difficulty level (locked for free users)
- First 3 puzzles per difficulty are free

### Integration Points
1. **MainMenuView**: "Go Premium" button
2. **PuzzleSelectionView**: Lock overlay on premium puzzles
3. **AppEnvironment**: `isPremium` published property

---

## Analytics (Firebase)

### Events Tracked
```swift
AnalyticsEventScreenView
Parameters: AnalyticsParameterScreenName
```

**Example**:
```swift
Analytics.logEvent(AnalyticsEventScreenView, parameters: [
    AnalyticsParameterScreenName: "puzzle_selection_4x4"
])
```

---

## Performance Optimizations

### 1. Async Puzzle Generation
- Generates puzzles on background thread
- Shows placeholder during generation
- Prevents UI blocking

### 2. Cached Puzzle Status
- Pre-computes completion/rating in `PuzzleSelectionView`
- Avoids repeated dictionary lookups during rendering

### 3. Efficient Filtering
- Single `onChange` handler for combined filter state
- Symmetric difference to detect relevant changes
- Only updates when necessary

### 4. Drawing Group
- Rasterizes puzzle grid in `PuzzleSelectionView`
- Reduces rendering overhead

### 5. Isolated Timer View
- `GameTimerView` only re-renders on time change
- Prevents entire `GameView` from updating every second

### 6. Audio Queue
- Plays sounds on background queue
- Non-blocking audio playback

---

## File Structure

```
kidsdoku2/
├── kidsdoku2App.swift              # App entry point
├── AppEnvironment.swift            # Global state management
├── ContentView.swift               # Root navigation container
├── MainMenuView.swift              # Home screen
├── PuzzleSelectionView.swift       # Puzzle browser
├── SettingsView.swift              # Settings screen
├── TutorialView.swift              # How to play
├── Theme.swift                     # Colors & layout constants
│
├── GameView/
│   ├── GameView.swift              # Main game UI
│   ├── GameViewModel.swift         # Game logic
│   ├── BoardGridView.swift         # Grid rendering
│   ├── CelebrationOverlay.swift    # Victory screen
│   └── DeviceSizing.swift          # Responsive sizing
│
├── Models/
│   ├── KidSudokuModel.swift        # Core data models
│   ├── PremadePuzzleStore.swift    # Handcrafted puzzles
│   └── GameSettingsSheet.swift     # In-game settings
│
├── Managers/
│   ├── SoundManager.swift          # Audio playback
│   ├── HapticManager.swift         # Haptic feedback
│   └── PuzzleCompletionManager.swift # Progress tracking
│
├── Components/
│   ├── StorybookComponents.swift   # Themed UI elements
│   ├── SymbolTokenView.swift       # Symbol display
│   └── RunningFoxView.swift        # Animated fox
│
└── Resources/
    ├── Sounds/                     # Audio files (.wav)
    ├── Assets.xcassets/            # Images & symbols
    ├── Localizable.xcstrings       # Localized strings
    └── InfoPlist.xcstrings         # App metadata
```

---

## Testing Considerations

### Unit Testing Targets
1. **KidSudokuGenerator**:
   - Verify unique solutions
   - Check board validity
   - Test shuffle randomness

2. **GameViewModel**:
   - Validation logic
   - Move history
   - Star rating calculation

3. **PuzzleCompletionManager**:
   - Persistence
   - Key generation
   - Reset functionality

### UI Testing Targets
1. **Navigation Flow**:
   - Menu → Selection → Game
   - Back navigation
   - Settings access

2. **Gameplay**:
   - Symbol placement
   - Undo/Erase/Hint
   - Completion detection

3. **Premium Flow**:
   - Paywall presentation
   - Lock/unlock behavior

---

## Future Enhancement Ideas

### Features
1. **Daily Challenge**: Scheduled puzzle with leaderboard
2. **Multiplayer**: Race mode with friends
3. **Custom Puzzles**: User-created puzzles
4. **Achievements**: Badge system for milestones
5. **Statistics**: Completion time, accuracy tracking
6. **Color Blind Mode**: Alternative color palettes
7. **Dark Mode**: Theme switching

### Technical Improvements
1. **CloudKit Sync**: Cross-device progress
2. **Puzzle Difficulty AI**: Adaptive difficulty based on performance
3. **Undo/Redo Stack**: Enhanced history management
4. **Puzzle Validation**: Verify premade puzzles on load
5. **Accessibility**: VoiceOver support, Dynamic Type
6. **Widget**: Today view with daily puzzle
7. **Apple Watch**: Companion app

---

## Debugging Tips

### Common Issues

1. **Sound Not Playing**:
   - Check audio files exist in bundle
   - Verify audio session setup
   - Check `isSoundEnabled` flag

2. **Puzzle Generation Hangs**:
   - Ensure async generation on background thread
   - Check for infinite loops in validation

3. **Premium Status Not Updating**:
   - Verify RevenueCat API key
   - Check entitlement name matches
   - Call `refreshSubscriptionStatus()` after purchase

4. **Layout Issues**:
   - Check `DeviceSizing` calculations
   - Verify safe area insets
   - Test on multiple device sizes

### Logging
- Sound Manager: Logs loading/playback status
- RevenueCat: Set `Purchases.logLevel = .debug`
- Firebase: Check Analytics debug view

---

## Build Configuration

### Info.plist Requirements
- Privacy descriptions for audio usage
- RevenueCat API key
- Firebase configuration

### Capabilities
- In-App Purchase
- Push Notifications (optional)

### Dependencies
- RevenueCat SDK
- RevenueCatUI
- Firebase Analytics

---

## Conclusion

Kidsdoku2 is a well-architected SwiftUI app with:
- ✅ Clean MVVM separation
- ✅ Reactive state management via Combine
- ✅ Performance-optimized rendering
- ✅ Comprehensive theming system
- ✅ Robust puzzle generation algorithm
- ✅ Premium monetization via RevenueCat
- ✅ Progress tracking and ratings
- ✅ Accessible and localized

The codebase is maintainable, extensible, and ready for future enhancements.
