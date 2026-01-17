//
//  SavingsGoal.swift
//  VisualCents
//
//  Gamified savings goal tracking
//

import Foundation
import SwiftData

/// Goal status enumeration
enum GoalStatus: String, Codable, CaseIterable {
    case active = "进行中"
    case completed = "已完成"
    case paused = "已暂停"
    case cancelled = "已取消"
}

/// Savings goal model for gamified savings
@Model
final class SavingsGoal {
    var id: UUID = UUID()
    var title: String = ""
    var targetAmount: Decimal = 0
    var currentAmount: Decimal = 0
    var deadline: Date?
    var statusRaw: String = GoalStatus.active.rawValue
    var iconName: String = "star.fill"
    var colorHex: String = "#FFD700"
    var notes: String?
    var createdAt: Date = Date()
    var completedAt: Date?
    
    /// Computed status property
    var status: GoalStatus {
        get { GoalStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }
    
    /// Progress percentage (0.0 to 1.0)
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(1.0, NSDecimalNumber(decimal: currentAmount / targetAmount).doubleValue)
    }
    
    /// Remaining amount to reach goal
    var remainingAmount: Decimal {
        max(0, targetAmount - currentAmount)
    }
    
    /// Days remaining until deadline
    var daysRemaining: Int? {
        guard let deadline = deadline else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day
        return max(0, days ?? 0)
    }
    
    /// Daily savings needed to reach goal
    var dailySavingsNeeded: Decimal? {
        guard let days = daysRemaining, days > 0 else { return nil }
        return remainingAmount / Decimal(days)
    }
    
    init(
        title: String,
        targetAmount: Decimal,
        deadline: Date? = nil,
        iconName: String = "star.fill",
        colorHex: String = "#FFD700"
    ) {
        self.id = UUID()
        self.title = title
        self.targetAmount = targetAmount
        self.deadline = deadline
        self.iconName = iconName
        self.colorHex = colorHex
        self.createdAt = Date()
    }
    
    /// Add amount to savings
    func deposit(_ amount: Decimal) {
        currentAmount += amount
        if currentAmount >= targetAmount {
            status = .completed
            completedAt = Date()
        }
    }
    
    /// Sample goals for preview
    static func sampleGoals() -> [SavingsGoal] {
        [
            {
                let goal = SavingsGoal(
                    title: "Mac Studio",
                    targetAmount: 19999,
                    deadline: Calendar.current.date(byAdding: .month, value: 6, to: Date()),
                    iconName: "desktopcomputer",
                    colorHex: "#007AFF"
                )
                goal.currentAmount = 8500
                return goal
            }(),
            {
                let goal = SavingsGoal(
                    title: "日本旅行",
                    targetAmount: 15000,
                    deadline: Calendar.current.date(byAdding: .month, value: 4, to: Date()),
                    iconName: "airplane",
                    colorHex: "#FF6B6B"
                )
                goal.currentAmount = 3200
                return goal
            }(),
            {
                let goal = SavingsGoal(
                    title: "应急基金",
                    targetAmount: 50000,
                    iconName: "shield.fill",
                    colorHex: "#4CAF50"
                )
                goal.currentAmount = 25000
                return goal
            }()
        ]
    }
}
