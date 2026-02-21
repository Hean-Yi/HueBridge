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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Result")
                        .font(compact ? .title.weight(.bold) : .largeTitle.weight(.bold))
                    Spacer()
                    stepPill
                }

                if let palette = viewModel.selectedPalette {
                    GlassSurface(stylePreset: viewModel.stylePreset, cornerRadius: 26, padding: 18) {
                        VStack(alignment: .leading, spacing: 16) {
                            BadgeView(
                                title: "Inclusive Poster Ready",
                                isPositive: true,
                                animated: true
                            )
                            .accessibilityLabel("Inclusive Poster Ready")
                            .accessibilityHint("All readability checks passed")

                            PosterPreview(palette: palette, visionMode: .normal)

                            styleCard(for: palette)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Recommended usage")
                                    .font(.headline)
                                ForEach(palette.guidance, id: \.self) { line in
                                    Text(line)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Button {
                                viewModel.copyStyleCardToClipboard()
                                if reduceMotion {
                                    copied = true
                                } else {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        copied = true
                                    }
                                }
                            } label: {
                                Label("Copy HEX values", systemImage: "doc.on.doc")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: 48)
                            }
                            .buttonStyle(.bordered)
                            .accessibilityLabel("Copy HEX values")
                            .accessibilityHint("Copies style card colors to clipboard")

                            if copied {
                                Text("Copied to clipboard")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.green)
                            }

                            Button {
                                viewModel.restart()
                                copied = false
                            } label: {
                                Text("Restart")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: 48)
                            }
                            .buttonStyle(.borderedProminent)
                            .accessibilityHint("Returns to the welcome screen")
                        }
                    }
                }
            }
            .padding(.vertical, 10)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: 760)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func styleCard(for palette: PaletteCandidate) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Style Card")
                .font(.title3.weight(.semibold))

            ForEach(palette.tokens) { token in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(token.rgba.color)
                        .frame(width: 36, height: 36)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.primary.opacity(0.14), lineWidth: 1)
                        )

                    Text(token.name)
                        .font(.body)

                    Spacer()

                    Text(viewModel.hexString(for: token.rgba))
                        .font(.body.monospaced())
                        .foregroundStyle(.secondary)
                }
                .frame(minHeight: 44)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.primary.opacity(0.05))
                )
            }
        }
    }

    private var stepPill: some View {
        HStack(spacing: 7) {
            Image(systemName: "3.circle.fill")
                .symbolRenderingMode(.hierarchical)
            Text("Step 3 of 3")
                .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(.secondary)
    }

    private var compact: Bool {
        horizontalSizeClass == .compact
    }
}
