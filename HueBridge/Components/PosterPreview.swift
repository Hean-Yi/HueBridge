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
    private var accentColor: Color { visibleColor(palette.accent) }
    private var textColor: Color { visibleColor(palette.text) }
    private var btnBg: Color { visibleColor(palette.buttonBackground) }
    private var btnTxt: Color { visibleColor(palette.buttonText) }

    var body: some View {
        let radius: CGFloat = compact ? 16 : 20
        let ratio = compact ? posterSize.compactAspectRatio : posterSize.aspectRatio

        ZStack {
            // Background
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(bg)

            // Multi-layer gradient overlay for depth
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [accentColor.opacity(compact ? 0.08 : 0.12), .clear, bg.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Radial glow behind headline area
            if !compact {
                RadialGradient(
                    colors: [accentColor.opacity(0.06), .clear],
                    center: .init(x: 0.3, y: 0.55),
                    startRadius: 20,
                    endRadius: 200
                )
                .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            }

            // Decorative elements (togglable)
            if content.showAccentShape {
                decorativeElements
                    .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            }

            // Content layout
            Group {
                if posterSize == .landscape {
                    landscapeLayout
                } else {
                    switch content.layoutStyle {
                    case .standard:
                        standardLayout
                    case .centered:
                        centeredLayout
                    case .editorial:
                        editorialLayout
                    }
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
                    .foregroundStyle(textColor.opacity(0.7))
                Spacer(minLength: 0)
                if content.showBadge && !content.badgeText.isEmpty {
                    badgeTag
                }
            }

            Spacer(minLength: 0)

            // Decorative divider
            if !compact && content.showDivider {
                decorativeDivider
            }

            // Headline
            Text(content.headline)
                .font(compact
                    ? .system(size: 14, weight: .heavy)
                    : .system(size: posterSize == .square ? 24 : 28, weight: .heavy)
                )
                .tracking(compact ? -0.3 : -0.5)
                .foregroundStyle(accentColor)
                .lineLimit(compact ? 2 : 4)

            // Date tag line
            if !compact {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(accentColor.opacity(0.4))
                        .frame(width: 16, height: 2)
                    Text(content.date.uppercased())
                        .font(.caption2.weight(.semibold))
                        .tracking(0.8)
                        .foregroundStyle(textColor.opacity(0.6))
                }
            }

            // Body
            Text(content.body)
                .font(compact ? .system(size: 9) : .callout)
                .foregroundStyle(textColor)
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
                    .foregroundStyle(textColor.opacity(0.75))
            }
        }
    }

    // MARK: - Centered Layout

    private var centeredLayout: some View {
        VStack(spacing: compact ? 6 : 14) {
            // Top organizer
            HStack {
                Spacer()
                if content.showBadge && !content.badgeText.isEmpty {
                    badgeTag
                }
            }

            Spacer(minLength: 0)

            // Center content
            VStack(spacing: compact ? 4 : 10) {
                Text(content.organizer.uppercased())
                    .font(compact ? .system(size: 7, weight: .bold) : .caption.weight(.bold))
                    .tracking(compact ? 0.8 : 1.8)
                    .foregroundStyle(textColor.opacity(0.5))

                if !compact && content.showDivider {
                    centeredDivider
                }

                Text(content.headline)
                    .font(compact
                        ? .system(size: 14, weight: .heavy)
                        : .system(size: posterSize == .square ? 26 : 30, weight: .heavy)
                    )
                    .tracking(compact ? -0.3 : -0.5)
                    .foregroundStyle(accentColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(compact ? 2 : 3)

                Text(content.body)
                    .font(compact ? .system(size: 8) : .callout)
                    .foregroundStyle(textColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(compact ? 1 : 3)
                    .lineLimit(compact ? 2 : 3)
                    .frame(maxWidth: compact ? .infinity : 280)
            }

            Spacer(minLength: 0)

            // Bottom bar
            VStack(spacing: compact ? 4 : 8) {
                Text(content.buttonText)
                    .font(compact ? .system(size: 10, weight: .bold) : .subheadline.weight(.bold))
                    .tracking(0.3)
                    .padding(.horizontal, compact ? 10 : 22)
                    .padding(.vertical, compact ? 6 : 10)
                    .background(Capsule(style: .continuous).fill(btnBg))
                    .foregroundStyle(btnTxt)

                HStack(spacing: compact ? 4 : 8) {
                    Text(content.date.uppercased())
                    Text("·")
                    Text(content.venue)
                }
                .font(compact ? .system(size: 7, weight: .medium) : .caption2.weight(.medium))
                .foregroundStyle(textColor.opacity(0.55))
            }
        }
    }

    // MARK: - Editorial Layout

    private var editorialLayout: some View {
        VStack(alignment: .leading, spacing: compact ? 5 : 10) {
            // Oversized number / date header
            HStack(alignment: .firstTextBaseline, spacing: compact ? 4 : 8) {
                Text(content.date.uppercased())
                    .font(compact ? .system(size: 20, weight: .black) : .system(size: 38, weight: .black))
                    .foregroundStyle(accentColor.opacity(0.15))
                Spacer()
                if content.showBadge && !content.badgeText.isEmpty {
                    badgeTag
                }
            }

            // Thin accent rule
            if content.showDivider {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(accentColor.opacity(0.5))
                        .frame(width: compact ? 30 : 50, height: compact ? 2 : 3)
                    Rectangle()
                        .fill(accentColor.opacity(0.15))
                        .frame(height: compact ? 1 : 1.5)
                }
            }

            // Organizer
            Text(content.organizer.uppercased())
                .font(compact ? .system(size: 7, weight: .bold) : .caption.weight(.bold))
                .tracking(compact ? 0.5 : 1.5)
                .foregroundStyle(textColor.opacity(0.5))

            // Headline
            Text(content.headline)
                .font(compact
                    ? .system(size: 14, weight: .heavy)
                    : .system(size: posterSize == .square ? 22 : 26, weight: .heavy)
                )
                .tracking(compact ? -0.2 : -0.3)
                .foregroundStyle(accentColor)
                .lineLimit(compact ? 2 : 4)

            // Body
            Text(content.body)
                .font(compact ? .system(size: 8) : .callout)
                .foregroundStyle(textColor)
                .lineSpacing(compact ? 1 : 4)
                .lineLimit(compact ? 2 : nil)

            Spacer(minLength: 0)

            // Footer
            HStack(alignment: .center) {
                Text(content.buttonText)
                    .font(compact ? .system(size: 9, weight: .bold) : .subheadline.weight(.bold))
                    .tracking(0.3)
                    .padding(.horizontal, compact ? 10 : 18)
                    .padding(.vertical, compact ? 5 : 9)
                    .background(
                        RoundedRectangle(cornerRadius: compact ? 6 : 8, style: .continuous)
                            .fill(btnBg)
                    )
                    .foregroundStyle(btnTxt)

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 1) {
                    Text(content.venue)
                    Text(content.date)
                }
                .font(compact ? .system(size: 7, weight: .medium) : .caption2.weight(.medium))
                .foregroundStyle(textColor.opacity(0.6))
            }
        }
    }

    // MARK: - Landscape Layout

    private var landscapeLayout: some View {
        HStack(spacing: compact ? 8 : 16) {
            VStack(alignment: .leading, spacing: compact ? 4 : 8) {
                HStack(spacing: 6) {
                    Text(content.organizer.uppercased())
                        .font(compact ? .system(size: 7, weight: .bold) : .caption2.weight(.bold))
                        .tracking(1.0)
                        .foregroundStyle(textColor.opacity(0.7))
                    if content.showBadge && !content.badgeText.isEmpty && !compact {
                        badgeTag
                    }
                }

                Text(content.headline)
                    .font(compact ? .system(size: 12, weight: .heavy) : .title3.weight(.heavy))
                    .tracking(-0.3)
                    .foregroundStyle(accentColor)
                    .lineLimit(2)

                if !compact {
                    Text(content.body)
                        .font(.caption)
                        .foregroundStyle(textColor)
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
                    .foregroundStyle(textColor.opacity(0.7))
            }
        }
    }

    // MARK: - Badge Tag

    private var badgeTag: some View {
        Text(content.badgeText.uppercased())
            .font(compact ? .system(size: 6, weight: .heavy) : .caption2.weight(.heavy))
            .tracking(0.5)
            .foregroundStyle(btnTxt)
            .padding(.horizontal, compact ? 5 : 8)
            .padding(.vertical, compact ? 2 : 4)
            .background(
                Capsule(style: .continuous)
                    .fill(btnBg)
            )
    }

    // MARK: - Decorative Elements

    private var decorativeElements: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            // Top-right circle cluster
            Circle()
                .fill(accentColor.opacity(0.06))
                .frame(width: w * 0.35, height: w * 0.35)
                .offset(x: w * 0.72, y: -w * 0.08)

            Circle()
                .stroke(accentColor.opacity(0.10), lineWidth: compact ? 1 : 1.5)
                .frame(width: w * 0.18, height: w * 0.18)
                .offset(x: w * 0.58, y: w * 0.06)

            // Small accent ring
            Circle()
                .stroke(accentColor.opacity(0.08), lineWidth: compact ? 0.8 : 1.2)
                .frame(width: w * 0.08, height: w * 0.08)
                .offset(x: w * 0.48, y: w * 0.15)

            // Bottom-left soft arc
            Circle()
                .fill(btnBg.opacity(0.05))
                .frame(width: w * 0.45, height: w * 0.45)
                .offset(x: -w * 0.18, y: h - w * 0.15)

            // Dot grid pattern (top-left)
            if !compact && content.showDecorativeDots {
                dotGrid(columns: 4, rows: 4, size: 2.5, spacing: 7)
                    .foregroundStyle(textColor.opacity(0.08))
                    .offset(x: w * 0.04, y: h * 0.10)
            }

            // Diagonal accent line
            Path { path in
                path.move(to: CGPoint(x: w * 0.85, y: h * 0.35))
                path.addLine(to: CGPoint(x: w * 0.92, y: h * 0.60))
            }
            .stroke(accentColor.opacity(0.08), lineWidth: compact ? 1.5 : 2.5)

            // Secondary subtle line
            if !compact {
                Path { path in
                    path.move(to: CGPoint(x: w * 0.88, y: h * 0.38))
                    path.addLine(to: CGPoint(x: w * 0.95, y: h * 0.58))
                }
                .stroke(accentColor.opacity(0.04), lineWidth: 1.5)
            }

            // Bottom-right corner detail
            if !compact {
                RoundedRectangle(cornerRadius: 2)
                    .fill(accentColor.opacity(0.06))
                    .frame(width: w * 0.12, height: w * 0.005)
                    .offset(x: w * 0.80, y: h * 0.88)
            }
        }
    }

    private var decorativeDivider: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(accentColor.opacity(0.30))
                .frame(width: 28, height: 3)
            Circle()
                .fill(accentColor.opacity(0.20))
                .frame(width: 4, height: 4)
            Circle()
                .fill(accentColor.opacity(0.12))
                .frame(width: 3, height: 3)
        }
    }

    private var centeredDivider: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(accentColor.opacity(0.15))
                .frame(width: 3, height: 3)
            RoundedRectangle(cornerRadius: 1)
                .fill(accentColor.opacity(0.25))
                .frame(width: 20, height: 2)
            Circle()
                .fill(accentColor.opacity(0.25))
                .frame(width: 5, height: 5)
            RoundedRectangle(cornerRadius: 1)
                .fill(accentColor.opacity(0.25))
                .frame(width: 20, height: 2)
            Circle()
                .fill(accentColor.opacity(0.15))
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
