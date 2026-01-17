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
                    onItemSelected: { _ in
                        closeMenu()
                    }
                )
                .frame(width: menuWidth)
                .offset(x: -menuWidth * (1 - openProgress) * 0.3)
                .opacity(0.3 + openProgress * 0.7)
                
                // Main Content
                mainContent
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: openProgress * 20,
                            style: .continuous
                        )
                    )
                    .scaleEffect(1 - openProgress * 0.05)
                    .shadow(
                        color: Color.black.opacity(openProgress * 0.3),
                        radius: openProgress * 20,
                        x: -openProgress * 5, y: 0
                    )
                    .overlay(
                        // Dim overlay
                        Color.black
                            .opacity(openProgress * 0.3)
                            .ignoresSafeArea()
                            .allowsHitTesting(openProgress > 0.1)
                            .onTapGesture {
                                closeMenu()
                            }
                    )
            }
            .offset(x: contentXOffset)
            .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.86, blendDuration: 0.25), value: isMenuOpen)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        NavigationStack {
            Group {
                switch selectedMenuItem {
                case .dashboard:
                    DashboardView()
                case .statistics:
                    StatisticsView()
                case .savings:
                    SavingsView()
                case .assets:
                    AssetManagementView()
                case .budget:
                    BudgetPlanningView()
                case .transactions:
                    TransactionListView()
                case .settings:
                    SettingsView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        toggleMenu()
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(theme.textPrimary)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(theme.background, for: .navigationBar)
            .toolbarColorScheme(isDarkTheme ? .dark : .light, for: .navigationBar)
        }
    }
    
    private var isDarkTheme: Bool {
        // Simple heuristic for toolbar brightness
        if theme.id == "soft_pop" || theme.id == "oilpaint" {
            return true
        }
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
        withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.86)) {
            isMenuOpen.toggle()
            dragProgress = 0
        }
    }
    
    private func openMenu() {
        theme.lightHaptic()
        withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.86)) {
            isMenuOpen = true
            dragProgress = 0
        }
    }
    
    private func closeMenu() {
        withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.86)) {
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
