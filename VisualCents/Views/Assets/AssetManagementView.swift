//
//  AssetManagementView.swift
//  VisualCents
//
//  Asset and account management view
//

import SwiftUI
import SwiftData

/// Asset management with net worth overview
struct AssetManagementView: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Asset.sortOrder) private var assets: [Asset]
    
    @State private var showAddAsset = false
    
    // MARK: - Computed
    
    private var totalAssets: Decimal {
        assets.filter { $0.type != .credit && $0.isIncludedInTotal }
            .reduce(Decimal.zero) { $0 + $1.balance }
    }
    
    private var totalLiabilities: Decimal {
        assets.filter { $0.type == .credit && $0.isIncludedInTotal }
            .reduce(Decimal.zero) { $0 + abs($1.balance) }
    }
    
    private var netWorth: Decimal {
        totalAssets - totalLiabilities
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: theme.padding) {
                // Net Worth Header
                netWorthCard
                
                // Assets Section
                if !assets.isEmpty {
                    assetsGrid
                } else {
                    emptyState
                }
                
                Spacer()
                    .frame(height: 60)
            }
            .padding(theme.padding)
        }
        .background(theme.background)
        .navigationTitle("资产")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    theme.mediumHaptic()
                    showAddAsset = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(theme.primaryAccent)
                }
            }
        }
        .sheet(isPresented: $showAddAsset) {
            AddAssetSheet()
                .presentationDetents([.medium])
        }
    }
    
    // MARK: - Net Worth Card
    
    private var netWorthCard: some View {
        VStack(spacing: 16) {
            Text("净资产")
                .font(theme.customFont(size: 14, weight: .medium))
                .foregroundStyle(theme.textSecondary)
            
            Text(formatAmount(netWorth))
                .font(theme.heroFont(size: 36))
                .foregroundStyle(netWorth >= 0 ? theme.incomeGreen : theme.expenseRed)
            
            HStack(spacing: theme.paddingLarge) {
                VStack(spacing: 4) {
                    Text("总资产")
                        .font(theme.customFont(size: 11, weight: .medium))
                        .foregroundStyle(theme.textTertiary)
                    Text(formatAmount(totalAssets))
                        .font(theme.amountFont(size: 16))
                        .foregroundStyle(theme.incomeGreen)
                }
                
                Rectangle()
                    .fill(theme.cardBackgroundElevated)
                    .frame(width: 1, height: 30)
                
                VStack(spacing: 4) {
                    Text("总负债")
                        .font(theme.customFont(size: 11, weight: .medium))
                        .foregroundStyle(theme.textTertiary)
                    Text(formatAmount(totalLiabilities))
                        .font(theme.amountFont(size: 16))
                        .foregroundStyle(theme.expenseRed)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(theme.paddingLarge)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cardCornerRadius))
    }
    
    // MARK: - Assets Grid
    
    private var assetsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("账户")
                .font(theme.customFont(size: 14, weight: .semibold))
                .foregroundStyle(theme.textSecondary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: theme.padding) {
                ForEach(assets) { asset in
                    AssetCard(asset: asset)
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard")
                .font(.system(size: 50))
                .foregroundStyle(theme.textTertiary)
            
            Text("添加你的第一个账户")
                .font(theme.customFont(size: 16, weight: .medium))
                .foregroundStyle(theme.textSecondary)
            
            Button {
                theme.mediumHaptic()
                showAddAsset = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("添加账户")
                }
                .font(theme.customFont(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(theme.primaryAccent)
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0"
    }
}

// MARK: - Asset Card

struct AssetCard: View {
    @Environment(\.appTheme) private var theme
    
    let asset: Asset
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon and type
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: asset.colorHex).opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: asset.iconName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(hex: asset.colorHex))
                }
                
                Spacer()
                
                Text(asset.type.rawValue)
                    .font(theme.customFont(size: 10, weight: .medium))
                    .foregroundStyle(theme.textTertiary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.cardBackgroundElevated)
                    .clipShape(Capsule())
            }
            
            // Name & Balance
            VStack(alignment: .leading, spacing: 4) {
                Text(asset.name)
                    .font(theme.customFont(size: 14, weight: .semibold))
                    .foregroundStyle(theme.textPrimary)
                    .lineLimit(1)
                
                Text(formatAmount(asset.balance))
                    .font(theme.amountFont(size: 16))
                    .foregroundStyle(asset.type == .credit ? theme.expenseRed : theme.textPrimary)
            }
        }
        .padding(theme.padding)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        let prefix = asset.type == .credit ? "-" : ""
        return prefix + (formatter.string(from: amount as NSDecimalNumber) ?? "¥0")
    }
}

// MARK: - Add Asset Sheet

struct AddAssetSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appTheme) private var theme
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var balance = ""
    @State private var selectedType: AssetType = .debit
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("账户名称", text: $name)
                    
                    Picker("类型", selection: $selectedType) {
                        ForEach(AssetType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.iconName)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    
                    HStack {
                        Text("¥")
                        TextField("余额", text: $balance)
                            .keyboardType(.decimalPad)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(theme.background)
            .navigationTitle("添加账户")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveAsset()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveAsset() {
        let balanceValue = Decimal(string: balance) ?? 0
        
        let asset = Asset(
            name: name,
            type: selectedType,
            balance: balanceValue
        )
        
        modelContext.insert(asset)
        theme.successHaptic()
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AssetManagementView()
    }
    .modelContainer(for: [Asset.self], inMemory: true)
    .environment(\.appTheme, SoftPopTheme())
}
