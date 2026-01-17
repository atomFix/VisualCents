//
//  ManualEntryView.swift
//  VisualCents
//
//  Full manual entry view with math keypad and themed UI
//

import SwiftUI
import SwiftData

/// Manual transaction entry sheet with math-capable keypad
struct ManualEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appTheme) private var theme
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    
    // MARK: - State
    
    @State private var expression: String = ""
    @State private var merchantName: String = ""
    @State private var selectedCategory: Category?
    @State private var isExpense: Bool = true
    @State private var selectedDate: Date = Date()
    @State private var notes: String = ""
    @State private var showDatePicker = false
    @State private var isSaving = false
    @State private var showSuccess = false
    @State private var shakeAmount = false
    
    // MARK: - Computed
    
    private var displayAmount: String {
        if expression.isEmpty {
            return "0"
        }
        return expression
    }
    
    private var canSave: Bool {
        !expression.isEmpty && !merchantName.isEmpty && selectedCategory != nil
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Amount Display
                            amountDisplay
                            
                            // Type Toggle
                            typeToggle
                            
                            // Category Grid
                            categoryGrid
                            
                            // Merchant Input
                            inputField(
                                icon: "storefront",
                                placeholder: "商家名称",
                                text: $merchantName,
                                required: expression.count > 0
                            )
                            
                            // Date Button
                            dateButton
                            
                            // Notes (optional)
                            inputField(
                                icon: "note.text",
                                placeholder: "备注 (可选)",
                                text: $notes,
                                required: false
                            )
                        }
                        .padding(theme.padding)
                    }
                    
                    // Math Keypad - fixed at bottom
                    MathKeypad(expression: $expression) { result in
                        saveTransaction(amount: result)
                    }
                    .padding(.bottom, theme.paddingLarge)
                }
                
                // Success overlay
                if showSuccess {
                    successOverlay
                }
            }
            .navigationTitle("记一笔")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        theme.lightHaptic()
                        dismiss()
                    }
                    .foregroundStyle(theme.textSecondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        attemptSave()
                    }
                    .font(theme.customFont(size: 16, weight: .semibold))
                    .foregroundStyle(canSave ? theme.primaryAccent : theme.textTertiary)
                    .disabled(!canSave || isSaving)
                }
            }
        }
        .interactiveDismissDisabled(isSaving)
    }
    
    // MARK: - Amount Display
    
    private var amountDisplay: some View {
        VStack(spacing: 8) {
            Text(isExpense ? "支出" : "收入")
                .font(theme.customFont(size: 13, weight: .medium))
                .foregroundStyle(theme.textSecondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("¥")
                    .font(theme.heroFont(size: 28))
                    .foregroundStyle(theme.textSecondary)
                
                Text(displayAmount)
                    .font(theme.heroFont(size: 52))
                    .foregroundStyle(isExpense ? theme.expenseRed : theme.incomeGreen)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: expression)
            }
            .offset(x: shakeAmount ? -10 : 0)
            .animation(
                shakeAmount ?
                    Animation.easeInOut(duration: 0.08).repeatCount(4, autoreverses: true) :
                    .default,
                value: shakeAmount
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    // MARK: - Type Toggle
    
    private var typeToggle: some View {
        HStack(spacing: 0) {
            ForEach([true, false], id: \.self) { expense in
                Button {
                    theme.lightHaptic()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpense = expense
                    }
                } label: {
                    Text(expense ? "支出" : "收入")
                        .font(theme.customFont(size: 15, weight: .semibold))
                        .foregroundStyle(isExpense == expense ? .white : theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            isExpense == expense ?
                            (expense ? theme.expenseRed : theme.incomeGreen) :
                            Color.clear
                        )
                }
            }
        }
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.buttonCornerRadius))
    }
    
    // MARK: - Category Grid
    
    private var categoryGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("分类")
                    .font(theme.customFont(size: 13, weight: .medium))
                    .foregroundStyle(theme.textSecondary)
                
                if selectedCategory == nil && !expression.isEmpty {
                    Text("• 请选择")
                        .font(theme.customFont(size: 11, weight: .medium))
                        .foregroundStyle(theme.expenseRed)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                ForEach(categories) { category in
                    EntryCategoryBubble(
                        category: category,
                        isSelected: selectedCategory?.id == category.id
                    ) {
                        theme.mediumHaptic()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            selectedCategory = category
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Input Field
    
    private func inputField(icon: String, placeholder: String, text: Binding<String>, required: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(theme.textTertiary)
                .frame(width: 24)
            
            TextField(placeholder, text: text)
                .font(theme.customFont(size: 16, weight: .regular))
                .foregroundStyle(theme.textPrimary)
        }
        .padding()
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .stroke(
                    required && text.wrappedValue.isEmpty ?
                        theme.expenseRed.opacity(0.5) : Color.clear,
                    lineWidth: 1
                )
        )
    }
    
    // MARK: - Date Button
    
    private var dateButton: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                theme.lightHaptic()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showDatePicker.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundStyle(theme.primaryAccent)
                        .frame(width: 24)
                    
                    Text(formatDate(selectedDate))
                        .font(theme.customFont(size: 16, weight: .regular))
                        .foregroundStyle(theme.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(theme.textTertiary)
                        .rotationEffect(.degrees(showDatePicker ? 90 : 0))
                }
                .padding()
                .background(theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
            }
            
            if showDatePicker {
                DatePicker(
                    "选择日期",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .tint(theme.primaryAccent)
                .padding()
                .background(theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95)),
                    removal: .opacity
                ))
            }
        }
    }
    
    // MARK: - Success Overlay
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(theme.incomeGreen)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(showSuccess ? 1 : 0.5)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showSuccess)
                
                Text("保存成功!")
                    .font(theme.customFont(size: 20, weight: .semibold))
                    .foregroundStyle(theme.textPrimary)
            }
        }
        .transition(.opacity)
    }
    
    // MARK: - Actions
    
    private func attemptSave() {
        guard !expression.isEmpty else {
            shakeAmount = true
            theme.errorHaptic()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                shakeAmount = false
            }
            return
        }
        
        guard !merchantName.isEmpty, selectedCategory != nil else {
            theme.errorHaptic()
            return
        }
        
        // Evaluate and save
        let result = evaluateExpression()
        saveTransaction(amount: result)
    }
    
    private func evaluateExpression() -> Decimal {
        // Simple evaluation (matches MathKeypad logic)
        var expr = expression
        while let last = expr.last, last == "+" || last == "-" || last == "." {
            expr.removeLast()
        }
        if expr.isEmpty { return 0 }
        
        var result: Decimal = 0
        var currentNumber = ""
        var currentOp: Character = "+"
        
        for (index, char) in expr.enumerated() {
            if char == "+" || char == "-" {
                if index == 0 || (index > 0 && (expr[expr.index(expr.startIndex, offsetBy: index - 1)] == "+" || expr[expr.index(expr.startIndex, offsetBy: index - 1)] == "-")) {
                    currentNumber.append(char)
                } else {
                    if let num = Decimal(string: currentNumber) {
                        result = currentOp == "+" ? result + num : result - num
                    }
                    currentNumber = ""
                    currentOp = char
                }
            } else {
                currentNumber.append(char)
            }
        }
        
        if let num = Decimal(string: currentNumber) {
            result = currentOp == "+" ? result + num : result - num
        }
        
        return result
    }
    
    private func saveTransaction(amount: Decimal) {
        guard amount > 0 else {
            theme.errorHaptic()
            return
        }
        
        isSaving = true
        theme.mediumHaptic()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let transaction = Transaction(
                amount: amount,
                merchantName: merchantName,
                date: selectedDate,
                notes: notes.isEmpty ? nil : notes,
                isExpense: isExpense,
                source: .manual,
                category: selectedCategory
            )
            
            modelContext.insert(transaction)
            
            do {
                try modelContext.save()
                
                withAnimation {
                    showSuccess = true
                }
                theme.successHaptic()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    dismiss()
                }
            } catch {
                isSaving = false
                theme.errorHaptic()
            }
        }
    }
    
    // MARK: - Helpers
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今天"
        } else if calendar.isDateInYesterday(date) {
            return "昨天"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日"
            formatter.locale = Locale(identifier: "zh_CN")
            return formatter.string(from: date)
        }
    }
}

// MARK: - Category Bubble

struct EntryCategoryBubble: View {
    @Environment(\.appTheme) private var theme
    
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isSelected ? categoryColor : categoryColor.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: category.iconName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(isSelected ? .white : categoryColor)
                }
                .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(category.name)
                    .font(theme.customFont(size: 10, weight: .medium))
                    .foregroundStyle(isSelected ? theme.textPrimary : theme.textSecondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var categoryColor: Color {
        Color(hex: category.colorHex)
    }
}

// MARK: - Preview

#Preview {
    ManualEntryView()
        .modelContainer(for: [Transaction.self, Category.self, Budget.self], inMemory: true)
        .environment(\.appTheme, SoftPopTheme())
}
