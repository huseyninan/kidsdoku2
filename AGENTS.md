# AGENTS.md

## Cursor Cloud specific instructions

### Project overview

Kidsdoku2 is a **native iOS/SwiftUI app** — a kid-friendly Sudoku puzzle game. It is a single Xcode project (not a monorepo) with 26 Swift source files, no automated tests, and no CI/CD pipeline.

### Platform constraint

This project **requires macOS with Xcode 16+** to build and run. It cannot be compiled or executed on Linux because it depends on Apple-only frameworks (SwiftUI, UIKit, AVFoundation, Combine). The Cloud Agent VM runs Ubuntu Linux, so **full builds and iOS Simulator runs are not possible** in this environment.

### What CAN be done on Linux

| Task | Command | Notes |
|---|---|---|
| **Lint** | `swiftlint lint` | SwiftLint binary at `/usr/local/bin/swiftlint` (v0.57.1). Runs on all 26 `.swift` files. |
| **Syntax parse** | `swiftc -parse kidsdoku2/*.swift kidsdoku2/**/*.swift` | Requires `/opt/swift/usr/bin` in `PATH`. Validates Swift syntax without type-checking Apple frameworks. |
| **Code review** | Read/edit `.swift` files directly | All source is under `kidsdoku2/`. |

### What CANNOT be done on Linux

- `xcodebuild` (not available)
- Running the app in iOS Simulator
- SPM dependency resolution for Apple-platform packages (RevenueCat requires iOS SDK)
- Automated tests (none exist in the project, and XCTest requires Apple toolchain)

### Dependencies

- **Swift 6.0.3** installed at `/opt/swift/` — add `/opt/swift/usr/bin` to `PATH`.
- **SwiftLint 0.57.1** installed at `/usr/local/bin/swiftlint`.
- The only third-party dependency is **RevenueCat SDK v5.48.0** (via SPM, resolved in `kidsdoku2.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`).

### Key files

- Entry point: `kidsdoku2/kidsdoku2App.swift`
- Core model/puzzle logic: `kidsdoku2/KidSudokuModel.swift`
- Premade puzzles: `kidsdoku2/Models/PremadePuzzleStore.swift`
- Game logic: `kidsdoku2/GameView/GameViewModel.swift`
- Xcode scheme: `kidsdoku2.xcodeproj/xcshareddata/xcschemes/kidsdoku2.xcscheme`

### Building & running (macOS only)

See `APPLICATION_OVERVIEW.md` § "Building & Running" and `TECHNICAL_ARCHITECTURE.md` § "Minimum Requirements".
