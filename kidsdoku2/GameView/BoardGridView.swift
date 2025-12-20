import SwiftUI

struct BoardGridView: View {
    let config: KidSudokuConfig
    let cells: [KidSudokuCell]
    let selected: KidSudokuPosition?
    let highlightedValue: Int?
    let showNumbers: Bool
    let completedCellPositions: Set<KidSudokuPosition>
    let completedRows: Set<Int>
    let completedColumns: Set<Int>
    let completedSubgrids: Set<Int>
    let isPuzzleComplete: Bool
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
                                let isCompleted = completedCellPositions.contains(cell.position)
                                BoardCellView(
                                    cell: cell,
                                    config: config,
                                    cellSize: cellSize,
                                    isSelected: selected == cell.position,
                                    isHighlighted: highlightedValue != nil && cell.value == highlightedValue,
                                    isCompleted: isCompleted,
                                    showNumbers: showNumbers,
                                    onTap: onTap
                                )
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
                
                // Completion border overlay
                CompletionBorderOverlay(
                    config: config,
                    completedRows: completedRows,
                    completedColumns: completedColumns,
                    completedSubgrids: completedSubgrids,
                    boardSize: side
                )
                .frame(width: side, height: side)
                .allowsHitTesting(false)
                
                // Full grid completion animation
                if isPuzzleComplete {
                    PuzzleCompleteBorderAnimation(boardSize: side)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: side, height: side)
        }
    }


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

// MARK: - Extracted Cell View (Performance)
struct BoardCellView: View {
    let cell: KidSudokuCell
    let config: KidSudokuConfig
    let cellSize: CGFloat
    let isSelected: Bool
    let isHighlighted: Bool
    let isCompleted: Bool
    let showNumbers: Bool
    let onTap: (KidSudokuCell) -> Void
    
    @Environment(\.gameTheme) private var theme
    
    private enum Layout {
        static let symbolSizeRatio: CGFloat = 0.82
        static let completionScaleEffect: CGFloat = 1.15
        static let springResponse: Double = 0.3
        static let springDamping: Double = 0.5
        static let borderLineWidth: CGFloat = 1
    }
    
    var body: some View {
        Button {
            onTap(cell)
        } label: {
            ZStack {
                Rectangle()
                    .fill(backgroundColor)
                
                if isHighlighted {
                    ThemedGlowingHighlight(size: cellSize)
                }
                
                if isCompleted {
                    CompletionCelebrationEffect(size: cellSize)
                }

                if let value = cell.value {
                    SymbolTokenView(
                        symbolIndex: value,
                        symbolName: symbol(for: value),
                        showNumbers: showNumbers,
                        size: cellSize * Layout.symbolSizeRatio,
                        context: .grid,
                        isSelected: isSelected || isHighlighted
                    )
                    .transition(.scale)
                    .scaleEffect(isCompleted ? Layout.completionScaleEffect : 1.0)
                    .animation(.spring(response: Layout.springResponse, dampingFraction: Layout.springDamping), value: isCompleted)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(width: cellSize, height: cellSize)
        .overlay(
            Rectangle()
                .stroke(theme.cellBorderColor, lineWidth: Layout.borderLineWidth)
        )
        .accessibilityLabel(Text("Cell at row \(cell.position.row + 1), column \(cell.position.col + 1)"))
        .accessibilityValue(Text(cell.value.map { symbol(for: $0) } ?? "Empty"))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
    
    private var backgroundColor: Color {
        if cell.isFixed {
            return theme.fixedCellColor
        }
        if isSelected {
            return theme.selectedCellColor
        }
        return theme.emptyCellColor
    }
    
    private func symbol(for value: Int) -> String {
        // Safety check for array bounds
        guard value >= 0 && value < config.symbols.count else { return "?" }
        return config.symbols[value]
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

/// Celebration effect shown when a row, column, or subgrid is completed
struct CompletionCelebrationEffect: View {
    let size: CGFloat
    @Environment(\.gameTheme) private var theme
    
    @State private var animate = false
    @State private var showStars = false
    
    var body: some View {
        ZStack {
            // Golden glow background
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(
                    RadialGradient(
                        colors: [
                            Color.yellow.opacity(0.6),
                            Color.orange.opacity(0.4),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size, height: size)
                .scaleEffect(animate ? 1.2 : 0.8)
                .opacity(animate ? 0.8 : 0.4)
            
            // Sparkle stars
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: size * 0.2))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .offset(
                        x: starOffset(for: index).x * (animate ? 1 : 0.5),
                        y: starOffset(for: index).y * (animate ? 1 : 0.5)
                    )
                    .scaleEffect(showStars ? 1 : 0)
                    .opacity(showStars ? 1 : 0)
                    .rotationEffect(.degrees(animate ? 360 : 0))
            }
            
            // Celebration ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.yellow.opacity(0.8),
                            Color.orange.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: size * 0.7, height: size * 0.7)
                .scaleEffect(animate ? 1.3 : 0.9)
                .opacity(animate ? 0 : 0.8)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                animate = true
            }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1)) {
                showStars = true
            }
        }
    }
    
    private func starOffset(for index: Int) -> CGPoint {
        let angles: [Double] = [-30, 90, 210]
        let angle = angles[index] * .pi / 180
        let radius = Double(size) * 0.35
        return CGPoint(
            x: Darwin.cos(angle) * radius,
            y: Darwin.sin(angle) * radius
        )
    }
}

/// Animated border overlay for completed rows, columns, and subgrids
struct CompletionBorderOverlay: View {
    let config: KidSudokuConfig
    let completedRows: Set<Int>
    let completedColumns: Set<Int>
    let completedSubgrids: Set<Int>
    let boardSize: CGFloat
    
    @State private var animateGlow = false
    @State private var dashPhase: CGFloat = 0
    
    private var cellSize: CGFloat {
        boardSize / CGFloat(config.size)
    }
    
    private var hasCompletions: Bool {
        !completedRows.isEmpty || !completedColumns.isEmpty || !completedSubgrids.isEmpty
    }
    
    var body: some View {
        ZStack {
            // Row borders
            ForEach(Array(completedRows), id: \.self) { row in
                AnimatedBorderRect(
                    rect: CGRect(
                        x: 0,
                        y: CGFloat(row) * cellSize,
                        width: boardSize,
                        height: cellSize
                    ),
                    cornerRadius: 8,
                    animateGlow: animateGlow,
                    dashPhase: dashPhase
                )
            }
            
            // Column borders
            ForEach(Array(completedColumns), id: \.self) { col in
                AnimatedBorderRect(
                    rect: CGRect(
                        x: CGFloat(col) * cellSize,
                        y: 0,
                        width: cellSize,
                        height: boardSize
                    ),
                    cornerRadius: 8,
                    animateGlow: animateGlow,
                    dashPhase: dashPhase
                )
            }
            
            // Subgrid borders
            ForEach(Array(completedSubgrids), id: \.self) { subgridIndex in
                let subgridRect = rectForSubgrid(index: subgridIndex)
                AnimatedBorderRect(
                    rect: subgridRect,
                    cornerRadius: 12,
                    animateGlow: animateGlow,
                    dashPhase: dashPhase
                )
            }
        }
        .onChange(of: hasCompletions) { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.3)) {
                    animateGlow = true
                }
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    dashPhase = 20
                }
            } else {
                animateGlow = false
                dashPhase = 0
            }
        }
        .onAppear {
            if hasCompletions {
                withAnimation(.easeInOut(duration: 0.3)) {
                    animateGlow = true
                }
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    dashPhase = 20
                }
            }
        }
    }
    
    private func rectForSubgrid(index: Int) -> CGRect {
        let subgridsPerRow = config.size / config.subgridCols
        let subgridRow = index / subgridsPerRow
        let subgridCol = index % subgridsPerRow
        
        let x = CGFloat(subgridCol * config.subgridCols) * cellSize
        let y = CGFloat(subgridRow * config.subgridRows) * cellSize
        let width = CGFloat(config.subgridCols) * cellSize
        let height = CGFloat(config.subgridRows) * cellSize
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

/// Individual animated border rectangle
struct AnimatedBorderRect: View {
    let rect: CGRect
    let cornerRadius: CGFloat
    let animateGlow: Bool
    let dashPhase: CGFloat
    
    var body: some View {
        ZStack {
            // Outer glow
            RoundedRectangle(cornerRadius: cornerRadius + 2)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.yellow.opacity(0.8),
                            Color.orange.opacity(0.6),
                            Color.yellow.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: animateGlow ? 6 : 2
                )
                .blur(radius: animateGlow ? 4 : 1)
                .frame(width: rect.width + 4, height: rect.height + 4)
                .position(x: rect.midX, y: rect.midY)
            
            // Main animated border with marching ants effect
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.yellow,
                            Color.orange,
                            Color.yellow
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: 3,
                        lineCap: .round,
                        lineJoin: .round,
                        dash: [10, 5],
                        dashPhase: dashPhase
                    )
                )
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)
            
            // Inner highlight
            RoundedRectangle(cornerRadius: cornerRadius - 2)
                .stroke(
                    Color.white.opacity(animateGlow ? 0.6 : 0.2),
                    lineWidth: 1.5
                )
                .frame(width: rect.width - 6, height: rect.height - 6)
                .position(x: rect.midX, y: rect.midY)
        }
        .opacity(animateGlow ? 1 : 0)
        .scaleEffect(animateGlow ? 1 : 0.95)
    }
}

/// Full grid border animation when puzzle is completely solved
struct PuzzleCompleteBorderAnimation: View {
    let boardSize: CGFloat
    
    @State private var animate = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    @State private var dashPhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Outer rainbow glow
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    AngularGradient(
                        colors: [
                            .yellow, .orange, .pink, .purple, .blue, .cyan, .green, .yellow
                        ],
                        center: .center,
                        angle: .degrees(rotationAngle)
                    ),
                    lineWidth: animate ? 8 : 4
                )
                .blur(radius: animate ? 8 : 4)
                .frame(width: boardSize + 16, height: boardSize + 16)
                .scaleEffect(pulseScale)
            
            // Secondary glow ring
            RoundedRectangle(cornerRadius: 26)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.yellow.opacity(0.9),
                            Color.orange.opacity(0.7),
                            Color.yellow.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 5
                )
                .blur(radius: 3)
                .frame(width: boardSize + 8, height: boardSize + 8)
            
            // Main animated border
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    AngularGradient(
                        colors: [
                            .yellow, .orange, .yellow, .white, .yellow
                        ],
                        center: .center,
                        angle: .degrees(rotationAngle)
                    ),
                    style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round,
                        lineJoin: .round,
                        dash: [15, 8],
                        dashPhase: dashPhase
                    )
                )
                .frame(width: boardSize, height: boardSize)
            
            // Inner white highlight
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    Color.white.opacity(animate ? 0.7 : 0.3),
                    lineWidth: 2
                )
                .frame(width: boardSize - 8, height: boardSize - 8)
            
            // Corner sparkles
            ForEach(0..<4, id: \.self) { corner in
                Image(systemName: "sparkle")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .white],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .offset(cornerOffset(for: corner))
                    .scaleEffect(animate ? 1.2 : 0.8)
                    .opacity(animate ? 1 : 0.6)
                    .rotationEffect(.degrees(animate ? 180 : 0))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                animate = true
            }
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                dashPhase = 23
            }
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        }
    }
    
    private func cornerOffset(for corner: Int) -> CGSize {
        let offset = boardSize / 2 + 12
        switch corner {
        case 0: return CGSize(width: -offset, height: -offset)
        case 1: return CGSize(width: offset, height: -offset)
        case 2: return CGSize(width: -offset, height: offset)
        case 3: return CGSize(width: offset, height: offset)
        default: return .zero
        }
    }
}
