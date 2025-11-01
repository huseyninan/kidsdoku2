import SwiftUI
import Combine

struct GameView: View {
    let config: KidSudokuConfig
    @StateObject private var viewModel: GameViewModel

    init(config: KidSudokuConfig, predefinedPuzzle: PredefinedPuzzle? = nil) {
        self.config = config
        _viewModel = StateObject(wrappedValue: GameViewModel(config: config, predefinedPuzzle: predefinedPuzzle))
    }

    var body: some View {
        VStack(spacing: 20) {
            header

            if let message = viewModel.message {
                messageBanner(message)
            }

            boardSection

            paletteSection

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 28)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("\(config.size) x \(config.size) Puzzle")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("New Puzzle") {
                    withAnimation(.easeInOut) {
                        viewModel.startNewPuzzle()
                    }
                }
                .font(.system(.headline, design: .rounded))
            }
        }
        .alert("Great job!", isPresented: Binding(
            get: { viewModel.showCelebration },
            set: { viewModel.showCelebration = $0 }
        )) {
            Button("Play again") {
                viewModel.startNewPuzzle()
            }
            Button("Keep playing", role: .cancel) { }
        } message: {
            Text("You solved the puzzle perfectly!")
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(titleText)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(.label))

            ProgressView(value: progressRatio)
                .progressViewStyle(.linear)
                .tint(Color.accentColor)
                .scaleEffect(x: 1, y: 1.5, anchor: .center)

            Text(progressText)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.secondaryLabel))
        }
    }

    private var boardSection: some View {
        GeometryReader { geometry in
            let boardSize = min(geometry.size.width, geometry.size.height)
            VStack {
                BoardGridView(
                    config: config,
                    cells: viewModel.puzzle.cells,
                    selected: viewModel.selectedPosition,
                    highlightedValue: viewModel.highlightedValue,
                    onTap: { cell in
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.didTapCell(cell)
                        }
                    }
                )
                .frame(width: boardSize, height: boardSize)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: boardFrameHeight)
    }

    private var paletteSection: some View {
        VStack(spacing: 16) {
            Text("Pick an icon and tap the glowing square")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.secondaryLabel))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(config.symbols.enumerated()), id: \.offset) { entry in
                        paletteButton(symbolIndex: entry.offset, symbol: entry.element)
                    }

                    removeButton
                }
                .padding(.vertical, 12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 6)
        )
    }

    private func paletteButton(symbolIndex: Int, symbol: String) -> some View {
        let isHighlighted = {
            guard let position = viewModel.selectedPosition else { return false }
            let current = viewModel.puzzle.cell(at: position)
            return current.value == symbolIndex
        }()

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                viewModel.placeSymbol(at: symbolIndex)
            }
        } label: {
            Text(symbol)
                .font(.system(size: 32))
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(isHighlighted ? Color.accentColor.opacity(0.25) : Color(.systemGray6))
                )
                .overlay(
                    Circle()
                        .stroke(isHighlighted ? Color.accentColor : Color.clear, lineWidth: 3)
                )
        }
        .buttonStyle(.plain)
    }

    private var removeButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.removeValue()
            }
        } label: {
            Image(systemName: "eraser.fill")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .frame(width: 56, height: 56)
                .foregroundStyle(Color.white)
                .background(
                    Circle()
                        .fill(Color(.systemPink))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Clear selected square")
    }

    private func messageBanner(_ message: KidSudokuMessage) -> some View {
        Text(message.text)
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 18)
            .background(
                Capsule()
                    .fill(color(for: message.type))
            )
            .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func color(for type: KidSudokuMessageType) -> Color {
        switch type {
        case .info:
            return Color(.systemBlue)
        case .success:
            return Color(.systemGreen)
        case .warning:
            return Color(.systemOrange)
        }
    }

    private var titleText: String {
        switch config.size {
        case 4:
            return "4 x 4 puzzle!"
        case 6:
            return "6 x 6 puzzle"
        default:
            return "Have fun with Sudoku!"
        }
    }

    private var progressRatio: Double {
        let total = Double(config.size * config.size)
        let filled = Double(viewModel.puzzle.cells.filter { $0.value != nil }.count)
        return filled / total
    }

    private var progressText: String {
        let filled = viewModel.puzzle.cells.filter { $0.value != nil }.count
        return "\(filled) of \(config.size * config.size) squares filled"
    }

    private var boardFrameHeight: CGFloat {
        switch config.size {
        case 4:
            return 320
        case 6:
            return 360
        default:
            return 360
        }
    }
}

private struct BoardGridView: View {
    let config: KidSudokuConfig
    let cells: [KidSudokuCell]
    let selected: KidSudokuPosition?
    let highlightedValue: Int?
    let onTap: (KidSudokuCell) -> Void

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let cellSize = side / CGFloat(config.size)

            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                VStack(spacing: 0) {
                    ForEach(0..<config.size, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<config.size, id: \.self) { col in
                                let index = row * config.size + col
                                let cell = cells[index]
                                cellView(cell: cell, cellSize: cellSize)
                            }
                        }
                    }
                }
                .frame(width: side, height: side)

                Canvas { context, size in
                    drawSubgridLines(context: &context, size: size)
                }
                .frame(width: side, height: side)
                .allowsHitTesting(false)
            }
            .frame(width: side, height: side)
        }
    }

    private func cellView(cell: KidSudokuCell, cellSize: CGFloat) -> some View {
        let isSelected = selected == cell.position
        let isMatchingHighlighted = {
            guard let highlightedValue = highlightedValue, let cellValue = cell.value else { return false }
            return cellValue == highlightedValue
        }()

        return Button {
            onTap(cell)
        } label: {
            ZStack {
                Rectangle()
                    .fill(cellBackground(for: cell, isSelected: isSelected))

                if isMatchingHighlighted {
                    Circle()
                        .stroke(Color.red, lineWidth: 3)
                        .frame(width: cellSize * 0.7, height: cellSize * 0.7)
                }

                Text(symbol(for: cell))
                    .font(.system(size: cellFontSize))
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(Color(.label))
            }
        }
        .buttonStyle(.plain)
        .frame(width: cellSize, height: cellSize)
        .overlay(
            Rectangle()
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }

    private func cellBackground(for cell: KidSudokuCell, isSelected: Bool) -> Color {
        if cell.isFixed {
            return Color(.systemGray6)
        }
        if isSelected {
            return Color.accentColor.opacity(0.25)
        }
        return Color.white
    }

    private func symbol(for cell: KidSudokuCell) -> String {
        guard let value = cell.value else { return "" }
        return config.symbols[value]
    }

    private var cellFontSize: CGFloat {
        config.size == 4 ? 44 : 36
    }

    // subgrid lines
    private func drawSubgridLines(context: inout GraphicsContext, size: CGSize) {
        let dimension = min(size.width, size.height)
        let cell = dimension / CGFloat(config.size)
        let lineColor = Color(.systemGray3)

        for row in 0...config.size where row % config.subgridRows == 0 {
            var path = Path()
            let y = CGFloat(row) * cell
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: dimension, y: y))
            context.stroke(path, with: .color(lineColor), lineWidth: row == 0 || row == config.size ? 4 : 3)
        }

        for col in 0...config.size where col % config.subgridCols == 0 {
            var path = Path()
            let x = CGFloat(col) * cell
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: dimension))
            context.stroke(path, with: .color(lineColor), lineWidth: col == 0 || col == config.size ? 4 : 3)
        }
    }
}

#Preview {
    GameView(config: .fourByFour)
}

