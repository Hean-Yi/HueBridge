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
    let stylePreset: StylePreset
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            GlassSurface(stylePreset: stylePreset, cornerRadius: 20, padding: 16) {
                VStack(alignment: .leading, spacing: 14) {
                    // Card header
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(palette.template.rawValue)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("Tap to inspect readability")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        BadgeView(
                            title: passes ? "Pass" : "Needs Fix",
                            isPositive: passes
                        )
                    }

                    // Poster preview
                    PosterPreview(palette: palette, visionMode: .normal, compact: true)

                    // Footer row
                    HStack(spacing: 8) {
                        Image(systemName: passes ? "checkmark.circle.fill" : "wand.and.sparkles")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(passes ? .green : .secondary)
                        Text(passes ? "Ready for style card" : "Open to apply quick fixes")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.tertiary)
                    }
                    .frame(minHeight: 36)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(palette.template.rawValue), \(passes ? "Pass" : "Needs Fix")")
        .accessibilityHint("Opens detailed readability checks")
    }
}
