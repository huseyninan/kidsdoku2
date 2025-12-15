import SwiftUI

struct BoardGridView: View {
    let config: KidSudokuConfig
    let cells: [KidSudokuCell]
    let selected: KidSudokuPosition?
    let highlightedValue: Int?
    let showNumbers: Bool
    let onTap: (KidSudokuCell) -> Void
    
    @Environment(\.gameTheme) private var theme
    
    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let cellSize = side / CGFloat(config.size)

            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(theme.boardBackgroundColor)
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
        // FIXED: Simplified from immediately-invoked closure to direct conditional
        let isMatchingHighlighted = highlightedValue != nil && cell.value == highlightedValue

        return Button {
            onTap(cell)
        } label: {
            ZStack {
                Rectangle()
                    .fill(cellBackground(for: cell, isSelected: isSelected))

                if isMatchingHighlighted {
                    ThemedGlowingHighlight(size: cellSize)
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
                .stroke(theme.cellBorderColor, lineWidth: 1)
        )
    }

    private func cellBackground(for cell: KidSudokuCell, isSelected: Bool) -> Color {
        if cell.isFixed {
            return theme.fixedCellColor
        }
        if isSelected {
            return theme.selectedCellColor
        }
        return theme.emptyCellColor
    }

    private func symbol(for cell: KidSudokuCell) -> String {
        guard let value = cell.value else { return "" }
        // FIXED: Added bounds check to prevent crash if value >= symbols.count
        guard value < config.symbols.count else { return "" }
        return config.symbols[value]
    }

    // NOTE: cellFontSize was removed as it appears unused in this file

    // subgrid lines
    private func drawSubgridLines(context: inout GraphicsContext, size: CGSize) {
        let dimension = min(size.width, size.height)
        let cell = dimension / CGFloat(config.size)
        let lineColor = theme.subgridLineColor

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

struct ThemedGlowingHighlight: View {
    let size: CGFloat
    @Environment(\.gameTheme) private var theme

    @State private var animate = false
    // FIXED: Replaced DispatchQueue-based animation with Task for proper cancellation
    @State private var animationTask: Task<Void, Never>?

    // IMPROVEMENT: Extracted magic numbers to named constants for clarity
    private enum Layout {
        static let cornerRadiusRatio: CGFloat = 0.28
        static let mainFrameRatio: CGFloat = 0.82
        static let strokeFrameRatio: CGFloat = 0.92
        static let innerFrameRatio: CGFloat = 0.8
        static let glowFrameRatio: CGFloat = 0.54
        static let animationDuration: Double = 1.4
    }

    var body: some View {
        let cornerRadius = size * Layout.cornerRadiusRatio

        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            theme.highlightGradientStart,
                            theme.highlightGradientEnd
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * Layout.mainFrameRatio, height: size * Layout.mainFrameRatio)
                .shadow(color: theme.highlightGlowColor.opacity(0.35), radius: 0.1)
                .shadow(color: theme.highlightGlowColor.opacity(0.6), radius: 0.82)

            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.18), lineWidth: size * 0.05)
                .frame(width: size * Layout.strokeFrameRatio, height: size * Layout.strokeFrameRatio)
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
                .frame(width: size * Layout.mainFrameRatio, height: size * Layout.mainFrameRatio)

            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.55), lineWidth: size * 0.03)
                .frame(width: size * Layout.innerFrameRatio, height: size * Layout.innerFrameRatio)
                .blendMode(.screen)
                .opacity(animate ? 0.95 : 0.55)

            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(theme.highlightGlowColor.opacity(animate ? 0.65 : 0.25), lineWidth: size * 0.14)
                .frame(width: size * Layout.glowFrameRatio, height: size * Layout.glowFrameRatio)
                .blur(radius: size * 0.1)
                .opacity(animate ? 1 : 0.7)
        }
        .scaleEffect(animate ? 1.06 : 0.94)
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            // FIXED: Cancel the task to prevent zombie animations and memory leaks
            animationTask?.cancel()
            animationTask = nil
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                animate = false
            }
        }
    }
    
    // FIXED: Replaced DispatchQueue.asyncAfter with Task-based animation loop
    // This ensures proper cancellation when the view disappears
    private func startAnimation() {
        animationTask = Task { @MainActor in
            while !Task.isCancelled {
                withAnimation(.easeInOut(duration: Layout.animationDuration)) {
                    animate = true
                }
                try? await Task.sleep(nanoseconds: UInt64(Layout.animationDuration * 1_000_000_000))
                guard !Task.isCancelled else { break }
                
                withAnimation(.easeInOut(duration: Layout.animationDuration)) {
                    animate = false
                }
                try? await Task.sleep(nanoseconds: UInt64(Layout.animationDuration * 1_000_000_000))
            }
        }
    }
}
