import SwiftUI
import Combine

/// SpriteKit游戏的ViewModel - 管理游戏状态和业务逻辑
final class SpriteKitGameViewModel: ObservableObject {
    
    // MARK: - Published状态
    @Published var fallingNotes: [FallingNote] = []
    @Published var currentTime: Double = 0
    @Published var lastJudgement: JudgementResult?
    @Published var feverMode = FeverMode()
    @Published var isPlaying: Bool = false
    @Published var isPaused: Bool = false
    @Published var gameCompleted: Bool = false  // 新增：游戏完成状态
    
    // MARK: - 私有属性
    private var hasEndedGame: Bool = false  // 防止重复调用 endGame
    private let song: Song
    private let mode: GameMode
    private var gameState = GameStateManager.shared
    private var startTime: Date?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 回调
    var onGameCompleted: (() -> Void)?  // 新增：游戏完成回调
    
    // MARK: - 初始化
    init(song: Song, mode: GameMode) {
        self.song = song
        self.mode = mode
        
        setupBindings()
    }
    
    // MARK: - 设置
    private func setupBindings() {
        // 监听Fever能量变化
        feverMode.$energy
            .sink { [weak self] energy in
                if energy >= 100 {
                    self?.tryActivateFever()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 游戏控制
    
    /// 开始游戏
    func startGame() {
        generateFallingNotes()
        gameState.startGame(song: song, mode: mode)
        isPlaying = true
        isPaused = false
        hasEndedGame = false  // 重置结束标记，允许新游戏保存记录
        startTime = Date()
        feverMode.reset()
        
        print("?? ViewModel: 游戏开始 - 音符数: \(fallingNotes.count)")
    }
    
    /// 暂停游戏
    func pauseGame() {
        isPaused = true
        gameState.pauseGame()
        print("⏸️ ViewModel: 游戏暂停")
    }
    
    /// 恢复游戏
    func resumeGame() {
        isPaused = false
        gameState.resumeGame()
        print("▶️ ViewModel: 游戏继续")
    }
    
    /// 停止游戏
    func stopGame() {
        isPlaying = false
        isPaused = false
        
        // 只在未保存记录时调用 endGame
        if !hasEndedGame {
            gameState.endGame()
            hasEndedGame = true
            print("🏁 ViewModel: 游戏结束")
        } else {
            print("⚠️ ViewModel: 游戏已结束，跳过重复保存")
        }
    }
    
    /// 退出游戏（不保存）
    func quitGame() {
        isPlaying = false
        isPaused = false
        gameState.quitGame()
        print("🚪 ViewModel: 退出游戏")
    }
    
    // MARK: - 音符生成
    
    /// 从歌曲生成下落音符
    private func generateFallingNotes() {
        var currentTargetTime: Double = 0
        fallingNotes.removeAll()
        
        for (index, noteIndex) in song.notes.enumerated() {
            // 计算目标击中时间
            currentTargetTime += song.durations[index]
            
            // 确定音符类型（可以根据歌曲数据扩展）
            let noteType = determineNoteType(at: index)
            
            // 创建下落音符
            let note = FallingNote(
                noteIndex: noteIndex,
                targetTime: currentTargetTime,
                currentY: -50,
                noteType: noteType
            )
            
            fallingNotes.append(note)
        }
        
        print("✅ ViewModel: 生成了 \(fallingNotes.count) 个下落音符")
    }
    
    /// 确定音符类型（简单策略，可扩展）
    private func determineNoteType(at index: Int) -> NoteType {
        // 暂时全部使用普通音符，后续可根据歌曲配置决定
        return .normal
    }
    
    // MARK: - 判定处理
    
    /// 处理音符击中
    func handleNoteHit(_ judgement: JudgementResult) {
        // 显示判定反馈
        lastJudgement = judgement
        
        // 记录判定
        let feverMultiplier = feverMode.scoreMultiplier
        gameState.recordJudgement(judgement, feverMultiplier: feverMultiplier)
        
        // 增加Fever能量
        feverMode.addEnergy(for: judgement)
        
        // 清除判定反馈
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.lastJudgement = nil
        }
        
        print("✅ 判定: \(judgement.rawValue) - 分数: \(gameState.currentScore) - Combo: \(gameState.currentCombo)")
    }
    
    /// 处理音符Miss
    func handleNoteMiss() {
        lastJudgement = .miss
        gameState.recordJudgement(.miss)
        
        // 清除判定反馈
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.lastJudgement = nil
        }
        
        print("❌ Miss - Combo中断")
    }
    
    // MARK: - 时间更新
    
    /// 更新游戏时间
    func updateTime(_ time: Double) {
        currentTime = time
        
        // 检查游戏是否结束 - 当所有音符都处理完成后结束
        if !fallingNotes.isEmpty {
            let allProcessed = fallingNotes.allSatisfy { note in
                note.isHit || note.judgement != nil
            }
            
            if allProcessed && isPlaying {
                // 所有音符都已处理，结束游戏
                finishGame()
            } else if let lastNote = fallingNotes.last {
                // 备用检查：如果最后一个音符已经过了判定线很长时间，强制结束
                if time > lastNote.targetTime + 2.0 {
                    finishGame()
                }
            }
        }
    }
    
    /// 完成游戏
    private func finishGame() {
        guard isPlaying else { return }
        
        isPlaying = false
        isPaused = false
        gameCompleted = true  // 标记游戏完成
        
        // 保存游戏记录（只保存一次）
        if !hasEndedGame {
            gameState.endGame()
            hasEndedGame = true
            print("🎊 游戏完成！最终得分: \(gameState.currentScore)")
        } else {
            print("⚠️ 游戏已保存记录，跳过重复保存")
        }
        
        // 即时触发游戏完成回调，避免用户等待
        onGameCompleted?()
    }
    
    /// 音频播放完成回调 - 确保音频和音符同步完成
    func onAudioPlaybackComplete() {
        // 等待一小段时间让剩余音符下落完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self, self.isPlaying else { return }
            
            // 检查所有音符是否都已处理（包括Miss）
            let unprocessedNotes = self.fallingNotes.filter { !$0.isHit && $0.judgement == nil }
            if unprocessedNotes.isEmpty {
                self.finishGame()
            } else {
                print("🎵 音频播放完成，但还有 \(unprocessedNotes.count) 个音符未处理，等待音符完成...")
            }
        }
    }
    
    // MARK: - Fever系统
    
    /// 尝试激活Fever模式
    private func tryActivateFever() {
        guard !feverMode.isActive else { return }
        
        feverMode.activate()
        print("🔥 Fever模式激活！")
    }
    
    /// 手动激活Fever（当玩家触发时）
    func activateFeverManually() {
        guard feverMode.energy >= 100 && !feverMode.isActive else { return }
        feverMode.activate()
    }
    
    // MARK: - 游戏统计
    
    /// 获取当前准确率
    var currentAccuracy: Double {
        let total = gameState.perfectCount + gameState.goodCount + gameState.missCount
        guard total > 0 else { return 0.0 }
        return Double(gameState.perfectCount + gameState.goodCount) / Double(total)
    }
    
    /// 获取完成度
    var completionPercentage: Double {
        guard !fallingNotes.isEmpty else { return 1.0 } // 如果没有音符，视为完成
        
        let processedCount = fallingNotes.filter { $0.isHit || $0.judgement != nil }.count
        return Double(processedCount) / Double(fallingNotes.count)
    }
}