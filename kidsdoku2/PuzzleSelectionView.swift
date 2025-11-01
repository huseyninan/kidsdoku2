import SwiftUI

struct PuzzleSelectionView: View {
    let size: Int
    @Binding var path: [KidSudokuRoute]
    
    private var puzzlesByDifficulty: [PuzzleDifficulty: [PreDefinedPuzzle]] {
        var dict: [PuzzleDifficulty: [PreDefinedPuzzle]] = [:]
        for difficulty in PuzzleDifficulty.allCases {
            dict[difficulty] = PuzzleLibrary.getPuzzles(for: size, difficulty: difficulty)
        }
        return dict
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView
                
                ForEach(PuzzleDifficulty.allCases, id: \.self) { difficulty in
                    if let puzzles = puzzlesByDifficulty[difficulty], !puzzles.isEmpty {
                        difficultySection(difficulty: difficulty, puzzles: puzzles)
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("\(size)x\(size) Puzzles")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Choose a puzzle")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color(.label))
            
            Text("Select a number to start playing")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    private func difficultySection(difficulty: PuzzleDifficulty, puzzles: [PreDefinedPuzzle]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                difficultyBadge(difficulty: difficulty)
                Spacer()
                Text("\(puzzles.count) puzzles")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(puzzles) { puzzle in
                    puzzleButton(puzzle: puzzle, difficulty: difficulty)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
    
    private func difficultyBadge(difficulty: PuzzleDifficulty) -> some View {
        Text(difficulty.rawValue.uppercased())
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(color(for: difficulty))
            )
    }
    
    private func puzzleButton(puzzle: PreDefinedPuzzle, difficulty: PuzzleDifficulty) -> some View {
        Button {
            path.append(.specificGame(size: size, puzzleId: puzzle.id, difficulty: difficulty.rawValue))
        } label: {
            VStack(spacing: 8) {
                Text("\(puzzle.id)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(color(for: difficulty))
                
                Text("Puzzle")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(.secondaryLabel))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(color(for: difficulty).opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(color(for: difficulty).opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func color(for difficulty: PuzzleDifficulty) -> Color {
        switch difficulty {
        case .easy:
            return Color(.systemGreen)
        case .normal:
            return Color(.systemOrange)
        case .hard:
            return Color(.systemRed)
        }
    }
}

#Preview {
    NavigationStack {
        PuzzleSelectionView(size: 4, path: .constant([]))
    }
}

