//
//  MainContainerView.swift
//  VisualCents
//
//  Smooth drawer navigation with dynamic animations and theme support
//

import SwiftUI
import SwiftData

/// Main container with smooth drawer navigation
struct MainContainerView: View {
    // MARK: - Environment

    @Environment(\.appTheme) private var theme

    // MARK: - State

    @State private var isMenuOpen = false
    @State private var selectedMenuItem: MenuItem = .dashboard
    @State private var dragProgress: CGFloat = 0

    // MARK: - Constants

    private let menuWidth: CGFloat = 280
    private let edgeDragWidth: CGFloat = 30
    private let minDragToOpen: CGFloat = 60
    
    // MARK: - Computed
    
    /// 0 = closed, 1 = open
    private var openProgress: CGFloat {
        if isMenuOpen {
            return max(0, 1 + dragProgress)
        } else {
            return max(0, dragProgress)
        }
    }
    
    private var contentXOffset: CGFloat {
        openProgress * menuWidth
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background - use theme background
                theme.background
                    .ignoresSafeArea()

                // Side Menu
                SideMenuView(
                    selectedItem: $selectedMenuItem,
                    onItemSelected: { item in
                        print("🔍 Menu item tapped: \(item.title)")
                        print("🔍 Current selectedMenuItem: \(selectedMenuItem.title)")
                        closeMenu()
                        print("🔍 After closeMenu, selectedMenuItem: \(selectedMenuItem.title)")
                    }
                )
                .frame(width: menuWidth)
                .clipped()

                // Main Content
                mainContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(x: openProgress * menuWidth)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: openProgress * 20,
                            style: .continuous
                        )
                    )
                    .shadow(
                        color: Color.black.opacity(openProgress * 0.3),
                        radius: openProgress * 20,
                        x: -openProgress * 5, y: 0
                    )
                    .overlay(
                        // Dim overlay - 只覆盖主内容，不覆盖菜单
                        Color.black
                            .opacity(openProgress * 0.3)
                            .frame(maxWidth: .infinity)
                            .offset(x: openProgress * menuWidth)
                            .allowsHitTesting(openProgress > 0.1)
                            .onTapGesture {
                                closeMenu()
                            }
                    )
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isMenuOpen)
            .animation(.easeInOut(duration: 0.3), value: selectedMenuItem)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        NavigationStack {
            Group {
                switch selectedMenuItem {
                case .dashboard:
                    DashboardView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .statistics:
                    StatisticsView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .savings:
                    SavingsView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .assets:
                    AssetManagementView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .budget:
                    BudgetPlanningView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .transactions:
                    TransactionListView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .organism:
                    FinancialOrganismView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .organicUI:
                    OrganicUIDemoView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .visualDemo:
                    VisualEffectsDemoView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .settings:
                    SettingsView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedMenuItem)
            .toolbar {
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(theme.background, for: .navigationBar)
            .toolbarColorScheme(isDarkTheme ? .dark : .light, for: .navigationBar)
            .environment(\.openSideMenu, SideMenuOpenAction(action: toggleMenu))
        }
    }

    private var isDarkTheme: Bool {
        // Theme is now light cream color
        return false
    }
    
    private var mainContent: some View {
        contentView
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        handleDrag(value)
                    }
                    .onEnded { value in
                        handleDragEnd(value)
                    }
            )
    }
    
    // MARK: - Logic
    
    private func handleDrag(_ value: DragGesture.Value) {
        let translation = value.translation.width
        if isMenuOpen {
            if translation < 0 { dragProgress = max(-1, translation / menuWidth) }
        } else {
            if value.startLocation.x < edgeDragWidth && translation > 0 {
                dragProgress = min(1, translation / menuWidth)
            }
        }
    }
    
    private func handleDragEnd(_ value: DragGesture.Value) {
        let translation = value.translation.width
        let velocity = value.velocity.width
        
        if isMenuOpen {
            if translation < -minDragToOpen || velocity < -500 { closeMenu() }
            else { dragProgress = 0 }
        } else {
            if translation > minDragToOpen || velocity > 500 { openMenu() }
            else { dragProgress = 0 }
        }
    }
    
    private func toggleMenu() {
        theme.mediumHaptic()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isMenuOpen.toggle()
            dragProgress = 0
        }
    }

    private func openMenu() {
        theme.lightHaptic()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isMenuOpen = true
            dragProgress = 0
        }
    }

    private func closeMenu() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isMenuOpen = false
            dragProgress = 0
        }
    }
}

// MARK: - Preview

#Preview {
    MainContainerView()
        .modelContainer(for: [Transaction.self, Category.self, Budget.self], inMemory: true)
        .environment(\.appTheme, CharcoalTheme())
}
