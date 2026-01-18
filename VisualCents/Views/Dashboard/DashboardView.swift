//
//  DashboardView.swift
//  VisualCents
//
//  Main dashboard with Calendar, Summary, and Timeline
//

import SwiftUI
import SwiftData

/// Main dashboard with calendar-based transaction view
struct DashboardView: View {
    // MARK: - Environment
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme
    @Environment(\.openSideMenu) private var openSideMenu
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query private var budgets: [Budget]
    
    // MARK: - State
    
    @State private var selectedDate = Date()
    @State private var showAddTransaction = false
    @State private var showScanReceipt = false
    @State private var calendarService = CalendarService()
    
    // MARK: - Computed
    
    private var currentYear: Int {
        Calendar.current.component(.year, from: selectedDate)
    }
    
    private var currentMonth: Int {
        Calendar.current.component(.month, from: selectedDate)
    }
    
    private var monthData: CalendarService.MonthData {
        calendarService.getMonthData(year: currentYear, month: currentMonth, transactions: transactions)
    }
    
    private var selectedDayTransactions: [Transaction] {
        let calendar = Calendar.current
        return transactions.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    private var totalBudget: Decimal {
        budgets.reduce(Decimal.zero) { $0 + $1.limitAmount }
    }
    
    // MARK: - Body

    var body: some View {
        ZStack {
            // 粒子背景层 - 增加粒子数量和动画速度
            ParticleBackgroundView(particleCount: 40, animationSpeed: 1.2)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // 主内容层
            ScrollView {
            VStack(spacing: theme.padding) {
                // Month Summary Card
                summaryCard
                
                // Calendar
                CalendarView(
                    monthData: monthData,
                    selectedDate: selectedDate,
                    onDateSelected: { date in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedDate = date
                        }
                    }
                )
                
                // Selected Day Timeline
                if !selectedDayTransactions.isEmpty {
                    timelineSection
                } else {
                    emptyDayState
                }
                
                // Bottom padding for safe area
                Spacer()
                    .frame(height: 60)
            }
            .padding(theme.padding)
        }
        .background(theme.background)
        .navigationTitle("明细")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // OCR Scan button
                Button {
                    theme.mediumHaptic()
                    showScanReceipt = true
                } label: {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(theme.secondaryAccent)
                }
                
                // Manual add button
                Button {
                    theme.mediumHaptic()
                    showAddTransaction = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(theme.primaryAccent)
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                // Menu Button
                Button {
                    openSideMenu()
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(theme.textPrimary)
                        .padding(8)
                        .background(theme.cardBackground.opacity(0.5))
                        .clipShape(Circle())
                }
            }
            
            ToolbarItem(placement: .principal) {
                MonthNavigator(selectedDate: $selectedDate)
                    .scaleEffect(0.9) // Adjust scale to fit nicely in title area
            }
        }
        .sheet(isPresented: $showAddTransaction) {
            ManualEntryView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showScanReceipt) {
            ScanReceiptView()
                .presentationDetents([.large])
        }
        }
    }
    
    // MARK: - Summary Card

    private var summaryCard: some View {
        SketchyCardView(cornerRadius: theme.cardCornerRadius) {
            HStack(spacing: theme.padding) {
                // Income
                SketchySummaryItem(
                    title: "收入",
                    amount: monthData.totalIncome,
                    color: theme.incomeGreen,
                    icon: "arrow.up.circle.fill"
                )

                // 垂直分割线
                Rectangle()
                    .fill(theme.textTertiary.opacity(0.2))
                    .frame(width: 1)
                    .overlay(
                        Rectangle()
                            .stroke(theme.textTertiary.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    )

                // Expense
                SketchySummaryItem(
                    title: "支出",
                    amount: monthData.totalExpense,
                    color: theme.expenseRed,
                    icon: "arrow.down.circle.fill"
                )

                // 垂直分割线
                Rectangle()
                    .fill(theme.textTertiary.opacity(0.2))
                    .frame(width: 1)
                    .overlay(
                        Rectangle()
                            .stroke(theme.textTertiary.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    )

                // Balance
                SketchySummaryItem(
                    title: "结余",
                    amount: monthData.balance,
                    color: monthData.balance >= 0 ? theme.incomeGreen : theme.expenseRed,
                    icon: "dollarsign.circle.fill"
                )
            }
        }
    }
    
    // MARK: - Timeline Section
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack {
                Text(formatSelectedDate())
                    .font(theme.customFont(size: 15, weight: .semibold))
                    .foregroundStyle(theme.textPrimary)
                
                Spacer()
                
                Text("\(selectedDayTransactions.count)笔")
                    .font(theme.customFont(size: 13, weight: .medium))
                    .foregroundStyle(theme.textTertiary)
            }
            .padding(.horizontal, 4)
            
            // Transaction Cards
            ForEach(selectedDayTransactions) { transaction in
                TransactionCard(transaction: transaction)
            }
        }
    }
    
    // MARK: - Empty State

    private var emptyDayState: some View {
        SketchyCardView(cornerRadius: theme.cardCornerRadius) {
            VStack(spacing: 20) {
                Image(systemName: "tray")
                    .font(.system(size: 50))
                    .foregroundStyle(theme.textTertiary.opacity(0.6))

                Text("今天暂无交易")
                    .font(theme.customFont(size: 17, weight: .semibold))
                    .foregroundStyle(theme.textSecondary)

                SketchyButton {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("添加第一笔")
                            .font(theme.customFont(size: 16, weight: .semibold))
                    }
                } action: {
                    theme.mediumHaptic()
                    showAddTransaction = true
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
        }
    }
    
    // MARK: - Helpers
    
    private func formatSelectedDate() -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) {
            return "今天"
        } else if calendar.isDateInYesterday(selectedDate) {
            return "昨天"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日 EEEE"
            formatter.locale = Locale(identifier: "zh_CN")
            return formatter.string(from: selectedDate)
        }
    }
}

// MARK: - Month Navigator

struct MonthNavigator: View {
    @Environment(\.appTheme) private var theme
    @Binding var selectedDate: Date

    var body: some View {
        HStack(spacing: 12) {
            // 左箭头按钮 - 手绘风格
            Button {
                navigateMonth(by: -1)
            } label: {
                ZStack {
                    Circle()
                        .fill(theme.cardBackgroundElevated)
                        .frame(width: 32, height: 32)

                    // 手绘圆圈边框
                    Circle()
                        .stroke(
                            theme.textTertiary.opacity(0.3),
                            style: StrokeStyle(lineWidth: 1.2, dash: [3, 2])
                        )
                        .frame(width: 32, height: 32)

                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(theme.textSecondary)
                }
            }

            // 日期显示
            Text(formatDate())
                .font(theme.customFont(size: 16, weight: .semibold))
                .foregroundStyle(theme.textPrimary)
                .frame(minWidth: 80)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.cardBackgroundElevated)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            theme.textTertiary.opacity(0.2),
                            style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                        )
                )
                .onTapGesture {
                    theme.lightHaptic()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedDate = Date()
                    }
                }

            // 右箭头按钮 - 手绘风格
            Button {
                navigateMonth(by: 1)
            } label: {
                ZStack {
                    Circle()
                        .fill(theme.cardBackgroundElevated)
                        .frame(width: 32, height: 32)

                    // 手绘圆圈边框
                    Circle()
                        .stroke(
                            theme.textTertiary.opacity(0.3),
                            style: StrokeStyle(lineWidth: 1.2, dash: [3, 2])
                        )
                        .frame(width: 32, height: 32)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(canGoForward ? theme.textSecondary : theme.textTertiary)
                }
            }
            .disabled(!canGoForward)
            .opacity(canGoForward ? 1 : 0.5)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    theme.textTertiary.opacity(0.15),
                    style: StrokeStyle(lineWidth: 1.5, dash: [8, 4])
                )
        )
    }

    private func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: selectedDate)
    }

    private var canGoForward: Bool {
        let calendar = Calendar.current
        let currentMonth = calendar.dateInterval(of: .month, for: Date())
        let selectedMonth = calendar.dateInterval(of: .month, for: selectedDate)
        return selectedMonth?.start ?? Date() < currentMonth?.start ?? Date()
    }

    private func navigateMonth(by value: Int) {
        theme.lightHaptic()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedDate) {
                selectedDate = newDate
            }
        }
    }
}

// MARK: - Sketchy Summary Item

struct SketchySummaryItem: View {
    @Environment(\.appTheme) private var theme

    let title: String
    let amount: Decimal
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            // 图标
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
            }

            // 标题
            Text(title)
                .font(theme.customFont(size: 12, weight: .medium))
                .foregroundStyle(theme.textTertiary)

            // 金额（使用数字滚动）
            NumberTicker(
                value: doubleValue,
                currency: "¥",
                precision: 0
            )
            .font(theme.amountFont(size: 18))
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private var doubleValue: Double {
        NSDecimalNumber(decimal: amount).doubleValue
    }
}

// MARK: - Transaction Card

struct TransactionCard: View {
    @Environment(\.appTheme) private var theme

    let transaction: Transaction

    var body: some View {
        SketchyCardView(cornerRadius: 12) {
            HStack(spacing: 14) {
                // Category Icon - 手绘风格圆圈
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.15))
                        .frame(width: 50, height: 50)

                    // 手绘圆圈边框
                    Circle()
                        .stroke(
                            categoryColor.opacity(0.3),
                            style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: transaction.category?.iconName ?? "ellipsis.circle")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(categoryColor)
                }

                // Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.merchantName)
                        .font(theme.customFont(size: 16, weight: .semibold))
                        .foregroundStyle(theme.textPrimary)
                        .lineLimit(1)

                    // 手绘标签
                    SketchyBadge(
                        text: transaction.category?.name ?? "未分类",
                        color: categoryColor
                    )
                }

                Spacer()

                // Amount - 使用数字滚动
                VStack(alignment: .trailing, spacing: 2) {
                    NumberTicker(
                        value: transactionAmount,
                        currency: transaction.isExpense ? "-" : "+",
                        precision: 2
                    )
                    .font(theme.amountFont(size: 18))
                    .foregroundStyle(transaction.isExpense ? theme.expenseRed : theme.incomeGreen)

                    Text(transactionTime)
                        .font(theme.customFont(size: 11, weight: .medium))
                        .foregroundStyle(theme.textTertiary)
                }
            }
        }
    }

    private var categoryColor: Color {
        if let hex = transaction.category?.colorHex {
            return Color(hex: hex)
        }
        return theme.textSecondary
    }

    private var transactionAmount: Double {
        NSDecimalNumber(decimal: transaction.amount).doubleValue
    }

    private var transactionTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: transaction.date)
    }
}

// MARK: - Old Summary Item (kept for compatibility)

struct SummaryItem: View {
    @Environment(\.appTheme) private var theme

    let title: String
    let amount: Decimal
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(theme.customFont(size: 11, weight: .medium))
                .foregroundStyle(theme.textTertiary)

            // 使用 NumberTicker 显示数字滚动动画
            NumberTicker(
                value: doubleValue,
                currency: "¥",
                precision: 0
            )
            .font(theme.amountFont(size: 16))
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private var doubleValue: Double {
        NSDecimalNumber(decimal: amount).doubleValue
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DashboardView()
    }
    .modelContainer(for: [Transaction.self, Category.self, Budget.self], inMemory: true)
    .environment(\.appTheme, SoftPopTheme())
}
