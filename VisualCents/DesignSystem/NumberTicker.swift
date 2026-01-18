//
//  NumberTicker.swift
//  VisualCents
//
//  数字滚动动画组件 - 用于金额变化的"灵动"展示
//

import SwiftUI

/// 数字滚动视图
struct NumberTicker: View {
    @Environment(\.appTheme) private var theme

    let value: Double
    let currency: String
    let precision: Int

    @State private var displayedValue: Double = 0
    @State private var animator: CGFloat = 0

    init(value: Double, currency: String = "¥", precision: Int = 2) {
        self.value = value
        self.currency = currency
        self.precision = precision
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(currency)
                .font(theme.amountFont(size: 24))
                .foregroundStyle(theme.textSecondary)

            Text(formattedNumber)
                .font(theme.amountFont(size: 36))
                .foregroundStyle(theme.textPrimary)
                .contentTransition(.numericText())
        }
        .onAppear {
            // 启动动画
            withAnimation(.easeOut(duration: 0.8)) {
                displayedValue = value
            }
        }
        .onChange(of: value) { _, newValue in
            withAnimation(.easeOut(duration: 0.6)) {
                displayedValue = newValue
            }
        }
    }

    private var formattedNumber: String {
        String(format: "%.\(precision)f", displayedValue)
    }
}

/// 带上下箭头的金额视图（增加/减少指示）
struct TrendingAmountView: View {
    @Environment(\.appTheme) private var theme

    let value: Double
    let previousValue: Double?
    let currency: String

    private var change: Double {
        guard let previous = previousValue else { return 0 }
        return value - previous
    }

    private var isIncrease: Bool {
        change >= 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: isIncrease ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isIncrease ? theme.expenseRed : theme.incomeGreen)

                NumberTicker(value: value, currency: currency)
            }

            if let previous = previousValue, previous != value {
                Text("\(previous.formattedCurrency) → \(value.formattedCurrency)")
                    .font(theme.customFont(size: 12, weight: .regular))
                    .foregroundStyle(isIncrease ? theme.expenseRed : theme.incomeGreen)
            }
        }
    }
}

/// 资产卡片滚动金额
struct AnimatedAssetCard: View {
    @Environment(\.appTheme) private var theme

    let title: String
    let amount: Double
    let previousAmount: Double?
    var trendIcon: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(theme.customFont(size: 14, weight: .medium))
                    .foregroundStyle(theme.textSecondary)

                Spacer()

                if let icon = trendIcon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundStyle(theme.textTertiary)
                }
            }

            TrendingAmountView(
                value: amount,
                previousValue: previousAmount,
                currency: "¥"
            )
        }
        .padding(20)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 使用示例

/*
 使用示例：

 1. 基础数字滚动：
    NumberTicker(value: 1234.56, currency: "¥")

 2. 显示趋势（有变化时）：
    TrendingAmountView(
        value: currentAmount,
        previousValue: previousAmount,
        currency: "¥"
    )

 3. 完整的资产卡片：
    AnimatedAssetCard(
        title: "总资产",
        amount: totalAssets,
        previousAmount: previousAssets,
        trendIcon: "chart.line.uptrend.xyaxis"
    )

 4. 在首页使用：
    VStack {
        AnimatedAssetCard(
            title: "本月支出",
            amount: monthlyExpense,
            previousAmount: lastMonthExpense
        )

        AnimatedAssetCard(
            title: "总资产",
            amount: totalAssets,
            previousAmount: nil
        )
    }
*/

// MARK: - Double Extension for Formatting

extension Double {
    func formattedCurrency(symbol: String = "¥") -> String {
        return "\(symbol)\(String(format: "%.2f", self))"
    }
}
