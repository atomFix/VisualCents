//
//  GooeyKeypad.swift
//  VisualCents
//
//  液体粘性数字键盘 - Metaball 效果
//  按钮之间会像液体一样融合
//

import SwiftUI

/// 液体粘性数字键盘
struct GooeyKeypad: View {
    @Environment(\.appTheme) private var theme

    let onNumberPress: (Int) -> Void
    let onDelete: () -> Void
    let onClear: () -> Void

    @State private var pressedButtons: Set<Int> = []
    @State private var buttonPositions: [Int: CGPoint] = [:]

    private let buttons: [[GooeyButton]] = [
        [.number(1), .number(2), .number(3)],
        [.number(4), .number(5), .number(6)],
        [.number(7), .number(8), .number(9)],
        [.clear, .number(0), .delete]
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 粘性效果层
                Canvas { context, size in
                    // 绘制所有按钮为圆形（用于 metaball 效果）
                    for button in buttons.flatMap({ $0 }) {
                        if let index = button.id,
                           pressedButtons.contains(index) || buttonPositions[index] != nil {
                            let pos = buttonPositions[index] ?? .zero
                            let basePos = calculateButtonPosition(index, in: size)

                            // 绘制大圆（按下时）
                            if pressedButtons.contains(index) {
                                context.fill(
                                    Path(ellipseIn: CGRect(
                                        x: basePos.x - 45,
                                        y: basePos.y - 45,
                                        width: 90,
                                        height: 90
                                    )),
                                    with: .color(theme.primaryAccent.opacity(0.6))
                                )
                            }

                            // 绘制小圆（正常状态）
                            context.fill(
                                Path(ellipseIn: CGRect(
                                    x: basePos.x - 35,
                                    y: basePos.y - 35,
                                    width: 70,
                                    height: 70
                                )),
                                with: .color(theme.primaryAccent.opacity(0.4))
                            )
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)

                // 高斯模糊层 - 创建粘性效果
                Canvas { context, size in
                    for button in buttons.flatMap({ $0 }) {
                        if let index = button.id,
                           pressedButtons.contains(index) || buttonPositions[index] != nil {
                            let basePos = calculateButtonPosition(index, in: size)

                            if pressedButtons.contains(index) {
                                context.fill(
                                    Path(ellipseIn: CGRect(
                                        x: basePos.x - 45,
                                        y: basePos.y - 45,
                                        width: 90,
                                        height: 90
                                    )),
                                    with: .color(theme.primaryAccent)
                                )
                            }
                        }
                    }
                }
                .blur(radius: 20)
                .frame(width: geometry.size.width, height: geometry.size.height)

                // 阈值层 - 锐化边缘
                Canvas { context, size in
                    for button in buttons.flatMap({ $0 }) {
                        if let index = button.id {
                            let basePos = calculateButtonPosition(index, in: size)

                            if pressedButtons.contains(index) {
                                context.fill(
                                    Path(ellipseIn: CGRect(
                                        x: basePos.x - 40,
                                        y: basePos.y - 40,
                                        width: 80,
                                        height: 80
                                    )),
                                    with: .color(theme.primaryAccent)
                                )
                            }
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)

                // 按钮层 - 显示数字和图标
                VStack(spacing: 16) {
                    ForEach(0..<buttons.count, id: \.self) { row in
                        HStack(spacing: 16) {
                            ForEach(0..<buttons[row].count, id: \.self) { col in
                                let button = buttons[row][col]
                                GooeyButtonView(
                                    button: button,
                                    isPressed: pressedButtons.contains(button.id ?? -1)
                                ) {
                                    handleButtonPress(button)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .frame(height: 400)
    }

    private func calculateButtonPosition(_ index: Int, in size: CGSize) -> CGPoint {
        let spacing: CGFloat = 16
        let buttonSize: CGFloat = 70
        let padding: CGFloat = 20

        let row = index / 3
        let col = index % 3

        let x = padding + CGFloat(col) * (buttonSize + spacing) + buttonSize / 2
        let y = padding + CGFloat(row) * (buttonSize + spacing) + buttonSize / 2

        return CGPoint(x: x, y: y)
    }

    private func handleButtonPress(_ button: GooeyButton) {
        guard let index = button.id else { return }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            pressedButtons.insert(index)
        }

        theme.mediumHaptic()

        // 延迟移除按压状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                _ = pressedButtons.remove(index)
            }
        }

        switch button {
        case .number(let num):
            onNumberPress(num)
        case .delete:
            onDelete()
        case .clear:
            onClear()
        }
    }
}

/// 粘性按钮视图
struct GooeyButtonView: View {
    @Environment(\.appTheme) private var theme

    let button: GooeyButton
    let isPressed: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if button.isSpecial {
                    // 特殊按钮（删除、清除）
                    Image(systemName: button.iconName ?? "")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isPressed ? .white : theme.textSecondary)
                        .frame(width: 70, height: 70)
                        .background(
                            Circle()
                                .fill(isPressed ? theme.expenseRed : Color.clear.opacity(0.5))
                        )
                } else {
                    // 数字按钮
                    Text("\(button.number ?? 0)")
                        .font(theme.customFont(size: 28, weight: .semibold))
                        .foregroundStyle(isPressed ? .white : theme.textPrimary)
                        .frame(width: 70, height: 70)
                }
            }
        }
        .buttonStyle(SpringButtonStyle())
    }
}

/// 弹簧按钮样式
struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// 粘性按钮类型
enum GooeyButton {
    case number(Int)
    case delete
    case clear

    var id: Int? {
        switch self {
        case .number(let num):
            return num
        case .delete:
            return 11
        case .clear:
            return 10
        }
    }

    var number: Int? {
        if case .number(let num) = self {
            return num
        }
        return nil
    }

    var isSpecial: Bool {
        if case .number = self {
            return false
        }
        return true
    }

    var iconName: String? {
        switch self {
        case .delete:
            return "delete.left"
        case .clear:
            return "xmark.circle.fill"
        default:
            return nil
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        Text("液体粘性键盘")
            .font(.title)
            .padding()

        GooeyKeypad(
            onNumberPress: { num in
                print("Pressed: \(num)")
            },
            onDelete: {
                print("Delete")
            },
            onClear: {
                print("Clear")
            }
        )
    }
    .background(Color(red: 0.97, green: 0.95, blue: 0.92))
    .environment(\.appTheme, CharcoalTheme())
}
