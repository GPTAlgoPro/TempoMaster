import SwiftUI

/// 可按压样式
struct PressableStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = newValue
                }
            }
    }
}

/// 紧凑型按钮（用于底部控制栏）
struct CompactGlassButton: View {
    let title: String
    let icon: String
    let tintColor: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(tintColor.opacity(isPressed ? 0.4 : 0.2))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(tintColor.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PressableStyle(isPressed: $isPressed))
    }
}

/// 记谱法切换按钮（支持动态状态显示）
struct NotationToggleButton: View {
    let statusText: String  // 动态状态文字：ABC 或 123
    let label: String       // 固定标签：记谱法 / Notation
    let icon: String
    let tintColor: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            VStack(spacing: 4) {
                // 上方：动态状态文字（ABC 或 123）
                Text(statusText)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                // 下方：固定标签（记谱法）
                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(tintColor.opacity(isPressed ? 0.4 : 0.2))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(tintColor.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PressableStyle(isPressed: $isPressed))
    }
}
