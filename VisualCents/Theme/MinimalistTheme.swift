//
//  MinimalistTheme.swift
//  VisualCents
//
//  Clean minimalist light theme
//

import SwiftUI

/// Minimalist theme - Clean, light, Apple-like
struct MinimalistTheme: AppTheme {
    
    // MARK: - Identity
    
    let name = "极简"
    let id = "minimalist"
    
    // MARK: - Colors
    
    var background: Color {
        Color(red: 0.96, green: 0.96, blue: 0.97)
    }
    
    var cardBackground: Color {
        .white
    }
    
    var cardBackgroundElevated: Color {
        Color(red: 0.98, green: 0.98, blue: 0.98)
    }
    
    var primaryAccent: Color {
        Color(red: 0.0, green: 0.48, blue: 1.0) // iOS Blue
    }
    
    var secondaryAccent: Color {
        Color(red: 0.35, green: 0.35, blue: 0.85)
    }
    
    var incomeGreen: Color {
        Color(red: 0.2, green: 0.78, blue: 0.35) // iOS Green
    }
    
    var expenseRed: Color {
        Color(red: 1.0, green: 0.23, blue: 0.19) // iOS Red
    }
    
    var warningYellow: Color {
        Color(red: 1.0, green: 0.8, blue: 0.0)
    }
    
    var textPrimary: Color {
        Color(red: 0.1, green: 0.1, blue: 0.1)
    }
    
    var textSecondary: Color {
        Color(red: 0.4, green: 0.4, blue: 0.45)
    }
    
    var textTertiary: Color {
        Color(red: 0.6, green: 0.6, blue: 0.65)
    }
    
    // MARK: - Typography
    
    func customFont(size: CGFloat, weight: Font.Weight) -> Font {
        .system(size: size, weight: weight)
    }
    
    func heroFont(size: CGFloat) -> Font {
        .system(size: size, weight: .bold)
    }
    
    func amountFont(size: CGFloat) -> Font {
        .system(size: size, weight: .medium).monospacedDigit()
    }
    
    // MARK: - Metrics
    
    var cornerRadius: CGFloat { 10 }
    var cardCornerRadius: CGFloat { 16 }
    var buttonCornerRadius: CGFloat { 10 }
    var padding: CGFloat { 16 }
    var paddingSmall: CGFloat { 8 }
    var paddingLarge: CGFloat { 20 }
    
    // MARK: - Shape Modifiers
    
    func styleCard<Content: View>(_ content: Content) -> AnyView {
        AnyView(
            content
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        )
    }
    
    func styleButton<Content: View>(_ content: Content, type: ButtonType) -> AnyView {
        let bgColor: Color
        let fgColor: Color
        
        switch type {
        case .primary:
            bgColor = primaryAccent
            fgColor = .white
        case .secondary:
            bgColor = Color(red: 0.9, green: 0.9, blue: 0.92)
            fgColor = textPrimary
        case .keypad:
            bgColor = .white
            fgColor = textPrimary
        case .destructive:
            bgColor = expenseRed
            fgColor = .white
        }
        
        return AnyView(
            content
                .foregroundStyle(fgColor)
                .background(bgColor)
                .clipShape(RoundedRectangle(cornerRadius: buttonCornerRadius))
        )
    }
    
    func styleTabBackground() -> AnyView {
        AnyView(
            ZStack {
                Rectangle()
                    .fill(.thinMaterial)
                
                VStack {
                    Divider()
                    Spacer()
                }
            }
            .ignoresSafeArea()
        )
    }
    
    func styleNavBackground() -> AnyView {
        AnyView(
            background
                .ignoresSafeArea()
        )
    }
}
