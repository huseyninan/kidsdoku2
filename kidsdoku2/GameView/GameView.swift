import SwiftUI

struct GameView: View {
    let config: KidSudokuConfig
    @StateObject private var viewModel: GameViewModel
    private let hapticManager = HapticManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appEnvironment: AppEnvironment
    
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
            let theme = appEnvironment.currentTheme
            
            ZStack {
                // Background image - uses theme
                Image(theme.backgroundImageName)
                    .resizable(resizingMode: .stretch)
                    .ignoresSafeArea()
                
                // Snowfall effect for Christmas theme
                if theme.showSnowfall {
                    SnowfallView()
                        .ignoresSafeArea()
                }
                
                // Animated running fox at the bottom of the screen (if theme supports it)
                if theme.showRunningFox {
                    VStack {
                        Spacer()
                        RunningFoxView()
                            .frame(height: 200)
                            .allowsHitTesting(false)
                    }
                }
                
                VStack(spacing: 8) {
                    header(theme: theme)
                    
                    boardSection(size: boardSize)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    
                    paletteSection(theme: theme)
                    
                    actionButtons(theme: theme)
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
                        messageBanner(message, theme: theme)
                            .padding(.top, 60)
                        Spacer()
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.message?.text)
                    .allowsHitTesting(false)
                }
            }
            .gameTheme(theme)
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
        .onChange(of: scenePhase) { _, newPhase in
            // Pause timer when app goes to background, resume when active
            switch newPhase {
            case .active:
                if !viewModel.showCelebration {
                    viewModel.startTimer()
                }
            case .inactive, .background:
                viewModel.stopTimer()
            @unknown default:
                break
            }
        }
    }

    private func header(theme: GameTheme) -> some View {
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
                        theme.settingsButtonGradientStart,
                        theme.settingsButtonGradientEnd
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

    private func paletteSection(theme: GameTheme) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(viewModel.currentConfig.symbolGroup.paletteTitle)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(theme.paletteTitleColor)
                Spacer()
                Text(viewModel.showNumbers ? "Tap a number below" : "Tap a friend below")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.paletteSubtitleColor)
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

    private func actionButtons(theme: GameTheme) -> some View {
        HStack(spacing: 12) {
            StorybookActionButton(
                title: String(localized: "Undo"),
                icon: "arrow.uturn.backward",
                isEnabled: viewModel.canUndo,
                gradient: [
                    theme.undoGradientStart,
                    theme.undoGradientEnd
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
                    theme.eraseGradientStart,
                    theme.eraseGradientEnd
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
                    theme.hintGradientStart,
                    theme.hintGradientEnd
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

    private func messageBanner(_ message: KidSudokuMessage, theme: GameTheme) -> some View {
        let accentColor = color(for: message.type, theme: theme)
        
        return HStack(alignment: .center, spacing: 10) {
            if let symbolImageName = message.symbolImageName {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme.messageBannerSymbolBackgroundStart,
                                    theme.messageBannerSymbolBackgroundEnd
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(symbolImageName)
                        .resizable()
                        .scaledToFit()
                        .padding(5)
                }
                .frame(width: 36, height: 36)
                .shadow(color: accentColor.opacity(0.3), radius: 6, x: 0, y: 3)
            }
            Text(message.text)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.messageBannerTextColor)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            theme.messageBannerBackgroundStart,
                            accentColor.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            accentColor.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: accentColor.opacity(0.35), radius: 14, x: 0, y: 8)
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 1)
        .padding(.horizontal, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private func color(for type: KidSudokuMessageType, theme: GameTheme) -> Color {
        switch type {
        case .info:
            return theme.messageInfoColor
        case .success:
            return theme.messageSuccessColor
        case .warning:
            return theme.messageWarningColor
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
        .environmentObject(AppEnvironment())
}
