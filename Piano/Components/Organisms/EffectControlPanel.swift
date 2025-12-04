import SwiftUI

/// 音效控制面板
struct EffectControlPanel: View {
    @ObservedObject var audioManager: AudioManager
    let onDismiss: () -> Void
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var localization = LocalizationManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            // 标题栏
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(themeManager.colors.primary)
                
                Text(localization.localized("effect.title"))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            
            // 当前音效显示
            VStack(spacing: 16) {
                Text(localization.localized("effect.current"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
                
                HStack {
                    Image(systemName: effectIcon)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(effectColor)
                    
                    Text(audioManager.currentEffect.localizedName)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(effectColor.opacity(0.5), lineWidth: 2)
                        )
                )
            }
            
            // 音效选择网格（排除原声选项）
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(AudioManager.AudioEffect.allCases.filter { $0 != .none }, id: \.self) { effect in
                    EffectOptionButton(
                        effect: effect,
                        isSelected: audioManager.currentEffect == effect,
                        onTap: {
                            audioManager.currentEffect = effect
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        }
                    )
                }
            }
            
            // 快捷操作按钮
            HStack(spacing: 12) {
                Button {
                    audioManager.currentEffect = .none
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                } label: {
                    Text(localization.localized("effect.disable"))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                        )
                }
                
                Button {
                    audioManager.nextEffect()
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                } label: {
                    Text(localization.localized("effect.switch"))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeManager.colors.primary.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(themeManager.colors.primary.opacity(0.5), lineWidth: 1)
                                )
                        )
                }
            }
        }
        .padding(24)
        .frame(width: 340)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(themeManager.colors.primary.opacity(0.3), lineWidth: 1.5)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
    
    private var effectIcon: String {
        switch audioManager.currentEffect {
        case .none: return "waveform"
        case .reverb: return "music.mic"
        case .delay: return "clock.arrow.circlepath"
        case .distortion: return "waveform.path"
        case .chorus: return "person.3"
        }
    }
    
    private var effectColor: Color {
        switch audioManager.currentEffect {
        case .none: return .gray
        case .reverb: return .purple
        case .delay: return .orange
        case .distortion: return .red
        case .chorus: return .green
        }
    }
}

/// 音效选项按钮
struct EffectOptionButton: View {
    let effect: AudioManager.AudioEffect
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            VStack(spacing: 8) {
                Image(systemName: effectIcon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : effectColor)
                
                Text(effect.localizedName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? effectColor : effectColor.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isSelected ? effectColor.opacity(0.3) : Color.clear)
                    )
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .buttonStyle(PressableStyle(isPressed: $isPressed))
    }
    
    private var effectIcon: String {
        switch effect {
        case .none: return "waveform"
        case .reverb: return "music.mic"
        case .delay: return "clock.arrow.circlepath"
        case .distortion: return "waveform.path"
        case .chorus: return "person.3"
        }
    }
    
    private var effectColor: Color {
        switch effect {
        case .none: return .gray
        case .reverb: return .purple
        case .delay: return .orange
        case .distortion: return .red
        case .chorus: return .green
        }
    }
}
