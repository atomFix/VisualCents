//
//  LiquidKeypadView.swift
//  VisualCents
//
//  Phase 1: The Liquid Keypad - Financial Organism
//  Metaball physics with gooey merging effect
//

import SwiftUI

/// Liquid Keypad with Metaball Effect
/// Buttons merge like liquid droplets when pressed together
struct LiquidKeypadView: View {
    @Environment(\.appTheme) private var theme

    let onNumberPress: (Int) -> Void
    let onDelete: () -> Void
    let onDone: () -> Void

    @State private var pressedButtons: Set<LiquidButton> = []
    @State private var buttonScales: [LiquidButton: CGFloat] = [:]
    @State private var rippleAnimations: [LiquidButton: CGFloat] = [:]

    private let layout = LiquidKeypadLayout()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gooey Effect Layer
                Canvas { context, size in
                    // Step 1: Draw all button circles (will be blurred)
                    drawButtonCircles(in: context, size: size)

                    // Step 2: Draw expanded pressed buttons
                    drawPressedButtons(in: context, size: size)

                    // Step 3: Draw connection lines for nearby pressed buttons
                    drawMetaballConnections(in: context, size: size)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)

                // Blur Layer - Creates the gooey effect
                canvasWithBlur(size: geometry.size)

                // Threshold Layer - Sharpens the blur into solid shapes
                thresholdCanvas(size: geometry.size)

                // Labels Layer - Numbers on top
                labelLayer(size: geometry.size)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(height: layout.totalHeight)
        .background(Color.clear)
    }

    // MARK: - Draw Button Circles (Base Layer)

    private func drawButtonCircles(in context: GraphicsContext, size: CGSize) {
        for button in LiquidButton.allCases {
            let center = layout.position(for: button, in: size)
            let scale = buttonScales[button] ?? 1.0

            // Draw base circle
            var circle = Path(ellipseIn: CGRect(
                x: center.x - layout.buttonRadius * scale,
                y: center.y - layout.buttonRadius * scale,
                width: layout.buttonRadius * 2 * scale,
                height: layout.buttonRadius * 2 * scale
            ))

            context.fill(circle, with: .color(theme.primaryAccent.opacity(0.3)))
        }
    }

    // MARK: - Draw Pressed Buttons (Expanded)

    private func drawPressedButtons(in context: GraphicsContext, size: CGSize) {
        for button in pressedButtons {
            let center = layout.position(for: button, in: size)
            let scale = buttonScales[button] ?? 1.0

            // Expanded circle for pressed button
            var expandedCircle = Path(ellipseIn: CGRect(
                x: center.x - layout.buttonRadius * scale * 1.5,
                y: center.y - layout.buttonRadius * scale * 1.5,
                width: layout.buttonRadius * 3 * scale,
                height: layout.buttonRadius * 3 * scale
            ))

            context.fill(expandedCircle, with: .color(theme.primaryAccent.opacity(0.6)))
        }
    }

    // MARK: - Draw Metaball Connections

    private func drawMetaballConnections(in context: GraphicsContext, size: CGSize) {
        let pressedArray = Array(pressedButtons)

        // Draw connections between nearby pressed buttons
        for i in 0..<pressedArray.count {
            for j in (i+1)..<pressedArray.count {
                let button1 = pressedArray[i]
                let button2 = pressedArray[j]

                let pos1 = layout.position(for: button1, in: size)
                let pos2 = layout.position(for: button2, in: size)

                let distance = sqrt(pow(pos1.x - pos2.x, 2) + pow(pos1.y - pos2.y, 2))

                // If buttons are close enough, draw a connecting shape
                if distance < layout.buttonRadius * 4 {
                    drawMetaballBridge(in: context, from: pos1, to: pos2, distance: distance)
                }
            }
        }
    }

    private func drawMetaballBridge(in context: GraphicsContext, from: CGPoint, to: CGPoint, distance: CGFloat) {
        // Draw a series of overlapping circles to create a smooth bridge
        let steps = Int(distance / 10)
        let dx = (to.x - from.x) / CGFloat(steps)
        let dy = (to.y - from.y) / CGFloat(steps)

        for i in 0...steps {
            let x = from.x + CGFloat(i) * dx
            let y = from.y + CGFloat(i) * dy
            let bridgeCircle = Path(ellipseIn: CGRect(
                x: x - layout.buttonRadius,
                y: y - layout.buttonRadius,
                width: layout.buttonRadius * 2,
                height: layout.buttonRadius * 2
            ))

            context.fill(bridgeCircle, with: .color(theme.primaryAccent.opacity(0.4)))
        }
    }

    // MARK: - Canvas with Blur

    private func canvasWithBlur(size: CGSize) -> some View {
        Canvas { context, size in
            // This canvas will be blurred to create the metaball effect
            for button in LiquidButton.allCases {
                let center = layout.position(for: button, in: size)
                let scale = buttonScales[button] ?? 1.0
                let isPressed = pressedButtons.contains(button)

                let radius = isPressed ? layout.buttonRadius * 1.5 : layout.buttonRadius
                let opacity = isPressed ? 0.8 : 0.4

                var circle = Path(ellipseIn: CGRect(
                    x: center.x - radius * scale,
                    y: center.y - radius * scale,
                    width: radius * 2 * scale,
                    height: radius * 2 * scale
                ))

                context.fill(circle, with: .color(theme.primaryAccent.opacity(opacity)))
            }

            // Draw metaball bridges
            let pressedArray = Array(pressedButtons)
            for i in 0..<pressedArray.count {
                for j in (i+1)..<pressedArray.count {
                    let pos1 = layout.position(for: pressedArray[i], in: size)
                    let pos2 = layout.position(for: pressedArray[j], in: size)
                    let distance = sqrt(pow(pos1.x - pos2.x, 2) + pow(pos1.y - pos2.y, 2))

                    if distance < layout.buttonRadius * 4 {
                        drawMetaballBridge(in: context, from: pos1, to: pos2, distance: distance)
                    }
                }
            }
        }
        .blur(radius: 25) // Heavy blur creates the gooey effect
        .frame(width: size.width, height: size.height)
    }

    // MARK: - Threshold Canvas (Sharpens edges)

    private func thresholdCanvas(size: CGSize) -> some View {
        Canvas { context, size in
            // This is a workaround - we draw the solid shapes on top
            // In a full implementation, this would use a Metal shader with alpha threshold

            for button in LiquidButton.allCases {
                let center = layout.position(for: button, in: size)
                let scale = buttonScales[button] ?? 1.0
                let isPressed = pressedButtons.contains(button)

                let radius = isPressed ? layout.buttonRadius * 1.3 : layout.buttonRadius * 0.9

                var circle = Path(ellipseIn: CGRect(
                    x: center.x - radius * scale,
                    y: center.y - radius * scale,
                    width: radius * 2 * scale,
                    height: radius * 2 * scale
                ))

                // Draw solid outline to sharpen the shape
                context.stroke(
                    circle,
                    with: .color(theme.primaryAccent),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )

                // Fill with lower opacity
                context.fill(circle, with: .color(theme.primaryAccent.opacity(isPressed ? 0.3 : 0.15)))
            }
        }
        .frame(width: size.width, height: size.height)
    }

    // MARK: - Label Layer

    private func labelLayer(size: CGSize) -> some View {
        ZStack {
            ForEach(LiquidButton.allCases, id: \.self) { button in
                let center = layout.position(for: button, in: size)
                let isPressed = pressedButtons.contains(button)
                let scale = buttonScales[button] ?? 1.0

                button.label
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(isPressed ? .white : theme.textPrimary)
                    .frame(width: layout.buttonRadius * 2, height: layout.buttonRadius * 2)
                    .position(center)
                    .scaleEffect(scale)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: scale)
            }
        }
        .allowsHitTesting(false) // Let touches pass through to gesture layer
    }

    // MARK: - Gesture Handler

    func handleTap(on button: LiquidButton) {
        // Animate button press
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            buttonScales[button] = 1.3
            pressedButtons.insert(button)
        }

        theme.mediumHaptic()

        // Ripple animation
        withAnimation(.easeOut(duration: 0.6)) {
            rippleAnimations[button] = 1.0
        }

        // Trigger action after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: DispatchWorkItem {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                buttonScales[button] = 1.0
                pressedButtons.remove(button)
            }

            // Execute button action
            switch button {
            case .one: onNumberPress(1)
            case .two: onNumberPress(2)
            case .three: onNumberPress(3)
            case .four: onNumberPress(4)
            case .five: onNumberPress(5)
            case .six: onNumberPress(6)
            case .seven: onNumberPress(7)
            case .eight: onNumberPress(8)
            case .nine: onNumberPress(9)
            case .zero: onNumberPress(0)
            case .delete: onDelete()
            case .done: onDone()
            }
        })
    }
}

// MARK: - Liquid Button Layout

struct LiquidKeypadLayout {
    let buttonRadius: CGFloat = 35
    let spacing: CGFloat = 12
    let padding: CGFloat = 20

    var totalHeight: CGFloat {
        let rows = 4
        return CGFloat(rows) * (buttonRadius * 2 + spacing) + padding * 2
    }

    func position(for button: LiquidButton, in size: CGSize) -> CGPoint {
        let row = button.row
        let col = button.column

        let x = padding + CGFloat(col) * (buttonRadius * 2 + spacing) + buttonRadius
        let y = padding + CGFloat(row) * (buttonRadius * 2 + spacing) + buttonRadius

        // Center horizontally in available space
        let totalWidth = CGFloat(3) * (buttonRadius * 2 + spacing)
        let xOffset = (size.width - totalWidth) / 2

        return CGPoint(x: x + xOffset, y: y)
    }
}

// MARK: - Liquid Button Enum

enum LiquidButton: CaseIterable {
    case one, two, three
    case four, five, six
    case seven, eight, nine
    case delete, zero, done

    var row: Int {
        switch self {
        case .one, .two, .three: return 0
        case .four, .five, .six: return 1
        case .seven, .eight, .nine: return 2
        case .delete, .zero, .done: return 3
        }
    }

    var column: Int {
        switch self {
        case .one, .four, .seven, .delete: return 0
        case .two, .five, .eight, .zero: return 1
        case .three, .six, .nine, .done: return 2
        }
    }

    @ViewBuilder
    var label: some View {
        switch self {
        case .one: Text("1")
        case .two: Text("2")
        case .three: Text("3")
        case .four: Text("4")
        case .five: Text("5")
        case .six: Text("6")
        case .seven: Text("7")
        case .eight: Text("8")
        case .nine: Text("9")
        case .zero: Text("0")
        case .delete:
            Image(systemName: "delete.left.fill")
                .font(.system(size: 20, weight: .semibold))
        case .done:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20, weight: .semibold))
        }
    }

    var numberValue: Int? {
        switch self {
        case .one: return 1
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 9
        case .zero: return 0
        case .delete, .done: return nil
        }
    }
}

// MARK: - Interactive Wrapper

struct InteractiveLiquidKeypad: View {
    @Environment(\.appTheme) private var theme

    let onNumberPress: (Int) -> Void
    let onDelete: () -> Void
    let onDone: () -> Void

    var body: some View {
        LiquidKeypadView(
            onNumberPress: onNumberPress,
            onDelete: onDelete,
            onDone: onDone
        )
        .overlay(
            // Gesture layer - invisible but captures taps
            GestureLayer(
                onNumberPress: onNumberPress,
                onDelete: onDelete,
                onDone: onDone
            )
        )
    }
}

// MARK: - Gesture Layer

struct GestureLayer: View {
    @Environment(\.appTheme) private var theme
    @State private var keypad: LiquidKeypadView?

    let onNumberPress: (Int) -> Void
    let onDelete: () -> Void
    let onDone: () -> Void

    let layout = LiquidKeypadLayout()

    var body: some View {
        GeometryReader { geometry in
            ForEach(LiquidButton.allCases, id: \.self) { button in
                let center = layout.position(for: button, in: geometry.size)

                Button(action: {}) {
                    // Actual tap handling via simultaneousGesture
                }
                .buttonStyle(LiquidButtonStyle(button: button))
                .position(center)
                .frame(width: layout.buttonRadius * 2, height: layout.buttonRadius * 2)
                .simultaneousGesture(
                    TapGesture()
                        .onEnded { _ in
                            theme.mediumHaptic()
                            onNumberPress(button.numberValue ?? 0)
                        }
                )
            }
        }
    }
}

struct LiquidButtonStyle: ButtonStyle {
    let button: LiquidButton

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Financial Organism - Liquid Keypad") {
    VStack(spacing: 30) {
        Text("💧 Financial Organism")
            .font(.title)
            .fontWeight(.bold)

        Text("Liquid Keypad - Phase 1")
            .font(.title2)
            .foregroundStyle(.secondary)

        InteractiveLiquidKeypad(
            onNumberPress: { num in
                print("Pressed: \(num)")
            },
            onDelete: {
                print("Delete")
            },
            onDone: {
                print("Done")
            }
        )

        Text("Tap multiple nearby buttons to see the gooey merge effect")
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding()
    }
    .background(
        LinearGradient(
            colors: [Color(red: 0.97, green: 0.95, blue: 0.92), Color.white],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
