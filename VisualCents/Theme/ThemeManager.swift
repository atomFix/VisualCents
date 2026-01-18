//
//  ThemeManager.swift
//  VisualCents
//
//  Simplified theme manager - single theme only
//

import SwiftUI

/// Observable object that manages the current theme
@Observable
final class ThemeManager {

    /// The current theme - always CharcoalTheme
    let current: any AppTheme = CharcoalTheme()

    init() {}
}

// MARK: - Environment Object Extension

private struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager()
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}
