//
//  MicroInteractionService.swift
//  VisualCents
//
//  微交互特效服务 - 提供"灵动感"反馈
//

import SwiftUI

/// 微交互特效服务
@Observable
final class MicroInteractionService {

    static let shared = MicroInteractionService()

    private init() {}

    // MARK: - 记账成功特效

    /// 记账成功时的庆祝特效
    func celebrateTransactionSaved() {
        #if canImport(Pow)
        // 使用 Pow 库的 confetti 特效
        Confetti.explosion()
        #else
        // 临时方案：使用原生动画
        nativeCelebration()
        #endif
    }

    // MARK: - 删除特效

    /// 删除账单时的消失特效
    func poofTransactionDeleted() {
        #if canImport(Pow)
        Poof()
        #else
        nativePoof()
        #endif
    }

    // MARK: - 警告特效

    /// 预算超支时的摇晃警告
    func warnBudgetExceeded() {
        #if canImport(Pow)
        Shake()
        #else
        nativeShake()
        #endif
    }

    /// 完成目标的庆祝
    func celebrateGoalAchieved() {
        #if canImport(Pow)
        Spray()
        #else
        nativeCelebration()
        #endif
    }

    // MARK: - 原生动画备选方案（未安装 Pow 库时使用）

    private func nativeCelebration() {
        // 简单的震动反馈
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func nativePoof() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private func nativeShake() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}

// MARK: - View Extensions for Easy Effects

extension View {

    /// 添加记账成功的庆祝效果
    func celebrateOnAppear(shouldCelebrate: Bool) -> some View {
        self.onAppear {
            if shouldCelebrate {
                MicroInteractionService.shared.celebrateTransactionSaved()
            }
        }
    }

    /// 添加预算警告的摇晃效果
    func warnIfOverBudget(isOver: Bool) -> some View {
        self.modifier(BudgetWarningModifier(isOverBudget: isOver))
    }
}

// MARK: - Custom Modifiers

/// 预算超支警告修饰符
private struct BudgetWarningModifier: ViewModifier {
    let isOverBudget: Bool

    @State private var isShaking = false

    func body(content: Content) -> some View {
        content
            .offset(x: isShaking ? -5 : 0)
            .animation(
                isOverBudget ? .easeInOut(duration: 0.05).repeatCount(6) : .default,
                value: isShaking
            )
            .onChange(of: isOverBudget) { _, newValue in
                if newValue {
                    MicroInteractionService.shared.warnBudgetExceeded()
                    withAnimation {
                        isShaking = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isShaking = false
                    }
                }
            }
    }
}

// MARK: - 快捷使用示例

/*
 使用示例：

 1. 记账成功后：
    .onAppear {
        MicroInteractionService.shared.celebrateTransactionSaved()
    }

 2. 删除账单时：
    Button("删除") {
        MicroInteractionService.shared.poofTransactionDeleted()
        // 删除逻辑...
    }

 3. 预算超支警告：
    BudgetCard()
        .warnIfOverBudget(isOver: budget.isOverLimit)

 4. 完成储蓄目标：
    .onAppear {
        MicroInteractionService.shared.celebrateGoalAchieved()
    }
*/
