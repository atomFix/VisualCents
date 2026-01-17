//
//  OilPaintTheme.swift
//  VisualCents
//
//  Van Gogh inspired oil painting theme with rich textures
//

import SwiftUI

/// Oil Paint / Impressionist theme (Starry Night inspired)
struct OilPaintTheme: AppTheme {
    
    // MARK: - Identity
    
    let name = "油画风格"
    let id = "oilpaint"
    
    // MARK: - Color Palette (Van Gogh)
    
    /// Deep starry night blue
    let background = Color(red: 0.12, green: 0.15, blue: 0.28)
    
    /// Slightly lighter blue with warmth
    let cardBackground = Color(red: 0.18, green: 0.22, blue: 0.38)
    
    /// Warm blue elevated
    let cardBackgroundElevated = Color(red: 0.25, green: 0.30, blue: 0.45)
    
    /// Sunflower yellow
    let primaryAccent = Color(red: 0.95, green: 0.78, blue: 0.15)
    
    /// Starry swirl blue
    let secondaryAccent = Color(red: 0.30, green: 0.55, blue: 0.85)
    
    /// Cypress green
    let incomeGreen = Color(red: 0.35, green: 0.65, blue: 0.30)
    
    /// Warm vermillion
    let expenseRed = Color(red: 0.85, green: 0.35, blue: 0.25)
    
    /// Wheat field yellow
    let warningYellow = Color(red: 0.95, green: 0.70, blue: 0.20)
    
    /// Cream white (not pure)
    let textPrimary = Color(red: 0.95, green: 0.92, blue: 0.85)
    
    /// Soft lavender
    let textSecondary = Color(red: 0.75, green: 0.72, blue: 0.80)
    
    /// Muted blue-gray
    let textTertiary = Color(red: 0.55, green: 0.52, blue: 0.60)
    
    // MARK: - Metrics
    
    let cornerRadius: CGFloat = 12
    let cardCornerRadius: CGFloat = 20
    let buttonCornerRadius: CGFloat = 16
    let padding: CGFloat = 16
    let paddingSmall: CGFloat = 8
    let paddingLarge: CGFloat = 24
    
    // MARK: - Typography (Serif)
    
    func customFont(size: CGFloat, weight: Font.Weight) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
    
    func heroFont(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .serif)
    }
    
    func amountFont(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .serif)
    }
    
    // MARK: - Shape Modifiers
    
    func styleCard<Content: View>(_ content: Content) -> AnyView {
        AnyView(
            content
                .padding(padding)
                .background(
                    ZStack {
                        // Base gradient simulating thick paint
                        RoundedRectangle(cornerRadius: cardCornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        cardBackground,
                                        cardBackground.opacity(0.9),
                                        cardBackgroundElevated.opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // Brush stroke texture overlay
                        RoundedRectangle(cornerRadius: cardCornerRadius)
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(0.08),
                                        Color.clear,
                                        primaryAccent.opacity(0.03)
                                    ],
                                    center: .topLeading,
                                    startRadius: 20,
                                    endRadius: 200
                                )
                            )
                        
                        // Light highlight stroke (oil reflection)
                        RoundedRectangle(cornerRadius: cardCornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                )
                .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 6)
                .shadow(color: secondaryAccent.opacity(0.15), radius: 20, x: 0, y: 10)
        )
    }
    
    func styleButton<Content: View>(_ content: Content, type: ButtonType) -> AnyView {
        let colors = buttonColors(for: type)
        
        return AnyView(
            content
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    ZStack {
                        // Impasto 3D gradient (thick paint effect)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        colors.0.opacity(0.9),
                                        colors.0,
                                        colors.1
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        // Oil reflection highlight
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.5),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .center
                                ),
                                lineWidth: 1.5
                            )
                            .padding(1)
                    }
                )
                .shadow(color: colors.1.opacity(0.5), radius: 8, x: 0, y: 4)
        )
    }
    
    private func buttonColors(for type: ButtonType) -> (Color, Color) {
        switch type {
        case .primary:
            return (primaryAccent, Color(red: 0.75, green: 0.55, blue: 0.05))
        case .secondary:
            return (secondaryAccent, Color(red: 0.20, green: 0.40, blue: 0.65))
        case .keypad:
            return (cardBackgroundElevated, cardBackground)
        case .destructive:
            return (expenseRed, Color(red: 0.65, green: 0.20, blue: 0.15))
        }
    }
    
    func styleTabBackground() -> AnyView {
        AnyView(
            ZStack {
                background
                
                // Canvas texture simulation
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.02),
                        Color.clear,
                        primaryAccent.opacity(0.02)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
    }
    
    func styleNavBackground() -> AnyView {
        AnyView(
            background
                .overlay(
                    LinearGradient(
                        colors: [primaryAccent.opacity(0.1), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        let theme = OilPaintTheme()
        
        Text("油画主题")
            .font(theme.heroFont(size: 32))
            .foregroundColor(theme.textPrimary)
        
        theme.styleCard(
            VStack {
                Text("卡片示例")
                    .font(theme.customFont(size: 16, weight: .semibold))
                    .foregroundColor(theme.textPrimary)
                Text("¥1,234.00")
                    .font(theme.amountFont(size: 28))
                    .foregroundColor(theme.primaryAccent)
            }
        )
        
        theme.styleButton(
            Text("确认").foregroundColor(.black),
            type: .primary
        )
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(OilPaintTheme().background)
}
