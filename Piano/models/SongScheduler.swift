import AVFoundation
import Foundation

/// 高精度歌曲调度器 - 使用优化的定时调度确保流畅播放
class SongScheduler {
    private let audioEngine: AVAudioEngine
    private let song: Song
    private let notes: [Note]
    private weak var audioManager: AudioManager?
    private let onNotePlay: (Int) -> Void
    private let onComplete: () -> Void
    
    private var isStopped = false
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private var currentNoteIndex = 0
    private var playedNotes: Set<Int> = []
    private var noteTimings: [TimeInterval] = []
    
    init(
        audioEngine: AVAudioEngine,
        song: Song,
        notes: [Note],
        audioManager: AudioManager,
        onNotePlay: @escaping (Int) -> Void,
        onComplete: @escaping () -> Void
    ) {
        self.audioEngine = audioEngine
        self.song = song
        self.notes = notes
        self.audioManager = audioManager
        self.onNotePlay = onNotePlay
        self.onComplete = onComplete
        
        // 预计算所有音符的时间点
        calculateNoteTimings()
    }
    
    /// 预计算所有音符的绝对时间点
    private func calculateNoteTimings() {
        var accumulatedTime: TimeInterval = 0
        noteTimings = song.durations.map { duration in
            let timing = accumulatedTime
            accumulatedTime += duration
            return timing
        }
    }
    
    /// 开始播放歌曲
    func start() {
        isStopped = false
        currentNoteIndex = 0
        playedNotes.removeAll()
        startTime = CACurrentMediaTime()
        
        // 使用 CADisplayLink 实现高精度调度
        setupDisplayLink()
        
        print("✅ 开始高精度播放 \(song.notes.count) 个音符")
    }
    
    /// 设置 DisplayLink 进行实时调度
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    /// 每帧更新 - 检查是否需要播放音符
    @objc private func update() {
        guard !isStopped else {
            stopDisplayLink()
            return
        }
        
        let currentTime = CACurrentMediaTime() - startTime
        
        // 检查所有未播放的音符
        while currentNoteIndex < song.notes.count {
            let noteTime = noteTimings[currentNoteIndex]
            
            // 提前一点调度（补偿系统延迟）
            let scheduleThreshold = 0.02 // 提前20ms调度
            
            if currentTime >= noteTime - scheduleThreshold {
                playNoteAtIndex(currentNoteIndex)
                currentNoteIndex += 1
            } else {
                // 还没到播放时间，等待下一帧
                break
            }
        }
        
        // 检查是否播放完成
        if currentNoteIndex >= song.notes.count {
            let totalDuration = noteTimings.last ?? 0
            if currentTime >= totalDuration + 0.5 {
                complete()
            }
        }
    }
    
    /// 播放指定索引的音符
    private func playNoteAtIndex(_ index: Int) {
        guard !playedNotes.contains(index) else { return }
        
        playedNotes.insert(index)
        let noteIndex = song.notes[index]
        let note = notes[noteIndex]
        
        // 在高优先级队列中播放音符
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            self.audioManager?.playNote(note)
            
            // 更新UI
            DispatchQueue.main.async {
                self.onNotePlay(index)
            }
        }
    }
    
    /// 停止 DisplayLink
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    /// 播放完成
    private func complete() {
        guard !isStopped else { return }
        
        stopDisplayLink()
        
        DispatchQueue.main.async { [weak self] in
            self?.onComplete()
        }
        
        print("✅ 歌曲播放完成")
    }
    
    /// 停止播放
    func stop() {
        guard !isStopped else { return }
        
        isStopped = true
        stopDisplayLink()
        playedNotes.removeAll()
        currentNoteIndex = 0
        
        print("⏹️ 歌曲调度已停止")
    }
    
    deinit {
        stop()
    }
}