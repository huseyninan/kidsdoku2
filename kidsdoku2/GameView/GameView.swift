import SwiftUI

struct GameView: View {
    let config: KidSudokuConfig
    @StateObject private var viewModel: GameViewModel
    private let hapticManager = HapticManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appEnvironment: AppEnvironment
    
    @State private var showSettings: Bool = false
    @State private var highlightManager = PaletteHighlightManager()

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
                // Background
                GameBackgroundView(theme: theme)
                
                VStack(spacing: GameConstants.Layout.mainVStackSpacing) {
                    GameHeaderView(
                        navigationTitle: viewModel.navigationTitle,
                        theme: theme,
                        showSettings: $showSettings,
                        progressRatio: progressRatio,
                        formattedTime: viewModel.formattedTime
                    )
                    
                    ZStack(alignment: .top) {
                        GameBoardSection(
                            viewModel: viewModel,
                            boardSize: boardSize,
                            highlightManager: highlightManager
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        
                        // Message banner positioned at top of grid area
                        if let message = viewModel.message {
                            GameMessageBanner(message: message, theme: theme)
                                .padding(.top, GameConstants.Layout.messageBannerTopPadding)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .zIndex(GameConstants.ZIndex.messageBanner)
                        }
                    }
                    
                    GamePaletteSection(
                        viewModel: viewModel,
                        theme: theme,
                        highlightManager: highlightManager
                    )
                    
                    GameActionButtons(
                        viewModel: viewModel,
                        theme: theme
                    )
                }
                .padding(.horizontal, GameConstants.Layout.mainHorizontalPadding)
                .padding(.top, GameConstants.Layout.mainTopPadding)
                .padding(.bottom, max(proxy.safeAreaInsets.bottom, GameConstants.Layout.mainBottomPaddingMin))
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
                
                // Overlays
                if viewModel.showCelebration {
                    CelebrationOverlay(
                        rating: viewModel.calculateStars(),
                        mistakeCount: viewModel.mistakeCount,
                        hintCount: viewModel.hintCount,
                        onDismiss: { dismiss() }
                    )
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
                showNumbers: $viewModel.showNumbers,
                themeType: appEnvironment.currentThemeType
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
            handleScenePhaseChange(newPhase)
        }
    }


    private var progressRatio: Double {
        let total = Double(viewModel.totalCellCount)
        let filled = Double(viewModel.filledCellCount)
        return total > 0 ? min(1.0, max(0.0, filled / total)) : 0
    }

    private func computeBoardSize(from proxy: GeometryProxy) -> CGFloat {
        DeviceSizing.computeBoardSize(
            availableWidth: proxy.size.width,
            availableHeight: proxy.size.height,
            bottomSafeArea: proxy.safeAreaInsets.bottom
        )
    }

    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
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

// MARK: - Subviews

struct GameBackgroundView: View {
    let theme: GameTheme
    
    var body: some View {
        ZStack {
            Image(theme.backgroundImageName)
                .resizable(resizingMode: .stretch)
                .ignoresSafeArea()
            
            if theme.showSnowfall {
                SnowfallView().ignoresSafeArea()
            }
            
            if theme.showRunningFox {
                VStack {
                    Spacer()
                    RunningFoxView()
                        .frame(height: GameConstants.Dimensions.runningFoxHeight)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}

struct GameHeaderView: View {
    let navigationTitle: String
    let theme: GameTheme
    @Binding var showSettings: Bool
    let progressRatio: Double
    let formattedTime: String
    private let hapticManager = HapticManager.shared
    
    var body: some View {
        HStack(spacing: DeviceSizing.headerSpacing) {
            StorybookBadge(text: navigationTitle)
                .scaleEffect(DeviceSizing.badgeScale)
            
            Spacer(minLength: GameConstants.Position.minSpacerLength)
            
            StorybookProgressBar(progress: progressRatio)
                .frame(height: DeviceSizing.progressBarHeight)
                .frame(maxWidth: DeviceSizing.progressBarMaxWidth)
            
            GameTimerView(formattedTime: formattedTime)
            
            Button(action: {
                showSettings = true
                hapticManager.trigger(.selection)
            }) {
                StorybookIconCircle(
                    systemName: "slider.horizontal.3",
                    gradient: [theme.settingsButtonGradientStart, theme.settingsButtonGradientEnd]
                )
                .scaleEffect(DeviceSizing.settingsButtonScale)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, DeviceSizing.headerVerticalPadding)
        .padding(.horizontal, DeviceSizing.headerHorizontalPadding)
        .background(StorybookHeaderCard())
    }
}

struct GameBoardSection: View {
    @ObservedObject var viewModel: GameViewModel
    let boardSize: CGFloat
    let highlightManager: PaletteHighlightManager
    private let hapticManager = HapticManager.shared
    
    var body: some View {
        ZStack {
            StorybookBoardMat(size: boardSize)
            
            BoardGridView(
                config: viewModel.currentConfig,
                cells: viewModel.puzzle.cells,
                selected: viewModel.selectedPosition,
                highlightedValue: viewModel.highlightedValue,
                showNumbers: viewModel.showNumbers,
                completedCellPositions: viewModel.completedCellPositions,
                completedRows: viewModel.completedRows,
                completedColumns: viewModel.completedColumns,
                completedSubgrids: viewModel.completedSubgrids,
                isPuzzleComplete: viewModel.isPuzzleCompleteAnimation,
                onTap: { cell in
                    withAnimation(.easeInOut(duration: GameConstants.Animation.cellTapDuration)) {
                        viewModel.didTapCell(cell)
                        highlightManager.hideHighlight()
                    }
                    hapticManager.trigger(.selection)
                }
            )
            .frame(width: boardSize, height: boardSize)
        }
        .frame(maxWidth: .infinity)
    }
}

struct GamePaletteSection: View {
    @ObservedObject var viewModel: GameViewModel
    let theme: GameTheme
    let highlightManager: PaletteHighlightManager
    
    var body: some View {
        VStack(spacing: GameConstants.Layout.paletteButtonSpacing) {
            HStack {
                Text(viewModel.currentConfig.symbolGroup.paletteTitle)
                    .font(.system(size: GameConstants.Typography.paletteTitleSize, weight: .heavy, design: .rounded))
                    .foregroundStyle(theme.paletteTitleColor)
                Spacer()
                Text(viewModel.showNumbers ? "Tap a number below" : "Tap a friend below")
                    .font(.system(size: GameConstants.Typography.paletteSubtitleSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.paletteSubtitleColor)
            }
            
            ZStack(alignment: .bottom) {
                HStack(spacing: GameConstants.Layout.paletteButtonSpacing) {
                    ForEach(viewModel.paletteSymbols, id: \.index) { item in
                        GamePaletteButton(
                            item: item,
                            isSelected: viewModel.selectedPaletteSymbol == item.index,
                            showNumbers: viewModel.showNumbers,
                            onTap: {
                                withAnimation(.spring(response: GameConstants.Animation.paletteSpringResponse, dampingFraction: GameConstants.Animation.paletteSpringDamping)) {
                                    viewModel.selectPaletteSymbol(item.index)
                                    highlightManager.hideHighlight()
                                }
                            }
                        )
                    }
                }
                
                PaletteHighlightComponent(highlightManager: highlightManager)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, GameConstants.Layout.paletteVerticalPadding)
        .padding(.horizontal, GameConstants.Layout.paletteHorizontalPadding)
        .background(StorybookPaletteMat())
    }
}

struct GamePaletteButton: View {
    let item: (index: Int, symbol: String)
    let isSelected: Bool
    let showNumbers: Bool
    let onTap: () -> Void
    private let hapticManager = HapticManager.shared
    
    var body: some View {
        Button {
            onTap()
            hapticManager.trigger(.selection)
        } label: {
            SymbolTokenView(
                symbolIndex: item.index,
                symbolName: item.symbol,
                showNumbers: showNumbers,
                size: DeviceSizing.paletteButtonSize,
                context: .palette,
                isSelected: isSelected
            )
            .shadow(color: Color.black.opacity(GameConstants.Shadow.paletteButtonOpacity), radius: GameConstants.Shadow.paletteButtonRadius, x: GameConstants.Shadow.paletteButtonOffset.width, y: GameConstants.Shadow.paletteButtonOffset.height)
            .scaleEffect(isSelected ? GameConstants.Scale.paletteButtonSelected : GameConstants.Scale.paletteButtonNormal)
        }
        .buttonStyle(.plain)
    }
}

struct PaletteHighlightTip: View {
    var body: some View {
        VStack(spacing: GameConstants.Padding.paletteItemSpacing) {
            Text("Start here!")
                .font(.system(size: GameConstants.Typography.highlightTipSize, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, GameConstants.Padding.highlightTipHorizontal)
                .padding(.vertical, GameConstants.Padding.highlightTipVertical)
                .background(
                    Capsule()
                        .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                        .shadow(color: .blue.opacity(GameConstants.Shadow.highlightTipOpacity), radius: GameConstants.Shadow.highlightTipRadius, x: GameConstants.Shadow.highlightTipOffset.width, y: GameConstants.Shadow.highlightTipOffset.height)
                )
            
            Image(systemName: "arrow.down")
                .font(.system(size: GameConstants.Typography.highlightArrowSize, weight: .bold))
                .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom))
                .shadow(color: .blue.opacity(GameConstants.Opacity.blueHighlight), radius: GameConstants.Shadow.highlightArrowRadius, x: GameConstants.Shadow.highlightArrowOffset.width, y: GameConstants.Shadow.highlightArrowOffset.height)
        }
        .offset(y: GameConstants.Position.highlightTipOffset)
    }
}

struct GameActionButtons: View {
    @ObservedObject var viewModel: GameViewModel
    let theme: GameTheme
    private let hapticManager = HapticManager.shared
    
    var body: some View {
        HStack(spacing: GameConstants.Layout.actionButtonSpacing) {
            StorybookActionButton(
                title: String(localized: "Undo"),
                icon: "arrow.uturn.backward",
                isEnabled: viewModel.canUndo,
                gradient: [theme.undoGradientStart, theme.undoGradientEnd],
                action: {
                    withAnimation(.easeInOut(duration: GameConstants.Animation.actionButtonDuration)) { viewModel.undo() }
                    hapticManager.trigger(.light)
                }
            )
            
            StorybookActionButton(
                title: String(localized: "Erase"),
                icon: "xmark.circle",
                isEnabled: true,
                gradient: [theme.eraseGradientStart, theme.eraseGradientEnd],
                action: {
                    withAnimation(.easeInOut(duration: GameConstants.Animation.actionButtonDuration)) { viewModel.removeValue() }
                    hapticManager.trigger(.light)
                }
            )
            
            StorybookActionButton(
                title: String(localized: "Hint"),
                icon: "lightbulb",
                isEnabled: true,
                gradient: [theme.hintGradientStart, theme.hintGradientEnd],
                action: {
                    withAnimation(.easeInOut(duration: GameConstants.Animation.actionButtonDuration)) { viewModel.provideHint() }
                    hapticManager.trigger(.medium)
                }
            )
        }
        .disabled(viewModel.showCelebration)
        .onChange(of: viewModel.showCelebration) { _, newValue in
            if newValue { hapticManager.trigger(.success) }
        }
    }
}

struct GameMessageBanner: View {
    let message: KidSudokuMessage
    let theme: GameTheme
    
    var body: some View {
        let accentColor = color(for: message.type, theme: theme)
        
        HStack(alignment: .center, spacing: GameConstants.Layout.actionButtonSpacing) {
            if let symbolImageName = message.symbolImageName {
                ZStack {
                    RoundedRectangle(cornerRadius: GameConstants.Dimensions.messageBannerSymbolCornerRadius, style: .continuous)
                        .fill(LinearGradient(colors: [theme.messageBannerSymbolBackgroundStart, theme.messageBannerSymbolBackgroundEnd], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Image(symbolImageName)
                        .resizable()
                        .scaledToFit()
                        .padding(GameConstants.Dimensions.messageBannerSymbolPadding)
                }
                .frame(width: GameConstants.Dimensions.messageBannerIconSize, height: GameConstants.Dimensions.messageBannerIconSize)
                .shadow(color: accentColor.opacity(0.3), radius: 6, x: 0, y: 3)
            }
            Text(message.text)
                .font(.system(size: GameConstants.Typography.messageBannerTextSize, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.messageBannerTextColor)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, GameConstants.Padding.messageBannerHorizontal)
        .padding(.vertical, GameConstants.Padding.messageBannerVertical)
        .background(
            RoundedRectangle(cornerRadius: GameConstants.Dimensions.messageBannerCornerRadius, style: .continuous)
                .fill(LinearGradient(colors: [theme.messageBannerBackgroundStart, accentColor.opacity(GameConstants.Opacity.messageBannerAccent)], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: GameConstants.Dimensions.messageBannerCornerRadius, style: .continuous)
                .stroke(LinearGradient(colors: [.white.opacity(GameConstants.Opacity.messageBannerBorder), accentColor.opacity(GameConstants.Opacity.messageBannerBorderAccent)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: GameConstants.Dimensions.messageBannerStrokeWidth)
        )
        .shadow(color: accentColor.opacity(GameConstants.Opacity.messageBannerMainShadow), radius: GameConstants.Shadow.messageBannerMainRadius, x: GameConstants.Shadow.messageBannerMainOffset.width, y: GameConstants.Shadow.messageBannerMainOffset.height)
        .shadow(color: Color.black.opacity(GameConstants.Opacity.messageBannerAccent), radius: GameConstants.Shadow.messageBannerSecondaryRadius, x: GameConstants.Shadow.messageBannerSecondaryOffset.width, y: GameConstants.Shadow.messageBannerSecondaryOffset.height)
        .padding(.horizontal, GameConstants.Layout.messageBannerHorizontalPadding)
    }
    
    private func color(for type: KidSudokuMessageType, theme: GameTheme) -> Color {
        switch type {
        case .info: return theme.messageInfoColor
        case .success: return theme.messageSuccessColor
        case .warning: return theme.messageWarningColor
        }
    }
}

// MARK: - GameTimerView
/// Isolated timer view that only re-renders when time changes,
/// preventing the entire GameView from re-rendering every second.
private struct GameTimerView: View {
    let formattedTime: String
    
    var body: some View {
        StorybookInfoChip(icon: "clock", text: formattedTime)
            .scaleEffect(DeviceSizing.badgeScale)
    }
}

#Preview {
    GameView(config: .sixBySix)
        .environmentObject(AppEnvironment())
}
