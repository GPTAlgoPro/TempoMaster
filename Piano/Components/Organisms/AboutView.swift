import SwiftUI

/// 重构后的关于页面视图 - 展示最新功能特性
struct AboutView: View {
    @Binding var isPresented: Bool
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var localization = LocalizationManager.shared
    @State private var selectedSection: AboutSection = .overview
    
    enum AboutSection: String, CaseIterable {
        case overview
        case features
        case game
        case developer
        
        var localizedTitle: String {
            switch self {
            case .overview: return "about.section.overview".localized
            case .features: return "about.section.features".localized
            case .game: return "about.section.game".localized
            case .developer: return "about.section.developer".localized
            }
        }
    }
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }
            
            // 主内容
            VStack(spacing: 0) {
                // 顶部装饰和导航
                topNavigation
                
                // 内容区域
                ScrollView {
                    VStack(spacing: 0) {
                        // App图标和基本信息
                        appHeader
                        
                        // 分段控制器
                        sectionSelector
                        
                        // 动态内容区域
                        dynamicContent
                        
                        // 底部按钮
                        closeButton
                    }
                    .padding(.vertical, 20)
                }
                .frame(height: 550)
            }
            .frame(width: 400, height: 700)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        themeManager.colors.primary.opacity(0.5),
                                        themeManager.colors.secondary.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
        }
        .transition(.scale(scale: 0.9).combined(with: .opacity))
    }
    
    // MARK: - 顶部导航
    private var topNavigation: some View {
        HStack(spacing: 12) {
            Image(systemName: "music.note")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(themeManager.colors.primary)
            
            Text("about.title".localized)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isPresented = false
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            LinearGradient(
                colors: [
                    themeManager.colors.primary.opacity(0.3),
                    themeManager.colors.secondary.opacity(0.2)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    // MARK: - App标题和图标
    private var appHeader: some View {
        VStack(spacing: 16) {
            // App图标
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                themeManager.colors.primary.opacity(0.3),
                                themeManager.colors.secondary.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                // 使用 SF Symbol 作为替代图标
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeManager.colors.primary,
                                    themeManager.colors.secondary
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "pianokeys.inverse")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.white)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: themeManager.colors.primary.opacity(0.4), radius: 15, x: 0, y: 8)
            }
            
            // App名称
            VStack(spacing: 8) {
                Text("app.name".localized)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("TempoMaster")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                
                Text("about.version.number".localized)
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - 分段选择器
    private var sectionSelector: some View {
        HStack(spacing: 0) {
            ForEach(AboutSection.allCases, id: \.self) { section in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedSection = section
                    }
                } label: {
                    Text(section.localizedTitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(selectedSection == section ? .white : .white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedSection == section ?
                            LinearGradient(
                                colors: [
                                    themeManager.colors.primary,
                                    themeManager.colors.secondary
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) : LinearGradient(
                                colors: [Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - 动态内容
    @ViewBuilder
    private var dynamicContent: some View {
        switch selectedSection {
        case .overview:
            overviewSection
        case .features:
            featuresSection
        case .game:
            gameModeSection
        case .developer:
            developerSection
        }
    }
    
    // MARK: - 总览部分
    private var overviewSection: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Text(localization.localized("about.overview.subtitle"))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(localization.localized("about.overview.description"))
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // 核心特性
            VStack(spacing: 12) {
                FeatureHighlight(
                    icon: "pianokeys",
                    title: localization.localized("about.feature.keyboard.title"),
                    description: localization.localized("about.feature.keyboard.description")
                )
                
                FeatureHighlight(
                    icon: "paintbrush.pointed",
                    title: localization.localized("about.feature.themes.title"),
                    description: localization.localized("about.feature.themes.description")
                )
                
                FeatureHighlight(
                    icon: "sparkles",
                    title: localization.localized("about.feature.effects.title"),
                    description: localization.localized("about.feature.effects.description")
                )
                
                FeatureHighlight(
                    icon: "gamecontroller",
                    title: localization.localized("about.feature.game.title"),
                    description: localization.localized("about.feature.game.description")
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }
    
    // MARK: - 功能部分
    private var featuresSection: some View {
        VStack(spacing: 16) {
            Text(localization.localized("about.features.title"))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            VStack(spacing: 12) {
                FeatureItem(
                    icon: "music.note.list",
                    title: localization.localized("about.features.songs.title"),
                    description: localization.localized("about.features.songs.description"),
                    color: .purple
                )
                
                FeatureItem(
                    icon: "speaker.wave.3",
                    title: localization.localized("about.features.volume.title"),
                    description: localization.localized("about.features.volume.description"),
                    color: .blue
                )
                
                FeatureItem(
                    icon: "waveform.path",
                    title: localization.localized("about.features.audio.title"),
                    description: localization.localized("about.features.audio.description"),
                    color: .orange
                )
                
                FeatureItem(
                    icon: "textformat.123",
                    title: localization.localized("about.features.notation.title"),
                    description: localization.localized("about.features.notation.description"),
                    color: .green
                )
                
//                FeatureItem(
//                    icon: "cpu",
//                    title: "性能优化",
//                    description: "三种性能模式，适配不同设备需求",
//                    color: .red
//                )
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - 游戏模式部分
    private var gameModeSection: some View {
        VStack(spacing: 16) {
            Text(localization.localized("about.game.title"))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            VStack(spacing: 12) {
                Text(localization.localized("about.game.name"))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(themeManager.colors.primary)
                
                Text(localization.localized("about.game.description.full"))
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                VStack(spacing: 8) {
                    GameFeatureRow(
                        icon: "speedometer",
                        title: localization.localized("about.game.difficulty.title"),
                        description: localization.localized("about.game.difficulty.description")
                    )
                    
                    GameFeatureRow(
                        icon: "trophy",
                        title: localization.localized("about.game.achievement.title"),
                        description: localization.localized("about.game.achievement.description")
                    )
                    
                    GameFeatureRow(
                        icon: "music.note.list",
                        title: localization.localized("about.game.editor.title"),
                        description: localization.localized("about.game.editor.description")
                    )
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(themeManager.colors.primary.opacity(0.3), lineWidth: 1.5)
                    )
            )
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - 开发者信息
    private var developerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "person.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(themeManager.colors.secondary)
                
                Text(localization.localized("about.developer.title"))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 14) {
                DeveloperInfoRow(
                    icon: "hammer.fill",
                    label: "开发者",
                    value: "孙凯",
                    color: .green
                )
                
                DeveloperInfoRow(
                    icon: "calendar",
                    label: "更新日期",
                    value: "2025年12月05日",
                    color: .orange
                )
                
                DeveloperInfoRow(
                    icon: "swift",
                    label: "技术栈",
                    value: "SwiftUI + AVFoundation + SpriteKit",
                    color: .red
                )
                
//                DeveloperInfoRow(
//                    icon: "checkmark.seal.fill",
//                    label: "版本特性",
//                    value: "游戏模式 + 性能优化",
//                    color: .blue
//                )
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(themeManager.colors.secondary.opacity(0.3), lineWidth: 1.5)
                    )
            )
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - 关闭按钮
    private var closeButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isPresented = false
            }
        } label: {
            HStack {
                Spacer()
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                Text("关闭")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                Spacer()
            }
            .foregroundStyle(.white)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [
                        themeManager.colors.primary.opacity(0.6),
                        themeManager.colors.secondary.opacity(0.5)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .cornerRadius(16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
}

// MARK: - 新增组件

/// 功能高亮项
struct FeatureHighlight: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

/// 功能项（用于功能页面）
struct FeatureItem: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // 图标
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
            }
            
            // 文字内容
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

/// 游戏特性行
struct GameFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            Spacer()
        }
    }
}

// MARK: - 开发者信息行
struct DeveloperInfoRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
                .frame(width: 28)
            
            Text(label)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            
            Spacer()
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.purple.opacity(0.3), .pink.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        AboutView(isPresented: .constant(true))
    }
}
