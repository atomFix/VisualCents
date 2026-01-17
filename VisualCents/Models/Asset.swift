//
//  Asset.swift
//  VisualCents
//
//  Account/wallet tracking model
//

import Foundation
import SwiftData

/// Asset type enumeration
enum AssetType: String, Codable, CaseIterable {
    case cash = "现金"
    case debit = "储蓄卡"
    case credit = "信用卡"
    case virtual = "虚拟账户"
    case investment = "投资"
    
    var iconName: String {
        switch self {
        case .cash: return "banknote"
        case .debit: return "creditcard"
        case .credit: return "creditcard.fill"
        case .virtual: return "iphone"
        case .investment: return "chart.line.uptrend.xyaxis"
        }
    }
    
    var defaultColor: String {
        switch self {
        case .cash: return "#4CAF50"
        case .debit: return "#2196F3"
        case .credit: return "#FF9800"
        case .virtual: return "#9C27B0"
        case .investment: return "#00BCD4"
        }
    }
}

/// Asset model for tracking accounts and wallets
@Model
final class Asset {
    var id: UUID = UUID()
    var name: String = ""
    var typeRaw: String = AssetType.cash.rawValue
    var balance: Decimal = 0
    var currency: String = "CNY"
    var iconName: String = "banknote"
    var colorHex: String = "#4CAF50"
    var isIncludedInTotal: Bool = true
    var sortOrder: Int = 0
    var createdAt: Date = Date()
    
    /// Computed type property
    var type: AssetType {
        get { AssetType(rawValue: typeRaw) ?? .cash }
        set { typeRaw = newValue.rawValue }
    }
    
    /// Transactions linked to this asset
    @Relationship(deleteRule: .nullify, inverse: \Transaction.asset)
    var transactions: [Transaction]? = []
    
    init(
        name: String,
        type: AssetType,
        balance: Decimal = 0,
        currency: String = "CNY",
        iconName: String? = nil,
        colorHex: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.balance = balance
        self.currency = currency
        self.iconName = iconName ?? type.iconName
        self.colorHex = colorHex ?? type.defaultColor
        self.createdAt = Date()
    }
    
    /// Default assets for first launch
    static func defaultAssets() -> [Asset] {
        [
            Asset(name: "现金", type: .cash, balance: 0),
            Asset(name: "微信支付", type: .virtual, iconName: "message.fill", colorHex: "#07C160"),
            Asset(name: "支付宝", type: .virtual, iconName: "a.circle.fill", colorHex: "#1677FF"),
            Asset(name: "银行卡", type: .debit, balance: 0)
        ]
    }
}
