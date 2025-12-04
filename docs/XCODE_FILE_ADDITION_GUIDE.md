# Xcode 文件添加指南 / Guide to Adding Files to Xcode

## ⚠️ 重要提示 / Important Notice

当前项目中已创建了以下本地化支持文件，但它们尚未添加到 Xcode 项目中：

### 已创建的文件 / Created Files:
```
Piano/Core/Localization/
├── LocalizationManager.swift
├── zh-Hans.lproj/
│   └── Localizable.strings
└── en.lproj/
    └── Localizable.strings

Piano/Components/Organisms/
└── LanguageSettingsView.swift
```

这些文件虽然存在于文件系统中，但 Xcode 无法识别它们，需要手动添加到项目中。

---

## 🔧 解决方法 / Solution

### 方法 1：在 Xcode 中添加文件（推荐）

#### 步骤 1：添加 LocalizationManager.swift

1. 在 Xcode 中打开 `Piano.xcodeproj`
2. 在左侧导航栏，找到 `Piano/Core` 文件夹
3. 右键点击 `Core` → 选择 "Add Files to Piano..."
4. 导航到 `Piano/Core/Localization` 文件夹
5. 选中 `LocalizationManager.swift`
6. 确保勾选：
   - ✅ Copy items if needed（可选，因为文件已经在正确位置）
   - ✅ Create groups（重要）
   - ✅ Target: Piano（重要）
7. 点击 "Add"

#### 步骤 2：添加本地化字符串文件

1. 继续在 Xcode 中，右键点击 `Core/Localization` 文件夹
2. 选择 "Add Files to Piano..."
3. 选中整个 `zh-Hans.lproj` 文件夹
4. 设置同上，点击 "Add"
5. 重复步骤添加 `en.lproj` 文件夹

#### 步骤 3：添加 LanguageSettingsView.swift

1. 在 Xcode 左侧导航栏，找到 `Piano/Components/Organisms` 文件夹
2. 右键点击 `Organisms` → 选择 "Add Files to Piano..."
3. 导航到文件位置，选中 `LanguageSettingsView.swift`
4. 设置同上，点击 "Add"

#### 步骤 4：验证文件已添加

1. 在 Xcode 项目导航器中应该能看到：
   ```
   Piano
   ├── Core
   │   └── Localization
   │       ├── LocalizationManager.swift
   │       ├── zh-Hans.lproj
   │       │   └── Localizable.strings
   │       └── en.lproj
   │           └── Localizable.strings
   └── Components
       └── Organisms
           └── LanguageSettingsView.swift
   ```

2. 选中任一文件，在右侧 File Inspector 中确认：
   - Target Membership 中 "Piano" 被勾选

#### 步骤 5：配置本地化

1. 选择项目根节点（蓝色的 Piano 图标）
2. 在 PROJECT 区域选择 Piano
3. 切换到 "Info" 标签页
4. 在 "Localizations" 部分：
   - 点击 "+" 添加 "Chinese (Simplified)"
   - 再点击 "+" 添加 "English"
5. 选中 `Localizable.strings` 文件
6. 在右侧 File Inspector 的 "Localization" 区域：
   - 勾选 ✅ Chinese (Simplified)
   - 勾选 ✅ English

---

### 方法 2：使用命令行工具（备用方案）

如果您熟悉 Xcode 项目文件的结构，可以使用脚本自动添加：

```bash
# 注意：这个方法需要谨慎使用，建议备份项目文件
# 这里仅提供思路，实际操作请使用方法1

# 1. 打开 Xcode
open Piano.xcodeproj

# 2. 手动添加文件（通过 GUI）
```

---

## 🧪 测试验证 / Testing

### 测试 1：编译测试

1. 在 Xcode 中按 ⌘B 构建项目
2. 应该不会再出现 "Cannot find 'LocalizationManager' in scope" 错误

### 测试 2：运行测试

1. 在模拟器或真机上运行应用（⌘R）
2. 点击底部控制面板的"语言"按钮
3. 验证语言切换功能是否正常工作

### 测试 3：本地化测试

1. 在 `HeaderView` 中，标题应该显示本地化文本
2. 切换到英文，标题应该变为 "Elegant Piano"
3. 切换回中文，标题应该变为 "隽婉雅韵"

---

## 🐛 常见问题 / Troubleshooting

### 问题 1：添加文件后仍然报错

**解决方法：**
1. Clean Build Folder（⇧⌘K）
2. 删除 DerivedData：
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. 重新构建项目（⌘B）

### 问题 2：.strings 文件格式错误

**症状：** 编译时提示 "unable to load contents of file"

**解决方法：**
1. 确保文件编码为 UTF-8
2. 确保每行格式为：`"key" = "value";`
3. 注意分号不能省略

### 问题 3：本地化字符串不显示

**解决方法：**
1. 检查 `Info.plist` 是否配置了 `CFBundleLocalizations`
2. 确认 `.strings` 文件在正确的 `.lproj` 文件夹中
3. 验证文件的 Localization 设置

---

## 📝 验证清单 / Verification Checklist

完成添加后，请确认：

- [ ] `LocalizationManager.swift` 在项目导航器中可见
- [ ] `zh-Hans.lproj/Localizable.strings` 在项目中
- [ ] `en.lproj/Localizable.strings` 在项目中
- [ ] `LanguageSettingsView.swift` 在项目中
- [ ] 所有文件的 Target Membership 包含 "Piano"
- [ ] 项目 Info 中添加了两种本地化语言
- [ ] 编译无错误（⌘B）
- [ ] 应用可以正常运行
- [ ] 语言切换功能正常

---

## 🎯 下一步 / Next Steps

文件添加完成后：

1. 参考 `docs/QUICK_START_LOCALIZATION.md` 测试功能
2. 参考 `docs/LOCALIZATION_EXAMPLES.md` 继续完善其他组件
3. 查看 `docs/LOCALIZATION_GUIDE.md` 了解更多配置细节

---

## 💡 提示 / Tips

- 建议在添加文件前先用 Git 提交当前更改，以便回滚
- 添加 `.lproj` 文件夹时，Xcode 会自动识别为本地化资源
- 如果使用 CocoaPods 或 SPM，确保它们的配置也正确

---

**创建时间 / Created:** 2025-12-04  
**最后更新 / Last Updated:** 2025-12-04  
**版本 / Version:** 1.0.0