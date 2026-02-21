//
//  PaletteDetailView.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI

struct PaletteDetailView: View {
    @ObservedObject var viewModel: HueBridgeViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: compact ? 14 : 16) {
                header
                stepPill

                if let palette = viewModel.selectedPalette {
                    GlassSurface(stylePreset: viewModel.stylePreset, cornerRadius: 24, padding: 14) {
                        PosterPreview(palette: palette, visionMode: viewModel.visionMode)
                    }

                    GlassSurface(stylePreset: viewModel.stylePreset, cornerRadius: 24, padding: 16) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Readability checks")
                                .font(.title3.weight(.semibold))

                            ForEach(viewModel.selectedChecks) { item in
                                CheckRowView(item: item)
                            }
                        }
                    }

                    GlassSurface(stylePreset: viewModel.stylePreset, cornerRadius: 24, padding: 16) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Color vision simulation")
                                .font(.headline)

                            Picker("Color vision simulation", selection: $viewModel.visionMode) {
                                ForEach(VisionMode.allCases) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .accessibilityLabel("Simulation mode")
                            .accessibilityHint("Applies preview-only color vision simulation")

                            oneTapFixButtons
                        }
                    }

                    Button {
                        viewModel.continueToResult()
                    } label: {
                        Text("Create Style Card")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 48)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.selectedPalettePasses)
                    .accessibilityHint("Moves to final style card")

                    if !viewModel.selectedPalettePasses {
                        Text("Apply one-tap fixes until all checks pass.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 10)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: 760)
        .frame(maxWidth: .infinity)
    }

    private var header: some View {
        HStack {
            Button {
                viewModel.backToGallery()
            } label: {
                Label("Back", systemImage: "chevron.left")
                    .frame(minHeight: 44)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text("Palette Detail")
                    .font(compact ? .title3.weight(.bold) : .title2.weight(.bold))
                Text("Tune and validate")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let palette = viewModel.selectedPalette {
                BadgeView(
                    title: viewModel.candidatePasses(palette) ? "Pass" : "Needs Fix",
                    isPositive: viewModel.candidatePasses(palette)
                )
                .accessibilityLabel("Overall status")
            }
        }
    }

    private var oneTapFixButtons: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 10) {
                fixButton(
                    title: "Make text darker",
                    icon: "textformat",
                    action: viewModel.makeTextDarker
                )
                fixButton(
                    title: "Lighten background",
                    icon: "sun.max",
                    action: viewModel.lightenBackground
                )
            }

            VStack(spacing: 10) {
                fixButton(
                    title: "Make text darker",
                    icon: "textformat",
                    action: viewModel.makeTextDarker
                )
                fixButton(
                    title: "Lighten background",
                    icon: "sun.max",
                    action: viewModel.lightenBackground
                )
            }
        }
    }

    private func fixButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
        }
        .buttonStyle(.bordered)
        .accessibilityLabel(title)
    }

    private var stepPill: some View {
        HStack(spacing: 8) {
            Image(systemName: "2.circle.fill")
                .symbolRenderingMode(.hierarchical)
            Text("Step 2 of 3 · Tune and validate")
                .font(.subheadline.weight(.medium))
        }
        .foregroundStyle(.secondary)
        .frame(minHeight: 32)
    }

    private var compact: Bool {
        horizontalSizeClass == .compact
    }
}
