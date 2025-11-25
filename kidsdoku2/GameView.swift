import SwiftUI
import Combine

struct GameView: View {
    let config: KidSudokuConfig
    @StateObject private var viewModel: GameViewModel
    @StateObject private var soundManager = SoundManager.shared
    @StateObject private var hapticManager = HapticManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?

    init(config: KidSudokuConfig) {
        self.config = config
        _viewModel = StateObject(wrappedValue: GameViewModel(config: config))
    }
    
    init(config: KidSudokuConfig, premadePuzzle: PremadePuzzle) {
        self.config = config
        _viewModel = StateObject(wrappedValue: GameViewModel(config: config, premadePuzzle: premadePuzzle))
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                StorybookBackground()
                    .ignoresSafeArea()
                
                // Animated running fox at the bottom of the screen
                VStack {
                    Spacer()
                    RunningFoxView()
                        .frame(height: 200)
                        .allowsHitTesting(false)
                }
                
                VStack(spacing: 8) {
                    header
                    
                    GeometryReader { innerProxy in
                        let rawSide = min(innerProxy.size.width, innerProxy.size.height)
                        let inset: CGFloat = 35
                        let candidate = max(200, rawSide - inset)
                        let side = min(candidate, rawSide)
                         
                        boardSection(size: side)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .animation(.easeInOut(duration: 0.2), value: viewModel.puzzle.cells)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    paletteSection
                    
                    actionButtons
                }
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .padding(.bottom, max(proxy.safeAreaInsets.bottom, 12))
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
                
                if viewModel.showCelebration {
                    ConfettiView()
                        .allowsHitTesting(false)
                    
                    CelebrationOverlay(
                        rating: viewModel.calculateStars(),
                        mistakeCount: viewModel.mistakeCount,
                        hintCount: viewModel.hintCount,
                        onDismiss: {
                            dismiss()
                        }
                    )
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            StorybookBadge(text: viewModel.navigationTitle)
            
            Spacer(minLength: 0)
            
            StorybookProgressBar(progress: progressRatio)
                .frame(height: 8, alignment: .center)
                .frame(maxWidth: 100)
            
            StorybookInfoChip(icon: "clock", text: formattedTime)
            
            Button(action: {
                soundManager.toggleSound()
                hapticManager.trigger(.selection)
            }) {
                StorybookIconCircle(
                    systemName: soundManager.isSoundEnabled ? "music.note" : "speaker.slash.fill",
                    gradient: soundManager.isSoundEnabled
                        ? [Color(red: 0.37, green: 0.67, blue: 0.39), Color(red: 0.23, green: 0.52, blue: 0.32)]
                        : [Color(red: 0.74, green: 0.74, blue: 0.75), Color(red: 0.6, green: 0.6, blue: 0.62)]
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(StorybookHeaderCard())
    }

    private func boardSection(size: CGFloat) -> some View {
        ZStack {
            StorybookBoardMat(size: size)
            
            BoardGridView(
                config: config,
                cells: viewModel.puzzle.cells,
                selected: viewModel.selectedPosition,
                highlightedValue: viewModel.highlightedValue,
                onTap: { cell in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        viewModel.didTapCell(cell)
                    }
                    hapticManager.trigger(.selection)
                }
            )
            .frame(width: size, height: size)
        }
        .frame(maxWidth: .infinity)
    }

    private var paletteSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text(config.symbolGroup.paletteTitle)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(red: 0.44, green: 0.3, blue: 0.23))
                Spacer()
                Text("Tap a friend below")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.62, green: 0.47, blue: 0.34))
            }
            
            HStack(spacing: 8) {
                ForEach(Array(config.symbols.enumerated()).filter { entry in
                    guard let firstRow = viewModel.puzzle.solution.first else { return true }
                    let symbolIndicesInFirstRow = Set(firstRow.map { $0 })
                    return symbolIndicesInFirstRow.contains(entry.offset)
                }, id: \.offset) { entry in
                    paletteButton(symbolIndex: entry.offset, symbol: entry.element)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(StorybookPaletteMat())
    }

    private func paletteButton(symbolIndex: Int, symbol: String) -> some View {
        let isSelected = viewModel.selectedPaletteSymbol == symbolIndex

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                viewModel.selectPaletteSymbol(symbolIndex)
            }
            hapticManager.trigger(.selection)
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isSelected
                                ? [Color(red: 1.0, green: 0.89, blue: 0.74), Color(red: 0.96, green: 0.72, blue: 0.46)]
                                : [Color.white, Color(red: 0.95, green: 0.95, blue: 0.93)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 2)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color(red: 0.92, green: 0.58, blue: 0.26) : Color(red: 0.87, green: 0.87, blue: 0.85), lineWidth: 2.5)
                    )
                
                Image(symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .padding(3)
            }
            .frame(width: 52, height: 52)
            .scaleEffect(isSelected ? 1.08 : 1.0)
        }
        .buttonStyle(.plain)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            StorybookActionButton(
                title: String(localized: "Undo"),
                icon: "arrow.uturn.backward",
                isEnabled: viewModel.canUndo,
                gradient: [
                    Color(red: 0.98, green: 0.89, blue: 0.75),
                    Color(red: 0.97, green: 0.78, blue: 0.58)
                ],
                action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.undo()
                    }
                    hapticManager.trigger(.light)
                }
            )
            
            StorybookActionButton(
                title: String(localized: "Erase"),
                icon: "xmark.circle",
                isEnabled: true,
                gradient: [
                    Color(red: 0.95, green: 0.85, blue: 0.95),
                    Color(red: 0.88, green: 0.7, blue: 0.92)
                ],
                action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.removeValue()
                    }
                    hapticManager.trigger(.light)
                }
            )
            
            StorybookActionButton(
                title: String(localized: "Hint"),
                icon: "lightbulb",
                isEnabled: true,
                gradient: [
                    Color(red: 1.0, green: 0.93, blue: 0.76),
                    Color(red: 0.99, green: 0.82, blue: 0.64)
                ],
                action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.provideHint()
                    }
                    hapticManager.trigger(.medium)
                }
            )
        }
        .disabled(viewModel.showCelebration)
        .onChange(of: viewModel.showCelebration) { isShowing in
            if isShowing {
                stopTimer()
                hapticManager.trigger(.success)
            }
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
        return String(localized: "Veggie Match!")
    }

    private var progressRatio: Double {
        let total = Double(config.size * config.size)
        let filled = Double(viewModel.puzzle.cells.filter { $0.value != nil }.count)
        return min(1.0, max(0.0, filled / total))
    }

    private var progressText: String {
        let filled = viewModel.puzzle.cells.filter { $0.value != nil }.count
        return String(localized: "\(filled) of \(config.size * config.size) squares filled")
    }

    private var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !viewModel.showCelebration {
                elapsedTime += 1
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
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
                    GlowingHighlight(size: cellSize)
                }

                Image(symbol(for: cell))
                    .resizable()
                    .scaledToFit()
                    .frame(width: cellSize * 0.9, height: cellSize * 0.9)
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
            // Soft peach glow for selected cells - friendly and inviting
            return Color(red: 1.0, green: 0.89, blue: 0.74).opacity(0.6)
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

    private struct GlowingHighlight: View {
        let size: CGFloat

        @State private var animate = false

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
            .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: animate)
            .onAppear {
                animate = true
            }
            .onDisappear {
                animate = false
            }
        }
    }
}

private struct StorybookBadge: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 15, weight: .heavy, design: .rounded))
            .foregroundStyle(Color(red: 0.33, green: 0.22, blue: 0.12))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.99, green: 0.94, blue: 0.82),
                                Color(red: 0.95, green: 0.87, blue: 0.74)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                Capsule()
                    .stroke(Color(red: 0.85, green: 0.67, blue: 0.46), lineWidth: 1)
            )
    }
}

private struct StorybookIconCircle: View {
    let systemName: String
    let gradient: [Color]
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 30, height: 30)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

private struct StorybookInfoChip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(text)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
        .foregroundStyle(Color(red: 0.62, green: 0.34, blue: 0.24))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule().fill(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.92, blue: 0.81),
                        Color(red: 0.98, green: 0.82, blue: 0.65)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        )
    }
}

private struct StorybookProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.6))
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.99, green: 0.78, blue: 0.33),
                                Color(red: 0.98, green: 0.6, blue: 0.37),
                                Color(red: 0.4, green: 0.7, blue: 0.35)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(12, geo.size.width * progress))
            }
        }
    }
}

private struct StorybookMiniBoardPreview: View {
    let symbols: [String]
    
    private var previewSymbols: [String] {
        guard !symbols.isEmpty else { return Array(repeating: "", count: 9) }
        return (0..<9).map { symbols[$0 % symbols.count] }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.85))
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 3)
            
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                .foregroundColor(Color(red: 0.94, green: 0.75, blue: 0.57))
            
            VStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { col in
                            let index = row * 3 + col
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(red: 0.98, green: 0.95, blue: 0.9))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color(red: 0.93, green: 0.85, blue: 0.74), lineWidth: 1)
                                    )
                                if index < previewSymbols.count, !previewSymbols[index].isEmpty {
                                    Image(previewSymbols[index])
                                        .resizable()
                                        .scaledToFit()
                                        .padding(4)
                                }
                            }
                        }
                    }
                }
            }
            .padding(8)
        }
        .frame(width: 104, height: 104)
    }
}

private struct StorybookBackground: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            
            ZStack(alignment: .bottom) {
                LinearGradient(
                    colors: [
                        Color(red: 0.9, green: 0.95, blue: 1.0),
                        Color(red: 0.98, green: 0.93, blue: 0.85)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                StorybookCloud()
                    .scaleEffect(1.1)
                    .offset(x: -width * 0.25, y: -height * 0.35)
                StorybookCloud()
                    .scaleEffect(0.8)
                    .offset(x: width * 0.35, y: -height * 0.3)
                StorybookCloud()
                    .scaleEffect(0.6)
                    .offset(x: width * 0.05, y: -height * 0.42)
                
                StorybookHill(width: width * 1.4, height: height * 0.35, color: Color(red: 0.68, green: 0.86, blue: 0.57))
                    .offset(x: -width * 0.2, y: height * 0.02)
                StorybookHill(width: width * 1.2, height: height * 0.28, color: Color(red: 0.5, green: 0.74, blue: 0.47))
                    .offset(x: width * 0.25, y: height * 0.05)
            }
            .frame(width: width, height: height)
        }
    }
}

private struct StorybookCloud: View {
    var body: some View {
        ZStack {
            Circle().fill(Color.white.opacity(0.85)).frame(width: 110, height: 80).offset(x: -40, y: 10)
            Circle().fill(Color.white.opacity(0.8)).frame(width: 100, height: 70).offset(x: 10, y: 0)
            Circle().fill(Color.white.opacity(0.9)).frame(width: 120, height: 90).offset(x: 40, y: 12)
        }
        .blur(radius: 0.3)
    }
}

private struct StorybookHill: View {
    let width: CGFloat
    let height: CGFloat
    let color: Color
    
    var body: some View {
        Ellipse()
            .fill(color)
            .frame(width: width, height: height)
            .shadow(color: color.opacity(0.4), radius: 10, x: 0, y: -6)
    }
}

private struct StorybookHeaderCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.9),
                        Color(red: 0.99, green: 0.94, blue: 0.86)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color(red: 0.91, green: 0.83, blue: 0.7), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 6)
    }
}

private struct StorybookPaletteMat: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.97, blue: 0.91),
                        Color(red: 0.96, green: 0.92, blue: 0.84)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color(red: 0.91, green: 0.82, blue: 0.69), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

private struct StorybookBoardMat: View {
    let size: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.97, blue: 0.92),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size + 30, height: size + 30)
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.94, green: 0.83, blue: 0.67),
                                Color(red: 0.86, green: 0.68, blue: 0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 3, dash: [10, 6])
                    )
            )
    }
}

private struct StorybookActionButton: View {
    let title: String
    let icon: String
    let isEnabled: Bool
    let gradient: [Color]
    let action: () -> Void
    
    private var resolvedGradient: [Color] {
        guard gradient.count >= 2 else {
            return [Color.white, Color.white.opacity(0.95)]
        }
        return gradient
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isEnabled ? Color(red: 0.37, green: 0.28, blue: 0.18) : Color(.systemGray3))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: resolvedGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 4)
            .opacity(isEnabled ? 1 : 0.6)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

private struct CelebrationOverlay: View {
    let rating: Double
    let mistakeCount: Int
    let hintCount: Int
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .blur(radius: 3)
            
            // Fun Card
            VStack(spacing: 24) {
                // Title with bounce
                Text("YOU DID IT!")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orange, Color.pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.orange.opacity(0.3), radius: 2, x: 0, y: 2)
                
                Text("Amazing job!\nYou're a Sudoku Star!")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(red: 0.4, green: 0.3, blue: 0.2))
                    .padding(.bottom, 4)
                
                // Star rating with glow
                HStack(spacing: 8) {
                    StarRatingView(rating: rating)
                        .scaleEffect(1.2)
                }
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(Color.yellow.opacity(0.15))
                        .blur(radius: 10)
                )
                
                // Stats
                let penalties = mistakeCount + hintCount
                if penalties == 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(Color.yellow)
                        Text("Perfect Game!")
                    }
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.green)
                } else {
                    HStack(spacing: 16) {
                        if mistakeCount > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill")
                                Text("\(mistakeCount)")
                            }
                            .foregroundStyle(Color.red.opacity(0.7))
                        }
                        if hintCount > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "lightbulb.fill")
                                Text("\(hintCount)")
                            }
                            .foregroundStyle(Color.orange)
                        }
                    }
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                
                // Big Fun Button
                Button(action: onDismiss) {
                    Text("Play Again!")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.cyan],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 5)
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.3), lineWidth: 3)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.top, 8)
            }
            .padding(32)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.white)
                    
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.95, blue: 0.8),
                                    Color(red: 1.0, green: 0.9, blue: 0.9)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 8
                        )
                }
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 36)
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

private struct StarRatingView: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                starView(for: index)
            }
        }
    }
    
    private func starView(for index: Int) -> some View {
        let starValue = rating - Double(index)
        
        return Group {
            if starValue >= 1.0 {
                // Full star
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            } else if starValue >= 0.5 {
                // Half star
                Image(systemName: "star.leadinghalf.filled")
                    .foregroundColor(.yellow)
            } else {
                // Empty star
                Image(systemName: "star")
                    .foregroundColor(.gray)
            }
        }
        .font(.system(size: 40))
    }
}

#Preview {
    GameView(config: .sixBySix)
}

