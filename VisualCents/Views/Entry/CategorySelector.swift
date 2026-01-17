//
//  CategorySelector.swift
//  VisualCents
//
//  Horizontal scrolling category selector with bouncy animations
//

import SwiftUI
import SwiftData

/// Horizontal category selector with bouncy bubble animations
struct CategorySelector: View {
    @Binding var selectedCategory: Category?
    let categories: [Category]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择分类")
                .font(VCFont.caption())
                .foregroundStyle(VCColors.textSecondary)
                .padding(.horizontal, VCMetrics.padding)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(categories) { category in
                        CategoryBubbleView(
                            category: category,
                            isSelected: selectedCategory?.id == category.id
                        ) {
                            VCHaptics.selection()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding(.horizontal, VCMetrics.padding)
            }
        }
    }
}

// MARK: - Category Bubble View

struct CategoryBubbleView: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    private var color: Color {
        Color(hex: category.colorHex)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    // Background circle
                    Circle()
                        .fill(isSelected ? color : color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    // Selection ring
                    if isSelected {
                        Circle()
                            .stroke(color, lineWidth: 3)
                            .frame(width: 66, height: 66)
                    }
                    
                    // Icon
                    Image(systemName: category.iconName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : color)
                }
                
                // Label
                Text(category.name)
                    .font(VCFont.caption(11))
                    .foregroundStyle(isSelected ? VCColors.textPrimary : VCColors.textSecondary)
                    .lineLimit(1)
                    .frame(width: 60)
            }
        }
        .buttonStyle(BounceButtonStyle(pressedScale: 0.9, hapticStyle: .light))
    }
}

// MARK: - Preview

#Preview {
    VStack {
        CategorySelector(
            selectedCategory: .constant(nil),
            categories: Category.defaultCategories()
        )
    }
    .padding(.vertical, 20)
    .background(VCColors.backgroundPrimary)
    .preferredColorScheme(.dark)
}
