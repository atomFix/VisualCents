//
//  BounceButtonStyle.swift
//  VisualCents
//
//  Custom button style with satisfying spring animation
//

import SwiftUI

/// Button style with bouncy spring animation on press
struct BounceButtonStyle: ButtonStyle {
    /// Scale factor when pressed
    var pressedScale: CGFloat = 0.95
    
    /// Haptic feedback intensity
    var hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if newValue {
                    let generator = UIImpactFeedbackGenerator(style: hapticStyle)
                    generator.impactOccurred()
                }
            }
    }
}

/// Button style with more pronounced bounce for important actions
struct HeavyBounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.5, blendDuration: 0), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if newValue {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
            }
    }
}

/// Subtle scale button style for list items
struct SubtlePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    /// Apply bounce button style
    func bounceButton(haptic: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.buttonStyle(BounceButtonStyle(hapticStyle: haptic))
    }
    
    /// Apply heavy bounce button style
    func heavyBounceButton() -> some View {
        self.buttonStyle(HeavyBounceButtonStyle())
    }
    
    /// Apply subtle press style
    func subtlePress() -> some View {
        self.buttonStyle(SubtlePressStyle())
    }
}

// MARK: - Haptic Helpers

/// Centralized haptic feedback generator
enum VCHaptics {
    /// Light tap (scrolling, minor interactions)
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Medium tap (button presses, selections)
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Heavy tap (important actions, confirmations)
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// Success feedback
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Warning feedback
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    /// Error feedback
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    /// Selection change feedback
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
