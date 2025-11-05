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
                      .234
                      3...
                      21.3
                      4.21
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(2, 4, .easy, "🌻",
               initial:  """
                      12.4
                      ..12
                      21.3
                      ..21
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(3, 4, .easy, "🐞",
               initial:  """
                      ..3.
                      3.1.
                      .143
                      4321
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
       puzzle(4, 4, .easy, "☀️",
               initial:  """
                      .23.
                      3412
                      .14.
                      4..1
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(5, 4, .easy, "🌻",
               initial:  """
                      .2.4
                      341.
                      21.3
                      .3.1
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(6, 4, .easy, "🐞",
               initial:  """
                      12..
                      .4.2
                      214.
                      43.1
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        puzzle(7, 4, .easy, "🌻",
               initial:  """
                      .2.4
                      .41.
                      2.43
                      43.1
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
       puzzle(8, 4, .easy, "🌻",
               initial:  """
                      .2.4
                      3.1.
                      2143
                      ..21
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(9, 4, .easy, "🐞",
               initial:  """
                      123.
                      3.1.
                      ..43
                      .321
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        puzzle(10, 4, .easy, "🐞",
               initial:  """
                      12.4
                      34.2
                      ..4.
                      4.21
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
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
        puzzle(1, 6, .normal,
               initial:  """
                      .57.9.
                      .941.7
                      5.1.4.
                      9.3571
                      71..3.
                      43.7.5
                      """,
               solution: """
                      157394
                      394157
                      571943
                      943571
                      715439
                      439715
                      """),
        puzzle(2, 6, .normal,
               initial:  """
                      ...826
                      826...
                      51.268
                      2.8.13
                      1..6.2
                      6.21.5
                      """,
               solution: """
                      351826
                      826351
                      513268
                      268513
                      135682
                      682135
                      """),
        puzzle(3, 6, .normal,
               initial:  """
                      .697..
                      7.1.69
                      6..1.2
                      2.794.
                      9.62.7
                      1.2.94
                      """,
               solution: """
                      469721
                      721469
                      694172
                      217946
                      946217
                      172694
                      """),
        puzzle(4, 6, .normal,
               initial:  """
                      2..6..
                      678235
                      ..2..6
                      78..52
                      5..8.7
                      86752.
                      """,
               solution: """
                      235678
                      678235
                      352786
                      786352
                      523867
                      867523
                      """),
        puzzle(5, 6, .normal,
               initial:  """
                      .56.3.
                      2..4.6
                      56..23
                      3.26.5
                      6.5..2
                      123564
                      """,
               solution: """
                      456231
                      231456
                      564123
                      312645
                      645312
                      123564
                      """),
        puzzle(6, 6, .normal,
               initial:  """
                      .18.73
                      27.91.
                      .893.7
                      7.2.9.
                      89.73.
                      3.71.9
                      """,
               solution: """
                      918273
                      273918
                      189327
                      732891
                      891732
                      327189
                      """),
        puzzle(7, 6, .normal,
               initial:  """
                      315...
                      .2.315
                      15.4.2
                      .4.5.1
                      5.1.48
                      .821.3
                      """,
               solution: """
                      315824
                      824315
                      153482
                      248531
                      531248
                      482153
                      """),
        puzzle(8, 6, .normal,
               initial:  """
                      91.8.4
                      82.913
                      1...82
                      2483.1
                      .9..4.
                      .82.39
                      """,
               solution: """
                      913824
                      824913
                      139482
                      248391
                      391248
                      482139
                      """),
        puzzle(9, 6, .normal,
               initial:  """
                      12.7.9
                      78.123
                      ......
                      89.231
                      3.2..8
                      978.12
                      """,
               solution: """
                      123789
                      789123
                      231897
                      897231
                      312978
                      978312
                      """),
        puzzle(10, 6, .normal,
               initial:  """
                      .96528
                      .2..9.
                      .4.285
                      .529.4
                      .6.85.
                      .856.9
                      """,
               solution: """
                      496528
                      528496
                      649285
                      852964
                      964852
                      285649
                      """),
        puzzle(11, 6, .normal,
               initial:  """
                      .9352.
                      5.71.3
                      31..7.
                      .5..31
                      9.17.2
                      .7531.
                      """,
               solution: """
                      193527
                      527193
                      319275
                      752931
                      931752
                      275319
                      """),
        puzzle(12, 6, .normal,
               initial:  """
                      1.5.7.
                      .7.1.5
                      3.1.9.
                      72.5.3
                      513.2.
                      2973.1
                      """,
               solution: """
                      135972
                      972135
                      351297
                      729513
                      513729
                      297351
                      """),
        
        // Hard 6x6
        puzzle(1, 6, .hard,
               initial:  """
                      ..59.2
                      .8.465
                      .54.98
                      ...54.
                      54..29
                      2.86..
                      """,
               solution: """
                      465982
                      982465
                      654298
                      829546
                      546829
                      298654
                      """),
        // Hard 6x6
        puzzle(2, 6, .hard,
               initial:  """
                      ......
                      1529.3
                      7..2.5
                      5213.7
                      3.75.1
                      .1.7.9
                      """,
               solution: """
                      973152
                      152973
                      739215
                      521397
                      397521
                      215739
                      """),
        // Hard 6x6
        puzzle(3, 6, .hard,
               initial:  """
                      4.3.1.
                      7.9.2.
                      ..4.97
                      1...3.
                      3.29.1
                      9.1342
                      """,
               solution: """
                      423719
                      719423
                      234197
                      197234
                      342971
                      971342
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
