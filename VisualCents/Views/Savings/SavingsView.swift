//
//  SavingsView.swift
//  VisualCents
//
//  Gamified savings goals view
//

import SwiftUI
import SwiftData

/// Savings goals list with progress cards
struct SavingsView: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavingsGoal.createdAt, order: .reverse) private var goals: [SavingsGoal]
    
    @State private var showAddGoal = false
    
    private var activeGoals: [SavingsGoal] {
        goals.filter { $0.status == .active }
    }
    
    private var completedGoals: [SavingsGoal] {
        goals.filter { $0.status == .completed }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: theme.padding) {
                // Header stats
                headerStats
                
                // Active goals
                if activeGoals.isEmpty {
                    emptyState
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: theme.padding) {
                        ForEach(activeGoals) { goal in
                            GoalProgressCard(goal: goal)
                        }
                    }
                }
                
                // Completed goals
                if !completedGoals.isEmpty {
                    completedSection
                }
                
                Spacer()
                    .frame(height: 100)
            }
            .padding(theme.padding)
        }
        .background(theme.background)
        .navigationTitle("攒钱计划")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    theme.mediumHaptic()
                    showAddGoal = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(theme.primaryAccent)
                }
            }
        }
        .sheet(isPresented: $showAddGoal) {
            AddSavingsGoalSheet()
                .presentationDetents([.medium])
        }
    }
    
    // MARK: - Header Stats
    
    private var headerStats: some View {
        HStack(spacing: theme.padding) {
            StatCard(
                title: "进行中",
                value: "\(activeGoals.count)",
                icon: "target",
                color: theme.primaryAccent
            )
            
            StatCard(
                title: "已完成",
                value: "\(completedGoals.count)",
                icon: "checkmark.circle.fill",
                color: theme.incomeGreen
            )
            
            StatCard(
                title: "总存款",
                value: formatAmount(totalSaved),
                icon: "banknote",
                color: theme.warningYellow
            )
        }
    }
    
    private var totalSaved: Decimal {
        goals.reduce(Decimal.zero) { $0 + $1.currentAmount }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.circle")
                .font(.system(size: 60))
                .foregroundStyle(theme.textTertiary)
            
            Text("开始你的第一个存钱目标")
                .font(theme.customFont(size: 16, weight: .medium))
                .foregroundStyle(theme.textSecondary)
            
            Button {
                theme.mediumHaptic()
                showAddGoal = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("创建目标")
                }
                .font(theme.customFont(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(theme.primaryAccent)
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Completed Section
    
    private var completedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("已完成")
                .font(theme.customFont(size: 14, weight: .semibold))
                .foregroundStyle(theme.textSecondary)
            
            ForEach(completedGoals) { goal in
                CompletedGoalRow(goal: goal)
            }
        }
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0"
    }
}

// MARK: - Stat Card

struct StatCard: View {
    @Environment(\.appTheme) private var theme
    
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
            
            Text(value)
                .font(theme.amountFont(size: 18))
                .foregroundStyle(theme.textPrimary)
            
            Text(title)
                .font(theme.customFont(size: 11, weight: .medium))
                .foregroundStyle(theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
    }
}

// MARK: - Goal Progress Card

struct GoalProgressCard: View {
    @Environment(\.appTheme) private var theme
    
    let goal: SavingsGoal
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon and title
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color(hex: goal.colorHex).opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: goal.iconName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(hex: goal.colorHex))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(theme.customFont(size: 14, weight: .semibold))
                        .foregroundStyle(theme.textPrimary)
                        .lineLimit(1)
                    
                    if let days = goal.daysRemaining {
                        Text("还剩 \(days) 天")
                            .font(theme.customFont(size: 11, weight: .regular))
                            .foregroundStyle(theme.textTertiary)
                    }
                }
            }
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(theme.cardBackgroundElevated)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: goal.colorHex), Color(hex: goal.colorHex).opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * animatedProgress)
                }
            }
            .frame(height: 12)
            
            // Amount info
            HStack {
                Text(formatAmount(goal.currentAmount))
                    .font(theme.amountFont(size: 14))
                    .foregroundStyle(theme.textPrimary)
                
                Spacer()
                
                Text(formatAmount(goal.targetAmount))
                    .font(theme.customFont(size: 12, weight: .regular))
                    .foregroundStyle(theme.textTertiary)
            }
        }
        .padding(theme.padding)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cardCornerRadius))
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animatedProgress = goal.progress
            }
        }
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0"
    }
}

// MARK: - Completed Goal Row

struct CompletedGoalRow: View {
    @Environment(\.appTheme) private var theme
    
    let goal: SavingsGoal
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(theme.incomeGreen)
            
            Text(goal.title)
                .font(theme.customFont(size: 14, weight: .medium))
                .foregroundStyle(theme.textSecondary)
            
            Spacer()
            
            Text(formatAmount(goal.targetAmount))
                .font(theme.amountFont(size: 14))
                .foregroundStyle(theme.textTertiary)
        }
        .padding(12)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0"
    }
}

// MARK: - Add Savings Goal Sheet

struct AddSavingsGoalSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appTheme) private var theme
    @Environment(\.modelContext) private var modelContext
    
    @State private var title = ""
    @State private var targetAmount = ""
    @State private var hasDeadline = false
    @State private var deadline = Date()
    @State private var selectedIcon = "star.fill"
    
    private let icons = ["star.fill", "heart.fill", "airplane", "car.fill", "house.fill", "gift.fill", "gamecontroller.fill", "desktopcomputer", "camera.fill", "tshirt.fill"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("目标名称", text: $title)
                    
                    HStack {
                        Text("¥")
                        TextField("目标金额", text: $targetAmount)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section {
                    Toggle("设置截止日期", isOn: $hasDeadline)
                    
                    if hasDeadline {
                        DatePicker("截止日期", selection: $deadline, displayedComponents: .date)
                    }
                }
                
                Section("选择图标") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(icons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.system(size: 24))
                                    .foregroundStyle(selectedIcon == icon ? theme.primaryAccent : theme.textSecondary)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(selectedIcon == icon ? theme.primaryAccent.opacity(0.2) : Color.clear)
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .scrollContentBackground(.hidden)
            .background(theme.background)
            .navigationTitle("新建目标")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveGoal()
                    }
                    .disabled(title.isEmpty || targetAmount.isEmpty)
                }
            }
        }
    }
    
    private func saveGoal() {
        guard let amount = Decimal(string: targetAmount) else { return }
        
        let goal = SavingsGoal(
            title: title,
            targetAmount: amount,
            deadline: hasDeadline ? deadline : nil,
            iconName: selectedIcon
        )
        
        modelContext.insert(goal)
        theme.successHaptic()
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SavingsView()
    }
    .modelContainer(for: [SavingsGoal.self], inMemory: true)
    .environment(\.appTheme, SoftPopTheme())
}
