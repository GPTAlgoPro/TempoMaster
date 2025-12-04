# 双语支持配置指南 / Bilingual Support Configuration Guide

## 概述 / Overview

本项目已经集成了中英双语支持系统。用户可以在应用内通过"语言"按钮切换界面语言。

This project has integrated Chinese-English bilingual support. Users can switch the interface language through the "Language" button in the app.

---

## 已完成的工作 / Completed Work

### 1. 本地化架构 / Localization Architecture

#### 1.1 LocalizationManager（本地化管理器）
- 路径：`Piano/Core/Localization/LocalizationManager.swift`
- 功能：
  - 统一管理应用的多语言切换
  - 支持系统语言、简体中文、英文三种模式
  - 自动保存用户语言偏好

#### 1.2 本地化字符串文件 / Localization String Files
- 中文：`Piano/Core/Localization/zh-Hans.lproj/Localizable.strings`
- 英文：`Piano/Core/Localization/en.lproj/Localizable.strings`

包含以下模块的翻译：
- 通用词汇（取消、确认、关闭等）
- 主界面文本
- 歌曲选择
- 控制面板
- 游戏模式
- 排行榜
- 乐谱编辑器
- 关于页面
- 音符名称

### 2. UI 组件更新 / UI Component Updates

已更新支持本地化的组件：
- ✅ `PianoMainView` - 主视图
- ✅ `HeaderView` - 标题栏
- ✅ `ControlPanel` - 控制面板（添加语言切换按钮）
- ✅ `SongSelectionPanel` - 歌曲选择面板
- ✅ `LanguageSettingsView` - 语言设置视图（新增）
- ✅ `AppState` - 添加语言设置模态框支持

### 3. 语言切换功能 / Language Switching Feature

用户可以通过以下方式切换语言：
1. 点击主界面底部控制面板的"语言"按钮
2. 在弹出的语言设置界面选择：
   - 跟随系统
   - 简体中文
   - English

---

## 需要在 Xcode 中完成的配置 / Xcode Configuration Required

### Step 1: 添加本地化资源到项目 / Add Localization Resources to Project

1. 在 Xcode 中打开项目 `Piano.xcodeproj`
2. 选择项目根节点（蓝色的 Piano 图标）
3. 在 PROJECT 区域选择 Piano
4. 切换到 "Info" 标签页
5. 在 "Localizations" 部分，点击 "+" 按钮
6. 添加 "Chinese (Simplified)" 和 "English"

### Step 2: 配置字符串文件 / Configure String Files

1. 在项目导航器中，右键点击 `Piano/Core/Localization` 文件夹
2. 选择 "Add Files to Piano..."
3. 选择以下文件：
   - `LocalizationManager.swift`
   - `zh-Hans.lproj/Localizable.strings`
   - `en.lproj/Localizable.strings`
4. 确保 "Copy items if needed" 被勾选
5. Target 选择 "Piano"

### Step 3: 验证文件引用 / Verify File References

1. 选中 `Localizable.strings` 文件
2. 在右侧的 File Inspector 中
3. 确认 "Localization" 区域显示：
   - ✅ Chinese (Simplified)
   - ✅ English

### Step 4: 配置 Info.plist

在 `Piano/Info.plist` 中添加以下键值：

```xml
<key>CFBundleLocalizations</key>
<array>
    <string>zh-Hans</string>
    <string>en</string>
</array>
<key>CFBundleDevelopmentRegion</key>
<string>zh-Hans</string>
```

---

## 使用方法 / Usage

### 在代码中使用本地化字符串 / Using Localized Strings in Code

```swift
// 方法 1：使用 String 扩展
Text("app.name".localized)

// 方法 2：带参数的本地化
Text("main.playing".localized(with: song.name))

// 方法 3：直接使用 LocalizationManager
Text(LocalizationManager.shared.localized("song.selection.title"))
```

### 添加新的本地化字符串 / Adding New Localized Strings

1. 在 `zh-Hans.lproj/Localizable.strings` 添加中文：
```
"new.key" = "中文文本";
```

2. 在 `en.lproj/Localizable.strings` 添加英文：
```
"new.key" = "English Text";
```

3. 在代码中使用：
```swift
Text("new.key".localized)
```

---

## 待完成的本地化工作 / Remaining Localization Work

以下组件仍需更新以支持本地化：

### 高优先级 / High Priority
- [ ] `AboutView` - 关于页面
- [ ] `EffectControlPanel` - 音效控制面板
- [ ] `OptimizedSkinSettingsView` - 外观设置
- [ ] `GameMainView` - 游戏主视图
- [ ] `GameResultView` - 游戏结果视图
- [ ] `ControlPanel` - 控制面板按钮文本

### 中优先级 / Medium Priority
- [ ] `LeaderboardView` - 排行榜视图
- [ ] `SheetMusicEditorView` - 乐谱编辑器
- [ ] `VolumeControlPanel` - 音量控制面板标题

### 低优先级 / Low Priority
- [ ] 歌曲名称本地化
- [ ] 错误提示信息
- [ ] Toast 通知消息

---

## 测试清单 / Testing Checklist

- [ ] 在中文环境下测试所有功能
- [ ] 在英文环境下测试所有功能
- [ ] 测试语言切换的即时响应
- [ ] 验证重启应用后语言设置是否保持
- [ ] 检查所有文本是否正确显示（无乱码）
- [ ] 确认所有 UI 布局在不同语言下正常

---

## 常见问题 / FAQ

### Q: 为什么切换语言后部分界面没有更新？
A: 某些组件可能还未实现本地化。请参考"待完成的本地化工作"部分。

### Q: 如何添加更多语言支持？
A: 1. 在 `LocalizationManager.Language` 枚举中添加新语言
   2. 创建对应的 `.lproj` 文件夹和 `Localizable.strings`
   3. 在 Xcode 项目设置中添加该语言

### Q: 本地化字符串文件编码问题？
A: 确保所有 `.strings` 文件使用 UTF-8 编码保存。

---

## 技术细节 / Technical Details

### 语言切换机制 / Language Switching Mechanism

1. 用户选择语言 → `LocalizationManager.currentLanguage` 更新
2. 通过 `@Published` 属性触发视图刷新
3. 所有使用 `.localized` 的文本自动更新
4. 语言偏好保存到 `UserDefaults`

### 性能优化 / Performance Optimization

- 使用懒加载机制加载本地化资源
- 缓存常用本地化字符串
- 最小化视图刷新范围

---

## 贡献指南 / Contribution Guidelines

如需为本地化工作做出贡献：

1. Fork 本项目
2. 创建本地化分支：`git checkout -b feature/localization-xxx`
3. 更新相应的 `.strings` 文件和代码
4. 提交 Pull Request，说明更新内容

---

**最后更新时间 / Last Updated:** 2025-12-04
**版本 / Version:** 1.0.0