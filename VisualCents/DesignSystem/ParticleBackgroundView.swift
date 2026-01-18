//
//  ParticleBackgroundView.swift
//  VisualCents
//
//  动态粒子背景 - 为主题注入生命力
//

import SwiftUI

/// 粒子背景视图
struct ParticleBackgroundView: View {
    @Environment(\.appTheme) private var theme

    var particleCount: Int = 30
    var animationSpeed: Double = 1.0

    var body: some View {
        #if canImport(Vortex)
        vortexBackground
        #else
        nativeParticleBackground
        #endif
    }

    private var vortexBackground: some View {
        // TODO: 等添加 Vortex 库后实现
        Color.clear
    }

    private var nativeParticleBackground: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景色
                theme.background
                    .ignoresSafeArea()

                // 浮动粒子
                ForEach(0..<particleCount, id: \.self) { index in
                    Particle(
                        index: index,
                        size: geometry.size,
                        speed: animationSpeed
                    )
                }
            }
        }
    }
}

/// 单个粒子
private struct Particle: View {
    let index: Int
    let size: CGSize
    let speed: Double

    @State private var position: CGPoint = .zero
    @State private var opacity: Double = 0
    @State private var scale: Double = 1.0

    init(index: Int, size: CGSize, speed: Double) {
        self.index = index
        self.size = size
        self.speed = speed
    }

    var body: some View {
        @Environment(\.appTheme) var theme

        Circle()
            .fill(theme.textTertiary.opacity(0.15))  // 深色粒子，半透明
            .frame(width: CGFloat.random(in: 3...8))  // 增加粒子大小
            .position(position)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                // 随机初始位置
                position = CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                )

                // 启动动画 - 增加不透明度范围
                withAnimation(
                    .linear(duration: Double.random(in: 10...20) / speed)
                    .repeatForever(autoreverses: false)
                ) {
                    opacity = Double.random(in: 0.25...0.6)  // 更明显的不透明度
                }

                // 漂浮动画
                withAnimation(
                    .easeInOut(duration: Double.random(in: 15...25) / speed)
                    .repeatForever(autoreverses: true)
                ) {
                    let newX = CGFloat.random(in: 0...size.width)
                    let newY = CGFloat.random(in: 0...size.height)
                    position = CGPoint(x: newX, y: newY)
                }

                // 缩放脉动
                withAnimation(
                    .easeInOut(duration: Double.random(in: 3...7) / speed)
                    .repeatForever(autoreverses: true)
                ) {
                    scale = Double.random(in: 0.8...1.2)
                }
            }
    }
}

/// 金币雨特效（完成目标时使用）
struct CoinRainView: View {
    @State private var isActive = false

    var body: some View {
        ZStack {
            if isActive {
                GeometryReader { geometry in
                    ForEach(0..<30, id: \.self) { index in
                        CoinParticle(
                            index: index,
                            size: geometry.size
                        )
                    }
                }
                .allowsHitTesting(false)
            }
        }
        .onAppear {
            // 3秒后自动消失
            if isActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isActive = false
                }
            }
        }
    }

    func trigger() {
        isActive = true
    }
}

/// 单个金币粒子
private struct CoinParticle: View {
    let index: Int
    let size: CGSize

    @State private var position: CGPoint = .zero
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0

    init(index: Int, size: CGSize) {
        self.index = index
        self.size = size
    }

    var body: some View {
        Image(systemName: "dollarsign.circle.fill")
            .font(.system(size: 24))
            .foregroundStyle(
                LinearGradient(
                    colors: [.yellow, .orange],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .rotationEffect(.degrees(rotation))
            .position(position)
            .opacity(opacity)
            .onAppear {
                // 从顶部随机位置开始
                position = CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: -50
                )

                withAnimation(.easeIn(duration: 2.5)) {
                    position = CGPoint(
                        x: CGFloat.random(in: 0...size.width),
                        y: size.height + 50
                    )
                    opacity = 1
                    rotation = Double.random(in: 0...720)
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        opacity = 0
                    }
                }
            }
    }
}

// MARK: - 使用示例

/*
 使用示例：

 1. 添加全局粒子背景：
    ZStack {
        ParticleBackgroundView(particleCount: 30)

        // 你的内容
        ContentView()
    }

 2. 完成目标时的金币雨：
    ZStack {
        ContentView()

        if showCoinRain {
            CoinRainView()
                .onAppear {
                    // 触发金币雨
                }
        }
    }

 3. 调整粒子数量和速度：
    ParticleBackgroundView(
        particleCount: 50,
        animationSpeed: 0.5
    )
*/
