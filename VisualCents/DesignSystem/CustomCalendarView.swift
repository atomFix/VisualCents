//
//  CustomCalendarView.swift
//  VisualCents
//
//  简化的自定义日历组件
//

import SwiftUI

/// 简化的自定义日历视图
struct SimpleCalendarView: View {
    @Environment(\.appTheme) private var theme

    @Binding var selectedDate: Date
    var hasTransactionDates: [Date] = []

    @State private var displayedMonth: Date = Date()
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 0) {
            // 月份导航
            monthNavigator

            // 星期标题
            weekdayHeader

            // 日期网格
            dayGrid
        }
        .padding()
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 月份导航

    private var monthNavigator: some View {
        HStack {
            Button {
                withAnimation {
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(theme.textSecondary)
                    .padding(8)
                    .background(theme.cardBackgroundElevated)
                    .clipShape(Circle())
            }

            Spacer()

            Text(monthYearString)
                .font(theme.customFont(size: 16, weight: .semibold))
                .foregroundStyle(theme.textPrimary)

            Spacer()

            Button {
                withAnimation {
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(theme.textSecondary)
                    .padding(8)
                    .background(theme.cardBackgroundElevated)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - 星期标题

    private var weekdayHeader: some View {
        HStack {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(theme.customFont(size: 12, weight: .medium))
                    .foregroundStyle(theme.textTertiary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - 日期网格

    private var dayGrid: some View {
        let days = daysInMonth

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(days.indices, id: \.self) { index in
                let date = days[index]
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                let hasTransaction = hasTransactionDates.contains(where: { calendar.isDate($0, inSameDayAs: date) })
                let isCurrentMonth = calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)

                SimpleCalendarDayCell(
                    theme: theme,
                    date: date,
                    isSelected: isSelected,
                    hasTransaction: hasTransaction,
                    isCurrentMonth: isCurrentMonth
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedDate = date
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
    }

    // MARK: - 辅助属性

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月"
        return formatter.string(from: displayedMonth)
    }

    private var weekdaySymbols: [String] {
        calendar.veryShortWeekdaySymbols
    }

    private var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else {
            return []
        }

        let days = calendar.dateComponents([.day], from: monthInterval.start, to: monthInterval.end).day!
        var dates: [Date] = []

        for day in 1...days {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) {
                dates.append(date)
            }
        }

        // 添加月初前的空白日期
        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let padding = (firstWeekday - calendar.firstWeekday + 7) % 7

        for _ in 0..<padding {
            dates.append(Date())
        }

        return dates
    }
}

/// 日历日期单元格
private struct SimpleCalendarDayCell: View {
    let theme: any AppTheme
    let date: Date
    let isSelected: Bool
    let hasTransaction: Bool
    let isCurrentMonth: Bool

    private let calendar = Calendar.current
    private var dayNumber: String {
        String(calendar.component(.day, from: date))
    }

    var body: some View {
        ZStack {
            // 背景
            if isSelected {
                Circle()
                    .fill(theme.primaryAccent)
            } else if isCurrentMonth {
                Circle()
                    .fill(Color.clear)
            } else {
                Circle()
                    .fill(Color.clear)
            }

            // 日期数字
            Text(dayNumber)
                .font(theme.customFont(size: 16, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : (isCurrentMonth ? theme.textPrimary : theme.textTertiary))

            // 交易标记点
            if hasTransaction {
                Circle()
                    .fill(isSelected ? Color.white : theme.expenseRed)
                    .frame(width: 4, height: 4)
                    .offset(y: 12)
            }
        }
        .frame(height: 44)
        .opacity(isCurrentMonth ? 1 : 0.3)
    }
}

// MARK: - 使用示例

/*
 使用示例：

 1. 基础日历：
    SimpleCalendarView(
        selectedDate: $selectedDate
    )

 2. 带交易标记：
    SimpleCalendarView(
        selectedDate: $selectedDate,
        hasTransactionDates: transactionDates
    )

 3. 在首页使用：
    SimpleCalendarView(
        selectedDate: $selectedDate,
        hasTransactionDates: transactions.map { $0.date }
    )
*/
