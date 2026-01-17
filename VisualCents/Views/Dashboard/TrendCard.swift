//
//  TrendCard.swift
//  VisualCents
//
//  7-day spending sparkline chart card
//

import SwiftUI
import Charts

/// Data point for the spending trend chart
struct SpendingDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Decimal
    
    var doubleAmount: Double {
        NSDecimalNumber(decimal: amount).doubleValue
    }
}

/// Card showing 7-day spending trend as a sparkline
struct TrendCard: View {
    /// Spending data for the last 7 days
    var dataPoints: [SpendingDataPoint]
    
    /// Animation state
    @State private var animateChart = false
    
    // MARK: - Computed
    
    private var totalSpent: Decimal {
        dataPoints.reduce(Decimal.zero) { $0 + $1.amount }
    }
    
    private var averageDaily: Decimal {
        dataPoints.isEmpty ? 0 : totalSpent / Decimal(dataPoints.count)
    }
    
    private var trend: Trend {
        guard dataPoints.count >= 2 else { return .stable }
        let firstHalf = dataPoints.prefix(dataPoints.count / 2).reduce(Decimal.zero) { $0 + $1.amount }
        let secondHalf = dataPoints.suffix(dataPoints.count / 2).reduce(Decimal.zero) { $0 + $1.amount }
        
        if secondHalf > firstHalf * Decimal(1.1) {
            return .up
        } else if secondHalf < firstHalf * Decimal(0.9) {
            return .down
        } else {
            return .stable
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: VCMetrics.padding) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("7-Day Spending")
                        .font(VCFont.caption())
                        .foregroundStyle(VCColors.textSecondary)
                    
                    Text(formatCurrency(totalSpent))
                        .font(VCFont.amount(24))
                        .foregroundStyle(VCColors.textPrimary)
                        .contentTransition(.numericText())
                }
                
                Spacer()
                
                // Trend indicator
                TrendBadge(trend: trend)
            }
            
            // Sparkline Chart
            if !dataPoints.isEmpty {
                Chart(dataPoints) { point in
                    LineMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Amount", animateChart ? point.doubleAmount : 0)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [VCColors.accent, VCColors.accentSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    
                    AreaMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Amount", animateChart ? point.doubleAmount : 0)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                VCColors.accent.opacity(0.3),
                                VCColors.accent.opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 60)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                        animateChart = true
                    }
                }
            }
            
            // Footer stats
            HStack {
                StatItem(label: "Avg/Day", value: formatCurrency(averageDaily))
                Spacer()
                StatItem(label: "Days", value: "\(dataPoints.count)")
            }
        }
        .padding(VCMetrics.paddingLarge)
        .vcCardStyle(shadowColor: VCColors.accent.opacity(0.2))
    }
    
    // MARK: - Helpers
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0"
    }
}

// MARK: - Trend

enum Trend {
    case up, down, stable
    
    var icon: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }
    
    var color: Color {
        switch self {
        case .up: return VCColors.expense
        case .down: return VCColors.positive
        case .stable: return VCColors.textSecondary
        }
    }
    
    var label: String {
        switch self {
        case .up: return "Increasing"
        case .down: return "Decreasing"
        case .stable: return "Stable"
        }
    }
}

// MARK: - Supporting Views

struct TrendBadge: View {
    let trend: Trend
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: trend.icon)
                .font(.system(size: 10, weight: .bold))
            Text(trend.label)
                .font(VCFont.caption(10))
        }
        .foregroundStyle(trend.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(trend.color.opacity(0.15))
        .clipShape(Capsule())
    }
}

struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(VCFont.caption(10))
                .foregroundStyle(VCColors.textTertiary)
            Text(value)
                .font(VCFont.body())
                .foregroundStyle(VCColors.textSecondary)
        }
    }
}

// MARK: - Preview

#Preview {
    let calendar = Calendar.current
    let today = Date()
    let sampleData = (0..<7).map { dayOffset in
        SpendingDataPoint(
            date: calendar.date(byAdding: .day, value: -dayOffset, to: today)!,
            amount: Decimal(arc4random_uniform(500) + 100)
        )
    }.reversed()
    
    return TrendCard(dataPoints: Array(sampleData))
        .padding()
        .background(VCColors.backgroundPrimary)
}
