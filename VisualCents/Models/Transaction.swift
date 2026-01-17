//
//  Transaction.swift
//  VisualCents
//
//  Core transaction model for expense/income tracking
//

import Foundation
import SwiftData

/// Represents a single financial transaction (expense or income)
@Model
final class Transaction {
    // MARK: - Properties
    
    /// Unique identifier for CloudKit sync
    @Attribute(.unique) var id: UUID
    
    /// Transaction amount in user's currency
    var amount: Decimal
    
    /// Merchant or source name (e.g., "Starbucks", "Salary")
    var merchantName: String
    
    /// Date and time of the transaction
    var date: Date
    
    /// Optional user notes
    var notes: String?
    
    /// True for expenses, false for income
    var isExpense: Bool
    
    /// Source of the transaction (manual, OCR, import)
    var source: TransactionSource
    
    /// Timestamp when created (for sorting within same date)
    var createdAt: Date
    
    // MARK: - Relationships
    
    /// Category this transaction belongs to
    var category: Category?
    
    /// Asset/account this transaction is from
    var asset: Asset?
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        amount: Decimal,
        merchantName: String,
        date: Date = Date(),
        notes: String? = nil,
        isExpense: Bool = true,
        source: TransactionSource = .manual,
        category: Category? = nil,
        asset: Asset? = nil
    ) {
        self.id = id
        self.amount = amount
        self.merchantName = merchantName
        self.date = date
        self.notes = notes
        self.isExpense = isExpense
        self.source = source
        self.category = category
        self.asset = asset
        self.createdAt = Date()
    }
    
    // MARK: - Computed Properties
    
    /// Signed amount (negative for expenses, positive for income)
    var signedAmount: Decimal {
        isExpense ? -amount : amount
    }
}

// MARK: - Transaction Source

/// How the transaction was created
enum TransactionSource: String, Codable, CaseIterable {
    case manual = "manual"
    case ocr = "ocr"
    case imported = "imported"
    
    var displayName: String {
        switch self {
        case .manual: return "Manual"
        case .ocr: return "Screenshot"
        case .imported: return "Imported"
        }
    }
    
    var iconName: String {
        switch self {
        case .manual: return "hand.tap.fill"
        case .ocr: return "camera.fill"
        case .imported: return "square.and.arrow.down.fill"
        }
    }
}
