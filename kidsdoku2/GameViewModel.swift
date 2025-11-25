import Foundation
import SwiftUI
import Combine

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var puzzle: KidSudokuPuzzle
    @Published var selectedPosition: KidSudokuPosition?
    @Published var message: KidSudokuMessage?
    @Published var showCelebration = false
    @Published var highlightedValue: Int?
    @Published var selectedPaletteSymbol: Int?
    @Published private(set) var mistakeCount = 0
    @Published private(set) var hintCount = 0

    let config: KidSudokuConfig
    private let isPremadePuzzle: Bool
    private let originalPremadePuzzle: PremadePuzzle?
    private let soundManager = SoundManager.shared
    private var moveHistory: [(position: KidSudokuPosition, oldValue: Int?)] = []

    init(config: KidSudokuConfig) {
        self.config = config
        self.isPremadePuzzle = false
        self.originalPremadePuzzle = nil
        self.puzzle = KidSudokuGenerator.generatePuzzle(config: config)
        self.highlightedValue = nil
    }
    
    init(config: KidSudokuConfig, premadePuzzle: PremadePuzzle) {
        self.config = config
        self.isPremadePuzzle = true
        self.originalPremadePuzzle = premadePuzzle
        self.puzzle = KidSudokuPuzzle(from: premadePuzzle)
        self.highlightedValue = nil
    }

    func startNewPuzzle() {
        if let premadePuzzle = originalPremadePuzzle {
            puzzle = KidSudokuPuzzle(from: premadePuzzle)
        } else {
            puzzle = KidSudokuGenerator.generatePuzzle(config: config)
        }
        selectedPosition = nil
        message = KidSudokuMessage(text: String(localized: "New puzzle ready!"), type: .info)
        showCelebration = false
        highlightedValue = nil
        selectedPaletteSymbol = nil
        moveHistory.removeAll()
        mistakeCount = 0
        hintCount = 0
    }

    func select(position: KidSudokuPosition) {
        guard puzzle.cell(at: position).isFixed == false else { return }
        selectedPosition = position
        message = nil
    }

    func didTapCell(_ cell: KidSudokuCell) {
        message = nil
        
        // If cell is fixed, just highlight it
        if cell.isFixed {
            highlightedValue = cell.value
            return
        }
        
        // If a palette symbol is selected and the cell is empty, fill it
        if let paletteSymbol = selectedPaletteSymbol, cell.value == nil {
            if isValid(paletteSymbol, at: cell.position) {
                moveHistory.append((position: cell.position, oldValue: cell.value))
                objectWillChange.send()
                puzzle.updateCell(at: cell.position, with: paletteSymbol)
                highlightedValue = paletteSymbol
                soundManager.play(.correctPlacement, volume: 0.6)
                checkForCompletion()
            } else {
                mistakeCount += 1
                let symbol = config.symbols[paletteSymbol]
                message = KidSudokuMessage(text: String(localized: "That \(symbol) is already there!"), type: .warning)
                soundManager.play(.incorrectPlacement, volume: 0.5)
            }
            return
        }
        
        // Otherwise, select the cell and highlight its value
        selectedPosition = cell.position
        highlightedValue = cell.value
    }

    func clearSelection() {
        selectedPosition = nil
    }

    func removeValue() {
        guard let position = selectedPosition else {
            message = KidSudokuMessage(text: String(localized: "Tap a square first."), type: .info)
            return
        }

        var cell = puzzle.cell(at: position)
        guard cell.isFixed == false else { return }

        if cell.value != nil {
            moveHistory.append((position: position, oldValue: cell.value))
            objectWillChange.send()
            puzzle.updateCell(at: position, with: nil)
        }
    }
    
    func highlightSymbol(at symbolIndex: Int) {
        highlightedValue = symbolIndex
    }
    
    func selectPaletteSymbol(_ symbolIndex: Int) {
        selectedPaletteSymbol = symbolIndex
        highlightedValue = symbolIndex
        message = nil
    }

    func placeSymbol(at symbolIndex: Int) {
        guard let position = selectedPosition else {
            message = KidSudokuMessage(text: String(localized: "Tap a square first."), type: .info)
            return
        }

        var cell = puzzle.cell(at: position)
        guard cell.isFixed == false else { return }

        if cell.value == symbolIndex {
            moveHistory.append((position: position, oldValue: cell.value))
            objectWillChange.send()
            puzzle.updateCell(at: position, with: nil)
            return
        }

        if isValid(symbolIndex, at: position) {
            moveHistory.append((position: position, oldValue: cell.value))
            objectWillChange.send()
            puzzle.updateCell(at: position, with: symbolIndex)
            highlightedValue = symbolIndex
            message = nil
            soundManager.play(.correctPlacement, volume: 0.6)
            checkForCompletion()
        } else {
            mistakeCount += 1
            let symbol = config.symbols[symbolIndex]
            message = KidSudokuMessage(text: String(localized: "That \(symbol) is already there!"), type: .warning)
            soundManager.play(.incorrectPlacement, volume: 0.5)
        }
    }

    func displaySymbol(for cell: KidSudokuCell) -> String {
        if let value = cell.value {
            return config.symbols[value]
        }
        return ""
    }

    private func checkForCompletion() {
        for cell in puzzleCells {
            guard let value = cell.value, value == cell.solution else {
                return
            }
        }
        showCelebration = true
        message = KidSudokuMessage(text: String(localized: "Amazing! Puzzle complete!"), type: .success)
        soundManager.play(.victory, volume: 0.7)
        
        // Mark premade puzzle as completed
        if let premadePuzzle = originalPremadePuzzle {
            PuzzleCompletionManager.shared.markCompleted(puzzle: premadePuzzle)
            PuzzleCompletionManager.shared.setRating(calculateStars(), for: premadePuzzle)
        }
    }

    private func isValid(_ value: Int, at position: KidSudokuPosition) -> Bool {
        let size = config.size

        for index in 0..<size {
            if index != position.col {
                let rowCellIndex = position.row * size + index
                if puzzleCells[rowCellIndex].value == value {
                    return false
                }
            }

            if index != position.row {
                let columnCellIndex = index * size + position.col
                if puzzleCells[columnCellIndex].value == value {
                    return false
                }
            }
        }

        let startRow = (position.row / config.subgridRows) * config.subgridRows
        let startCol = (position.col / config.subgridCols) * config.subgridCols

        for row in startRow..<(startRow + config.subgridRows) {
            for col in startCol..<(startCol + config.subgridCols) {
                if row == position.row && col == position.col { continue }
                let index = row * size + col
                if puzzleCells[index].value == value {
                    return false
                }
            }
        }

        return true
    }

    private var puzzleCells: [KidSudokuCell] {
        puzzle.cells
    }
    
    var navigationTitle: String {
        if let premadePuzzle = originalPremadePuzzle {
            return "\(premadePuzzle.displayName)"
        } else {
            return String(localized: "\(config.size) x \(config.size) Puzzle")
        }
    }
    
    func provideHint() {
        // Find an empty cell that can be filled
        let emptyCells = puzzleCells.filter { !$0.isFixed && $0.value == nil }
        
        guard !emptyCells.isEmpty else {
            message = KidSudokuMessage(text: String(localized: "No hints available!"), type: .info)
            return
        }
        
        // Pick a random empty cell
        if let randomCell = emptyCells.randomElement() {
            hintCount += 1
            moveHistory.append((position: randomCell.position, oldValue: randomCell.value))
            objectWillChange.send()
            puzzle.updateCell(at: randomCell.position, with: randomCell.solution)
            highlightedValue = randomCell.solution
            selectedPosition = randomCell.position
            message = KidSudokuMessage(text: String(localized: "Here's a hint! ✨"), type: .info)
            soundManager.play(.hint, volume: 0.6)
            
            // Check if this completes the puzzle
            checkForCompletion()
        }
    }
    
    func undo() {
        guard let lastMove = moveHistory.popLast() else {
            message = KidSudokuMessage(text: String(localized: "Nothing to undo!"), type: .info)
            return
        }
        
        objectWillChange.send()
        puzzle.updateCell(at: lastMove.position, with: lastMove.oldValue)
        selectedPosition = lastMove.position
        highlightedValue = lastMove.oldValue
        message = nil
    }
    
    var canUndo: Bool {
        return !moveHistory.isEmpty
    }
    
    /// Calculate star rating based on mistakes and hints (0 to 3 stars with half-star increments)
    func calculateStars() -> Double {
        let totalPenalties = mistakeCount + hintCount
        
        switch totalPenalties {
        case 0:
            return 3.0  // Perfect!
        case 1...2:
            return 2.5
        case 3...4:
            return 2.0
        case 5...6:
            return 1.5
        case 7...8:
            return 1.0
        case 9...10:
            return 0.5
        default:
            return 0.0  // 11+ penalties
        }
    }
}

