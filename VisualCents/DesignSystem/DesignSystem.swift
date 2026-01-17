//
//  DesignSystem.swift
//  VisualCents
//
//  Centralized design tokens for the "Friendly, Fluid, Tangible" aesthetic
//

import SwiftUI

// MARK: - Color Palette

/// VisualCents color palette - "Soft Pop" aesthetic (Legacy constants)
enum VCColors {
    // MARK: Primary Colors
    
    static let positive = Color(hex: "58D68D")
    static let expense = Color(hex: "FF9F68")
    static let accent = Color(hex: "8E7CC3")
    static let accentSecondary = Color(hex: "5DADE2")
    
    // MARK: Semantic Colors
    
    static let warning = Color(hex: "F0B429")
    static let danger = Color(hex: "E74C3C")
    
    // MARK: Background Colors
    
    static let backgroundPrimary = Color(hex: "0D0D0F")
    static let cardBackground = Color(hex: "1A1A1E")
    static let cardBackgroundElevated = Color(hex: "242428")
    static let glassOverlay = Color.white.opacity(0.05)
    
    // MARK: Text Colors
    
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.4)
}

// MARK: - Typography

enum VCFont {
    static func hero(_ size: CGFloat = 48) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
    
    static func title(_ size: CGFloat = 24) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    static func headline(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    static func body(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
    
    static func caption(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
    
    static func amount(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
}

// MARK: - Metrics

enum VCMetrics {
    static let cardCornerRadius: CGFloat = 24
    static let buttonCornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
    static let paddingLarge: CGFloat = 24
    static let paddingSmall: CGFloat = 8
    
    static let shadowRadius: CGFloat = 20
    static let shadowOpacity: CGFloat = 0.3
}

// MARK: - Shadows

extension View {
    func vcCardShadow(color: Color = VCColors.accent) -> some View {
        self.shadow(
            color: color.opacity(VCMetrics.shadowOpacity),
            radius: VCMetrics.shadowRadius,
            x: 0,
            y: 8
        )
    }
    
    func vcInnerGlow(color: Color = .white.opacity(0.1)) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: VCMetrics.cardCornerRadius)
                .stroke(color, lineWidth: 1)
        )
    }
}

// MARK: - Glassmorphism

extension View {
    func vcGlassBackground() -> some View {
        self
            .background(.ultraThinMaterial)
            .background(VCColors.glassOverlay)
            .clipShape(RoundedRectangle(cornerRadius: VCMetrics.cardCornerRadius))
    }
    
    func vcCardStyle(shadowColor: Color = VCColors.accent) -> some View {
        self
            .background(VCColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: VCMetrics.cardCornerRadius))
            .vcInnerGlow()
            .vcCardShadow(color: shadowColor)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
