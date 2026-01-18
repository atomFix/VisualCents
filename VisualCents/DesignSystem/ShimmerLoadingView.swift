//
//  ShimmerLoadingView.swift
//  VisualCents
//
//  骨架屏加载动画 - 用于 OCR 分析时的优雅占位
//

import SwiftUI

/// 骨架屏加载视图
struct ShimmerLoadingView: View {
    @Environment(\.appTheme) private var theme

    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat

    init(width: CGFloat, height: CGFloat, cornerRadius: CGFloat = 8) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(theme.cardBackground)

            // 扫光效果
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .onAppear {
                    // 启动动画
                }
        }
        .frame(width: width, height: height)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .shimmering()
    }
}

/// 扫光动画修饰符
private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width)
                    .offset(x: geometry.size.width * (phase - 1.5))
                }
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 2
                }
            }
    }
}

extension View {
    /// 添加扫光动画
    func shimmering() -> some View {
        self.modifier(ShimmerModifier())
    }
}

// MARK: - 预设的骨架屏组件

extension ShimmerLoadingView {
    /// 卡片骨架屏
    static func card() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ShimmerLoadingView(width: 60, height: 20)
            ShimmerLoadingView(width: .infinity, height: 16)
            ShimmerLoadingView(width: .infinity, height: 16, cornerRadius: 4)
            ShimmerLoadingView(width: 120, height: 16, cornerRadius: 4)
        }
        .padding()
        .background(Color.clear)
    }

    /// 列表项骨架屏
    static func listItem() -> some View {
        HStack(spacing: 12) {
            ShimmerLoadingView(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 8) {
                ShimmerLoadingView(width: 120, height: 16)
                ShimmerLoadingView(width: 80, height: 14, cornerRadius: 4)
            }
        }
        .padding(.horizontal)
    }

    /// 数值骨架屏
    static func amount() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ShimmerLoadingView(width: 100, height: 14, cornerRadius: 4)
            ShimmerLoadingView(width: 150, height: 32, cornerRadius: 8)
        }
    }
}

// MARK: - 使用示例

/*
 使用示例：

 1. 基础使用：
    ShimmerLoadingView(width: 200, height: 100)

 2. 预设卡片：
    ShimmerLoadingView.card()

 3. 预设列表项：
    ShimmerLoadingView.listItem()

 4. 预设金额：
    ShimmerLoadingView.amount()

 5. 在 OCR 分析时显示：
    if isAnalyzing {
        VStack {
            ShimmerLoadingView.card()
            ShimmerLoadingView.card()
            ShimmerLoadingView.card()
        }
    } else {
        // 实际内容
    }
*/
