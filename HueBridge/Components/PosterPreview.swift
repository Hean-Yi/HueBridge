//
//  PosterPreview.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI

struct PosterPreview: View {
    let palette: PaletteCandidate
    let visionMode: VisionMode
    var compact: Bool = false

    private let cvdService = CVDService()

    var body: some View {
        let backgroundColor = visibleColor(palette.background)
        let titleColor = visibleColor(palette.accent)
        let textColor = visibleColor(palette.text)
        let buttonBackground = visibleColor(palette.buttonBackground)
        let buttonText = visibleColor(palette.buttonText)

        return ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: compact ? 16 : 24, style: .continuous)
                .fill(backgroundColor)

            RoundedRectangle(cornerRadius: compact ? 16 : 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            titleColor.opacity(compact ? 0.16 : 0.18),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: compact ? 8 : 14) {
                HStack {
                    Text("A11Y DESIGN CLUB")
                        .font(compact ? .caption2.weight(.semibold) : .caption.weight(.semibold))
                        .foregroundStyle(textColor.opacity(0.82))
                    Spacer(minLength: 0)
                    Text("APR 24")
                        .font(compact ? .caption2.weight(.semibold) : .caption.weight(.semibold))
                        .foregroundStyle(textColor.opacity(0.82))
                }

                Text("Campus Innovation Expo")
                    .font(compact ? .headline : .title2.weight(.bold))
                    .foregroundStyle(titleColor)

                Text("Design that everyone can read. Build posters with clear contrast and inclusive color choices.")
                    .font(compact ? .caption : .body)
                    .foregroundStyle(textColor)
                    .lineLimit(compact ? 3 : nil)

                HStack {
                    Text("Join Now")
                        .font(compact ? .caption.weight(.semibold) : .headline)
                        .padding(.horizontal, compact ? 10 : 16)
                        .padding(.vertical, compact ? 7 : 10)
                        .background(
                            Capsule(style: .continuous)
                                .fill(buttonBackground)
                        )
                        .foregroundStyle(buttonText)

                    Spacer(minLength: 0)

                    Text("Hall B")
                        .font(compact ? .caption2.weight(.medium) : .subheadline.weight(.medium))
                        .foregroundStyle(textColor.opacity(0.84))
                }
            }
            .padding(compact ? 12 : 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: compact ? 170 : 290)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Poster preview")
        .accessibilityValue("\(palette.template.rawValue), \(visionMode.rawValue) simulation")
    }

    private func visibleColor(_ color: RGBA) -> Color {
        cvdService.simulate(color, mode: visionMode).color
    }
}
