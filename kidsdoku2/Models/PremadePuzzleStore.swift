//
//  PremadePuzzleStore.swift
//  kidsdoku2
//
//  Created by hinan on 4.11.2025.
//

// MARK: - How to Add New Puzzles
//
// Use compact string notation where:
// - Each row is on a new line
// - Use '.' for empty cells
// - Use digits (0-5) for filled cells
// - Rows should have consistent spacing for readability
//
// Emoji can be auto-assigned or provided manually:
//   puzzle(1, 4, .easy, initial: "...", solution: "...")      // Auto emoji
//   puzzle(1, 4, .easy, "🎨", initial: "...", solution: "...")  // Custom emoji
//
// Example for 4x4:
//   initial:  "0..3"
//             "..0."
//             ".1.."
//             "2..1"
//   solution: "0213"
//             "3102"
//             "1320"
//             "2031"
//
// Then use the helper: puzzle(number: 1, size: 4, difficulty: .easy, initial: "...", solution: "...")

import Foundation
private let emojiPalette: [PuzzleDifficulty: [String]] = [
    .easy: ["☀️", "🌼", "🌻", "🌈", "🐣", "🦋", "🍓", "🍉", "🎈", "🎉"],
    .normal: ["🌿", "🌵", "🍄", "🍁", "🚲", "🚀", "🎯", "🎳", "🎨", "🎪"],
    .hard: ["💎", "🔮", "🌋", "🪄", "🧠", "🛰", "🪐", "🏆", "⚡️", "🧬"]
]

struct PremadePuzzleStore {
    static let shared = PremadePuzzleStore()
    
    // MARK: - 4x4 Puzzles
    private let fourByFourPuzzles: [PremadePuzzle] = [
        // Easy 4x4
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
                      """),
        
        puzzle(2, 4, .easy, "🌻",
               initial:  """
                      .2..
                      3..1
                      1..0
                      ..3.
                      """,
               solution: """
                      0213
                      3102
                      1320
                      2031
                      """),
        
        puzzle(3, 4, .easy, "🐞",
               initial:  """
                      ..20
                      .3..
                      ..1.
                      32..
                      """,
               solution: """
                      1023
                      2301
                      0132
                      3210
                      """),
        
        // Normal 4x4
        puzzle(1, 4, .normal, "🍄",
               initial:  """
                      ...3
                      .2..
                      ..1.
                      0...
                      """,
               solution: """
                      1023
                      3201
                      2310
                      0132
                      """),
        
        puzzle(2, 4, .normal, "🌿",
               initial:  """
                      2...
                      ..3.
                      .1..
                      ...0
                      """,
               solution: """
                      2301
                      1032
                      3120
                      0213
                      """),
        
        // Hard 4x4
        puzzle(1, 4, .hard, "💎",
               initial:  """
                      ....
                      .02.
                      .31.
                      ....
                      """,
               solution: """
                      3102
                      1023
                      0312
                      2130
                      """)
    ]
    
    // MARK: - 6x6 Puzzles
    private let sixBySixPuzzles: [PremadePuzzle] = [
        // Easy 6x6
        puzzle(1, 6, .easy,
               initial:  """
                      .234.6
                      4.612.
                      23.6.5
                      .643.2
                      .12.64
                      64523.
                      """,
               solution: """
                      123456
                      456123
                      231645
                      564312
                      312564
                      645231
                      """),
        
        puzzle(2, 6, .easy,
               initial:  """
                      9.82.4
                      25..68
                      6.95.2
                      5.2689
                      .964.5
                      42.89.
                      """,
               solution: """
                      968254
                      254968
                      689542
                      542689
                      896425
                      425896
                      """),
        
        puzzle(3, 6, .easy,
               initial:  """
                      .5792.
                      9.41.7
                      57.49.
                      .49.15
                      7.52..
                      49257.
                      """,
               solution: """
                      157924
                      924157
                      571492
                      249715
                      715249
                      492571
                      """),
        
        puzzle(4, 6, .easy,
               initial:  """
                      34.6.8
                      ..8.45
                      4.3..7
                      7.6534
                      534.86
                      86.453
                      """,
               solution: """
                      345678
                      678345
                      453867
                      786534
                      534786
                      867453
                      """),
        
        puzzle(5, 6, .easy,
               initial:  """
                      9.76.4
                      .549.7
                      7.8465
                      465..8
                      8.9546
                      .4.8.9
                      """,
               solution: """
                      987654
                      654987
                      798465
                      465798
                      879546
                      546879
                      """),
        
        puzzle(6, 6, .easy,
               initial:  """
                      876543
                      .4.8.6
                      76843.
                      4..7.8
                      6.73.4
                      35.6.7
                      """,
               solution: """
                      876543
                      543876
                      768435
                      435768
                      687354
                      354687
                      """),
        
        puzzle(7, 6, .easy,
               initial:  """
                      468.75
                      ..5468
                      84..97
                      5978..
                      68.759
                      .5.684
                      """,
               solution: """
                      468975
                      975468
                      846597
                      597846
                      684759
                      759684
                      """),
        
        puzzle(8, 6, .easy,
               initial:  """
                      643.21
                      .2.6.3
                      364.82
                      .8..6.
                      436218
                      .184.6
                      """,
               solution: """
                      643821
                      821643
                      364182
                      182364
                      436218
                      218436
                      """),
        
        puzzle(9, 6, .easy,
               initial:  """
                      4.6123
                      12..5.
                      5.42.1
                      231.64
                      64.312
                      .126.5
                      """,
               solution: """
                      456123
                      123456
                      564231
                      231564
                      645312
                      312645
                      """),
        
        puzzle(10, 6, .easy,
               initial:  """
                      2.6.31
                      83.246
                      6.41.3
                      183.24
                      .62..8
                      .18462
                      """,
               solution: """
                      246831
                      831246
                      624183
                      183624
                      462318
                      318462
                      """),
        
        // Normal 6x6
        puzzle(1, 6, .normal, "🌳",
               initial:  """
                      ....4.
                      .2....
                      ...1..
                      ..5...
                      ....3.
                      .1....
                      """,
               solution: """
                      132540
                      420315
                      503124
                      045231
                      254013
                      310452
                      """),
        
        // Hard 6x6
        puzzle(1, 6, .hard, "💠",
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
    ]
    
    // MARK: - Public Interface
    func puzzles(for size: Int) -> [PremadePuzzle] {
        switch size {
        case 4:
            return fourByFourPuzzles
        case 6:
            return sixBySixPuzzles
        default:
            return []
        }
    }
    
    func puzzles(for size: Int, difficulty: PuzzleDifficulty) -> [PremadePuzzle] {
        return puzzles(for: size).filter { $0.difficulty == difficulty }
    }
}


// MARK: - Puzzle Builder Helper
/// Creates a PremadePuzzle from compact string notation
/// - Parameters:
///   - number: Puzzle number within its difficulty level
///   - size: Board size (4 or 6)
///   - difficulty: Easy, Normal, or Hard
///   - emoji: Emoji to display for this puzzle
///   - initial: String representation of initial board (use '.' for empty cells)
///   - solution: String representation of solution board
/// - Returns: A validated PremadePuzzle
private func puzzle(
    _ number: Int,
    _ size: Int,
    _ difficulty: PuzzleDifficulty,
    _ emoji: String? = nil,
    initial: String,
    solution: String
) -> PremadePuzzle {
    let config: KidSudokuConfig = size == 4 ? .fourByFour : .sixBySix
    
    let initialBoard = parseBoard(initial, size: size)
    let solutionBoard = parseSolutionBoard(solution, size: size)
    
    // Validate boards
    assert(initialBoard.count == size, "Initial board must have \(size) rows")
    assert(solutionBoard.count == size, "Solution board must have \(size) rows")
    assert(initialBoard.allSatisfy { $0.count == size }, "All initial board rows must have \(size) columns")
    assert(solutionBoard.allSatisfy { $0.count == size }, "All solution board rows must have \(size) columns")
    
    let assignedEmoji = emoji ?? autoAssignEmoji(size: size, difficulty: difficulty, number: number)
    
    return PremadePuzzle(
        number: number,
        size: size,
        difficulty: difficulty,
        config: config,
        initialBoard: initialBoard,
        solutionBoard: solutionBoard,
        emoji: assignedEmoji
    )
}

private func autoAssignEmoji(size: Int, difficulty: PuzzleDifficulty, number: Int) -> String {
    let palette = emojiPalette[difficulty] ?? []
    let fallback = "🎯"
    guard !palette.isEmpty else { return fallback }
    guard let difficultyIndex = PuzzleDifficulty.allCases.firstIndex(of: difficulty) else {
        return palette.first ?? fallback
    }
    let seed = size * 100 + difficultyIndex * 10 + number
    let index = abs(seed) % palette.count
    return palette[index]
}

/// Parse a string representation into a board with optional cells
private func parseBoard(_ string: String, size: Int) -> [[Int?]] {
    let lines = string.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
    return lines.map { line in
        line.map { char in
            if char == "." {
                return nil
            } else if let digit = char.wholeNumberValue {
                return digit
            } else {
                fatalError("Invalid character '\(char)' in puzzle string")
            }
        }
    }
}

/// Parse a string representation into a complete solution board
private func parseSolutionBoard(_ string: String, size: Int) -> [[Int]] {
    let lines = string.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
    return lines.map { line in
        line.compactMap { char in
            if let digit = char.wholeNumberValue {
                return digit
            } else {
                fatalError("Invalid character '\(char)' in solution string")
            }
        }
    }
}
