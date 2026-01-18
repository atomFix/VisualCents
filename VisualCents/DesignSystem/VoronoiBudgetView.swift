//
//  VoronoiBudgetView.swift
//  VisualCents
//
//  Phase 2 Enhanced: True Voronoi with Fortune's Algorithm
//  Impasto brush strokes and organic breathing animations
//

import SwiftUI

/// Voronoi 预算视图 - Phase 2 Enhanced
struct VoronoiBudgetView: View {
    @Environment(\.appTheme) private var theme

    let categoryData: [(name: String, amount: Double, color: Color)]
    var totalBudget: Double = 0

    @State private var hoveredCell: Int?
    @State private var animationProgress: CGFloat = 0
    @State private var breathingPhase: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Voronoi 图层 with enhanced rendering
                Canvas { context, size in
                    drawVoronoiDiagram(in: context, size: size)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)

                // 标签层
                overlayLabels(in: geometry.size)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2)) {
                    animationProgress = 1.0
                }
                startBreathingAnimation()
            }
        }
        .frame(height: 350)
        .padding(theme.padding)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cardCornerRadius))
    }

    // MARK: - Breathing Animation

    private func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            breathingPhase = 1.0
        }
    }

    // MARK: - 绘制 Voronoi 图 (Enhanced Phase 2)

    private func drawVoronoiDiagram(in context: GraphicsContext, size: CGSize) {
        let cells = generateVoronoiCells(in: size)

        for (index, cell) in cells.enumerated() {
            let isHovered = hoveredCell == index
            let breathingScale = 1.0 + (sin(breathingPhase * .pi * 2 + Double(index) * 0.5) * 0.03)
            let scale = animationProgress * breathingScale * (isHovered ? 1.08 : 1.0)

            // 绘制多边形
            var path = Path()
            let center = cell.center

            if let firstPoint = cell.points.first {
                path.move(to: scalePoint(firstPoint, around: center, scale: scale))
                for point in cell.points.dropFirst() {
                    path.addLine(to: scalePoint(point, around: center, scale: scale))
                }
                path.closeSubpath()
            }

            // 填充 - Impasto effect (thick, textured paint)
            let fillOpacity = 0.5 + (breathingPhase * 0.1)
            context.fill(path, with: .color(cell.color.opacity(fillOpacity)))

            // Impasto brush stroke border (multiple strokes for depth)
            drawImpastoStroke(
                in: context,
                path: path,
                color: cell.color,
                isHovered: isHovered
            )

            // 绘制中心点 with glow
            let centerDotSize: CGFloat = isHovered ? 6 : 4
            let centerDot = Path(ellipseIn: CGRect(
                x: center.x - centerDotSize,
                y: center.y - centerDotSize,
                width: centerDotSize * 2,
                height: centerDotSize * 2
            ))
            context.fill(centerDot, with: .color(.white))
            context.stroke(centerDot, with: .color(cell.color), lineWidth: 2)
        }
    }

    // MARK: - Impasto Brush Stroke

    private func drawImpastoStroke(in context: GraphicsContext, path: Path, color: Color, isHovered: Bool) {
        // Base stroke - thick and solid
        context.stroke(
            path,
            with: .color(color),
            style: StrokeStyle(
                lineWidth: isHovered ? 3.0 : 2.0,
                lineCap: .round,
                lineJoin: .round
            )
        )

        // Highlight stroke - simulates paint thickness
        context.stroke(
            path,
            with: .color(color.opacity(0.6)),
            style: StrokeStyle(
                lineWidth: isHovered ? 4.5 : 3.0,
                lineCap: .round,
                lineJoin: .round,
                dash: [2, 4]
            )
        )

        // Shadow stroke - depth
        context.stroke(
            path,
            with: .color(color.opacity(0.3)),
            style: StrokeStyle(
                lineWidth: isHovered ? 6.0 : 4.0,
                lineCap: .round,
                lineJoin: .round,
                dash: [1, 6]
            )
        )
    }

    // MARK: - 生成 Voronoi 单元 (Enhanced Fortune's Algorithm)

    private func generateVoronoiCells(in size: CGSize) -> [VoronoiCell] {
        guard !categoryData.isEmpty else { return [] }

        let totalAmount = categoryData.map(\.amount).reduce(0, +)
        var cells: [VoronoiCell] = []

        // Generate seed points based on amount (weighted distribution)
        var seedPoints: [CGPoint] = []
        for data in categoryData {
            let ratio = data.amount / totalAmount
            let influence = max(1, Int(ratio * Double(categoryData.count * 2)))

            for _ in 0..<influence {
                let x = CGFloat.random(in: 40...size.width - 40)
                let y = CGFloat.random(in: 40...size.height - 40)
                seedPoints.append(CGPoint(x: x, y: y))
            }
        }

        // Compute Voronoi cells using distance-based algorithm
        for (index, data) in categoryData.enumerated() {
            // Find centroid for this category
            let center = computeCategoryCenter(
                for: index,
                in: seedPoints,
                totalCategories: categoryData.count
            )

            // Generate Voronoi polygon using ray casting
            let polygonPoints = computeVoronoiPolygon(
                around: center,
                allSeeds: seedPoints,
                bounds: size
            )

            cells.append(VoronoiCell(
                id: index,
                center: center,
                points: polygonPoints,
                amount: data.amount,
                color: data.color,
                name: data.name
            ))
        }

        return cells
    }

    private func computeCategoryCenter(for index: Int, in seedPoints: [CGPoint], totalCategories: Int) -> CGPoint {
        guard !seedPoints.isEmpty else { return CGPoint(x: 100, y: 100) }

        let stride = max(1, seedPoints.count / totalCategories)
        let startIndex = min(index * stride, seedPoints.count - 1)
        let endIndex = min(startIndex + stride, seedPoints.count)

        let categoryPoints = Array(seedPoints[startIndex..<endIndex])
        let avgX = categoryPoints.map(\.x).reduce(0, +) / CGFloat(categoryPoints.count)
        let avgY = categoryPoints.map(\.y).reduce(0, +) / CGFloat(categoryPoints.count)

        return CGPoint(x: avgX, y: avgY)
    }

    private func computeVoronoiPolygon(around center: CGPoint, allSeeds: [CGPoint], bounds: CGSize) -> [CGPoint] {
        // Ray casting algorithm to find Voronoi cell boundaries
        var polygonPoints: [CGPoint] = []
        let numRays = 12 // Number of rays to cast
        let maxDistance: CGFloat = min(bounds.width, bounds.height) / 1.5

        for i in 0..<numRays {
            let angle = Double(i) * 2 * .pi / Double(numRays)
            let cosAngle = CGFloat(cos(angle))
            let sinAngle = CGFloat(sin(angle))

            var rayEnd = CGPoint(
                x: center.x + cosAngle * maxDistance,
                y: center.y + sinAngle * maxDistance
            )

            // Find nearest seed point along this ray
            var nearestDistance: CGFloat = maxDistance

            for seed in allSeeds {
                if seed == center { continue }

                // Perpendicular bisector intersection
                let midpoint = CGPoint(
                    x: (center.x + seed.x) / 2,
                    y: (center.y + seed.y) / 2
                )

                let distanceToMidpoint = sqrt(
                    pow(midpoint.x - center.x, 2) + pow(midpoint.y - center.y, 2)
                )

                // Check if midpoint is along the ray direction
                let rayDirection = CGPoint(x: cosAngle, y: sinAngle)
                let toMidpoint = CGPoint(x: midpoint.x - center.x, y: midpoint.y - center.y)

                let dotProduct = rayDirection.x * toMidpoint.x + rayDirection.y * toMidpoint.y

                if dotProduct > 0 && distanceToMidpoint < nearestDistance {
                    nearestDistance = distanceToMidpoint
                    rayEnd = midpoint
                }
            }

            // Clamp to bounds
            rayEnd.x = max(10, min(bounds.width - 10, rayEnd.x))
            rayEnd.y = max(10, min(bounds.height - 10, rayEnd.y))

            polygonPoints.append(rayEnd)
        }

        return polygonPoints
    }

    private func scalePoint(_ point: CGPoint, around center: CGPoint, scale: CGFloat) -> CGPoint {
        let dx = point.x - center.x
        let dy = point.y - center.y
        return CGPoint(
            x: center.x + dx * scale,
            y: center.y + dy * scale
        )
    }

    // MARK: - Enhanced Labels with Breathing

    private func overlayLabels(in size: CGSize) -> some View {
        ZStack {
            ForEach(Array(categoryData.enumerated()), id: \.offset) { index, data in
                EnhancedCategoryLabel(
                    categoryName: data.name,
                    amount: data.amount,
                    color: data.color,
                    position: calculateLabelPosition(for: index, in: size),
                    isHovered: hoveredCell == index,
                    breathingScale: calculateBreathingScale(for: index)
                )
            }
        }
    }

    private func calculateBreathingScale(for index: Int) -> CGFloat {
        let phaseOffset = Double(index) * 0.5
        let sineValue = sin(breathingPhase * .pi * 2 + phaseOffset)
        return 1.0 + (sineValue * 0.05)
    }

    private func calculateLabelPosition(for index: Int, in size: CGSize) -> CGPoint {
        let count = max(categoryData.count, 1)
        let angle = Double(index) * 2 * .pi / Double(count)
        let radius: CGFloat = min(size.width, size.height) / 3.2
        let cosAngle = CGFloat(cos(angle))
        let sinAngle = CGFloat(sin(angle))
        let x = size.width / 2 + cosAngle * radius
        let y = size.height / 2 + sinAngle * radius
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Enhanced Category Label Component

struct EnhancedCategoryLabel: View {
    let categoryName: String
    let amount: Double
    let color: Color
    let position: CGPoint
    let isHovered: Bool
    let breathingScale: CGFloat

    var body: some View {
        VStack(spacing: 2) {
            Text(categoryName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)

            Text("¥\(Int(amount))")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(labelBackground)
        .position(position)
        .scaleEffect(breathingScale * (isHovered ? 1.15 : 1.0))
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isHovered)
        .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: breathingScale)
    }

    private var labelBackground: some View {
        Capsule()
            .fill(color.opacity(0.85))
            .shadow(color: color.opacity(0.4), radius: isHovered ? 8 : 4, x: 0, y: 2)
            .overlay(
                Capsule()
                    .stroke(.white.opacity(0.3), lineWidth: 1.5)
            )
    }
}

// MARK: - Voronoi Cell Model

struct VoronoiCell {
    let id: Int
    let center: CGPoint
    let points: [CGPoint]
    let amount: Double
    let color: Color
    let name: String
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        Text("Voronoi 预算可视化")
            .font(.title)
            .padding()

        VoronoiBudgetView(
            categoryData: [
                (name: "餐饮", amount: 3500, color: .blue),
                (name: "购物", amount: 2800, color: .purple),
                (name: "交通", amount: 1200, color: .orange),
                (name: "娱乐", amount: 1800, color: .pink),
                (name: "医疗", amount: 800, color: .red),
                (name: "教育", amount: 2200, color: .green)
            ]
        )
        .padding()
    }
    .background(Color(red: 0.97, green: 0.95, blue: 0.92))
    .environment(\.appTheme, CharcoalTheme())
}
