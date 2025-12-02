import SwiftUI

/// 带倒计时功能的游戏视图
struct CountdownGameView: View {
    @State private var showCountdown = true
    @State private var gameStarted = false
    
    let song: Song
    let mode: GameMode
    let audioManager: AudioManager
    let onExit: () -> Void
    
    var body: some View {
        ZStack {
            // 黑色背景
            Color.black
                .ignoresSafeArea()
            
            if showCountdown {
                CountdownView {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showCountdown = false
                        gameStarted = true
                    }
                }
                .transition(.opacity)
            } else if gameStarted {
                SpriteKitGamePlayView(
                    song: song,
                    mode: mode,
                    audioManager: audioManager,
                    onExit: onExit
                )
                .transition(.opacity)
            }
        }
        .onAppear {
            print("🎮 开始倒计时游戏流程")
        }
    }
}

#Preview {
    CountdownGameView(
        song: Song.twinkleTwinkleLittleStar,
        mode: .normal,
        audioManager: AudioManager(),
        onExit: {}
    )
}