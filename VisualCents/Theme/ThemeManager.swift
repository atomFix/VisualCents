//
//  ThemeManager.swift
//  VisualCents
//
//  Observable theme manager for switching themes
//

import SwiftUI

/// Available themes
enum AvailableTheme: String, CaseIterable, Identifiable {
    case softPop = "soft_pop"
    case minimalist = "minimalist"
    case oilPaint = "oil_paint"
    case charcoal = "charcoal"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .softPop: return "Soft Pop"
        case .minimalist: return "极简"
        case .oilPaint: return "油画风格"
        case .charcoal: return "素描风格"
        }
    }
    
    var theme: any AppTheme {
        switch self {
        case .softPop: return SoftPopTheme()
        case .minimalist: return MinimalistTheme()
        case .oilPaint: return OilPaintTheme()
        case .charcoal: return CharcoalTheme()
        }
    }
}

/// Observable object that manages the current theme
@Observable
final class ThemeManager {
    
    /// The current theme selection
    var currentThemeId: AvailableTheme {
        didSet {
            UserDefaults.standard.set(currentThemeId.rawValue, forKey: "selectedTheme")
        }
    }
    
    /// The actual theme object
    var current: any AppTheme {
        currentThemeId.theme
    }
    
    init(loadFromStorage: Bool = true) {
        if loadFromStorage {
            // Load saved theme or default to charcoal
            if let savedId = UserDefaults.standard.string(forKey: "selectedTheme"),
               let theme = AvailableTheme(rawValue: savedId) {
                self.currentThemeId = theme
            } else {
                self.currentThemeId = .charcoal
            }
        } else {
            // Safe default for static context
            self.currentThemeId = .charcoal
        }
    }
    
    /// Switch to a different theme
    func setTheme(_ theme: AvailableTheme) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentThemeId = theme
        }
    }
}

// MARK: - Environment Object Extension

private struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager(loadFromStorage: false)
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}
