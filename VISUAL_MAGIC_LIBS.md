# VisualCents 视觉魔法库集成指南

本文档说明如何集成推荐的高级视觉特效库，打造独特的 UI 体验。

---

## 📦 推荐库总览

| 库名 | 用途 | 优先级 | GitHub |
|------|------|--------|--------|
| **RoughSwift** | 手绘草图风格 | 🔥 必选 | [链接](https://github.com/bakhtiyor1996/RoughSwift) |
| **Pow** | 微交互特效 | 🔥 必选 | [链接](https://github.com/EmergeTools/Pow) |
| **Vortex** | 粒子系统 | ⭐ 推荐 | [链接](https://github.com/scottecgrove/Vortex) |
| **MijickCalendarView** | 自定义日历 | ⭐ 推荐 | [链接](https://github.com/Mijick/Calendar) |

---

## 🎨 1. RoughSwift - 手绘草图风格

**效果：** 将标准图形渲染成"手绘乱涂"的达芬奇手稿质感

**VisualCents 应用场景：**
- ✅ CharcoalTheme 的卡片边框
- ✅ 分割线变成手绘线条
- ✅ 图表边框的草图风格
- ✅ 按钮边框的手绘效果

**添加步骤：**
1. File → Add Package Dependencies...
2. 粘贴：`https://github.com/bakhtiyor1996/RoughSwift`
3. 选择版本并添加

**基础用法：**
```swift
import RoughSwift

// 手绘矩形
RoughRectangle(cornerRadius: 8)
    .stroke(Color.black, lineWidth: 2)
    .fill(Color.white.opacity(0.8))

// 手绘圆形
RoughCircle()
    .stroke(Color.black, lineWidth: 2)

// 手绘线条
RoughLine()
    .stroke(Color.black, lineWidth: 1.5)
```

---

## ✨ 2. Pow - 微交互特效

**效果：** 极其丝滑的转场与粒子特效

**VisualCents 应用场景：**
- 🎊 记账成功：`.confetti` 撒花 / `.spray` 彩带
- 💨 删除账单：`.poof` 烟雾消失（解压！）
- 📳 预算超支：`.shake` 摇晃警告
- 🎉 完成目标：`.fireworks` 烟花

**添加步骤：**
1. File → Add Package Dependencies...
2. 粘贴：`https://github.com/EmergeTools/Pow`
3. 选择版本并添加

**基础用法：**
```swift
import Pow

// 撒花特效
Confetti.explosion()

// 烟雾消失
.poof()

// 摇晃警告
.shake()

// 烟花
.fireworks()
```

---

## 🌌 3. Vortex - 粒子系统

**效果：** 高性能粒子系统，创建流动的背景

**VisualCents 应用场景：**
- 🎨 油画主题：流动的"光斑"粒子背景
- ✨ 存钱目标达成：金币雨/烟花
- 💫 主页动态背景：浮尘粒子

**添加步骤：**
1. File → Add Package Dependencies...
2. 粘贴：`https://github.com/scottecgrove/Vortex`
3. 选择版本并添加

**基础用法：**
```swift
import Vortex

// 粒子背景
VortexView {
    CircleParticle()
        .color(.random)
        .speed(0.5)
        .radius(10)
}

// 金币雨
VortexView {
    ImageParticle(systemName: "dollarsign.circle.fill")
        .speed(2)
        .life(3)
}
```

---

## 📅 4. MijickCalendarView - 自定义日历

**效果：** 极度可定制的日历组件

**VisualCents 应用场景：**
- 📆 首页日期选择器
- 🎨 按主题自定义每一天的样式
- ✨ 标记有交易的日期

**添加步骤：**
1. File → Add Package Dependencies...
2. 粘贴：`https://github.com/Mijick/Calendar`
3. 选择版本并添加

**基础用法：**
```swift
import MijickCalendar

MijickCalendar(
    config: CalendarConfig(
        monthHeight: 300,
        dayAspectRatio: 1.2,
        maximumDayHeight: 45
    ),
    selections: $selections
)
```

---

## 🚀 快速开始

### 步骤 1：添加所有依赖

在 Xcode 中依次添加上述 4 个库。

### 步骤 2：创建视觉特效服务

创建 `VisualEffectsService.swift` 来管理所有特效。

### 步骤 3：应用特效到现有视图

按照应用场景逐步应用特效。

---

## 📝 集成顺序

### 第一阶段（必选）
1. ✅ **Pow** - 基础微交互（已准备）
2. ✅ **RoughSwift** - 手绘风格核心

### 第二阶段（推荐）
3. **Vortex** - 粒子背景
4. **MijickCalendarView** - 自定义日历

---

## ⚠️ 注意事项

1. **性能考虑**：粒子特效不要过度使用
2. **用户体验**：动效要服务于功能，不喧宾夺主
3. **主题适配**：确保所有动效都适配当前主题

---

## 🎯 预期效果

集成完成后，VisualCents 将拥有：

- ✨ **手绘风格**的卡片和边框（CharcoalTheme）
- 🎊 **丰富微交互**（撒花、烟雾、摇晃）
- 🌌 **动态粒子背景**（油画主题）
- 📅 **自定义日历**（完全匹配主题风格）

**打造独特的视觉体验，让用户爱上记账！** 💜
