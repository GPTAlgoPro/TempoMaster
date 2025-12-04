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

// MARK: - App Delegate for Orientation Lock
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        // 锁定为仅竖屏模式
        return .portrait
    }
}
