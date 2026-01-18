# VisualCents 依赖库集成指南

本文档说明如何添加推荐的第三方库来增强 VisualCents 的用户体验。

## 📦 需要添加的 Swift Package

### 1. Pow - 微交互特效（优先级最高）

**GitHub:** [https://github.com/EmergeTools/Pow](https://github.com/EmergeTools/Pow)

**添加步骤：**
1. 在 Xcode 中打开项目
2. File → Add Package Dependencies...
3. 粘贴 URL: `https://github.com/EmergeTools/Pow`
4. 点击 "Add Package"

**提供的效果：**
- `Confetti` - 撒花特效（记账成功）
- `Poof` - 烟雾消失（删除账单）
- `Shake` - 摇晃警告（预算超支）
- `Spray` - 彩带喷射（完成目标）

---

### 2. Shimmer - 骨架屏加载动画

**GitHub:** [https://github.com/markiv/SwiftUI-Shimmer](https://github.com/markiv/SwiftUI-Shimmer)

**添加步骤：**
1. File → Add Package Dependencies...
2. 粘贴 URL: `https://github.com/markiv/SwiftUI-Shimmer`
3. 选择 "Shimmer" 版本（至少 1.0.0）
4. 点击 "Add Package"

**用途：** OCR 分析小票时的优雅加载占位

---

### 3. NumberTicker - 数字滚动动画

**GitHub:** [https://github.com/uacaps/NumberTicker](https://github.com/uacaps/NumberTicker)

**添加步骤：**
1. File → Add Package Dependencies...
2. 粘贴 URL: `https://github.com/uacaps/NumberTicker`
3. 点击 "Add Package"

**用途：** 资产金额变化的滚动效果

---

## 🎯 集成优先级

1. **第一阶段（必选）：**
   - ✅ Pow - 核心微交互
   - ✅ Shimmer - OCR 体验优化

2. **第二阶段（推荐）：**
   - NumberTicker - 数字动画
   - Swift Charts - 图表增强（iOS 16+ 内置）

---

## 📝 注意事项

- 所有库都支持 Swift Package Manager，无需 CocoaPods
- 添加后需要 `import` 对应的模块才能使用
- 如果暂时不想添加，代码中已有原生备选方案
- 建议一次只添加一个库，测试无误后再添加下一个

---

## 🚀 快速开始

添加完 Pow 库后，重新编译项目即可自动启用特效。使用示例见 `MicroInteractionService.swift`。
