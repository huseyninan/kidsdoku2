import Foundation
import SwiftUI
import Combine

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var puzzle: KidSudokuPuzzle
    @Published var selectedPosition: KidSudokuPosition?
    @Published var message: KidSudokuMessage?
    @Published private(set) var showCelebration = false
    @Published var highlightedValue: Int?
    @Published var selectedPaletteSymbol: Int?
    @Published private(set) var mistakeCount = 0
    @Published private(set) var hintCount = 0
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published var showNumbers: Bool = false {
        didSet { updateCurrentConfig() }
    }
    @Published var selectedSymbolGroupRawValue: Int {
        didSet { updateCurrentConfig() }
    }
    @Published private(set) var currentConfig: KidSudokuConfig
    @Published private(set) var filledCellCount: Int = 0
    @Published private(set) var isGeneratingPuzzle = false
    private(set) var validSymbolIndices: [Int] = []
    @Published private(set) var paletteSymbols: [(index: Int, symbol: String)] = []

    let config: KidSudokuConfig
    private let isPremadePuzzle: Bool
    private let originalPremadePuzzle: PremadePuzzle?
    private let soundManager = SoundManager.shared
    private var moveHistory: [(position: KidSudokuPosition, oldValue: Int?)] = []
    private var timerCancellable: AnyCancellable?
    private var isTimerRunning = false
    private var generationTask: Task<Void, Never>?
    
    var selectedSymbolGroup: SymbolGroup {
        SymbolGroup(rawValue: selectedSymbolGroupRawValue) ?? config.symbolGroup
    }
    
    private func updateCurrentConfig() {
        currentConfig = KidSudokuConfig(
            size: config.size,
            subgridRows: config.subgridRows,
            subgridCols: config.subgridCols,
            symbolGroup: showNumbers ? .numbers : selectedSymbolGroup
        )
        updatePaletteSymbols()
    }
    
    private func cacheSymbolData() {
        guard let firstRow = puzzle.solution.first else {
            validSymbolIndices = Array(0..<config.size)
            updatePaletteSymbols()
            return
        }
        validSymbolIndices = Array(Set(firstRow)).sorted()
        updatePaletteSymbols()
    }
    
    private func updatePaletteSymbols() {
        paletteSymbols = validSymbolIndices.map { index in
            (index: index, symbol: currentConfig.symbols[index])
        }
    }

    init(config: KidSudokuConfig) {
        self.config = config
        self.isPremadePuzzle = false
        self.originalPremadePuzzle = nil
        // Start with a placeholder puzzle while generating in background
        self.puzzle = Self.createPlaceholderPuzzle(config: config)
        self.highlightedValue = nil
        self.selectedSymbolGroupRawValue = config.symbolGroup.rawValue
        self.currentConfig = config
        self.filledCellCount = 0
        self.isGeneratingPuzzle = true
        cacheSymbolData()
        
        // Generate puzzle off the main thread
        generatePuzzleAsync(config: config)
    }
    
    /// Creates a placeholder puzzle with empty cells for initial display
    private static func createPlaceholderPuzzle(config: KidSudokuConfig) -> KidSudokuPuzzle {
        let size = config.size
        var cells: [KidSudokuCell] = []
        let emptySolution = Array(repeating: Array(repeating: 0, count: size), count: size)
        
        for row in 0..<size {
            for col in 0..<size {
                cells.append(KidSudokuCell(
                    row: row,
                    col: col,
                    value: nil,
                    solution: 0,
                    isFixed: false,
                    boardSize: size
                ))
            }
        }
        return KidSudokuPuzzle(config: config, cells: cells, solution: emptySolution)
    }
    
    /// Generates puzzle on a background thread and updates the view model when complete
    private func generatePuzzleAsync(config: KidSudokuConfig) {
        generationTask = Task.detached(priority: .userInitiated) {
            let generatedPuzzle = KidSudokuGenerator.generatePuzzle(config: config)
            await MainActor.run {
                self.puzzle = generatedPuzzle
                self.filledCellCount = generatedPuzzle.cells.filter { $0.value != nil }.count
                self.isGeneratingPuzzle = false
                self.cacheSymbolData()
            }
        }
    }
    
    init(config: KidSudokuConfig, premadePuzzle: PremadePuzzle) {
        self.config = config
        self.isPremadePuzzle = true
        self.originalPremadePuzzle = premadePuzzle
        self.puzzle = KidSudokuPuzzle(from: premadePuzzle)
        self.highlightedValue = nil
        self.selectedSymbolGroupRawValue = config.symbolGroup.rawValue
        self.currentConfig = config
        self.filledCellCount = puzzle.cells.filter { $0.value != nil }.count
        cacheSymbolData()
    }

    func startNewPuzzle() {
        // Cancel any ongoing generation
        generationTask?.cancel()
        
        selectedPosition = nil
        showCelebration = false
        highlightedValue = nil
        selectedPaletteSymbol = nil
        moveHistory.removeAll()
        mistakeCount = 0
        hintCount = 0
        resetTimer()
        
        if let premadePuzzle = originalPremadePuzzle {
            puzzle = KidSudokuPuzzle(from: premadePuzzle)
            updateFilledCount()
            cacheSymbolData()
            message = KidSudokuMessage(text: String(localized: "New puzzle ready!"), type: .info)
            startTimer()
        } else {
            // Generate new puzzle in background
            puzzle = Self.createPlaceholderPuzzle(config: config)
            filledCellCount = 0
            isGeneratingPuzzle = true
            cacheSymbolData()
            
            generationTask = Task.detached(priority: .userInitiated) {
                let generatedPuzzle = KidSudokuGenerator.generatePuzzle(config: self.config)
                await MainActor.run {
                    self.puzzle = generatedPuzzle
                    self.filledCellCount = generatedPuzzle.cells.filter { $0.value != nil }.count
                    self.isGeneratingPuzzle = false
                    self.cacheSymbolData()
                    self.message = KidSudokuMessage(text: String(localized: "New puzzle ready!"), type: .info)
                    self.startTimer()
                }
            }
        }
    }

    func select(position: KidSudokuPosition) {
        guard puzzle.cell(at: position).isFixed == false else { return }
        selectedPosition = position
        message = nil
    }

    func didTapCell(_ cell: KidSudokuCell) {
        message = nil
        
        // If cell is fixed, just highlight it and select it in the palette
        if cell.isFixed {
            highlightedValue = cell.value
            selectedPaletteSymbol = cell.value
            selectedPosition = nil
            return
        }
        
        // If a palette symbol is selected and the cell is empty, fill it
        if let paletteSymbol = selectedPaletteSymbol, cell.value == nil {
            if isValid(paletteSymbol, at: cell.position) {
                moveHistory.append((position: cell.position, oldValue: cell.value))
                puzzle.updateCell(at: cell.position, with: paletteSymbol)
                updateFilledCount()
                highlightedValue = paletteSymbol
                soundManager.play(.correctPlacement, volume: 0.6)
                checkForCompletion()
            } else {
                mistakeCount += 1
                guard paletteSymbol < config.symbols.count else {
                    print("⚠️ Symbol index \(paletteSymbol) out of bounds (max: \(config.symbols.count - 1))")
                    message = KidSudokuMessage(text: String(localized: "Invalid symbol!"), type: .warning)
                    soundManager.play(.incorrectPlacement, volume: 0.5)
                    return
                }
                let symbolImageName = config.symbols[paletteSymbol]
                message = KidSudokuMessage(text: String(localized: "That symbol is already there!"), type: .warning, symbolImageName: symbolImageName)
                soundManager.play(.incorrectPlacement, volume: 0.5)
            }
            return
        }
        
        // Otherwise, select the cell and highlight its value
        selectedPosition = cell.position
        highlightedValue = cell.value
        selectedPaletteSymbol = cell.value
    }

    func clearSelection() {
        selectedPosition = nil
    }

    func removeValue() {
        guard let position = selectedPosition else {
            message = KidSudokuMessage(text: String(localized: "Tap a square first."), type: .info)
            return
        }

        let cell = puzzle.cell(at: position)
        guard cell.isFixed == false else { return }

        if cell.value != nil {
            moveHistory.append((position: position, oldValue: cell.value))
            puzzle.updateCell(at: position, with: nil)
            updateFilledCount()
        }
    }
    
    func highlightSymbol(at symbolIndex: Int) {
        highlightedValue = symbolIndex
    }
    
    func selectPaletteSymbol(_ symbolIndex: Int) {
        selectedPaletteSymbol = symbolIndex
        highlightedValue = symbolIndex
        selectedPosition = nil
        message = nil
    }

    func placeSymbol(at symbolIndex: Int) {
        guard let position = selectedPosition else {
            message = KidSudokuMessage(text: String(localized: "Tap a square first."), type: .info)
            return
        }

        let cell = puzzle.cell(at: position)
        guard cell.isFixed == false else { return }

        if cell.value == symbolIndex {
            moveHistory.append((position: position, oldValue: cell.value))
            puzzle.updateCell(at: position, with: nil)
            updateFilledCount()
            return
        }

        if isValid(symbolIndex, at: position) {
            moveHistory.append((position: position, oldValue: cell.value))
            puzzle.updateCell(at: position, with: symbolIndex)
            updateFilledCount()
            highlightedValue = symbolIndex
            message = nil
            soundManager.play(.correctPlacement, volume: 0.6)
            checkForCompletion()
        } else {
            mistakeCount += 1
            guard symbolIndex < config.symbols.count else {
                print("⚠️ Symbol index \(symbolIndex) out of bounds (max: \(config.symbols.count - 1))")
                message = KidSudokuMessage(text: String(localized: "Invalid symbol!"), type: .warning)
                soundManager.play(.incorrectPlacement, volume: 0.5)
                return
            }
            let symbolImageName = config.symbols[symbolIndex]
            message = KidSudokuMessage(text: String(localized: "That symbol is already there!"), type: .warning, symbolImageName: symbolImageName)
            soundManager.play(.incorrectPlacement, volume: 0.5)
        }
    }

    func displaySymbol(for cell: KidSudokuCell) -> String {
        if let value = cell.value {
            guard value < config.symbols.count else {
                print("⚠️ Symbol value \(value) out of bounds (max: \(config.symbols.count - 1))")
                return "?"
            }
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
        stopTimer()
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
    
    private func updateFilledCount() {
        filledCellCount = puzzleCells.filter { $0.value != nil }.count
    }
    
    var totalCellCount: Int {
        config.size * config.size
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
            puzzle.updateCell(at: randomCell.position, with: randomCell.solution)
            updateFilledCount()
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
        
        puzzle.updateCell(at: lastMove.position, with: lastMove.oldValue)
        updateFilledCount()
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
    
    // MARK: - Timer Management
    
    func startTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, !self.showCelebration else { return }
                self.elapsedTime += 1
            }
    }
    
    func stopTimer() {
        isTimerRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    func resetTimer() {
        stopTimer()
        elapsedTime = 0
    }
    
    var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func showInitialMessage() {
        let paletteTitle = selectedSymbolGroup.paletteTitle
        message = KidSudokuMessage(
            text: String(localized: "Select a symbol from \(paletteTitle)"),
            type: .info
        )
    }
    
    deinit {
        // Cancel timer and task without calling MainActor methods
        timerCancellable?.cancel()
        generationTask?.cancel()
    }
}

