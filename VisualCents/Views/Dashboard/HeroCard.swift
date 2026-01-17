//
//  HeroCard.swift
//  VisualCents
//
//  Large hero card showing monthly budget with animated progress ring
//

import SwiftUI

/// Hero card displaying monthly budget status with animated circular progress
struct HeroCard: View {
    @Environment(\.appTheme) private var theme
    
    /// Current spent amount
    var spent: Decimal
    
    /// Total budget limit
    var budget: Decimal
    
    /// Animation trigger
    @State private var animateProgress = false
    
    /// Current animated progress value
    @State private var displayedProgress: Double = 0
    
    // MARK: - Computed Properties
    
    private var remaining: Decimal {
        max(budget - spent, 0)
    }
    
    private var progress: Double {
        guard budget > 0 else { return 0 }
        return min(NSDecimalNumber(decimal: spent / budget).doubleValue, 1.0)
    }
    
    private var progressColor: Color {
        if progress >= 1.0 {
            return theme.expenseRed
        } else if progress >= 0.8 {
            return theme.warningYellow
        } else {
            return theme.incomeGreen
        }
    }
    
    private var statusText: String {
        if progress >= 1.0 {
            return "Budget Exceeded!"
        } else if progress >= 0.8 {
            return "Almost there..."
        } else {
            return "Monthly Budget Left"
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: theme.paddingLarge) {
            // Progress Ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(
                        theme.cardBackgroundElevated,
                        lineWidth: 12
                    )
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: displayedProgress)
                    .stroke(
                        progressColor,
                        style: StrokeStyle(
                            lineWidth: 12,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: progressColor.opacity(0.3), radius: 8)
                
                // Percentage text
                VStack(spacing: 2) {
                    Text("\(Int(displayedProgress * 100))")
                        .font(theme.customFont(size: 28, weight: .bold))
                        .foregroundStyle(theme.textPrimary)
                    Text("%")
                        .font(theme.customFont(size: 11, weight: .medium))
                        .foregroundStyle(theme.textSecondary)
                }
            }
            .frame(width: 100, height: 100)
            
            // Budget Info
            VStack(alignment: .leading, spacing: 8) {
                Text(statusText)
                    .font(theme.customFont(size: 12, weight: .medium))
                    .foregroundStyle(theme.textSecondary)
                
                // Remaining amount with counting animation
                Text(formatCurrency(remaining))
                    .font(theme.heroFont(size: 36))
                    .foregroundStyle(progressColor)
                    .contentTransition(.numericText())
                
                Text("of \(formatCurrency(budget))")
                    .font(theme.customFont(size: 15, weight: .regular))
                    .foregroundStyle(theme.textTertiary)
            }
            
            Spacer()
        }
        .padding(theme.paddingLarge)
        .background(
            theme.styleCard(EmptyView())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                displayedProgress = progress
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                displayedProgress = newValue
            }
        }
    }
    
    // MARK: - Helpers
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "¥0"
    }
}

// MARK: - Preview

#Preview("Under Budget") {
    HeroCard(spent: 2500, budget: 5000)
        .padding()
        .background(VCColors.backgroundPrimary)
}

#Preview("Near Limit") {
    HeroCard(spent: 4200, budget: 5000)
        .padding()
        .background(VCColors.backgroundPrimary)
}

#Preview("Over Budget") {
    HeroCard(spent: 5500, budget: 5000)
        .padding()
        .background(VCColors.backgroundPrimary)
}
