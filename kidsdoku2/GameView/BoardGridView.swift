import SwiftUI

struct BoardGridView: View {
    let config: KidSudokuConfig
    let cells: [KidSudokuCell]
    let selected: KidSudokuPosition?
    let highlightedValue: Int?
    let showNumbers: Bool
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
                    GlowingHighlight(size: cellSize)
                }

                let symbolName = symbol(for: cell)
                if let value = cell.value {
                    SymbolTokenView(
                        symbolIndex: value,
                        symbolName: symbolName,
                        showNumbers: showNumbers,
                        size: cellSize * 0.82,
                        context: .grid,
                        isSelected: isSelected || isMatchingHighlighted
                    )
                    .transition(.scale)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(width: cellSize, height: cellSize)
        .overlay(
            Rectangle()
                .stroke(Color(red: 0.89, green: 0.84, blue: 0.76), lineWidth: 1)
        )
    }

    private func cellBackground(for cell: KidSudokuCell, isSelected: Bool) -> Color {
        if cell.isFixed {
            // Warm beige for fixed cells - like parchment paper in a storybook
            return Color(red: 0.96, green: 0.94, blue: 0.89)
        }
        if isSelected {
            // Red highlight for selected cells
            return Color.red.opacity(0.6)
        }
        // Pure white for empty cells - clean storybook pages
        return Color.white
    }

    private func symbol(for cell: KidSudokuCell) -> String {
        guard let value = cell.value else { return "" }
        let symbol = config.symbols[value]
        return symbol
    }

    private var cellFontSize: CGFloat {
        switch config.size {
        case 3:
            return 52
        case 4:
            return 44
        default:
            return 36
        }
    }

    // subgrid lines
    private func drawSubgridLines(context: inout GraphicsContext, size: CGSize) {
        let dimension = min(size.width, size.height)
        let cell = dimension / CGFloat(config.size)
        // Warm brown color like storybook illustrations
        let lineColor = Color(red: 0.76, green: 0.65, blue: 0.52)

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

struct GlowingHighlight: View {
    let size: CGFloat

    @State private var animate = false
    @State private var isVisible = false

    var body: some View {
        let cornerRadius = size * 0.28

        return ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.23, green: 0.78, blue: 1.0),
                            Color(red: 0.0, green: 0.58, blue: 0.93)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.82, height: size * 0.82)
                .shadow(color: Color.cyan.opacity(0.35), radius: 0.1)
                .shadow(color: Color(red: 0.1, green: 0.7, blue: 0.95).opacity(0.6), radius: 0.82)

            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.18), lineWidth: size * 0.05)
                .frame(width: size * 0.92, height: size * 0.92)
                .blur(radius: size * 0.02)

            RoundedRectangle(cornerRadius: cornerRadius * 0.92)
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.7),
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.45
                    )
                )
                .frame(width: size * 0.82, height: size * 0.82)

            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.55), lineWidth: size * 0.03)
                .frame(width: size * 0.8, height: size * 0.8)
                .blendMode(.screen)
                .opacity(animate ? 0.95 : 0.55)

            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.cyan.opacity(animate ? 0.65 : 0.25), lineWidth: size * 0.14)
                .frame(width: size * 0.54, height: size * 0.54)
                .blur(radius: size * 0.1)
                .opacity(animate ? 1 : 0.7)
        }
        .scaleEffect(animate ? 1.06 : 0.94)
        .onAppear {
            isVisible = true
            startAnimation()
        }
        .onDisappear {
            // Stop animation immediately without triggering new animation
            isVisible = false
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                animate = false
            }
        }
    }
    
    private func startAnimation() {
        guard isVisible else { return }
        withAnimation(.easeInOut(duration: 1.4)) {
            animate = true
        }
        // Schedule the reverse animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            guard isVisible else { return }
            withAnimation(.easeInOut(duration: 1.4)) {
                animate = false
            }
            // Schedule the next cycle
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                startAnimation()
            }
        }
    }
}

