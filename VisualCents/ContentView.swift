//
//  ContentView.swift
//  VisualCents
//
//  Main entry point - Side drawer navigation
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        MainContainerView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Transaction.self, Category.self, Budget.self, Asset.self, SavingsGoal.self], inMemory: true)
        .environment(ThemeManager())
        .environment(\.appTheme, SoftPopTheme())
}
