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
    private var playbackTimer: Timer?
    private var startTime: Date?
    private var currentNoteIndex = 0
    
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
    }
    
    /// 开始播放歌曲
    func start() {
        isStopped = false
        currentNoteIndex = 0
        startTime = Date()
        
        // 预先调度所有音符播放
        scheduleAllNotes()
        
        print("✅ 已调度 \(song.notes.count) 个音符播放")
    }
    
    /// 调度所有音符
    private func scheduleAllNotes() {
        var accumulatedTime: TimeInterval = 0
        
        // 使用高优先级队列确保及时执行
        let queue = DispatchQueue.global(qos: .userInteractive)
        
        for (index, noteIndex) in song.notes.enumerated() {
            guard !isStopped else { break }
            
            let note = notes[noteIndex]
            let duration = song.durations[index]
            let playTime = accumulatedTime
            
            // 在指定时间播放音符
            queue.asyncAfter(deadline: .now() + playTime) { [weak self] in
                guard let self = self, !self.isStopped else { return }
                
                // 播放音符
                self.audioManager?.playNote(note)
                
                // 更新UI
                DispatchQueue.main.async {
                    self.onNotePlay(index)
                }
            }
            
            accumulatedTime += duration
        }
        
        // 播放完成回调
        let totalDuration = song.durations.reduce(0, +)
        queue.asyncAfter(deadline: .now() + totalDuration + 0.3) { [weak self] in
            guard let self = self, !self.isStopped else { return }
            DispatchQueue.main.async {
                self.onComplete()
            }
        }
    }
    
    /// 停止播放
    func stop() {
        isStopped = true
        playbackTimer?.invalidate()
        playbackTimer = nil
        print("⏹️ 歌曲调度已停止")
    }
}