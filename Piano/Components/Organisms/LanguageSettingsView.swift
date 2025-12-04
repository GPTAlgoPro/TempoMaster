import SwiftUI

/// 语言设置视图
struct LanguageSettingsView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // 背景遮罩
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }
            
            // 主内容
            VStack(spacing: 0) {
                // 标题栏
                headerView
                
                // 语言选项列表
                languageList
                
                // 关闭按钮
                closeButton
            }
            .frame(width: 320)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(themeManager.colors.primary.opacity(0.3), lineWidth: 1.5)
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
    
    // MARK: - 子视图
    
    private var headerView: some View {
        HStack(spacing: 12) {
            Image(systemName: "globe")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(themeManager.colors.primary)
            
            Text("language.setting".localized)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.5)
        )
    }
    
    private var languageList: some View {
        VStack(spacing: 0) {
            ForEach(LocalizationManager.Language.allCases, id: \.self) { language in
                languageRow(for: language)
                
                if language != LocalizationManager.Language.allCases.last {
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.horizontal, 20)
                }
            }
        }
        .padding(.vertical, 16)
    }
    
    private func languageRow(for language: LocalizationManager.Language) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                localizationManager.currentLanguage = language
            }
        }) {
            HStack(spacing: 16) {
                // 图标
                if language.icon.count == 1 {
                    Text(language.icon)
                        .font(.system(size: 32))
                } else {
                    Image(systemName: language.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(themeManager.colors.primary)
                }
                
                // 语言名称
                Text(language.displayName)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
                
                // 选中标记
                if localizationManager.currentLanguage == language {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(themeManager.colors.primary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(localizationManager.currentLanguage == language ? 
                          themeManager.colors.primary.opacity(0.15) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var closeButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isPresented = false
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                Text("close".localized)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.colors.secondary.opacity(0.3))
            )
        }
        .padding(20)
    }
}