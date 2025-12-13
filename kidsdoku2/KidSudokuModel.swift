import Foundation

import SwiftUI

enum SymbolGroup: Int, CaseIterable, Hashable {
    case animals = 1
    case birds2
    case animals3
    case weather
    case sea
    case birds
    case animals2
    case birds3
    case birds4
    case animals4
    case numbers
    case animalItems
    case christmas1
    case christmas2
    case christmas3
    case christmas4

    var symbols: [String] {
            switch self {
            case .animals:
                return ["animal1", "animal1", "animal2", "animal4", "animal8", "animal10", "animal15"]
            case .animals2:
                return ["animal3", "animal3", "animal6", "animal12", "animal14", "animal15", "animal10"]
            case .birds2:
                return ["bird_2_11", "bird_2_11", "bird_2_12", "bird_2_13", "bird_2_14", "bird_2_15", "bird_2_10"]
            case .birds3:
                return ["bird_2_1", "bird_2_1", "bird_2_2", "bird_2_3", "bird_2_4", "bird_2_5", "bird_2_6"]
            case .animals3:
                return ["animal_2_6", "animal_2_6", "animal_2_7", "animal_2_8", "animal_2_9", "animal_2_10", "animal_2_11"]
            case .animals4:
                return ["animal_2_1", "animal_2_1", "animal_2_3", "animal_2_5", "animal_2_4", "animal_2_12", "animal_2_13"]
            case .weather:
                return ["sea6", "sea6", "sea8", "sea10", "sea12", "sea14", "sea1"]
            case .sea:
                return ["sea7", "sea7", "sea11", "sea3", "sea5", "sea9", "sea13"]
            case .birds:
                return ["bird1", "bird1", "bird4", "bird6", "bird7", "bird9", "bird13"]
            case .birds4:
                return ["bird2", "bird2", "bird3", "bird5", "bird14", "bird15", "bird11"]
            case .numbers:
                return ["number1", "number1", "number2", "number3", "number4", "number5", "number6"]
            case .animalItems:
                return ["animal_with_item_1", "animal_with_item_1", "animal_with_item_2", "animal_with_item_3", "animal_with_item_4", "animal_with_item_5", "animal_with_item_6"]
            case .christmas1:
                return ["christmas_1", "christmas_1", "christmas_2", "christmas_6", "christmas_4", "christmas_5", "christmas_3"]
            case .christmas2:
                return ["christmas_8", "christmas_8", "christmas_7", "christmas_9", "christmas_10", "christmas_11", "christmas_12"]
            case .christmas3:
                return ["christmas_13", "christmas_13", "christmas_9", "christmas_12", "christmas_4", "christmas_5", "christmas_3"]
            case .christmas4:
                return ["christmas_2", "christmas_2", "christmas_5", "christmas_9", "christmas_10", "christmas_8", "christmas_11"]
            }
        }
    
    var id: Int {
        return rawValue
    }
    
    var paletteTitle: String {
        switch self {
        case .animals, .animals2, .animals3, .animals4, .animalItems:
            return String(localized: "Safari Camp")
        case .sea, .weather:
            return String(localized: "Coral Reef")
        case .birds, .birds2, .birds3, .birds4:
            return String(localized: "Bird's Nest")
        case .numbers:
            return String(localized: "Numbers")
        case .christmas1, .christmas2, .christmas3, .christmas4:
            return String(localized: "Christmas Box")
        }
    }
    
    static var puzzleCases: [SymbolGroup] {
        return [.animalItems, .animals, .animals2, .animals3, .animals4, .birds, .birds2, .birds3, .birds4, .sea, .weather]
    }
    
    static var christmasCases: [SymbolGroup] {
        return [.christmas1, .christmas3, .christmas4, .christmas2]
    }
}

struct KidSudokuConfig: Hashable {
    let size: Int
    let subgridRows: Int
    let subgridCols: Int
    let symbolGroup: SymbolGroup
    
    var symbols: [String] {
        return Array(symbolGroup.symbols)
    }

    static let threeByThree = KidSudokuConfig(
        size: 3,
        subgridRows: 1,
        subgridCols: 3,
        symbolGroup: .animals
    )

    static let fourByFour = KidSudokuConfig(
        size: 4,
        subgridRows: 2,
        subgridCols: 2,
        symbolGroup: .birds2
    )

    static let sixBySix = KidSudokuConfig(
        size: 6,
        subgridRows: 2,
        subgridCols: 3,
        symbolGroup: .birds2
    )

    static func configuration(for size: Int) -> KidSudokuConfig? {
        switch size {
        case 3:
            return .threeByThree
        case 4:
            return .fourByFour
        case 6:
            return .sixBySix
        default:
            return nil
        }
    }
}

struct KidSudokuPosition: Hashable, Equatable {
    let row: Int
    let col: Int
}

struct KidSudokuCell: Identifiable, Equatable {
    let id: Int
    let position: KidSudokuPosition
    var value: Int?
    let solution: Int
    let isFixed: Bool

    init(row: Int, col: Int, value: Int?, solution: Int, isFixed: Bool, boardSize: Int) {
        self.id = row * boardSize + col
        self.position = KidSudokuPosition(row: row, col: col)
        self.value = value
        self.solution = solution
        self.isFixed = isFixed
    }
}

struct KidSudokuPuzzle {
    let config: KidSudokuConfig
    private(set) var cells: [KidSudokuCell]
    let solution: [[Int]]

    init(config: KidSudokuConfig, cells: [KidSudokuCell], solution: [[Int]]) {
        self.config = config
        self.cells = cells
        self.solution = solution
    }
    
    init(from premadePuzzle: PremadePuzzle) {
        self.config = premadePuzzle.config
        self.solution = premadePuzzle.solutionBoard
        
        var cells: [KidSudokuCell] = []
        for row in 0..<premadePuzzle.size {
            for col in 0..<premadePuzzle.size {
                let value = premadePuzzle.initialBoard[row][col]
                let solutionValue = premadePuzzle.solutionBoard[row][col]
                let isFixed = value != nil
                let cell = KidSudokuCell(
                    row: row,
                    col: col,
                    value: value,
                    solution: solutionValue,
                    isFixed: isFixed,
                    boardSize: premadePuzzle.size
                )
                cells.append(cell)
            }
        }
        self.cells = cells
    }

    func cell(at position: KidSudokuPosition) -> KidSudokuCell {
        cells[position.row * config.size + position.col]
    }

    mutating func updateCell(at position: KidSudokuPosition, with value: Int?) {
        let index = position.row * config.size + position.col
        cells[index].value = value
    }
}

enum KidSudokuMessageType {
    case info
    case success
    case warning
}

struct KidSudokuMessage: Identifiable {
    let id = UUID()
    let text: String
    let type: KidSudokuMessageType
    let symbolImageName: String?
    
    init(text: String, type: KidSudokuMessageType, symbolImageName: String? = nil) {
        self.text = text
        self.type = type
        self.symbolImageName = symbolImageName
    }
}

enum KidSudokuRoute: Hashable {
    case game(size: Int)
    case puzzleSelection(size: Int, themeOverride: GameThemeType? = nil)
    case premadePuzzle(puzzle: PremadePuzzle)
    case settings
    case badges
}

enum PuzzleDifficulty: String, CaseIterable {
    case easy = "Easy"
    case normal = "Normal" 
    case hard = "Hard"
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .normal: return .orange
        case .hard: return .red
        }
    }
}

struct PremadePuzzle: Hashable, Identifiable {
    let id = UUID()
    let number: Int
    let size: Int
    let difficulty: PuzzleDifficulty
    let config: KidSudokuConfig
    let initialBoard: [[Int?]]
    let solutionBoard: [[Int]]
    
    var displayName: String {
        return String(localized: "Puzzle \(number)")
    }
    
    var displayEmoji: String {
        return config.symbolGroup.symbols.first ?? ""
    }
}

enum KidSudokuGenerator {
    static func generatePuzzle(config: KidSudokuConfig) -> KidSudokuPuzzle {
        var solution = generateCompleteBoard(config: config)
        shuffleBoard(&solution, config: config)

        var puzzleBoard = solution.map { row in row.map { Optional($0) } }
        carvePuzzle(board: &puzzleBoard, solution: solution, config: config)

        let cells = buildCells(from: puzzleBoard, solution: solution, config: config)
        return KidSudokuPuzzle(config: config, cells: cells, solution: solution)
    }

    private static func generateCompleteBoard(config: KidSudokuConfig) -> [[Int]] {
        let size = config.size
        let subCols = config.subgridCols
        let subRows = config.subgridRows
        var board = Array(repeating: Array(repeating: 0, count: size), count: size)

        for row in 0..<size {
            for col in 0..<size {
                board[row][col] = (row * subCols + row / subRows + col) % size
            }
        }
        return board
    }

    private static func shuffleBoard(_ board: inout [[Int]], config: KidSudokuConfig) {
        shuffleRows(&board, config: config)
        shuffleColumns(&board, config: config)
        permuteSymbols(&board, config: config)
    }

    private static func shuffleRows(_ board: inout [[Int]], config: KidSudokuConfig) {
        let size = config.size
        let blockHeight = config.subgridRows
        let blockCount = size / blockHeight
        var newRows: [[Int]] = []

        var groupOrder = Array(0..<blockCount)
        groupOrder.shuffle()

        for group in groupOrder {
            var rowsInGroup: [[Int]] = []
            for offset in 0..<blockHeight {
                rowsInGroup.append(board[group * blockHeight + offset])
            }
            rowsInGroup.shuffle()
            newRows.append(contentsOf: rowsInGroup)
        }

        board = newRows
    }

    private static func shuffleColumns(_ board: inout [[Int]], config: KidSudokuConfig) {
        let size = config.size
        let blockWidth = config.subgridCols
        let blockCount = size / blockWidth

        var columns = (0..<size).map { columnIndex in
            board.map { $0[columnIndex] }
        }

        var newColumns: [[Int]] = []
        var groupOrder = Array(0..<blockCount)
        groupOrder.shuffle()

        for group in groupOrder {
            var colsInGroup: [[Int]] = []
            for offset in 0..<blockWidth {
                colsInGroup.append(columns[group * blockWidth + offset])
            }
            colsInGroup.shuffle()
            newColumns.append(contentsOf: colsInGroup)
        }

        for col in 0..<size {
            for row in 0..<size {
                board[row][col] = newColumns[col][row]
            }
        }
    }

    private static func permuteSymbols(_ board: inout [[Int]], config: KidSudokuConfig) {
        let permutation = Array(0..<config.size).shuffled()
        for row in 0..<config.size {
            for col in 0..<config.size {
                board[row][col] = permutation[board[row][col]]
            }
        }
    }

    private static func carvePuzzle(board: inout [[Int?]], solution: [[Int]], config: KidSudokuConfig) {
        let size = config.size
        let totalCells = size * size
        let targetGivens: Int

        switch size {
        case 3:
            targetGivens = 4
        case 4:
            targetGivens = 8
        case 6:
            targetGivens = 14
        default:
            targetGivens = Int(Double(totalCells) * 0.4)
        }

        var positions = Array(0..<totalCells)
        positions.shuffle()

        var givens = totalCells
        for index in positions {
            guard givens > targetGivens else { break }

            let row = index / size
            let col = index % size
            guard board[row][col] != nil else { continue }

            let backup = board[row][col]
            board[row][col] = nil

            if !hasUniqueSolution(board: board, config: config) {
                board[row][col] = backup
            } else {
                givens -= 1
            }
        }
    }

    private static func hasUniqueSolution(board: [[Int?]], config: KidSudokuConfig) -> Bool {
        var mutableBoard = board
        let solutions = countSolutions(board: &mutableBoard, config: config, limit: 2)
        return solutions == 1
    }

    private static func countSolutions(board: inout [[Int?]], config: KidSudokuConfig, limit: Int) -> Int {
        guard let position = nextEmptyCell(board, config: config) else {
            return 1
        }

        var total = 0
        for candidate in 0..<config.size {
            if isValid(candidate, at: position, in: board, config: config) {
                board[position.row][position.col] = candidate
                total += countSolutions(board: &board, config: config, limit: limit)
                board[position.row][position.col] = nil

                if total >= limit {
                    break
                }
            }
        }
        return total
    }

    private static func nextEmptyCell(_ board: [[Int?]], config: KidSudokuConfig) -> KidSudokuPosition? {
        for row in 0..<config.size {
            for col in 0..<config.size {
                if board[row][col] == nil {
                    return KidSudokuPosition(row: row, col: col)
                }
            }
        }
        return nil
    }

    private static func isValid(_ value: Int, at position: KidSudokuPosition, in board: [[Int?]], config: KidSudokuConfig) -> Bool {
        let size = config.size

        for index in 0..<size {
            if board[position.row][index] == value || board[index][position.col] == value {
                return false
            }
        }

        let subgridRowStart = (position.row / config.subgridRows) * config.subgridRows
        let subgridColStart = (position.col / config.subgridCols) * config.subgridCols

        for row in subgridRowStart..<(subgridRowStart + config.subgridRows) {
            for col in subgridColStart..<(subgridColStart + config.subgridCols) {
                if board[row][col] == value {
                    return false
                }
            }
        }
        return true
    }

    private static func buildCells(from board: [[Int?]], solution: [[Int]], config: KidSudokuConfig) -> [KidSudokuCell] {
        var cells: [KidSudokuCell] = []
        cells.reserveCapacity(config.size * config.size)

        for row in 0..<config.size {
            for col in 0..<config.size {
                let currentValue = board[row][col]
                let isFixed = currentValue != nil
                let cell = KidSudokuCell(
                    row: row,
                    col: col,
                    value: currentValue,
                    solution: solution[row][col],
                    isFixed: isFixed,
                    boardSize: config.size
                )
                cells.append(cell)
            }
        }
        return cells
    }
}

