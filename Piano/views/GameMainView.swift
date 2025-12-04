import SwiftUI

/// 游戏主入口视图 - 完全独立的全屏游戏模块
struct GameMainView: View {
    @StateObject private var gameState = GameStateManager.shared
    @ObservedObject var audioManager: AudioManager
    @ObservedObject private var localization = LocalizationManager.shared
    
    @State private var currentView: GameViewState = .menu
    @State private var showEditor = false
    @State private var showLeaderboard = false
    @State private var selectedSong: Song?
    @State private var selectedMode: GameMode = .normal
    @State private var lastRecord: GameRecord?
    
    let onExit: () -> Void
    
    // 视图状态枚举
    enum GameViewState {
        case menu
        case modeSelection
        case playing
        case result
    }
    
    var body: some View {
        ZStack {
            // 强制黑色背景作为最底层，覆盖所有可能的父视图背景
            Color.black
                .ignoresSafeArea()
                .zIndex(-1)
            
            // 内容层
            Group {
                switch currentView {
                case .menu:
                    mainMenuView
                        .transition(.opacity)
                    
                case .modeSelection:
                    if let song = selectedSong {
                        modeSelectionView(song: song)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                case .playing:
                    if let song = selectedSong {
                        // 使用SpriteKit + SwiftUI架构，包含倒计时
                        CountdownGameView(
                            song: song,
                            mode: selectedMode,
                            audioManager: audioManager,
                            onExit: {
                                handleGameExit()
                            }
                        )
                        .transition(.opacity)
                    }
                    
                case .result:
                    if let record = lastRecord {
                        GameResultView(
                            record: record,
                            onRestart: {
                                restartGame()
                            },
                            onExit: {
                                withAnimation {
                                    currentView = .menu
                                    lastRecord = nil
                                }
                            }
                        )
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentView)
        .sheet(isPresented: $showEditor) {
            SheetMusicEditorView()
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView()
        }
    }
    
    // MARK: - 主菜单视图
    private var mainMenuView: some View {
        ZStack {
            // 主题配色背景层 - 使用磨砂玻璃效果
            ZStack {
                // 底层渐变色
                LinearGradient(
                    colors: ThemeManager.shared.backgroundGradient(isDark: true),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 磨砂玻璃效果层
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
            }
            
            // 内容
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 40)
                    
                    // 标题区域
                    titleSection
                    
                    // 快速统计
                    quickStatsSection
                    
                    // 歌曲选择
                    songSelectionSection
                    
                    // 功能按钮
                    featureButtonsSection
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
            
            // 返回按钮
            VStack {
                HStack {
                    Button(action: onExit) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(radius: 5)
                    }
                    Spacer()
                }
                .padding()
                Spacer()
            }
        }
    }
    
    // MARK: - 标题区域
    private var titleSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 60, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .cyan.opacity(0.5), radius: 20)
            
            Text(localization.localized("game.title"))
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            
            Text(localization.localized("game.subtitle"))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
    
    // MARK: - 快速统计区域
    private var quickStatsSection: some View {
        HStack(spacing: 12) {
            statBox(
                icon: "star.fill",
                color: .yellow,
                value: "\(gameState.gameRecords.map { $0.score }.max() ?? 0)",
                label: localization.localized("game.menu.stats.highest")
            )
            
            statBox(
                icon: "trophy.fill",
                color: .orange,
                value: "\(gameState.unlockedAchievementsCount)",
                label: localization.localized("game.menu.stats.achievements")
            )
            
            statBox(
                icon: "music.note",
                color: .cyan,
                value: "\(Song.allSongs.count + gameState.customSongs.count)",
                label: localization.localized("game.menu.stats.songs")
            )
        }
    }
    
    @ViewBuilder
    private func statBox(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - 歌曲选择区域
    private var songSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(localization.localized("game.menu.select.song"))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            // 内置歌曲
            VStack(spacing: 12) {
                ForEach(Song.allSongs) { song in
                    songCard(song: song)
                }
            }
            
            // 自定义歌曲
            if !gameState.customSongs.isEmpty {
                HStack {
                    Text(localization.localized("game.menu.my.songs"))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Button(action: { /* 清空所有自定义歌曲 */ }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.red.opacity(0.8))
                    }
                }
                .padding(.top, 8)
                
                VStack(spacing: 12) {
                    ForEach(gameState.customSongs) { customSong in
                        if let song = customSong.toSong() {
                            customSongCard(song: song, customSong: customSong)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func customSongCard(song: Song, customSong: CustomSong) -> some View {
        HStack(spacing: 0) {
            Button(action: {
                selectSong(song)
            }) {
                HStack(spacing: 16) {
                    // 音符图标
                    ZStack {
                        Circle()
                            .fill(.cyan.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Text("♪")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.cyan)
                    }
                    
                    // 歌曲信息
                    VStack(alignment: .leading, spacing: 4) {
                        Text(song.name)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        HStack(spacing: 8) {
                            Text("\(song.notes.count) " + localization.localized("game.menu.notes"))
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                            
                            Text("•")
                                .foregroundStyle(.white.opacity(0.3))
                            
                            Text("BPM \(song.bpm)")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        
                        // 最佳记录
                        if let bestRecord = gameState.getBestRecord(for: song.name) {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.yellow)
                                Text(localization.localized("game.menu.best") + ": \(bestRecord.rank) - \(bestRecord.score)")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(.yellow)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(16)
            }
            .buttonStyle(.plain)
            
            // 删除按钮
            Button(action: {
                gameState.deleteCustomSong(customSong)
            }) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
                    .frame(width: 50)
            }
            .buttonStyle(.plain)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.cyan.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    private func songCard(song: Song) -> some View {
        Button(action: {
            selectSong(song)
        }) {
            HStack(spacing: 16) {
                // 音符图标
                ZStack {
                    Circle()
                        .fill(.cyan.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text("♪")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.cyan)
                }
                
                // 歌曲信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.name)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    HStack(spacing: 8) {
                        Text("\(song.notes.count) " + localization.localized("game.menu.notes"))
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                        
                        Text("•")
                            .foregroundStyle(.white.opacity(0.3))
                        
                        Text("BPM \(song.bpm)")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    
                    // 最佳记录
                    if let bestRecord = gameState.getBestRecord(for: song.name) {
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.yellow)
                            Text(localization.localized("game.menu.best") + ": \(bestRecord.rank) - \(bestRecord.score)")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(.yellow)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.cyan.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 功能按钮区域
    private var featureButtonsSection: some View {
        VStack(spacing: 12) {
            featureButton(
                icon: "music.note.list",
                title: localization.localized("game.menu.editor"),
                color: .purple,
                action: { showEditor = true }
            )
            
            featureButton(
                icon: "chart.bar.fill",
                title: localization.localized("game.menu.leaderboard"),
                color: .orange,
                action: { showLeaderboard = true }
            )
        }
    }
    
    @ViewBuilder
    private func featureButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 游戏控制方法
    
    // MARK: - 难度选择视图（内嵌版本）
    @ViewBuilder
    private func modeSelectionView(song: Song) -> some View {
        ZStack {
            // 主题配色背景层 - 使用磨砂玻璃效果
            ZStack {
                // 底层渐变色
                LinearGradient(
                    colors: ThemeManager.shared.backgroundGradient(isDark: true),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 磨砂玻璃效果层
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 32) {
                // 标题
                VStack(spacing: 8) {
                    Text(song.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(localization.localized("game.mode.select.title"))
                        .font(.system(size: 16, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                // 难度选项
                VStack(spacing: 16) {
                    ForEach([GameMode.easy, .normal, .hard, .expert], id: \.self) { mode in
                        modeButton(mode, selectedMode: $selectedMode)
                    }
                }
                .padding(.horizontal, 20)
                
                // 按钮
                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation {
                            currentView = .menu
                            selectedSong = nil
                        }
                    }) {
                        Text(localization.localized("game.mode.cancel"))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white.opacity(0.1))
                            )
                    }
                    
                    Button(action: {
                        startGame(song: song, mode: selectedMode)
                    }) {
                        Text(localization.localized("game.mode.start"))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.cyan.opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.cyan, lineWidth: 2)
                                    )
                            )
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(40)
        }
    }
    
    // MARK: - 难度选择按钮
    @ViewBuilder
    private func modeButton(_ mode: GameMode, selectedMode: Binding<GameMode>) -> some View {
        Button(action: {
            selectedMode.wrappedValue = mode
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.localizedName)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text(localization.localized("game.mode.fall.speed") + ": \(String(format: "%.1fx", mode.fallSpeed))")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                Spacer()
                
                if selectedMode.wrappedValue == mode {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.cyan)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedMode.wrappedValue == mode ? Color.cyan.opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selectedMode.wrappedValue == mode ? Color.cyan : Color.white.opacity(0.2), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 游戏控制方法
    
    private func selectSong(_ song: Song) {
        selectedSong = song
        withAnimation {
            currentView = .modeSelection
        }
    }
    
    private func startGame(song: Song, mode: GameMode) {
        selectedSong = song
        selectedMode = mode
        withAnimation {
            currentView = .playing
        }
    }
    
    private func handleGameExit() {
        // 检查是否有记录需要显示
        if let latestRecord = gameState.gameRecords.first,
           latestRecord.songName == selectedSong?.name {
            lastRecord = latestRecord
            print("🎯 找到匹配的游戏记录 - 歌曲: \(latestRecord.songName), 得分: \(latestRecord.score)")
            withAnimation {
                currentView = .result
            }
        } else {
            print("⚠️ 未找到匹配的游戏记录 - 当前歌曲: \(selectedSong?.name ?? "无")")
            if let firstRecord = gameState.gameRecords.first {
                print("📝 第一条记录: \(firstRecord.songName), 得分: \(firstRecord.score)")
            }
            withAnimation {
                currentView = .menu
                selectedSong = nil
            }
        }
    }
    
    private func restartGame() {
        lastRecord = nil
        if selectedSong != nil {
            withAnimation {
                currentView = .playing
            }
        }
    }
}
