//
//  FinancialOrganismView.swift
//  VisualCents
//
//  The "Financial Organism" - Interactive Art Finance App
//  A living, breathing finance visualization
//

import SwiftUI

/// Financial Organism - The Complete Experience
struct FinancialOrganismView: View {
    @Environment(\.appTheme) private var theme

    @State private var inputAmount: String = ""
    @State private var showDetail = false

    var body: some View {
        ZStack {
            // Fluid Background - The "Living" Canvas
            FluidBackgroundView(flowSpeed: 1.5, intensity: 0.5)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 40) {
                    // Header - Manifesto
                    manifestoHeader

                    // Phase 1: Liquid Keypad
                    liquidKeypadSection

                    // Phase 2 Preview: Voronoi Budget
                    voronoiPreview

                    // Phase 3 Preview: 3D Assets
                    asset3DPreview

                    // Footer
                    footer

                    Spacer()
                        .frame(height: 40)
                }
                .padding(20)
            }
        }
        .navigationTitle("💧 Financial Organism")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Manifesto Header

    private var manifestoHeader: some View {
        VStack(spacing: 16) {
            Text("💧 Financial Organism")
                .font(theme.customFont(size: 32, weight: .bold))
                .foregroundStyle(theme.textPrimary)

            Text("A Living Finance Experience")
                .font(theme.customFont(size: 18, weight: .medium))
                .foregroundStyle(theme.textSecondary)

            Text("Data is alive. Money flows like liquid. Your finances are an organic ecosystem.")
                .font(theme.customFont(size: 14, weight: .regular))
                .foregroundStyle(theme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(theme.cardBackground.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(theme.textTertiary.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [8, 4]))
                )
        )
    }

    // MARK: - Liquid Keypad Section

    private var liquidKeypadSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Phase 1")
                        .font(theme.customFont(size: 14, weight: .semibold))
                        .foregroundStyle(theme.primaryAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(theme.primaryAccent.opacity(0.15))
                        )

                    Text("Liquid Keypad")
                        .font(theme.customFont(size: 24, weight: .bold))
                        .foregroundStyle(theme.textPrimary)
                }

                Text("Metaball Physics - Buttons merge like liquid droplets")
                    .font(theme.customFont(size: 14, weight: .regular))
                    .foregroundStyle(theme.textTertiary)
            }

            // Input Display
            if !inputAmount.isEmpty {
                VStack(spacing: 8) {
                    Text("Amount")
                        .font(theme.customFont(size: 12, weight: .medium))
                        .foregroundStyle(theme.textTertiary)

                    Text("¥\(inputAmount)")
                        .font(theme.customFont(size: 36, weight: .bold))
                        .foregroundStyle(theme.primaryAccent)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(theme.primaryAccent.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                        )
                )
            }

            // The Liquid Keypad
            InteractiveLiquidKeypad(
                onNumberPress: { num in
                    if inputAmount.count < 9 {
                        inputAmount += "\(num)"
                    }
                    theme.lightHaptic()
                },
                onDelete: {
                    if !inputAmount.isEmpty {
                        inputAmount.removeLast()
                    }
                    theme.lightHaptic()
                },
                onDone: {
                    theme.successHaptic()
                    showDetail = true
                }
            )

            // Instructions
            HStack(spacing: 20) {
                InstructionItem(
                    icon: "hand.tap.fill",
                    text: "Tap buttons to see gooey effect"
                )

                InstructionItem(
                    icon: "arrow.left.arrow.right",
                    text: "Press nearby buttons to merge"
                )
            }
        }
    }

    // MARK: - Voronoi Preview

    private var voronoiPreview: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Phase 2")
                    .font(theme.customFont(size: 14, weight: .semibold))
                    .foregroundStyle(theme.secondaryAccent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(theme.secondaryAccent.opacity(0.15))
                    )

                Text("Voronoi Budget Visualization")
                    .font(theme.customFont(size: 20, weight: .bold))
                    .foregroundStyle(theme.textPrimary)
            }

            Text("Budget categories as organic cells that breathe and grow")
                .font(theme.customFont(size: 14, weight: .regular))
                .foregroundStyle(theme.textTertiary)

            VoronoiBudgetView(
                categoryData: [
                    (name: "餐饮", amount: 3500, color: .blue),
                    (name: "购物", amount: 2800, color: .purple),
                    (name: "交通", amount: 1200, color: .orange),
                    (name: "娱乐", amount: 1800, color: .pink)
                ]
            )
            .frame(height: 280)
        }
    }

    // MARK: - 3D Asset Preview

    private var asset3DPreview: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Phase 3")
                    .font(theme.customFont(size: 14, weight: .semibold))
                    .foregroundStyle(theme.incomeGreen)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(theme.incomeGreen.opacity(0.15))
                    )

                Text("Tangible 3D Assets")
                    .font(theme.customFont(size: 20, weight: .bold))
                    .foregroundStyle(theme.textPrimary)
            }

            Text("Drag to rotate • Gyroscope coming soon")
                .font(theme.customFont(size: 14, weight: .regular))
                .foregroundStyle(theme.textTertiary)

            Asset3DCardView(
                assetName: "招商银行",
                amount: 12580.50,
                cardColor: .blue,
                cardType: .visa
            )
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 12) {
            Text("💡 The Future of Finance")
                .font(theme.customFont(size: 18, weight: .semibold))
                .foregroundStyle(theme.textPrimary)

            Text("Standard apps use tables and charts.\nFinancial Organism uses art, physics, and life.")
                .font(theme.customFont(size: 14, weight: .regular))
                .foregroundStyle(theme.textTertiary)
                .multilineTextAlignment(.center)

            Text("Phase 1 Complete ✨")
                .font(theme.customFont(size: 12, weight: .medium))
                .foregroundStyle(theme.primaryAccent)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(theme.primaryAccent.opacity(0.15))
                )
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Instruction Item

struct InstructionItem: View {
    @Environment(\.appTheme) private var theme

    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(theme.primaryAccent)
                .frame(width: 40)

            Text(text)
                .font(theme.customFont(size: 12, weight: .medium))
                .foregroundStyle(theme.textTertiary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackground.opacity(0.6))
        )
    }
}

// MARK: - Preview

#Preview("Financial Organism") {
    NavigationStack {
        FinancialOrganismView()
    }
    .environment(\.appTheme, CharcoalTheme())
}
