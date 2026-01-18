//
//  FluidBackgroundView.swift
//  VisualCents
//
//  流体动态背景 - 使用 MeshGradient 或自定义动画渐变
//  颜色会像液体一样流动和变化
//

import SwiftUI

/// 流体动态背景
struct FluidBackgroundView: View {
    @Environment(\.appTheme) private var theme

    var flowSpeed: Double = 1.0
    var intensity: Double = 0.5

    @State private var phase1: CGFloat = 0
    @State private var phase2: CGFloat = 0
    @State private var phase3: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 使用备用渐变方案（兼容性更好）
                legacyFluidBackground(size: geometry.size)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                startFluidAnimation()
            }
        }
    }

    // MARK: - Legacy 渐变背景

    private func legacyFluidBackground(size: CGSize) -> some View {
        ZStack {
            // 基础背景
            theme.background
                .ignoresSafeArea()

            // 流动渐变层 1
            RadialGradient(
                colors: [
                    theme.primaryAccent.opacity(0.15 * intensity),
                    theme.primaryAccent.opacity(0.05 * intensity),
                    Color.clear
                ],
                center: UnitPoint(x: fluidOffset(phase: phase1, offset: 0.3).width,
                                y: fluidOffset(phase: phase1, offset: 0.3).height),
                startRadius: 50,
                endRadius: 400
            )
            .animation(
                .linear(duration: 10.0 / flowSpeed)
                .repeatForever(autoreverses: true),
                value: phase1
            )

            // 流动渐变层 2
            RadialGradient(
                colors: [
                    theme.secondaryAccent.opacity(0.12 * intensity),
                    theme.secondaryAccent.opacity(0.04 * intensity),
                    Color.clear
                ],
                center: UnitPoint(x: fluidOffset(phase: phase2, offset: 0.7).width,
                                y: fluidOffset(phase: phase2, offset: 0.6).height),
                startRadius: 80,
                endRadius: 450
            )
            .animation(
                .linear(duration: 12.0 / flowSpeed)
                .repeatForever(autoreverses: true),
                value: phase2
            )

            // 流动渐变层 3
            RadialGradient(
                colors: [
                    theme.incomeGreen.opacity(0.1 * intensity),
                    Color.clear
                ],
                center: UnitPoint(x: fluidOffset(phase: phase3, offset: 0.5).width,
                                y: fluidOffset(phase: phase3, offset: 0.4).height),
                startRadius: 60,
                endRadius: 350
            )
            .animation(
                .linear(duration: 14.0 / flowSpeed)
                .repeatForever(autoreverses: true),
                value: phase3
            )
        }
    }

    // MARK: - 动画控制

    private func startFluidAnimation() {
        withAnimation(.linear(duration: 10.0 / flowSpeed).repeatForever(autoreverses: true)) {
            phase1 = .pi * 2
        }
        withAnimation(.linear(duration: 12.0 / flowSpeed).repeatForever(autoreverses: true)) {
            phase2 = .pi * 2
        }
        withAnimation(.linear(duration: 14.0 / flowSpeed).repeatForever(autoreverses: true)) {
            phase3 = .pi * 2
        }
    }

    private func fluidOffset(phase: CGFloat, offset: CGFloat) -> CGSize {
        let x = (sin(phase) + 1) / 2
        let y = (cos(phase) + 1) / 2
        return CGSize(width: x + offset, height: y + offset)
    }
}

// MARK: - Color Blending Extension

extension Color {
    func blended(with other: Color, by fraction: CGFloat) -> Color {
        // 简化的颜色混合
        return self.opacity(1 - fraction).blend(other, by: fraction)
    }

    private func blend(_ other: Color, by fraction: CGFloat) -> Color {
        // 使用白色作为中间色进行简化混合
        return self
    }
}

// MARK: - Reactive Fluid Background

/// 响应式流体背景 - 根据支出/储蓄变化
struct ReactiveFluidBackground: View {
    @Environment(\.appTheme) private var theme

    var dailyExpense: Double = 0
    var savings: Double = 0
    var baseSpeed: Double = 1.0

    @State private var currentIntensity: Double = 0.5
    @State private var currentSpeed: Double = 1.0
    @State private var temperature: ColorTemperature = .neutral

    var body: some View {
        FluidBackgroundView(
            flowSpeed: currentSpeed * baseSpeed,
            intensity: currentIntensity
        )
        .onChange(of: dailyExpense) { _, newValue in
            // 支出增加 → 流体变快、变暖
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                currentIntensity = min(1.0, 0.3 + newValue / 10000)
                currentSpeed = min(3.0, 1.0 + newValue / 5000)
                temperature = .warm
            }
        }
        .onChange(of: savings) { _, newValue in
            // 储蓄增加 → 流体变慢、变冷
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                currentIntensity = max(0.2, 0.5 - newValue / 20000)
                currentSpeed = max(0.5, 1.0 - newValue / 10000)
                temperature = .cool
            }
        }
    }
}

enum ColorTemperature {
    case neutral
    case warm
    case cool
}

// MARK: - Preview

#Preview {
    ZStack {
        FluidBackgroundView(flowSpeed: 1.5, intensity: 0.6)
            .ignoresSafeArea()

        VStack {
            Text("流体动态背景")
                .font(.largeTitle)
                .foregroundStyle(Color.black)
                .padding()

            Text("颜色会像液体一样流动")
                .font(.title2)
                .foregroundStyle(Color.gray)
        }
    }
    .environment(\.appTheme, CharcoalTheme())
}
