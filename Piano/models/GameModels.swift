import Foundation
import SwiftUI
import Combine

// MARK: - 游戏模式
enum GameMode: String, Codable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    case expert = "Expert"
    
    var localizedName: String {
        switch self {
        case .easy: return "game.mode.easy.name".localized
        case .normal: return "game.mode.normal.name".localized
        case .hard: return "game.mode.hard.name".localized
        case .expert: return "game.mode.expert.name".localized
        }
    }
    
    var fallSpeed: Double {
        switch self {
        case .easy: return 0.35     // 进一步降低速度
        case .normal: return 0.5    // 进一步降低速度
        case .hard: return 0.7      // 进一步降低速度
        case .expert: return 1.0    // 进一步降低速度
        }
    }
    
    var judgementWindow: JudgementWindow {
        switch self {
        case .easy: return JudgementWindow(perfect: 0.15, good: 0.25, miss: 0.40)     // 进一步放宽判定窗口
        case .normal: return JudgementWindow(perfect: 0.12, good: 0.22, miss: 0.35)  // 进一步放宽判定窗口
        case .hard: return JudgementWindow(perfect: 0.10, good: 0.18, miss: 0.30)    // 进一步放宽判定窗口
        case .expert: return JudgementWindow(perfect: 0.08, good: 0.15, miss: 0.25)  // 进一步放宽判定窗口
        }
    }
}

// MARK: - 判定窗口
struct JudgementWindow {
    let perfect: Double  // Perfect判定窗口（秒）
    let good: Double     // Good判定窗口（秒）
    let miss: Double     // Miss判定窗口（秒）
}

// MARK: - 判定结果
enum JudgementResult: String, Codable {
    case perfect = "Perfect"
    case good = "Good"
    case miss = "Miss"
    
    var score: Int {
        switch self {
        case .perfect: return 100
        case .good: return 50
        case .miss: return 0
        }
    }
    
    var color: Color {
        switch self {
        case .perfect: return .yellow
        case .good: return .green
        case .miss: return .red
        }
    }
    
    var displayText: String {
        rawValue
    }
}

// MARK: - 音符类型
enum NoteType {
    case normal      // 普通音符
    case hold        // 长按音符
    case slide       // 滑动音符
}

// MARK: - 下落音符
struct FallingNote: Identifiable {
    let id = UUID()
    let noteIndex: Int          // 音符索引（0-15）
    let targetTime: Double      // 目标击中时间（相对游戏开始）
    var currentY: CGFloat = 0   // 当前Y坐标
    var isHit: Bool = false     // 是否已击中
    var judgement: JudgementResult? // 判定结果
    
    // 新增属性
    let noteType: NoteType      // 音符类型
    let holdDuration: Double?   // 长按持续时间（仅hold类型）
    let slideEndIndex: Int?     // 滑动终点索引（仅slide类型）
    var isHolding: Bool = false // 是否正在长按
    var holdProgress: Double = 0 // 长按进度（0-1）
    
    init(
        noteIndex: Int,
        targetTime: Double,
        currentY: CGFloat = 0,
        noteType: NoteType = .normal,
        holdDuration: Double? = nil,
        slideEndIndex: Int? = nil
    ) {
        self.noteIndex = noteIndex
        self.targetTime = targetTime
        self.currentY = currentY
        self.noteType = noteType
        self.holdDuration = holdDuration
        self.slideEndIndex = slideEndIndex
    }
    
    /// 获取音符颜色
    var color: Color {
        let colors: [Color] = [
            .red, .orange, .yellow, .green,
            .cyan, .blue, .purple, .pink
        ]
        return colors[noteIndex % 8]
    }
    
    /// 获取音符名称
    var noteName: String {
        let names = ["Do", "Re", "Mi", "Fa", "Sol", "La", "Si", "Do²",
                    "Do", "Re", "Mi", "Fa", "Sol", "La", "Si", "Do"]
        return names[noteIndex]
    }
}

// MARK: - 游戏记录
struct GameRecord: Identifiable, Codable {
    let id: UUID
    let songName: String
    let mode: GameMode
    let score: Int
    let accuracy: Double        // 准确率（0-1）
    let perfectCount: Int
    let goodCount: Int
    let missCount: Int
    let maxCombo: Int
    let timestamp: Date
    
    init(id: UUID = UUID(), songName: String, mode: GameMode, score: Int,
         accuracy: Double, perfectCount: Int, goodCount: Int, missCount: Int,
         maxCombo: Int, timestamp: Date = Date()) {
        self.id = id
        self.songName = songName
        self.mode = mode
        self.score = score
        self.accuracy = accuracy
        self.perfectCount = perfectCount
        self.goodCount = goodCount
        self.missCount = missCount
        self.maxCombo = maxCombo
        self.timestamp = timestamp
    }
    
    /// 获取评级
    var rank: String {
        if accuracy >= 0.95 { return "SSS" }
        if accuracy >= 0.90 { return "SS" }
        if accuracy >= 0.85 { return "S" }
        if accuracy >= 0.80 { return "A" }
        if accuracy >= 0.70 { return "B" }
        if accuracy >= 0.60 { return "C" }
        return "D"
    }
    
    /// 获取评级颜色
    var rankColor: Color {
        switch rank {
        case "SSS": return .yellow
        case "SS": return .orange
        case "S": return .red
        case "A": return .purple
        case "B": return .blue
        case "C": return .green
        default: return .gray
        }
    }
}

// MARK: - 成就
struct Achievement: Identifiable, Codable {
    let id: String
    let titleKey: String        // 本地化键
    let descriptionKey: String  // 本地化键
    let icon: String
    var isUnlocked: Bool
    var progress: Double        // 0-1
    let requirement: Int        // 解锁要求
    
    // 动态获取本地化文本
    var title: String {
        titleKey.localized
    }
    
    var description: String {
        descriptionKey.localized
    }
    
    /// 检查是否满足解锁条件
    mutating func checkUnlock(currentValue: Int) -> Bool {
        progress = min(1.0, Double(currentValue) / Double(requirement))
        if progress >= 1.0 && !isUnlocked {
            isUnlocked = true
            return true
        }
        return false
    }
}

// MARK: - 预定义成就
extension Achievement {
    static let allAchievements: [Achievement] = [
        Achievement(id: "first_game", titleKey: "achievement.first_game.title", descriptionKey: "achievement.first_game.description", icon: "star.fill", isUnlocked: false, progress: 0, requirement: 1),
        Achievement(id: "perfect_10", titleKey: "achievement.perfect_10.title", descriptionKey: "achievement.perfect_10.description", icon: "flame.fill", isUnlocked: false, progress: 0, requirement: 10),
        Achievement(id: "combo_50", titleKey: "achievement.combo_50.title", descriptionKey: "achievement.combo_50.description", icon: "bolt.fill", isUnlocked: false, progress: 0, requirement: 50),
        Achievement(id: "full_combo", titleKey: "achievement.full_combo.title", descriptionKey: "achievement.full_combo.description", icon: "crown.fill", isUnlocked: false, progress: 0, requirement: 1),
        Achievement(id: "play_100", titleKey: "achievement.play_100.title", descriptionKey: "achievement.play_100.description", icon: "music.note", isUnlocked: false, progress: 0, requirement: 100),
        Achievement(id: "expert_clear", titleKey: "achievement.expert_clear.title", descriptionKey: "achievement.expert_clear.description", icon: "trophy.fill", isUnlocked: false, progress: 0, requirement: 1),
        Achievement(id: "sss_rank", titleKey: "achievement.sss_rank.title", descriptionKey: "achievement.sss_rank.description", icon: "sparkles", isUnlocked: false, progress: 0, requirement: 1)
    ]
}

// MARK: - Fever模式系统
class FeverMode: ObservableObject {
    @Published var energy: Double = 0           // 能量值（0-100）
    @Published var isActive: Bool = false       // 是否激活
    @Published var remainingTime: Double = 0    // 剩余时间
    
    private let maxEnergy: Double = 100
    private let feverDuration: Double = 10.0    // Fever持续10秒
    private var feverTimer: Timer?
    
    /// 增加能量（击中音符时调用）
    func addEnergy(for judgement: JudgementResult) {
        guard !isActive else { return }
        
        let energyGain: Double
        switch judgement {
        case .perfect: energyGain = 5.0
        case .good: energyGain = 2.0
        case .miss: energyGain = 0.0
        }
        
        energy = min(maxEnergy, energy + energyGain)
        
        // 检查是否可以激活
        if energy >= maxEnergy {
            energy = maxEnergy
        }
    }
    
    /// 激活Fever模式
    func activate() {
        guard energy >= maxEnergy && !isActive else { return }
        
        isActive = true
        remainingTime = feverDuration
        energy = 0
        
        // 启动倒计时
        feverTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.remainingTime -= 0.1
            if self.remainingTime <= 0 {
                self.deactivate()
            }
        }
    }
    
    /// 取消激活
    func deactivate() {
        isActive = false
        remainingTime = 0
        feverTimer?.invalidate()
        feverTimer = nil
    }
    
    /// 重置
    func reset() {
        energy = 0
        deactivate()
    }
    
    /// 获取分数倍率
    var scoreMultiplier: Double {
        isActive ? 2.0 : 1.0
    }
    
    /// 获取能量百分比
    var energyPercentage: Double {
        energy / maxEnergy
    }
}

// MARK: - 自定义歌曲
struct CustomSong: Identifiable, Codable {
    let id: UUID
    var name: String
    var sheetMusic: String      // 简谱文本
    var bpm: Int
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, sheetMusic: String, bpm: Int, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.sheetMusic = sheetMusic
        self.bpm = bpm
        self.createdAt = createdAt
    }
    
    /// 解析简谱生成Song对象
    func toSong() -> Song? {
        SheetMusicParser.parse(sheetMusic: sheetMusic, name: name, bpm: bpm)
    }
}