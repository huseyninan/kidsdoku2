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
    private var correctCellCount: Int = 0
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
                self.correctCellCount = generatedPuzzle.cells.filter { $0.value == $0.solution }.count
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
        self.correctCellCount = puzzle.cells.filter { $0.value == $0.solution }.count
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
                    self.correctCellCount = generatedPuzzle.cells.filter { $0.value == $0.solution }.count
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
                let oldValue = cell.value
                moveHistory.append((position: cell.position, oldValue: oldValue))
                puzzle.updateCell(at: cell.position, with: paletteSymbol)
                updateFilledCount()
                updateCorrectCount(at: cell.position, oldValue: oldValue, newValue: paletteSymbol)
                highlightedValue = paletteSymbol
                let isCompleted = checkForCompletion()
                if !isCompleted {
                    soundManager.play(.correctPlacement, volume: 0.6)
                }
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
            let oldValue = cell.value
            moveHistory.append((position: position, oldValue: oldValue))
            puzzle.updateCell(at: position, with: nil)
            updateFilledCount()
            updateCorrectCount(at: position, oldValue: oldValue, newValue: nil)
            selectedPosition = nil
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
            let oldValue = cell.value
            moveHistory.append((position: position, oldValue: oldValue))
            puzzle.updateCell(at: position, with: nil)
            updateFilledCount()
            updateCorrectCount(at: position, oldValue: oldValue, newValue: nil)
            return
        }

        if isValid(symbolIndex, at: position) {
            let oldValue = cell.value
            moveHistory.append((position: position, oldValue: oldValue))
            puzzle.updateCell(at: position, with: symbolIndex)
            updateFilledCount()
            updateCorrectCount(at: position, oldValue: oldValue, newValue: symbolIndex)
            highlightedValue = symbolIndex
            message = nil
            let isCompleted = checkForCompletion()
            if !isCompleted {
                soundManager.play(.correctPlacement, volume: 0.6)
            }
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

    private func checkForCompletion() -> Bool {
        // Use incremental tracking instead of O(n²) iteration
        guard correctCellCount == totalCellCount else {
            return false
        }
        showCelebration = true
        stopTimer()
        message = KidSudokuMessage(text: String(localized: "Amazing! Puzzle complete!"), type: .success)
        soundManager.play(.victory, volume: 0.7)
        
        // Mark premade puzzle as completed
        if let premadePuzzle = originalPremadePuzzle {
            premadePuzzle.markAsSolved()
            PuzzleCompletionManager.shared.setRating(calculateStars(), for: premadePuzzle)
        }
        
        return showCelebration
    }

    private func isValid(_ value: Int, at position: KidSudokuPosition) -> Bool {
        let size = config.size
        let cells = puzzleCells  // Cache once to avoid repeated computed property access

        for index in 0..<size {
            if index != position.col {
                let rowCellIndex = position.row * size + index
                if cells[rowCellIndex].value == value {
                    return false
                }
            }

            if index != position.row {
                let columnCellIndex = index * size + position.col
                if cells[columnCellIndex].value == value {
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
                if cells[index].value == value {
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
    
    /// Updates correct cell count incrementally when a cell value changes
    private func updateCorrectCount(at position: KidSudokuPosition, oldValue: Int?, newValue: Int?) {
        let cell = puzzle.cell(at: position)
        let wasCorrect = oldValue == cell.solution
        let isCorrect = newValue == cell.solution
        
        if wasCorrect && !isCorrect {
            correctCellCount -= 1
        } else if !wasCorrect && isCorrect {
            correctCellCount += 1
        }
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
            let oldValue = randomCell.value
            moveHistory.append((position: randomCell.position, oldValue: oldValue))
            puzzle.updateCell(at: randomCell.position, with: randomCell.solution)
            updateFilledCount()
            updateCorrectCount(at: randomCell.position, oldValue: oldValue, newValue: randomCell.solution)
            highlightedValue = randomCell.solution
            selectedPaletteSymbol = randomCell.solution
            message = KidSudokuMessage(text: String(localized: "Here's a hint! ✨"), type: .info)
            
            // Check if this completes the puzzle
            let isCompleted = checkForCompletion()
            if !isCompleted {
                soundManager.play(.hint, volume: 0.6)
            }
        }
    }
    
    func undo() {
        guard let lastMove = moveHistory.popLast() else {
            message = KidSudokuMessage(text: String(localized: "Nothing to undo!"), type: .info)
            return
        }
        
        let currentValue = puzzle.cell(at: lastMove.position).value
        puzzle.updateCell(at: lastMove.position, with: lastMove.oldValue)
        updateFilledCount()
        updateCorrectCount(at: lastMove.position, oldValue: currentValue, newValue: lastMove.oldValue)
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
                guard let self = self else {
                    // Self was deallocated, timer will be cleaned up
                    return
                }
                guard !self.showCelebration else { return }
                self.elapsedTime += 1
            }
    }
    
    func stopTimer() {
        guard isTimerRunning || timerCancellable != nil else { return }
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
        // Cancel timer subscription to prevent any further callbacks
        // Note: AnyCancellable.cancel() is thread-safe and can be called from deinit
        timerCancellable?.cancel()
        timerCancellable = nil
        
        // Cancel any ongoing puzzle generation task
        generationTask?.cancel()
        generationTask = nil
    }
}

