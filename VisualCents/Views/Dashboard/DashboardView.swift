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
                MonthNavigator(selectedDate: $selectedDate)
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
    
    // MARK: - Summary Card
    
    private var summaryCard: some View {
        HStack(spacing: theme.padding) {
            // Income
            SummaryItem(
                title: "收入",
                amount: monthData.totalIncome,
                color: theme.incomeGreen
            )
            
            // Expense
            SummaryItem(
                title: "支出",
                amount: monthData.totalExpense,
                color: theme.expenseRed
            )
            
            // Balance
            SummaryItem(
                title: "结余",
                amount: monthData.balance,
                color: monthData.balance >= 0 ? theme.incomeGreen : theme.expenseRed
            )
        }
        .padding(theme.padding)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cardCornerRadius))
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
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(theme.textTertiary)
            
            Text("今天暂无交易")
                .font(theme.customFont(size: 15, weight: .medium))
                .foregroundStyle(theme.textSecondary)
            
            Button {
                theme.mediumHaptic()
                showAddTransaction = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("添加一笔")
                        .font(theme.customFont(size: 14, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(theme.primaryAccent)
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cardCornerRadius))
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
        HStack(spacing: 8) {
            Button {
                navigateMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.textSecondary)
            }
            
            Button {
                navigateMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(canGoForward ? theme.textSecondary : theme.textTertiary)
            }
            .disabled(!canGoForward)
        }
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

// MARK: - Summary Item

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
            
            Text(formatAmount())
                .font(theme.amountFont(size: 16))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func formatAmount() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0"
    }
}

// MARK: - Transaction Card

struct TransactionCard: View {
    @Environment(\.appTheme) private var theme
    
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 14) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: transaction.category?.iconName ?? "ellipsis.circle")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(categoryColor)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.merchantName)
                    .font(theme.customFont(size: 15, weight: .medium))
                    .foregroundStyle(theme.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text(transaction.category?.name ?? "未分类")
                        .font(theme.customFont(size: 12, weight: .regular))
                        .foregroundStyle(theme.textTertiary)
                    
                    if let notes = transaction.notes, !notes.isEmpty {
                        Text("• \(notes)")
                            .font(theme.customFont(size: 12, weight: .regular))
                            .foregroundStyle(theme.textTertiary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // Amount
            Text(formatAmount())
                .font(theme.amountFont(size: 16))
                .foregroundStyle(transaction.isExpense ? theme.expenseRed : theme.incomeGreen)
        }
        .padding(theme.padding)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
    }
    
    private var categoryColor: Color {
        if let hex = transaction.category?.colorHex {
            return Color(hex: hex)
        }
        return theme.textSecondary
    }
    
    private func formatAmount() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        let prefix = transaction.isExpense ? "-" : "+"
        return prefix + (formatter.string(from: transaction.amount as NSDecimalNumber) ?? "¥0")
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
