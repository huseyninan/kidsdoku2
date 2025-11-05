import SwiftUI
import Combine

struct GameView: View {
    let config: KidSudokuConfig
    @StateObject private var viewModel: GameViewModel

    init(config: KidSudokuConfig) {
        self.config = config
        _viewModel = StateObject(wrappedValue: GameViewModel(config: config))
    }
    
    init(config: KidSudokuConfig, premadePuzzle: PremadePuzzle) {
        self.config = config
        _viewModel = StateObject(wrappedValue: GameViewModel(config: config, premadePuzzle: premadePuzzle))
    }

    var body: some View {
        VStack(spacing: 20) {
            header

            if let message = viewModel.message {
                messageBanner(message)
            }

            boardSection

            paletteSection
            
            actionButtons

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 28)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(false)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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
        VStack(spacing: 12) {
            // Top bar with pause button, title, and stars
            HStack {
                Text(viewModel.navigationTitle)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(.label))
                
                Spacer()
                
                HStack(spacing: 4) {
                    ForEach(0..<3) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            // Theme title
            Text(titleText)
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.green)
            
            // Progress text above bar
            Text(progressText)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.secondaryLabel))

            // Progress bar with gradient
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                    
                    LinearGradient(
                        colors: [Color.orange, Color.yellow, Color.green.opacity(0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * progressRatio, height: 12)
                    .cornerRadius(8)
                }
            }
            .frame(height: 12)
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
        HStack(spacing: 12) {
            ForEach(Array(config.symbols.enumerated()).filter { entry in
                guard let firstRow = viewModel.puzzle.solution.first else { return true }
                let symbolIndicesInFirstRow = Set(firstRow.map { $0 })
                return symbolIndicesInFirstRow.contains(entry.offset)
            }, id: \.offset) { entry in
                paletteButton(symbolIndex: entry.offset, symbol: entry.element)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.green.opacity(0.15))
        )
    }

    private func paletteButton(symbolIndex: Int, symbol: String) -> some View {
        let isSelected = viewModel.selectedPaletteSymbol == symbolIndex

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                viewModel.selectPaletteSymbol(symbolIndex)
            }
        } label: {
            Text(symbol)
                .font(.system(size: 32))
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(isSelected ? Color.accentColor.opacity(0.25) : Color(.systemGray6))
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
                )
        }
        .buttonStyle(.plain)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            // Undo button
            Button(action: {
                // Undo action
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Undo")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(Color(.label))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                )
            }
            .buttonStyle(.plain)
            
            // Erase button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.removeValue()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Erase")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(Color(.label))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                )
            }
            .buttonStyle(.plain)
            
            // Hint button
            Button(action: {
                // Hint action
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Hint")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(Color(.label))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                )
            }
            .buttonStyle(.plain)
        }
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
        return "Veggie Match!"
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
        let symbol = config.symbols[value]
        return symbol
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
            
            // Use dashed lines for subgrid separators, solid for borders
            if row == 0 || row == config.size {
                context.stroke(path, with: .color(lineColor), lineWidth: 4)
            } else {
                context.stroke(path, with: .color(lineColor), style: StrokeStyle(lineWidth: 3, dash: [6, 4]))
            }
        }

        for col in 0...config.size where col % config.subgridCols == 0 {
            var path = Path()
            let x = CGFloat(col) * cell
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: dimension))
            
            // Use dashed lines for subgrid separators, solid for borders
            if col == 0 || col == config.size {
                context.stroke(path, with: .color(lineColor), lineWidth: 4)
            } else {
                context.stroke(path, with: .color(lineColor), style: StrokeStyle(lineWidth: 3, dash: [6, 4]))
            }
        }
    }
}

#Preview {
    GameView(config: .sixBySix)
}

