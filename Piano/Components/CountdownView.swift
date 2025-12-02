import SwiftUI

/// 游戏倒计时视图 - 酷炫的倒计时界面
struct CountdownView: View {
    @State private var countdownValue: Int = 3
    @State private var showStart = false
    @State private var rotationAngle: Double = 0
    @State private var scaleEffect: Double = 0.5
    @State private var opacity: Double = 0
    
    // 缓存的主题颜色 - 避免倒计时期间颜色变化
    @State private var cachedThemeColors: ThemeColors?
    
    let onComplete: () -> Void
    
    // 粒子系统
    @State private var particles: [CountdownParticle] = []
    
    var body: some View {
        ZStack {
            // 主题背景层 - 使用缓存的渐变效果
            ZStack {
                // 底层渐变色
                if let cachedColors = cachedThemeColors {
                    LinearGradient(
                        colors: cachedColors.gradient.map { $0.opacity(0.35) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    LinearGradient(
                        colors: ThemeManager.shared.backgroundGradient(isDark: true),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                
                // 磨砂玻璃效果层
                Rectangle()
                    .fill(.ultraThinMaterial)
            }
            .ignoresSafeArea()
            
            // 旋转光环
            if !showStart {
                ZStack {
                    // 外层光环
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: cachedThemeColors?.gradient ?? ThemeManager.shared.colors.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 8
                        )
                        .frame(width: 300, height: 300)
                        .rotationEffect(.degrees(rotationAngle))
                        .opacity(0.8)
                    
                    // 中层光环
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: (cachedThemeColors?.gradient ?? ThemeManager.shared.colors.gradient).map { $0.opacity(0.8) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-rotationAngle * 1.5))
                        .opacity(0.6)
                    
                    // 内层光环
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: (cachedThemeColors?.gradient ?? ThemeManager.shared.colors.gradient).map { $0.opacity(0.6) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(rotationAngle * 2))
                        .opacity(0.4)
                }
            }
            
            // 粒子效果 - 使用主题色
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
            }
            
            // 倒计时数字或START文字
            VStack(spacing: 20) {
                if showStart {
                    Text("START!")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: cachedThemeColors != nil ? 
                                    [cachedThemeColors!.primary, cachedThemeColors!.secondary, cachedThemeColors!.accent] :
                                    [ThemeManager.shared.colors.primary, ThemeManager.shared.colors.secondary, ThemeManager.shared.colors.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: cachedThemeColors?.primary ?? ThemeManager.shared.colors.primary, radius: 20)
                        .scaleEffect(scaleEffect)
                        .opacity(opacity)
                } else {
                    Text("\(countdownValue)")
                        .font(.system(size: 120, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: countdownValue == 3 ? 
                                    (cachedThemeColors != nil ? [cachedThemeColors!.primary, cachedThemeColors!.secondary] : [ThemeManager.shared.colors.primary, ThemeManager.shared.colors.secondary]) :
                                    countdownValue == 2 ? 
                                    (cachedThemeColors != nil ? [cachedThemeColors!.secondary, cachedThemeColors!.accent] : [ThemeManager.shared.colors.secondary, ThemeManager.shared.colors.accent]) :
                                    (cachedThemeColors != nil ? [cachedThemeColors!.accent, cachedThemeColors!.primary] : [ThemeManager.shared.colors.accent, ThemeManager.shared.colors.primary]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: countdownValue == 3 ? (cachedThemeColors?.primary ?? ThemeManager.shared.colors.primary) : 
                                countdownValue == 2 ? (cachedThemeColors?.secondary ?? ThemeManager.shared.colors.secondary) : (cachedThemeColors?.accent ?? ThemeManager.shared.colors.accent), radius: 20)
                        .scaleEffect(scaleEffect)
                        .opacity(opacity)
                }
            }
        }
        .onAppear {
            // 进入游戏模式并缓存当前颜色
            ThemeManager.shared.enterGameMode()
            cachedThemeColors = ThemeManager.shared.colors
            startCountdown()
            generateParticles()
        }
        .onDisappear {
            // 退出游戏模式
            ThemeManager.shared.exitGameMode()
        }
    }
    
    // MARK: - 倒计时逻辑
    private func startCountdown() {
        // 第一个数字动画
        animateCountdownNumber()
        
        // 倒计时序列
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if countdownValue > 1 {
                countdownValue -= 1
                animateCountdownNumber()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if countdownValue > 1 {
                        countdownValue -= 1
                        animateCountdownNumber()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            // 显示START
                            countdownValue -= 1
                            showStart = true
                            animateStart()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                onComplete()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 动画效果
    private func animateCountdownNumber() {
        // 数字缩放动画
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scaleEffect = 1.2
            opacity = 1.0
        }
        
        // 环光环旋转加速
        withAnimation(.linear(duration: 1.0)) {
            rotationAngle += 360
        }
        
        // 收缩动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.7)) {
                scaleEffect = 0.8
                opacity = 0.8
            }
        }
        
        // 恢复
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scaleEffect = 1.0
                opacity = 1.0
            }
        }
    }
    
    private func animateStart() {
        // START文字动画
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
            scaleEffect = 1.5
            opacity = 1.0
        }
        
        // 爆炸效果
        generateExplosionParticles()
        
        // 淡出
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                scaleEffect = 2.0
                opacity = 0.0
            }
        }
    }
    
    // MARK: - 粒子系统
    private func generateParticles() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if countdownValue > 0 || showStart {
                addRandomParticle()
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func addRandomParticle() {
        let angle = Double.random(in: 0...2 * .pi)
        let distance = Double.random(in: 50...200)
        
        // 使用缓存的主题色而不是固定颜色
        let themeColors = cachedThemeColors != nil ? 
            [cachedThemeColors!.primary, cachedThemeColors!.secondary, cachedThemeColors!.accent] :
            [ThemeManager.shared.colors.primary, ThemeManager.shared.colors.secondary, ThemeManager.shared.colors.accent]
        
        let particle = CountdownParticle(
            id: UUID(),
            position: CGPoint(
                x: UIScreen.main.bounds.width / 2 + cos(angle) * distance,
                y: UIScreen.main.bounds.height / 2 + sin(angle) * distance
            ),
            color: themeColors.randomElement() ?? ThemeManager.shared.colors.primary,
            size: CGFloat.random(in: 2...8),
            opacity: Double.random(in: 0.3...0.8),
            scale: 1.0
        )
        
        particles.append(particle)
        
        // 限制粒子数量
        if particles.count > 50 {
            particles.removeFirst()
        }
        
        // 粒子动画
        animateParticle(particle)
    }
    
    private func animateParticle(_ particle: CountdownParticle) {
        withAnimation(.easeOut(duration: 1.0)) {
            if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                particles[index].opacity = 0
                particles[index].scale = 0.1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            particles.removeAll { $0.id == particle.id }
        }
    }
    
    private func generateExplosionParticles() {
        for _ in 0..<30 {
            let angle = Double.random(in: 0...2 * .pi)
            let distance = Double.random(in: 20...100)
            
            let particle = CountdownParticle(
                id: UUID(),
                position: CGPoint(
                    x: UIScreen.main.bounds.width / 2,
                    y: UIScreen.main.bounds.height / 2
                ),
                color: [.yellow, .orange, .red].randomElement() ?? .yellow,
                size: CGFloat.random(in: 4...12),
                opacity: 1.0,
                scale: 1.0
            )
            
            particles.append(particle)
            
            // 爆炸动画
            withAnimation(.easeOut(duration: 1.5)) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    let targetX = UIScreen.main.bounds.width / 2 + cos(angle) * distance * 3
                    let targetY = UIScreen.main.bounds.height / 2 + sin(angle) * distance * 3
                    particles[index].position = CGPoint(x: targetX, y: targetY)
                    particles[index].opacity = 0
                    particles[index].scale = 0.1
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                particles.removeAll { $0.id == particle.id }
            }
        }
    }
}

// MARK: - 粒子模型
struct CountdownParticle {
    let id: UUID
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
    var scale: Double
}

#Preview {
    CountdownView {
        print("倒计时完成")
    }
}