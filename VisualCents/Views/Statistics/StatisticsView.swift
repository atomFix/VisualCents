//
//  StatisticsView.swift
//  VisualCents
//
//  Statistics page with day/month/year views
//

import SwiftUI
import SwiftData
import Charts

/// Time period for statistics display
enum StatsPeriod: String, CaseIterable {
    case day = "日"
    case month = "月"
    case year = "年"
}

/// Statistics view with period selector
struct StatisticsView: View {
    // MARK: - Environment
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query private var categories: [Category]
    
    // MARK: - State
    
    @State private var selectedPeriod: StatsPeriod = .month
    @State private var selectedDate = Date()
    @State private var animateCharts = false
    
    // MARK: - Computed
    
    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        return transactions.filter { transaction in
            switch selectedPeriod {
            case .day:
                return calendar.isDate(transaction.date, inSameDayAs: selectedDate)
            case .month:
                return calendar.isDate(transaction.date, equalTo: selectedDate, toGranularity: .month)
            case .year:
                return calendar.isDate(transaction.date, equalTo: selectedDate, toGranularity: .year)
            }
        }
    }
    
    private var totalIncome: Decimal {
        filteredTransactions.filter { !$0.isExpense }.reduce(Decimal.zero) { $0 + $1.amount }
    }
    
    private var totalExpense: Decimal {
        filteredTransactions.filter { $0.isExpense }.reduce(Decimal.zero) { $0 + $1.amount }
    }
    
    private var balance: Decimal {
        totalIncome - totalExpense
    }
    
    private var categoryBreakdown: [(category: String, amount: Double, color: Color)] {
        var breakdown: [String: (amount: Decimal, color: Color)] = [:]
        
        for transaction in filteredTransactions.filter({ $0.isExpense }) {
            let categoryName = transaction.category?.name ?? "Other"
            let color = transaction.category.map { Color(hex: $0.colorHex) } ?? theme.textSecondary
            
            if let existing = breakdown[categoryName] {
                breakdown[categoryName] = (existing.amount + transaction.amount, color)
            } else {
                breakdown[categoryName] = (transaction.amount, color)
            }
        }
        
        return breakdown.map { (category: $0.key, amount: NSDecimalNumber(decimal: $0.value.amount).doubleValue, color: $0.value.color) }
            .sorted { $0.amount > $1.amount }
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: theme.padding) {
                // Period Selector
                periodSelector
                
                // Summary Cards
                summaryCards
                
                // Category Breakdown Chart
                if !categoryBreakdown.isEmpty {
                    categoryChart
                }
                
                // Daily/Monthly Trend
                trendSection
            }
            .padding(theme.padding)
        }
        .background(theme.background)
        .navigationTitle("统计")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                animateCharts = true
            }
        }
    }
    
    // MARK: - Period Selector
    
    private var periodSelector: some View {
        HStack(spacing: 0) {
            ForEach(StatsPeriod.allCases, id: \.self) { period in
                Button {
                    theme.mediumHaptic()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedPeriod = period
                        animateCharts = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            animateCharts = true
                        }
                    }
                } label: {
                    Text(period.rawValue)
                        .font(theme.customFont(size: 17, weight: .semibold))
                        .foregroundStyle(selectedPeriod == period ? .white : theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedPeriod == period ?
                            theme.primaryAccent : Color.clear
                        )
                }
            }
        }
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.buttonCornerRadius))
    }
    
    // MARK: - Summary Cards
    
    private var summaryCards: some View {
        HStack(spacing: theme.padding) {
            SummaryCard(
                title: "收入",
                amount: totalIncome,
                color: theme.incomeGreen,
                icon: "arrow.down.circle.fill"
            )
            
            SummaryCard(
                title: "支出",
                amount: totalExpense,
                color: theme.expenseRed,
                icon: "arrow.up.circle.fill"
            )
            
            SummaryCard(
                title: "结余",
                amount: balance,
                color: balance >= 0 ? theme.incomeGreen : theme.expenseRed,
                icon: "equal.circle.fill"
            )
        }
    }
    
    // MARK: - Category Chart
    
    private var categoryChart: some View {
        VStack(alignment: .leading, spacing: theme.padding) {
            Text("支出分类")
                .font(theme.customFont(size: 17, weight: .semibold))
                .foregroundStyle(theme.textPrimary)
            
            Chart(categoryBreakdown, id: \.category) { item in
                SectorMark(
                    angle: .value("Amount", animateCharts ? item.amount : 0),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(item.color)
                .cornerRadius(4)
            }
            .frame(height: 200)
            
            // Legend
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(categoryBreakdown.prefix(6), id: \.category) { item in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 10, height: 10)
                        Text(item.category)
                            .font(theme.customFont(size: 12, weight: .medium))
                            .foregroundStyle(theme.textSecondary)
                            .lineLimit(1)
                        Spacer()
                    }
                }
            }
        }
        .padding(theme.paddingLarge)
        .background(
            theme.styleCard(EmptyView())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
    
    // MARK: - Trend Section
    
    private var trendSection: some View {
        VStack(alignment: .leading, spacing: theme.padding) {
            Text("趋势")
                .font(theme.customFont(size: 17, weight: .semibold))
                .foregroundStyle(theme.textPrimary)
            
            if filteredTransactions.isEmpty {
                Text("暂无数据")
                    .font(theme.customFont(size: 15, weight: .regular))
                    .foregroundStyle(theme.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                Text("\(filteredTransactions.count) 笔交易")
                    .font(theme.customFont(size: 15, weight: .regular))
                    .foregroundStyle(theme.textSecondary)
            }
        }
        .padding(theme.paddingLarge)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            theme.styleCard(EmptyView())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
}

// MARK: - Summary Card

struct SummaryCard: View {
    @Environment(\.appTheme) private var theme
    
    let title: String
    let amount: Decimal
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(formatCurrency(amount))
                .font(theme.amountFont(size: 16))
                .foregroundStyle(theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(title)
                .font(theme.customFont(size: 11, weight: .medium))
                .foregroundStyle(theme.textTertiary)
        }
        .padding(theme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.buttonCornerRadius))
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0"
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        StatisticsView()
    }
    .modelContainer(for: [Transaction.self, Category.self, Budget.self], inMemory: true)
    .environment(\.appTheme, CharcoalTheme())
}
