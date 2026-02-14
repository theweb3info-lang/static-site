//
//  HomeView.swift
//  PDF Pro
//

import SwiftUI

struct HomeView: View {
    @State private var destination: Destination?

    enum Destination: Hashable {
        case merge, split, rearrange
    }

    var body: some View {
        NavigationStack(path: Binding(
            get: { destination.map { [$0] } ?? [] },
            set: { destination = $0.last }
        )) {
            ZStack {
                // Subtle gradient background
                backgroundGradient

                VStack(spacing: 0) {
                    Spacer()

                    // Header
                    header
                        .padding(.bottom, 48)

                    // Feature cards
                    HStack(spacing: 24) {
                        FeatureCard(
                            icon: "doc.on.doc.fill",
                            title: String(localized: "Merge"),
                            description: String(localized: "Combine multiple PDFs into one"),
                            gradient: .mergeCard,
                            iconColor: Color(hex: 0x667EEA)
                        ) {
                            destination = .merge
                        }

                        FeatureCard(
                            icon: "scissors",
                            title: String(localized: "Split"),
                            description: String(localized: "Break a PDF into parts"),
                            gradient: .splitCard,
                            iconColor: Color(hex: 0xED8936)
                        ) {
                            destination = .split
                        }

                        FeatureCard(
                            icon: "rectangle.grid.2x2.fill",
                            title: String(localized: "Rearrange"),
                            description: String(localized: "Reorder & manage pages"),
                            gradient: .rearrangeCard,
                            iconColor: Color(hex: 0x9F7AEA)
                        ) {
                            destination = .rearrange
                        }
                    }
                    .padding(.horizontal, 48)

                    Spacer()

                    // Footer
                    Text("100% local · 100% private · Zero uploads")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.bottom, 20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationDestination(for: Destination.self) { dest in
                switch dest {
                case .merge:      MergeView()
                case .split:      SplitView()
                case .rearrange:  RearrangeView()
                }
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.brandBlue.opacity(0.03),
                Color.brandPurple.opacity(0.02),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: 10) {
            // App icon
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient.brand)
                    .frame(width: 72, height: 72)
                    .cardShadow()

                Image(systemName: "doc.text.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 8)

            Text("PDF Pro")
                .font(.system(size: 32, weight: .bold, design: .rounded))

            Text("Merge · Split · Rearrange")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Feature Card

private struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let gradient: LinearGradient
    let iconColor: Color
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 18) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(isHovering ? 0.15 : 0.08))
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(iconColor)
                }

                VStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))

                    Text(description)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(width: 200, height: 190)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.background)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        iconColor.opacity(isHovering ? 0.3 : 0.1),
                        lineWidth: 1
                    )
            }
            .cardShadow(isHovering: isHovering)
            .scaleEffect(isHovering ? 1.04 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}
