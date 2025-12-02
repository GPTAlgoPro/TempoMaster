import SwiftUI

/// 主控制面板 - 有机组件
struct ControlPanel: View {
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 8) {
            // 第一行：主要控制按钮
            HStack(spacing: 8) {
                // 停止按钮
                CompactGlassButton(
                    title: "停止",
                    icon: "stop.circle.fill",
                    tintColor: .blue,
                    action: {
                        appState.stopAll()
                        audioManager.stopAll()
                    }
                )
                
                // 示例曲按钮
                CompactGlassButton(
                    title: "曲目",
                    icon: "music.note.list",
                    tintColor: .purple,
                    action: {
                        appState.showModal(.songMenu)
                    }
                )
                
                // 游戏按钮
                CompactGlassButton(
                    title: "游戏",
                    icon: "gamecontroller.fill",
                    tintColor: .green,
                    action: {
                        appState.showModal(.game)
                    }
                )
                
                // 音量按钮
                CompactGlassButton(
                    title: "音量",
                    icon: volumeIcon,
                    tintColor: .cyan,
                    action: {
                        appState.showModal(.volumeControl)
                    }
                )
            }
            
            // 第二行：设置按钮
            HStack(spacing: 8) {
                // 音效按钮
                CompactGlassButton(
                    title: "音效",
                    icon: effectIcon,
                    tintColor: effectColor,
                    action: {
                        appState.showModal(.effectControl)
                    }
                )
                
                // 外观设置按钮
                CompactGlassButton(
                    title: "外观",
                    icon: "paintpalette.fill",
                    tintColor: .pink,
                    action: {
                        appState.showModal(.skinSettings)
                    }
                )
                
                // 简谱切换按钮
                CompactGlassButton(
                    title: appState.showNotation ? "简谱" : "ABC",
                    icon: appState.showNotation ? "textformat.123" : "textformat.abc",
                    tintColor: appState.showNotation ? .green : .gray,
                    action: {
                        withAnimation {
                            appState.showNotation.toggle()
                        }
                    }
                )
                
                // 关于按钮
                CompactGlassButton(
                    title: "关于",
                    icon: "info.circle.fill",
                    tintColor: .indigo,
                    action: {
                        appState.showModal(.about)
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
    
    var body: some View {
        VStack(spacing: 24) {
            // 标题栏
            HStack {
                Image(systemName: volumeIcon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(themeManager.colors.primary)
                
                Text("音量控制")
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