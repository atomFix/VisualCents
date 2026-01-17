//
//  QuickActionButton.swift
//  VisualCents
//
//  Reusable quick action button with bounce animation
//

import SwiftUI

/// Quick action button for dashboard
struct QuickActionButton: View {
    /// Button icon (SF Symbol name)
    let icon: String
    
    /// Button label
    let label: String
    
    /// Button color
    var color: Color = VCColors.accent
    
    /// Action to perform
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            VCHaptics.medium()
            action()
        }) {
            VStack(spacing: 10) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(color)
                }
                
                Text(label)
                    .font(VCFont.caption())
                    .foregroundStyle(VCColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, VCMetrics.padding)
            .background(VCColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: VCMetrics.cardCornerRadius))
            .vcInnerGlow()
        }
        .buttonStyle(BounceButtonStyle(pressedScale: 0.95, hapticStyle: .light))
    }
}

/// Larger quick action button for primary actions
struct PrimaryActionButton: View {
    let icon: String
    let label: String
    var color: Color = VCColors.accent
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            VCHaptics.heavy()
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                
                Text(label)
                    .font(VCFont.headline())
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: VCMetrics.buttonCornerRadius))
            .shadow(color: color.opacity(0.4), radius: 12, y: 6)
        }
        .buttonStyle(HeavyBounceButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: VCMetrics.padding) {
            QuickActionButton(
                icon: "plus.circle.fill",
                label: "Add",
                color: VCColors.positive
            ) {
                print("Add tapped")
            }
            
            QuickActionButton(
                icon: "camera.fill",
                label: "Scan",
                color: VCColors.accent
            ) {
                print("Scan tapped")
            }
            
            QuickActionButton(
                icon: "chart.pie.fill",
                label: "Stats",
                color: VCColors.accentSecondary
            ) {
                print("Stats tapped")
            }
        }
        
        PrimaryActionButton(
            icon: "plus",
            label: "Add Transaction",
            color: VCColors.accent
        ) {
            print("Primary tapped")
        }
    }
    .padding()
    .background(VCColors.backgroundPrimary)
}
