import SwiftUI

/// 重构后的主视图 - 清晰的架构
struct PianoMainView: View {
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var appState = AppState.shared
    @StateObject private var themeManager = ThemeManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        GeometryReader { outerGeometry in
            ZStack {
                // 背景层 - 填满整个屏幕
                backgroundLayer
                
                // 主内容层 - 仅 iPad 锁定宽高比
                if UIDevice.current.userInterfaceIdiom == .pad {
                    // iPad: 锁定设备原生宽高比
                    mainContentLayer
                        .aspectRatio(nativeAspectRatio, contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // iPhone: 保持全屏显示
                    mainContentLayer
                }
                
                // 模态弹窗层
                modalLayer
            }
        }
        .preferredColorScheme(.none) // 使用系统自动模式
    }
    
    /// 获取当前设备的原生屏幕宽高比（竖屏状态下的比例）
    private var nativeAspectRatio: CGFloat {
        let screen = UIScreen.main.bounds
        let width = min(screen.width, screen.height)  // 竖屏时的宽度
        let height = max(screen.width, screen.height) // 竖屏时的高度
        return width / height
    }
    
    // MARK: - 背景层
    private var backgroundLayer: some View {
        ZStack {
            // 基础渐变背景
            LinearGradient(
                colors: themeManager.backgroundGradient(),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // 动态背景光效
            // TODO: OptimizedBackgroundView 组件待实现
            // if appState.performanceMode.enableDynamicBackground {
            //     OptimizedBackgroundView(noteIndex: appState.currentlyPlayingKey)
            //         .ignoresSafeArea()
            //         .allowsHitTesting(false)
            // }
        }
    }
    
    // MARK: - 主内容层
    private var mainContentLayer: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 1. 顶部标题
                HeaderView(
                    currentSong: appState.currentSong,
                    audioManager: audioManager
                )
                .padding(.top, geometry.safeAreaInsets.top + 8)
                
                // 2. 上方灵活间隔
                Spacer()
                
                // 3. 正在播放信息
                if let song = appState.currentSong {
                    Text("main.playing".localized(with: song.name))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(themeManager.colors.secondary.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .transition(.scale.combined(with: .opacity))
                    
                    Spacer().frame(height: 16)
                }

                // 4. 波形图和烟花特效区域
                ZStack {
                    CompactVisualizerView(audioManager: audioManager)
                        .opacity(0.7)
                        .blur(radius: 0.5)

                    // TODO: OptimizedParticleView 组件待实现
                    // if appState.performanceMode.enableParticles {
                    //     OptimizedParticleView(
                    //         noteIndex: appState.currentlyPlayingKey,
                    //         particleCount: appState.performanceMode.particleCount
                    //     )
                    // }
                }
                .frame(height: 60)
                .allowsHitTesting(false)
                
                Spacer().frame(height: 20)

                // 5. 乐谱（播放时显示）
                if let song = appState.currentSong, appState.isPlayingSong {
                    CompactSheetMusicView(
                        song: song,
                        currentNoteIndex: appState.currentNoteIndex
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                    Spacer().frame(height: 16)
                }
                
                // 6. 键盘
                PianoKeyboardView(
                    playingIndex: appState.currentlyPlayingKey,
                    showNotation: appState.showNotation,
                    onKeyPress: { index in
                        playNote(at: index)
                    }
                )
                
                // 7. 下方灵活间隔
                Spacer()
                
                // 8. 控制面板
                ControlPanel(
                    audioManager: audioManager,
                    appState: appState
                )
                .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 12)
            }
            .padding(.horizontal, adaptiveHorizontalPadding(for: geometry.size))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    /// 根据屏幕宽度返回自适应水平边距
    private func adaptiveHorizontalPadding(for size: CGSize) -> CGFloat {
        if size.width <= 375 {
            return 8   // iPhone 13 mini, iPhone SE - 最小边距
        } else if size.width < 400 {
            return 12  // 标准 iPhone
        } else if size.width < 600 {
            return 16  // iPhone Pro Max
        } else {
            return 24  // iPad
        }
    }
    
    // MARK: - 模态弹窗层
    private var modalLayer: some View {
        ZStack {
            if let modal = appState.activeModal {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            appState.dismissModal()
                        }
                    }
                    .transition(.opacity)
                
                modalContent(for: modal)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.activeModal)
    }
    
    @ViewBuilder
    private func modalContent(for modal: AppState.ModalType) -> some View {
        switch modal {
        case .songMenu:
            SongSelectionPanel(
                songs: Song.allSongs,
                onSongSelected: { song in
                    playSong(song)
                    appState.dismissModal()
                },
                onCancel: {
                    appState.dismissModal()
                }
            )
            
        case .volumeControl:
            VolumeControlPanel(
                audioManager: audioManager,
                isPresented: Binding(
                    get: { appState.activeModal == .volumeControl },
                    set: { if !$0 { appState.dismissModal() } }
                )
            )
            
        case .skinSettings:
            OptimizedSkinSettingsView(
                isPresented: Binding(
                    get: { appState.activeModal == .skinSettings },
                    set: { if !$0 { appState.dismissModal() } }
                )
            )
            
        case .effectControl:
            EffectControlPanel(audioManager: audioManager) {
                appState.dismissModal()
            }
            
        case .about:
            AboutView(
                isPresented: Binding(
                    get: { appState.activeModal == .about },
                    set: { if !$0 { appState.dismissModal() } }
                )
            )
            
        case .languageSettings:
            LanguageSettingsView(
                isPresented: Binding(
                    get: { appState.activeModal == .languageSettings },
                    set: { if !$0 { appState.dismissModal() } }
                )
            )
            
        case .game:
            GameMainView(
                audioManager: audioManager,
                onExit: {
                    appState.dismissModal()
                }
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    // MARK: - 交互逻辑
    
    private func playNote(at index: Int) {
        appState.playNote(at: index)
        audioManager.playNote(Note.allNotes[index])
    }
    
    private func playSong(_ song: Song) {
        appState.playSong(song)
        
        // 使用高精度音频调度器播放歌曲
        audioManager.playSong(
            song,
            notes: Note.allNotes,
            onNotePlay: { [appState] index in
                guard appState.isPlayingSong, appState.currentSong?.id == song.id else { return }
                
                // 更新当前音符索引
                appState.currentNoteIndex = index
                
                // 更新当前播放的琴键索引
                let noteIndex = song.notes[index]
                appState.currentlyPlayingKey = noteIndex
                
                // 短暂延迟后清除高亮
                DispatchQueue.main.asyncAfter(deadline: .now() + song.durations[index] * 0.8) {
                    if appState.currentlyPlayingKey == noteIndex {
                        appState.currentlyPlayingKey = nil
                    }
                }
            },
            onComplete: { [appState] in
                if appState.currentSong?.id == song.id {
                    // 播放完成后重置到初始状态
                    appState.stopAll()
                }
            }
        )
    }
}

// MARK: - 子组件

/// 标题视图 - 可点击进入关于页面
struct HeaderView: View {
    let currentSong: Song?
    let audioManager: AudioManager
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var appState = AppState.shared
    @State private var isPressed = false
    
    var body: some View {
        Button {
            // 触觉反馈
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            // 重置播放状态（如果正在播放歌曲）
            if appState.isPlayingSong {
                appState.stopAll()
                audioManager.stopAll()
            }
            
            // 显示关于页面
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appState.showModal(.about)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "music.note")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(themeManager.colors.primary)
                
                Text("app.name".localized)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                // 小巧的信息图标提示
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(4)
                    .background(
                        Circle()
                            .fill(themeManager.colors.primary.opacity(0.3))
                    )
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(themeManager.colors.primary.opacity(isPressed ? 0.5 : 0.3), lineWidth: 1.5)
                    )
            )
            .shadow(color: themeManager.colors.primary.opacity(0.2), radius: 8, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

/// 琴键盘视图 - 响应式布局
struct PianoKeyboardView: View {
    let playingIndex: Int?
    let showNotation: Bool
    let onKeyPress: (Int) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: adaptiveSpacing(for: geometry.size)) {
                // 低音区
                PianoKeyRow(
                    notes: Array(Note.allNotes[0..<8]),
                    playingIndex: playingIndex,
                    showNotation: showNotation,
                    onKeyPress: onKeyPress
                )
                
                // 高音区
                PianoKeyRow(
                    notes: Array(Note.allNotes[8..<16]),
                    playingIndex: playingIndex.map { $0 - 8 },
                    showNotation: showNotation,
                    onKeyPress: { index in onKeyPress(index + 8) }
                )
            }
            .padding(adaptivePadding(for: geometry.size))
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                    )
            )
        }
        .frame(height: 180)
    }
    
    private func adaptiveSpacing(for size: CGSize) -> CGFloat {
        size.width <= 375 ? 8 : 12
    }
    
    private func adaptivePadding(for size: CGSize) -> CGFloat {
        size.width <= 375 ? 10 : 16
    }
}

/// 紧凑型可视化器
struct CompactVisualizerView: View {
    @ObservedObject var audioManager: AudioManager
    @State private var levels: [CGFloat] = Array(repeating: 0.1, count: 24)
    @State private var timer: Timer?
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<24, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(barColor(for: levels[index]))
                    .frame(width: 5, height: max(4, levels[index] * 60))
            }
        }
        .frame(height: 60)
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
                updateLevels()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func updateLevels() {
        withAnimation(.easeInOut(duration: 0.08)) {
            for i in 0..<24 {
                if audioManager.hasActivePlayers {
                    levels[i] = CGFloat.random(in: 0.2...0.9)
                } else {
                    levels[i] = max(0.1, levels[i] - 0.1)
                }
            }
        }
    }
    
    private func barColor(for level: CGFloat) -> Color {
        if level < 0.3 { return .blue.opacity(0.6) }
        else if level < 0.6 { return .purple.opacity(0.7) }
        else { return .pink.opacity(0.9) }
    }
}

/// 紧凑型乐谱视图
struct CompactSheetMusicView: View {
    let song: Song
    let currentNoteIndex: Int?
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(song.notes.enumerated()), id: \.offset) { index, noteIndex in
                        CompactNoteView(
                            note: Note.allNotes[noteIndex],
                            isPlaying: currentNoteIndex == index
                        )
                        .id(index)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.purple.opacity(0.3), lineWidth: 1.5)
                    )
            )
            .onChange(of: currentNoteIndex) { _, newValue in
                if let newValue = newValue {
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
    }
}

struct CompactNoteView: View {
    let note: Note
    let isPlaying: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text("♪")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(isPlaying ? .yellow : note.color)
            
            Text(note.name)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(width: 40)
        .scaleEffect(isPlaying ? 1.2 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPlaying)
    }
}
