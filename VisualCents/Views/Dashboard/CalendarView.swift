//
//  CalendarView.swift
//  VisualCents
//
//  Monthly/weekly calendar grid with daily totals
//

import SwiftUI
import SwiftData

/// Collapsible calendar view with daily expense indicators
struct CalendarView: View {
    @Environment(\.appTheme) private var theme
    
    let monthData: CalendarService.MonthData
    let selectedDate: Date
    var onDateSelected: (Date) -> Void
    
    @State private var isExpanded = true
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdays = ["一", "二", "三", "四", "五", "六", "日"]
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            header
            
            // Weekday labels
            weekdayLabels
            
            // Calendar grid
            if isExpanded {
                monthGrid
            } else {
                weekGrid
            }
        }
        .padding(theme.padding)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cardCornerRadius))
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Text(monthData.monthName)
                .font(theme.customFont(size: 18, weight: .semibold))
                .foregroundStyle(theme.textPrimary)
            
            Spacer()
            
            // Expand/collapse button
            Button {
                theme.lightHaptic()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.textSecondary)
                    .padding(8)
                    .background(theme.cardBackgroundElevated)
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: - Weekday Labels
    
    private var weekdayLabels: some View {
        HStack(spacing: 4) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(theme.customFont(size: 11, weight: .medium))
                    .foregroundStyle(theme.textTertiary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Month Grid
    
    private var monthGrid: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            // Leading empty cells
            ForEach(0..<leadingEmptyCells, id: \.self) { _ in
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
            }
            
            // Day cells
            ForEach(monthData.days) { dayData in
                DayCell(
                    dayData: dayData,
                    isSelected: Calendar.current.isDate(dayData.date, inSameDayAs: selectedDate),
                    isToday: dayData.date.isToday
                ) {
                    theme.lightHaptic()
                    onDateSelected(dayData.date)
                }
            }
        }
    }
    
    // MARK: - Week Grid (collapsed view)
    
    private var weekGrid: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(currentWeekDays) { dayData in
                DayCell(
                    dayData: dayData,
                    isSelected: Calendar.current.isDate(dayData.date, inSameDayAs: selectedDate),
                    isToday: dayData.date.isToday
                ) {
                    theme.lightHaptic()
                    onDateSelected(dayData.date)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private var leadingEmptyCells: Int {
        guard let firstDay = monthData.days.first else { return 0 }
        let weekday = Calendar.current.component(.weekday, from: firstDay.date)
        // Convert to Monday = 0
        return (weekday + 5) % 7
    }
    
    private var currentWeekDays: [CalendarService.DayData] {
        let calendar = Calendar.current
        
        // Find the week containing selected date
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        
        return monthData.days.filter { dayData in
            if let interval = calendar.dateInterval(of: .weekOfYear, for: dayData.date) {
                return interval.start == weekStart
            }
            return false
        }
    }
}

// MARK: - Day Cell

struct DayCell: View {
    @Environment(\.appTheme) private var theme
    
    let dayData: CalendarService.DayData
    let isSelected: Bool
    let isToday: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                // Day number
                Text("\(dayData.date.dayNumber)")
                    .font(theme.customFont(size: 14, weight: isSelected || isToday ? .bold : .regular))
                    .foregroundStyle(dayNumberColor)
                
                // Expense indicator
                if dayData.hasTransactions {
                    if dayData.totalExpense > 0 {
                        Text(formatCompact(dayData.totalExpense))
                            .font(theme.customFont(size: 9, weight: .medium))
                            .foregroundStyle(theme.expenseRed)
                            .lineLimit(1)
                    } else if dayData.totalIncome > 0 {
                        Text(formatCompact(dayData.totalIncome))
                            .font(theme.customFont(size: 9, weight: .medium))
                            .foregroundStyle(theme.incomeGreen)
                            .lineLimit(1)
                    }
                } else {
                    Text(" ")
                        .font(theme.customFont(size: 9, weight: .medium))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday ? theme.primaryAccent : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var dayNumberColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return theme.primaryAccent
        } else {
            return theme.textPrimary
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return theme.primaryAccent
        } else {
            return Color.clear
        }
    }
    
    private func formatCompact(_ amount: Decimal) -> String {
        let doubleValue = NSDecimalNumber(decimal: amount).doubleValue
        if doubleValue >= 1000 {
            return String(format: "%.0fk", doubleValue / 1000)
        } else if doubleValue >= 100 {
            return String(format: "%.0f", doubleValue)
        } else {
            return String(format: "%.0f", doubleValue)
        }
    }
}

// MARK: - Preview

#Preview {
    let service = CalendarService()
    let monthData = service.getMonthData(year: 2024, month: 1, transactions: [])
    
    return CalendarView(
        monthData: monthData,
        selectedDate: Date(),
        onDateSelected: { _ in }
    )
    .padding()
    .background(Color(red: 0.08, green: 0.08, blue: 0.12))
    .environment(\.appTheme, SoftPopTheme())
}
