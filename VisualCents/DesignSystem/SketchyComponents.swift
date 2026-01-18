//
//  SketchyComponents.swift
//  VisualCents
//
//  手绘风格组件库 - 达芬奇手稿质感
//

import SwiftUI

// MARK: - 手绘按钮样式

/// 手绘风格按钮
struct SketchyButton<Content: View>: View {
    @Environment(\.appTheme) private var theme

    let content: Content
    let action: () -> Void
    var cornerRadius: CGFloat = 12

    init(cornerRadius: CGFloat = 12, @ViewBuilder content: () -> Content, action: @escaping () -> Void) {
        self.cornerRadius = cornerRadius
        self.content = content()
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(theme.primaryAccent)

                // 手绘边框
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        Color.white.opacity(0.3),
                        style: StrokeStyle(
                            lineWidth: 1.5,
                            lineCap: .round,
                            dash: [6, 3]
                        )
                    )

                // 第二层边框
                RoundedRectangle(cornerRadius: cornerRadius + 1)
                    .stroke(
                        Color.white.opacity(0.15),
                        style: StrokeStyle(
                            lineWidth: 0.8,
                            lineCap: .round,
                            dash: [10, 5]
                        )
                    )
                    .offset(x: 0.5, y: 0.5)

                // 内容
                content
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

/// 次要手绘按钮（outline 样式）
struct SketchySecondaryButton<Content: View>: View {
    @Environment(\.appTheme) private var theme

    let content: Content
    let action: () -> Void
    var cornerRadius: CGFloat = 12

    init(cornerRadius: CGFloat = 12, @ViewBuilder content: () -> Content, action: @escaping () -> Void) {
        self.cornerRadius = cornerRadius
        self.content = content()
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                // 透明背景
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.clear)

                // 手绘边框
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        theme.textSecondary,
                        style: StrokeStyle(
                            lineWidth: 1.5,
                            lineCap: .round,
                            dash: [6, 3]
                        )
                    )

                // 第二层边框
                RoundedRectangle(cornerRadius: cornerRadius + 1)
                    .stroke(
                        theme.textSecondary.opacity(0.5),
                        style: StrokeStyle(
                            lineWidth: 0.8,
                            lineCap: .round,
                            dash: [10, 5]
                        )
                    )
                    .offset(x: 0.5, y: 0.5)

                // 内容
                content
                    .foregroundStyle(theme.textSecondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - 手绘输入框

/// 手绘风格输入框
struct SketchyTextField: View {
    @Environment(\.appTheme) private var theme

    @Binding var text: String
    var placeholder: String
    var icon: String? = nil
    var cornerRadius: CGFloat = 12

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundStyle(theme.textTertiary)
                    .font(.system(size: 16))
            }

            TextField(placeholder, text: $text)
                .font(theme.customFont(size: 16, weight: .regular))
                .foregroundStyle(theme.textPrimary)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(theme.cardBackgroundElevated)

                // 手绘边框
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        theme.textTertiary.opacity(0.3),
                        style: StrokeStyle(
                            lineWidth: 1.2,
                            lineCap: .round,
                            dash: [4, 2]
                        )
                    )
            }
        )
    }
}

// MARK: - 手绘标签

/// 手绘风格标签（用于类别、状态等）
struct SketchyBadge: View {
    @Environment(\.appTheme) private var theme

    let text: String
    let color: Color
    var cornerRadius: CGFloat = 8

    var body: some View {
        Text(text)
            .font(theme.customFont(size: 12, weight: .medium))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                ZStack {
                    // 半透明背景
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(color.opacity(0.15))

                    // 手绘边框
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            color.opacity(0.4),
                            style: StrokeStyle(
                                lineWidth: 1,
                                lineCap: .round,
                                dash: [3, 2]
                            )
                        )
                }
            )
    }
}

// MARK: - 按钮样式

/// 缩放按钮样式（用于手绘按钮）
private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - 使用示例

/*
 使用示例：

 1. 手绘分割线：
    SketchyDivider()

 2. 主要手绘按钮：
    SketchyButton {
        Text("保存交易")
    } action: {
        // 处理点击
    }

 3. 次要手绘按钮：
    SketchySecondaryButton {
        Text("取消")
    } action: {
        // 处理点击
    }

 4. 手绘输入框：
    SketchyTextField(
        text: $amount,
        placeholder: "输入金额",
        icon: "dollarsign.circle"
    )

 5. 手绘标签：
    SketchyBadge(
        text: "餐饮",
        color: .blue
    )

 6. 手绘卡片：
    SketchyCardView {
        VStack(alignment: .leading) {
            Text("手绘风格卡片")
                .font(.title2)
            Text("达芬奇手稿质感")
                .font(.body)
        }
    }
*/
