//
//  BudgetPlanningView.swift
//  VisualCents
//
//  Budget management view with theme support
//

import SwiftUI
import SwiftData

/// Budget planning and management view
struct BudgetPlanningView: View {
    // MARK: - Environment
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme
    @Query private var categories: [Category]
    @Query private var budgets: [Budget]
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    // MARK: - State
    
    @State private var showAddBudget = false
    @State private var selectedCategory: Category?
    
    // MARK: - Computed
    
    private var totalBudget: Decimal {
        budgets.reduce(Decimal.zero) { $0 + $1.limitAmount }
    }
    
    private var totalSpent: Decimal {
        let startOfMonth = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
        return transactions
            .filter { $0.isExpense && $0.date >= startOfMonth }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: theme.padding) {
                // Overview Card
                overviewCard
                
                // Category Budgets
                categoryBudgetsList
            }
            .padding(theme.padding)
        }
        .background(theme.background)
        .navigationTitle("预算")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    theme.mediumHaptic()
                    showAddBudget = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(theme.primaryAccent)
                }
            }
        }
        .sheet(isPresented: $showAddBudget) {
            AddBudgetSheet(categories: categories)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Overview Card
    
    private var overviewCard: some View {
        VStack(spacing: theme.padding) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("本月预算概览")
                        .font(theme.customFont(size: 13, weight: .medium))
                        .foregroundStyle(theme.textSecondary)
                    
                    Text(formatCurrency(totalBudget))
                        .font(theme.heroFont(size: 32))
                        .foregroundStyle(theme.textPrimary)
                }
                
                Spacer()
                
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(theme.cardBackgroundElevated, lineWidth: 8)
                    
                    Circle()
                        .trim(from: 0, to: min(progress, 1.0))
                        .stroke(progressColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(progress * 100))%")
                        .font(theme.customFont(size: 11, weight: .bold))
                        .foregroundStyle(theme.textSecondary)
                }
                .frame(width: 60, height: 60)
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("已使用")
                        .font(theme.customFont(size: 11, weight: .medium))
                        .foregroundStyle(theme.textTertiary)
                    Spacer()
                    Text(formatCurrency(totalSpent))
                        .font(theme.customFont(size: 15, weight: .medium))
                        .foregroundStyle(progressColor)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(theme.cardBackgroundElevated)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(progressColor)
                            .frame(width: geo.size.width * min(progress, 1.0))
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(theme.paddingLarge)
        .background(
            theme.styleCard(EmptyView())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
    
    private var progress: Double {
        guard totalBudget > 0 else { return 0 }
        return NSDecimalNumber(decimal: totalSpent / totalBudget).doubleValue
    }
    
    private var progressColor: Color {
        if progress >= 1.0 { return theme.expenseRed }
        if progress >= 0.8 { return theme.warningYellow }
        return theme.incomeGreen
    }
    
    // MARK: - Category Budgets List
    
    private var categoryBudgetsList: some View {
        VStack(alignment: .leading, spacing: theme.padding) {
            Text("分类预算")
                .font(theme.customFont(size: 17, weight: .semibold))
                .foregroundStyle(theme.textPrimary)
            
            if budgets.isEmpty {
                emptyState
            } else {
                ForEach(budgets) { budget in
                    BudgetCategoryRow(
                        budget: budget,
                        spent: calculateSpent(for: budget)
                    )
                }
            }
        }
        .padding(theme.paddingLarge)
        .background(
            theme.styleCard(EmptyView())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 40))
                .foregroundStyle(theme.textTertiary)
            
            Text("暂无预算")
                .font(theme.customFont(size: 15, weight: .medium))
                .foregroundStyle(theme.textSecondary)
            
            Text("点击右上角添加预算")
                .font(theme.customFont(size: 12, weight: .regular))
                .foregroundStyle(theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
    
    // MARK: - Helpers
    
    private func calculateSpent(for budget: Budget) -> Decimal {
        guard let category = budget.category else { return 0 }
        let startOfMonth = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
        
        return transactions
            .filter { $0.isExpense && $0.category?.id == category.id && $0.date >= startOfMonth }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0"
    }
}

// MARK: - Budget Category Row

struct BudgetCategoryRow: View {
    @Environment(\.appTheme) private var theme
    
    let budget: Budget
    let spent: Decimal
    
    private var progress: Double {
        guard budget.limitAmount > 0 else { return 0 }
        return NSDecimalNumber(decimal: spent / budget.limitAmount).doubleValue
    }
    
    private var progressColor: Color {
        if progress >= 1.0 { return theme.expenseRed }
        if progress >= 0.8 { return theme.warningYellow }
        return theme.incomeGreen
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Icon
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: budget.category?.iconName ?? "ellipsis.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(categoryColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(budget.category?.name ?? "未分类")
                        .font(theme.customFont(size: 15, weight: .medium))
                        .foregroundStyle(theme.textPrimary)
                    
                    Text("\(formatCurrency(spent)) / \(formatCurrency(budget.limitAmount))")
                        .font(theme.customFont(size: 12, weight: .regular))
                        .foregroundStyle(theme.textTertiary)
                }
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(theme.amountFont(size: 14))
                    .foregroundStyle(progressColor)
            }
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(theme.cardBackgroundElevated)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(progressColor)
                        .frame(width: geo.size.width * min(progress, 1.0))
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 8)
    }
    
    private var categoryColor: Color {
        if let hex = budget.category?.colorHex {
            return Color(hex: hex)
        }
        return theme.textSecondary
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0"
    }
}

// MARK: - Add Budget Sheet

struct AddBudgetSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme
    
    let categories: [Category]
    
    @State private var selectedCategory: Category?
    @State private var budgetAmount: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: theme.paddingLarge) {
                // Category picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("选择分类")
                        .font(theme.customFont(size: 11, weight: .medium))
                        .foregroundStyle(theme.textSecondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categories) { category in
                                let isSelected = selectedCategory?.id == category.id
                                CategoryBubble(
                                    category: category,
                                    isSelected: isSelected
                                ) {
                                    selectCategory(category)
                                }
                            }
                        }
                    }
                }
                
                // Amount input
                VStack(alignment: .leading, spacing: 8) {
                    Text("预算金额")
                        .font(theme.customFont(size: 11, weight: .medium))
                        .foregroundStyle(theme.textSecondary)
                    
                    TextField("0", text: $budgetAmount)
                        .font(theme.heroFont(size: 36))
                        .foregroundStyle(theme.textPrimary)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(theme.cardBackgroundElevated)
                        .clipShape(RoundedRectangle(cornerRadius: theme.buttonCornerRadius))
                }
                
                Spacer()
                
                // Save button
                Button {
                    saveBudget()
                } label: {
                    Text("保存")
                        .font(theme.customFont(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(theme.primaryAccent)
                        .clipShape(RoundedRectangle(cornerRadius: theme.buttonCornerRadius))
                }
                .disabled(selectedCategory == nil || budgetAmount.isEmpty)
                .opacity(selectedCategory == nil || budgetAmount.isEmpty ? 0.5 : 1)
            }
            .padding(theme.paddingLarge)
            .background(theme.background)
            .navigationTitle("添加预算")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .foregroundStyle(theme.primaryAccent)
                }
            }
        }
    }
    
    private func saveBudget() {
        guard let category = selectedCategory,
              let amount = Decimal(string: budgetAmount) else { return }
        
        let budget = Budget(limitAmount: amount, category: category)
        modelContext.insert(budget)
        theme.successHaptic()
        dismiss()
    }
    
    private func selectCategory(_ category: Category) {
        theme.lightHaptic()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedCategory = category
        }
    }
}

// MARK: - Category Bubble

struct CategoryBubble: View {
    @Environment(\.appTheme) private var theme
    
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? categoryColor : categoryColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: category.iconName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : categoryColor)
                }
                
                Text(category.name)
                    .font(theme.customFont(size: 10, weight: .medium))
                    .foregroundStyle(isSelected ? theme.textPrimary : theme.textSecondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(BounceButtonStyle())
    }
    
    private var categoryColor: Color {
        Color(hex: category.colorHex)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BudgetPlanningView()
    }
    .modelContainer(for: [Transaction.self, Category.self, Budget.self], inMemory: true)
    .environment(\.appTheme, CharcoalTheme())
}
