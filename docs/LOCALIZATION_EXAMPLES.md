# 本地化使用示例 / Localization Usage Examples

本文档提供实际的代码示例，展示如何在项目中正确使用双语支持功能。

---

## 📚 基础用法 / Basic Usage

### 1. 简单文本本地化

```swift
import SwiftUI

struct MyView: View {
    var body: some View {
        VStack {
            // ✅ 正确：使用 .localized 扩展
            Text("app.name".localized)
            
            // ❌ 错误：硬编码中文
            // Text("隽婉雅韵")
        }
    }
}
```

### 2. 带参数的文本本地化

```swift
struct SongInfoView: View {
    let songName: String
    let noteCount: Int
    
    var body: some View {
        VStack {
            // 单个参数
            Text("main.playing".localized(with: songName))
            // 输出：🎵 正在播放：小星星 / 🎵 Now Playing: Little Star
            
            // 多个参数
            Text("song.notes.count".localized(with: noteCount))
            // 输出：32 音符 / 32 Notes
        }
    }
}
```

---

## 🎯 实际场景示例 / Real-world Examples

### 场景 1: 按钮文本

```swift
// ❌ 之前的写法（硬编码）
Button("开始游戏") {
    startGame()
}

// ✅ 现在的写法（本地化）
Button("game.start".localized) {
    startGame()
}
```

### 场景 2: 导航标题

```swift
struct GameView: View {
    var body: some View {
        NavigationView {
            GameContent()
                .navigationTitle("game.title".localized)
                // 显示：缤纷乐符 / Rhythm Notes
        }
    }
}
```

### 场景 3: 提示信息

```swift
struct StatusView: View {
    @State private var isLoading = true
    
    var body: some View {
        if isLoading {
            ProgressView("loading".localized)
            // 显示：加载中... / Loading...
        }
    }
}
```

### 场景 4: 弹窗消息

```swift
func showAlert() {
    let alert = UIAlertController(
        title: "error".localized,
        message: "error.message".localized,
        preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(
        title: "confirm".localized,
        style: .default
    ))
    
    present(alert, animated: true)
}
```

---

## 🔧 组件更新模板 / Component Update Template

### 模板 1: 简单视图更新

```swift
// === 更新前 ===
struct OldView: View {
    var body: some View {
        VStack {
            Text("标题")
                .font(.title)
            
            Button("确认") {
                // action
            }
        }
    }
}

// === 更新后 ===
struct NewView: View {
    var body: some View {
        VStack {
            Text("view.title".localized)  // ← 添加 .localized
                .font(.title)
            
            Button("confirm".localized) {  // ← 添加 .localized
                // action
            }
        }
    }
}
```

### 模板 2: 带参数的视图更新

```swift
// === 更新前 ===
struct ScoreView: View {
    let score: Int
    
    var body: some View {
        Text("得分: \(score)")
    }
}

// === 更新后 ===
struct ScoreView: View {
    let score: Int
    
    var body: some View {
        Text("game.score".localized(with: score))
    }
}

// 对应的 strings 文件：
// zh-Hans: "game.score" = "得分: %d";
// en: "game.score" = "Score: %d";
```

### 模板 3: 复杂组件更新

```swift
// === 更新前 ===
struct SettingsPanel: View {
    var body: some View {
        VStack {
            Text("设置")
                .font(.headline)
            
            Toggle("显示简谱", isOn: $showNotation)
            
            Button("保存设置") {
                saveSettings()
            }
        }
    }
}

// === 更新后 ===
struct SettingsPanel: View {
    var body: some View {
        VStack {
            Text("settings.title".localized)
                .font(.headline)
            
            Toggle("settings.show.notation".localized, isOn: $showNotation)
            
            Button("settings.save".localized) {
                saveSettings()
            }
        }
    }
}
```

---

## 📝 添加新翻译步骤 / Adding New Translations

### Step 1: 在 strings 文件中添加翻译

```strings
// zh-Hans.lproj/Localizable.strings
"feature.new.button" = "新功能";
"feature.new.description" = "这是一个新功能的描述";

// en.lproj/Localizable.strings
"feature.new.button" = "New Feature";
"feature.new.description" = "This is a description of the new feature";
```

### Step 2: 在代码中使用

```swift
struct NewFeatureView: View {
    var body: some View {
        VStack {
            Button("feature.new.button".localized) {
                // action
            }
            
            Text("feature.new.description".localized)
                .font(.caption)
        }
    }
}
```

---

## 🎨 控制面板按钮更新示例

### 当前实现：ControlPanel

```swift
// 音效按钮
CompactGlassButton(
    title: "音效",  // 需要更新为 "control.effect".localized
    icon: effectIcon,
    tintColor: effectColor,
    action: {
        appState.showModal(.effectControl)
    }
)

// 外观设置按钮
CompactGlassButton(
    title: "外观",  // 需要更新为 "control.skin".localized
    icon: "paintpalette.fill",
    tintColor: .pink,
    action: {
        appState.showModal(.skinSettings)
    }
)

// 语言切换按钮（已实现）
CompactGlassButton(
    title: "语言",  // 需要更新为 "control.language".localized
    icon: "globe",
    tintColor: .orange,
    action: {
        appState.showModal(.languageSettings)
    }
)
```

### 建议更新为：

```swift
// 音效按钮
CompactGlassButton(
    title: "control.effect".localized,
    icon: effectIcon,
    tintColor: effectColor,
    action: {
        appState.showModal(.effectControl)
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
```

并在 strings 文件中添加：
```strings
// zh-Hans
"control.effect" = "音效";
"control.skin" = "外观";
"control.language" = "语言";

// en
"control.effect" = "Effect";
"control.skin" = "Skin";
"control.language" = "Language";
```

---

## 🚨 常见错误 / Common Mistakes

### 错误 1: 忘记添加 .localized

```swift
// ❌ 错误
Text("app.name")  // 会直接显示 "app.name"

// ✅ 正确
Text("app.name".localized)  // 显示：隽婉雅韵 / Elegant Piano
```

### 错误 2: 硬编码文本

```swift
// ❌ 错误
Button("开始") {
    start()
}

// ✅ 正确
Button("start".localized) {
    start()
}
```

### 错误 3: 参数格式错误

```swift
// ❌ 错误
Text("得分: \(score)".localized)  // 参数在本地化之前

// ✅ 正确
Text("game.score".localized(with: score))  // 参数在本地化之后
```

### 错误 4: 缺少对应翻译

```swift
// 如果 strings 文件中没有 "new.feature"
Text("new.feature".localized)  // 会显示 "new.feature"

// 解决方法：确保在两个 .strings 文件中都添加了翻译
```

---

## ✅ 检查清单 / Checklist

在提交代码前，请确认：

- [ ] 所有硬编码的中文文本都已替换为 `.localized`
- [ ] 在两个 `.strings` 文件中都添加了对应翻译
- [ ] 使用了有意义的 key 命名（如 `module.component.element`）
- [ ] 带参数的文本使用了正确的格式符号（%@, %d 等）
- [ ] 在两种语言下都测试了显示效果
- [ ] UI 布局在两种语言下都正常显示

---

## 📖 参考资料 / References

- [LocalizationManager 源码](../Piano/Core/Localization/LocalizationManager.swift)
- [中文字符串文件](../Piano/Core/Localization/zh-Hans.lproj/Localizable.strings)
- [英文字符串文件](../Piano/Core/Localization/en.lproj/Localizable.strings)
- [配置指南](./LOCALIZATION_GUIDE.md)
- [实现总结](./BILINGUAL_SUPPORT_SUMMARY.md)

---

**最后更新 / Last Updated:** 2025-12-04  
**版本 / Version:** 1.0.0