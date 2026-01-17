//
//  AppTheme.swift
//  VisualCents
//
//  Theme protocol for UI decoupling
//

import SwiftUI

// MARK: - Button Type

enum ButtonType {
    case primary
    case secondary
    case keypad
    case destructive
}

// MARK: - App Theme Protocol

/// Protocol that defines all visual properties for a theme
/// All feature views should use these properties instead of hardcoded values
protocol AppTheme {
    
    // MARK: - Identity
    
    var name: String { get }
    var id: String { get }
    
    // MARK: - Semantic Colors
    
    /// Main app background color
    var background: Color { get }
    
    /// Secondary background (for cards, containers)
    var cardBackground: Color { get }
    
    /// Elevated card background
    var cardBackgroundElevated: Color { get }
    
    /// Primary brand/accent color
    var primaryAccent: Color { get }
    
    /// Secondary accent color
    var secondaryAccent: Color { get }
    
    /// Income/positive amount color
    var incomeGreen: Color { get }
    
    /// Expense/negative amount color
    var expenseRed: Color { get }
    
    /// Warning color
    var warningYellow: Color { get }
    
    /// Primary text color
    var textPrimary: Color { get }
    
    /// Secondary text color
    var textSecondary: Color { get }
    
    /// Tertiary/hint text color
    var textTertiary: Color { get }
    
    // MARK: - Typography
    
    /// Returns a custom font for the theme
    func customFont(size: CGFloat, weight: Font.Weight) -> Font
    
    /// Hero/large number font
    func heroFont(size: CGFloat) -> Font
    
    /// Amount display font
    func amountFont(size: CGFloat) -> Font
    
    // MARK: - Shape Modifiers
    
    /// Style a card container
    func styleCard<Content: View>(_ content: Content) -> AnyView
    
    /// Style a button
    func styleButton<Content: View>(_ content: Content, type: ButtonType) -> AnyView
    
    /// Style the tab bar background
    func styleTabBackground() -> AnyView
    
    /// Style the navigation bar
    func styleNavBackground() -> AnyView
    
    // MARK: - Metrics
    
    var cornerRadius: CGFloat { get }
    var cardCornerRadius: CGFloat { get }
    var buttonCornerRadius: CGFloat { get }
    var padding: CGFloat { get }
    var paddingSmall: CGFloat { get }
    var paddingLarge: CGFloat { get }
    
    // MARK: - Haptics
    
    func lightHaptic()
    func mediumHaptic()
    func heavyHaptic()
    func successHaptic()
    func errorHaptic()
}

// MARK: - Default Implementations

extension AppTheme {
    
    func lightHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func mediumHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func heavyHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    func successHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func errorHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

// MARK: - Environment Key

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: any AppTheme = SoftPopTheme()
}

extension EnvironmentValues {
    var appTheme: any AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    func appTheme(_ theme: any AppTheme) -> some View {
        environment(\.appTheme, theme)
    }
}
