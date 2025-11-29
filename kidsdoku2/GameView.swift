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
    @State private var showNumbers: Bool = false
    @State private var showSettings: Bool = false
    @State private var selectedSymbolGroupRawValue: Int
    
    private var selectedSymbolGroup: SymbolGroup {
        SymbolGroup(rawValue: selectedSymbolGroupRawValue) ?? config.symbolGroup
    }
    
    // Computed property to get the current effective config
    private var currentConfig: KidSudokuConfig {
        if showNumbers {
            return KidSudokuConfig(
                size: config.size,
                subgridRows: config.subgridRows,
                subgridCols: config.subgridCols,
                symbolGroup: .numbers
            )
        } else {
            return KidSudokuConfig(
                size: config.size,
                subgridRows: config.subgridRows,
                subgridCols: config.subgridCols,
                symbolGroup: selectedSymbolGroup
            )
        }
    }

    init(config: KidSudokuConfig) {
        self.config = config
        _viewModel = StateObject(wrappedValue: GameViewModel(config: config))
        _selectedSymbolGroupRawValue = State(initialValue: config.symbolGroup.rawValue)
    }
    
    init(config: KidSudokuConfig, premadePuzzle: PremadePuzzle) {
        self.config = config
        _viewModel = StateObject(wrappedValue: GameViewModel(config: config, premadePuzzle: premadePuzzle))
        _selectedSymbolGroupRawValue = State(initialValue: config.symbolGroup.rawValue)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Background image
                Image("gridbg")
                    .resizable(resizingMode: .stretch)
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
                        
                        // Constrain grid size for iPad to make it more reasonable
                        let maxGridSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 550 : .infinity
                        let side = min(candidate, rawSide, maxGridSize)
                         
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
        .navigationBarBackButtonHidden(viewModel.showCelebration)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSettings) {
            GameSettingsSheet(
                selectedSymbolGroup: Binding(
                    get: { selectedSymbolGroup },
                    set: { selectedSymbolGroupRawValue = $0.rawValue }
                ),
                showNumbers: $showNumbers
            )
        }
        .onChange(of: selectedSymbolGroupRawValue) { _ in
            // The currentConfig computed property will automatically use the updated symbol group
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    private var header: some View {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let spacing: CGFloat = isIPad ? 15 : 10
        let progressBarHeight: CGFloat = isIPad ? 12 : 8
        let progressBarMaxWidth: CGFloat = isIPad ? 140 : 100
        let verticalPadding: CGFloat = isIPad ? 12 : 8
        let horizontalPadding: CGFloat = isIPad ? 18 : 12
        
        return HStack(spacing: spacing) {
            StorybookBadge(text: viewModel.navigationTitle)
                .scaleEffect(isIPad ? 1.2 : 1.0)
            
            Spacer(minLength: 0)
            
            StorybookProgressBar(progress: progressRatio)
                .frame(height: progressBarHeight, alignment: .center)
                .frame(maxWidth: progressBarMaxWidth)
            
            StorybookInfoChip(icon: "clock", text: formattedTime)
                .scaleEffect(isIPad ? 1.2 : 1.0)
            
            Button(action: {
                showSettings = true
                hapticManager.trigger(.selection)
            }) {
                StorybookIconCircle(
                    systemName: "slider.horizontal.3",
                    gradient: [
                        Color(red: 0.7, green: 0.5, blue: 0.9),
                        Color(red: 0.6, green: 0.4, blue: 0.8)
                    ]
                )
                .scaleEffect(isIPad ? 1.3 : 1.0)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
        .background(StorybookHeaderCard())
    }

    private func boardSection(size: CGFloat) -> some View {
        ZStack {
            StorybookBoardMat(size: size)
            
            BoardGridView(
                config: currentConfig,
                cells: viewModel.puzzle.cells,
                selected: viewModel.selectedPosition,
                highlightedValue: viewModel.highlightedValue,
                showNumbers: showNumbers,
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
                Text(currentConfig.symbolGroup.paletteTitle)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(red: 0.44, green: 0.3, blue: 0.23))
                Spacer()
                Text(showNumbers ? "Tap a number below" : "Tap a friend below")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.62, green: 0.47, blue: 0.34))
            }
            
            HStack(spacing: 8) {
                ForEach(Array(currentConfig.symbols.enumerated()).filter { entry in
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
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let buttonSize: CGFloat = isIPad ? 72 : 52
        
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                viewModel.selectPaletteSymbol(symbolIndex)
            }
            hapticManager.trigger(.selection)
        } label: {
            SymbolTokenView(
                symbolIndex: symbolIndex,
                symbolName: symbol,
                showNumbers: showNumbers,
                size: buttonSize,
                context: .palette,
                isSelected: isSelected
            )
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 3)
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
            .multilineTextAlignment(.center)
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

private struct SymbolTokenView: View {
    enum DisplayContext {
        case grid
        case palette
        
        var cornerRadiusScale: CGFloat {
            switch self {
            case .grid:
                return 0.28
            case .palette:
                return 0.35
            }
        }
        
        var contentPaddingScale: CGFloat {
            switch self {
            case .grid:
                return 0.01
            case .palette:
                return 0.01
            }
        }
    }
    
    let symbolIndex: Int
    let symbolName: String
    let showNumbers: Bool
    let size: CGFloat
    let context: DisplayContext
    var isSelected: Bool = false
    
    @State private var glowPhase: CGFloat = 0
    
    private var glowAnimation: Animation {
        .easeInOut(duration: 1.6).repeatForever(autoreverses: true)
    }
    
    private var numberText: String {
        "\(symbolIndex + 1)"
    }
    
    private var selectionBorderColor: Color {
        isSelected ? SymbolColorPalette.badgeColor(for: symbolIndex) : Color.white.opacity(0.25)
    }
    
    var body: some View {
        let gradient = SymbolColorPalette.gradient(for: symbolIndex)
        let cornerRadius = size * context.cornerRadiusScale
        let padding = size * context.contentPaddingScale
        let highlightStrength = max(0, min(1, isSelected ? glowPhase : 0))
        let pulseOverlay = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.35 + 0.25 * highlightStrength),
                        selectionBorderColor.opacity(0.2 + 0.35 * highlightStrength)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blendMode(.plusLighter)
            .opacity(highlightStrength > 0 ? 0.5 + 0.3 * highlightStrength : 0)
            .scaleEffect(1 + 0.05 * highlightStrength)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        
        return ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(pulseOverlay)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            selectionBorderColor.opacity(0.5 + 0.4 * highlightStrength),
                            lineWidth: size * (0.04 + 0.05 * highlightStrength)
                        )
                        .shadow(
                            color: selectionBorderColor.opacity(0.2 + 0.35 * highlightStrength),
                            radius: size * (0.03 + 0.08 * highlightStrength),
                            x: 0,
                            y: size * 0.04
                        )
                )
                .shadow(color: Color.black.opacity(0.12), radius: size * 0.12, x: 0, y: size * 0.08)
            
            Group {
                if showNumbers || symbolName.isEmpty {
                    Text(numberText)
                        .font(.system(size: size * 0.55, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                } else {
                    Image(symbolName)
                        .resizable()
                        .scaledToFit()
                        .padding(padding)
                        .shadow(color: Color.black.opacity(0.18), radius: size * 0.08, x: 0, y: size * 0.04)
                }
            }
            .frame(width: size * 0.88, height: size * 0.88)
        }
        .frame(width: size, height: size)
        .overlay(alignment: .bottomTrailing) {
            if !showNumbers {
                numberBadge
                    .offset(x: -size * 0.01, y: -size * 0.01)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Symbol \(numberText)"))
        .onAppear {
            updateGlowAnimation(isSelected)
        }
        .onChange(of: isSelected) { newValue in
            updateGlowAnimation(newValue)
        }
    }
    
    private var numberBadge: some View {
        Text(numberText)
            .font(.system(size: size * 0.2, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, size * 0.08)
            .padding(.vertical, size * 0.02)
            .background(
                Capsule()
                    .fill(SymbolColorPalette.badgeColor(for: symbolIndex))
            )
            .shadow(color: Color.black.opacity(0.28), radius: size * 0.1, x: 0, y: 1)
    }
    
    private func updateGlowAnimation(_ active: Bool) {
        if active {
            glowPhase = 0
            DispatchQueue.main.async {
                withAnimation(glowAnimation) {
                    glowPhase = 1
                }
            }
        } else {
            withAnimation(.easeOut(duration: 0.25)) {
                glowPhase = 0
            }
        }
    }
}

private enum SymbolColorPalette {
    private static let gradients: [[Color]] = [
        [Color(red: 1.0, green: 0.74, blue: 0.47), Color(red: 0.98, green: 0.51, blue: 0.27)],
        [Color(red: 0.38, green: 0.8, blue: 0.81), Color(red: 0.12, green: 0.6, blue: 0.73)],
        [Color(red: 0.76, green: 0.62, blue: 0.98), Color(red: 0.53, green: 0.4, blue: 0.89)],
        [Color(red: 0.57, green: 0.86, blue: 0.58), Color(red: 0.27, green: 0.64, blue: 0.39)],
        [Color(red: 1.0, green: 0.6, blue: 0.77), Color(red: 0.91, green: 0.33, blue: 0.58)],
        [Color(red: 0.99, green: 0.86, blue: 0.47), Color(red: 0.99, green: 0.69, blue: 0.3)],
        [Color(red: 0.37, green: 0.66, blue: 0.98), Color(red: 0.18, green: 0.43, blue: 0.88)],
        [Color(red: 0.96, green: 0.8, blue: 0.45), Color(red: 0.85, green: 0.53, blue: 0.25)],
        [Color(red: 0.52, green: 0.84, blue: 0.94), Color(red: 0.29, green: 0.63, blue: 0.86)],
        [Color(red: 0.99, green: 0.7, blue: 0.54), Color(red: 0.97, green: 0.48, blue: 0.43)]
    ]
    
    static func gradient(for index: Int) -> [Color] {
        let safeIndex = index % gradients.count
        return gradients[safeIndex]
    }
    
    static func badgeColor(for index: Int) -> Color {
        gradient(for: index).last ?? .orange
    }
}

private struct CelebrationOverlay: View {
    let rating: Double
    let mistakeCount: Int
    let hintCount: Int
    let onDismiss: () -> Void
    
    @State private var showCard = false
    @State private var animateBadge = false
    
    private var perfectGame: Bool {
        mistakeCount == 0 && hintCount == 0
    }
    
    private var subtitle: String {
        if perfectGame {
            return String(localized: "Flawless logic! Not a single hint or mistake.")
        } else if mistakeCount == 0 {
            return String(localized: "Brilliant thinking with just a nudge from hints.")
        } else if hintCount == 0 {
            return String(localized: "You stayed determined and solved it all by yourself!")
        } else {
            return String(localized: "Every puzzle teaches something new. Ready for the next one?")
        }
    }
    
    private var formattedRating: String {
        String(format: "%.1f", rating)
    }
    
    private var metrics: [(icon: String, title: String, value: String)] {
        [
            ("star.fill", String(localized: "Stars"), formattedRating),
            ("xmark.circle.fill", String(localized: "Mistakes"), mistakeCount == 0 ? String(localized: "None") : "\(mistakeCount)"),
            ("lightbulb.fill", String(localized: "Hints"), hintCount == 0 ? String(localized: "None") : "\(hintCount)")
        ]
    }
    
    var body: some View {
        ZStack {
            CelebrationBackdrop()
                .ignoresSafeArea()
                .transition(.opacity)
            
            VStack {
                Spacer()
                celebrationCard
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.05)) {
                showCard = true
            }
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                animateBadge = true
            }
        }
    }
    
    private var celebrationCard: some View {
        VStack(spacing: 24) {
            badge
            
            VStack(spacing: 6) {
                Text(perfectGame ? String(localized: "Storybook Hero!") : String(localized: "Puzzle Complete!"))
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.98, green: 0.74, blue: 0.3),
                                Color(red: 0.96, green: 0.38, blue: 0.57)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(subtitle)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.38, green: 0.28, blue: 0.2))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                StarRatingView(rating: rating)
                    .scaleEffect(1.1)
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.93, blue: 0.74),
                                Color(red: 1.0, green: 0.8, blue: 0.76)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 6)
                    .overlay(
                        Capsule()
                            .fill(Color.white.opacity(0.45))
                            .frame(width: 40, height: 2)
                            .offset(x: -40)
                    )
                    .opacity(0.5)
            }
            
            HStack(spacing: 12) {
                ForEach(metrics, id: \.title) { metric in
                    CelebrationMetric(icon: metric.icon, title: metric.title, value: metric.value)
                }
            }
            
            Button(action: onDismiss) {
                Text(String(localized: "Play Again"))
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.28, green: 0.67, blue: 0.96),
                                        Color(red: 0.49, green: 0.9, blue: 0.87)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.35), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 6)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.top, 4)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(Color.white.opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.89, blue: 0.63),
                            Color(red: 0.97, green: 0.69, blue: 0.81)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 5
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                .blur(radius: 1)
        )
        .shadow(color: Color.black.opacity(0.25), radius: 30, x: 0, y: 18)
        .scaleEffect(showCard ? 1 : 0.85)
        .opacity(showCard ? 1 : 0)
    }
    
    private var badge: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.85, blue: 0.46),
                            Color(red: 1.0, green: 0.63, blue: 0.46)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 110, height: 110)
                .shadow(color: Color.yellow.opacity(0.35), radius: 15, x: 0, y: 5)
            
            Image(systemName: perfectGame ? "crown.fill" : "sparkles")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.white.opacity(0.4), radius: 6, x: 0, y: 2)
        }
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.55), lineWidth: 4)
        )
        .scaleEffect(animateBadge ? 1.03 : 0.97)
    }
}

private struct CelebrationMetric: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.98, green: 0.72, blue: 0.3),
                            Color(red: 0.92, green: 0.35, blue: 0.59)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(red: 0.49, green: 0.36, blue: 0.25))
            
            Text(value)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.18))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 4)
    }
}

private struct CelebrationBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.26, blue: 0.16),
                    Color(red: 0.06, green: 0.38, blue: 0.22),
                    Color(red: 0.08, green: 0.5, blue: 0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            RadialGradient(
                colors: [
                    Color(red: 0.77, green: 0.93, blue: 0.62).opacity(0.6),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 420
            )
            .blendMode(.screen)
            
            CelebrationSparkles()
                .blur(radius: 0.5)
            
            Color.black.opacity(0.25)
        }
    }
}

private struct CelebrationSparkles: View {
    private struct Sparkle: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let color: Color
        let delay: Double
    }
    
    @State private var glow = false
    
    private let sparkles: [Sparkle] = [
        Sparkle(x: 0.18, y: 0.22, size: 6, color: Color.cyan.opacity(0.8), delay: 0.0),
        Sparkle(x: 0.4, y: 0.15, size: 5, color: Color.white.opacity(0.9), delay: 0.2),
        Sparkle(x: 0.72, y: 0.18, size: 7, color: Color.pink.opacity(0.7), delay: 0.4),
        Sparkle(x: 0.9, y: 0.32, size: 5, color: Color.orange.opacity(0.8), delay: 0.6),
        Sparkle(x: 0.13, y: 0.55, size: 8, color: Color.blue.opacity(0.5), delay: 0.1),
        Sparkle(x: 0.32, y: 0.68, size: 5, color: Color.green.opacity(0.6), delay: 0.5),
        Sparkle(x: 0.58, y: 0.62, size: 8, color: Color.yellow.opacity(0.7), delay: 0.3),
        Sparkle(x: 0.84, y: 0.78, size: 6, color: Color.purple.opacity(0.7), delay: 0.7),
        Sparkle(x: 0.23, y: 0.86, size: 4, color: Color.white.opacity(0.6), delay: 0.9),
        Sparkle(x: 0.65, y: 0.88, size: 5, color: Color.cyan.opacity(0.8), delay: 0.2)
    ]
    
    var body: some View {
        GeometryReader { geo in
            ForEach(sparkles) { sparkle in
                Circle()
                    .fill(sparkle.color)
                    .frame(width: sparkle.size, height: sparkle.size)
                    .position(
                        x: sparkle.x * geo.size.width,
                        y: sparkle.y * geo.size.height
                    )
                    .scaleEffect(glow ? 1.4 : 0.7, anchor: .center)
                    .animation(
                        .easeInOut(duration: 1.8)
                            .repeatForever(autoreverses: true)
                            .delay(sparkle.delay),
                        value: glow
                    )
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            glow = true
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
    GameView(config: .threeByThree)
}

