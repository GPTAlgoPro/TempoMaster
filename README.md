# 隽婉雅韵 TempoMaster

[English](README_EN.md) | 简体中文

<div align="center">

<img src="Piano/Assets.xcassets/AppIcon.appiconset/piano-flat.jpg" title="" alt="App Icon" width="276">

**为爱而生的音乐启蒙应用 · 让孩子在游戏中爱上简谱**

[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)](https://www.apple.com/ios)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)

[开发故事](#开发故事) • [功能特性](#功能特性) • [应用截图](#应用截图) • [快速开始](#快速开始)

</div>

---

## 💝 开发故事

这款应用的诞生源于一位父亲对女儿的爱。

为了帮助女儿**隽婉**学习音乐简谱，我开发了这款寓教于乐的电子琴应用。应用名称"隽婉雅韵"既是对女儿的爱称，也代表着对音乐教育的美好愿景——让孩子在优雅的旋律中，快乐地学习和成长。

> "音乐是最好的礼物，而陪伴是最长情的告白。"

---

## 📖 简介

**隽婉雅韵 (TempoMaster)** 是一款专为 iOS 设计的音乐启蒙应用，将电子琴演奏与趣味游戏完美结合。无论是音乐启蒙、简谱学习，还是亲子互动，TempoMaster 都能让学习音乐变得简单而有趣。

### ✨ 为什么选择隽婉雅韵

- 🎯 **简谱启蒙首选** - 专为儿童简谱学习设计，从小星星开始
- 🎮 **游戏化学习** - "缤纷乐符"让枯燥的练习变得有趣
- 🎹 **简单易用** - 16键双排设计，孩子也能轻松上手
- 🎨 **视觉友好** - 彩色音符和6种主题，吸引孩子注意力
- 👨‍👧 **亲子互动** - 成就系统让家长见证孩子每一步成长
- 💯 **完全免费** - 无广告、无内购，纯粹的音乐体验

---

## 📱 应用截图

### 主演奏界面

<div align="center">
<img src="docs/screenshots/1.jpg" alt="主演奏界面" width="300"/>

*彩色琴键 + 音符显示，边玩边学简谱*

</div>

### 主题与曲库

<div align="center">
<img src="docs/screenshots/2.jpg" alt="主题设置" width="300"/>
<img src="docs/screenshots/3.jpg" alt="曲目选择" width="300"/>

*6种配色主题 | 经典儿歌曲库*

</div>

### 游戏模式

<div align="center">
<img src="docs/screenshots/6.jpg" alt="游戏菜单" width="200"/>
<img src="docs/screenshots/4.jpg" alt="难度选择" width="200"/>
<img src="docs/screenshots/5.jpg" alt="游戏中" width="200"/>

*趣味游戏化学习：4个难度等级适配不同水平*

</div>

### 成就与排行

<div align="center">
<img src="docs/screenshots/7.jpg" alt="成就系统" width="300"/>
<img src="docs/screenshots/8.jpg" alt="排行榜" width="300"/>

*记录成长轨迹，见证进步时刻*

</div>

---

## 🎯 核心功能

### 🎹 演奏学习模式

#### 简谱启蒙设计

- **彩色音符标识**：每个琴键配有简谱数字（1-7、i）
- **实时音符显示**：演奏时显示对应的简谱符号
- **双排键盘布局**：高低音分离，音域清晰
- **一键演奏**：播放示例曲目，跟着学习

#### 儿歌曲库

- 🌟 **小星星** - 最经典的启蒙曲目
- 🐯 **两只老虎** - 朗朗上口的儿歌
- 🎵 **欢乐颂** - 提升进阶水平
- 支持简谱/五线谱切换显示

### 🎮 游戏模式 - 缤纷乐符

让学习变成游戏，让枯燥变得有趣！

#### 4个难度等级

- 🟢 **简单** - 音符下落慢，适合刚入门的孩子
- 🟡 **普通** - 节奏适中，巩固基础
- 🟠 **困难** - 挑战反应速度
- 🔴 **专家** - 高手进阶之路

#### 成就激励系统

- 🌟 **初次挑战** - 完成第一次游戏
- 🔥 **完美十连** - 连续10次Perfect
- ⚡ **连击大师** - 达成50连击
- 👑 **全连击** - 完成一首歌的全连击
- 🎵 **音乐爱好者** - 累计100次游戏
- 🏆 **专家玩家** - 通关专家难度

### 🎨 个性化主题

6种配色方案，让孩子选择自己喜欢的风格：

- 经典紫粉、海洋蓝、日落橙、森林绿、宝石红、随机配色

### 🔊 音效增强

4种音效让演奏更有趣：混响、延迟、失真、合唱

---

## 🏗️ 技术实现

### 核心技术

```
SwiftUI 4.0          - 原生 iOS UI 框架
AVFoundation         - 专业音频处理
SpriteKit           - 流畅游戏动画
Combine             - 响应式架构
Swift 5.9           - 100% Swift 开发
```

### 项目结构

```
Piano/
├── app/
│   └── PianoApp.swift              # 应用入口
├── Features/
│   └── Piano/
│       └── PianoMainView.swift     # 主界面
├── Components/
│   ├── Atoms/                      # 原子组件
│   │   └── GlassButton.swift
│   ├── Molecules/                  # 分子组件
│   │   └── PianoKeyButton.swift
│   └── Organisms/                  # 有机组件
│       ├── AboutView.swift
│       ├── ControlPanel.swift
│       ├── EffectControlPanel.swift
│       └── SongSelectionPanel.swift
├── Core/
│   ├── SpriteKit/                  # 游戏引擎
│   │   ├── GameScene.swift
│   │   ├── SpriteKitGameView.swift
│   │   └── SpriteKitGameViewModel.swift
│   ├── Theme/
│   │   └── ThemeManager.swift      # 主题管理
│   └── AppState.swift              # 应用状态
├── models/
│   ├── AudioManager.swift          # 音频管理
│   ├── GameModels.swift            # 游戏数据模型
│   ├── GameStateManager.swift      # 游戏状态管理
│   ├── Note.swift                  # 音符模型
│   ├── NoteFallEngine.swift        # 音符下落引擎
│   ├── SheetMusicParser.swift      # 简谱解析器
│   └── SongScheduler.swift         # 曲目调度器
├── playlist/
│   └── Song.swift                  # 曲目模型
└── views/
    ├── GameMainView.swift          # 游戏主界面
    ├── GameResultView.swift        # 结果页面
    ├── LeaderboardView.swift       # 排行榜
    └── SheetMusicEditorView.swift  # 简谱编辑器
```

### 核心特性实现

#### 音频系统

- **AVAudioEngine** - 音频处理引擎
- **AVAudioPlayerNode** - 多音轨同步播放
- **AVAudioUnitReverb/Delay/Distortion** - 实时音效处理
- **低延迟设计** - 优化的音频缓冲配置

#### 游戏引擎

- **SpriteKit Scene** - 高性能 2D 渲染
- **物理引擎集成** - 流畅的音符下落动画
- **碰撞检测** - 精确的判定系统
- **粒子系统** - 华丽的视觉特效

#### 状态管理

- **Combine Framework** - 响应式数据流
- **ObservableObject** - MVVM 架构
- **@Published** - 自动 UI 更新
- **AppStorage** - 持久化配置

---

## 💻 快速开始

### 系统要求

- iOS 17.0 或更高版本
- iPhone 设备
- Xcode 15.0+（开发者）

### 安装运行

1. **克隆仓库**
   
   ```bash
   git clone https://github.com/GPTAlgoPro/TempoMaster.git
   cd TempoMaster
   ```

2. **打开项目**
   
   ```bash
   open Piano.xcodeproj
   ```

3. **运行应用**
   
   - 连接 iPhone 设备或使用模拟器
   - 选择目标设备
   - 点击运行 (⌘R)

---

## 📚 使用建议

### 给家长的话

**循序渐进**：

1. 先让孩子认识彩色琴键和对应的简谱数字
2. 播放示例曲目，让孩子跟着旋律点击
3. 从"简单"难度开始游戏模式
4. 每天练习15-20分钟，保持兴趣

**鼓励为主**：

- 关注成就系统，及时表扬孩子的进步
- 不要强求分数，重在培养兴趣
- 和孩子一起玩，增进亲子关系

### 学习路径

**第一周**：认识音符 → 学会《小星星》  
**第二周**：挑战游戏简单模式 → 解锁"初次挑战"成就  
**第三周**：学习《两只老虎》→ 尝试普通难度  
**第四周**：自由练习 → 冲击高分

---

## 🎯 未来计划

### v1.0.0（当前版本）

- ✅ 基础简谱学习功能
- ✅ 3首经典儿歌
- ✅ 游戏化学习模式
- ✅ 成就激励系统

### v1.1.0（计划中）

- 🔄 更多儿歌曲库（10+首）
- 🔄 练习模式：慢速跟弹
- 🔄 家长模式：学习报告

### v2.0.0（构想中）

- 🔄 iCloud 同步进度
- 🔄 iPad 适配大屏体验
- 🔄 录音分享功能

---

## 👨‍💻 关于开发者

**开发者**: 孙凯  
**初衷**: 为女儿隽婉创作的音乐启蒙礼物  
**版本**: 1.0.0  
**更新**: 2025年12月

> "这个应用承载着一位父亲对女儿的爱，希望它也能帮助更多孩子爱上音乐。"

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 🤝 参与贡献

如果您也是关心孩子音乐教育的家长或开发者，欢迎：

- 🐛 提交 Bug 反馈
- 💡 分享使用心得和改进建议
- 🎵 贡献更多适合儿童的曲目
- ⭐ 给项目一个 Star，让更多人看到

**提交方式**：[GitHub Issues](https://github.com/GPTAlgoPro/TempoMaster/issues)

---

## 🙏 特别鸣谢

- 💝 **隽婉** - 这个应用最重要的"产品经理"和测试用户
- 🍎 **Apple** - SwiftUI 和 AVFoundation 框架
- 🎵 **音乐教育工作者** - 提供的宝贵建议
- 👨‍👩‍👧‍👦 **所有关心孩子成长的家长们**

---

<div align="center">

**用爱陪伴成长，用音乐启迪心灵** 🎵

献给我的女儿隽婉，以及所有热爱音乐的孩子们

Made with 💖 by 孙凯

[⬆ 返回顶部](#隽婉雅韵-tempomaster)

</div>