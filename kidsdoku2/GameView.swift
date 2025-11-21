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
        ZStack {
            // Storybook background
            StorybookBackground()
            
            VStack(spacing: 20) {
                header

                boardSection

                paletteSection
                
                actionButtons

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 28)
            .navigationBarBackButtonHidden(false)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
            
            // Confetti overlay
            if viewModel.showCelebration {
                ConfettiView()
                    .allowsHitTesting(false)
                
                // Custom celebration overlay
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

    private var header: some View {
        VStack(spacing: 12) {
            // Top bar with pause button, title, and stars
            HStack {
                // Puzzle name - storybook style
                HStack(spacing: 6) {
                    Text("📖")
                        .font(.system(size: 20))
                    Text(viewModel.navigationTitle)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.8, green: 0.4, blue: 0.9), Color(red: 0.4, green: 0.6, blue: 1.0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.purple.opacity(0.2), radius: 4, x: 0, y: 2)
                        
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.4), Color.blue.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2.5
                            )
                    }
                )
                
                Spacer()
                
                // Sound toggle button - storybook style
                Button(action: {
                    soundManager.toggleSound()
                    hapticManager.trigger(.selection)
                }) {
                    Text(soundManager.isSoundEnabled ? "🔊" : "🔇")
                        .font(.system(size: 24))
                        .padding(10)
                        .background(
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .shadow(color: soundManager.isSoundEnabled ? Color.green.opacity(0.3) : Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
                                
                                Circle()
                                    .stroke(
                                        soundManager.isSoundEnabled 
                                            ? Color.green.opacity(0.6)
                                            : Color.gray.opacity(0.4),
                                        lineWidth: 2.5
                                    )
                            }
                        )
                }
                .buttonStyle(.plain)
                .padding(.trailing, 8)
                
                // Timer display - storybook style
                HStack(spacing: 6) {
                    Text("⏱️")
                        .font(.system(size: 24))
                    Text(formattedTime)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.6, blue: 0.2), Color(red: 1.0, green: 0.4, blue: 0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .monospacedDigit()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.orange.opacity(0.2), radius: 4, x: 0, y: 2)
                        
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.5), Color.pink.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2.5
                            )
                    }
                )
            }
            
            // Theme title - storybook style
            HStack(spacing: 8) {
                Text("🌟")
                    .font(.system(size: 28))
                Text(titleText)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.2, green: 0.8, blue: 0.4), Color(red: 0.4, green: 0.9, blue: 0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.green.opacity(0.3), radius: 2, x: 0, y: 1)
                Text("🌟")
                    .font(.system(size: 28))
            }
            
            // Progress text above bar
            Text(progressText)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.secondaryLabel))

            // Progress bar - storybook style
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .frame(height: 16)
                        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(height: 16)
                    
                    // Progress fill with magical gradient
                    ZStack(alignment: .trailing) {
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.6, blue: 0.2),
                                Color(red: 1.0, green: 0.9, blue: 0.3),
                                Color(red: 0.4, green: 0.9, blue: 0.5)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: max(0, geometry.size.width * progressRatio), height: 12)
                        .cornerRadius(10)
                        .shadow(color: Color.yellow.opacity(0.4), radius: 3, x: 0, y: 0)
                        
                        // Sparkle at the end
                        if progressRatio > 0.05 {
                            Text("✨")
                                .font(.system(size: 16))
                                .offset(x: -4)
                        }
                    }
                    .padding(.leading, 2)
                }
            }
            .frame(height: 16)
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
                        hapticManager.trigger(.selection)
                    }
                )
                .frame(width: boardSize, height: boardSize)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: boardFrameHeight)
    }

    private var paletteSection: some View {
        VStack(spacing: 8) {
            // Decorative label
            HStack(spacing: 6) {
                Text("🎨")
                    .font(.system(size: 18))
                Text("Pick a Friend!")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.purple, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text("🎨")
                    .font(.system(size: 18))
            }
            .padding(.top, 8)
            
            HStack(spacing: 10) {
                ForEach(Array(config.symbols.enumerated()).filter { entry in
                    guard let firstRow = viewModel.puzzle.solution.first else { return true }
                    let symbolIndicesInFirstRow = Set(firstRow.map { $0 })
                    return symbolIndicesInFirstRow.contains(entry.offset)
                }, id: \.offset) { entry in
                    paletteButton(symbolIndex: entry.offset, symbol: entry.element)
                }
            }
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.green.opacity(0.15), radius: 8, x: 0, y: 3)
                
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.green.opacity(0.4),
                                Color.mint.opacity(0.4),
                                Color.cyan.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2.5
                    )
            }
        )
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
                // Magical glow for selected
                if isSelected {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.yellow.opacity(0.4),
                                    Color.orange.opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 35
                            )
                        )
                        .frame(width: 60, height: 60)
                }
                
                Image(symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50.0, height: 50.0)
                    .background(
                        Circle()
                            .fill(
                                isSelected 
                                    ? LinearGradient(
                                        colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [Color.white, Color(.systemGray6).opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                            )
                            .shadow(color: isSelected ? Color.yellow.opacity(0.3) : Color.black.opacity(0.1), radius: isSelected ? 6 : 3, x: 0, y: 2)
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected 
                                    ? LinearGradient(
                                        colors: [Color.yellow, Color.orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [Color.gray.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                lineWidth: isSelected ? 3 : 2
                            )
                    )
                    .scaleEffect(isSelected ? 1.1 : 1.0)
            }
        }
        .buttonStyle(.plain)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            // Undo button - storybook style
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.undo()
                }
                hapticManager.trigger(.light)
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .font(.system(size: 28, weight: .semibold))
                    Text("Undo")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundStyle(
                    viewModel.canUndo 
                        ? LinearGradient(
                            colors: [Color.blue, Color.cyan],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        : LinearGradient(
                            colors: [Color.gray.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: viewModel.canUndo ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                viewModel.canUndo ? Color.blue.opacity(0.4) : Color.gray.opacity(0.3),
                                lineWidth: 2
                            )
                    }
                )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canUndo)
            
            // Erase button - storybook style
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.removeValue()
                }
                hapticManager.trigger(.light)
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28, weight: .semibold))
                    Text("Erase")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.red, Color.orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.red.opacity(0.2), radius: 4, x: 0, y: 2)
                        
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red.opacity(0.4), lineWidth: 2)
                    }
                )
            }
            .buttonStyle(.plain)
            
            // Hint button - storybook style
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.provideHint()
                }
                hapticManager.trigger(.medium)
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 28, weight: .semibold))
                    Text("Hint")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.yellow.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                    }
                )
            }
            .buttonStyle(.plain)
        }
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
                // Storybook board background with decorative shadow
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color(red: 0.98, green: 0.98, blue: 1.0)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.purple.opacity(0.15), radius: 12, x: 0, y: 6)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                
                // Decorative border
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.purple.opacity(0.2),
                                Color.blue.opacity(0.2),
                                Color.green.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )

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
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }

    private func cellBackground(for cell: KidSudokuCell, isSelected: Bool) -> Color {
        if cell.isFixed {
            return Color(red: 0.97, green: 0.97, blue: 0.99)
        }
        if isSelected {
            return Color(red: 1.0, green: 0.95, blue: 0.7).opacity(0.6)
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

private struct CelebrationOverlay: View {
    let rating: Double
    let mistakeCount: Int
    let hintCount: Int
    let onDismiss: () -> Void
    
    @State private var celebrationScale: CGFloat = 0.8
    @State private var celebrationOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Magical storybook background
            Color(red: 0.3, green: 0.2, blue: 0.5)
                .opacity(0.4)
                .ignoresSafeArea()
                .blur(radius: 3)
            
            // Storybook celebration card
            VStack(spacing: 20) {
                // Magical title with decorations
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Text("✨")
                            .font(.system(size: 32))
                        Text("🌟")
                            .font(.system(size: 32))
                        Text("✨")
                            .font(.system(size: 32))
                    }
                    
                    Text("You're a Star!")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.8, blue: 0.2),
                                    Color(red: 1.0, green: 0.6, blue: 0.3),
                                    Color(red: 1.0, green: 0.4, blue: 0.6)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color.yellow.opacity(0.5), radius: 8, x: 0, y: 2)
                }
                
                Text("You did it! Amazing job\nsolving the puzzle!")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.purple, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Star rating with glow
                HStack(spacing: 4) {
                    StarRatingView(rating: rating)
                }
                .padding(.vertical, 8)
                .shadow(color: .yellow.opacity(0.5), radius: 10)
                
                // Stats
                let penalties = mistakeCount + hintCount
                if penalties == 0 {
                    Text("Perfect game! ⭐️")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                } else {
                    Text("\(mistakeCount) mistakes • \(hintCount) hints")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.primary.opacity(0.7))
                }
                
                // Magical storybook button
                Button(action: onDismiss) {
                    HStack(spacing: 8) {
                        Text("🎊")
                            .font(.system(size: 24))
                        Text("Hooray!")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        Text("🎊")
                            .font(.system(size: 24))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.5, blue: 0.3),
                                            Color(red: 0.9, green: 0.3, blue: 0.6),
                                            Color(red: 0.6, green: 0.3, blue: 0.9)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.purple.opacity(0.5), radius: 12, x: 0, y: 6)
                            
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    Color.white.opacity(0.5),
                                    lineWidth: 2
                                )
                        }
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(36)
            .background(
                ZStack {
                    // Storybook page background
                    RoundedRectangle(cornerRadius: 32)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.98, blue: 0.95),
                                    Color.white
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Magical border with rainbow gradient
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.7, blue: 0.8),
                                    Color(red: 0.8, green: 0.6, blue: 1.0),
                                    Color(red: 0.6, green: 0.8, blue: 1.0),
                                    Color(red: 0.6, green: 1.0, blue: 0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                }
            )
            .shadow(color: Color.purple.opacity(0.3), radius: 30, x: 0, y: 15)
            .shadow(color: Color.pink.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 40)
            .scaleEffect(celebrationScale)
            .opacity(celebrationOpacity)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    celebrationScale = 1.0
                    celebrationOpacity = 1.0
                }
            }
        }
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

// MARK: - Storybook Background
private struct StorybookBackground: View {
    @State private var animateStars = false
    
    var body: some View {
        ZStack {
            // Base gradient - soft pastel storybook colors
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.92, blue: 1.0),
                    Color(red: 0.98, green: 0.95, blue: 0.98),
                    Color(red: 0.92, green: 0.95, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle pattern overlay for storybook paper texture
            Canvas { context, size in
                let dotSpacing: CGFloat = 30
                let dotRadius: CGFloat = 1.5
                
                for x in stride(from: 0, to: size.width, by: dotSpacing) {
                    for y in stride(from: 0, to: size.height, by: dotSpacing) {
                        var path = Path()
                        path.addEllipse(in: CGRect(x: x, y: y, width: dotRadius, height: dotRadius))
                        context.fill(path, with: .color(Color.purple.opacity(0.05)))
                    }
                }
            }
            .ignoresSafeArea()
            
            // Decorative floating elements
            GeometryReader { geometry in
                // Top left cloud
                Text("☁️")
                    .font(.system(size: 40))
                    .opacity(0.3)
                    .position(x: 60, y: 80)
                
                // Top right stars
                Text("✨")
                    .font(.system(size: 24))
                    .opacity(0.4)
                    .position(x: geometry.size.width - 50, y: 100)
                    .scaleEffect(animateStars ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateStars)
                
                // Bottom decoration
                Text("🌈")
                    .font(.system(size: 35))
                    .opacity(0.25)
                    .position(x: geometry.size.width - 70, y: geometry.size.height - 100)
                
                Text("⭐️")
                    .font(.system(size: 20))
                    .opacity(0.35)
                    .position(x: 40, y: geometry.size.height - 150)
                    .scaleEffect(animateStars ? 0.8 : 1.2)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.5), value: animateStars)
            }
            .ignoresSafeArea()
        }
        .onAppear {
            animateStars = true
        }
    }
}

#Preview {
    GameView(config: .sixBySix)
}

