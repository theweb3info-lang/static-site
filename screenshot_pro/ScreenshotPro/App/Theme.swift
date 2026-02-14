//
//  Theme.swift
//  ScreenshotPro
//
//  Brand colors, typography, and design tokens
//

import SwiftUI

// MARK: - Brand Colors

extension Color {
    /// Primary brand color — warm coral/orange
    static let brand = Color(red: 1.0, green: 0.36, blue: 0.26)        // #FF5C42
    static let brandLight = Color(red: 1.0, green: 0.45, blue: 0.35)   // lighter variant
    static let brandDark = Color(red: 0.85, green: 0.28, blue: 0.2)    // darker variant
    
    /// Gradient pair
    static let brandGradientStart = Color(red: 1.0, green: 0.42, blue: 0.22)  // orange
    static let brandGradientEnd = Color(red: 0.96, green: 0.26, blue: 0.42)   // pinkish-red
    
    /// Semantic colors
    static let surfacePrimary = Color(.windowBackgroundColor)
    static let surfaceSecondary = Color(.controlBackgroundColor)
    static let surfaceElevated = Color(.underPageBackgroundColor)
    
    static let textPrimary = Color(.labelColor)
    static let textSecondary = Color(.secondaryLabelColor)
    static let textTertiary = Color(.tertiaryLabelColor)
    
    static let separator = Color(.separatorColor)
}

// MARK: - Brand Gradient

extension LinearGradient {
    static let brand = LinearGradient(
        colors: [.brandGradientStart, .brandGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Design Tokens

enum SPSpacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 6
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
    static let huge: CGFloat = 40
}

enum SPRadius {
    static let sm: CGFloat = 6
    static let md: CGFloat = 10
    static let lg: CGFloat = 14
    static let xl: CGFloat = 20
}

// MARK: - Custom Button Styles

struct SPPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, SPSpacing.xl)
            .padding(.vertical, SPSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SPRadius.md)
                    .fill(LinearGradient.brand)
                    .opacity(configuration.isPressed ? 0.85 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SPGhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.brand)
            .padding(.horizontal, SPSpacing.lg)
            .padding(.vertical, SPSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: SPRadius.sm)
                    .fill(Color.brand.opacity(configuration.isPressed ? 0.12 : 0.06))
            )
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - View Modifiers

struct SPCardModifier: ViewModifier {
    var padding: CGFloat = SPSpacing.lg
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: SPRadius.lg)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            )
    }
}

extension View {
    func spCard(padding: CGFloat = SPSpacing.lg) -> some View {
        modifier(SPCardModifier(padding: padding))
    }
}
