import SwiftUI
import Combine

/// 音符下落引擎 - 管理音符的生成和下落动画（支持高级音符类型）
final class NoteFallEngine: ObservableObject {
    
    // MARK: - 配置
    private let fallDistance: CGFloat = 600  // 下落总距离
    private let judgementLineY: CGFloat = 500 // 判定线Y坐标
    private let noteSpawnY: CGFloat = -100    // 音符生成Y坐标（从屏幕顶端开始）
    private let maxVisibleNotes: Int = 8      // 同时最多显示8个音符（更聪明的可见性控制）
    
    // MARK: - 状态
    @Published var fallingNotes: [FallingNote] = []
    @Published var currentTime: Double = 0
    @Published var feverMode = FeverMode()
    
    private var song: Song?
    private var gameMode: GameMode = .normal
    private var startTime: Date?
    private var timer: AnyCancellable?
    
    // 长按音符状态追踪
    private var activeHoldNotes: [UUID: Date] = [:]  // 音符ID -> 开始长按时间
    
    // 判定回调
    var onJudgement: ((JudgementResult) -> Void)?
    var onNotePass: ((Int) -> Void)?  // 音符通过判定线时触发（用于播放音效）
    var onGameComplete: (() -> Void)?
    var onFeverActivated: (() -> Void)?  // Fever模式激活回调
    
    // MARK: - 初始化
    init() {}
    
    // MARK: - 游戏控制
    
    /// 开始游戏
    func startGame(song: Song, mode: GameMode) {
        self.song = song
        self.gameMode = mode
        self.startTime = Date()
        self.currentTime = 0
        self.fallingNotes.removeAll()
        
        // 生成所有下落音符
        generateFallingNotes(from: song, mode: mode)
        
        // 启动更新循环
        startUpdateLoop()
        
        print("🎮 下落引擎启动 - 歌曲: \(song.name), 音符数: \(fallingNotes.count)")
    }
    
    /// 暂停游戏
    func pause() {
        timer?.cancel()
        timer = nil
    }
    
    /// 恢复游戏
    func resume() {
        startUpdateLoop()
    }
    
    /// 停止游戏
    func stop() {
        timer?.cancel()
        timer = nil
        fallingNotes.removeAll()
        currentTime = 0
        startTime = nil
    }
    
    // MARK: - 音符生成
    
    /// 从歌曲生成下落音符
    private func generateFallingNotes(from song: Song, mode: GameMode) {
        var currentTargetTime: Double = 0
        
        for (index, noteIndex) in song.notes.enumerated() {
            // 计算目标击中时间
            currentTargetTime += song.durations[index]
            
            // 创建下落音符
            let note = FallingNote(
                noteIndex: noteIndex,
                targetTime: currentTargetTime,
                currentY: noteSpawnY
            )
            
            fallingNotes.append(note)
        }
        
        print("✅ 生成了 \(fallingNotes.count) 个下落音符")
    }
    
    // MARK: - 更新循环
    
    /// 启动更新循环（60 FPS）
    private func startUpdateLoop() {
        timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.update()
            }
    }
    
    /// 每帧更新
    private func update() {
        guard let startTime = startTime else { return }
        
        // 更新当前时间
        currentTime = Date().timeIntervalSince(startTime)
        
        // 更新所有音符位置
        updateNotePositions()
        
        // 检查是否完成
        checkGameCompletion()
    }
    
    /// 更新音符位置（根据BPM同步）
    private func updateNotePositions() {
        guard let song = song else { return }
        
        // 根据BPM计算下落速度
        let bpm = Double(song.bpm)
        let beatsPerSecond = bpm / 60.0
        let fallSpeed = gameMode.fallSpeed * beatsPerSecond / 2.0  // BPM同步调整
        
        for i in 0..<fallingNotes.count {
            guard !fallingNotes[i].isHit else { continue }
            
            let note = fallingNotes[i]
            let timeUntilHit = note.targetTime - currentTime
            
            // 计算Y坐标：根据剩余时间和下落速度
            let leadTime = fallDistance / (100 * fallSpeed)
            let progress = 1.0 - (timeUntilHit / leadTime)
            
            let newY = noteSpawnY + (judgementLineY - noteSpawnY) * progress
            fallingNotes[i].currentY = newY
            
            // 检查是否超过判定线（Miss）
            if newY > judgementLineY + 50 && !fallingNotes[i].isHit {
                handleMiss(at: i)
            }
            
            // 音符接近判定线时播放音效
            if abs(newY - judgementLineY) < 5 && !fallingNotes[i].isHit {
                onNotePass?(note.noteIndex)
            }
        }
    }
    
    // MARK: - 用户输入处理
    
    /// 处理键盘点击
    func handleKeyPress(noteIndex: Int) {
        // 查找最接近判定线且未击中的对应音符
        var closestNote: (index: Int, distance: Double, note: FallingNote)?
        
        for (i, note) in fallingNotes.enumerated() {
            guard note.noteIndex == noteIndex && !note.isHit else { continue }
            
            let distance = Double(abs(note.currentY - judgementLineY))
            
            if closestNote == nil || distance < closestNote!.distance {
                closestNote = (i, distance, note)
            }
        }
        
        guard let (index, distance, note) = closestNote else {
            return  // 没有找到对应音符
        }
        
        // 根据音符类型处理
        switch note.noteType {
        case .normal:
            handleNormalNote(at: index, distance: distance)
            
        case .hold:
            handleHoldNoteStart(at: index, distance: distance)
            
        case .slide:
            handleSlideNote(at: index, distance: distance)
        }
    }
    
    /// 处理普通音符
    private func handleNormalNote(at index: Int, distance: Double) {
        let judgement = calculateJudgement(distance: distance)
        
        fallingNotes[index].isHit = true
        fallingNotes[index].judgement = judgement
        
        // Fever能量增加
        feverMode.addEnergy(for: judgement)
        
        onJudgement?(judgement)
        print("⚡ 判定: \(judgement.rawValue) - 距离: \(Int(distance))px")
    }
    
    /// 处理长按音符开始
    private func handleHoldNoteStart(at index: Int, distance: Double) {
        let judgement = calculateJudgement(distance: distance)
        
        if judgement != .miss {
            // 开始长按
            fallingNotes[index].isHolding = true
            activeHoldNotes[fallingNotes[index].id] = Date()
            print("🎯 长按开始: \(fallingNotes[index].noteName)")
        } else {
            // Miss
            fallingNotes[index].isHit = true
            fallingNotes[index].judgement = .miss
            onJudgement?(.miss)
        }
    }
    
    /// 处理键盘释放（长按音符结束）
    func handleKeyRelease(noteIndex: Int) {
        // 查找正在长按的音符
        for i in 0..<fallingNotes.count {
            let note = fallingNotes[i]
            
            guard note.noteIndex == noteIndex,
                  note.noteType == .hold,
                  note.isHolding,
                  let startTime = activeHoldNotes[note.id],
                  let requiredDuration = note.holdDuration else {
                continue
            }
            
            // 计算长按时长
            let holdTime = Date().timeIntervalSince(startTime)
            let progress = min(1.0, holdTime / requiredDuration)
            
            fallingNotes[i].holdProgress = progress
            fallingNotes[i].isHolding = false
            fallingNotes[i].isHit = true
            
            // 根据完成度判定
            let judgement: JudgementResult
            if progress >= 0.95 {
                judgement = .perfect
            } else if progress >= 0.7 {
                judgement = .good
            } else {
                judgement = .miss
            }
            
            fallingNotes[i].judgement = judgement
            activeHoldNotes.removeValue(forKey: note.id)
            
            // Fever能量增加
            feverMode.addEnergy(for: judgement)
            
            onJudgement?(judgement)
            print("🎯 长按结束: \(note.noteName) - 完成度: \(Int(progress * 100))%")
            
            return
        }
    }
    
    /// 处理滑动音符
    private func handleSlideNote(at index: Int, distance: Double) {
        let judgement = calculateJudgement(distance: distance)
        
        fallingNotes[index].isHit = true
        fallingNotes[index].judgement = judgement
        
        // 滑动音符给予额外能量奖励
        feverMode.addEnergy(for: judgement)
        if judgement == .perfect {
            feverMode.addEnergy(for: .good) // 额外奖励
        }
        
        onJudgement?(judgement)
        print("⚡ 滑动判定: \(judgement.rawValue)")
    }
    
    /// 激活Fever模式
    func activateFever() {
        feverMode.activate()
        onFeverActivated?()
        print("🔥 Fever模式激活！")
    }
    
    /// 计算判定结果
    private func calculateJudgement(distance: Double) -> JudgementResult {
        let window = gameMode.judgementWindow
        let distanceInSeconds = distance / (100 * gameMode.fallSpeed)
        
        if distanceInSeconds <= window.perfect {
            return .perfect
        } else if distanceInSeconds <= window.good {
            return .good
        } else {
            return .miss
        }
    }
    
    /// 处理Miss
    private func handleMiss(at index: Int) {
        fallingNotes[index].isHit = true
        fallingNotes[index].judgement = .miss
        onJudgement?(.miss)
        print("❌ Miss - 音符索引: \(index)")
    }
    
    // MARK: - 游戏完成检查
    
    /// 检查游戏是否完成
    private func checkGameCompletion() {
        // 所有音符都已处理
        let allProcessed = fallingNotes.allSatisfy { $0.isHit }
        
        if allProcessed && !fallingNotes.isEmpty {
            stop()
            onGameComplete?()
        }
    }
    
    // MARK: - 获取可见音符（智能筛选）
    
    /// 获取当前屏幕上可见的音符（限制数量，优先显示最接近判定线的）
    func getVisibleNotes() -> [FallingNote] {
        // 筛选未击中且在屏幕范围内的音符
        let candidateNotes = fallingNotes.filter { note in
            !note.isHit && note.currentY >= noteSpawnY && note.currentY <= judgementLineY + 100
        }
        
        // 按距离判定线的远近排序
        let sortedNotes = candidateNotes.sorted { note1, note2 in
            let distance1 = abs(note1.currentY - judgementLineY)
            let distance2 = abs(note2.currentY - judgementLineY)
            return distance1 < distance2
        }
        
        // 只返回最接近的N个音符
        return Array(sortedNotes.prefix(maxVisibleNotes))
    }
    
    // MARK: - 调试信息
    
    var debugInfo: String {
        """
        时间: \(String(format: "%.2f", currentTime))s
        音符数: \(fallingNotes.count)
        可见: \(getVisibleNotes().count)
        已击中: \(fallingNotes.filter { $0.isHit }.count)
        """
    }
}
