//
//  OrganicUIDemoView.swift
//  VisualCents
//
//  完整的有机 UI 演示 - 展示所有生成式和有机组件
//

import SwiftUI

/// 有机 UI 演示页面
struct OrganicUIDemoView: View {
    @Environment(\.appTheme) private var theme

    @State private var inputAmount: String = ""
    @State private var showFluidDemo = false

    var body: some View {
        ZStack {
            // 流体背景
            FluidBackgroundView(flowSpeed: 1.2, intensity: 0.4)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // 标题
                    header

                    // 1. 流体背景介绍
                    fluidSection

                    // 2. Voronoi 预算可视化
                    voronoiSection

                    // 3. 3D 资产卡片
                    asset3DSection

                    // 4. 液体粘性键盘
                    gooeyKeypadSection

                    // 底部间距
                    Spacer()
                        .frame(height: 60)
                }
                .padding(theme.padding)
            }
        }
        .navigationTitle("有机 UI")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            Text("🌊 生成式有机 UI")
                .font(theme.customFont(size: 28, weight: .bold))
                .foregroundStyle(theme.textPrimary)

            Text("打破网格，拥抱流动")
                .font(theme.customFont(size: 16, weight: .medium))
                .foregroundStyle(theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.cardBackground.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(theme.textTertiary.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [8, 4]))
                )
        )
    }

    // MARK: - Fluid Background Section

    private var fluidSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("1. 流体动态背景")
                .font(theme.customFont(size: 20, weight: .semibold))
                .foregroundStyle(theme.textPrimary)

            Text("颜色像液体一样流动，根据支出和储蓄变化")
                .font(theme.customFont(size: 14, weight: .regular))
                .foregroundStyle(theme.textTertiary)
                .padding(.horizontal, 4)

            HStack(spacing: 12) {
                FluidDemoCard(
                    title: "平静状态",
                    description: "储蓄充足",
                    intensity: 0.3,
                    color: theme.incomeGreen
                )

                FluidDemoCard(
                    title: "活跃状态",
                    description: "正常支出",
                    intensity: 0.5,
                    color: theme.primaryAccent
                )

                FluidDemoCard(
                    title: "紧张状态",
                    description: "支出超标",
                    intensity: 0.8,
                    color: theme.expenseRed
                )
            }
        }
    }

    // MARK: - Voronoi Section

    private var voronoiSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("2. Voronoi 预算可视化")
                .font(theme.customFont(size: 20, weight: .semibold))
                .foregroundStyle(theme.textPrimary)

            Text("每个类别是一个有机的多边形，大小代表支出金额")
                .font(theme.customFont(size: 14, weight: .regular))
                .foregroundStyle(theme.textTertiary)
                .padding(.horizontal, 4)

            VoronoiBudgetView(
                categoryData: [
                    (name: "餐饮", amount: 3500, color: .blue),
                    (name: "购物", amount: 2800, color: .purple),
                    (name: "交通", amount: 1200, color: .orange),
                    (name: "娱乐", amount: 1800, color: .pink),
                    (name: "医疗", amount: 800, color: .red),
                    (name: "教育", amount: 2200, color: .green)
                ]
            )
        }
    }

    // MARK: - 3D Asset Section

    private var asset3DSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("3. 3D 资产卡片")
                .font(theme.customFont(size: 20, weight: .semibold))
                .foregroundStyle(theme.textPrimary)

            Text("拖拽旋转卡片，支持陀螺仪视差效果")
                .font(theme.customFont(size: 14, weight: .regular))
                .foregroundStyle(theme.textTertiary)
                .padding(.horizontal, 4)

            Asset3DCardView(
                assetName: "招商银行",
                amount: 12580.50,
                cardColor: .blue,
                cardType: .visa
            )
        }
    }

    // MARK: - Gooey Keypad Section

    private var gooeyKeypadSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("4. 液体粘性键盘")
                .font(theme.customFont(size: 20, weight: .semibold))
                .foregroundStyle(theme.textPrimary)

            Text("按钮像液体一样融合，使用 Metaball 效果")
                .font(theme.customFont(size: 14, weight: .regular))
                .foregroundStyle(theme.textTertiary)
                .padding(.horizontal, 4)

            VStack(spacing: 12) {
                // 输入显示
                if !inputAmount.isEmpty {
                    Text("输入金额: ¥\(inputAmount)")
                        .font(theme.customFont(size: 24, weight: .bold))
                        .foregroundStyle(theme.primaryAccent)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(theme.primaryAccent.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                                )
                        )
                }

                // 粘性键盘
                GooeyKeypad(
                    onNumberPress: { num in
                        if inputAmount.count < 9 {
                            inputAmount += "\(num)"
                        }
                        theme.lightHaptic()
                    },
                    onDelete: {
                        if !inputAmount.isEmpty {
                            inputAmount.removeLast()
                        }
                        theme.lightHaptic()
                    },
                    onClear: {
                        inputAmount = ""
                        theme.mediumHaptic()
                    }
                )
            }
        }
    }
}

// MARK: - Fluid Demo Card

struct FluidDemoCard: View {
    @Environment(\.appTheme) private var theme

    let title: String
    let description: String
    let intensity: Double
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // 流体模拟
                RadialGradient(
                    colors: [
                        color.opacity(0.6),
                        color.opacity(0.2),
                        Color.clear
                    ],
                    center: .topLeading,
                    startRadius: 20,
                    endRadius: 100
                )
                .frame(height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(title)
                    .font(theme.customFont(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text(description)
                .font(theme.customFont(size: 12, weight: .medium))
                .foregroundStyle(theme.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        OrganicUIDemoView()
    }
    .environment(\.appTheme, CharcoalTheme())
}
