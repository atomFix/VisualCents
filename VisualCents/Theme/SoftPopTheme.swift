//
//  SoftPopTheme.swift
//  VisualCents
//
//  Default "Soft Pop" theme - vibrant, modern, dark mode
//

import SwiftUI

/// Soft Pop theme - The default vibrant dark theme
struct SoftPopTheme: AppTheme {
    
    // MARK: - Identity
    
    let name = "Soft Pop"
    let id = "soft_pop"
    
    // MARK: - Colors
    
    var background: Color {
        Color(red: 0.08, green: 0.08, blue: 0.12)
    }
    
    var cardBackground: Color {
        Color(red: 0.12, green: 0.12, blue: 0.16)
    }
    
    var cardBackgroundElevated: Color {
        Color(red: 0.16, green: 0.16, blue: 0.20)
    }
    
    var primaryAccent: Color {
        Color(red: 0.55, green: 0.45, blue: 0.95) // Soft violet
    }
    
    var secondaryAccent: Color {
        Color(red: 0.35, green: 0.65, blue: 0.95) // Soft blue
    }
    
    var incomeGreen: Color {
        Color(red: 0.35, green: 0.85, blue: 0.65) // Soft teal
    }
    
    var expenseRed: Color {
        Color(red: 0.95, green: 0.55, blue: 0.45) // Muted coral
    }
    
    var warningYellow: Color {
        Color(red: 0.95, green: 0.75, blue: 0.35)
    }
    
    var textPrimary: Color {
        Color(white: 0.95)
    }
    
    var textSecondary: Color {
        Color(white: 0.65)
    }
    
    var textTertiary: Color {
        Color(white: 0.45)
    }
    
    // MARK: - Typography
    
    func customFont(size: CGFloat, weight: Font.Weight) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    
    func heroFont(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    func amountFont(size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    // MARK: - Metrics
    
    var cornerRadius: CGFloat { 12 }
    var cardCornerRadius: CGFloat { 20 }
    var buttonCornerRadius: CGFloat { 14 }
    var padding: CGFloat { 16 }
    var paddingSmall: CGFloat { 8 }
    var paddingLarge: CGFloat { 24 }
    
    // MARK: - Shape Modifiers
    
    func styleCard<Content: View>(_ content: Content) -> AnyView {
        AnyView(
            content
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
                .shadow(color: primaryAccent.opacity(0.1), radius: 12, y: 4)
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
            bgColor = cardBackgroundElevated
            fgColor = textPrimary
        case .keypad:
            bgColor = cardBackground
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
                    .fill(.ultraThinMaterial)
                
                LinearGradient(
                    colors: [cardBackground.opacity(0.9), cardBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                VStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [primaryAccent.opacity(0.3), secondaryAccent.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 0.5)
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
