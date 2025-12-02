import SwiftUI
import Combine

/// 应用全局状态管理
final class AppState: ObservableObject {
    static let shared = AppState()
    
    // MARK: - 播放状态
    @Published var currentlyPlayingKey: Int?
    @Published var currentSong: Song?
    @Published var currentNoteIndex: Int?
    @Published var isPlayingSong = false
    
    // MARK: - UI状态
    @Published var activeModal: ModalType?
    @Published var showAdvancedControls = false
    
    // MARK: - 性能设置
    @Published var performanceMode: PerformanceMode = .balanced
    @Published var showNotation: Bool = true
    
    enum ModalType: Equatable {
        case songMenu
        case volumeControl
        case skinSettings
        case effectControl
        case about
        case game
    }
    
    enum PerformanceMode: String, CaseIterable {
        case lowPower = "省电模式"
        case balanced = "平衡模式"
        case highQuality = "高画质"
        
        var enableParticles: Bool {
            self != .lowPower
        }
        
        var enableDynamicBackground: Bool {
            self == .highQuality
        }
        
        var particleCount: Int {
            switch self {
            case .lowPower: return 0
            case .balanced: return 8
            case .highQuality: return 15
            }
        }
    }
    
    private init() {}
    
    // MARK: - Actions
    func showModal(_ modal: ModalType) {
        activeModal = modal
    }
    
    func dismissModal() {
        activeModal = nil
    }
    
    func playNote(at index: Int) {
        currentlyPlayingKey = index
        
        // 自动重置（延长视觉反馈）
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if self.currentlyPlayingKey == index {
                self.currentlyPlayingKey = nil
            }
        }
    }
    
    func stopAll() {
        currentlyPlayingKey = nil
        currentNoteIndex = nil
        isPlayingSong = false
        currentSong = nil
    }
    
    func playSong(_ song: Song) {
        stopAll()
        currentSong = song
        isPlayingSong = true
    }
}