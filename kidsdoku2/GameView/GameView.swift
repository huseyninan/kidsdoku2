import SwiftUI

struct GameView: View {
    let config: KidSudokuConfig
    @StateObject private var viewModel: GameViewModel
    private let hapticManager = HapticManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showSettings: Bool = false

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
            let boardSize = computeBoardSize(from: proxy)
            
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
                    
                    boardSection(size: boardSize)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    
                    paletteSection
                    
                    actionButtons
                }
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .padding(.bottom, max(proxy.safeAreaInsets.bottom, 12))
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
                
                if viewModel.showCelebration {
                    CelebrationOverlay(
                        rating: viewModel.calculateStars(),
                        mistakeCount: viewModel.mistakeCount,
                        hintCount: viewModel.hintCount,
                        onDismiss: {
                            dismiss()
                        }
                    )
                }
                
                // Message banner overlay
                if let message = viewModel.message {
                    VStack {
                        messageBanner(message)
                            .padding(.top, 60)
                        Spacer()
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.message?.text)
                    .allowsHitTesting(false)
                }
            }
        }
        .navigationBarBackButtonHidden(viewModel.showCelebration)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSettings) {
            GameSettingsSheet(
                selectedSymbolGroup: Binding(
                    get: { viewModel.selectedSymbolGroup },
                    set: { viewModel.selectedSymbolGroupRawValue = $0.rawValue }
                ),
                showNumbers: $viewModel.showNumbers
            )
        }
        .onAppear {
            viewModel.startTimer()
            viewModel.showInitialMessage()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
    }

    private var header: some View {
        HStack(spacing: DeviceSizing.headerSpacing) {
            StorybookBadge(text: viewModel.navigationTitle)
                .scaleEffect(DeviceSizing.badgeScale)
            
            Spacer(minLength: 0)
            
            StorybookProgressBar(progress: progressRatio)
                .frame(height: DeviceSizing.progressBarHeight, alignment: .center)
                .frame(maxWidth: DeviceSizing.progressBarMaxWidth)
            
            GameTimerView(viewModel: viewModel)
            
            Button(action: {
                showSettings = true
                hapticManager.trigger(.selection)
            }) {
                StorybookIconCircle(
                    systemName: "slider.horizontal.3",
                    gradient: [
                        Theme.Colors.gameSettingsGradientStart,
                        Theme.Colors.gameSettingsGradientEnd
                    ]
                )
                .scaleEffect(DeviceSizing.settingsButtonScale)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, DeviceSizing.headerVerticalPadding)
        .padding(.horizontal, DeviceSizing.headerHorizontalPadding)
        .background(StorybookHeaderCard())
    }

    private func boardSection(size: CGFloat) -> some View {
        ZStack {
            StorybookBoardMat(size: size)
            
            BoardGridView(
                config: viewModel.currentConfig,
                cells: viewModel.puzzle.cells,
                selected: viewModel.selectedPosition,
                highlightedValue: viewModel.highlightedValue,
                showNumbers: viewModel.showNumbers,
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
                Text(viewModel.currentConfig.symbolGroup.paletteTitle)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.Colors.gamePaletteTitle)
                Spacer()
                Text(viewModel.showNumbers ? "Tap a number below" : "Tap a friend below")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.Colors.gamePaletteSubtitle)
            }
            
            HStack(spacing: 8) {
                ForEach(viewModel.paletteSymbols, id: \.index) { item in
                    paletteButton(symbolIndex: item.index, symbol: item.symbol)
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
            SymbolTokenView(
                symbolIndex: symbolIndex,
                symbolName: symbol,
                showNumbers: viewModel.showNumbers,
                size: DeviceSizing.paletteButtonSize,
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
                    Theme.Colors.undoGradientStart,
                    Theme.Colors.undoGradientEnd
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
                    Theme.Colors.eraseGradientStart,
                    Theme.Colors.eraseGradientEnd
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
                    Theme.Colors.hintGradientStart,
                    Theme.Colors.hintGradientEnd
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
        .onChange(of: viewModel.showCelebration) { _, newValue in
            if newValue {
                hapticManager.trigger(.success)
            }
        }
    }

    private func messageBanner(_ message: KidSudokuMessage) -> some View {
        HStack(spacing: 6) {
            if let symbolImageName = message.symbolImageName {
                Image(symbolImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            Text(message.text)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white)
        }
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

    private var progressRatio: Double {
        let total = Double(viewModel.totalCellCount)
        let filled = Double(viewModel.filledCellCount)
        return min(1.0, max(0.0, filled / total))
    }

    private func computeBoardSize(from proxy: GeometryProxy) -> CGFloat {
        DeviceSizing.computeBoardSize(
            availableWidth: proxy.size.width,
            availableHeight: proxy.size.height,
            bottomSafeArea: proxy.safeAreaInsets.bottom
        )
    }
}

// MARK: - GameTimerView
/// Isolated timer view that only re-renders when time changes,
/// preventing the entire GameView from re-rendering every second.
private struct GameTimerView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        StorybookInfoChip(icon: "clock", text: viewModel.formattedTime)
            .scaleEffect(DeviceSizing.badgeScale)
    }
}

#Preview {
    GameView(config: .sixBySix)
}

