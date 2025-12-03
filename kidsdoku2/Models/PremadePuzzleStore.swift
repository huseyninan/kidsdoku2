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
// Usage:
//   puzzle(1, 4, .easy, initial: "...", solution: "...")
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

final class PremadePuzzleStore {
    static let shared = PremadePuzzleStore()
    
    /// Pre-computed index for O(1) lookup
    private var indexedPuzzles: [Int: [PuzzleDifficulty: [PremadePuzzle]]] = [:]
    
    private init() {
        // Build index eagerly at app startup
        for (size, puzzles) in [(3, threeByThreePuzzles), (4, fourByFourPuzzles), (6, sixBySixPuzzles)] {
            var byDifficulty: [PuzzleDifficulty: [PremadePuzzle]] = [:]
            for difficulty in PuzzleDifficulty.allCases {
                byDifficulty[difficulty] = puzzles.filter { $0.difficulty == difficulty }
            }
            indexedPuzzles[size] = byDifficulty
        }
    }
    
    // MARK: - 3x3 Puzzles
    private let threeByThreePuzzles: [PremadePuzzle] = [
        // Easy 3x3
        puzzle(1, 3, .easy,
               initial:  """
                      1.3
                      .31
                      31.
                      """,
               solution: """
                      123
                      231
                      312
                      """),
        
        puzzle(2, 3, .easy,
               initial:  """
                      1..
                      231
                      .1.
                      """,
               solution: """
                      123
                      231
                      312
                      """),
        
        puzzle(3, 3, .easy,
               initial:  """
                      12.
                      3.2
                      .31
                      """,
               solution: """
                      123
                      312
                      231
                      """),
        
        puzzle(4, 3, .easy,
               initial:  """
                      .23
                      231
                      31.
                      """,
               solution: """
                      123
                      231
                      312
                      """),
        
        puzzle(5, 3, .easy,
               initial:  """
                      1.3
                      31.
                      .31
                      """,
               solution: """
                      123
                      312
                      231
                      """),
        
        puzzle(6, 3, .easy,
               initial:  """
                      .2.
                      231
                      3.2
                      """,
               solution: """
                      123
                      231
                      312
                      """),
        
        puzzle(7, 3, .easy,
               initial:  """
                      1.3
                      .31
                      .12
                      """,
               solution: """
                      123
                      231
                      312
                      """),
        
        puzzle(8, 3, .easy,
               initial:  """
                      12.
                      .12
                      .31
                      """,
               solution: """
                      123
                      312
                      231
                      """),
        
        puzzle(9, 3, .easy,
               initial:  """
                      .23
                      23.
                      31.
                      """,
               solution: """
                      123
                      231
                      312
                      """),
        
        // Normal 3x3
        puzzle(1, 3, .normal,
               initial:  """
                      ..3
                      .31
                      31.
                      """,
               solution: """
                      123
                      231
                      312
                      """),
        
        puzzle(2, 3, .normal,
               initial:  """
                      1.3
                      ...
                      .31
                      """,
               solution: """
                      123
                      312
                      231
                      """),
        
        puzzle(3, 3, .normal,
               initial:  """
                      1..
                      .31
                      3..
                      """,
               solution: """
                      123
                      231
                      312
                      """),
        
        puzzle(4, 3, .normal,
               initial:  """
                      ..3
                      .3.
                      31.
                      """,
               solution: """
                      123
                      231
                      312
                      """),
        
        puzzle(5, 3, .normal,
               initial:  """
                      1.3
                      .3.
                      31.
                      """,
               solution: """
                      123
                      231
                      312
                      """),
        
        puzzle(6, 3, .normal,
               initial:  """
                      ..3
                      3.2
                      .31
                      """,
               solution: """
                      123
                      312
                      231
                      """),
        
        puzzle(7, 3, .normal,
               initial:  """
                      1..
                      23.
                      31.
                      """,
               solution: """
                      123
                      231
                      312
                      """),
        
        puzzle(8, 3, .normal,
               initial:  """
                      .2.
                      .31
                      31.
                      """,
               solution: """
                      123
                      231
                      312
                      """),
        
        puzzle(9, 3, .normal,
               initial:  """
                      1..
                      .1.
                      .31
                      """,
               solution: """
                      123
                      312
                      231
                      """),
        
        // Hard 3x3
        puzzle(1, 3, .hard,
               initial:  """
                      1..
                      ...
                      31.
                      """,
               solution: """
                      123
                      231
                      312
                      """),
        
        puzzle(2, 3, .hard,
               initial:  """
                      ..3
                      .3.
                      .1.
                      """,
               solution: """
                      123
                      231
                      312
                      """),
        
        puzzle(3, 3, .hard,
               initial:  """
                      1..
                      .3.
                      31.
                      """,
               solution: """
                      123
                      231
                      312
                      """),
        
        puzzle(4, 3, .hard,
               initial:  """
                      ...
                      .31
                      31.
                      """,
               solution: """
                      123
                      231
                      312
                      """),
        
        puzzle(5, 3, .hard,
               initial:  """
                      1..
                      31.
                      ...
                      """,
               solution: """
                      123
                      312
                      231
                      """),
        
        puzzle(6, 3, .hard,
               initial:  """
                      ..3
                      ...
                      31.
                      """,
               solution: """
                      123
                      231
                      312
                      """),
        
        puzzle(7, 3, .hard,
               initial:  """
                      1..
                      ...
                      .31
                      """,
               solution: """
                      123
                      312
                      231
                      """),
        
        puzzle(8, 3, .hard,
               initial:  """
                      ...
                      .31
                      .1.
                      """,
               solution: """
                      123
                      231
                      312
                      """),
    ]
    
    // MARK: - 4x4 Puzzles
    private let fourByFourPuzzles: [PremadePuzzle] = [
        // Easy 4x4
        puzzle(1, 4, .easy,
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
        
        puzzle(2, 4, .easy,
               initial:  """
                      12.4
                      .412
                      21.3
                      ..21
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(3, 4, .easy,
               initial:  """
                      .2..
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
       puzzle(4, 4, .easy,
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
        
        puzzle(5, 4, .easy,
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
        
        puzzle(6, 4, .easy,
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
        puzzle(7, 4, .easy,
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
       puzzle(8, 4, .easy,
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
        
        puzzle(9, 4, .easy,
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
        puzzle(10, 4, .easy,
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
        puzzle(1, 4, .normal,
               initial:  """
                      ....
                      3412
                      .14.
                      43.1
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(2, 4, .normal,
               initial:  """
                      .234
                      ...2
                      .14.
                      4.21
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(3, 4, .normal,
               initial:  """
                      1.34
                      .4..
                      2.43
                      ..21
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(4, 4, .normal,
               initial:  """
                      .23.
                      .4.2
                      21.3
                      4..1
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(5, 4, .normal,
               initial:  """
                      12.4
                      3...
                      .143
                      .32.
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(6, 4, .normal,
               initial:  """
                      12..
                      3..2
                      .143
                      4.2.
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(7, 4, .normal,
               initial:  """
                      12.4
                      ...2
                      2.43
                      43.1
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(8, 4, .normal,
               initial:  """
                      ..34
                      3..2
                      2.4.
                      4321
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(9, 4, .normal,
               initial:  """
                      ..34
                      3..2
                      21..
                      4321
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(10, 4, .normal,
               initial:  """
                      123.
                      34.2
                      2.43
                      ....
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(11, 4, .normal,
               initial:  """
                      .234
                      ..1.
                      ..43
                      .321
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(12, 4, .normal,
               initial:  """
                      .2.4
                      3.12
                      214.
                      ..2.
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(13, 4, .normal,
               initial:  """
                      1.3.
                      .4.2
                      2..3
                      ..21
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(14, 4, .normal,
               initial:  """
                      .2.4
                      4.2.
                      ..13
                      31..
                      """,
               solution: """
                      1234
                      4321
                      2413
                      3142
                      """),
        
        puzzle(15, 4, .normal,
               initial:  """
                      1.34
                      ..2.
                      .1..
                      43.2
                      """,
               solution: """
                      1234
                      3421
                      2143
                      4312
                      """),
        
        
        puzzle(16, 4, .normal,
               initial:  """
                      ..34
                      3..2
                      .12.
                      .3.1
                      """,
               solution: """
                      1234
                      3412
                      4123
                      2341
                      """),
        
        puzzle(17, 4, .normal,
               initial:  """
                      12.4
                      ..1.
                      ...3
                      432.
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(18, 4, .normal,
               initial:  """
                      .234
                      3...
                      .1.3
                      2.4.
                      """,
               solution: """
                      1234
                      3412
                      4123
                      2341
                      """),
        
        puzzle(19, 4, .normal,
               initial:  """
                      .2.4
                      4...
                      1342
                      ..3.
                      """,
               solution: """
                      3214
                      4123
                      1342
                      2431
                      """),
        
        puzzle(20, 4, .normal,
               initial:  """
                      1234
                      .32.
                      .1.3
                      ...2
                      """,
               solution: """
                      1234
                      4321
                      2143
                      3412
                      """),
        
        puzzle(21, 4, .normal,
               initial:  """
                      12..
                      .31.
                      .134
                      ..2.
                      """,
               solution: """
                      1243
                      4312
                      2134
                      3421
                      """),
        
        puzzle(22, 4, .normal,
               initial:  """
                      12.4
                      4..1
                      ..43
                      ..1.
                      """,
               solution: """
                      1234
                      4321
                      2143
                      3412
                      """),
        
        puzzle(23, 4, .normal,
               initial:  """
                      .234
                      3..2
                      ..21
                      ..4.
                      """,
               solution: """
                      1234
                      3412
                      4321
                      2143
                      """),
        
        puzzle(24, 4, .normal,
               initial:  """
                      ..34
                      ..12
                      12.3
                      .3..
                      """,
               solution: """
                      2134
                      3412
                      1243
                      4321
                      """),
        
        puzzle(25, 4, .normal,
               initial:  """
                      ..34
                      4.1.
                      34.1
                      2...
                      """,
               solution: """
                      1234
                      4312
                      3421
                      2143
                      """),
        
        puzzle(26, 4, .normal,
               initial:  """
                      12..
                      3.2.
                      43..
                      213.
                      """,
               solution: """
                      1243
                      3421
                      4312
                      2134
                      """),
        
        puzzle(27, 4, .normal,
               initial:  """
                      ..34
                      4.12
                      3.2.
                      .2..
                      """,
               solution: """
                      2134
                      4312
                      3421
                      1243
                      """),
        
        // Hard 4x4
        puzzle(1, 4, .hard,
               initial:  """
                      1..4
                      .41.
                      2..3
                      4.2.
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        // Hard 4x4
        puzzle(2, 4, .hard,
               initial:  """
                      ...4
                      34.2
                      .1.3
                      4.2.
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        // Hard 4x4
        puzzle(3, 4, .hard,
               initial:  """
                      1..4
                      341.
                      ....
                      432.
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        puzzle(4, 4, .hard,
               initial:  """
                      .2.4
                      .412
                      .14.
                      43.1
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        // Hard 4x4
        puzzle(5, 4, .hard,
               initial:  """
                      1...
                      .4..
                      2.43
                      .32.
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        // Hard 4x4
        puzzle(6, 4, .hard,
               initial:  """
                      ..3.
                      3412
                      2.43
                      ....
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        puzzle(7, 4, .hard,
               initial:  """
                      .2.4
                      ..1.
                      21.3
                      .3..
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        // Hard 4x4
        puzzle(8, 4, .hard,
               initial:  """
                      1234
                      ..1.
                      2...
                      .3.1
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        // Hard 4x4
        puzzle(9, 4, .hard,
               initial:  """
                      ...4
                      341.
                      .1..
                      .321
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        puzzle(10, 4, .hard,
               initial:  """
                      ..34
                      ...2
                      2143
                      4...
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        // Hard 4x4
        puzzle(11, 4, .hard,
               initial:  """
                      .23.
                      ...2
                      21..
                      43..
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        // Hard 4x4
        puzzle(12, 4, .hard,
               initial:  """
                      12..
                      3.1.
                      2.4.
                      .32.
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        puzzle(13, 4, .hard,
               initial:  """
                      1.34
                      ....
                      21..
                      432.
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        // Hard 4x4
        puzzle(14, 4, .hard,
               initial:  """
                      1.34
                      3.1.
                      2...
                      ..21
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        // Hard 4x4
        puzzle(15, 4, .hard,
               initial:  """
                      1...
                      3..2
                      .14.
                      43..
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        puzzle(16, 4, .hard,
               initial:  """
                      .234
                      ..1.
                      2...
                      4.21
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        // Hard 4x4
        puzzle(17, 4, .hard,
               initial:  """
                      .23.
                      ..1.
                      21.3
                      4...
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        // Hard 4x4
        puzzle(18, 4, .hard,
               initial:  """
                      .23.
                      .4..
                      21..
                      .3.1
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        puzzle(19, 4, .hard,
               initial:  """
                      123.
                      ....
                      ..43
                      432.
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        // Hard 4x4
        puzzle(20, 4, .hard,
               initial:  """
                      ..34
                      ..1.
                      2...
                      43.1
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        // Hard 4x4
        puzzle(21, 4, .hard,
               initial:  """
                      1..4
                      ..1.
                      2..3
                      4..1
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(22, 4, .hard,
               initial:  """
                      1..4
                      .3.2
                      2.4.
                      3..1
                      """,
               solution: """
                      1234
                      4312
                      2143
                      3421
                      """),
        
        puzzle(23, 4, .hard,
               initial:  """
                      .23.
                      4..1
                      3..2
                      .14.
                      """,
               solution: """
                      1234
                      4321
                      3412
                      2143
                      """),
        
        puzzle(24, 4, .hard,
               initial:  """
                      1.3.
                      .4.2
                      2..3
                      4..1
                      """,
               solution: """
                      1234
                      3412
                      2143
                      4321
                      """),
        
        puzzle(25, 4, .hard,
               initial:  """
                      12..
                      ..2.
                      .1.3
                      341.
                      """,
               solution: """
                      1234
                      4321
                      2143
                      3412
                      """),
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
                      1.32.4
                      25..63
                      6.15.2
                      5.2631
                      .164.5
                      42.31.
                      """,
               solution: """
                      163254
                      254163
                      631542
                      542631
                      316425
                      425316
                      """),
        
        puzzle(3, 6, .easy,
               initial:  """
                      .5632.
                      3.41.6
                      56.43.
                      .43.15
                      6.52..
                      43256.
                      """,
               solution: """
                      156324
                      324156
                      561432
                      243615
                      615243
                      432561
                      """),
        
        puzzle(4, 6, .easy,
               initial:  """
                      34.6.1
                      ..1.45
                      4.3..2
                      2.6534
                      534.16
                      16.453
                      """,
               solution: """
                      345621
                      621345
                      453162
                      216534
                      534216
                      162453
                      """),
        
        puzzle(5, 6, .easy,
               initial:  """
                      3.26.4
                      .543.2
                      2.1465
                      465..1
                      1.3546
                      .4.1.3
                      """,
               solution: """
                      312654
                      654312
                      231465
                      465231
                      123546
                      546123
                      """),
        
        puzzle(6, 6, .easy,
               initial:  """
                      126543
                      .4.1.6
                      26143.
                      4..2.1
                      6.23.4
                      35.6.2
                      """,
               solution: """
                      126543
                      543126
                      261435
                      435261
                      612354
                      354612
                      """),
        
        puzzle(7, 6, .easy,
               initial:  """
                      461.25
                      ..5461
                      14..32
                      5321..
                      61.253
                      .5.614
                      """,
               solution: """
                      461325
                      325461
                      146532
                      532146
                      614253
                      253614
                      """),
        
        puzzle(8, 6, .easy,
               initial:  """
                      643.21
                      .2.6.3
                      364.52
                      .5..6.
                      436215
                      .154.6
                      """,
               solution: """
                      643521
                      521643
                      364152
                      152364
                      436215
                      215436
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
                      53.246
                      6.41.3
                      153.24
                      .62..5
                      .15462
                      """,
               solution: """
                      246531
                      531246
                      624153
                      153624
                      462315
                      315462
                      """),
        
        // Normal 6x6
        puzzle(1, 6, .normal,
               initial:  """
                      .56.2.
                      .241.6
                      5.1.4.
                      2.3561
                      61..32
                      43.6.5
                      """,
               solution: """
                      156324
                      324156
                      561243
                      243561
                      615432
                      432615
                      """),
        puzzle(2, 6, .normal,
               initial:  """
                      ...426
                      426...
                      51.264
                      2.4.13
                      1..6.2
                      6.2135
                      """,
               solution: """
                      351426
                      426351
                      513264
                      264513
                      135642
                      642135
                      """),
        puzzle(3, 6, .normal,
               initial:  """
                      .635..
                      5.1.63
                      6..1.2
                      2.534.
                      3.62.5
                      1.2.34
                      """,
               solution: """
                      463521
                      521463
                      634152
                      215346
                      346215
                      152634
                      """),
        puzzle(4, 6, .normal,
               initial:  """
                      2..6..
                      641235
                      ..2..6
                      41..52
                      5..1.4
                      16452.
                      """,
               solution: """
                      235641
                      641235
                      352416
                      416352
                      523164
                      164523
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
                      .15.63
                      26.41.
                      .543.6
                      6.2.4.
                      54.63.
                      3.61.4
                      """,
               solution: """
                      415263
                      263415
                      154326
                      632541
                      541632
                      326154
                      """),
        puzzle(7, 6, .normal,
               initial:  """
                      315...
                      .2.315
                      15.4.2
                      .4.531
                      5.1.46
                      .621.3
                      """,
               solution: """
                      315624
                      624315
                      153462
                      246531
                      531246
                      462153
                      """),
        puzzle(8, 6, .normal,
               initial:  """
                      51.6.4
                      62.513
                      1...62
                      2463.1
                      .5..4.
                      .62.35
                      """,
               solution: """
                      513624
                      624513
                      135462
                      246351
                      351246
                      462135
                      """),
        puzzle(9, 6, .normal,
               initial:  """
                      12.5.4
                      56.123
                      ......
                      64.231
                      3.2..6
                      456.12
                      """,
               solution: """
                      123564
                      564123
                      231645
                      645231
                      312456
                      456312
                      """),
        puzzle(10, 6, .normal,
               initial:  """
                      .16523
                      .2..1.
                      .4.235
                      .521.4
                      .6.35.
                      .356.1
                      """,
               solution: """
                      416523
                      523416
                      641235
                      352164
                      164352
                      235641
                      """),
        puzzle(11, 6, .normal,
               initial:  """
                      .4352.
                      5.61.3
                      314.6.
                      .5..31
                      4.16.2
                      .6531.
                      """,
               solution: """
                      143526
                      526143
                      314265
                      652431
                      431652
                      265314
                      """),
        puzzle(12, 6, .normal,
               initial:  """
                      1.5.6.
                      .6.1.5
                      3.1.4.
                      62.5.3
                      513.24
                      2463.1
                      """,
               solution: """
                      135462
                      462135
                      351246
                      624513
                      513624
                      246351
                      """),
        
        // Hard 6x6
        puzzle(1, 6, .hard,
               initial:  """
                      ..51.2
                      .3.465
                      .54.13
                      ...54.
                      54..21
                      2.36..
                      """,
               solution: """
                      465132
                      132465
                      654213
                      321546
                      546321
                      213654
                      """),
        // Hard 6x6
        puzzle(2, 6, .hard,
               initial:  """
                      ......
                      1524.3
                      6..2.5
                      5213.6
                      3.65.1
                      .1.6.4
                      """,
               solution: """
                      463152
                      152463
                      634215
                      521346
                      346521
                      215634
                      """),
        // Hard 6x6
        puzzle(3, 6, .hard,
               initial:  """
                      4.3.1.
                      6.5.2.
                      ..4.56
                      1...3.
                      3.25.1
                      5.1342
                      """,
               solution: """
                      423615
                      615423
                      234156
                      156234
                      342561
                      561342
                      """),
        
        
        
        puzzle(4, 6, .hard,
               initial:  """
                      ....26
                      ..6143
                      31....
                      .5.431
                      .3.652
                      2..314
                      """,
               solution: """
                      143526
                      526143
                      314265
                      652431
                      431652
                      265314
                      """),
        // Hard 6x6
        puzzle(5, 6, .hard,
               initial:  """
                      ...143
                      143...
                      ..6.31
                      314..5
                      625.1.
                      .31256
                      """,
               solution: """
                      562143
                      143562
                      256431
                      314625
                      625314
                      431256
                      """),
        // Hard 6x6
        puzzle(6, 6, .hard,
               initial:  """
                      .4..51
                      .512.3
                      4.2...
                      5.632.
                      ...516
                      165.32
                      """,
               solution: """
                      243651
                      651243
                      432165
                      516324
                      324516
                      165432
                      """),
        puzzle(7, 6, .hard,
               initial:  """
                      .32651
                      ......
                      32.165
                      51.24.
                      2..5.6
                      .65.2.
                      """,
               solution: """
                      432651
                      651432
                      324165
                      516243
                      243516
                      165324
                      """),
        // Hard 6x6
        puzzle(8, 6, .hard,
               initial:  """
                      ..625.
                      25..16
                      .6.5..
                      54..63
                      ..1425
                      42..3.
                      """,
               solution: """
                      316254
                      254316
                      163542
                      542163
                      631425
                      425631
                      """),
        // Hard 6x6 ----------------------------------
        puzzle(9, 6, .hard,
               initial:  """
                      ......
                      1.4326
                      .6354.
                      5.12.3
                      .3241.
                      4.5.32
                      """,
               solution: """
                      326154
                      154326
                      263541
                      541263
                      632415
                      415632
                      """),
        puzzle(10, 6, .hard,
               initial:  """
                      ..2.56
                      .563..
                      ....45
                      645...
                      123564
                      564.23
                      """,
               solution: """
                      312456
                      456312
                      231645
                      645231
                      123564
                      564123
                      """),
        // Hard 6x6
        puzzle(11, 6, .hard,
               initial:  """
                      .356..
                      .2.135
                      5.....
                      46..13
                      ..1246
                      2463..
                      """,
               solution: """
                      135624
                      624135
                      513462
                      462513
                      351246
                      246351
                      """),
        // Hard 6x6
        puzzle(12, 6, .hard,
               initial:  """
                      ..4.56
                      15...4
                      423.6.
                      .1..4.
                      3.2615
                      5...23
                      """,
               solution: """
                      234156
                      156234
                      423561
                      615342
                      342615
                      561423
                      """),
        puzzle(13, 6, .hard,
               initial:  """
                      ..6524
                      52..36
                      3614..
                      ...6.3
                      6.324.
                      4....1
                      """,
               solution: """
                      136524
                      524136
                      361452
                      245613
                      613245
                      452361
                      """),
        // Hard 6x6
        puzzle(14, 6, .hard,
               initial:  """
                      .453.2
                      3.214.
                      5..6..
                      2.6.51
                      ..12..
                      6..514
                      """,
               solution: """
                      145362
                      362145
                      514623
                      236451
                      451236
                      623514
                      """),
        // Hard 6x6 ---------------
        puzzle(15, 6, .hard,
               initial:  """
                      .516.3
                      .43251
                      1....6
                      3.45.2
                      51..6.
                      43...5
                      """,
               solution: """
                      251643
                      643251
                      125436
                      364512
                      512364
                      436125
                      """),
        puzzle(16, 6, .hard,
               initial:  """
                      .32..4
                      65..32
                      21.465
                      ...21.
                      321546
                      ..6...
                      """,
               solution: """
                      132654
                      654132
                      213465
                      465213
                      321546
                      546321
                      """),
        // Hard 6x6
        puzzle(17, 6, .hard,
               initial:  """
                      ....6.
                      1.43.5
                      .5364.
                      6.12.3
                      .3241.
                      4.6.32
                      """,
               solution: """
                      325164
                      164325
                      253641
                      641253
                      532416
                      416532
                      """),
        // Hard 6x6
        puzzle(18, 6, .hard,
               initial:  """
                      .3.45.
                      4.1..6
                      .6.14.
                      5.4..3
                      62.51.
                      145.62
                      """,
               solution: """
                      236451
                      451236
                      362145
                      514623
                      623514
                      145362
                      """),
        puzzle(19, 6, .hard,
               initial:  """
                      ..3.56
                      4.61..
                      .3..4.
                      56.31.
                      .12.64
                      .452.1
                      """,
               solution: """
                      123456
                      456123
                      231645
                      564312
                      312564
                      645231
                      """),
        // Hard 6x6
        puzzle(20, 6, .hard,
               initial:  """
                      56.1.4
                      1.45.3
                      3562.1
                      ......
                      6.5412
                      ..13.6
                      """,
               solution: """
                      563124
                      124563
                      356241
                      412635
                      635412
                      241356
                      """),
        // Hard 6x6
        puzzle(21, 6, .hard,
               initial:  """
                      5.31.2
                      1...63
                      6.....
                      4.1356
                      3.6.21
                      .14..5
                      """,
               solution: """
                      563142
                      142563
                      635214
                      421356
                      356421
                      214635
                      """)
    ]
    
    // MARK: - Public Interface
    func puzzles(for size: Int) -> [PremadePuzzle] {
        switch size {
        case 3:
            return threeByThreePuzzles
        case 4:
            return fourByFourPuzzles
        case 6:
            return sixBySixPuzzles
        default:
            return []
        }
    }
    
    func puzzles(for size: Int, difficulty: PuzzleDifficulty) -> [PremadePuzzle] {
        return indexedPuzzles[size]?[difficulty] ?? []
    }
}


// MARK: - Puzzle Builder Helper
/// Creates a PremadePuzzle from compact string notation
/// - Parameters:
///   - number: Puzzle number within its difficulty level
///   - size: Board size (4 or 6)
///   - difficulty: Easy, Normal, or Hard
///   - initial: String representation of initial board (use '.' for empty cells)
///   - solution: String representation of solution board
/// - Returns: A validated PremadePuzzle
private func puzzle(
    _ number: Int,
    _ size: Int,
    _ difficulty: PuzzleDifficulty,
    initial: String,
    solution: String
) -> PremadePuzzle {
    let symbolGroup = assignSymbolGroup(size: size, difficulty: difficulty, number: number)
    
    let (subgridRows, subgridCols): (Int, Int)
    switch size {
    case 3:
        (subgridRows, subgridCols) = (1, 3)
    case 4:
        (subgridRows, subgridCols) = (2, 2)
    case 6:
        (subgridRows, subgridCols) = (2, 3)
    default:
        fatalError("Unsupported puzzle size: \(size)")
    }
    
    let config = KidSudokuConfig(
        size: size,
        subgridRows: subgridRows,
        subgridCols: subgridCols,
        symbolGroup: symbolGroup
    )
    
    let initialBoard = parseBoard(initial, size: size)
    let solutionBoard = parseSolutionBoard(solution, size: size)
    
    // Validate boards
    assert(initialBoard.count == size, "Initial board must have \(size) rows")
    assert(solutionBoard.count == size, "Solution board must have \(size) rows")
    assert(initialBoard.allSatisfy { $0.count == size }, "All initial board rows must have \(size) columns")
    assert(solutionBoard.allSatisfy { $0.count == size }, "All solution board rows must have \(size) columns")
    
    return PremadePuzzle(
        number: number,
        size: size,
        difficulty: difficulty,
        config: config,
        initialBoard: initialBoard,
        solutionBoard: solutionBoard
    )
}

private func assignSymbolGroup(size: Int, difficulty: PuzzleDifficulty, number: Int) -> SymbolGroup {
    // Create a deterministic assignment based on puzzle characteristics
    let seed = size * 1000 + (difficulty == .easy ? 0 : difficulty == .normal ? 100 : 200) + number
    let groupIndex = abs(seed) % SymbolGroup.puzzleCases.count
    return SymbolGroup.puzzleCases[groupIndex]
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
