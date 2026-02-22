//
//  PaletteCard.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI

struct PaletteCard: View {
    let palette: PaletteCandidate
    let passes: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(palette.template.rawValue)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("Tap to inspect readability")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    BadgeView(
                        title: passes ? "Pass" : "Needs Fix",
                        isPositive: passes
                    )
                }

                PosterPreview(palette: palette, visionMode: .normal, compact: true)

                HStack(spacing: 8) {
                    Image(systemName: passes ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                    Text(passes ? "Ready for detail check" : "Open and apply quick fixes")
                        .font(.subheadline.weight(.medium))
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.tertiary)
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.quaternary)
                )
            }
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(palette.template.rawValue), \(passes ? "Pass" : "Needs Fix")")
        .accessibilityHint("Opens detailed readability checks")
    }
}
