import SwiftUI

/// 优化的歌曲选择面板
struct SongSelectionPanel: View {
    let songs: [Song]
    let onSongSelected: (Song) -> Void
    let onCancel: () -> Void
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var isInitialized = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            header
            
            // 歌曲列表
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(songs) { song in
                        SongCard(song: song) {
                            onSongSelected(song)
                        }
                    }
                }
                .padding(16)
            }
            
            // 底部按钮
            footer
        }
        .frame(width: 360, height: 500)
        .background(
            ZStack {
                // 确保有基础背景色
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.black.opacity(0.85))
                
                // 半透明材质层
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
            }
        )
        .shadow(color: .black.opacity(0.3), radius: 24, x: 0, y: 12)
        .opacity(isInitialized ? 1 : 0.99) // 强制初始渲染
        .onAppear {
            isInitialized = true
        }
    }
    
    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "music.note.list")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(themeManager.colors.primary)
            
            Text("选择曲目")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Spacer()
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
    
    private var footer: some View {
        Button {
            onCancel()
        } label: {
            HStack {
                Spacer()
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                Text("取消")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                Spacer()
            }
            .foregroundStyle(.white)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(0.3))
            )
        }
        .padding(16)
    }
}

/// 歌曲卡片组件
struct SongCard: View {
    let song: Song
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 16) {
                // 歌曲图标
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [songColor.opacity(0.6), songColor.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: songIcon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                // 歌曲信息
                VStack(alignment: .leading, spacing: 6) {
                    Text(song.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    HStack(spacing: 12) {
                        Label("\(song.notes.count)", systemImage: "music.note")
                        Label("\(song.bpm)", systemImage: "metronome")
                    }
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                }
                
                Spacer()
                
                // 播放图标
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(songColor)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isPressed ? songColor.opacity(0.3) : songColor.opacity(0.15))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(songColor.opacity(0.4), lineWidth: 1.5)
                    )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(PressableStyle(isPressed: $isPressed))
    }
    
    private var songIcon: String {
        switch song.name {
        case "小星星": return "star.fill"
        case "两只老虎": return "pawprint.fill"
        case "欢乐颂": return "heart.fill"
        default: return "music.note"
        }
    }
    
    private var songColor: Color {
        switch song.name {
        case "小星星": return .yellow
        case "两只老虎": return .orange
        case "欢乐颂": return .pink
        default: return .blue
        }
    }
}