import SwiftUI

struct PuzzleSelectionView: View {
    let size: Int
    @Binding var path: [KidSudokuRoute]
    
    private var puzzles: [PremadePuzzle] {
        PremadePuzzleStore.shared.puzzles(for: size)
    }
    
    private var puzzlesByDifficulty: [(PuzzleDifficulty, [PremadePuzzle])] {
        PuzzleDifficulty.allCases.compactMap { difficulty in
            let filteredPuzzles = PremadePuzzleStore.shared.puzzles(for: size, difficulty: difficulty)
            return filteredPuzzles.isEmpty ? nil : (difficulty, filteredPuzzles)
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemTeal), Color(.systemBlue)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    LazyVStack(spacing: 20) {
                        ForEach(puzzlesByDifficulty, id: \.0) { difficulty, puzzles in
                            difficultySection(difficulty: difficulty, puzzles: puzzles)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
        }
        .navigationTitle("\(size)×\(size) Puzzles")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Random Puzzle") {
                    path.append(.game(size: size))
                }
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                )
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Choose Your Puzzle")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            
            Text("Select from our collection of hand-crafted puzzles")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
    }
    
    private func difficultySection(difficulty: PuzzleDifficulty, puzzles: [PremadePuzzle]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(difficulty.rawValue)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Circle()
                    .fill(difficulty.color)
                    .frame(width: 12, height: 12)
                
                Spacer()
                
                Text("\(puzzles.count) puzzles")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }
            
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(puzzles) { puzzle in
                    puzzleButton(puzzle: puzzle)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.15))
        )
    }
    
    private func puzzleButton(puzzle: PremadePuzzle) -> some View {
        Button {
            path.append(.premadePuzzle(puzzle: puzzle))
        } label: {
            VStack(spacing: 8) {
                Text("\(puzzle.number)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(puzzle.displayName)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [puzzle.difficulty.color, puzzle.difficulty.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: puzzle.difficulty.color.opacity(0.4), radius: 6, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    }
}

#Preview {
    NavigationStack {
        PuzzleSelectionView(size: 4, path: .constant([]))
    }
}