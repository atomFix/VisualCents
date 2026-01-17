//
//  SideMenuView.swift
//  VisualCents
//
//  Polished side drawer menu with global theme synchronization
//

import SwiftUI

/// Side drawer menu view with polished styling
struct SideMenuView: View {
    @Environment(\.appTheme) private var theme
    
    /// Currently selected menu item
    @Binding var selectedItem: MenuItem
    
    /// Callback when menu item is selected
    var onItemSelected: (MenuItem) -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Profile Header
            ThemedProfileHeader()
                .padding(.top, 60)
                .padding(.bottom, 40)
            
            // Menu Items
            VStack(spacing: 4) {
                ForEach(MenuItem.allCases) { item in
                    ThemedMenuItemRow(
                        item: item,
                        isSelected: selectedItem == item
                    ) {
                        theme.mediumHaptic()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedItem = item
                        }
                        // 延迟关闭菜单以显示选中效果
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            onItemSelected(item)
                        }
                    }
                }
            }
            
            Spacer()
            
            // App Version Footer
            VStack(alignment: .leading, spacing: 6) {
                Rectangle()
                    .fill(theme.textTertiary.opacity(0.2))
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                
                HStack {
                    Image(systemName: "paintbrush.fill")
                        .font(.system(size: 12))
                    Text("VisualCents")
                        .font(theme.customFont(size: 12, weight: .medium))
                }
                .foregroundStyle(theme.textTertiary)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(theme.cardBackground)
    }
}

// MARK: - Themed Profile Header

struct ThemedProfileHeader: View {
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
                    .frame(width: 56, height: 56)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.white)
            }
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text("记账达人")
                    .font(theme.customFont(size: 18, weight: .bold))
                    .foregroundStyle(theme.textPrimary)
                
                Text("坚持记录每一笔")
                    .font(theme.customFont(size: 13, weight: .regular))
                    .foregroundStyle(theme.textSecondary)
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Themed Menu Item Row

struct ThemedMenuItemRow: View {
    @Environment(\.appTheme) private var theme
    
    let item: MenuItem
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        let itemColor = item.themeColor(for: theme)
        
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? itemColor.opacity(0.2) : Color.clear)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(isSelected ? itemColor : theme.textSecondary)
                }
                
                // Label
                Text(item.title)
                    .font(theme.customFont(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? theme.textPrimary : theme.textSecondary)
                
                Spacer()
                
                // Chevron for selected
                if isSelected {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(theme.textTertiary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? theme.cardBackgroundElevated : Color.clear)
            )
            .padding(.horizontal, 12)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

// MARK: - Preview

#Preview {
    SideMenuView(selectedItem: .constant(.dashboard)) { _ in }
        .frame(width: 280)
        .environment(\.appTheme, CharcoalTheme())
}
