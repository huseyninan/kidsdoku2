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
                      71..39
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
                      6.2135
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
                      .4.531
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
                      319.7.
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
                      513.29
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
                      """),
        
        
        
        puzzle(4, 6, .hard,
               initial:  """
                      ....27
                      ..7183
                      31....
                      .9.831
                      .3.792
                      2..318
                      """,
               solution: """
                      183927
                      927183
                      318279
                      792831
                      831792
                      279318
                      """),
        // Hard 6x6
        puzzle(5, 6, .hard,
               initial:  """
                      ...947
                      947...
                      ..6.79
                      794..5
                      685.9.
                      .79856
                      """,
               solution: """
                      568947
                      947568
                      856479
                      794685
                      685794
                      479856
                      """),
        // Hard 6x6
        puzzle(6, 6, .hard,
               initial:  """
                      .9..81
                      .812.3
                      9.2...
                      8.732.
                      ...817
                      178.32
                      """,
               solution: """
                      293781
                      781293
                      932178
                      817329
                      329817
                      178932
                      """),
        puzzle(7, 6, .hard,
               initial:  """
                      .38651
                      ......
                      38.165
                      51.89.
                      8..5.6
                      .65.8.
                      """,
               solution: """
                      938651
                      651938
                      389165
                      516893
                      893516
                      165389
                      """),
        // Hard 6x6
        puzzle(8, 6, .hard,
               initial:  """
                      ..725.
                      25..17
                      .7.5..
                      54..73
                      ..1425
                      42..3.
                      """,
               solution: """
                      317254
                      254317
                      173542
                      542173
                      731425
                      425731
                      """),
        // Hard 6x6 ----------------------------------
        puzzle(9, 6, .hard,
               initial:  """
                      ......
                      9.4327
                      .7384.
                      8.92.3
                      .3249.
                      4.8.32
                      """,
               solution: """
                      327984
                      984327
                      273849
                      849273
                      732498
                      498732
                      """),
        puzzle(10, 6, .hard,
               initial:  """
                      ..2.56
                      .567..
                      ....45
                      645...
                      827564
                      564.27
                      """,
               solution: """
                      782456
                      456782
                      278645
                      645278
                      827564
                      564827
                      """),
        // Hard 6x6
        puzzle(11, 6, .hard,
               initial:  """
                      .397..
                      .2.139
                      9.....
                      47..13
                      ..1247
                      2473..
                      """,
               solution: """
                      139724
                      724139
                      913472
                      472913
                      391247
                      247391
                      """),
        // Hard 6x6
        puzzle(12, 6, .hard,
               initial:  """
                      ..4.57
                      85...4
                      423.7.
                      .8..4.
                      3.2785
                      5...23
                      """,
               solution: """
                      234857
                      857234
                      423578
                      785342
                      342785
                      578423
                      """),
        puzzle(13, 6, .hard,
               initial:  """
                      ..7924
                      92..37
                      3714..
                      ...7.3
                      7.324.
                      4....1
                      """,
               solution: """
                      137924
                      924137
                      371492
                      249713
                      713249
                      492371
                      """),
        // Hard 6x6
        puzzle(14, 6, .hard,
               initial:  """
                      .493.8
                      3.814.
                      9..7..
                      8.7.91
                      ..18..
                      7..914
                      """,
               solution: """
                      149378
                      378149
                      914783
                      837491
                      491837
                      783914
                      """),
        // Hard 6x6 ---------------
        puzzle(15, 6, .hard,
               initial:  """
                      .596.8
                      .78259
                      9....6
                      8.75.2
                      59..6.
                      78...5
                      """,
               solution: """
                      259678
                      678259
                      925786
                      867592
                      592867
                      786925
                      """),
        puzzle(16, 6, .hard,
               initial:  """
                      .39..4
                      85..39
                      91.485
                      ...91.
                      391548
                      ..8...
                      """,
               solution: """
                      139854
                      854139
                      913485
                      485913
                      391548
                      548391
                      """),
        // Hard 6x6
        puzzle(17, 6, .hard,
               initial:  """
                      ....8.
                      9.43.7
                      .7384.
                      8.92.3
                      .3249.
                      4.8.32
                      """,
               solution: """
                      327984
                      984327
                      273849
                      849273
                      732498
                      498732
                      """),
        // Hard 6x6
        puzzle(18, 6, .hard,
               initial:  """
                      .3.75.
                      7.1..8
                      .8.17.
                      5.7..3
                      82.51.
                      175.82
                      """,
               solution: """
                      238751
                      751238
                      382175
                      517823
                      823517
                      175382
                      """),
        puzzle(19, 6, .hard,
               initial:  """
                      ..8.56
                      7.69..
                      .8..7.
                      56.89.
                      .92.67
                      .752.9
                      """,
               solution: """
                      928756
                      756928
                      289675
                      567892
                      892567
                      675289
                      """),
        // Hard 6x6
        puzzle(20, 6, .hard,
               initial:  """
                      56.9.7
                      9.75.3
                      3562.9
                      ......
                      6.5792
                      ..93.6
                      """,
               solution: """
                      563927
                      927563
                      356279
                      792635
                      635792
                      279356
                      """),
        // Hard 6x6
        puzzle(21, 6, .hard,
               initial:  """
                      9.31.2
                      1...63
                      6.....
                      4.1396
                      3.6.21
                      .14..9
                      """,
               solution: """
                      963142
                      142963
                      639214
                      421396
                      396421
                      214639
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
