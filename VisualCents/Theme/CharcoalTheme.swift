//
//  CharcoalTheme.swift
//  VisualCents
//
//  Warm cream paper sketch theme with pencil strokes
//

import SwiftUI

/// Warm Cream / Pencil Sketch theme (vibrant and clear)
struct CharcoalTheme: AppTheme {

    // MARK: - Identity

    let name = "素描风格"
    let id = "charcoal"

    // MARK: - Color Palette (Warm Cream + Dark Pencil)

    /// Warm cream background - 活力米白色背景
    let background = Color(red: 0.97, green: 0.95, blue: 0.92)

    /// Light cream card - 浅色卡片
    let cardBackground = Color(red: 1.0, green: 0.98, blue: 0.95)

    /// White for elevated cards - 提升卡片
    let cardBackgroundElevated = Color.white

    /// Vibrant purple accent - 紫色主色
    let primaryAccent = Color(red: 0.55, green: 0.35, blue: 0.85)

    /// Bright blue accent - 蓝色次色
    let secondaryAccent = Color(red: 0.30, green: 0.55, blue: 0.95)

    /// Bright green for income - 收入绿
    let incomeGreen = Color(red: 0.30, green: 0.70, blue: 0.45)

    /// Vibrant red for expense - 支出红
    let expenseRed = Color(red: 0.95, green: 0.30, blue: 0.35)

    /// Bright yellow warning - 警告黄
    let warningYellow = Color(red: 1.0, green: 0.70, blue: 0.20)

    /// Dark text - high contrast - 深色主文字
    let textPrimary = Color(red: 0.20, green: 0.20, blue: 0.22)

    /// Medium gray text - 中灰次要文字
    let textSecondary = Color(red: 0.45, green: 0.45, blue: 0.48)

    /// Light gray text - 浅灰三级文字
    let textTertiary = Color(red: 0.60, green: 0.60, blue: 0.62)
    
    // MARK: - Metrics
    
    let cornerRadius: CGFloat = 8
    let cardCornerRadius: CGFloat = 12
    let buttonCornerRadius: CGFloat = 8
    let padding: CGFloat = 16
    let paddingSmall: CGFloat = 8
    let paddingLarge: CGFloat = 24
    
    // MARK: - Typography (Modern & Clean)

    func customFont(size: CGFloat, weight: Font.Weight) -> Font {
        // Use rounded font for modern, friendly feel
        .system(size: size, weight: weight, design: .rounded)
    }

    func heroFont(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    func amountFont(size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    // MARK: - Shape Modifiers
    
    func styleCard<Content: View>(_ content: Content) -> AnyView {
        AnyView(
            content
                .padding(padding)
                .background(
                    ZStack {
                        // Dark card background
                        RoundedRectangle(cornerRadius: cardCornerRadius)
                            .fill(cardBackground)

                        // Subtle texture
                        RoundedRectangle(cornerRadius: cardCornerRadius)
                            .fill(
                                AngularGradient(
                                    colors: [
                                        Color.white.opacity(0.02),
                                        Color.clear,
                                        Color.white.opacity(0.01),
                                        Color.clear
                                    ],
                                    center: .center
                                )
                            )

                        // White chalk border - main stroke
                        RoundedRectangle(cornerRadius: cardCornerRadius)
                            .stroke(
                                Color.white.opacity(0.15),
                                style: StrokeStyle(
                                    lineWidth: 1.5,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )

                        // Second pass - slightly offset for hand-drawn feel
                        RoundedRectangle(cornerRadius: cardCornerRadius + 1)
                            .stroke(
                                Color.white.opacity(0.05),
                                style: StrokeStyle(
                                    lineWidth: 0.8,
                                    lineCap: .round,
                                    dash: [8, 4]
                                )
                            )
                            .offset(x: 0.5, y: 0.5)
                    }
                )
                // Subtle shadow
                .background(
                    RoundedRectangle(cornerRadius: cardCornerRadius)
                        .fill(Color.black.opacity(0.3))
                        .offset(x: 2, y: 2)
                        .blur(radius: 1)
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
                        // Button fill
                        RoundedRectangle(cornerRadius: buttonCornerRadius)
                            .fill(fill)

                        // White chalk border strokes
                        RoundedRectangle(cornerRadius: buttonCornerRadius)
                            .stroke(
                                stroke,
                                style: StrokeStyle(
                                    lineWidth: 2,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )

                        // Double-pass chalk effect
                        RoundedRectangle(cornerRadius: buttonCornerRadius)
                            .stroke(
                                stroke.opacity(0.3),
                                style: StrokeStyle(
                                    lineWidth: 1,
                                    lineCap: .round,
                                    dash: [12, 3]
                                )
                            )
                            .offset(x: -0.5, y: -0.5)
                    }
                )
                // Subtle shadow
                .background(
                    RoundedRectangle(cornerRadius: buttonCornerRadius)
                        .fill(Color.black.opacity(0.25))
                        .offset(x: 2, y: 2)
                        .blur(radius: 1)
                )
        )
    }

    private func buttonStyle(for type: ButtonType) -> (Color, Color) {
        switch type {
        case .primary:
            return (primaryAccent.opacity(0.15), Color.white.opacity(0.3))
        case .secondary:
            return (Color.clear, Color.white.opacity(0.2))
        case .keypad:
            return (Color.white.opacity(0.08), Color.white.opacity(0.15))
        case .destructive:
            return (expenseRed.opacity(0.2), expenseRed)
        }
    }
    
    func styleTabBackground() -> AnyView {
        AnyView(
            ZStack {
                background

                // Subtle chalk dust texture
                Rectangle()
                    .fill(
                        AngularGradient(
                            colors: [
                                Color.white.opacity(0.015),
                                Color.clear,
                                Color.white.opacity(0.01),
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
                    // Top edge line like a chalkboard
                    VStack {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 1)
                        Spacer()
                    }
                )
        )
    }
}

// MARK: - Sketchy Divider

/// A hand-drawn style divider line (chalk on dark board)
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
            .stroke(Color.white.opacity(0.15), style: StrokeStyle(lineWidth: 1, lineCap: .round))
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
