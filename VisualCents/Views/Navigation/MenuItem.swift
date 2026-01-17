//
//  MenuItem.swift
//  VisualCents
//
//  Menu item configuration for side drawer with theme support
//

import SwiftUI

/// Represents a menu item in the side drawer
enum MenuItem: String, CaseIterable, Identifiable {
    case dashboard = "dashboard"
    case statistics = "statistics"
    case savings = "savings"
    case assets = "assets"
    case transactions = "transactions"
    case budget = "budget"
    case settings = "settings"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .dashboard: return "首页"
        case .statistics: return "统计"
        case .savings: return "攒钱"
        case .assets: return "资产"
        case .transactions: return "明细"
        case .budget: return "预算"
        case .settings: return "设置"
        }
    }
    
    var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .statistics: return "chart.bar.fill"
        case .savings: return "star.fill"
        case .assets: return "creditcard.fill"
        case .transactions: return "list.bullet.rectangle.fill"
        case .budget: return "dollarsign.circle.fill"
        case .settings: return "gearshape.fill"
        }
    }
    
    /// Returns the color for the menu item based on the active theme
    func themeColor(for theme: any AppTheme) -> Color {
        switch self {
        case .dashboard: return theme.primaryAccent
        case .statistics: return theme.secondaryAccent
        case .savings: return theme.warningYellow
        case .assets: return theme.incomeGreen
        case .transactions: return theme.expenseRed
        case .budget: return theme.incomeGreen
        case .settings: return theme.textSecondary
        }
    }
}
