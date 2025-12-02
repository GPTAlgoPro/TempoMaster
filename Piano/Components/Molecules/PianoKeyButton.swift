import SwiftUI

/// 优化的琴键按钮 - 分子组件
struct PianoKeyButton: View {
    let note: Note
    let isPlaying: Bool
    let showNotation: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: {
            // 增强触觉反馈
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            action()
        }) {
            VStack(spacing: 8) {
                // 音符图标
                Image(systemName: note.icon)
                    .font(.system(size: iconSize))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2)
                
                // 音符名称
                Text(showNotation ? note.notation : note.name)
                    .font(.system(size: showNotation ? 22 : fontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: keyHeight)
            .background(keyBackground)
            .overlay(keyBorder)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
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
    
    private var keyHeight: CGFloat { 72 }
    private var cornerRadius: CGFloat { 16 }
    private var iconSize: CGFloat { 28 }
    private var fontSize: CGFloat { 14 }
    
    private var animationScale: CGFloat {
        isPlaying ? 1.08 : (isPressed ? 0.96 : 1.0)
    }
    
    private var keyBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
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
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(
                isPlaying ? note.color : note.color.opacity(0.3),
                lineWidth: isPlaying ? 2.5 : 1.5
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

/// 琴键行组件
struct PianoKeyRow: View {
    let notes: [Note]
    let playingIndex: Int?
    let showNotation: Bool
    let onKeyPress: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(notes.enumerated()), id: \.offset) { index, note in
                PianoKeyButton(
                    note: note,
                    isPlaying: playingIndex == index,
                    showNotation: showNotation,
                    action: { onKeyPress(index) }
                )
            }
        }
    }
}
