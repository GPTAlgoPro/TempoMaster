import SwiftUI

/// 主控制面板 - 有机组件 - 按功能分组合理布局
struct ControlPanel: View {
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var appState: AppState
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        VStack(spacing: 8) {
            // 第一行：核心功能（音量、曲目、游戏、停止）
            HStack(spacing: 8) {
                // 音量按钮
                CompactGlassButton(
                    title: "control.volume".localized,
                    icon: volumeIcon,
                    tintColor: .cyan,
                    action: {
                        appState.showModal(.volumeControl)
                    }
                )
                
                // 曲目按钮
                CompactGlassButton(
                    title: "control.songs".localized,
                    icon: "music.note.list",
                    tintColor: .purple,
                    action: {
                        appState.showModal(.songMenu)
                    }
                )
                
                // 游戏按钮
                CompactGlassButton(
                    title: "control.game".localized,
                    icon: "gamecontroller.fill",
                    tintColor: .green,
                    action: {
                        appState.showModal(.game)
                    }
                )
                
                // 停止按钮
                CompactGlassButton(
                    title: "control.stop".localized,
                    icon: "stop.circle.fill",
                    tintColor: .blue,
                    action: {
                        appState.stopAll()
                        audioManager.stopAll()
                    }
                )
            }
            
            // 第二行：音效和视觉设置（音效、简谱切换、外观）
            HStack(spacing: 8) {
                // 音效按钮
                CompactGlassButton(
                    title: "control.effect".localized,
                    icon: effectIcon,
                    tintColor: effectColor,
                    action: {
                        appState.showModal(.effectControl)
                    }
                )
                
                // 记谱法切换按钮 - 上方显示ABC/123，下方显示"记谱法"标签
                NotationToggleButton(
                    statusText: appState.showNotation ? "123" : "ABC",
                    label: "control.notation".localized,
                    icon: appState.showNotation ? "textformat.123" : "textformat.abc",
                    tintColor: appState.showNotation ? .green : .gray,
                    action: {
                        withAnimation {
                            appState.showNotation.toggle()
                        }
                    }
                )
                
                // 外观设置按钮
                CompactGlassButton(
                    title: "control.skin".localized,
                    icon: "paintpalette.fill",
                    tintColor: .pink,
                    action: {
                        appState.showModal(.skinSettings)
                    }
                )
                
                // 语言切换按钮
                CompactGlassButton(
                    title: "control.language".localized,
                    icon: "globe",
                    tintColor: .orange,
                    action: {
                        appState.showModal(.languageSettings)
                    }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var volumeIcon: String {
        let volume = audioManager.volume
        if volume == 0 {
            return "speaker.slash.fill"
        } else if volume < 0.3 {
            return "speaker.wave.1.fill"
        } else if volume < 0.7 {
            return "speaker.wave.2.fill"
        } else {
            return "speaker.wave.3.fill"
        }
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

/// 优化的音量控制面板
struct VolumeControlPanel: View {
    @ObservedObject var audioManager: AudioManager
    @Binding var isPresented: Bool
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var localization = LocalizationManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            // 标题栏
            HStack {
                Image(systemName: volumeIcon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(themeManager.colors.primary)
                
                Text(localization.localized("volume.title"))
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
            
            // 音量显示
            VStack(spacing: 16) {
                Text("\(Int(audioManager.volume * 100))%")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                
                // 音量滑块
                VStack(spacing: 8) {
                    Slider(value: $audioManager.volume, in: 0...1)
                        .tint(volumeColor)
                        .frame(height: 44) // 增大触控区域
                    
                    HStack {
                        Image(systemName: "speaker.fill")
                            .font(.system(size: 14))
                        Spacer()
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 14))
                    }
                    .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(.vertical, 20)
            
            // 快捷按钮
            HStack(spacing: 12) {
                QuickVolumeButton(icon: "minus", action: {
                    withAnimation {
                        audioManager.decreaseVolume()
                    }
                })
                
                QuickVolumeButton(icon: "speaker.slash.fill", action: {
                    withAnimation {
                        audioManager.volume = 0
                    }
                })
                
                QuickVolumeButton(icon: "plus", action: {
                    withAnimation {
                        audioManager.increaseVolume()
                    }
                })
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
    
    private var volumeIcon: String {
        let volume = audioManager.volume
        if volume == 0 { return "speaker.slash.fill" }
        else if volume < 0.3 { return "speaker.wave.1.fill" }
        else if volume < 0.7 { return "speaker.wave.2.fill" }
        else { return "speaker.wave.3.fill" }
    }
    
    private var volumeColor: Color {
        let volume = audioManager.volume
        if volume < 0.3 { return .blue }
        else if volume < 0.7 { return .green }
        else { return .orange }
    }
}

/// 快捷音量按钮
struct QuickVolumeButton: View {
    let icon: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue.opacity(isPressed ? 0.4 : 0.2))
                        )
                )
                .scaleEffect(isPressed ? 0.92 : 1.0)
        }
        .buttonStyle(PressableStyle(isPressed: $isPressed))
    }
}