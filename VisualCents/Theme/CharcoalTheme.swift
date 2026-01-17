//
//  CharcoalTheme.swift
//  VisualCents
//
//  Da Vinci notebook inspired sketch theme with pencil strokes
//

import SwiftUI

/// Charcoal / Pencil Sketch theme (Da Vinci notebook inspired)
struct CharcoalTheme: AppTheme {
    
    // MARK: - Identity
    
    let name = "素描风格"
    let id = "charcoal"
    
    // MARK: - Color Palette (Grayscale + Red Accent)
    
    /// Aged paper off-white
    let background = Color(red: 0.96, green: 0.94, blue: 0.90)
    
    /// Pure white with transparency
    let cardBackground = Color.white.opacity(0.85)
    
    /// Slight gray
    let cardBackgroundElevated = Color(red: 0.92, green: 0.90, blue: 0.87)
    
    /// Graphite black
    let primaryAccent = Color(red: 0.15, green: 0.15, blue: 0.15)
    
    /// Charcoal gray
    let secondaryAccent = Color(red: 0.40, green: 0.40, blue: 0.40)
    
    /// Dark green ink
    let incomeGreen = Color(red: 0.20, green: 0.35, blue: 0.20)
    
    /// Red chalk (Leonardo's style)
    let expenseRed = Color(red: 0.70, green: 0.25, blue: 0.20)
    
    /// Sepia warning
    let warningYellow = Color(red: 0.65, green: 0.50, blue: 0.25)
    
    /// Dark graphite
    let textPrimary = Color(red: 0.12, green: 0.12, blue: 0.12)
    
    /// Medium gray
    let textSecondary = Color(red: 0.35, green: 0.35, blue: 0.35)
    
    /// Light gray
    let textTertiary = Color(red: 0.55, green: 0.55, blue: 0.55)
    
    // MARK: - Metrics
    
    let cornerRadius: CGFloat = 8
    let cardCornerRadius: CGFloat = 12
    let buttonCornerRadius: CGFloat = 8
    let padding: CGFloat = 16
    let paddingSmall: CGFloat = 8
    let paddingLarge: CGFloat = 24
    
    // MARK: - Typography (Handwritten/Monospace)
    
    func customFont(size: CGFloat, weight: Font.Weight) -> Font {
        // Use monospaced for that technical drawing feel
        .system(size: size, weight: weight, design: .monospaced)
    }
    
    func heroFont(size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }
    
    func amountFont(size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
    
    // MARK: - Shape Modifiers
    
    func styleCard<Content: View>(_ content: Content) -> AnyView {
        AnyView(
            content
                .padding(padding)
                .background(
                    ZStack {
                        // Paper background
                        RoundedRectangle(cornerRadius: cardCornerRadius)
                            .fill(cardBackground)
                        
                        // Paper grain texture simulation
                        RoundedRectangle(cornerRadius: cardCornerRadius)
                            .fill(
                                AngularGradient(
                                    colors: [
                                        Color.black.opacity(0.02),
                                        Color.clear,
                                        Color.black.opacity(0.01),
                                        Color.clear
                                    ],
                                    center: .center
                                )
                            )
                        
                        // Sketchy border - main stroke
                        RoundedRectangle(cornerRadius: cardCornerRadius)
                            .stroke(
                                primaryAccent,
                                style: StrokeStyle(
                                    lineWidth: 1.5,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                        
                        // Second pass - slightly offset for hand-drawn feel
                        RoundedRectangle(cornerRadius: cardCornerRadius + 1)
                            .stroke(
                                primaryAccent.opacity(0.3),
                                style: StrokeStyle(
                                    lineWidth: 0.8,
                                    lineCap: .round,
                                    dash: [8, 4]
                                )
                            )
                            .offset(x: 0.5, y: 0.5)
                    }
                )
                // Hard shadow (no blur) - like a stencil
                .background(
                    RoundedRectangle(cornerRadius: cardCornerRadius)
                        .fill(Color.black.opacity(0.08))
                        .offset(x: 3, y: 3)
                )
        )
    }
    
    func styleButton<Content: View>(_ content: Content, type: ButtonType) -> AnyView {
        let (fill, stroke) = buttonStyle(for: type)
        
        return AnyView(
            content
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(
                    ZStack {
                        // Scribble fill (cross-hatch simulation)
                        RoundedRectangle(cornerRadius: buttonCornerRadius)
                            .fill(fill)
                        
                        // Pencil border strokes
                        RoundedRectangle(cornerRadius: buttonCornerRadius)
                            .stroke(
                                stroke,
                                style: StrokeStyle(
                                    lineWidth: 2,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                        
                        // Double-pass pencil effect
                        RoundedRectangle(cornerRadius: buttonCornerRadius)
                            .stroke(
                                stroke.opacity(0.4),
                                style: StrokeStyle(
                                    lineWidth: 1,
                                    lineCap: .round,
                                    dash: [12, 3]
                                )
                            )
                            .offset(x: -0.5, y: -0.5)
                    }
                )
                // Hard shadow offset
                .background(
                    RoundedRectangle(cornerRadius: buttonCornerRadius)
                        .fill(Color.black.opacity(0.1))
                        .offset(x: 2, y: 2)
                )
        )
    }
    
    private func buttonStyle(for type: ButtonType) -> (Color, Color) {
        switch type {
        case .primary:
            return (primaryAccent.opacity(0.1), primaryAccent)
        case .secondary:
            return (Color.clear, secondaryAccent)
        case .keypad:
            return (Color.white.opacity(0.5), primaryAccent.opacity(0.6))
        case .destructive:
            return (expenseRed.opacity(0.1), expenseRed)
        }
    }
    
    func styleTabBackground() -> AnyView {
        AnyView(
            ZStack {
                background
                
                // Paper grain noise simulation
                Rectangle()
                    .fill(
                        AngularGradient(
                            colors: [
                                Color.black.opacity(0.015),
                                Color.clear,
                                Color.black.opacity(0.01),
                                Color.clear
                            ],
                            center: .center
                        )
                    )
            }
        )
    }
    
    func styleNavBackground() -> AnyView {
        AnyView(
            background
                .overlay(
                    // Top edge line like a notebook
                    VStack {
                        Rectangle()
                            .fill(primaryAccent.opacity(0.2))
                            .frame(height: 1)
                        Spacer()
                    }
                )
        )
    }
}

// MARK: - Sketchy Divider

/// A hand-drawn style divider line
struct SketchyDivider: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let y = geo.size.height / 2
                path.move(to: CGPoint(x: 0, y: y))
                
                // Create slightly wavy line
                let segments = Int(geo.size.width / 20)
                for i in 0...segments {
                    let x = CGFloat(i) * 20
                    let yOffset = i % 2 == 0 ? 0.5 : -0.5
                    path.addLine(to: CGPoint(x: x, y: y + yOffset))
                }
            }
            .stroke(Color.black.opacity(0.3), style: StrokeStyle(lineWidth: 1, lineCap: .round))
        }
        .frame(height: 2)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        let theme = CharcoalTheme()
        
        Text("素描主题")
            .font(theme.heroFont(size: 32))
            .foregroundColor(theme.textPrimary)
        
        SketchyDivider()
            .padding(.horizontal)
        
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
            Text("确认").foregroundColor(theme.textPrimary),
            type: .primary
        )
        
        theme.styleButton(
            Text("取消").foregroundColor(theme.expenseRed),
            type: .destructive
        )
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(CharcoalTheme().background)
}
