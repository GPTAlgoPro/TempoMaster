import SwiftUI

/// 排行榜和成就视图
struct LeaderboardView: View {
    @StateObject private var gameState = GameStateManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTab = 0
    @State private var showClearAlert = false
    @State private var clearAlertMessage = ""
    @State private var pendingClearAction: ClearAction?
    
    private enum ClearAction {
        case records
        case achievements
        case all
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                LinearGradient(
                    colors: [.black, .purple.opacity(0.2), .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 分段选择器
                    Picker("", selection: $selectedTab) {
                        Text("排行榜").tag(0)
                        Text("成就").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // 内容区域
                    TabView(selection: $selectedTab) {
                        leaderboardTab
                            .tag(0)
                        
                        achievementsTab
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("记录与成就")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        if selectedTab == 0 && !gameState.gameRecords.isEmpty {
                            Button(role: .destructive, action: {
                                clearAllRecordsAlert()
                            }) {
                                Label("清除所有记录", systemImage: "trash.fill")
                            }
                        }
                        
                        if selectedTab == 1 && gameState.unlockedAchievementsCount > 0 {
                            Button(role: .destructive, action: {
                                resetAchievementsAlert()
                            }) {
                                Label("重置所有成就", systemImage: "arrow.counterclockwise")
                            }
                        }
                        
                        if selectedTab == 0 && !gameState.gameRecords.isEmpty || 
                           selectedTab == 1 && gameState.unlockedAchievementsCount > 0 {
                            Button(role: .destructive, action: {
                                clearAllDataAlert()
                            }) {
                                Label("清除所有数据", systemImage: "xmark.circle.fill")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .alert("确认清除", isPresented: $showClearAlert) {
                Button("取消", role: .cancel) { }
                Button("确认", role: .destructive) {
                    executeClearAction()
                }
            } message: {
                Text(clearAlertMessage)
            }
        }
    }
    
    // MARK: - 排行榜标签页
    private var leaderboardTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 统计卡片
                statsCard
                
                // 排行榜列表
                if gameState.gameRecords.isEmpty {
                    emptyStateView(
                        icon: "trophy.fill",
                        title: "暂无记录",
                        message: "开始游戏来创建你的第一条记录吧！"
                    )
                    .padding(.top, 60)
                } else {
                    VStack(spacing: 12) {
                        ForEach(Array(gameState.getLeaderboard(limit: 50).enumerated()), id: \.element.id) { index, record in
                            HStack(spacing: 0) {
                                recordRow(record: record, rank: index + 1)
                                
                                // 删除单条记录按钮
                                Button(action: {
                                    deleteRecord(record)
                                }) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.red)
                                        .frame(width: 40)
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white.opacity(0.05))
                            )
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - 成就标签页
    private var achievementsTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 成就进度卡片
                achievementProgressCard
                
                // 成就列表
                VStack(spacing: 12) {
                    ForEach(gameState.achievements) { achievement in
                        achievementRow(achievement)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - 统计卡片
    private var statsCard: some View {
        HStack(spacing: 20) {
            statColumn(
                icon: "gamecontroller.fill",
                color: .cyan,
                title: "游戏次数",
                value: "\(gameState.gameRecords.count)"
            )
            
            Divider()
                .background(.white.opacity(0.2))
            
            statColumn(
                icon: "star.fill",
                color: .yellow,
                title: "最高分",
                value: "\(gameState.gameRecords.map { $0.score }.max() ?? 0)"
            )
            
            Divider()
                .background(.white.opacity(0.2))
            
            statColumn(
                icon: "bolt.fill",
                color: .orange,
                title: "最大连击",
                value: "\(gameState.gameRecords.map { $0.maxCombo }.max() ?? 0)"
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    @ViewBuilder
    private func statColumn(icon: String, color: Color, title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - 成就进度卡片
    private var achievementProgressCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.yellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("成就完成度")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("\(gameState.unlockedAchievementsCount) / \(gameState.achievements.count)")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Spacer()
                
                Text(String(format: "%.0f%%", gameState.achievementProgress * 100))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.yellow)
            }
            
            ProgressView(value: gameState.achievementProgress)
                .tint(.yellow)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - 记录行
    @ViewBuilder
    private func recordRow(record: GameRecord, rank: Int) -> some View {
        HStack(spacing: 16) {
            // 排名
            ZStack {
                Circle()
                    .fill(rankColor(for: rank).opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text("\(rank)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(rankColor(for: rank))
            }
            
            // 歌曲信息
            VStack(alignment: .leading, spacing: 4) {
                Text(record.songName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                
                HStack(spacing: 8) {
                    Text(record.mode.rawValue)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.cyan)
                    
                    Text("•")
                        .foregroundStyle(.white.opacity(0.3))
                    
                    Text(formatDate(record.timestamp))
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            // 评级和分数
            VStack(alignment: .trailing, spacing: 4) {
                Text(record.rank)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(record.rankColor)
                
                Text("\(record.score)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(rankColor(for: rank).opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - 成就行
    @ViewBuilder
    private func achievementRow(_ achievement: Achievement) -> some View {
        HStack(spacing: 16) {
            // 图标
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(achievement.isUnlocked ? .yellow : .gray)
            }
            
            // 信息
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(achievement.isUnlocked ? .white : .white.opacity(0.5))
                
                Text(achievement.description)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                
                // 进度条（未解锁时显示）
                if !achievement.isUnlocked {
                    ProgressView(value: achievement.progress)
                        .tint(.cyan)
                        .scaleEffect(x: 1, y: 0.5)
                }
            }
            
            Spacer()
            
            // 解锁状态
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.green)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(achievement.isUnlocked ? Color.yellow.opacity(0.1) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(achievement.isUnlocked ? Color.yellow.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - 空状态视图
    @ViewBuilder
    private func emptyStateView(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60, weight: .bold))
                .foregroundStyle(.white.opacity(0.3))
            
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text(message)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - 辅助方法
    
    private func rankColor(for rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .cyan
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: date)
    }
    
    // MARK: - 删除操作
    private func deleteRecord(_ record: GameRecord) {
        gameState.deleteGameRecord(record)
    }
    
    // MARK: - 清除功能
    
    private func clearAllRecordsAlert() {
        clearAlertMessage = "确定要清除所有游戏记录吗？此操作不可撤销。"
        pendingClearAction = .records
        showClearAlert = true
    }
    
    private func resetAchievementsAlert() {
        clearAlertMessage = "确定要重置所有成就吗？此操作不可撤销。"
        pendingClearAction = .achievements
        showClearAlert = true
    }
    
    private func clearAllDataAlert() {
        clearAlertMessage = "确定要清除所有数据吗？包括游戏记录和成就，此操作不可撤销。"
        pendingClearAction = .all
        showClearAlert = true
    }
    
    private func executeClearAction() {
        guard let action = pendingClearAction else { return }
        
        switch action {
        case .records:
            gameState.clearGameRecords()
        case .achievements:
            gameState.resetAchievements()
        case .all:
            gameState.clearAllData()
        }
        
        pendingClearAction = nil
    }
}