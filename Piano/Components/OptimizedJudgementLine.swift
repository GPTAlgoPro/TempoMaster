import SwiftUI
import SpriteKit

/// 美化版判定线组件 - 多层光晕、波纹效果和动态粒子流
struct OptimizedJudgementLine: View {
    @State private var rippleOffset: CGFloat = 0
    @State private var particleOffset: CGFloat = 0
    @State private var glowIntensity: Double = 0.8
    @State private var showPerfectEffect = false
    @State private var particles: [JudgementLineParticle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 多层光晕背景
                multiLayerGlowBackground
                    .frame(height: 40)
                    .position(y: geometry.size.height / 3)

                // 波纹效果层
                waveEffectLayer
                    .frame(height: 30)
                    .position(y: geometry.size.height / 3)

                // 三层结构主线
                threeLayerMainLine
                    .frame(height: 4)
                    .position(y: geometry.size.height / 3)

                // 动态粒子流
                particleFlowLayer
                    .frame(height: 60)
                    .position(y: geometry.size.height / 3)

                // 完美判定提示框
                if showPerfectEffect {
                    perfectJudgementBox
                        .position(y: geometry.size.height / 3 - 80)
                }
            }
        }
        .onAppear {
            startAnimations()
            generateParticles()
        }
    }
    
    // MARK: - 多层光晕背景
    private var multiLayerGlowBackground: some View {
        ZStack {
            // 外层光晕（最大，最淡）
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.1 * glowIntensity),
                            .clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 150
                    )
                )
                .blur(radius: 20)
            
            // 中层光晕（中等，半透明）
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    RadialGradient(
                        colors: [
                            .cyan.opacity(0.2 * glowIntensity),
                            .blue.opacity(0.15 * glowIntensity),
                            .clear
                        ],
                        center: .center,
                        startRadius: 3,
                        endRadius: 80
                    )
                )
                .blur(radius: 10)
            
            // 内层光晕（最小，最亮）
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.4 * glowIntensity),
                            .cyan.opacity(0.3 * glowIntensity),
                            .clear
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: 40
                    )
                )
                .blur(radius: 5)
        }
    }
    
    // MARK: - 波纹效果层
    private var waveEffectLayer: some View {
        ZStack {
            // 主波纹
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.6),
                            .cyan.opacity(0.8),
                            .white.opacity(0.6)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
                .opacity(0.8)
            
            // 动态波纹
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    LinearGradient(
                        colors: [
                            .cyan.opacity(0.4),
                            .blue.opacity(0.6),
                            .cyan.opacity(0.4)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
                .offset(x: rippleOffset)
                .opacity(0.5)
            
            // 第二层动态波纹
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    LinearGradient(
                        colors: [
                            .purple.opacity(0.3),
                            .pink.opacity(0.5),
                            .purple.opacity(0.3)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
                .offset(x: -rippleOffset)
                .opacity(0.4)
        }
    }
    
    // MARK: - 三层结构主线
    private var threeLayerMainLine: some View {
        ZStack {
            // 底部装饰线（最宽）
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [
                            .purple.opacity(0.6),
                            .blue.opacity(0.8),
                            .purple.opacity(0.6)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 4)
            
            // 主线（标准宽度）
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.9),
                            .cyan.opacity(1.0),
                            .white.opacity(0.9)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
            
            // 顶部装饰线（最细，最亮）
            RoundedRectangle(cornerRadius: 1)
                .fill(
                    LinearGradient(
                        colors: [
                            .white,
                            .yellow.opacity(0.8),
                            .white
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .shadow(color: .white, radius: 2)
        }
    }
    
    // MARK: - 动态粒子流
    private var particleFlowLayer: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
                    .blur(radius: particle.blur)
            }
        }
    }
    
    // MARK: - 完美判定提示框
    private var perfectJudgementBox: some View {
        VStack(spacing: 8) {
            // 星星装饰
            HStack(spacing: 8) {
                ForEach(0..<3) { _ in
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundStyle(.yellow)
                        .shadow(color: .yellow, radius: 5)
                }
            }
            
            // 完美文字
            Text("PERFECT!")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange, .red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .yellow, radius: 10)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .scaleEffect(showPerfectEffect ? 1.0 : 0.5)
        .opacity(showPerfectEffect ? 1.0 : 0.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showPerfectEffect)
    }
    
    // MARK: - 动画控制
    private func startAnimations() {
        // 波纹动画
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
            rippleOffset = 50
        }
        
        // 光晕强度动画
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                glowIntensity = 0.6 + 0.4 * sin(Date().timeIntervalSince1970 * 3)
            }
        }
    }
    
    // MARK: - 粒子系统
    private func generateParticles() {
        // 生成12个流动粒子
        for i in 0..<12 {
            let particle = JudgementLineParticle(
                id: UUID(),
                x: CGFloat(i) * (UIScreen.main.bounds.width / 12) + UIScreen.main.bounds.width / 24,
                y: 0,
                color: [.cyan, .yellow, .orange, .purple, .pink].randomElement() ?? .cyan,
                size: CGFloat.random(in: 2...6),
                opacity: Double.random(in: 0.3...0.8),
                blur: CGFloat.random(in: 0...2),
                speed: Double.random(in: 1...3)
            )
            particles.append(particle)
        }
        
        // 粒子流动动画
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            updateParticles()
        }
    }
    
    private func updateParticles() {
        for i in 0..<particles.count {
            let particle = particles[i]
            
            // 垂直流动效果
            let newY = particle.y + particle.speed
            let finalY: CGFloat
            
            if abs(newY) > 30 {
                finalY = -30
            } else {
                finalY = newY
            }
            
            particles[i] = JudgementLineParticle(
                id: particle.id,
                x: particle.x,
                y: finalY,
                color: particle.color,
                size: particle.size,
                opacity: 0.3 + 0.5 * sin(Double(i) + Date().timeIntervalSince1970 * 2),
                blur: particle.blur,
                speed: particle.speed
            )
        }
    }
    
    // MARK: - 外部触发方法
    func triggerPerfectEffect() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            showPerfectEffect = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                showPerfectEffect = false
            }
        }
    }
}

// MARK: - 判定线粒子模型
struct JudgementLineParticle {
    let id: UUID
    let x: CGFloat
    var y: CGFloat
    let color: Color
    let size: CGFloat
    var opacity: Double
    let blur: CGFloat
    let speed: Double
}

/// SpriteKit版本的判定线节点
class OptimizedJudgementLineNode: SKNode {
    private let multiLayerGlow: SKNode
    private let waveEffect: SKNode
    private let mainLine: SKNode
    private let particleFlow: SKNode
    private var particles: [JudgementLineSKParticle] = []
    
    override init() {
        multiLayerGlow = SKNode()
        waveEffect = SKNode()
        mainLine = SKNode()
        particleFlow = SKNode()
        
        super.init()
        
        setupMultiLayerGlow()
        setupWaveEffect()
        setupMainLine()
        setupParticleFlow()
        
        addChild(multiLayerGlow)
        addChild(waveEffect)
        addChild(mainLine)
        addChild(particleFlow)
        
        startAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 设置方法
    private func setupMultiLayerGlow() {
        // 外层光晕
        let outerGlow = SKShapeNode(rectOf: CGSize(width: 1000, height: 40), cornerRadius: 20)
        outerGlow.fillColor = .clear
        outerGlow.strokeColor = .white
        outerGlow.lineWidth = 1
        outerGlow.alpha = 0.1
        outerGlow.glowWidth = 20
        multiLayerGlow.addChild(outerGlow)
        
        // 中层光晕
        let middleGlow = SKShapeNode(rectOf: CGSize(width: 800, height: 30), cornerRadius: 15)
        middleGlow.fillColor = .clear
        middleGlow.strokeColor = .cyan
        middleGlow.lineWidth = 2
        middleGlow.alpha = 0.2
        middleGlow.glowWidth = 10
        multiLayerGlow.addChild(middleGlow)
        
        // 内层光晕
        let innerGlow = SKShapeNode(rectOf: CGSize(width: 600, height: 20), cornerRadius: 10)
        innerGlow.fillColor = .clear
        innerGlow.strokeColor = .white
        innerGlow.lineWidth = 1
        innerGlow.alpha = 0.4
        innerGlow.glowWidth = 5
        multiLayerGlow.addChild(innerGlow)
    }
    
    private func setupWaveEffect() {
        // 主波纹
        let mainWave = SKShapeNode(rectOf: CGSize(width: 1000, height: 30), cornerRadius: 8)
        mainWave.fillColor = .clear
        mainWave.strokeColor = .white
        mainWave.lineWidth = 2
        mainWave.alpha = 0.8
        waveEffect.addChild(mainWave)
        
        // 动态波纹
        let dynamicWave1 = SKShapeNode(rectOf: CGSize(width: 1000, height: 30), cornerRadius: 8)
        dynamicWave1.fillColor = .clear
        dynamicWave1.strokeColor = .cyan
        dynamicWave1.lineWidth = 1
        dynamicWave1.alpha = 0.5
        waveEffect.addChild(dynamicWave1)
        
        let dynamicWave2 = SKShapeNode(rectOf: CGSize(width: 1000, height: 30), cornerRadius: 8)
        dynamicWave2.fillColor = .clear
        dynamicWave2.strokeColor = .purple
        dynamicWave2.lineWidth = 1
        dynamicWave2.alpha = 0.4
        waveEffect.addChild(dynamicWave2)
        
        // 波纹动画
        let moveAction1 = SKAction.moveBy(x: 50, y: 0, duration: 2.0)
        let moveAction2 = SKAction.moveBy(x: -50, y: 0, duration: 2.0)
        dynamicWave1.run(SKAction.repeatForever(SKAction.sequence([moveAction1, moveAction1.reversed()])))
        dynamicWave2.run(SKAction.repeatForever(SKAction.sequence([moveAction2, moveAction2.reversed()])))
    }
    
    private func setupMainLine() {
        // 底部装饰线
        let bottomLine = SKShapeNode(rectOf: CGSize(width: 1000, height: 4), cornerRadius: 2)
        bottomLine.fillColor = UIColor.cyan
        bottomLine.strokeColor = .clear
        mainLine.addChild(bottomLine)
        
        // 主线
        let mainLineShape = SKShapeNode(rectOf: CGSize(width: 1000, height: 2), cornerRadius: 1)
        mainLineShape.fillColor = UIColor.white
        mainLineShape.strokeColor = .clear
        mainLine.addChild(mainLineShape)
        
        // 顶部装饰线
        let topLine = SKShapeNode(rectOf: CGSize(width: 1000, height: 1), cornerRadius: 0.5)
        topLine.fillColor = UIColor.yellow
        topLine.strokeColor = .clear
        topLine.glowWidth = 2
        mainLine.addChild(topLine)
    }
    
    private func setupParticleFlow() {
        for i in 0..<12 {
            let particle = JudgementLineSKParticle(
                x: CGFloat(i) * 83.33 + 41.67,
                y: 0,
                color: [.cyan, .yellow, .orange, .purple, .pink].randomElement() ?? .cyan,
                size: CGFloat.random(in: 2...6),
                opacity: Double.random(in: 0.3...0.8),
                speed: CGFloat.random(in: 1...3)
            )
            particles.append(particle)
            particleFlow.addChild(particle.node)
        }
    }
    
    // MARK: - 动画控制
    private func startAnimations() {
        // 光晕脉冲动画
        let pulseAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 0.5),
            SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        ])
        multiLayerGlow.run(SKAction.repeatForever(pulseAction))
        
        // 粒子流动动画
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            self.updateParticles()
        }
    }
    
    private func updateParticles() {
        for i in 0..<particles.count {
            let particle = particles[i]
            
            let newY = particle.y + particle.speed
            let finalY: CGFloat
            
            if abs(newY) > 30 {
                finalY = -30
            } else {
                finalY = newY
            }
            
            particle.y = finalY
            particle.node.position = CGPoint(x: particle.x, y: finalY)
            particle.node.alpha = 0.3 + 0.5 * sin(Double(i) + Date().timeIntervalSince1970 * 2)
        }
    }
    
    // MARK: - 外部方法
    func showPerfectEffect() {
        let perfectLabel = SKLabelNode(text: "PERFECT!")
        perfectLabel.fontSize = 24
        perfectLabel.fontName = "Helvetica-Bold"
        perfectLabel.fontColor = SKColor.yellow
        perfectLabel.position = CGPoint(x: 0, y: -80)
        perfectLabel.zPosition = 100
        
        addChild(perfectLabel)
        
        let scaleAction = SKAction.scale(to: 1.5, duration: 0.3)
        let fadeAction = SKAction.fadeOut(withDuration: 0.7)
        perfectLabel.run(SKAction.sequence([scaleAction, fadeAction, SKAction.removeFromParent()]))
    }
}

// MARK: - SpriteKit粒子模型
class JudgementLineSKParticle {
    let x: CGFloat
    var y: CGFloat
    let color: Color
    let size: CGFloat
    let opacity: Double
    let speed: CGFloat
    let node: SKShapeNode
    
    init(x: CGFloat, y: CGFloat, color: Color, size: CGFloat, opacity: Double, speed: CGFloat) {
        self.x = x
        self.y = y
        self.color = color
        self.size = size
        self.opacity = opacity
        self.speed = speed
        
        node = SKShapeNode(circleOfRadius: size / 2)
        node.fillColor = UIColor(color)
        node.strokeColor = .clear
        node.position = CGPoint(x: x, y: y)
        node.alpha = opacity
        node.zPosition = 5
    }
}

#Preview {
    OptimizedJudgementLine()
        .background(Color.black)
}
