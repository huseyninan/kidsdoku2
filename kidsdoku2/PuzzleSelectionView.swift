import SwiftUI

struct PuzzleSelectionView: View {
    let size: Int
    @Binding var path: [KidSudokuRoute]
    
    private let puzzles: [PredefinedPuzzle]
    private let columns = [
        GridItem(.adaptive(minimum: 70), spacing: 16)
    ]
    
    init(size: Int, path: Binding<[KidSudokuRoute]>) {
        self.size = size
        self._path = path
        self.puzzles = PredefinedPuzzles.puzzles(for: size)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                headerSection
                
                ForEach(PuzzleDifficulty.allCases, id: \.self) { difficulty in
                    difficultySection(for: difficulty)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("\(size)x\(size) Puzzles")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Choose a Puzzle")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(.label))
            
            Text("Pick your favorite challenge!")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
    
    private func difficultySection(for difficulty: PuzzleDifficulty) -> some View {
        let filteredPuzzles = puzzles.filter { $0.difficulty == difficulty }
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(difficulty.rawValue)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(colorForDifficulty(difficulty))
                
                Spacer()
                
                difficultyBadge(for: difficulty)
            }
            .padding(.horizontal, 4)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(filteredPuzzles) { puzzle in
                    puzzleButton(puzzle: puzzle, difficulty: difficulty)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
    
    private func puzzleButton(puzzle: PredefinedPuzzle, difficulty: PuzzleDifficulty) -> some View {
        Button {
            path.append(.game(size: size, puzzleId: puzzle.id))
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    colorForDifficulty(difficulty),
                                    colorForDifficulty(difficulty).opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text(puzzle.displayNumber)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .frame(width: 70, height: 70)
                .shadow(color: colorForDifficulty(difficulty).opacity(0.3), radius: 6, x: 0, y: 4)
            }
        }
        .buttonStyle(.plain)
    }
    
    private func difficultyBadge(for difficulty: PuzzleDifficulty) -> some View {
        let icon: String
        switch difficulty {
        case .easy:
            icon = "🌱"
        case .normal:
            icon = "🌟"
        case .hard:
            icon = "🔥"
        }
        
        return HStack(spacing: 4) {
            Text(icon)
                .font(.system(size: 16))
            Text("\(puzzles.filter { $0.difficulty == difficulty }.count)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(.secondaryLabel))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(colorForDifficulty(difficulty).opacity(0.15))
        )
    }
    
    private func colorForDifficulty(_ difficulty: PuzzleDifficulty) -> Color {
        switch difficulty {
        case .easy:
            return Color.green
        case .normal:
            return Color.orange
        case .hard:
            return Color.red
        }
    }
}

#Preview {
    NavigationStack {
        PuzzleSelectionView(size: 4, path: .constant([]))
    }
}
