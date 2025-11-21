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
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
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
                // Puzzle name - kid friendly
                Text(viewModel.navigationTitle)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.15), Color.blue.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.purple.opacity(0.3), lineWidth: 2)
                    )
                
                Spacer()
                
                // Sound toggle button - kid friendly
                Button(action: {
                    soundManager.toggleSound()
                    hapticManager.trigger(.selection)
                }) {
                    HStack(spacing: 4) {
                        Text(soundManager.isSoundEnabled ? "🔊" : "🔇")
                            .font(.system(size: 22))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                soundManager.isSoundEnabled 
                                    ? LinearGradient(
                                        colors: [Color.green.opacity(0.3), Color.mint.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                soundManager.isSoundEnabled ? Color.green.opacity(0.5) : Color.gray.opacity(0.3),
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: soundManager.isSoundEnabled ? Color.green.opacity(0.2) : Color.clear,
                        radius: 4,
                        x: 0,
                        y: 2
                    )
                }
                .buttonStyle(.plain)
                .padding(.trailing, 8)
                
                // Timer display - kid friendly
                HStack(spacing: 6) {
                    Text("⏱️")
                        .font(.system(size: 24))
                    Text(formattedTime)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .monospacedDigit()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.5), lineWidth: 2)
                )
                .shadow(color: Color.orange.opacity(0.2), radius: 4, x: 0, y: 2)
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
        HStack(spacing: 10) {
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
        .padding(.horizontal, 10)
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
            hapticManager.trigger(.selection)
        } label: {
            Image(symbol)
                .resizable()
                .scaledToFit()
                .frame(width: 50.0, height: 50.0)
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
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.undo()
                }
                hapticManager.trigger(.light)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Undo")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(viewModel.canUndo ? Color(.label) : Color(.systemGray3))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canUndo)
            
            // Erase button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.removeValue()
                }
                hapticManager.trigger(.light)
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
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.provideHint()
                }
                hapticManager.trigger(.medium)
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
    
    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .blur(radius: 2)
            
            // Liquid glass card
            VStack(spacing: 20) {
                Text("🎉 You're a Star! 🎉")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("You did it! Amazing job\nsolving the puzzle!")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary.opacity(0.8))
                
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
                
                // Glass button
                Button(action: onDismiss) {
                    Text("Yay!")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.blue.opacity(0.8),
                                                Color.purple.opacity(0.6)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.5),
                                                Color.white.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            }
                        )
                        .shadow(color: .blue.opacity(0.4), radius: 15, x: 0, y: 8)
                }
                .buttonStyle(.plain)
            }
            .padding(32)
            .background(
                ZStack {
                    // Glassmorphic background
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.ultraThinMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.25),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                    
                    // Border with gradient
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .shadow(color: .black.opacity(0.2), radius: 30, x: 0, y: 15)
            .shadow(color: .blue.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 40)
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

#Preview {
    GameView(config: .sixBySix)
}

