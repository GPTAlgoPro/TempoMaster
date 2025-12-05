import SwiftUI

@main
struct PianoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            PianoMainView()
        }
    }
}

// MARK: - App Delegate for Orientation Lock and Audio Management
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        // 锁定为仅竖屏模式
        return .portrait
    }
    
    // MARK: - 应用进入后台
    func applicationWillResignActive(_ application: UIApplication) {
        print("📱 应用即将进入后台，准备关闭音频引擎...")
        shutdownAudioEngine()
    }
    
    // MARK: - 应用即将终止
    func applicationWillTerminate(_ application: UIApplication) {
        print("📱 应用即将终止，关闭音频引擎...")
        shutdownAudioEngine()
    }
    
    // MARK: - 关闭音频引擎
    private func shutdownAudioEngine() {
        // 获取音频管理器的共享实例并安全停止所有音频
        let audioManager = AudioManager.shared
        audioManager.safeStopAllAudio {
            print("✅ 音频引擎已安全关闭")
        }
    }
}
