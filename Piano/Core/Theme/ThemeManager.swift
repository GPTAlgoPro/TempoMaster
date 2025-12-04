import SwiftUI
import Combine

/// 主题管理器 - 优化版
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme = .dark
    @Published var currentColorScheme: ColorPalette = .classic
    
    // 游戏模式标志 - 用于禁用随机配色的自动刷新
    @Published var isInGameMode: Bool = false
    
    // 缓存的随机颜色 - 避免游戏模式下频繁变化
    private var cachedRandomColors: ThemeColors?
    
    enum AppTheme: String, CaseIterable {
        case dark = "深色"
        case light = "浅色"
        case auto = "自动"
    }
    
enum ColorPalette: String, CaseIterable, Identifiable {
        case classic = "经典紫粉"
        case ocean = "海洋蓝"
        case sunset = "日落橙"
        case forest = "森林绿"
        case ruby = "宝石红"
        case random = "随机配色"
        
        var id: String { rawValue }
        
        var localizedName: String {
            switch self {
            case .classic: return "theme.classic".localized
            case .ocean: return "theme.ocean".localized
            case .sunset: return "theme.sunset".localized
            case .forest: return "theme.forest".localized
            case .ruby: return "theme.ruby".localized
            case .random: return "theme.random".localized
            }
        }
        
        var colors: ThemeColors {
            switch self {
            case .classic:
                return ThemeColors(
                    primary: .purple,
                    secondary: .pink,
                    accent: .blue,
                    gradient: [.purple, .pink, .blue]
                )
            case .ocean:
                return ThemeColors(
                    primary: .blue,
                    secondary: .cyan,
                    accent: .indigo,
                    gradient: [.blue, .cyan, .indigo]
                )
            case .sunset:
                return ThemeColors(
                    primary: .orange,
                    secondary: .red,
                    accent: .purple,
                    gradient: [.orange, .red, .purple]
                )
            case .forest:
                return ThemeColors(
                    primary: .green,
                    secondary: .teal,
                    accent: .mint,
                    gradient: [.green, .teal, .mint]
                )
            case .ruby:
                return ThemeColors(
                    primary: .red,
                    secondary: .pink,
                    accent: .purple,
                    gradient: [.red, .pink, .purple]
                )
            case .random:
                let hue1 = Double.random(in: 0..<1)
                let hue2 = (hue1 + Double.random(in: 0.2...0.4)).truncatingRemainder(dividingBy: 1)
                let hue3 = (hue2 + Double.random(in: 0.2...0.4)).truncatingRemainder(dividingBy: 1)
                
                return ThemeColors(
                    primary: Color(hue: hue1, saturation: 0.8, brightness: 0.9),
                    secondary: Color(hue: hue2, saturation: 0.7, brightness: 0.8),
                    accent: Color(hue: hue3, saturation: 0.9, brightness: 0.7),
                    gradient: [
                        Color(hue: hue1, saturation: 0.8, brightness: 0.9),
                        Color(hue: hue2, saturation: 0.7, brightness: 0.8),
                        Color(hue: hue3, saturation: 0.9, brightness: 0.7)
                    ]
                )
            }
        }
    }
    
    private init() {}
    
    var isDarkMode: Bool {
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
    
    var colors: ThemeColors {
        // 如果是随机配色且在游戏模式下，使用缓存的颜色
        if currentColorScheme == .random && isInGameMode {
            if let cached = cachedRandomColors {
                return cached
            }
        }
        
        let newColors = currentColorScheme.colors
        
        // 如果是随机配色，缓存生成的颜色
        if currentColorScheme == .random {
            cachedRandomColors = newColors
        }
        
        return newColors
    }
    
    /// 进入游戏模式 - 锁定随机配色
    func enterGameMode() {
        isInGameMode = true
        // 如果当前是随机配色，立即缓存一个颜色方案
        if currentColorScheme == .random {
            cachedRandomColors = currentColorScheme.colors
        }
    }
    
    /// 退出游戏模式 - 解锁随机配色
    func exitGameMode() {
        isInGameMode = false
        // 清除缓存，允许随机配色再次变化
        cachedRandomColors = nil
    }
    
    /// 手动刷新随机配色（用于非游戏模式下的主动刷新）
    func refreshRandomColors() {
        if currentColorScheme == .random && !isInGameMode {
            cachedRandomColors = nil
            objectWillChange.send()
        }
    }
    
    func backgroundGradient(isDark: Bool? = nil) -> [Color] {
        let userInterfaceStyle = UITraitCollection.current.userInterfaceStyle
        let dark = isDark ?? (userInterfaceStyle == .dark)
        let opacity: Double = dark ? 0.35 : 0.2
        return colors.gradient.map { $0.opacity(opacity) }
    }
}

/// 主题颜色集合
struct ThemeColors {
    let primary: Color
    let secondary: Color
    let accent: Color
    let gradient: [Color]
    
    func backgroundGradient(isDark: Bool) -> LinearGradient {
        let opacity: Double = isDark ? 0.35 : 0.2
        return LinearGradient(
            colors: gradient.map { $0.opacity(opacity) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}