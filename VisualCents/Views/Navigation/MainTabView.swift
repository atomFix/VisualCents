//
//  MainTabView.swift
//  VisualCents
//
//  Bottom tab navigation - best practice for finance apps
//

import SwiftUI
import SwiftData

/// Main tab-based navigation view
struct MainTabView: View {
    // MARK: - State
    
    @State private var selectedTab: TabItem = .dashboard
    @State private var tabBarVisible = true
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            TabView(selection: $selectedTab) {
                ForEach(TabItem.allCases) { tab in
                    tab.destination
                        .tag(tab)
                }
            }
            .onChange(of: selectedTab) { _, _ in
                VCHaptics.selection()
            }
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Tab Item

enum TabItem: String, CaseIterable, Identifiable {
    case dashboard = "首页"
    case statistics = "统计"
    case add = "记账"
    case transactions = "明细"
    case settings = "设置"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .dashboard: return "house"
        case .statistics: return "chart.pie"
        case .add: return "plus.circle.fill"
        case .transactions: return "list.bullet.rectangle"
        case .settings: return "gearshape"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .statistics: return "chart.pie.fill"
        case .add: return "plus.circle.fill"
        case .transactions: return "list.bullet.rectangle.fill"
        case .settings: return "gearshape.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .dashboard: return VCColors.accent
        case .statistics: return VCColors.accentSecondary
        case .add: return VCColors.positive
        case .transactions: return VCColors.expense
        case .settings: return VCColors.textSecondary
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .dashboard:
            NavigationStack {
                DashboardView()
            }
        case .statistics:
            NavigationStack {
                StatisticsView()
            }
        case .add:
            Color.clear // Handled separately
        case .transactions:
            NavigationStack {
                TransactionListView()
            }
        case .settings:
            NavigationStack {
                SettingsView()
            }
        }
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    @State private var showAddSheet = false
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases) { tab in
                if tab == .add {
                    // Center add button
                    AddButton {
                        showAddSheet = true
                    }
                } else {
                    TabBarButton(
                        tab: tab,
                        isSelected: selectedTab == tab
                    ) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            TabBarBackground()
        )
        .sheet(isPresented: $showAddSheet) {
            ManualEntryView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Tab Bar Background

struct TabBarBackground: View {
    var body: some View {
        ZStack {
            // Blur effect
            Rectangle()
                .fill(.ultraThinMaterial)
            
            // Gradient overlay
            LinearGradient(
                colors: [
                    VCColors.cardBackground.opacity(0.9),
                    VCColors.cardBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Top border
            VStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [VCColors.accent.opacity(0.3), VCColors.accentSecondary.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 0.5)
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Tab Bar Button

struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? tab.color : VCColors.textTertiary)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                
                Text(tab.rawValue)
                    .font(VCFont.caption(10))
                    .foregroundStyle(isSelected ? tab.color : VCColors.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(TabButtonStyle())
    }
}

// MARK: - Add Button

struct AddButton: View {
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            VCHaptics.medium()
            action()
        }) {
            ZStack {
                // Glow effect
                Circle()
                    .fill(VCColors.positive.opacity(0.3))
                    .frame(width: 64, height: 64)
                    .blur(radius: 8)
                
                // Main button
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [VCColors.positive, VCColors.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: VCColors.positive.opacity(0.5), radius: 12, y: 4)
                
                // Icon
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }
            .offset(y: -20)
        }
        .buttonStyle(AddButtonStyle())
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Button Styles

struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AddButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .modelContainer(for: [Transaction.self, Category.self, Budget.self], inMemory: true)
}
