import Foundation

extension PremadePuzzle {
    static let tutorialPuzzle = PremadePuzzle(
        id: "tutorial_3x3",
        number: 0,
        size: 3,
        difficulty: .easy,
        config: KidSudokuConfig(
            size: 3,
            subgridRows: 1,
            subgridCols: 3,
            symbolGroup: .animals
        ),
        initialBoard: [
            [nil, 2, 3],
            [nil, 1, 2],
            [2, 3, 1]
        ],
        solutionBoard: [
            [1, 2, 3],
            [3, 1, 2],
            [2, 3, 1]
        ]
    )
}
