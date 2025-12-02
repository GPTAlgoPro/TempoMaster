import SwiftUI
import Combine

/// 游戏状态管理器 - 管理游戏的整体状态和数据持久化
final class GameStateManager: ObservableObject {
    static let shared = GameStateManager()
    
    // MARK: - 游戏状态
    @Published var currentMode: GameMode = .normal
    @Published var isPlaying = false
    @Published var isPaused = false
    @Published var selectedSong: Song?
    
    // MARK: - 游戏数据
    @Published var currentScore = 0
    @Published var currentCombo = 0
    @Published var maxCombo = 0
    @Published var perfectCount = 0
    @Published var goodCount = 0
    @Published var missCount = 0
    
    // MARK: - 历史记录
    @Published var gameRecords: [GameRecord] = []
    @Published var achievements: [Achievement] = Achievement.allAchievements
    @Published var customSongs: [CustomSong] = []
    
    // MARK: - 持久化键
    private let recordsKey = "game_records"
    private let achievementsKey = "game_achievements"
    private let customSongsKey = "custom_songs"
    
    private init() {
        loadData()
    }
    
    // MARK: - 游戏控制
    
    /// 开始新游戏
    func startGame(song: Song, mode: GameMode) {
        selectedSong = song
        currentMode = mode
        resetGameData()
        isPlaying = true
        isPaused = false
        print("🎮 游戏开始: \(song.name) - 难度: \(mode.rawValue)")
    }
    
    /// 暂停游戏
    func pauseGame() {
        isPaused = true
        print("⏸️ 游戏暂停")
    }
    
    /// 恢复游戏
    func resumeGame() {
        isPaused = false
        print("▶️ 游戏继续")
    }
    
    /// 结束游戏
    func endGame() {
        guard let song = selectedSong else { return }
        
        // 计算准确率
        let totalNotes = perfectCount + goodCount + missCount
        let accuracy = totalNotes > 0 ? Double(perfectCount + goodCount) / Double(totalNotes) : 0.0
        
        // 创建游戏记录
        let record = GameRecord(
            songName: song.name,
            mode: currentMode,
            score: currentScore,
            accuracy: accuracy,
            perfectCount: perfectCount,
            goodCount: goodCount,
            missCount: missCount,
            maxCombo: maxCombo,
            timestamp: Date()
        )
        
        // 保存记录
        gameRecords.insert(record, at: 0)
        saveData()
        
        // 检查成就
        checkAchievements(record: record)
        
        isPlaying = false
        isPaused = false
        print("🏁 游戏结束 - 得分: \(currentScore) - 评级: \(record.rank)")
        
        // 延迟0.5秒后触发自动进入结算界面的逻辑
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 这里通过 @Published 属性自动触发UI更新
            // GameMainView 会监听 gameRecords 的变化并自动切换到结算界面
            print("🎯 自动进入结算界面延迟触发")
        }
    }
    
    /// 退出游戏（不保存记录）
    func quitGame() {
        isPlaying = false
        isPaused = false
        resetGameData()
        print("🚪 退出游戏")
    }
    
    // MARK: - 判定处理
    
    /// 记录判定结果（支持Fever倍率）
    func recordJudgement(_ judgement: JudgementResult, feverMultiplier: Double = 1.0) {
        switch judgement {
        case .perfect:
            perfectCount += 1
            currentCombo += 1
            let baseScore = judgement.score + (currentCombo / 10 * 10) // 连击加分
            currentScore += Int(Double(baseScore) * feverMultiplier)
        case .good:
            goodCount += 1
            currentCombo += 1
            let baseScore = judgement.score + (currentCombo / 10 * 5)
            currentScore += Int(Double(baseScore) * feverMultiplier)
        case .miss:
            missCount += 1
            currentCombo = 0
        }
        
        // 更新最大连击
        if currentCombo > maxCombo {
            maxCombo = currentCombo
        }
    }
    
    /// 获取判定统计字典
    var judgementCounts: [JudgementResult: Int] {
        [
            .perfect: perfectCount,
            .good: goodCount,
            .miss: missCount
        ]
    }
    
    // MARK: - 数据管理
    
    /// 重置游戏数据
    private func resetGameData() {
        currentScore = 0
        currentCombo = 0
        maxCombo = 0
        perfectCount = 0
        goodCount = 0
        missCount = 0
    }
    
    /// 获取歌曲最佳记录
    func getBestRecord(for songName: String) -> GameRecord? {
        gameRecords
            .filter { $0.songName == songName }
            .sorted { $0.score > $1.score }
            .first
    }
    
    /// 获取排行榜（按分数排序）
    func getLeaderboard(limit: Int = 10) -> [GameRecord] {
        Array(gameRecords.sorted { $0.score > $1.score }.prefix(limit))
    }
    
    // MARK: - 自定义歌曲管理
    
    /// 添加自定义歌曲
    func addCustomSong(_ song: CustomSong) {
        customSongs.append(song)
        saveData()
        print("✅ 添加自定义歌曲: \(song.name)")
    }
    
    /// 删除自定义歌曲
    func deleteCustomSong(_ song: CustomSong) {
        customSongs.removeAll { $0.id == song.id }
        saveData()
        print("🗑️ 删除自定义歌曲: \(song.name)")
    }
    
    /// 更新自定义歌曲
    func updateCustomSong(_ song: CustomSong) {
        if let index = customSongs.firstIndex(where: { $0.id == song.id }) {
            customSongs[index] = song
            saveData()
            print("📝 更新自定义歌曲: \(song.name)")
        }
    }
    
    // MARK: - 成就系统
    
    /// 检查并解锁成就
    private func checkAchievements(record: GameRecord) {
        var newUnlocks: [Achievement] = []
        
        // 检查各项成就
        for i in 0..<achievements.count {
            var achievement = achievements[i]
            
            switch achievement.id {
            case "first_game":
                if achievement.checkUnlock(currentValue: gameRecords.count) {
                    newUnlocks.append(achievement)
                }
            case "perfect_10":
                if achievement.checkUnlock(currentValue: record.perfectCount >= 10 ? 1 : 0) {
                    newUnlocks.append(achievement)
                }
            case "combo_50":
                if achievement.checkUnlock(currentValue: record.maxCombo >= 50 ? 1 : 0) {
                    newUnlocks.append(achievement)
                }
            case "full_combo":
                if record.missCount == 0 && record.perfectCount + record.goodCount > 0 {
                    if achievement.checkUnlock(currentValue: 1) {
                        newUnlocks.append(achievement)
                    }
                }
            case "play_100":
                if achievement.checkUnlock(currentValue: gameRecords.count) {
                    newUnlocks.append(achievement)
                }
            case "expert_clear":
                if record.mode == .expert {
                    if achievement.checkUnlock(currentValue: 1) {
                        newUnlocks.append(achievement)
                    }
                }
            case "sss_rank":
                if record.rank == "SSS" {
                    if achievement.checkUnlock(currentValue: 1) {
                        newUnlocks.append(achievement)
                    }
                }
            default:
                break
            }
            
            achievements[i] = achievement
        }
        
        // 显示新解锁的成就
        for achievement in newUnlocks {
            print("🏆 解锁成就: \(achievement.title)")
        }
        
        saveData()
    }
    
    /// 获取已解锁成就数量
    var unlockedAchievementsCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    /// 获取成就完成度
    var achievementProgress: Double {
        let total = achievements.count
        let unlocked = unlockedAchievementsCount
        return total > 0 ? Double(unlocked) / Double(total) : 0.0
    }
    
    // MARK: - 数据持久化
    
    /// 加载数据
    private func loadData() {
        // 加载游戏记录
        if let data = UserDefaults.standard.data(forKey: recordsKey),
           let records = try? JSONDecoder().decode([GameRecord].self, from: data) {
            gameRecords = records
        }
        
        // 加载成就
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let loadedAchievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = loadedAchievements
        }
        
        // 加载自定义歌曲
        if let data = UserDefaults.standard.data(forKey: customSongsKey),
           let songs = try? JSONDecoder().decode([CustomSong].self, from: data) {
            customSongs = songs
        }
        
        print("✅ 数据加载完成 - 记录: \(gameRecords.count), 成就: \(unlockedAchievementsCount)/\(achievements.count), 自定义歌曲: \(customSongs.count)")
    }
    
    /// 保存数据
    private func saveData() {
        // 保存游戏记录（最多保留100条）
        let recordsToSave = Array(gameRecords.prefix(100))
        if let data = try? JSONEncoder().encode(recordsToSave) {
            UserDefaults.standard.set(data, forKey: recordsKey)
        }
        
        // 保存成就
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: achievementsKey)
        }
        
        // 保存自定义歌曲
        if let data = try? JSONEncoder().encode(customSongs) {
            UserDefaults.standard.set(data, forKey: customSongsKey)
        }
    }
    
    /// 清除所有数据（用于测试）
    func clearAllData() {
        gameRecords.removeAll()
        achievements = Achievement.allAchievements
        customSongs.removeAll()
        saveData()
        print("🗑️ 所有数据已清除")
    }
    
    /// 删除单个游戏记录
    func deleteGameRecord(_ record: GameRecord) {
        gameRecords.removeAll { $0.id == record.id }
        saveData()
        print("🗑️ 删除游戏记录: \(record.songName)")
    }
    
    /// 清除所有游戏记录
    func clearGameRecords() {
        gameRecords.removeAll()
        saveData()
        print("🗑️ 所有游戏记录已清除")
    }
    
    /// 重置所有成就
    func resetAchievements() {
        achievements = Achievement.allAchievements
        saveData()
        print("🗑️ 所有成就已重置")
    }
}