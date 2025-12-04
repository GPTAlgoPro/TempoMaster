# 双语支持快速启动指南 / Quick Start Guide for Bilingual Support

## 🚀 5分钟快速配置 / 5-Minute Quick Setup

### Step 1: 在 Xcode 中添加文件 (2分钟)

1. 打开 `Piano.xcodeproj`
2. 右键点击 `Piano` 文件夹 → "Add Files to Piano..."
3. 选择以下文件夹：
   ```
   Piano/Core/Localization/
   Piano/Components/Organisms/LanguageSettingsView.swift
   ```
4. 确保勾选 "Copy items if needed"
5. Target 选择 "Piano"

### Step 2: 配置项目本地化 (1分钟)

1. 选择项目根节点（蓝色 Piano 图标）
2. PROJECT → Piano → Info 标签页
3. Localizations 区域点击 "+" 按钮
4. 添加：
   - ✅ Chinese (Simplified)
   - ✅ English

### Step 3: 运行测试 (2分钟)

1. 构建并运行项目 (⌘R)
2. 点击底部控制面板的"语言"按钮（地球图标）
3. 切换语言，验证效果

---

## ✅ 验证清单 / Verification Checklist

运行应用后，请验证以下功能：

- [ ] 主界面标题显示正确（隽婉雅韵 / Elegant Piano）
- [ ] 控制面板显示"语言"按钮
- [ ] 点击"语言"按钮弹出设置界面
- [ ] 可以切换三种语言选项
- [ ] 切换后界面文本即时更新
- [ ] 重启应用后语言设置保持

---

## 📱 用户操作指南 / User Guide

### 如何切换语言？

```
1. 打开应用
   ↓
2. 找到底部控制面板
   ↓
3. 点击"语言"按钮（第二行，地球图标🌐）
   ↓
4. 在弹出的界面中选择：
   - 🌐 跟随系统
   - 🇨🇳 简体中文
   - 🇺🇸 English
   ↓
5. 界面立即切换，无需重启
```

---

## 🎯 已支持的界面 / Supported Interfaces

### ✅ 已完成本地化
- 主界面标题
- 正在播放提示
- 歌曲选择面板
- 语言设置界面
- 取消按钮

### ⏳ 待完成本地化
- 控制面板所有按钮
- 关于页面
- 游戏界面
- 设置界面
- 更多...

---

## 🔧 开发者快速上手 / Developer Quick Start

### 如何在代码中使用本地化？

```swift
// 1. 简单文本
Text("app.name".localized)

// 2. 带参数
Text("main.playing".localized(with: songName))

// 3. 按钮
Button("cancel".localized) {
    // action
}
```

### 如何添加新翻译？

1. 在 `zh-Hans.lproj/Localizable.strings` 添加：
   ```
   "my.new.key" = "中文文本";
   ```

2. 在 `en.lproj/Localizable.strings` 添加：
   ```
   "my.new.key" = "English Text";
   ```

3. 在代码中使用：
   ```swift
   Text("my.new.key".localized)
   ```

---

## 🐛 常见问题 / FAQ

### Q: 为什么切换语言后没有变化？
A: 某些界面可能还未实现本地化，这是正常的。我们正在持续完善。

### Q: 如何让新添加的组件支持多语言？
A: 参考 `docs/LOCALIZATION_EXAMPLES.md` 中的示例。

### Q: 切换语言后需要重启应用吗？
A: 不需要，界面会立即更新。

### Q: 语言设置保存在哪里？
A: 保存在 UserDefaults 中，应用重启后自动恢复。

---

## 📚 详细文档 / Detailed Documentation

- **配置指南**: `docs/LOCALIZATION_GUIDE.md`
- **实现总结**: `docs/BILINGUAL_SUPPORT_SUMMARY.md`
- **使用示例**: `docs/LOCALIZATION_EXAMPLES.md`

---

## 🎉 恭喜！/ Congratulations!

您已经成功配置了双语支持系统！现在可以：

1. ✅ 在应用内自由切换中英文
2. ✅ 为新功能添加多语言支持
3. ✅ 持续完善现有界面的本地化

享受优雅的多语言体验吧！??

---

**创建时间 / Created:** 2025-12-04  
**版本 / Version:** 1.0.0