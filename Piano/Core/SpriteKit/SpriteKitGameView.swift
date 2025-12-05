import SwiftUI
import SpriteKit

/// SpriteKit游戏视图的SwiftUI包装器
struct SpriteKitGameView: UIViewRepresentable {
    let scene: GameScene
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        
        // 配置 SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.backgroundColor = .clear
        
        // 禁用不必要的焦点系统（修复卡死问题）
        skView.allowsTransparency = true
        
        // 延迟呈现场景，避免初始化问题
        DispatchQueue.main.async {
            skView.presentScene(scene)
        }
        
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // 更新逻辑（如需要）
    }
}

/// 使用SpriteKit的游戏主视图
struct SpriteKitGamePlayView: View {
    @StateObject private var gameState = GameStateManager.shared
    @StateObject private var viewModel: SpriteKitGameViewModel
    @ObservedObject var audioManager: AudioManager
    @ObservedObject private var themeManager = ThemeManager.shared
    
    let song: Song
    let mode: GameMode
    let onExit: () -> Void
    
    @State private var showPauseMenu = false
    @State private var gameScene: GameScene?
    @State private var assistMode = false  // 辅助模式开关
    @State private var highlightedKeys: Set<Int> = []  // 当前应该高亮的按键
    @State private var pianoKeysHeight: CGFloat = 0  // 琴键区域动态高度
    
    // 缓存的主题颜色 - 避免游戏期间颜色变化
    @State private var cachedThemeColors: ThemeColors?
    
    init(song: Song, mode: GameMode, audioManager: AudioManager, onExit: @escaping () -> Void) {
        self.song = song
        self.mode = mode
        self.audioManager = audioManager
        self.onExit = onExit
        
        _viewModel = StateObject(wrappedValue: SpriteKitGameViewModel(song: song, mode: mode))
    }
    
    private func setupGameCompletionCallback() {
        // 设置游戏完成回调
        viewModel.onGameCompleted = {
            print("🎯 游戏完成回调触发 - 准备退出到记分页面")
            self.stopGame()
            self.onExit()
        }
    }
    
    var body: some View {
        ZStack {
            // 背景层
            backgroundLayer
            
            // SpriteKit游戏场景
            GeometryReader { geometry in
                ZStack {
                    if let scene = gameScene {
                        SpriteKitGameView(scene: scene)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .allowsHitTesting(true)
                    } else {
                        Color.clear
                    }
                }
                .onAppear {
                    // 确保几何尺寸有效
                    if geometry.size.width > 0 && geometry.size.height > 0 {
                        setupGameScene(size: geometry.size)
                    }
                }
            }
            
            // HUD层
            VStack {
                hudTopBar
                Spacer()
                hudBottomBar
            }
            .padding()
            
            // 底部琴键按钮层
            VStack {
                Spacer()
                pianoKeysBar
            }
            
            // 判定反馈 - 移动到屏幕正中间
            if let judgement = viewModel.lastJudgement {
                judgementFeedbackView(judgement)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(100)
            }
            
            // Fever特效覆盖层
            if viewModel.feverMode.isActive {
                feverOverlayView
            }
            
            // 暂停菜单
            if showPauseMenu {
                pauseMenuView
            }
        }
        .onAppear {
            print("📱 SpriteKitGamePlayView 出现")
            themeManager.enterGameMode()
            
            // 缓存当前主题颜色
            cachedThemeColors = themeManager.colors
            
            // 设置游戏完成回调
            setupGameCompletionCallback()
            
            // 延迟启动游戏，确保场景已初始化
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                startGame()
            }
        }
        .onDisappear {
            stopGame()
            themeManager.exitGameMode()
        }
    }
    
    // MARK: - 背景层
    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: cachedThemeColors?.gradient.map { $0.opacity(0.35) } ?? themeManager.backgroundGradient(isDark: true),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        }
    }
    
    // MARK: - HUD顶部
    private var hudTopBar: some View {
        HStack {
            HStack(spacing: 12) {
                // 暂停按钮
                Button(action: togglePause) {
                    Image(systemName: showPauseMenu ? "play.fill" : "pause.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                
                // 辅助模式开关
                Button(action: { assistMode.toggle() }) {
                    Image(systemName: assistMode ? "lightbulb.fill" : "lightbulb")
                        .font(.title2)
                        .foregroundColor(assistMode ? .yellow : .white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            
            Spacer()
            
            // 分数显示
            VStack(alignment: .trailing, spacing: 4) {
                Text("SCORE")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Text("\(gameState.currentScore)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - HUD底部
    private var hudBottomBar: some View {
        VStack(spacing: 12) {
            // Fever能量条
            feverEnergyBar
            
            // 连击显示
            if gameState.currentCombo > 0 {
                HStack(spacing: 8) {
                    Text("COMBO")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(gameState.currentCombo)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    // MARK: - 琴键按钮栏（双层布局）
    private var pianoKeysBar: some View {
        GeometryReader { outerGeometry in
            let keyWidth = outerGeometry.size.width / 7.0
            let keyHeight = keyWidth  // 1:1 宽高比
            let totalHeight = keyHeight * 2 + 8  // 两排琴键 + 光效条高度
            
            VStack(spacing: 0) {
                // 装饰性律动光效层
                rhythmicLightBar
                
                // 琴键区域
                HStack(spacing: 0) { // 移除固定间距，改为0让琴键紧贴
                    ForEach(0..<7, id: \.self) { index in
                        dualLayerPianoKey(baseIndex: index, keyWidth: keyWidth)
                    }
                }
                .frame(height: keyHeight * 2)  // 动态计算高度：两排琴键，1:1宽高比
                .background(.ultraThinMaterial)
            }
            .frame(height: totalHeight, alignment: .bottom)  // 固定总高度并底部对齐
            .onAppear {
                // 首次计算并保存琴键区域高度
                if pianoKeysHeight == 0 {
                    pianoKeysHeight = totalHeight
                }
            }
            .onChange(of: outerGeometry.size.width) { oldValue, newValue in
                // 屏幕宽度变化时重新计算高度
                let newKeyWidth = newValue / 7.0
                pianoKeysHeight = newKeyWidth * 2 + 8
            }
        }
        .frame(height: pianoKeysHeight > 0 ? pianoKeysHeight : 150)  // 使用动态计算的高度，初始值150
    }
    
    // MARK: - 律动光效条
    private var rhythmicLightBar: some View {
        GeometryReader { geometry in
            ZStack {
                // 渐变背景
                LinearGradient(
                    colors: [
                        .orange.opacity(0.3),
                        .yellow.opacity(0.5),
                        .orange.opacity(0.3)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                
                // 动态光效（根据连击数变化）
                if gameState.currentCombo > 0 {
                    LinearGradient(
                        colors: [
                            .yellow.opacity(0.8),
                            .orange.opacity(0.8),
                            .red.opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .opacity(min(Double(gameState.currentCombo) / 50.0, 1.0))
                }
                
                // Fever模式特效
                if viewModel.feverMode.isActive {
                    LinearGradient(
                        colors: [
                            .yellow,
                            .orange,
                            .red,
                            .orange,
                            .yellow
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .opacity(0.9)
                }
            }
        }
        .frame(height: 8)
    }
    
    private func dualLayerPianoKey(baseIndex: Int, keyWidth: CGFloat) -> some View {
        let normalIndex = baseIndex  // 0-6 对应正常音 1234567
        let highIndex = baseIndex + 8  // 8-14 对应高音 1̇2̇3̇4̇5̇6̇7̇
        
        let notations = ["1", "2", "3", "4", "5", "6", "7"]
        
        // 彩虹色系：红、橙、黄、绿、青、蓝、紫
        let rainbowColors: [Color] = [
            .red, .orange, .yellow, .green,
            .cyan, .blue, .purple
        ]
        
        let baseColor = rainbowColors[baseIndex]
        
        return VStack(spacing: 0) {
            // 上半部分：中音区 - 正常亮度的彩虹色
            Button(action: {
                triggerNoteAtTrack(normalIndex)
            }) {
                ZStack {
                    // 2D琴键主体 - 2:1高宽比
                    RoundedRectangle(cornerRadius: 8)
                        .fill(baseColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(baseColor.opacity(0.8), lineWidth: 2)
                        )
                        .shadow(color: baseColor.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    // 辅助高亮效果
                    if assistMode && highlightedKeys.contains(normalIndex) {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 3)
                            .blur(radius: 2)
                    }
                    
                    // 数字标记
                    Text(notations[baseIndex])
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                }
                .frame(width: keyWidth, height: keyWidth) // 1:1 宽高比
            }
            .buttonStyle(.plain)
            
            // 下半部分：高音区 - 使用同色系但更深的颜色来区分
            Button(action: {
                triggerNoteAtTrack(highIndex)
            }) {
                ZStack {
                    // 2D琴键主体 - 使用同色系但更深的颜色
                    RoundedRectangle(cornerRadius: 8)
                        .fill(getHighKeyColor(from: baseColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(getHighKeyBorder(from: baseColor), lineWidth: 2)
                        )
                        .shadow(color: getHighKeyShadow(from: baseColor), radius: 4, x: 0, y: 2)
                    
                    // 辅助高亮效果
                    if assistMode && highlightedKeys.contains(highIndex) {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.7), lineWidth: 3)
                            .blur(radius: 2)
                    }
                    
                    // 高音标记（点在数字上方）
                    VStack(spacing: 0) {
                        Text("˙")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                        Text(notations[baseIndex])
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                }
                .frame(width: keyWidth, height: keyWidth) // 1:1 宽高比
            }
            .buttonStyle(.plain)
        }
    }
    
    // 根据基础颜色获取高音区琴键颜色 - 使用同色系但更深的颜色
    private func getHighKeyColor(from baseColor: Color) -> Color {
        switch baseColor {
        case .red:
            return .red.opacity(0.8) // 深红色
        case .orange:
            return .orange.opacity(0.85) // 深橙色
        case .yellow:
            return .yellow.opacity(0.7) // 深黄色
        case .green:
            return .green.opacity(0.8) // 深绿色
        case .cyan:
            return .cyan.opacity(0.8) // 深青色
        case .blue:
            return .blue.opacity(0.85) // 深蓝色
        case .purple:
            return .purple.opacity(0.8) // 深紫色
        default:
            return baseColor.opacity(0.7)
        }
    }
    
    // 获取高音区琴键边框颜色
    private func getHighKeyBorder(from baseColor: Color) -> Color {
        return getHighKeyColor(from: baseColor).opacity(0.8)
    }
    
    // 获取高音区琴键阴影颜色
    private func getHighKeyShadow(from baseColor: Color) -> Color {
        return getHighKeyColor(from: baseColor).opacity(0.3)
    }
    
    // 触发指定轨道的音符判定
    private func triggerNoteAtTrack(_ trackIndex: Int) {
        // 模拟在该轨道上的触摸
        guard let scene = gameScene else { return }
        
        let trackWidth = scene.size.width / CGFloat(16)
        let xPosition = trackWidth * CGFloat(trackIndex) + trackWidth / 2
        
        // 创建一个模拟触摸位置（用于未来可能的扩展）
        let _ = CGPoint(x: xPosition, y: 100)
        
        // 直接调用场景的击中逻辑
        scene.simulateTouch(at: trackIndex)
    }
    
    // MARK: - Fever能量条
    private var feverEnergyBar: some View {
        VStack(spacing: 4) {
            HStack {
                Text("FEVER")
                    .font(.caption2)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(viewModel.feverMode.energyPercentage * 100))%")
                    .font(.caption2)
                    .foregroundColor(.yellow)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // 背景
                    Capsule()
                        .fill(.white.opacity(0.2))
                    
                    // 能量条
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * viewModel.feverMode.energyPercentage)
                    
                    // 满能量光效
                    if viewModel.feverMode.energyPercentage >= 1.0 {
                        Capsule()
                            .stroke(Color.yellow, lineWidth: 2)
                            .blur(radius: 4)
                    }
                }
            }
            .frame(height: 12)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - 判定反馈
    private func judgementFeedbackView(_ judgement: JudgementResult) -> some View {
        VStack(spacing: 8) {
            Text(judgement.displayText)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(judgement.color)
                .shadow(color: judgement.color, radius: 18, x: 3, y: 3)  // 加深加宽阴影
            
            if gameState.currentCombo > 5 {
                Text("\(gameState.currentCombo) COMBO!")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 12, x: 2, y: 2)  // 加深加宽阴影
            }
        }
    }
    
    // MARK: - Fever覆盖层
    private var feverOverlayView: some View {
        VStack {
            // Fever文字 - 移动到距离状态栏1/3的位置
            VStack {
                Text("FEVER TIME!")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundColor(.yellow)
                    .shadow(color: .orange, radius: 15, x: 2, y: 2)  // 加深加宽阴影
                
                Text(String(format: "%.1fs", viewModel.feverMode.remainingTime))
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 12, x: 1.5, y: 1.5)  // 加深加宽阴影
            }
            .padding(.top, 60)  // 距离状态栏1/3位置的padding
            
            Spacer()
        }
        .background(
            // 边框光效 - 只围绕文字区域
            Rectangle()
                .strokeBorder(
                    LinearGradient(
                        colors: [.yellow, .orange, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )
                .blur(radius: 8)
        )
        .allowsHitTesting(false)
    }
    
    // MARK: - 暂停菜单
    private var pauseMenuView: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("game.pause.title".localized)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    Button(action: togglePause) {
                        Label("game.pause.resume".localized, systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        stopGame()
                        onExit()
                    }) {
                        Label("game.pause.exit".localized, systemImage: "xmark")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
    
    // MARK: - 游戏控制
    private func setupGameScene(size: CGSize) {
        print("🎬 设置游戏场景 - 尺寸: \(size)")
        
        let scene = GameScene(size: size)
        scene.scaleMode = .aspectFill
        
        // 设置回调
        scene.onNoteHit = { [weak viewModel] noteId, judgement in
            viewModel?.handleNoteHit(judgement)
        }
        
        scene.onNoteMiss = { [weak viewModel] noteId in
            viewModel?.handleNoteMiss()
        }
        
        scene.onTimeUpdate = { [weak viewModel] time in
            viewModel?.updateTime(time)
            // 注意：这里不能使用 weak self，因为 View 是 struct
            // 辅助高亮在主视图中通过 @State 更新
        }
        
        self.gameScene = scene
        print("✅ 游戏场景设置完成")
    }
    
    private func startGame() {
        guard let scene = gameScene else {
            print("❌ 错误：游戏场景未初始化")
            return
        }
        
        print("🎮 开始游戏 - 歌曲: \(song.name), 模式: \(mode.rawValue)")
        
        viewModel.startGame()
        print("📝 音符数量: \(viewModel.fallingNotes.count)")
        
        scene.startGame(notes: viewModel.fallingNotes, mode: mode)
        
        // 启动音频 - 使用正确的方法签名
        audioManager.playSong(
            song,
            notes: Note.allNotes,
            onNotePlay: { _ in },
            onComplete: {
                // 音频播放完成，通知ViewModel
                viewModel.onAudioPlaybackComplete()
            }
        )
        
        print("✅ SpriteKit游戏启动完成")
        
        // 启动辅助高亮更新定时器
        startAssistHighlightTimer()
    }
    
    private func startAssistHighlightTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak viewModel] timer in
            guard let vm = viewModel, vm.isPlaying && !vm.isPaused else {
                timer.invalidate()
                return
            }
            updateAssistHighlight()
        }
    }
    
    private func togglePause() {
        showPauseMenu.toggle()
        
        if showPauseMenu {
            gameScene?.pauseGame()
            audioManager.stopSong()
            viewModel.pauseGame()
        } else {
            gameScene?.resumeGame()
            // 恢复时重新启动音频
            audioManager.playSong(
                song,
                notes: Note.allNotes,
                onNotePlay: { _ in },
                onComplete: { }
            )
            viewModel.resumeGame()
        }
    }
    
    private func stopGame() {
        gameScene?.stopGame()
        audioManager.stopSong()
        viewModel.stopGame()
    }
    
    // MARK: - 辅助模式高亮更新
    private func updateAssistHighlight() {
        guard assistMode else {
            if !highlightedKeys.isEmpty {
                highlightedKeys.removeAll()
            }
            return
        }
        
        // 查找即将到达判定线的音符（提前0.3秒高亮）
        let currentTime = viewModel.currentTime
        let highlightWindow = 0.3  // 提前0.3秒开始高亮
        
        var newHighlightedKeys: Set<Int> = []
        
        for note in viewModel.fallingNotes {
            guard !note.isHit else { continue }
            
            let timeUntilHit = note.targetTime - currentTime
            
            // 如果音符即将到达判定线（0到0.3秒之间）
            if timeUntilHit >= 0 && timeUntilHit <= highlightWindow {
                newHighlightedKeys.insert(note.noteIndex)
            }
        }
        
        // 只有变化时才更新
        if newHighlightedKeys != highlightedKeys {
            highlightedKeys = newHighlightedKeys
        }
    }
}

// MARK: - 预览
#Preview {
    SpriteKitGamePlayView(
        song: Song.twinkleTwinkleLittleStar,
        mode: .normal,
        audioManager: AudioManager(),
        onExit: {}
    )
}