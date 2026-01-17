//
//  ProfileView.swift
//  VisualCents
//
//  User profile and tools page
//

import SwiftUI
import SwiftData

/// User profile with stats and tools grid
struct ProfileView: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.modelContext) private var modelContext
    @Query private var transactions: [Transaction]
    @Query private var goals: [SavingsGoal]
    
    @State private var showSettings = false
    
    // MARK: - Computed
    
    private var daysRecorded: Int {
        guard let firstTransaction = transactions.sorted(by: { $0.createdAt < $1.createdAt }).first else {
            return 0
        }
        let days = Calendar.current.dateComponents([.day], from: firstTransaction.createdAt, to: Date()).day ?? 0
        return max(1, days)
    }
    
    private var totalTransactions: Int {
        transactions.count
    }
    
    private var completedGoals: Int {
        goals.filter { $0.status == .completed }.count
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: theme.paddingLarge) {
                // Profile header
                profileHeader
                
                // Stats cards
                statsSection
                
                // Tools grid
                toolsGrid
                
                Spacer()
                    .frame(height: 100)
            }
            .padding(theme.padding)
        }
        .background(theme.background)
        .navigationTitle("我的")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [theme.primaryAccent, theme.secondaryAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
            }
            
            VStack(spacing: 4) {
                Text("记账达人")
                    .font(theme.customFont(size: 20, weight: .bold))
                    .foregroundStyle(theme.textPrimary)
                
                Text("已坚持记账 \(daysRecorded) 天")
                    .font(theme.customFont(size: 14, weight: .regular))
                    .foregroundStyle(theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cardCornerRadius))
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: theme.padding) {
            ProfileStatCard(
                value: "\(totalTransactions)",
                label: "总交易",
                icon: "list.bullet.rectangle",
                color: theme.primaryAccent
            )
            
            ProfileStatCard(
                value: "\(completedGoals)",
                label: "完成目标",
                icon: "trophy.fill",
                color: theme.warningYellow
            )
            
            ProfileStatCard(
                value: "\(daysRecorded)",
                label: "连续天数",
                icon: "flame.fill",
                color: theme.expenseRed
            )
        }
    }
    
    // MARK: - Tools Grid
    
    private var toolsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("工具")
                .font(theme.customFont(size: 14, weight: .semibold))
                .foregroundStyle(theme.textSecondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                ToolButton(icon: "gear", title: "设置") {
                    showSettings = true
                }
                
                ToolButton(icon: "square.and.arrow.up", title: "导出") {
                    // TODO: Export
                }
                
                ToolButton(icon: "bell.badge", title: "提醒") {
                    // TODO: Reminders
                }
                
                ToolButton(icon: "dollarsign.arrow.circlepath", title: "汇率") {
                    // TODO: Exchange rates
                }
                
                ToolButton(icon: "chart.bar.doc.horizontal", title: "年度账单") {
                    // TODO: Annual report
                }
                
                ToolButton(icon: "creditcard", title: "资产") {
                    // TODO: Assets
                }
                
                ToolButton(icon: "tag", title: "分类管理") {
                    // TODO: Categories
                }
                
                ToolButton(icon: "questionmark.circle", title: "帮助") {
                    // TODO: Help
                }
            }
        }
        .padding(theme.padding)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cardCornerRadius))
    }
}

// MARK: - Profile Stat Card

struct ProfileStatCard: View {
    @Environment(\.appTheme) private var theme
    
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
            
            Text(value)
                .font(theme.amountFont(size: 20))
                .foregroundStyle(theme.textPrimary)
            
            Text(label)
                .font(theme.customFont(size: 11, weight: .medium))
                .foregroundStyle(theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
    }
}

// MARK: - Tool Button

struct ToolButton: View {
    @Environment(\.appTheme) private var theme
    
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            theme.lightHaptic()
            action()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.cardBackgroundElevated)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(theme.primaryAccent)
                }
                
                Text(title)
                    .font(theme.customFont(size: 11, weight: .medium))
                    .foregroundStyle(theme.textSecondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileView()
    }
    .modelContainer(for: [Transaction.self, SavingsGoal.self], inMemory: true)
    .environment(\.appTheme, SoftPopTheme())
}
