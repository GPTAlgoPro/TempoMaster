import SwiftUI

/// 优化的皮肤设置视图
struct OptimizedSkinSettingsView: View {
    @Binding var isPresented: Bool
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var localization = LocalizationManager.shared
    @State private var selectedColorScheme: ThemeManager.ColorPalette
    @State private var randomColorScheme: ThemeManager.ColorPalette = .random
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._selectedColorScheme = State(initialValue: ThemeManager.shared.currentColorScheme)
        self._randomColorScheme = State(initialValue: .random)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            header
            
            ScrollView {
                VStack(spacing: 24) {
                    // 配色方案选择
                    colorSchemeSection
                    
                    // 预览区域
                    previewSection
                }
                .padding(20)
            }
            
            // 底部操作按钮
            footer
        }
        .frame(width: 360, height: 580)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    themeManager.colors.primary.opacity(0.4),
                                    themeManager.colors.secondary.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 24, x: 0, y: 12)
    }
    
    // MARK: - 组件
    
    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(themeManager.colors.primary)
            
            Text(localization.localized("skin.title"))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Spacer()
            
            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    themeManager.colors.primary.opacity(0.2),
                    themeManager.colors.secondary.opacity(0.1)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    
    private var colorSchemeSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "paintbrush.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(themeManager.colors.primary)
                
                Text(localization.localized("skin.color.scheme"))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                ForEach(ThemeManager.ColorPalette.allCases) { scheme in
                    ColorSchemeCard(
                        scheme: scheme,
                        isSelected: selectedColorScheme == scheme,
                        action: {
                            withAnimation(.spring(response: 0.3)) {
                                if scheme == .random {
                                    randomColorScheme = .random // 强制刷新随机配色
                                    selectedColorScheme = randomColorScheme
                                } else {
                                    selectedColorScheme = scheme
                                }
                            }
                        }
                    )
                }
            }
        }
    }
    
    private var previewSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "eye.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(themeManager.colors.primary)
                
                Text(localization.localized("skin.preview.title"))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
            }
            
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: previewGradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 120)
                .overlay(
                    VStack(spacing: 12) {
                        Text(localization.localized("skin.preview.text"))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        HStack(spacing: 12) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(Color.white.opacity(0.3 + Double(index) * 0.2))
                                    .frame(width: 32, height: 32)
                            }
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                )
        }
    }
    
    private var footer: some View {
        VStack(spacing: 12) {
            Button {
                applySettings()
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                    Text(localization.localized("skin.apply.button"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Spacer()
                }
                .foregroundStyle(.white)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        colors: [
                            selectedColorScheme.colors.primary,
                            selectedColorScheme.colors.secondary
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .cornerRadius(16)
                )
            }
        }
        .padding(20)
    }
    
    // MARK: - 辅助方法
    
    private var previewGradient: [Color] {
        let userInterfaceStyle = UITraitCollection.current.userInterfaceStyle
        let isDark = userInterfaceStyle == .dark
        let opacity: Double = isDark ? 0.4 : 0.25
        return selectedColorScheme.colors.gradient.map { $0.opacity(opacity) }
    }
    
    private func applySettings() {
        themeManager.currentColorScheme = selectedColorScheme == .random ? randomColorScheme : selectedColorScheme
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        isPresented = false
    }
}


/// 配色方案卡片
struct ColorSchemeCard: View {
    let scheme: ThemeManager.ColorPalette
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: scheme.colors.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.white : Color.white.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                    )
                
                Text(scheme.localizedName)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }
}