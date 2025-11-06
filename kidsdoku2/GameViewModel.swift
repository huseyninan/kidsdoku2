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

    let config: KidSudokuConfig
    private let isPremadePuzzle: Bool
    private let originalPremadePuzzle: PremadePuzzle?
    private let soundManager = SoundManager.shared

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
        message = KidSudokuMessage(text: "New puzzle ready!", type: .info)
        showCelebration = false
        highlightedValue = nil
        selectedPaletteSymbol = nil
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
            soundManager.playHighlightSound()
            soundManager.playHaptic(style: .light)
            return
        }
        
        // If a palette symbol is selected and the cell is empty, fill it
        if let paletteSymbol = selectedPaletteSymbol, cell.value == nil {
            if isValid(paletteSymbol, at: cell.position) {
                soundManager.playCorrectPlacementSound()
                soundManager.playSuccessHaptic()
                objectWillChange.send()
                puzzle.updateCell(at: cell.position, with: paletteSymbol)
                highlightedValue = paletteSymbol
                checkForCompletion()
            } else {
                let symbol = config.symbols[paletteSymbol]
                message = KidSudokuMessage(text: "That \(symbol) is already there!", type: .warning)
                soundManager.playErrorSound()
                soundManager.playWarningHaptic()
            }
            return
        }
        
        // Otherwise, select the cell and highlight its value
        selectedPosition = cell.position
        highlightedValue = cell.value
        soundManager.playTapSound()
        soundManager.playHaptic(style: .light)
    }

    func clearSelection() {
        selectedPosition = nil
    }

    func removeValue() {
        guard let position = selectedPosition else {
            message = KidSudokuMessage(text: "Tap a square first.", type: .info)
            return
        }

        var cell = puzzle.cell(at: position)
        guard cell.isFixed == false else { return }

        if cell.value != nil {
            soundManager.playEraseSound()
            soundManager.playHaptic(style: .medium)
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
        soundManager.playSelectSound()
        soundManager.playHaptic(style: .light)
    }

    func placeSymbol(at symbolIndex: Int) {
        guard let position = selectedPosition else {
            message = KidSudokuMessage(text: "Tap a square first.", type: .info)
            return
        }

        var cell = puzzle.cell(at: position)
        guard cell.isFixed == false else { return }

        if cell.value == symbolIndex {
            soundManager.playEraseSound()
            soundManager.playHaptic(style: .medium)
            objectWillChange.send()
            puzzle.updateCell(at: position, with: nil)
            return
        }

        if isValid(symbolIndex, at: position) {
            soundManager.playCorrectPlacementSound()
            soundManager.playSuccessHaptic()
            objectWillChange.send()
            puzzle.updateCell(at: position, with: symbolIndex)
            highlightedValue = symbolIndex
            message = nil
            checkForCompletion()
        } else {
            let symbol = config.symbols[symbolIndex]
            message = KidSudokuMessage(text: "That \(symbol) is already there!", type: .warning)
            soundManager.playErrorSound()
            soundManager.playWarningHaptic()
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
        soundManager.playCelebrationSound()
        soundManager.playSuccessHaptic()
        showCelebration = true
        message = KidSudokuMessage(text: "Amazing! Puzzle complete!", type: .success)
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
            return "\(premadePuzzle.displayName) (\(premadePuzzle.difficulty.rawValue))"
        } else {
            return "\(config.size) x \(config.size) Puzzle"
        }
    }
}

