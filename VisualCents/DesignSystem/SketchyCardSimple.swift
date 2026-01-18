//
//  SketchyCard.swift
//  VisualCents
//
//  手绘风格组件 - 达芬奇手稿质感
//

import SwiftUI

/// 手绘风格卡片容器（简化版）
struct SketchyCardView<Content: View>: View {
    @Environment(\.appTheme) private var theme

    let content: Content
    var cornerRadius: CGFloat = 12

    init(cornerRadius: CGFloat = 12, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        ZStack {
            // 卡片背景
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(theme.cardBackground)

            // 手绘风格的边框（使用虚线模拟）
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    Color.white.opacity(0.2),
                    style: StrokeStyle(
                        lineWidth: 1.5,
                        lineCap: .round,
                        dash: [8, 4]
                    )
                )

            // 第二层边框（略微偏移，模拟手绘重描）
            RoundedRectangle(cornerRadius: cornerRadius + 1)
                .stroke(
                    Color.white.opacity(0.1),
                    style: StrokeStyle(
                        lineWidth: 0.8,
                        lineCap: .round,
                        dash: [12, 6]
                    )
                )
                .offset(x: 0.5, y: 0.5)

            // 内容
            content
                .padding(20)
        }
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 2, y: 4)
    }
}

// MARK: - 使用示例

/*
 使用示例：

 SketchyCardView {
    VStack(alignment: .leading) {
        Text("手绘风格卡片")
            .font(.title2)
        Text("达芬奇手稿质感")
            .font(.body)
    }
}
*/
