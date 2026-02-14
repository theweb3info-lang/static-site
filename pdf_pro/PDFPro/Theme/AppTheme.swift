//
//  AppTheme.swift
//  PDF Pro
//

import SwiftUI

// MARK: - Brand Colors

extension Color {
    static let brandBlue = Color(hex: 0x667EEA)
    static let brandPurple = Color(hex: 0x764BA2)

    static let brandGradientStart = Color(hex: 0x667EEA)
    static let brandGradientEnd = Color(hex: 0x764BA2)

    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

// MARK: - Gradients

extension LinearGradient {
    static let brand = LinearGradient(
        colors: [.brandGradientStart, .brandGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let mergeCard = LinearGradient(
        colors: [Color(hex: 0x667EEA), Color(hex: 0x5A67D8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let splitCard = LinearGradient(
        colors: [Color(hex: 0xED8936), Color(hex: 0xDD6B20)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let rearrangeCard = LinearGradient(
        colors: [Color(hex: 0x9F7AEA), Color(hex: 0x805AD5)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Shadows

extension View {
    func cardShadow(isHovering: Bool = false) -> some View {
        self.shadow(
            color: .black.opacity(isHovering ? 0.15 : 0.08),
            radius: isHovering ? 12 : 6,
            y: isHovering ? 6 : 3
        )
    }

    func subtleShadow() -> some View {
        self.shadow(color: .black.opacity(0.06), radius: 3, y: 1)
    }
}

// MARK: - View Modifiers

struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat = 12

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
    }
}

extension View {
    func glassBackground(cornerRadius: CGFloat = 12) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius))
    }
}

// MARK: - Drop Zone Style

struct DropZoneStyle: ViewModifier {
    let isTargeted: Bool
    var accentColor: Color = .brandBlue

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isTargeted ? accentColor.opacity(0.05) : Color.clear)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        isTargeted ? accentColor : Color.secondary.opacity(0.2),
                        style: StrokeStyle(lineWidth: 2, dash: isTargeted ? [] : [8, 6])
                    )
            }
            .animation(.easeInOut(duration: 0.2), value: isTargeted)
    }
}

extension View {
    func dropZoneStyle(isTargeted: Bool, accentColor: Color = .brandBlue) -> some View {
        modifier(DropZoneStyle(isTargeted: isTargeted, accentColor: accentColor))
    }
}
