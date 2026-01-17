//
//  Category.swift
//  VisualCents
//
//  Core category model for organizing transactions
//

import Foundation
import SwiftData

/// Represents a spending/income category with visual properties
@Model
final class Category {
    // MARK: - Properties
    
    /// Unique identifier for CloudKit sync
    @Attribute(.unique) var id: UUID
    
    /// Display name (e.g., "Food", "Transport")
    var name: String
    
    /// SF Symbol name for the category icon
    var iconName: String
    
    /// Hex color string for visual representation
    var colorHex: String
    
    /// Sort order for display
    var sortOrder: Int
    
    /// Whether this is a system-created default category
    var isDefault: Bool
    
    // MARK: - Relationships
    
    /// All transactions in this category
    @Relationship(deleteRule: .nullify, inverse: \Transaction.category)
    var transactions: [Transaction]?
    
    /// Budget for this category (optional)
    @Relationship(deleteRule: .cascade, inverse: \Budget.category)
    var budget: Budget?
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        name: String,
        iconName: String,
        colorHex: String,
        sortOrder: Int = 0,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.sortOrder = sortOrder
        self.isDefault = isDefault
    }
    
    // MARK: - Default Categories
    
    /// Creates the default set of expense categories
    static func defaultCategories() -> [Category] {
        [
            Category(name: "Food & Dining", iconName: "fork.knife", colorHex: "FF9F68", sortOrder: 0, isDefault: true),
            Category(name: "Transport", iconName: "car.fill", colorHex: "5DADE2", sortOrder: 1, isDefault: true),
            Category(name: "Shopping", iconName: "bag.fill", colorHex: "AF7AC5", sortOrder: 2, isDefault: true),
            Category(name: "Entertainment", iconName: "gamecontroller.fill", colorHex: "45B7D1", sortOrder: 3, isDefault: true),
            Category(name: "Health", iconName: "heart.fill", colorHex: "E74C3C", sortOrder: 4, isDefault: true),
            Category(name: "Income", iconName: "arrow.down.circle.fill", colorHex: "58D68D", sortOrder: 5, isDefault: true),
            Category(name: "Other", iconName: "ellipsis.circle.fill", colorHex: "95A5A6", sortOrder: 6, isDefault: true)
        ]
    }
}
