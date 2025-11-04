//
//  PremadePuzzleStore.swift
//  kidsdoku2
//
//  Created by hinan on 4.11.2025.
//

struct PremadePuzzleStore {
    static let shared = PremadePuzzleStore()
    
    private let fourByFourPuzzles: [PremadePuzzle] = [
        // Easy 4x4 puzzles
        PremadePuzzle(
            number: 1,
            size: 4,
            difficulty: .easy,
            config: .fourByFour,
            initialBoard: [
                [0, nil, nil, 3],
                [nil, nil, 0, nil],
                [nil, 1, nil, nil],
                [2, nil, nil, 1]
            ],
            solutionBoard: [
                [0, 2, 1, 3],
                [3, 1, 0, 2],
                [1, 3, 2, 0],
                [2, 0, 3, 1]
            ],
            emoji: "☀️"
        ),
        PremadePuzzle(
            number: 2,
            size: 4,
            difficulty: .easy,
            config: .fourByFour,
            initialBoard: [
                [nil, 2, nil, nil],
                [3, nil, nil, 1],
                [1, nil, nil, 0],
                [nil, nil, 3, nil]
            ],
            solutionBoard: [
                [0, 2, 1, 3],
                [3, 1, 0, 2],
                [1, 3, 2, 0],
                [2, 0, 3, 1]
            ],
            emoji: "🌻"
        ),
        PremadePuzzle(
            number: 3,
            size: 4,
            difficulty: .easy,
            config: .fourByFour,
            initialBoard: [
                [nil, nil, 2, 0],
                [nil, 3, nil, nil],
                [nil, nil, 1, nil],
                [3, 2, nil, nil]
            ],
            solutionBoard: [
                [1, 0, 2, 3],
                [2, 3, 0, 1],
                [0, 1, 3, 2],
                [3, 2, 1, 0]
            ],
            emoji: "🐞"
        ),
        
        // Normal 4x4 puzzles
        PremadePuzzle(
            number: 1,
            size: 4,
            difficulty: .normal,
            config: .fourByFour,
            initialBoard: [
                [nil, nil, nil, 3],
                [nil, 2, nil, nil],
                [nil, nil, 1, nil],
                [0, nil, nil, nil]
            ],
            solutionBoard: [
                [1, 0, 2, 3],
                [3, 2, 0, 1],
                [2, 3, 1, 0],
                [0, 1, 3, 2]
            ],
            emoji: "🍄"
        ),
        PremadePuzzle(
            number: 2,
            size: 4,
            difficulty: .normal,
            config: .fourByFour,
            initialBoard: [
                [2, nil, nil, nil],
                [nil, nil, 3, nil],
                [nil, 1, nil, nil],
                [nil, nil, nil, 0]
            ],
            solutionBoard: [
                [2, 3, 0, 1],
                [1, 0, 3, 2],
                [3, 1, 2, 0],
                [0, 2, 1, 3]
            ],
            emoji: "🌿"
        ),
        
        // Hard 4x4 puzzles
        PremadePuzzle(
            number: 1,
            size: 4,
            difficulty: .hard,
            config: .fourByFour,
            initialBoard: [
                [nil, nil, nil, nil],
                [nil, 0, 2, nil],
                [nil, 3, 1, nil],
                [nil, nil, nil, nil]
            ],
            solutionBoard: [
                [3, 1, 0, 2],
                [1, 0, 2, 3],
                [0, 3, 1, 2],
                [2, 1, 3, 0]
            ],
            emoji: "💎"
        )
    ]
    
    private let sixBySixPuzzles: [PremadePuzzle] = [
        // Easy 6x6 puzzles
        PremadePuzzle(
            number: 1,
            size: 6,
            difficulty: .easy,
            config: .sixBySix,
            initialBoard: [
                [0, nil, nil, 3, nil, nil],
                [nil, nil, 4, nil, nil, 1],
                [nil, 3, nil, nil, 0, nil],
                [nil, 5, nil, nil, 2, nil],
                [2, nil, nil, 1, nil, nil],
                [nil, nil, 5, nil, nil, 3]
            ],
            solutionBoard: [
                [0, 1, 2, 3, 4, 5],
                [3, 2, 4, 5, 1, 0],
                [4, 3, 1, 2, 0, 5],
                [1, 5, 0, 4, 2, 3],
                [2, 0, 3, 1, 5, 4],
                [5, 4, 0, 1, 3, 2]
            ],
            emoji: "🦋"
        ),
        
        // Normal 6x6 puzzle
        PremadePuzzle(
            number: 1,
            size: 6,
            difficulty: .normal,
            config: .sixBySix,
            initialBoard: [
                [nil, nil, nil, nil, 4, nil],
                [nil, 2, nil, nil, nil, nil],
                [nil, nil, nil, 1, nil, nil],
                [nil, nil, 5, nil, nil, nil],
                [nil, nil, nil, nil, 3, nil],
                [nil, 1, nil, nil, nil, nil]
            ],
            solutionBoard: [
                [1, 3, 2, 5, 4, 0],
                [4, 2, 0, 3, 1, 5],
                [5, 0, 3, 1, 2, 4],
                [0, 4, 5, 2, 3, 1],
                [2, 5, 4, 0, 1, 3],
                [3, 1, 0, 4, 5, 2]
            ],
            emoji: "🌳"
        ),
        
        // Hard 6x6 puzzle
        PremadePuzzle(
            number: 1,
            size: 6,
            difficulty: .hard,
            config: .sixBySix,
            initialBoard: [
                [nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, 2, nil, nil],
                [nil, nil, 4, nil, nil, nil],
                [nil, nil, nil, 1, nil, nil],
                [nil, nil, 3, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil]
            ],
            solutionBoard: [
                [3, 1, 5, 0, 2, 4],
                [0, 4, 1, 2, 5, 3],
                [5, 2, 4, 3, 1, 0],
                [4, 0, 2, 1, 3, 5],
                [1, 5, 3, 4, 0, 2],
                [2, 3, 0, 5, 4, 1]
            ],
            emoji: "💠"
        )
    ]
    
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
