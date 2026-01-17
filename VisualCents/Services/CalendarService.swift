//
//  CalendarService.swift
//  VisualCents
//
//  Calendar aggregation service for grouping transactions
//

import Foundation
import SwiftData

/// Service for calendar-based transaction aggregation
@Observable
final class CalendarService {
    
    // MARK: - Types
    
    struct DayData: Identifiable {
        let id = UUID()
        let date: Date
        let transactions: [Transaction]
        
        var totalExpense: Decimal {
            transactions.filter { $0.isExpense }.reduce(Decimal.zero) { $0 + $1.amount }
        }
        
        var totalIncome: Decimal {
            transactions.filter { !$0.isExpense }.reduce(Decimal.zero) { $0 + $1.amount }
        }
        
        var netAmount: Decimal {
            totalIncome - totalExpense
        }
        
        var hasTransactions: Bool {
            !transactions.isEmpty
        }
    }
    
    struct MonthData {
        let year: Int
        let month: Int
        let days: [DayData]
        
        var totalExpense: Decimal {
            days.reduce(Decimal.zero) { $0 + $1.totalExpense }
        }
        
        var totalIncome: Decimal {
            days.reduce(Decimal.zero) { $0 + $1.totalIncome }
        }
        
        var balance: Decimal {
            totalIncome - totalExpense
        }
        
        var monthName: String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "yyyy年M月"
            
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = 1
            
            if let date = Calendar.current.date(from: components) {
                return formatter.string(from: date)
            }
            return "\(year)年\(month)月"
        }
    }
    
    // MARK: - Public Methods
    
    /// Group transactions by date
    func groupByDate(_ transactions: [Transaction]) -> [Date: [Transaction]] {
        let calendar = Calendar.current
        var grouped: [Date: [Transaction]] = [:]
        
        for transaction in transactions {
            let dayStart = calendar.startOfDay(for: transaction.date)
            if grouped[dayStart] != nil {
                grouped[dayStart]?.append(transaction)
            } else {
                grouped[dayStart] = [transaction]
            }
        }
        
        return grouped
    }
    
    /// Get data for a specific month
    func getMonthData(year: Int, month: Int, transactions: [Transaction]) -> MonthData {
        let calendar = Calendar.current
        
        // Filter transactions for this month
        let monthTransactions = transactions.filter { transaction in
            let components = calendar.dateComponents([.year, .month], from: transaction.date)
            return components.year == year && components.month == month
        }
        
        // Group by day
        let grouped = groupByDate(monthTransactions)
        
        // Get all days in month
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let startOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return MonthData(year: year, month: month, days: [])
        }
        
        // Create day data for each day
        var days: [DayData] = []
        for day in range {
            components.day = day
            if let date = calendar.date(from: components) {
                let dayStart = calendar.startOfDay(for: date)
                let dayTransactions = grouped[dayStart] ?? []
                days.append(DayData(date: dayStart, transactions: dayTransactions))
            }
        }
        
        return MonthData(year: year, month: month, days: days)
    }
    
    /// Get timeline data (grouped by day, sorted by date descending)
    func getTimelineData(_ transactions: [Transaction]) -> [DayData] {
        let grouped = groupByDate(transactions)
        
        return grouped.map { date, transactions in
            DayData(date: date, transactions: transactions.sorted { $0.date > $1.date })
        }
        .sorted { $0.date > $1.date }
    }
    
    /// Get week data for the given date
    func getWeekDates(for date: Date) -> [Date] {
        let calendar = Calendar.current
        
        // Get start of week (Monday)
        var startOfWeek = date
        var interval: TimeInterval = 0
        _ = calendar.dateInterval(of: .weekOfYear, start: &startOfWeek, interval: &interval, for: date)
        
        // Generate 7 days
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startOfWeek)
        }
    }
}

// MARK: - Date Helpers

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isThisMonth: Bool {
        let calendar = Calendar.current
        let now = Date()
        return calendar.component(.month, from: self) == calendar.component(.month, from: now) &&
               calendar.component(.year, from: self) == calendar.component(.year, from: now)
    }
    
    var dayNumber: Int {
        Calendar.current.component(.day, from: self)
    }
    
    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
}
