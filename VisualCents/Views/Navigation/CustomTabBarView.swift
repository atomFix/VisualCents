//
//  CustomTabBarView.swift
//  VisualCents
//
//  Custom bottom tab bar with floating add button
//

import SwiftUI
import SwiftData

/// Tab items for navigation
enum VCTab: Int, CaseIterable, Identifiable {
    case timeline = 0
    case stats = 1
    case add = 2
    case savings = 3
    case profile = 4
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .timeline: return "明细"
        case .stats: return "账单"
        case .add: return ""
        case .savings: return "攒钱"
        case .profile: return "我的"
        }
    }
    
    var icon: String {
        switch self {
        case .timeline: return "calendar"
        case .stats: return "chart.pie"
        case .add: return "plus"
        case .savings: return "target"
        case .profile: return "person"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .timeline: return "calendar.circle.fill"
        case .stats: return "chart.pie.fill"
        case .add: return "plus"
        case .savings: return "target"
        case .profile: return "person.fill"
        }
    }
}

/// Main container with custom tab bar
struct CustomTabBarView: View {
    @Environment(\.appTheme) private var theme
    
    @State private var selectedTab: VCTab = .timeline
    @State private var showAddSheet = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            TabView(selection: $selectedTab) {
                NavigationStack {
                    DashboardView()
                }
                .tag(VCTab.timeline)
                
                NavigationStack {
                    StatisticsView()
                }
                .tag(VCTab.stats)
                
                // Placeholder for center button
                Color.clear
                    .tag(VCTab.add)
                
                NavigationStack {
                    SavingsView()
                }
                .tag(VCTab.savings)
                
                NavigationStack {
                    ProfileView()
                }
                .tag(VCTab.profile)
            }
            
            // Custom Tab Bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showAddSheet) {
            ManualEntryView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Custom Tab Bar
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(VCTab.allCases) { tab in
                if tab == .add {
                    // Floating add button
                    floatingAddButton
                } else {
                    tabButton(for: tab)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(tabBarBackground)
    }
    
    // MARK: - Tab Button
    
    private func tabButton(for tab: VCTab) -> some View {
        Button {
            theme.lightHaptic()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22, weight: selectedTab == tab ? .semibold : .regular))
                    .foregroundStyle(selectedTab == tab ? theme.primaryAccent : theme.textTertiary)
                    .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                
                Text(tab.title)
                    .font(theme.customFont(size: 10, weight: selectedTab == tab ? .medium : .regular))
                    .foregroundStyle(selectedTab == tab ? theme.primaryAccent : theme.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Floating Add Button
    
    private var floatingAddButton: some View {
        Button {
            theme.mediumHaptic()
            showAddSheet = true
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [theme.incomeGreen, theme.incomeGreen.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: theme.incomeGreen.opacity(0.4), radius: 10, y: 4)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }
            .offset(y: -20)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Tab Bar Background
    
    private var tabBarBackground: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
            
            theme.cardBackground.opacity(0.9)
            
            VStack(spacing: 0) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [theme.primaryAccent.opacity(0.3), theme.secondaryAccent.opacity(0.2)],
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

// MARK: - Preview

#Preview {
    CustomTabBarView()
        .modelContainer(for: [Transaction.self, Category.self, Budget.self, Asset.self, SavingsGoal.self], inMemory: true)
        .environment(\.appTheme, SoftPopTheme())
}
