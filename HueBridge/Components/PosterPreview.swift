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
    var content: PosterContent = PosterContent()
    var posterSize: PosterSize = .portrait
    var compact: Bool = false

    private static let cvdService = CVDService()

    // MARK: - Resolved colors

    private var bg: Color { visibleColor(palette.background) }
    private var title: Color { visibleColor(palette.accent) }
    private var text: Color { visibleColor(palette.text) }
    private var btnBg: Color { visibleColor(palette.buttonBackground) }
    private var btnTxt: Color { visibleColor(palette.buttonText) }

    var body: some View {
        let radius: CGFloat = compact ? 16 : 20
        let ratio = compact ? posterSize.compactAspectRatio : posterSize.aspectRatio

        ZStack {
            // Background
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(bg)

            // Gradient overlay
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [title.opacity(compact ? 0.12 : 0.15), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Decorative elements
            decorativeElements
                .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))

            // Content layout
            Group {
                if posterSize == .landscape {
                    landscapeLayout
                } else {
                    standardLayout
                }
            }
            .padding(compact ? 12 : 20)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(ratio, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Poster preview")
        .accessibilityValue("\(palette.template.rawValue), \(visionMode.rawValue) simulation")
    }

    // MARK: - Standard Layout (Portrait + Square)

    private var standardLayout: some View {
        VStack(alignment: .leading, spacing: compact ? 6 : 12) {
            // Top bar
            HStack {
                Text(content.organizer.uppercased())
                    .font(compact ? .system(size: 8, weight: .bold) : .caption.weight(.bold))
                    .tracking(compact ? 0.8 : 1.2)
                    .foregroundStyle(text.opacity(0.7))
                Spacer(minLength: 0)
                Text(content.date.uppercased())
                    .font(compact ? .system(size: 8, weight: .bold) : .caption.weight(.bold))
                    .tracking(compact ? 0.8 : 1.2)
                    .foregroundStyle(text.opacity(0.7))
            }

            Spacer(minLength: 0)

            // Decorative divider
            if !compact {
                decorativeDivider
            }

            // Headline
            Text(content.headline)
                .font(compact
                    ? .system(size: 14, weight: .heavy)
                    : .system(size: posterSize == .square ? 24 : 28, weight: .heavy)
                )
                .tracking(compact ? -0.3 : -0.5)
                .foregroundStyle(title)
                .lineLimit(compact ? 2 : 4)

            // Body
            Text(content.body)
                .font(compact ? .system(size: 9) : .callout)
                .foregroundStyle(text)
                .lineSpacing(compact ? 1 : 3)
                .lineLimit(compact ? 2 : nil)

            Spacer(minLength: 0)

            // Bottom bar
            HStack(alignment: .center) {
                Text(content.buttonText)
                    .font(compact
                        ? .system(size: 10, weight: .bold)
                        : .subheadline.weight(.bold)
                    )
                    .tracking(0.3)
                    .padding(.horizontal, compact ? 10 : 18)
                    .padding(.vertical, compact ? 6 : 10)
                    .background(Capsule(style: .continuous).fill(btnBg))
                    .foregroundStyle(btnTxt)

                Spacer(minLength: 0)

                Text(content.venue)
                    .font(compact ? .system(size: 8, weight: .semibold) : .footnote.weight(.semibold))
                    .tracking(0.5)
                    .foregroundStyle(text.opacity(0.75))
            }
        }
    }

    // MARK: - Landscape Layout

    private var landscapeLayout: some View {
        HStack(spacing: compact ? 8 : 16) {
            VStack(alignment: .leading, spacing: compact ? 4 : 8) {
                Text(content.organizer.uppercased())
                    .font(compact ? .system(size: 7, weight: .bold) : .caption2.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(text.opacity(0.7))

                Text(content.headline)
                    .font(compact ? .system(size: 12, weight: .heavy) : .title3.weight(.heavy))
                    .tracking(-0.3)
                    .foregroundStyle(title)
                    .lineLimit(2)

                if !compact {
                    Text(content.body)
                        .font(.caption)
                        .foregroundStyle(text)
                        .lineLimit(2)
                        .lineSpacing(2)
                }
            }

            Spacer(minLength: 0)

            VStack(spacing: compact ? 4 : 8) {
                Spacer(minLength: 0)

                Text(content.buttonText)
                    .font(compact ? .system(size: 9, weight: .bold) : .footnote.weight(.bold))
                    .tracking(0.3)
                    .padding(.horizontal, compact ? 8 : 14)
                    .padding(.vertical, compact ? 5 : 8)
                    .background(Capsule(style: .continuous).fill(btnBg))
                    .foregroundStyle(btnTxt)

                Text("\(content.date) · \(content.venue)")
                    .font(compact ? .system(size: 7, weight: .medium) : .caption2.weight(.medium))
                    .foregroundStyle(text.opacity(0.7))
            }
        }
    }

    // MARK: - Decorative Elements

    private var decorativeElements: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            // Top-right circle cluster
            Circle()
                .fill(title.opacity(0.08))
                .frame(width: w * 0.35, height: w * 0.35)
                .offset(x: w * 0.72, y: -w * 0.08)

            Circle()
                .stroke(title.opacity(0.12), lineWidth: compact ? 1 : 1.5)
                .frame(width: w * 0.18, height: w * 0.18)
                .offset(x: w * 0.58, y: w * 0.06)

            // Bottom-left arc
            Circle()
                .fill(btnBg.opacity(0.06))
                .frame(width: w * 0.45, height: w * 0.45)
                .offset(x: -w * 0.18, y: h - w * 0.15)

            // Dot grid pattern (top-left)
            if !compact {
                dotGrid(columns: 3, rows: 3, size: 3, spacing: 8)
                    .foregroundStyle(text.opacity(0.1))
                    .offset(x: w * 0.05, y: h * 0.12)
            }

            // Diagonal accent line
            Path { path in
                path.move(to: CGPoint(x: w * 0.85, y: h * 0.4))
                path.addLine(to: CGPoint(x: w * 0.95, y: h * 0.65))
            }
            .stroke(title.opacity(0.1), lineWidth: compact ? 1.5 : 2.5)
        }
    }

    private var decorativeDivider: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 1)
                .fill(title.opacity(0.25))
                .frame(width: 24, height: 2.5)
            Circle()
                .fill(title.opacity(0.18))
                .frame(width: 4, height: 4)
            Circle()
                .fill(title.opacity(0.12))
                .frame(width: 3, height: 3)
        }
    }

    private func dotGrid(columns: Int, rows: Int, size: CGFloat, spacing: CGFloat) -> some View {
        VStack(spacing: spacing) {
            ForEach(0..<rows, id: \.self) { _ in
                HStack(spacing: spacing) {
                    ForEach(0..<columns, id: \.self) { _ in
                        Circle()
                            .frame(width: size, height: size)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func visibleColor(_ color: RGBA) -> Color {
        Self.cvdService.simulate(color, mode: visionMode).color
    }
}

// MARK: - Exportable Poster (for ImageRenderer)

struct ExportablePoster: View {
    let palette: PaletteCandidate
    let content: PosterContent
    let posterSize: PosterSize

    var body: some View {
        PosterPreview(
            palette: palette,
            visionMode: .normal,
            content: content,
            posterSize: posterSize,
            compact: false
        )
        .frame(width: exportWidth)
    }

    private var exportWidth: CGFloat {
        switch posterSize {
        case .portrait:  return 900
        case .square:    return 1080
        case .landscape: return 1200
        }
    }
}
