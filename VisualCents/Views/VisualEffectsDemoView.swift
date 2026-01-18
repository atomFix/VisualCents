//
//  VisualEffectsDemoView.swift
//  VisualCents
//
//  完整的视觉效果演示页面
//

import SwiftUI

/// 视觉效果演示页面 - 展示所有可用的视觉魔法效果
struct VisualEffectsDemoView: View {
    @Environment(\.appTheme) private var theme

    @State private var demoAmount: Double = 0
    @State private var selectedDate = Date()
    @State private var showShimmer = false
    @State private var transactionDates: [Date] = []

    var body: some View {
        ZStack {
            // 粒子背景
            ParticleBackgroundView(particleCount: 30, animationSpeed: 1.0)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            ScrollView {
                VStack(spacing: 24) {
                    // 标题
                    header

                    // 1. 数字滚动动画
                    numberTickerSection

                    // 2. 手绘风格卡片
                    sketchyCardSection

                    // 3. 手绘按钮
                    sketchyButtonSection

                    // 4. 手绘标签
                    sketchyBadgeSection

                    // 5. 加载动画
                    shimmerSection

                    // 6. 自定义日历
                    calendarSection

                    // 底部间距
                    Spacer()
                        .frame(height: 60)
                }
                .padding(theme.padding)
            }
        }
        .navigationTitle("视觉魔法演示")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            // 启动演示动画
            startDemoAnimations()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            Text("✨ VisualCents 视觉效果库")
                .font(theme.customFont(size: 24, weight: .bold))
                .foregroundStyle(theme.textPrimary)

            Text("展示所有可用的视觉魔法效果")
                .font(theme.customFont(size: 14, weight: .regular))
                .foregroundStyle(theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(theme.cardBackground.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Number Ticker Section

    private var numberTickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("1. 数字滚动动画 (NumberTicker)")
                .font(theme.customFont(size: 18, weight: .semibold))
                .foregroundStyle(theme.textPrimary)

            SketchyCardView {
                VStack(spacing: 16) {
                    HStack {
                        Text("本月支出")
                            .font(theme.customFont(size: 14, weight: .medium))
                            .foregroundStyle(theme.textTertiary)

                        Spacer()

                        // 使用数字滚动
                        NumberTicker(
                            value: demoAmount,
                            currency: "¥",
                            precision: 2
                        )
                        .font(theme.amountFont(size: 24))
                        .foregroundStyle(theme.expenseRed)
                    }

                    // 重置按钮
                    Button {
                        withAnimation(.easeInOut(duration: 1.5)) {
                            demoAmount = Double.random(in: 1000...5000)
                        }
                        theme.lightHaptic()
                    } label: {
                        Text("随机金额")
                            .font(theme.customFont(size: 14, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(theme.primaryAccent)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    // MARK: - Sketchy Card Section

    private var sketchyCardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("2. 手绘风格卡片 (SketchyCardView)")
                .font(theme.customFont(size: 18, weight: .semibold))
                .foregroundStyle(theme.textPrimary)

            HStack(spacing: 12) {
                SketchyCardView {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 24))
                            .foregroundStyle(theme.incomeGreen)

                        Text("收入趋势")
                            .font(theme.customFont(size: 14, weight: .semibold))
                            .foregroundStyle(theme.textPrimary)

                        Text("+12.5%")
                            .font(theme.customFont(size: 20, weight: .bold))
                            .foregroundStyle(theme.incomeGreen)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                SketchyCardView {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "chart.line.downtrend.xyaxis")
                            .font(.system(size: 24))
                            .foregroundStyle(theme.expenseRed)

                        Text("支出分析")
                            .font(theme.customFont(size: 14, weight: .semibold))
                            .foregroundStyle(theme.textPrimary)

                        Text("-8.3%")
                            .font(theme.customFont(size: 20, weight: .bold))
                            .foregroundStyle(theme.expenseRed)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    // MARK: - Sketchy Button Section

    private var sketchyButtonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("3. 手绘按钮 (SketchyButton)")
                .font(theme.customFont(size: 18, weight: .semibold))
                .foregroundStyle(theme.textPrimary)

            VStack(spacing: 12) {
                // 主要按钮
                SketchyButton {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("保存交易")
                    }
                } action: {
                    theme.successHaptic()
                    MicroInteractionService.shared.celebrateTransactionSaved()
                }

                // 次要按钮
                SketchySecondaryButton {
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text("取消操作")
                    }
                } action: {
                    theme.lightHaptic()
                }
            }
        }
    }

    // MARK: - Sketchy Badge Section

    private var sketchyBadgeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("4. 手绘标签 (SketchyBadge)")
                .font(theme.customFont(size: 18, weight: .semibold))
                .foregroundStyle(theme.textPrimary)

            SketchyCardView {
                VStack(spacing: 12) {
                    HStack {
                        Text("交易类别")
                            .font(theme.customFont(size: 14, weight: .medium))
                            .foregroundStyle(theme.textTertiary)

                        Spacer()
                    }

                    FlowLayout(spacing: 8) {
                        SketchyBadge(text: "餐饮", color: .blue)
                        SketchyBadge(text: "购物", color: .purple)
                        SketchyBadge(text: "交通", color: .orange)
                        SketchyBadge(text: "娱乐", color: .pink)
                        SketchyBadge(text: "医疗", color: .red)
                        SketchyBadge(text: "教育", color: .green)
                    }
                }
            }
        }
    }

    // MARK: - Shimmer Loading Section

    private var shimmerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("5. 加载动画 (ShimmerLoadingView)")
                .font(theme.customFont(size: 18, weight: .semibold))
                .foregroundStyle(theme.textPrimary)

            SketchyCardView {
                VStack(spacing: 12) {
                    if showShimmer {
                        VStack(spacing: 12) {
                            Text("正在识别小票...")
                                .font(theme.customFont(size: 14, weight: .medium))
                                .foregroundStyle(theme.textTertiary)

                            // 骨架屏演示
                            ShimmerLoadingView(width: .infinity, height: 20)
                            ShimmerLoadingView(width: .infinity, height: 16)
                            ShimmerLoadingView(width: 120, height: 16)
                            ShimmerLoadingView(width: .infinity, height: 40, cornerRadius: 12)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Text("点击下方按钮查看加载动画效果")
                                .font(theme.customFont(size: 14, weight: .medium))
                                .foregroundStyle(theme.textTertiary)
                                .multilineTextAlignment(.center)

                            SketchyButton {
                                Text("开始演示")
                            } action: {
                                theme.lightHaptic()
                                withAnimation {
                                    showShimmer = true
                                }
                                // 2秒后自动停止
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showShimmer = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Calendar Section

    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("6. 自定义日历 (SimpleCalendarView)")
                .font(theme.customFont(size: 18, weight: .semibold))
                .foregroundStyle(theme.textPrimary)

            SketchyCardView {
                SimpleCalendarView(
                    selectedDate: $selectedDate,
                    hasTransactionDates: transactionDates
                )
            }
        }
    }

    // MARK: - Helpers

    private func startDemoAnimations() {
        // 延迟启动数字动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 1.5)) {
                demoAmount = 3256.78
            }
        }

        // 添加一些演示日期
        let calendar = Calendar.current
        for i in 0..<5 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                transactionDates.append(date)
            }
        }
    }
}

// MARK: - Flow Layout (for badges)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        VisualEffectsDemoView()
    }
    .environment(\.appTheme, CharcoalTheme())
}
