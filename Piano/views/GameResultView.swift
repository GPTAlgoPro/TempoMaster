import SwiftUI

/// 游戏结算界面
struct GameResultView: View {
    let record: GameRecord
    let onRestart: () -> Void
    let onExit: () -> Void
    
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var localization = LocalizationManager.shared
    @State private var showStats = false
    @State private var showRank = false
    
    var body: some View {
        ZStack {
            // 主题配色背景层 - 使用磨砂玻璃效果
            ZStack {
                // 底层渐变色 - 融合主题色与评级色
                LinearGradient(
                    colors: [
                        themeManager.colors.gradient[0].opacity(0.3),
                        record.rankColor.opacity(0.2),
                        themeManager.colors.gradient[1].opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 磨砂玻璃效果层
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
            }
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 40)
                    
                    // 评级展示
                    rankSection
                    
                    // 统计数据
                    statsSection
                    
                    // 详细信息
                    detailsSection
                    
                    // 按钮
                    buttonsSection
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            animateAppearance()
        }
    }
    
    // MARK: - 评级区域
    private var rankSection: some View {
        VStack(spacing: 16) {
            Text(localization.localized("game.result.title"))
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
            
            // 评级
            Text(record.rank)
                .font(.system(size: 80, weight: .heavy, design: .rounded))
                .foregroundStyle(record.rankColor)
                .shadow(color: record.rankColor.opacity(0.6), radius: 20)
                .scaleEffect(showRank ? 1.0 : 0.5)
                .opacity(showRank ? 1.0 : 0.0)
            
            // 歌曲名称
            Text(record.songName)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            // 难度
            Text(record.mode.localizedName)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.cyan)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.cyan.opacity(0.2))
                        .overlay(
                            Capsule()
                                .stroke(.cyan, lineWidth: 1)
                        )
                )
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - 统计区域
    private var statsSection: some View {
        VStack(spacing: 16) {
            // 分数
            statRow(
                icon: "star.fill",
                color: .yellow,
                title: localization.localized("game.result.total.score"),
                value: "\(record.score)"
            )
            
            Divider()
                .background(.white.opacity(0.2))
            
            // 准确率
            statRow(
                icon: "target",
                color: .green,
                title: localization.localized("game.result.accuracy.rate"),
                value: String(format: "%.1f%%", record.accuracy * 100)
            )
            
            Divider()
                .background(.white.opacity(0.2))
            
            // 最大连击
            statRow(
                icon: "bolt.fill",
                color: .orange,
                title: localization.localized("game.result.max.combo"),
                value: "\(record.maxCombo)"
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
        .opacity(showStats ? 1.0 : 0.0)
        .offset(y: showStats ? 0 : 20)
    }
    
    // MARK: - 详细信息区域
    private var detailsSection: some View {
        VStack(spacing: 16) {
            Text(localization.localized("game.result.judgement.title"))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                judgementCard(
                    result: .perfect,
                    count: record.perfectCount,
                    total: record.perfectCount + record.goodCount + record.missCount
                )
                
                judgementCard(
                    result: .good,
                    count: record.goodCount,
                    total: record.perfectCount + record.goodCount + record.missCount
                )
                
                judgementCard(
                    result: .miss,
                    count: record.missCount,
                    total: record.perfectCount + record.goodCount + record.missCount
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
        .opacity(showStats ? 1.0 : 0.0)
        .offset(y: showStats ? 0 : 20)
    }
    
    // MARK: - 按钮区域
    private var buttonsSection: some View {
        VStack(spacing: 12) {
            Button(action: onRestart) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: 24)
                    
                    Text(localization.localized("game.result.play.again"))
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .frame(minHeight: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.cyan.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.cyan, lineWidth: 2)
                        )
                )
            }
            .buttonStyle(.plain)
            
            Button(action: onExit) {
                HStack(spacing: 12) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: 24)
                    
                    Text(localization.localized("game.result.back.to.menu"))
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .frame(minHeight: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.3), lineWidth: 2)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - 辅助组件
    
    @ViewBuilder
    private func statRow(icon: String, color: Color, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 40)
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
    
    @ViewBuilder
    private func judgementCard(result: JudgementResult, count: Int, total: Int) -> some View {
        VStack(spacing: 8) {
            Text(result.displayText)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(result.color)
            
            Text("\(count)")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            
            // 百分比
            if total > 0 {
                Text(String(format: "%.1f%%", Double(count) / Double(total) * 100))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(result.color.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(result.color, lineWidth: 1)
                )
        )
    }
    
    // MARK: - 动画
    
    private func animateAppearance() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
            showRank = true
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5)) {
            showStats = true
        }
    }
}