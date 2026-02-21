//
//  ResultCardView.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI

struct ResultCardView: View {
    @ObservedObject var viewModel: HueBridgeViewModel
    @State private var copied = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var hPad: CGFloat { horizontalSizeClass == .compact ? 20 : 28 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                pageHeader
                    .padding(.horizontal, hPad)
                    .padding(.top, 16)

                if let palette = viewModel.selectedPalette {
                    BadgeView(title: "Inclusive Poster Ready", isPositive: true, animated: true)
                        .padding(.horizontal, hPad)
                        .accessibilityLabel("Inclusive Poster Ready")
                        .accessibilityHint("All readability checks passed")

                    GlassSurface(stylePreset: viewModel.stylePreset, cornerRadius: 20, padding: 14) {
                        PosterPreview(palette: palette, visionMode: .normal)
                    }
                    .padding(.horizontal, hPad)

                    styleCard(for: palette)
                        .padding(.horizontal, hPad)

                    guidanceCard(for: palette)
                        .padding(.horizontal, hPad)
                }

                Spacer().frame(height: 8)
            }
            .padding(.bottom, 8)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            bottomActions
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Page Header

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your Style Card")
                .font(.largeTitle.weight(.bold))

            Label("Step 3 of 3  ·  Done", systemImage: "3.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Style Card (Token List)

    private func styleCard(for palette: PaletteCandidate) -> some View {
        GlassSurface(stylePreset: viewModel.stylePreset, cornerRadius: 20, padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Style Card")
                    .font(.title3.weight(.semibold))

                VStack(spacing: 0) {
                    ForEach(Array(palette.tokens.enumerated()), id: \.offset) { index, token in
                        if index > 0 { Divider() }
                        tokenRow(token)
                    }
                }
                .background(.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private func tokenRow(_ token: ColorToken) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(token.rgba.color)
                .frame(width: 40, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(.primary.opacity(0.12), lineWidth: 1)
                )

            Text(token.name)
                .font(.body)

            Spacer()

            Text(viewModel.hexString(for: token.rgba))
                .font(.body.monospaced())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(minHeight: 52)
    }

    // MARK: - Guidance Card

    private func guidanceCard(for palette: PaletteCandidate) -> some View {
        GlassSurface(stylePreset: viewModel.stylePreset, cornerRadius: 20, padding: 16) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text("Recommended Usage")
                        .font(.headline)
                }

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(palette.guidance, id: \.self) { line in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "arrow.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.top, 3)
                            Text(line)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Bottom Action Bar

    private var bottomActions: some View {
        VStack(spacing: 0) {
            Divider()
            VStack(spacing: 10) {
                Button {
                    viewModel.copyStyleCardToClipboard()
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                        copied = true
                    }
                } label: {
                    Label(
                        copied ? "Copied!" : "Copy HEX Values",
                        systemImage: copied ? "checkmark" : "doc.on.doc"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                }
                .buttonStyle(.borderedProminent)
                .animation(reduceMotion ? nil : .spring(duration: 0.3, bounce: 0.2), value: copied)
                .accessibilityLabel(copied ? "Copied to clipboard" : "Copy HEX values")
                .accessibilityHint("Copies all color hex values to clipboard")

                Button {
                    viewModel.restart()
                    copied = false
                } label: {
                    Text("Start Over")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Returns to the welcome screen")
            }
            .padding(.horizontal, hPad)
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
        .background(.regularMaterial)
    }
}
