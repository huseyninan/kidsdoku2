import SwiftUI
import Foundation

struct PuzzleSelectionView: View {
    let size: Int
    @Binding var path: [KidSudokuRoute]
    
    private var puzzles: [PuzzlePack] {
        PuzzleLibrary.puzzles(for: size)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                headerSection
                
                ForEach(puzzles) { pack in
                    difficultySection(pack: pack)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("\(size)×\(size) Puzzles")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Choose Your Challenge")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(.label))
            
            Text("Pick a puzzle number to start solving")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.secondaryLabel))
        }
        .padding(.top, 16)
    }
    
    private func difficultySection(pack: PuzzlePack) -> some View {
        VStack(spacing: 16) {
            // Difficulty header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(pack.difficulty.displayName)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(pack.difficulty.color)
                    
                    Text(pack.difficulty.description)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(.secondaryLabel))
                }
                
                Spacer()
                
                difficultyIcon(for: pack.difficulty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(pack.difficulty.color.opacity(0.1))
            )
            
            // Puzzle grid
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(pack.puzzles.indices, id: \.self) { index in
                    puzzleButton(
                        number: index + 1,
                        puzzle: pack.puzzles[index],
                        difficulty: pack.difficulty
                    )
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    private func puzzleButton(number: Int, puzzle: PuzzleData, difficulty: PuzzleDifficulty) -> some View {
        Button {
            let config = puzzle.config
            path.append(.puzzle(config: config, puzzleData: puzzle))
        } label: {
            VStack(spacing: 8) {
                Text("\(number)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                // Difficulty stars or completion indicator could go here
                if puzzle.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                } else {
                    Circle()
                        .fill(.white.opacity(0.3))
                        .frame(width: 4, height: 4)
                }
            }
            .frame(width: 64, height: 64)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [difficulty.color, difficulty.color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: difficulty.color.opacity(0.3), radius: 4, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(puzzle.isCompleted ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: puzzle.isCompleted)
    }
    
    private func difficultyIcon(for difficulty: PuzzleDifficulty) -> some View {
        Image(systemName: difficulty.iconName)
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(difficulty.color)
    }
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)
    }
}

// MARK: - Supporting Types

enum PuzzleDifficulty: String, CaseIterable, Identifiable {
    case easy = "easy"
    case normal = "normal"
    case hard = "hard"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .normal: return "Normal"
        case .hard: return "Hard"
        }
    }
    
    var description: String {
        switch self {
        case .easy: return "Perfect for beginners"
        case .normal: return "A good challenge"
        case .hard: return "For puzzle masters"
        }
    }
    
    var color: Color {
        switch self {
        case .easy: return Color(.systemGreen)
        case .normal: return Color(.systemOrange)
        case .hard: return Color(.systemRed)
        }
    }
    
    var iconName: String {
        switch self {
        case .easy: return "leaf.fill"
        case .normal: return "flame.fill"
        case .hard: return "bolt.fill"
        }
    }
}

struct PuzzleData: Identifiable, Hashable {
    let id = UUID()
    let config: KidSudokuConfig
    let puzzle: KidSudokuPuzzle
    let isCompleted: Bool
    
    init(config: KidSudokuConfig, isCompleted: Bool = false) {
        self.config = config
        self.puzzle = KidSudokuGenerator.generatePuzzle(config: config)
        self.isCompleted = isCompleted
    }
    
    static func == (lhs: PuzzleData, rhs: PuzzleData) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct PuzzlePack: Identifiable {
    let id = UUID()
    let difficulty: PuzzleDifficulty
    let puzzles: [PuzzleData]
}

enum PuzzleLibrary {
    static func puzzles(for size: Int) -> [PuzzlePack] {
        guard let config = KidSudokuConfig.configuration(for: size) else { return [] }
        
        return PuzzleDifficulty.allCases.map { difficulty in
            let puzzleCount = puzzleCount(for: difficulty)
            let puzzles = (0..<puzzleCount).map { index in
                PuzzleData(
                    config: configWithDifficulty(config, difficulty: difficulty),
                    isCompleted: shouldMarkAsCompleted(difficulty: difficulty, index: index)
                )
            }
            return PuzzlePack(difficulty: difficulty, puzzles: puzzles)
        }
    }
    
    private static func puzzleCount(for difficulty: PuzzleDifficulty) -> Int {
        switch difficulty {
        case .easy: return 15
        case .normal: return 12
        case .hard: return 10
        }
    }
    
    private static func configWithDifficulty(_ baseConfig: KidSudokuConfig, difficulty: PuzzleDifficulty) -> KidSudokuConfig {
        // Use different symbol groups for variety based on difficulty
        let symbolGroups = SymbolGroup.allCases
        let selectedGroup: SymbolGroup
        
        switch difficulty {
        case .easy:
            // For easy puzzles, use more recognizable symbols
            selectedGroup = [.animals, .fruits].randomElement() ?? .animals
        case .normal:
            // For normal puzzles, use a mix
            selectedGroup = [.sports, .weather, .vehicles].randomElement() ?? .sports
        case .hard:
            // For hard puzzles, use more varied symbols
            selectedGroup = symbolGroups.randomElement() ?? baseConfig.symbolGroup
        }
        
        return KidSudokuConfig(
            size: baseConfig.size,
            subgridRows: baseConfig.subgridRows,
            subgridCols: baseConfig.subgridCols,
            symbolGroup: selectedGroup
        )
    }
    
    private static func shouldMarkAsCompleted(difficulty: PuzzleDifficulty, index: Int) -> Bool {
        // Mark some easy puzzles as completed for demo purposes
        switch difficulty {
        case .easy:
            return index < 3 // First 3 easy puzzles completed
        case .normal:
            return index < 1 // First normal puzzle completed
        case .hard:
            return false // No hard puzzles completed
        }
    }
}

#Preview {
    NavigationStack {
        PuzzleSelectionView(size: 4, path: .constant([]))
    }
}