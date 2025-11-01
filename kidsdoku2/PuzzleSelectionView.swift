import SwiftUI

struct PuzzleSelectionView: View {
    let size: Int
    @Binding var path: [KidSudokuRoute]

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    }

    private let counts: [KidSudokuDifficulty: Int] = [
        .easy: 12,
        .normal: 12,
        .hard: 12
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                sectionView(title: "Easy", difficulty: .easy)
                sectionView(title: "Normal", difficulty: .normal)
                sectionView(title: "Hard", difficulty: .hard)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private func sectionView(title: String, difficulty: KidSudokuDifficulty) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(.label))
                .padding(.horizontal, 4)

            LazyVGrid(columns: columns, spacing: 12) {
                let total = counts[difficulty] ?? 0
                ForEach(0..<total, id: \.self) { index in
                    Button {
                        let seed = seedFor(difficulty: difficulty, index: index)
                        path.append(.gameSeed(size: size, seed: seed))
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 4)
                            Text("\(index + 1)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(.label))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(height: 56)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func seedFor(difficulty: KidSudokuDifficulty, index: Int) -> UInt64 {
        let base: UInt64
        switch difficulty {
        case .easy: base = 0x1111_2222_3333_4444
        case .normal: base = 0x2222_3333_4444_5555
        case .hard: base = 0x3333_4444_5555_6666
        }
        let sizePart = UInt64(size & 0xFF) << 56
        let indexPart: UInt64 = UInt64(index + 1) & 0x0000_FFFF_FFFF_FFFF
        return base ^ sizePart ^ indexPart
    }
}

#Preview {
    NavigationStack {
        PuzzleSelectionView(size: 4, path: .constant([]))
            .navigationTitle("Select Puzzle")
    }
}
