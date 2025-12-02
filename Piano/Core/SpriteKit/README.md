# SpriteKit + SwiftUI 游戏架构

## 概述

本项目采用 **SpriteKit + SwiftUI 混合架构**，充分发挥两个框架的优势：

- **SpriteKit**：高性能游戏渲染引擎，负责音符动画、粒子特效和实时物理模拟
- **SwiftUI**：声明式UI框架，负责HUD界面、菜单系统和状态管理

## 架构设计

```
┌─────────────────────────────────────────────┐
│          SpriteKitGamePlayView              │  ← SwiftUI主视图
│  ┌─────────────────────────────────────┐   │
│  │     SpriteKitGameView (Wrapper)     │   │  ← UIViewRepresentable
│  │  ┌───────────────────────────────┐  │   │
│  │  │       GameScene (SKScene)     │  │   │  ← SpriteKit场景
│  │  │  - 音符渲染                    │  │   │
│  │  │  - 粒子特效                    │  │   │
│  │  │  - 触摸处理                    │  │   │
│  │  └───────────────────────────────┘  │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  SpriteKitGameViewModel (ObservableObject) │  ← 状态管理
│  │  - 游戏逻辑                          │   │
│  │  - 判定系统                          │   │
│  │  - Fever模式                         │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
         ↓ 通过回调通信 ↓
┌─────────────────────────────────────────────┐
│         GameStateManager (Shared)           │  ← 全局状态
│  - 分数统计                                  │
│  - 成就系统                                  │
│  - 数据持久化                                │
└─────────────────────────────────────────────┘
```

## 核心组件

### 1. GameScene.swift
**职责**：SpriteKit游戏场景，负责所有游戏内渲染

**功能**：
- 音符下落动画（60 FPS高性能渲染）
- 轨道和判定线显示
- 触摸事件处理和判定
- 粒子特效系统（打击特效、Fever特效）
- 音符节点管理

### 2. SpriteKitGameView.swift
**职责**：SwiftUI包装器和完整游戏视图

**特点**：
- 使用 `UIViewRepresentable` 协议
- 管理SKView生命周期
- 集成HUD界面和游戏控制

### 3. SpriteKitGameViewModel.swift
**职责**：游戏业务逻辑和状态管理

**功能**：
- 音符生成和管理
- 判定处理和分数计算
- Fever模式管理
- 游戏流程控制

## 使用方法

在主菜单中选择"SpriteKit"渲染引擎，然后选择歌曲和难度即可体验高性能游戏渲染！

## 性能优势

✅ 稳定60 FPS渲染  
✅ 支持数百个同时渲染的节点  
✅ 内置强大的粒子系统  
✅ 更流畅的动画和特效

## 相关文件

- `Piano/Core/SpriteKit/GameScene.swift` - 核心场景
- `Piano/Core/SpriteKit/SpriteKitGameView.swift` - SwiftUI包装器
- `Piano/Core/SpriteKit/SpriteKitGameViewModel.swift` - ViewModel
- `Piano/views/GameMainView.swift` - 主入口（含引擎切换）

---

**作者**：Comate Zulu  
**日期**：2025-12-01  
**版本**：1.0.0