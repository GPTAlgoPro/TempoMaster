import Foundation
import SwiftUI
import Combine

/// 本地化管理器 - 统一管理应用的多语言支持
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: Language = .system {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "AppLanguage")
        }
    }
    
    enum Language: String, CaseIterable {
        case system = "system"
        case chinese = "zh-Hans"
        case english = "en"
        
        var displayName: String {
            switch self {
            case .system:
                return NSLocalizedString("language.system", comment: "")
            case .chinese:
                return "简体中文"
            case .english:
                return "English"
            }
        }
        
        var icon: String {
            switch self {
            case .system: return "globe"
            case .chinese: return "🇨🇳"
            case .english: return "🇺🇸"
            }
        }
    }
    
    private init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage"),
           let language = Language(rawValue: savedLanguage) {
            currentLanguage = language
        }
    }
    
    /// 获取本地化字符串
    func localized(_ key: String, comment: String = "") -> String {
        let language = currentLanguage == .system ? Language.chinese : currentLanguage
        
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: comment)
        }
        
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}

/// String 扩展 - 简化本地化调用
extension String {
    var localized: String {
        LocalizationManager.shared.localized(self)
    }
    
    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}
