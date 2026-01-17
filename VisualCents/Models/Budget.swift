//
//  Budget.swift
//  VisualCents
//
//  Budget model for category spending limits
//

import Foundation
import SwiftData

/// Represents a spending budget for a category
@Model
final class Budget {
    // MARK: - Properties
    
    /// Unique identifier for CloudKit sync
    @Attribute(.unique) var id: UUID
    
    /// Budget limit amount
    var limitAmount: Decimal
    
    /// Budget period type
    var periodType: BudgetPeriod
    
    /// Whether notifications are enabled when approaching limit
    var notificationsEnabled: Bool
    
    /// Warning threshold percentage (0.0 - 1.0)
    var warningThreshold: Double
    
    // MARK: - Relationships
    
    /// Category this budget applies to
    var category: Category?
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        limitAmount: Decimal,
        periodType: BudgetPeriod = .monthly,
        notificationsEnabled: Bool = true,
        warningThreshold: Double = 0.8,
        category: Category? = nil
    ) {
        self.id = id
        self.limitAmount = limitAmount
        self.periodType = periodType
        self.notificationsEnabled = notificationsEnabled
        self.warningThreshold = warningThreshold
        self.category = category
    }
    
    // MARK: - Budget Calculation
    
    /// Calculate spent amount for the current period
    func calculateSpent(from transactions: [Transaction]) -> Decimal {
        let periodStart = periodType.currentPeriodStart
        return transactions
            .filter { $0.isExpense && $0.date >= periodStart }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }
    
    /// Calculate remaining budget
    func calculateRemaining(from transactions: [Transaction]) -> Decimal {
        limitAmount - calculateSpent(from: transactions)
    }
    
    /// Calculate progress (0.0 - 1.0+)
    func calculateProgress(from transactions: [Transaction]) -> Double {
        let spent = calculateSpent(from: transactions)
        guard limitAmount > 0 else { return 0 }
        return NSDecimalNumber(decimal: spent / limitAmount).doubleValue
    }
}

// MARK: - Budget Period

/// Time period for budget calculation
enum BudgetPeriod: String, Codable, CaseIterable {
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
    
    var currentPeriodStart: Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .weekly:
            return calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        case .monthly:
            return calendar.dateInterval(of: .month, for: now)?.start ?? now
        case .yearly:
            return calendar.dateInterval(of: .year, for: now)?.start ?? now
        }
    }
}
