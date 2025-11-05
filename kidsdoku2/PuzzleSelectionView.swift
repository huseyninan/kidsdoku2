import SwiftUI

struct DifficultyTheme {
    let name: String
    let backgroundColor: Color
    let emoji: String
}

struct PuzzleSelectionView: View {
    let size: Int
    @Binding var path: [KidSudokuRoute]
    
    private let themes: [PuzzleDifficulty: DifficultyTheme] = [
        .easy: DifficultyTheme(name: "Sunny Meadow", backgroundColor: Color(red: 0.45, green: 0.55, blue: 0.45), emoji: "🌻"),
        .normal: DifficultyTheme(name: "Whispering Woods", backgroundColor: Color(red: 0.35, green: 0.45, blue: 0.60), emoji: "🌲"),
        .hard: DifficultyTheme(name: "Crystal Caves", backgroundColor: Color(red: 0.30, green: 0.35, blue: 0.50), emoji: "💎")
    ]
    
    private var puzzlesByDifficulty: [(PuzzleDifficulty, [PremadePuzzle])] {
        PuzzleDifficulty.allCases.compactMap { difficulty in
            let filteredPuzzles = PremadePuzzleStore.shared.puzzles(for: size, difficulty: difficulty)
            return filteredPuzzles.isEmpty ? nil : (difficulty, filteredPuzzles)
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.85, green: 0.88, blue: 0.92)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                    
                    VStack(spacing: 12) {
                        ForEach(puzzlesByDifficulty, id: \.0) { difficulty, puzzles in
                            difficultyCard(difficulty: difficulty, puzzles: puzzles)
                        }
                        
                        randomAdventureButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
    
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("🦉")
                .font(.system(size: 44))
            
            Text("Choose Your Adventure")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.3, green: 0.3, blue: 0.35))
            
            Spacer()
            
            Button {
                // Settings action
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
    
    private func difficultyCard(difficulty: PuzzleDifficulty, puzzles: [PremadePuzzle]) -> some View {
        let theme = themes[difficulty] ?? DifficultyTheme(name: difficulty.rawValue, backgroundColor: .gray, emoji: "")
        
        return VStack(spacing: 16) {
            Text("\(difficulty.rawValue) - \(theme.name)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(0..<puzzles.count, id: \.self) { index in
                    if index < puzzles.count {
                        puzzleButton(puzzle: puzzles[index], theme: theme)
                    } else {
                        emptyPuzzleSlot(number: index + 1, theme: theme)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(theme.backgroundColor)
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
    }
    
    private func puzzleButton(puzzle: PremadePuzzle, theme: DifficultyTheme) -> some View {
        Button {
            path.append(.premadePuzzle(puzzle: puzzle))
        } label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.9))
                    .frame(height: 100)
                
                VStack(spacing: -2) {
                    Text("\(puzzle.number)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.35))
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color(red: 0.85, green: 0.82, blue: 0.65))
                        )
                        .padding(.top, 10)
                    
                    Spacer()
                    
                    Text(puzzle.displayEmoji)
                        .font(.system(size: 44))
                        .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .buttonStyle(.plain)
    }
    
    private func emptyPuzzleSlot(number: Int, theme: DifficultyTheme) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.2))
                .frame(height: 100)
            
            Text("\(number)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.5))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.15))
                )
                .padding(8)
        }
    }
    
    private var randomAdventureButton: some View {
        Button {
            path.append(.game(size: size))
        } label: {
            HStack(spacing: 12) {
                Text("🍃")
                    .font(.system(size: 32))
                
                Text("Random\nAdventure")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(red: 0.65, green: 0.35, blue: 0.35))
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PuzzleSelectionView(size: 4, path: .constant([]))
    }
}
