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
            GlassSurface(stylePreset: stylePreset, cornerRadius: 24, padding: 15) {
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
                            .font(.subheadline.weight(.semibold))
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.bold))
                    }
                    .foregroundStyle(.secondary)
                    .frame(minHeight: 44)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.primary.opacity(0.06))
                    )
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(palette.template.rawValue), \(passes ? "Pass" : "Needs Fix")")
        .accessibilityHint("Opens detailed readability checks")
    }
}
