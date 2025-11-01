import Foundation

enum SymbolGroup: Int, CaseIterable, Hashable {
    case animals = 1
    case fruits = 2
    case sports = 3
    case weather = 4
    case vehicles = 5
    case nature = 6
    
    var symbols: [String] {
        switch self {
        case .animals:
            return ["🐶", "🐱", "🐻", "🐼", "🐸", "🦊"]
        case .fruits:
            return ["🍎", "🍊", "🍓", "🍉", "🍇", "🍌"]
        case .sports:
            return ["⚽️", "🏀", "⚾️", "🎾", "🏈", "🏐"]
        case .weather:
            return ["☀️", "⛅️", "☁️", "🌧️", "⚡️", "🌈"]
        case .vehicles:
            return ["🚗", "🚕", "🚙", "🚌", "🚎", "🏎️"]
        case .nature:
            return ["🌸", "🌺", "🌻", "🌷", "🌹", "🌼"]
        }
    }
    
    var id: Int {
        return rawValue
    }
}

struct KidSudokuConfig: Hashable {
    let size: Int
    let subgridRows: Int
    let subgridCols: Int
    let symbolGroup: SymbolGroup
    
    var symbols: [String] {
        return Array(symbolGroup.symbols.prefix(size))
    }

    static let fourByFour = KidSudokuConfig(
        size: 4,
        subgridRows: 2,
        subgridCols: 2,
        symbolGroup: .sports
    )

    static let sixBySix = KidSudokuConfig(
        size: 6,
        subgridRows: 2,
        subgridCols: 3,
        symbolGroup: .fruits
    )

    static func configuration(for size: Int) -> KidSudokuConfig? {
        switch size {
        case 4:
            return .fourByFour
        case 6:
            return .sixBySix
        default:
            return nil
        }
    }
}

struct KidSudokuPosition: Hashable {
    let row: Int
    let col: Int
}

struct KidSudokuCell: Identifiable {
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
}

enum PuzzleDifficulty: String, CaseIterable, Hashable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
}

struct PredefinedPuzzle: Identifiable, Hashable {
    let id: Int
    let size: Int
    let difficulty: PuzzleDifficulty
    let board: [[Int?]]
    let solution: [[Int]]
    
    var displayNumber: String {
        return "\(id)"
    }
}

enum KidSudokuRoute: Hashable {
    case puzzleSelection(size: Int)
    case game(size: Int, puzzleId: Int?)
}

enum PredefinedPuzzles {
    static func puzzles(for size: Int) -> [PredefinedPuzzle] {
        switch size {
        case 4:
            return fourByFourPuzzles
        case 6:
            return sixBySixPuzzles
        default:
            return []
        }
    }
    
    private static let fourByFourPuzzles: [PredefinedPuzzle] = [
        // Easy puzzles (more givens)
        PredefinedPuzzle(
            id: 1,
            size: 4,
            difficulty: .easy,
            board: [
                [0, nil, nil, 3],
                [nil, 3, 0, nil],
                [nil, 2, 3, nil],
                [3, nil, nil, 2]
            ],
            solution: [
                [0, 1, 2, 3],
                [2, 3, 0, 1],
                [1, 2, 3, 0],
                [3, 0, 1, 2]
            ]
        ),
        PredefinedPuzzle(
            id: 2,
            size: 4,
            difficulty: .easy,
            board: [
                [nil, 2, nil, 0],
                [3, nil, 2, nil],
                [nil, 3, nil, 2],
                [2, nil, 0, nil]
            ],
            solution: [
                [1, 2, 3, 0],
                [3, 0, 2, 1],
                [0, 3, 1, 2],
                [2, 1, 0, 3]
            ]
        ),
        PredefinedPuzzle(
            id: 3,
            size: 4,
            difficulty: .easy,
            board: [
                [nil, nil, 1, 2],
                [1, nil, nil, 0],
                [0, nil, nil, 1],
                [2, 1, nil, nil]
            ],
            solution: [
                [3, 0, 1, 2],
                [1, 2, 3, 0],
                [0, 3, 2, 1],
                [2, 1, 0, 3]
            ]
        ),
        // Normal puzzles (medium givens)
        PredefinedPuzzle(
            id: 4,
            size: 4,
            difficulty: .normal,
            board: [
                [nil, 1, nil, nil],
                [nil, nil, 0, 1],
                [1, 0, nil, nil],
                [nil, nil, 1, nil]
            ],
            solution: [
                [2, 1, 3, 0],
                [3, 2, 0, 1],
                [1, 0, 2, 3],
                [0, 3, 1, 2]
            ]
        ),
        PredefinedPuzzle(
            id: 5,
            size: 4,
            difficulty: .normal,
            board: [
                [3, nil, nil, nil],
                [nil, nil, 3, 2],
                [2, 3, nil, nil],
                [nil, nil, nil, 3]
            ],
            solution: [
                [3, 0, 1, 2],
                [1, 2, 3, 0],
                [2, 3, 0, 1],
                [0, 1, 2, 3]
            ]
        ),
        PredefinedPuzzle(
            id: 6,
            size: 4,
            difficulty: .normal,
            board: [
                [nil, nil, 2, nil],
                [2, nil, nil, 0],
                [0, nil, nil, 2],
                [nil, 2, nil, nil]
            ],
            solution: [
                [1, 0, 2, 3],
                [2, 3, 1, 0],
                [0, 1, 3, 2],
                [3, 2, 0, 1]
            ]
        ),
        // Hard puzzles (fewer givens)
        PredefinedPuzzle(
            id: 7,
            size: 4,
            difficulty: .hard,
            board: [
                [nil, nil, nil, 1],
                [nil, 1, 2, nil],
                [nil, 2, 1, nil],
                [1, nil, nil, nil]
            ],
            solution: [
                [2, 3, 0, 1],
                [0, 1, 2, 3],
                [3, 2, 1, 0],
                [1, 0, 3, 2]
            ]
        ),
        PredefinedPuzzle(
            id: 8,
            size: 4,
            difficulty: .hard,
            board: [
                [nil, nil, 3, nil],
                [3, nil, nil, 1],
                [1, nil, nil, 3],
                [nil, 3, nil, nil]
            ],
            solution: [
                [0, 1, 3, 2],
                [3, 2, 0, 1],
                [1, 0, 2, 3],
                [2, 3, 1, 0]
            ]
        ),
        PredefinedPuzzle(
            id: 9,
            size: 4,
            difficulty: .hard,
            board: [
                [nil, 0, nil, nil],
                [nil, nil, 0, nil],
                [nil, 3, nil, nil],
                [nil, nil, 3, 0]
            ],
            solution: [
                [2, 0, 1, 3],
                [3, 1, 0, 2],
                [0, 3, 2, 1],
                [1, 2, 3, 0]
            ]
        )
    ]
    
    private static let sixBySixPuzzles: [PredefinedPuzzle] = [
        // Easy puzzles
        PredefinedPuzzle(
            id: 1,
            size: 6,
            difficulty: .easy,
            board: [
                [0, nil, 2, nil, 4, nil],
                [nil, 4, nil, 2, nil, 0],
                [2, nil, 0, nil, 1, nil],
                [nil, 1, nil, 0, nil, 2],
                [4, nil, 1, nil, 0, nil],
                [nil, 0, nil, 4, nil, 1]
            ],
            solution: [
                [0, 3, 2, 1, 4, 5],
                [5, 4, 3, 2, 1, 0],
                [2, 5, 0, 3, 1, 4],
                [3, 1, 4, 0, 5, 2],
                [4, 2, 1, 5, 0, 3],
                [1, 0, 5, 4, 2, 3]
            ]
        ),
        PredefinedPuzzle(
            id: 2,
            size: 6,
            difficulty: .easy,
            board: [
                [nil, 1, nil, 3, nil, 5],
                [3, nil, 5, nil, 1, nil],
                [nil, 3, 1, nil, 5, nil],
                [nil, 5, nil, 1, 3, nil],
                [nil, 0, nil, 5, nil, 3],
                [5, nil, 3, nil, 0, nil]
            ],
            solution: [
                [0, 1, 2, 3, 4, 5],
                [3, 4, 5, 0, 1, 2],
                [2, 3, 1, 4, 5, 0],
                [4, 5, 0, 1, 3, 2],
                [1, 0, 4, 5, 2, 3],
                [5, 2, 3, 1, 0, 4]
            ]
        ),
        PredefinedPuzzle(
            id: 3,
            size: 6,
            difficulty: .easy,
            board: [
                [1, nil, nil, 4, nil, nil],
                [nil, 4, 5, nil, nil, 1],
                [nil, nil, 1, 5, 4, nil],
                [nil, 5, 4, 1, nil, nil],
                [4, nil, nil, 0, 5, nil],
                [nil, nil, 0, nil, nil, 4]
            ],
            solution: [
                [1, 2, 3, 4, 0, 5],
                [0, 4, 5, 2, 3, 1],
                [3, 0, 1, 5, 4, 2],
                [2, 5, 4, 1, 3, 0],
                [4, 3, 2, 0, 5, 1],
                [5, 1, 0, 3, 2, 4]
            ]
        ),
        // Normal puzzles
        PredefinedPuzzle(
            id: 4,
            size: 6,
            difficulty: .normal,
            board: [
                [nil, nil, 3, nil, nil, 2],
                [nil, 2, nil, 3, nil, nil],
                [3, nil, nil, 2, nil, nil],
                [nil, nil, 2, nil, nil, 3],
                [nil, nil, 5, nil, 2, nil],
                [2, nil, nil, 5, nil, nil]
            ],
            solution: [
                [1, 0, 3, 4, 5, 2],
                [4, 2, 5, 3, 1, 0],
                [3, 5, 1, 2, 0, 4],
                [0, 4, 2, 1, 5, 3],
                [5, 3, 0, 4, 2, 1],
                [2, 1, 4, 5, 3, 0]
            ]
        ),
        PredefinedPuzzle(
            id: 5,
            size: 6,
            difficulty: .normal,
            board: [
                [nil, 4, nil, nil, 1, nil],
                [1, nil, nil, 4, nil, nil],
                [nil, 1, 4, nil, nil, nil],
                [nil, nil, nil, 1, 4, nil],
                [nil, nil, 1, nil, nil, 4],
                [nil, 5, nil, nil, 0, nil]
            ],
            solution: [
                [0, 4, 2, 5, 1, 3],
                [1, 3, 5, 4, 0, 2],
                [2, 1, 4, 3, 5, 0],
                [3, 0, 5, 1, 4, 2],
                [5, 2, 1, 0, 3, 4],
                [4, 5, 3, 2, 0, 1]
            ]
        ),
        PredefinedPuzzle(
            id: 6,
            size: 6,
            difficulty: .normal,
            board: [
                [5, nil, nil, nil, nil, 4],
                [nil, nil, 4, 5, nil, nil],
                [nil, 5, nil, nil, 4, nil],
                [nil, 4, nil, nil, 5, nil],
                [nil, nil, 5, 4, nil, nil],
                [4, nil, nil, nil, nil, 5]
            ],
            solution: [
                [5, 2, 1, 3, 0, 4],
                [3, 0, 4, 5, 2, 1],
                [1, 5, 3, 2, 4, 0],
                [0, 4, 2, 1, 5, 3],
                [2, 3, 5, 4, 1, 0],
                [4, 1, 0, 2, 3, 5]
            ]
        ),
        // Hard puzzles
        PredefinedPuzzle(
            id: 7,
            size: 6,
            difficulty: .hard,
            board: [
                [nil, nil, nil, 3, nil, nil],
                [3, nil, nil, nil, nil, 1],
                [nil, 3, nil, nil, 1, nil],
                [nil, 1, nil, nil, 3, nil],
                [1, nil, nil, nil, nil, 3],
                [nil, nil, 3, nil, nil, nil]
            ],
            solution: [
                [2, 4, 5, 3, 0, 1],
                [3, 0, 4, 2, 5, 1],
                [4, 3, 2, 5, 1, 0],
                [0, 1, 5, 4, 3, 2],
                [1, 5, 0, 4, 2, 3],
                [5, 2, 3, 1, 4, 0]
            ]
        ),
        PredefinedPuzzle(
            id: 8,
            size: 6,
            difficulty: .hard,
            board: [
                [nil, nil, 2, nil, nil, 5],
                [nil, 5, nil, 2, nil, nil],
                [2, nil, nil, 5, nil, nil],
                [nil, nil, 5, nil, nil, 2],
                [nil, nil, 4, nil, 5, nil],
                [5, nil, nil, 4, nil, nil]
            ],
            solution: [
                [1, 3, 2, 0, 4, 5],
                [4, 5, 1, 2, 3, 0],
                [2, 4, 3, 5, 0, 1],
                [3, 0, 5, 1, 4, 2],
                [0, 2, 4, 3, 5, 1],
                [5, 1, 0, 4, 2, 3]
            ]
        ),
        PredefinedPuzzle(
            id: 9,
            size: 6,
            difficulty: .hard,
            board: [
                [nil, 0, nil, nil, nil, nil],
                [nil, nil, nil, 0, nil, nil],
                [nil, nil, 0, nil, nil, nil],
                [nil, nil, nil, nil, 0, nil],
                [nil, nil, nil, 5, nil, nil],
                [nil, nil, nil, nil, nil, 0]
            ],
            solution: [
                [3, 0, 1, 2, 4, 5],
                [2, 4, 5, 0, 3, 1],
                [1, 5, 0, 3, 2, 4],
                [4, 3, 2, 1, 0, 5],
                [0, 2, 4, 5, 1, 3],
                [5, 1, 3, 4, 2, 0]
            ]
        )
    ]
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

