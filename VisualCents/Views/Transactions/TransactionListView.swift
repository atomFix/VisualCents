//
//  TransactionListView.swift
//  VisualCents
//
//  Transaction list with filters and swipe actions with theme support
//

import SwiftUI
import SwiftData

/// Full transaction list with grouping and filters
struct TransactionListView: View {
    // MARK: - Environment
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query private var categories: [Category]
    
    // MARK: - State
    
    @State private var searchText = ""
    @State private var selectedFilter: TransactionFilter = .all
    @State private var showAddTransaction = false
    
    // MARK: - Computed
    
    private var filteredTransactions: [Transaction] {
        var result = transactions
        
        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .income:
            result = result.filter { !$0.isExpense }
        case .expense:
            result = result.filter { $0.isExpense }
        }
        
        // Apply search
        if !searchText.isEmpty {
            result = result.filter {
                $0.merchantName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    private var groupedTransactions: [(date: Date, transactions: [Transaction])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredTransactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }
        
        return grouped.map { (date: $0.key, transactions: $0.value) }
            .sorted { $0.date > $1.date }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Pills
            filterPills
                .padding(.horizontal, theme.padding)
                .padding(.vertical, 12)
            
            // Transaction List
            if groupedTransactions.isEmpty {
                emptyState
            } else {
                transactionList
            }
        }
        .background(theme.background)
        .navigationTitle("明细")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "搜索交易...")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    theme.mediumHaptic()
                    showAddTransaction = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(theme.primaryAccent)
                }
            }
        }
        .sheet(isPresented: $showAddTransaction) {
            ManualEntryView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Filter Pills
    
    private var filterPills: some View {
        HStack(spacing: 12) {
            ForEach(TransactionFilter.allCases, id: \.self) { filter in
                FilterPill(
                    title: filter.title,
                    isSelected: selectedFilter == filter
                ) {
                    theme.mediumHaptic()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedFilter = filter
                    }
                }
            }
            Spacer()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(theme.textTertiary)
            
            Text("暂无交易记录")
                .font(theme.customFont(size: 17, weight: .semibold))
                .foregroundStyle(theme.textSecondary)
            
            Text("添加你的第一笔交易吧")
                .font(theme.customFont(size: 15, weight: .regular))
                .foregroundStyle(theme.textTertiary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Transaction List
    
    private var transactionList: some View {
        List {
            ForEach(groupedTransactions, id: \.date) { group in
                Section {
                    ForEach(group.transactions) { transaction in
                        TransactionListRow(transaction: transaction)
                            .listRowBackground(theme.cardBackground)
                            .listRowSeparatorTint(theme.cardBackgroundElevated)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteTransaction(transaction)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                    }
                } header: {
                    DateSectionHeader(date: group.date)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    // MARK: - Actions
    
    private func deleteTransaction(_ transaction: Transaction) {
        theme.errorHaptic()
        withAnimation {
            modelContext.delete(transaction)
        }
    }
}

// MARK: - Transaction Filter

enum TransactionFilter: CaseIterable {
    case all, income, expense
    
    var title: String {
        switch self {
        case .all: return "全部"
        case .income: return "收入"
        case .expense: return "支出"
        }
    }
}

// MARK: - Filter Pill

struct FilterPill: View {
    @Environment(\.appTheme) private var theme
    
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(theme.customFont(size: 12, weight: .medium))
                .foregroundStyle(isSelected ? .white : theme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? theme.primaryAccent : theme.cardBackground)
                .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Date Section Header

struct DateSectionHeader: View {
    @Environment(\.appTheme) private var theme
    let date: Date
    
    private var displayText: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今天"
        } else if calendar.isDateInYesterday(date) {
            return "昨天"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日 EEEE"
            formatter.locale = Locale(identifier: "zh_CN")
            return formatter.string(from: date)
        }
    }
    
    var body: some View {
        Text(displayText)
            .font(theme.customFont(size: 12, weight: .medium))
            .foregroundStyle(theme.textTertiary)
            .textCase(nil)
    }
}

// MARK: - Transaction List Row

struct TransactionListRow: View {
    @Environment(\.appTheme) private var theme
    
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: categoryIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(categoryColor)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.merchantName)
                    .font(theme.customFont(size: 15, weight: .medium))
                    .foregroundStyle(theme.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text(transaction.category?.name ?? "未分类")
                        .font(theme.customFont(size: 11, weight: .regular))
                        .foregroundStyle(theme.textTertiary)
                    
                    if let notes = transaction.notes, !notes.isEmpty {
                        Text("•")
                            .foregroundStyle(theme.textTertiary)
                        Text(notes)
                            .font(theme.customFont(size: 11, weight: .regular))
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
        .padding(.vertical, 4)
    }
    
    private var categoryColor: Color {
        if let hex = transaction.category?.colorHex {
            return Color(hex: hex)
        }
        return theme.textSecondary
    }
    
    private var categoryIcon: String {
        transaction.category?.iconName ?? "ellipsis.circle.fill"
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
        TransactionListView()
    }
    .modelContainer(for: [Transaction.self, Category.self, Budget.self], inMemory: true)
    .environment(\.appTheme, CharcoalTheme())
}
