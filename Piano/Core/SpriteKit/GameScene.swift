import SpriteKit
import SwiftUI
import Combine

/// 游戏主场景 - 使用SpriteKit渲染音符和特效
class GameScene: SKScene {
    
    // MARK: - 配置常量
    private var judgementLineY: CGFloat = 0   // 判定线Y坐标（将在didMove中设置为屏幕中心）
    private var noteSpawnY: CGFloat = 0       // 音符生成Y坐标（从屏幕顶端开始，在didMove中设置）
    private let trackCount: Int = 7            // 轨道数量（与琴键数量匹配）
    
    // MARK: - 场景节点
    private var trackNodes: [SKShapeNode] = []
    private var judgementLineNode: SKShapeNode?
    private var optimizedJudgementLine: OptimizedJudgementLineNode?  // 美化版判定线
    private var noteNodes: [UUID: NoteNode] = [:]
    
    // MARK: - 游戏状态
    private var gameMode: GameMode = .normal
    private var currentTime: Double = 0
    private var gameStartTime: TimeInterval = 0  // 游戏开始的绝对时间
    private var fallingNotes: [FallingNote] = []
    private var isRunning: Bool = false
    
    // MARK: - 回调闭包
    var onNoteHit: ((UUID, JudgementResult) -> Void)?
    var onNoteMiss: ((UUID) -> Void)?
    var onTimeUpdate: ((Double) -> Void)?
    
    // MARK: - 初始化
    override func didMove(to view: SKView) {
        // 设置音符生成位置为屏幕最顶部
        noteSpawnY = size.height
        
        setupScene()
        setupTracks()
        setupJudgementLine()
    }
    
    // MARK: - 场景设置
    private func setupScene() {
        backgroundColor = .clear
        scaleMode = .aspectFill
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    }
    
    /// 设置轨道（与琴键数量匹配）
    private func setupTracks() {
        let trackWidth = size.width / CGFloat(trackCount)
        
        for i in 0..<trackCount {
            let xPosition = trackWidth * CGFloat(i) + trackWidth / 2
            
            // 轨道背景 - 使用与琴键一致的颜色
            let track = SKShapeNode(rectOf: CGSize(width: trackWidth - 2, height: size.height))
            track.position = CGPoint(x: xPosition, y: size.height / 2)
            
            // 使用琴键颜色作为轨道背景色
            let keyColor = getKeyColorForIndex(i)
            track.fillColor = UIColor(keyColor).withAlphaComponent(0.1)  // 更淡的背景色
            track.strokeColor = UIColor(keyColor).withAlphaComponent(0.2)
            track.lineWidth = 1
            track.zPosition = 0
            addChild(track)
            trackNodes.append(track)
        }
    }
    
    /// 获取轨道索引对应的琴键颜色 - 彩虹色系
    private func getKeyColorForIndex(_ index: Int) -> Color {
        // 彩虹色系：红、橙、黄、绿、青、蓝、紫
        let rainbowColors: [Color] = [
            .red, .orange, .yellow, .green,
            .cyan, .blue, .purple
        ]
        
        return rainbowColors[index]
    }
    
    /// 设置判定线
    private func setupJudgementLine() {
        // 设置判定线位置为距离屏幕底部33%的位置
        judgementLineY = size.height * 0.33  // 33%的位置，即距离底部67%
        
        // 创建美化版判定线
        optimizedJudgementLine = OptimizedJudgementLineNode()
        optimizedJudgementLine?.position = CGPoint(x: size.width / 2, y: judgementLineY)
        optimizedJudgementLine?.zPosition = 10
        if let judgementLine = optimizedJudgementLine {
            addChild(judgementLine)
        }
        
        print("🎯 判定线设置在距离底部33%的位置: Y = \(judgementLineY) (屏幕高度: \(size.height))")
    }
    
    // MARK: - 游戏控制
    /// 开始游戏
    func startGame(notes: [FallingNote], mode: GameMode) {
        self.fallingNotes = notes
        self.gameMode = mode
        self.currentTime = 0
        self.gameStartTime = 0  // 将在第一次update时设置
        self.isRunning = true
        
        // 清除现有音符
        noteNodes.values.forEach { $0.removeFromParent() }
        noteNodes.removeAll()
        
        print("🎮 GameScene 启动 - 音符数: \(notes.count)")
    }
    
    /// 暂停游戏
    func pauseGame() {
        isRunning = false
        isPaused = true
    }
    
    /// 恢复游戏
    func resumeGame() {
        isRunning = true
        isPaused = false
    }
    
    /// 停止游戏
    func stopGame() {
        isRunning = false
        noteNodes.values.forEach { $0.removeFromParent() }
        noteNodes.removeAll()
        fallingNotes.removeAll()
    }
    
    // MARK: - 帧更新
    override func update(_ currentTime: TimeInterval) {
        guard isRunning else { return }
        
        // 第一次更新时，记录游戏开始时间
        if gameStartTime == 0 {
            gameStartTime = currentTime
            print("⏱️ 游戏时间基准设置: \(gameStartTime)")
        }
        
        // 计算相对游戏开始的时间
        self.currentTime = currentTime - gameStartTime
        
        // 更新时间回调
        onTimeUpdate?(self.currentTime)
        
        // 生成和更新音符
        updateNotes(deltaTime: 1.0 / 60.0)  // 假设60 FPS
        
        // 检查未击中的音符
        checkMissedNotes()
    }
    
    /// 更新音符位置
    private func updateNotes(deltaTime: TimeInterval) {
        let fallSpeed = 300.0 * gameMode.fallSpeed  // 像素/秒
        let totalFallDistance = noteSpawnY - judgementLineY  // 总下落距离
        
        for i in 0..<fallingNotes.count {
            var note = fallingNotes[i]
            
            // 跳过已击中的音符
            guard !note.isHit else { continue }
            
            // 计算音符应该出现的时机（提前足够时间从顶端开始下落）
            let appearTime = note.targetTime - totalFallDistance / CGFloat(fallSpeed)
            
            if currentTime >= appearTime {
                // 创建或更新音符节点
                if noteNodes[note.id] == nil {
                    let noteNode = createNoteNode(for: note)
                    noteNodes[note.id] = noteNode
                    addChild(noteNode)
                }
                
                // 更新音符位置
                if let noteNode = noteNodes[note.id] {
                    // 从顶端开始计算位置
                    let timeFromAppear = currentTime - appearTime
                    let fallDistance = CGFloat(timeFromAppear) * CGFloat(fallSpeed)
                    let currentY = noteSpawnY - fallDistance
                    
                    noteNode.position.y = currentY
                    
                    // 更新音符数据
                    note.currentY = currentY
                    fallingNotes[i] = note
                }
            }
        }
    }
    
    /// 创建音符节点
    private func createNoteNode(for note: FallingNote) -> NoteNode {
        // 计算音符所在的实际琴键组（0-6，对应7个琴键）
        let actualKeyGroup = note.noteIndex % 7  // 0-6 直接映射到对应的琴键
        
        // 每个琴键占据的宽度（7个琴键）
        let keyWidth = size.width / 7.0
        let xPosition = keyWidth * CGFloat(actualKeyGroup) + keyWidth / 2
        
        // 获取与琴键一致的颜色
        let noteColor = getKeyColor(for: note.noteIndex)
        
        // 创建正方形音符，尺寸基于琴键宽度的比例
        let squareSize = min(keyWidth - 4, 40) // 确保是正方形，限制最大尺寸
        let noteNode = NoteNode(
            noteType: note.noteType,
            color: UIColor(noteColor),
            size: CGSize(width: squareSize, height: squareSize)  // 正方形音符
        )
        noteNode.position = CGPoint(x: xPosition, y: noteSpawnY)
        noteNode.zPosition = 5
        noteNode.noteId = note.id
        
        // 添加简谱标记
        let notationText = getNotationForIndex(note.noteIndex)
        noteNode.setNotation(notationText)
        
        return noteNode
    }
    
    /// 获取音符对应的琴键颜色（与SpriteKitGameView保持一致）- 彩虹色系
    private func getKeyColor(for noteIndex: Int) -> Color {
        let actualKeyGroup = noteIndex % 7  // 0-6 对应7个琴键
        
        // 彩虹色系：红、橙、黄、绿、青、蓝、紫
        let rainbowColors: [Color] = [
            .red, .orange, .yellow, .green,
            .cyan, .blue, .purple
        ]
        
        return rainbowColors[actualKeyGroup]
    }
    
    /// 获取音符索引对应的简谱标记
    private func getNotationForIndex(_ index: Int) -> String {
        let notations = ["1", "2", "3", "4", "5", "6", "7", "1̇",
                        "1̇", "2̇", "3̇", "4̇", "5̇", "6̇", "7̇", "1̈"]
        return index < notations.count ? notations[index] : "\(index + 1)"
    }
    
    /// 检查未击中的音符
    private func checkMissedNotes() {
        for i in 0..<fallingNotes.count {
            var note = fallingNotes[i]
            
            guard !note.isHit else { continue }
            
            // 如果音符已经过了判定线很远，判定为Miss
            let missThreshold = gameMode.judgementWindow.miss
            if currentTime > note.targetTime + missThreshold {
                note.isHit = true
                note.judgement = .miss
                fallingNotes[i] = note
                
                // 移除音符节点
                if let noteNode = noteNodes[note.id] {
                    noteNode.fadeOut()
                    noteNodes.removeValue(forKey: note.id)
                }
                
                // 触发Miss回调
                onNoteMiss?(note.id)
            }
        }
    }
    
    // MARK: - 触摸处理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // 确定触摸的轨道（现在有7个轨道）
        let trackWidth = size.width / CGFloat(trackCount)
        let trackIndex = Int(location.x / trackWidth)
        
        guard trackIndex >= 0 && trackIndex < trackCount else { return }
        
        // 查找该轨道上最接近判定线的音符
        hitNote(at: trackIndex)
    }
    
    /// 模拟触摸（供外部调用）
    func simulateTouch(at trackIndex: Int) {
        hitNote(at: trackIndex)
    }
    
    /// 击中音符
    private func hitNote(at trackIndex: Int) {
        // 查找该轨道上未击中且最接近判定线的音符
        var closestNote: (index: Int, note: FallingNote, distance: Double)?
        
        for (index, note) in fallingNotes.enumerated() {
            // 检查音符是否在对应的轨道上（使用mod 7映射）
            guard note.noteIndex % 7 == trackIndex && !note.isHit else { continue }
            
            let distance = abs(currentTime - note.targetTime)
            
            if let closest = closestNote {
                if distance < closest.distance {
                    closestNote = (index, note, distance)
                }
            } else {
                closestNote = (index, note, distance)
            }
        }
        
        guard let (index, note, distance) = closestNote else { return }
        
        // 判定
        let judgement: JudgementResult
        let window = gameMode.judgementWindow
        
        if distance <= window.perfect {
            judgement = .perfect
        } else if distance <= window.good {
            judgement = .good
        } else if distance <= window.miss {
            judgement = .miss
        } else {
            return  // 超出判定范围
        }
        
        // 更新音符状态
        var updatedNote = note
        updatedNote.isHit = true
        updatedNote.judgement = judgement
        fallingNotes[index] = updatedNote
        
        // 播放击中特效
        if let noteNode = noteNodes[note.id] {
            playHitEffect(at: noteNode.position, judgement: judgement, color: note.color)
            
            // Perfect判定时触发美化判定线特效
            if judgement == .perfect {
                optimizedJudgementLine?.showPerfectEffect()
            }
            
            noteNode.explode()
            noteNodes.removeValue(forKey: note.id)
        }
        
        // 触发回调
        onNoteHit?(note.id, judgement)
    }
    
    // MARK: - 特效系统
    
    /// 播放击中特效
    private func playHitEffect(at position: CGPoint, judgement: JudgementResult, color: Color) {
        // 粒子爆炸
        let particleCount = judgement == .perfect ? 30 : 20
        
        for _ in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            particle.fillColor = UIColor(color)
            particle.strokeColor = .clear
            particle.position = position
            particle.zPosition = 20
            addChild(particle)
            
            // 随机方向和速度
            let angle = CGFloat.random(in: 0...2 * .pi)
            let speed = CGFloat.random(in: 100...300)
            let dx = cos(angle) * speed
            let dy = sin(angle) * speed
            
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.5)
            let fadeAction = SKAction.fadeOut(withDuration: 0.5)
            let scaleAction = SKAction.scale(to: 0, duration: 0.5)
            let group = SKAction.group([moveAction, fadeAction, scaleAction])
            
            particle.run(SKAction.sequence([group, SKAction.removeFromParent()]))
        }
        
        // 冲击波
        let shockwave = SKShapeNode(circleOfRadius: 40)
        shockwave.strokeColor = UIColor(judgement.color)
        shockwave.lineWidth = 4
        shockwave.fillColor = .clear
        shockwave.position = position
        shockwave.zPosition = 15
        addChild(shockwave)
        
        let scaleAction = SKAction.scale(to: 3, duration: 0.4)
        let fadeAction = SKAction.fadeOut(withDuration: 0.4)
        shockwave.run(SKAction.sequence([
            SKAction.group([scaleAction, fadeAction]),
            SKAction.removeFromParent()
        ]))
    }
    
    /// 激活Fever特效
    func activateFeverEffect() {
        // 屏幕闪光
        let flashNode = SKShapeNode(rectOf: size)
        flashNode.fillColor = .yellow
        flashNode.strokeColor = .clear
        flashNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flashNode.zPosition = 100
        flashNode.alpha = 0.6
        addChild(flashNode)
        
        flashNode.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
        
        // 粒子雨
        let emitter = createFeverParticleEmitter()
        emitter.position = CGPoint(x: size.width / 2, y: size.height)
        emitter.zPosition = 50
        addChild(emitter)
        
        emitter.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ]))
    }
    
    /// 创建Fever粒子发射器
    private func createFeverParticleEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleBirthRate = 100
        emitter.numParticlesToEmit = 200
        emitter.particleLifetime = 2.0
        emitter.particleSpeed = 200
        emitter.particleSpeedRange = 100
        emitter.emissionAngle = -.pi / 2
        emitter.emissionAngleRange = .pi / 4
        emitter.particleColor = .yellow
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlpha = 0.8
        emitter.particleAlphaSpeed = -0.4
        emitter.particleScale = 0.3
        emitter.particleScaleSpeed = -0.1
        return emitter
    }
}

// MARK: - 音符节点
class NoteNode: SKShapeNode {
    var noteId: UUID?
    private let noteType: NoteType
    private let noteColor: UIColor
    
    init(noteType: NoteType, color: UIColor, size: CGSize) {
        self.noteType = noteType
        self.noteColor = color
        super.init()
        
        setupAppearance(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAppearance(size: CGSize) {
        let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)
        let cornerRadius: CGFloat = 8
        path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        
        // 美化音符主体 - 渐变效果
        fillColor = noteColor.withAlphaComponent(0.9)
        strokeColor = noteColor.withAlphaComponent(0.6)
        lineWidth = 3
        
        // 添加发光效果
        if let notePath = path {
            glowNode = SKShapeNode(path: notePath)
            glowNode?.fillColor = .clear
            glowNode?.strokeColor = noteColor.withAlphaComponent(0.3)
            glowNode?.lineWidth = 6
            glowNode?.glowWidth = 10
            if let glow = glowNode {
                addChild(glow)
            }
        }
        
        // 根据类型添加标记
        switch noteType {
        case .normal:
            break
        case .hold:
            addHoldIndicator()
        case .slide:
            addSlideIndicator()
        }
        
        // 添加呼吸动画
        addBreathingAnimation()
    }
    
    private var glowNode: SKShapeNode?
    
    private func addBreathingAnimation() {
        let breathe = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])
        let breatheForever = SKAction.repeatForever(breathe)
        run(breatheForever)
    }
    
    /// 设置音符的简谱标记
    func setNotation(_ notation: String) {
        // 处理高音标记（小黑点在数字上方）
        let hasHighNote = notation.contains("̇")
        let baseNotation = hasHighNote ? String(notation.dropLast()) : notation
        
        // 如果是高音，先添加小黑点
        if hasHighNote {
            let dotLabel = SKLabelNode(text: "˙")
            dotLabel.fontSize = 12
            dotLabel.fontName = "Helvetica-Bold"
            dotLabel.fontColor = .white.withAlphaComponent(0.9)
            dotLabel.verticalAlignmentMode = .center
            dotLabel.horizontalAlignmentMode = .center
            dotLabel.position = CGPoint(x: 0, y: 8)  // 小黑点在上方
            dotLabel.zPosition = 2
            
            // 小黑点的描边
            let dotStrokeLabel = SKLabelNode(text: "˙")
            dotStrokeLabel.fontSize = 12
            dotStrokeLabel.fontName = "Helvetica-Bold"
            dotStrokeLabel.fontColor = .black.withAlphaComponent(0.5)
            dotStrokeLabel.verticalAlignmentMode = .center
            dotStrokeLabel.horizontalAlignmentMode = .center
            dotStrokeLabel.position = CGPoint(x: 0, y: 8)
            dotStrokeLabel.zPosition = 1
            
            addChild(dotStrokeLabel)
            addChild(dotLabel)
        }
        
        // 添加数字标记
        let label = SKLabelNode(text: baseNotation)
        label.fontSize = 20
        label.fontName = "Helvetica-Bold"
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: hasHighNote ? -2 : 0)  // 高音数字稍微下移
        label.zPosition = 2
        
        // 添加黑色描边效果，使数字更醒目
        let strokeLabel = SKLabelNode(text: baseNotation)
        strokeLabel.fontSize = 20
        strokeLabel.fontName = "Helvetica-Bold"
        strokeLabel.fontColor = .black
        strokeLabel.verticalAlignmentMode = .center
        strokeLabel.horizontalAlignmentMode = .center
        strokeLabel.position = CGPoint(x: 0, y: hasHighNote ? -2 : 0)
        strokeLabel.zPosition = 1
        strokeLabel.alpha = 0.5
        
        addChild(strokeLabel)
        addChild(label)
    }
    
    private func addHoldIndicator() {
        let indicator = SKLabelNode(text: "◉")
        indicator.fontSize = 20
        indicator.fontColor = .white
        indicator.verticalAlignmentMode = .center
        addChild(indicator)
    }
    
    private func addSlideIndicator() {
        let indicator = SKLabelNode(text: "→")
        indicator.fontSize = 20
        indicator.fontColor = .white
        indicator.verticalAlignmentMode = .center
        addChild(indicator)
    }
    
    /// 爆炸动画
    func explode() {
        let scaleAction = SKAction.scale(to: 1.5, duration: 0.1)
        let fadeAction = SKAction.fadeOut(withDuration: 0.1)
        run(SKAction.group([scaleAction, fadeAction])) { [weak self] in
            self?.removeFromParent()
        }
    }
    
    /// 淡出动画
    func fadeOut() {
        run(SKAction.fadeOut(withDuration: 0.2)) { [weak self] in
            self?.removeFromParent()
        }
    }
}