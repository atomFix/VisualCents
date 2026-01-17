//
//  SettingsView.swift
//  VisualCents
//
//  App settings and preferences with theme switching
//

import SwiftUI

/// Settings and preferences view
struct SettingsView: View {
    // MARK: - Environment
    
    @Environment(ThemeManager.self) private var themeManager: ThemeManager?
    @Environment(\.appTheme) private var theme
    
    // MARK: - State
    
    @AppStorage("currency") private var currency = "CNY"
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    
    // MARK: - Computed
    
    private var currentThemeId: AvailableTheme {
        themeManager?.currentThemeId ?? .softPop
    }
    
    // MARK: - Body
    
    var body: some View {
        List {
            // Theme Selection
            Section {
                ForEach(AvailableTheme.allCases) { availableTheme in
                    ThemeSelectionRow(
                        theme: availableTheme,
                        isSelected: currentThemeId == availableTheme
                    ) {
                        theme.mediumHaptic()
                        themeManager?.setTheme(availableTheme)
                    }
                }
            } header: {
                Text("外观主题")
                    .font(theme.customFont(size: 12, weight: .medium))
                    .foregroundStyle(theme.textTertiary)
            }
            .listRowBackground(theme.cardBackground)
            
            // General Settings
            Section {
                // Currency
                ThemedSettingsRow(
                    icon: "yensign.circle.fill",
                    iconColor: theme.incomeGreen,
                    title: "货币",
                    value: currencyName
                )
                
                // Haptic Feedback
                ThemedSettingsToggle(
                    icon: "waveform",
                    iconColor: theme.primaryAccent,
                    title: "触感反馈",
                    isOn: $hapticEnabled
                )
                
                // Notifications
                ThemedSettingsToggle(
                    icon: "bell.fill",
                    iconColor: theme.expenseRed,
                    title: "预算提醒",
                    isOn: $notificationsEnabled
                )
            } header: {
                Text("通用")
                    .font(theme.customFont(size: 12, weight: .medium))
                    .foregroundStyle(theme.textTertiary)
            }
            .listRowBackground(theme.cardBackground)
            
            // Data Section
            Section {
                ThemedSettingsRow(
                    icon: "icloud.fill",
                    iconColor: theme.secondaryAccent,
                    title: "iCloud 同步",
                    value: "已开启"
                )
                
                ThemedSettingsButton(
                    icon: "arrow.down.circle.fill",
                    iconColor: theme.incomeGreen,
                    title: "导出数据"
                ) {
                    theme.mediumHaptic()
                }
                
                ThemedSettingsButton(
                    icon: "arrow.up.circle.fill",
                    iconColor: theme.secondaryAccent,
                    title: "导入数据"
                ) {
                    theme.mediumHaptic()
                }
            } header: {
                Text("数据")
                    .font(theme.customFont(size: 12, weight: .medium))
                    .foregroundStyle(theme.textTertiary)
            }
            .listRowBackground(theme.cardBackground)
            
            // About Section
            Section {
                ThemedSettingsRow(
                    icon: "info.circle.fill",
                    iconColor: theme.textSecondary,
                    title: "版本",
                    value: "1.0.0"
                )
                
                ThemedSettingsButton(
                    icon: "star.fill",
                    iconColor: theme.warningYellow,
                    title: "给我们评分"
                ) {
                    theme.mediumHaptic()
                }
                
                ThemedSettingsButton(
                    icon: "envelope.fill",
                    iconColor: theme.primaryAccent,
                    title: "反馈建议"
                ) {
                    theme.mediumHaptic()
                }
            } header: {
                Text("关于")
                    .font(theme.customFont(size: 12, weight: .medium))
                    .foregroundStyle(theme.textTertiary)
            }
            .listRowBackground(theme.cardBackground)
            
            // Danger Zone
            Section {
                ThemedSettingsButton(
                    icon: "trash.fill",
                    iconColor: theme.expenseRed,
                    title: "清除所有数据",
                    isDestructive: true
                ) {
                    theme.errorHaptic()
                }
            } header: {
                Text("危险操作")
                    .font(theme.customFont(size: 12, weight: .medium))
                    .foregroundStyle(theme.expenseRed)
            }
            .listRowBackground(theme.cardBackground)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(theme.background)
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var currencyName: String {
        switch currency {
        case "CNY": return "人民币 ¥"
        case "USD": return "美元 $"
        case "EUR": return "欧元 €"
        default: return currency
        }
    }
}

// MARK: - Theme Selection Row

struct ThemeSelectionRow: View {
    @Environment(\.appTheme) private var theme
    
    let selectedTheme: AvailableTheme
    let isSelected: Bool
    let action: () -> Void
    
    init(theme: AvailableTheme, isSelected: Bool, action: @escaping () -> Void) {
        self.selectedTheme = theme
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Theme preview circle
                ZStack {
                    Circle()
                        .fill(selectedTheme.theme.primaryAccent)
                        .frame(width: 36, height: 36)
                    
                    Circle()
                        .fill(selectedTheme.theme.background)
                        .frame(width: 18, height: 18)
                }
                .overlay(
                    Circle()
                        .stroke(isSelected ? theme.primaryAccent : Color.clear, lineWidth: 2)
                        .frame(width: 42, height: 42)
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(selectedTheme.displayName)
                        .font(theme.customFont(size: 16, weight: .medium))
                        .foregroundStyle(theme.textPrimary)
                    
                    Text(selectedTheme == .softPop ? "深色活力" : "浅色简洁")
                        .font(theme.customFont(size: 12, weight: .regular))
                        .foregroundStyle(theme.textTertiary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(theme.primaryAccent)
                }
            }
            .padding(.vertical, 6)
        }
    }
}

// MARK: - Themed Settings Row

struct ThemedSettingsRow: View {
    @Environment(\.appTheme) private var theme
    
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            
            Text(title)
                .font(theme.customFont(size: 16, weight: .regular))
                .foregroundStyle(theme.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(theme.customFont(size: 16, weight: .regular))
                .foregroundStyle(theme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Themed Settings Toggle

struct ThemedSettingsToggle: View {
    @Environment(\.appTheme) private var theme
    
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            
            Text(title)
                .font(theme.customFont(size: 16, weight: .regular))
                .foregroundStyle(theme.textPrimary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(theme.primaryAccent)
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Themed Settings Button

struct ThemedSettingsButton: View {
    @Environment(\.appTheme) private var theme
    
    let icon: String
    let iconColor: Color
    let title: String
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(iconColor)
                }
                
                Text(title)
                    .font(theme.customFont(size: 16, weight: .regular))
                    .foregroundStyle(isDestructive ? theme.expenseRed : theme.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.textTertiary)
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(ThemeManager())
    .environment(\.appTheme, SoftPopTheme())
}
