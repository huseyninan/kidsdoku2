import SwiftUI

struct BoardGridView: View, Equatable {
    let config: KidSudokuConfig
    let cells: [KidSudokuCell]
    let selected: KidSudokuPosition?
    let highlightedValue: Int?
    let showNumbers: Bool
    let onTap: (KidSudokuCell) -> Void
    
    @Environment(\.gameTheme) private var theme
    
    /// PERF: `onTap` is a fresh closure on every parent render, which would otherwise stop
    /// SwiftUI from skipping this view. It always forwards to the same view model, so it is
    /// excluded from the comparison; use with `.equatable()`.
    static func == (lhs: BoardGridView, rhs: BoardGridView) -> Bool {
        lhs.config == rhs.config &&
        lhs.cells == rhs.cells &&
        lhs.selected == rhs.selected &&
        lhs.highlightedValue == rhs.highlightedValue &&
        lhs.showNumbers == rhs.showNumbers
    }
    
    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let cellSize = side / CGFloat(config.size)
            // PERF: `config.symbols` allocates a new array on each access; look it up once per render.
            let symbols = config.symbols

            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(theme.boardBackgroundColor)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                VStack(spacing: 0) {
                    ForEach(0..<config.size, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<config.size, id: \.self) { col in
                                let cell = cells[row * config.size + col]
                                BoardCellView(
                                    cell: cell,
                                    cellSize: cellSize,
                                    symbolName: symbol(for: cell, in: symbols),
                                    isSelected: selected == cell.position,
                                    isMatchingHighlighted: highlightedValue != nil && cell.value == highlightedValue,
                                    showNumbers: showNumbers,
                                    onTap: onTap
                                )
                                .equatable()
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

    private func symbol(for cell: KidSudokuCell, in symbols: [String]) -> String {
        guard let value = cell.value else { return "" }
        // FIXED: Added bounds check to prevent crash if value >= symbols.count
        guard value < symbols.count else { return "" }
        return symbols[value]
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

/// A single board cell. Equatable (ignoring `onTap`) so that a change to one cell
/// only re-renders that cell instead of the whole grid.
private struct BoardCellView: View, Equatable {
    let cell: KidSudokuCell
    let cellSize: CGFloat
    let symbolName: String
    let isSelected: Bool
    let isMatchingHighlighted: Bool
    let showNumbers: Bool
    let onTap: (KidSudokuCell) -> Void
    
    @Environment(\.gameTheme) private var theme
    
    static func == (lhs: BoardCellView, rhs: BoardCellView) -> Bool {
        lhs.cell == rhs.cell &&
        lhs.cellSize == rhs.cellSize &&
        lhs.symbolName == rhs.symbolName &&
        lhs.isSelected == rhs.isSelected &&
        lhs.isMatchingHighlighted == rhs.isMatchingHighlighted &&
        lhs.showNumbers == rhs.showNumbers
    }

    var body: some View {
        Button {
            onTap(cell)
        } label: {
            ZStack {
                Rectangle()
                    .fill(cellBackground)

                if isMatchingHighlighted {
                    ThemedGlowingHighlight(size: cellSize)
                }

                if let value = cell.value {
                    SymbolTokenView(
                        symbolIndex: value,
                        symbolName: symbolName,
                        showNumbers: showNumbers,
                        size: cellSize * 0.82,
                        context: .grid,
                        isSelected: isSelected || isMatchingHighlighted,
                        // PERF: ThemedGlowingHighlight already pulses behind the token;
                        // a second repeat-forever shadow animation per cell is wasted work.
                        animatesGlow: false
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

    private var cellBackground: Color {
        if cell.isFixed {
            return theme.fixedCellColor
        }
        if isSelected {
            return theme.selectedCellColor
        }
        return theme.emptyCellColor
    }
}

struct ThemedGlowingHighlight: View {
    let size: CGFloat
    @Environment(\.gameTheme) private var theme

    @State private var animate = false

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
        // PERF: The layered gradients, blurs and shadows are static and flattened into a
        // single offscreen bitmap with `.drawingGroup()`. Only scale and opacity animate on
        // that bitmap, so the blur is not re-rendered on every frame of the pulse.
        glowLayers
            .frame(width: size, height: size)
            .drawingGroup()
            .scaleEffect(animate ? 1.06 : 0.94)
            .opacity(animate ? 1 : 0.7)
            .onAppear {
                withAnimation(.easeInOut(duration: Layout.animationDuration).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
            .onDisappear {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    animate = false
                }
            }
    }

    private var glowLayers: some View {
        let cornerRadius = size * Layout.cornerRadiusRatio

        return ZStack {
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
                .stroke(Color.white.opacity(0.75), lineWidth: size * 0.03)
                .frame(width: size * Layout.innerFrameRatio, height: size * Layout.innerFrameRatio)

            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(theme.highlightGlowColor.opacity(0.45), lineWidth: size * 0.14)
                .frame(width: size * Layout.glowFrameRatio, height: size * Layout.glowFrameRatio)
                .blur(radius: size * 0.1)
        }
    }
}
