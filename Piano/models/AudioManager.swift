import AVFoundation
import Combine
import UIKit

/// 音频管理器 - 负责生成和播放音符
final class AudioManager: ObservableObject {
    private let audioEngine = AVAudioEngine()
    private var playerNodes: [AVAudioPlayerNode] = []
    private var isEngineRunning = false
    private var reverbNode: AVAudioUnitReverb?
    private var delayNode: AVAudioUnitDelay?
    private var distortionNode: AVAudioUnitDistortion?
    
    // 音频缓存 - 存储预生成的音符缓冲区
    private var audioBufferCache: [Int: AVAudioPCMBuffer] = [:]
    
    // 播放节点池 - 重用播放节点
    private var playerNodePool: [AVAudioPlayerNode] = []
    private let playerNodePoolSize = 8
    
    // 高精度音频调度
    private var songScheduler: SongScheduler?
    private var isPlayingSong = false
    
    /// 音频效果类型
    enum AudioEffect: String, CaseIterable {
        case none = "原声"
        case reverb = "混响"
        case delay = "延迟"
        case distortion = "失真"
        case chorus = "合唱"
        
        var localizedName: String {
            switch self {
            case .none: return "audio.effect.none".localized
            case .reverb: return "audio.effect.reverb".localized
            case .delay: return "audio.effect.delay".localized
            case .distortion: return "audio.effect.distortion".localized
            case .chorus: return "audio.effect.chorus".localized
            }
        }
    }
    
    /// 当前音频效果
    @Published var currentEffect: AudioEffect = .none {
        didSet {
            updateAudioEffect()
        }
    }
    
    /// 音量控制 (0.0 - 1.0)
    @Published var volume: Float = 0.5 {
        didSet {
            let clampedVolume = max(0.0, min(1.0, volume))
            if volume != clampedVolume {
                volume = clampedVolume
            }
            DispatchQueue.main.async { [weak self] in
                self?.updateVolume()
            }
        }
    }
    
    init() {
        setupAudioSession()
        setupEngine()
    }
    
    deinit {
        stopAll()
        if isEngineRunning {
            audioEngine.stop()
        }
        
        // 清理效果节点
        if let reverbNode = reverbNode {
            audioEngine.detach(reverbNode)
        }
        if let delayNode = delayNode {
            audioEngine.detach(delayNode)
        }
        if let distortionNode = distortionNode {
            audioEngine.detach(distortionNode)
        }
    }
    
    // MARK: - 切换音频效果（安全版本 - 优化版）
    func nextEffect() {
        print("🔄 切换音效...")
        
        // 1. 完全停止所有音频
        stopAll()
        
        // 2. 确保音频引擎处于完全停止状态
        if audioEngine.isRunning {
            audioEngine.stop()
            isEngineRunning = false
            print("✅ 音频引擎已停止")
        }
        
        // 3. 重置音频引擎连接
        audioEngine.reset()
        
        let allEffects = AudioEffect.allCases
        guard let currentIndex = allEffects.firstIndex(of: currentEffect) else { return }
        
        let nextIndex = (currentIndex + 1) % allEffects.count
        let nextEffect = allEffects[nextIndex]
        
        // 4. 直接切换效果
        currentEffect = nextEffect
        
        print("✅ 音效已切换到: \(nextEffect.rawValue)")
        
        // 5. 触觉反馈
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - 暂停音频引擎（用于配置更改）- 优化版
    private func pauseAudioEngineForConfiguration() -> Bool {
        print("⏸️ 暂停音频引擎进行配置...")
        
        // 完全停止所有播放
        stopAll()
        
        // 确保音频引擎完全停止
        if audioEngine.isRunning {
            audioEngine.stop()
            isEngineRunning = false
        }
        
        // 重置所有连接和节点
        audioEngine.reset()
        
        return true
    }
    
    // MARK: - 恢复音频引擎（配置完成后）
    private func resumeAudioEngine() -> Bool {
        print("▶️ 恢复音频引擎...")
        
        // 根据当前效果重新配置音频链
        switch currentEffect {
        case .reverb:
            return setupReverbEffect()
        case .delay:
            return setupDelayEffect()
        case .distortion:
            return setupDistortionEffect()
        case .chorus:
            return setupChorusEffect()
        case .none:
            return setupDefaultAudioChain()
        }
    }
    
    // MARK: - 更新音频效果
    private func updateAudioEffect() {
        // 暂停音频引擎进行安全配置
        guard pauseAudioEngineForConfiguration() else {
            print("❌ 无法暂停音频引擎进行配置")
            return
        }
        
        // 移除所有效果节点引用
        reverbNode = nil
        delayNode = nil
        distortionNode = nil
        
        // 恢复音频引擎使用新配置
        guard resumeAudioEngine() else {
            print("❌ 无法恢复音频引擎")
            return
        }
        
        print("✅ 音频效果已成功切换到: \(currentEffect.rawValue)")
    }
    
    // MARK: - 设置默认音频链（无效果）
    private func setupDefaultAudioChain() -> Bool {
        // 连接主混音器到输出节点
        let outputFormat = audioEngine.outputNode.inputFormat(forBus: 0)
        audioEngine.connect(audioEngine.mainMixerNode, to: audioEngine.outputNode, format: outputFormat)
        
        // 准备引擎
        audioEngine.prepare()
        
        // 启动引擎
        do {
            try audioEngine.start()
            isEngineRunning = true
            print("✅ 默认音频链配置成功")
            return true
        } catch {
            print("❌ 默认音频链启动失败: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - 重置到默认连接
    private func resetToDefaultConnection() {
        // 确保引擎停止
        if audioEngine.isRunning {
            audioEngine.stop()
            isEngineRunning = false
        }
        
        // 重置所有连接
        audioEngine.reset()
        
        // 重新建立基础连接
        let outputFormat = audioEngine.outputNode.inputFormat(forBus: 0)
        audioEngine.connect(audioEngine.mainMixerNode, to: audioEngine.outputNode, format: outputFormat)
        
        // 重新准备引擎
        audioEngine.prepare()
        
        // 尝试重新启动引擎
        do {
            try audioEngine.start()
            isEngineRunning = true
            print("✅ 音频引擎重新启动成功（默认模式）")
        } catch {
            print("❌ 音频引擎重新启动失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 设置音频会话
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            print("✅ 音频会话配置成功")
        } catch {
            print("❌ 音频会话设置失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 设置音频引擎
    private func setupEngine() {
        // 确保音频引擎处于停止状态
        if audioEngine.isRunning {
            audioEngine.stop()
            isEngineRunning = false
        }
        
        // 重置所有连接
        audioEngine.disconnectNodeInput(audioEngine.outputNode)
        audioEngine.disconnectNodeOutput(audioEngine.mainMixerNode)
        
        // 设置初始音量
        audioEngine.mainMixerNode.outputVolume = volume
        
        // 连接主混音器到输出节点
        let outputFormat = audioEngine.outputNode.inputFormat(forBus: 0)
        audioEngine.connect(audioEngine.mainMixerNode, to: audioEngine.outputNode, format: outputFormat)
        
        // 准备引擎
        audioEngine.prepare()
        print("✅ 音频引擎配置完成")
    }
    
    // MARK: - 更新音量
    private func updateVolume() {
        // 同时更新主混音器和所有活跃播放节点的音量
        audioEngine.mainMixerNode.outputVolume = volume
        
        // 更新所有正在播放的节点音量
        for playerNode in playerNodes {
            playerNode.volume = volume
        }
        
        print("🔊 音量已调整为: \(Int(volume * 100))% (主混音器: \(volume), 播放节点: \(playerNodes.count)个)")
    }
    
    // MARK: - 增大音量
    func increaseVolume() {
        volume = min(1.0, volume + 0.1)
    }
    
    // MARK: - 减小音量
    func decreaseVolume() {
        volume = max(0.0, volume - 0.1)
    }
    
    // MARK: - 启动音频引擎
    private func startEngineIfNeeded() {
        guard !isEngineRunning else { return }
        
        do {
            try audioEngine.start()
            isEngineRunning = true
            print("✅ 音频引擎启动成功")
        } catch {
            print("❌ 音频引擎启动失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 播放音符（优化版）
    func playNote(_ note: Note, scheduledTime: AVAudioTime? = nil) {
        // 确保引擎正在运行
        startEngineIfNeeded()
        
        // 获取或创建音频缓冲区
        guard let buffer = getOrCreateBuffer(for: note) else {
            print("❌ 无法获取音频缓冲区")
            return
        }
        
        // 获取可重用的播放节点
        let playerNode = getReusablePlayerNode()
        
        // 播放音频 - 支持精确时间调度
        playerNode.scheduleBuffer(buffer, at: scheduledTime, options: []) { [weak self, weak playerNode] in
            guard let self = self, let playerNode = playerNode else { return }
            DispatchQueue.main.async {
                self.returnPlayerNodeToPool(playerNode)
            }
        }
        
        // 设置音量并开始播放
        playerNode.volume = volume
        if !playerNode.isPlaying {
            playerNode.play()
        }
        playerNodes.append(playerNode)
        
        // 只在手动演奏时触发触觉反馈
        if scheduledTime == nil {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }
        
        print("🎵 播放音符: \(note.name) - 频率: \(note.frequency)Hz (调度时间: \(scheduledTime != nil ? "精确" : "即时"))")
    }
    
    // MARK: - 预加载音频缓冲区
    func preloadBuffers(for notes: [Note]) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            notes.forEach { note in
                _ = self?.getOrCreateBuffer(for: note)
            }
            print("✅ 预加载了 \(notes.count) 个音频缓冲区")
        }
    }
    
    // MARK: - 歌曲播放支持（高精度调度）
    func playSong(_ song: Song, notes: [Note], onNotePlay: @escaping (Int) -> Void, onComplete: @escaping () -> Void) {
        // 停止之前的播放
        stopSong()
        
        // 预加载所有需要的音符
        let uniqueNoteIndices = Set(song.notes)
        let notesToPreload = notes.filter { uniqueNoteIndices.contains($0.index) }
        preloadBuffers(for: notesToPreload)
        
        // 确保引擎正在运行
        startEngineIfNeeded()
        
        // 创建歌曲调度器
        let scheduler = SongScheduler(
            audioEngine: audioEngine,
            song: song,
            notes: notes,
            audioManager: self,
            onNotePlay: onNotePlay,
            onComplete: onComplete
        )
        
        self.songScheduler = scheduler
        self.isPlayingSong = true
        
        // 开始调度
        scheduler.start()
        
        print("🎼 开始播放歌曲: \(song.name), BPM: \(song.bpm)")
    }
    
    // MARK: - 停止歌曲播放
    func stopSong() {
        songScheduler?.stop()
        songScheduler = nil
        isPlayingSong = false
        stopAll()
        print("⏹️ 停止歌曲播放")
    }
    
    // MARK: - 批量预加载歌曲音符
    func preloadSongNotes(_ song: Song, notes: [Note]) {
        // 获取歌曲中使用的所有独特音符
        let uniqueNoteIndices = Set(song.notes)
        let notesToPreload = notes.filter { uniqueNoteIndices.contains($0.index) }
        preloadBuffers(for: notesToPreload)
    }
    
    // MARK: - 获取或创建音频缓冲区
    private func getOrCreateBuffer(for note: Note) -> AVAudioPCMBuffer? {
        // 首先检查缓存
        if let cachedBuffer = audioBufferCache[note.index] {
            return cachedBuffer
        }
        
        // 创建新的缓冲区
        guard let buffer = createSineWaveBuffer(frequency: note.frequency, duration: 0.8) else {
            return nil
        }
        
        // 缓存结果
        audioBufferCache[note.index] = buffer
        return buffer
    }
    
    // MARK: - 获取可重用的播放节点
    private func getReusablePlayerNode() -> AVAudioPlayerNode {
        // 首先尝试从池中获取
        if let node = playerNodePool.popLast() {
            audioEngine.attach(node)
            audioEngine.connect(node, to: audioEngine.mainMixerNode, format: AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2))
            return node
        }
        
        // 池为空，创建新节点
        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2))
        return playerNode
    }
    
    // MARK: - 将播放节点返回到池中
    private func returnPlayerNodeToPool(_ playerNode: AVAudioPlayerNode) {
        // 停止节点
        playerNode.stop()
        
        // 分离节点
        if audioEngine.attachedNodes.contains(playerNode) {
            audioEngine.detach(playerNode)
        }
        
        // 如果池未满，则回收节点
        if playerNodePool.count < playerNodePoolSize {
            playerNodePool.append(playerNode)
        }
        
        // 从活跃节点列表中移除
        if let index = playerNodes.firstIndex(of: playerNode) {
            playerNodes.remove(at: index)
        }
    }
    
    
    // MARK: - 检查是否有活跃的播放节点
    var hasActivePlayers: Bool {
        !playerNodes.isEmpty
    }
    
    // MARK: - 停止所有声音（增强版）
    func stopAll() {
        print("🛑 停止所有音频播放...")
        
        // 1. 首先停止歌曲调度器
        songScheduler?.stop()
        songScheduler = nil
        isPlayingSong = false
        
        // 2. 立即停止所有播放器节点
        for playerNode in playerNodes {
            playerNode.stop()
        }
        
        // 3. 安全分离所有播放节点
        safeDetachAllPlayerNodes()
        
        // 4. 清空播放器数组
        playerNodes.removeAll()
        
        // 5. 强制重置音频引擎状态
        if audioEngine.isRunning {
            audioEngine.reset()
        }
        
        print("✅ 所有音频已停止")
    }
    
    // MARK: - 安全分离所有播放节点
    private func safeDetachAllPlayerNodes() {
        // 获取当前附加的所有播放节点
        let attachedPlayerNodes = audioEngine.attachedNodes.filter { $0 is AVAudioPlayerNode }
        
        for playerNode in attachedPlayerNodes {
            // 先停止节点
            (playerNode as? AVAudioPlayerNode)?.stop()
            
            // 安全分离节点
            audioEngine.detach(playerNode)
        }
        
        // 清空播放节点池
        playerNodePool.removeAll()
    }
    
    // MARK: - 移除播放节点
    private func removePlayerNode(_ playerNode: AVAudioPlayerNode) {
        returnPlayerNodeToPool(playerNode)
    }
    
    // MARK: - 效果节点管理
    private func getLastEffectNode() -> AVAudioNode? {
        switch currentEffect {
        case .reverb where reverbNode != nil:
            return reverbNode
        case .delay where delayNode != nil:
            return delayNode
        case .distortion where distortionNode != nil:
            return distortionNode
        default:
            return nil
        }
    }
    
    // MARK: - 设置混响效果
    private func setupReverbEffect() -> Bool {
        let reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(.largeHall)
        reverb.wetDryMix = 30
        
        audioEngine.attach(reverb)
        
        // 连接混音器 -> 混响 -> 输出
        let outputFormat = audioEngine.outputNode.inputFormat(forBus: 0)
        audioEngine.connect(audioEngine.mainMixerNode, to: reverb, format: outputFormat)
        audioEngine.connect(reverb, to: audioEngine.outputNode, format: outputFormat)
        
        // 准备并启动引擎
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isEngineRunning = true
            reverbNode = reverb
            print("🔊 混响效果已启用")
            return true
        } catch {
            print("❌ 混响效果启用失败: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - 设置延迟效果
    private func setupDelayEffect() -> Bool {
        let delay = AVAudioUnitDelay()
        delay.delayTime = 0.3
        delay.feedback = 30
        delay.wetDryMix = 25
        
        audioEngine.attach(delay)
        
        // 连接混音器 -> 延迟 -> 输出
        let outputFormat = audioEngine.outputNode.inputFormat(forBus: 0)
        audioEngine.connect(audioEngine.mainMixerNode, to: delay, format: outputFormat)
        audioEngine.connect(delay, to: audioEngine.outputNode, format: outputFormat)
        
        // 准备并启动引擎
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isEngineRunning = true
            delayNode = delay
            print("🔊 延迟效果已启用")
            return true
        } catch {
            print("❌ 延迟效果启用失败: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - 设置失真效果
    private func setupDistortionEffect() -> Bool {
        let distortion = AVAudioUnitDistortion()
        distortion.loadFactoryPreset(.multiEcho1)
        distortion.wetDryMix = 20
        
        audioEngine.attach(distortion)
        
        // 连接混音器 -> 失真 -> 输出
        let outputFormat = audioEngine.outputNode.inputFormat(forBus: 0)
        audioEngine.connect(audioEngine.mainMixerNode, to: distortion, format: outputFormat)
        audioEngine.connect(distortion, to: audioEngine.outputNode, format: outputFormat)
        
        // 准备并启动引擎
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isEngineRunning = true
            distortionNode = distortion
            print("🔊 失真效果已启用")
            return true
        } catch {
            print("❌ 失真效果启用失败: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - 设置合唱效果
    private func setupChorusEffect() -> Bool {
        let delay = AVAudioUnitDelay()
        delay.delayTime = 0.03
        delay.feedback = 10
        delay.wetDryMix = 35
        
        audioEngine.attach(delay)
        
        // 连接混音器 -> 延迟（合唱）-> 输出
        let outputFormat = audioEngine.outputNode.inputFormat(forBus: 0)
        audioEngine.connect(audioEngine.mainMixerNode, to: delay, format: outputFormat)
        audioEngine.connect(delay, to: audioEngine.outputNode, format: outputFormat)
        
        // 准备并启动引擎
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isEngineRunning = true
            delayNode = delay
            print("🔊 合唱效果已启用")
            return true
        } catch {
            print("❌ 合唱效果启用失败: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - 创建正弦波音频缓冲区（增大基础振幅）
    private func createSineWaveBuffer(frequency: Double, duration: Double) -> AVAudioPCMBuffer? {
        createWaveBuffer(frequency: frequency, duration: duration) { time, freq in
            sin(2.0 * .pi * freq * time)
        }
    }
    
    // MARK: - 创建方波缓冲区
    private func createSquareWaveBuffer(frequency: Double, duration: Double) -> AVAudioPCMBuffer? {
        createWaveBuffer(frequency: frequency, duration: duration) { time, freq in
            sin(2.0 * .pi * freq * time) > 0 ? 1.0 : -1.0
        }
    }
    
    // MARK: - 创建锯齿波缓冲区
    private func createSawtoothWaveBuffer(frequency: Double, duration: Double) -> AVAudioPCMBuffer? {
        createWaveBuffer(frequency: frequency, duration: duration) { time, freq in
            2.0 * (time * freq - floor(time * freq + 0.5))
        }
    }
    
    // MARK: - 通用波形生成器
    private func createWaveBuffer(frequency: Double, duration: Double, waveform: (Double, Double) -> Double) -> AVAudioPCMBuffer? {
        let sampleRate = 44100.0
        let amplitude = 0.5  // 从 0.25 增加到 0.5，提升基础音量
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else {
            return nil
        }
        
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }
        
        buffer.frameLength = frameCount
        
        guard let leftChannel = buffer.floatChannelData?[0],
              let rightChannel = buffer.floatChannelData?[1] else {
            return nil
        }
        
        // 生成波形，添加包络
        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            let value = Float(waveform(time, frequency) * amplitude)
            
            // 添加ADSR包络
            var envelope: Float = 1.0
            let attack = 0.01  // 10ms 起音
            let decay = 0.1    // 100ms 衰减
            let sustain: Float = 0.7  // 70% 持续音量
            let release = 0.1  // 100ms 释音
            
            if time < attack {
                envelope = Float(time / attack)
            } else if time < attack + decay {
                let decayProgress = Float((time - attack) / decay)
                envelope = 1.0 - (1.0 - sustain) * decayProgress
            } else if time > duration - release {
                envelope = Float((duration - time) / release) * sustain
            } else {
                envelope = sustain
            }
            
            // 添加立体声效果
            let pan = sin(2.0 * .pi * 0.5 * time) * 0.3  // 缓慢左右移动
            
            leftChannel[frame] = value * envelope * Float(1.0 - pan)
            rightChannel[frame] = value * envelope * Float(1.0 + pan)
        }
        
        return buffer
    }
}
