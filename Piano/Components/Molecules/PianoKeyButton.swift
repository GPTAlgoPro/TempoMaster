import SwiftUI

/// 优化的琴键按钮 - 分子组件 - 完全自适应尺寸
struct PianoKeyButton: View {
    let note: Note
    let isPlaying: Bool
    let showNotation: Bool
    let action: () -> Void
    let keySize: PianoKeySize  // 新增：由父组件传入的尺寸配置
    
    @State private var isPressed = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: {
            // 增强触觉反馈
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            action()
        }) {
            VStack(spacing: keySize.verticalSpacing) {
                // 音符图标
                Image(systemName: note.icon)
                    .font(.system(size: keySize.iconSize))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2)
                
                // 音符名称
                Text(showNotation ? note.notation : note.name)
                    .font(.system(size: keySize.textSize(forNotation: showNotation), weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(keyBackground)
            .overlay(keyBorder)
            .clipShape(RoundedRectangle(cornerRadius: keySize.cornerRadius))
            .scaleEffect(animationScale)
            .shadow(
                color: isPlaying ? note.color.opacity(0.6) : .black.opacity(0.1),
                radius: isPlaying ? 12 : 4,
                x: 0,
                y: isPlaying ? 6 : 2
            )
        }
        .buttonStyle(OptimizedPianoKeyStyle())
    }
    
    // MARK: - 视觉属性
    
    private var animationScale: CGFloat {
        isPlaying ? 1.08 : (isPressed ? 0.96 : 1.0)
    }
    
    private var keyBackground: some View {
        RoundedRectangle(cornerRadius: keySize.cornerRadius)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: keySize.cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }
    
    private var gradientColors: [Color] {
        if isPlaying {
            return [
                note.color.opacity(0.7),
                note.color.opacity(0.5)
            ]
        } else {
            return [
                note.color.opacity(0.4),
                note.color.opacity(0.2)
            ]
        }
    }
    
    private var keyBorder: some View {
        RoundedRectangle(cornerRadius: keySize.cornerRadius)
            .stroke(
                isPlaying ? note.color : note.color.opacity(0.3),
                lineWidth: isPlaying ? 2.5 : 1.5
            )
    }
}

/// 琴键尺寸配置 - 根据可用空间动态计算
struct PianoKeySize {
    let keyHeight: CGFloat
    let iconSize: CGFloat
    let notationTextSize: CGFloat
    let nameTextSize: CGFloat
    let cornerRadius: CGFloat
    let verticalSpacing: CGFloat
    
    func textSize(forNotation: Bool) -> CGFloat {
        forNotation ? notationTextSize : nameTextSize
    }
    
    /// 根据可用高度计算最优尺寸
    static func calculate(availableHeight: CGFloat) -> PianoKeySize {
        // 理想高度 72pt，但根据实际可用高度自适应
        let actualHeight = max(50, min(72, availableHeight))
        let scale = actualHeight / 72.0  // 缩放比例
        
        // 图标尺寸额外缩小20%，避免在小屏设备上过大
        let iconScale = scale * 0.8
        
        return PianoKeySize(
            keyHeight: actualHeight,
            iconSize: 24 * iconScale,        // 基础尺寸从28pt降到24pt，再乘以0.8倍
            notationTextSize: 22 * scale,
            nameTextSize: 14 * scale,
            cornerRadius: 16 * scale,
            verticalSpacing: 6 * scale       // 间距也稍微减小
        )
    }
}

/// 优化的琴键交互样式
struct OptimizedPianoKeyStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// 琴键行组件 - 完全响应式布局
struct PianoKeyRow: View {
    let notes: [Note]
    let playingIndex: Int?
    let showNotation: Bool
    let onKeyPress: (Int) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let keySize = PianoKeySize.calculate(availableHeight: geometry.size.height)
            let spacing = adaptiveSpacing(for: geometry.size)
            
            HStack(spacing: spacing) {
                ForEach(Array(notes.enumerated()), id: \.offset) { index, note in
                    PianoKeyButton(
                        note: note,
                        isPlaying: playingIndex == index,
                        showNotation: showNotation,
                        action: { onKeyPress(index) },
                        keySize: keySize
                    )
                    .frame(height: keySize.keyHeight)
                }
            }
        }
    }
    
    private func adaptiveSpacing(for size: CGSize) -> CGFloat {
        // 根据可用宽度动态计算间距
        let availableWidth = size.width
        let numberOfKeys: CGFloat = 8
        let numberOfSpaces: CGFloat = 7
        
        // 计算每个按键的理想最小宽度
        let minKeyWidth: CGFloat = 35
        
        // 如果空间充足，使用标准间距
        let idealSpacing: CGFloat = 8
        let idealTotalWidth = (minKeyWidth * numberOfKeys) + (idealSpacing * numberOfSpaces)
        
        if availableWidth >= idealTotalWidth {
            return idealSpacing
        }
        
        // 空间不足时，动态调整间距
        let totalMinWidth = minKeyWidth * numberOfKeys
        let remainingSpace = max(0, availableWidth - totalMinWidth)
        let spacing = remainingSpace / numberOfSpaces
        
        return max(2, spacing)  // 最小间距2pt，确保按键不贴合
    }
}
