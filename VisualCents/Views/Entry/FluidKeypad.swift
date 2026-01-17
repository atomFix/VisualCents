//
//  FluidKeypad.swift
//  VisualCents
//
//  Custom numeric keypad with ripple effects and haptic feedback
//

import SwiftUI

/// Fluid numeric keypad for amount entry
struct FluidKeypad: View {
    @Binding var value: String
    var onDone: () -> Void
    
    private let buttons: [[KeypadButton]] = [
        [.digit("1"), .digit("2"), .digit("3")],
        [.digit("4"), .digit("5"), .digit("6")],
        [.digit("7"), .digit("8"), .digit("9")],
        [.decimal, .digit("0"), .delete]
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<buttons.count, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(buttons[row], id: \.self) { button in
                        KeypadButtonView(
                            button: button,
                            action: { handleButton(button) }
                        )
                    }
                }
            }
        }
        .padding(.horizontal, VCMetrics.padding)
    }
    
    private func handleButton(_ button: KeypadButton) {
        switch button {
        case .digit(let digit):
            // Prevent leading zeros except for decimals
            if value == "0" && digit != "." {
                value = digit
            } else if value.count < 10 {
                value += digit
            }
            VCHaptics.light()
            
        case .decimal:
            if !value.contains(".") {
                value += value.isEmpty ? "0." : "."
            }
            VCHaptics.light()
            
        case .delete:
            if !value.isEmpty {
                value.removeLast()
            }
            VCHaptics.light()
        }
    }
}

// MARK: - Keypad Button Type

enum KeypadButton: Hashable {
    case digit(String)
    case decimal
    case delete
    
    var display: String {
        switch self {
        case .digit(let d): return d
        case .decimal: return "."
        case .delete: return "⌫"
        }
    }
    
    var isSpecial: Bool {
        switch self {
        case .digit: return false
        case .decimal, .delete: return true
        }
    }
}

// MARK: - Keypad Button View

struct KeypadButtonView: View {
    let button: KeypadButton
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var ripplePosition: CGPoint = .zero
    @State private var showRipple = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 16)
                    .fill(button.isSpecial ? VCColors.cardBackgroundElevated : VCColors.cardBackground)
                
                // Ripple effect
                if showRipple {
                    Circle()
                        .fill(VCColors.accent.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .scaleEffect(showRipple ? 2 : 0)
                        .opacity(showRipple ? 0 : 1)
                        .position(ripplePosition)
                        .animation(.easeOut(duration: 0.4), value: showRipple)
                }
                
                // Label
                Group {
                    if case .delete = button {
                        Image(systemName: "delete.left.fill")
                            .font(.system(size: 22, weight: .medium))
                    } else {
                        Text(button.display)
                            .font(VCFont.title(28))
                    }
                }
                .foregroundStyle(button.isSpecial ? VCColors.textSecondary : VCColors.textPrimary)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isPressed {
                            isPressed = true
                            ripplePosition = value.location
                            showRipple = true
                            
                            // Reset ripple
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                showRipple = false
                            }
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        action()
                    }
            )
        }
        .aspectRatio(1.5, contentMode: .fit)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Text("¥ 123.45")
            .font(VCFont.hero(48))
            .foregroundStyle(VCColors.textPrimary)
            .padding()
        
        FluidKeypad(value: .constant("123.45")) {
            print("Done")
        }
    }
    .padding()
    .background(VCColors.backgroundPrimary)
    .preferredColorScheme(.dark)
}
