//
//  VisualCentsApp.swift
//  VisualCents
//
//  Personal finance app with frictionless transaction logging
//

import SwiftUI
import SwiftData

@main
struct VisualCentsApp: App {
    
    /// Theme manager for UI styling - pure @State ownership
    @State private var themeManager = ThemeManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self,
            Category.self,
            Budget.self,
            Asset.self,
            SavingsGoal.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ThemedRootView(themeManager: themeManager)
                .onAppear {
                    setupDefaultCategories()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func setupDefaultCategories() {
        let context = sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.isDefault == true }
        )
        
        do {
            let existingDefaults = try context.fetch(descriptor)
            if existingDefaults.isEmpty {
                for category in Category.defaultCategories() {
                    context.insert(category)
                }
                try context.save()
            }
        } catch {
            print("Failed to setup default categories: \(error)")
        }
    }
}

// MARK: - Themed Root View

struct ThemedRootView: View {
    @Bindable var themeManager: ThemeManager

    var body: some View {
        ContentView()
            .environment(themeManager)
            .environment(\.appTheme, themeManager.current)
    }
}
