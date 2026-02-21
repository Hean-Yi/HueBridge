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

    private var hPad: CGFloat { horizontalSizeClass == .compact ? 20 : 28 }

    var body: some View {
        VStack(spacing: 0) {
            navBar
                .padding(.horizontal, hPad)
                .padding(.top, 12)
                .padding(.bottom, 8)

            scrollContent
        }
        .safeAreaInset(edge: .bottom) {
            ctaSection
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Pinned Navigation Bar

    private var navBar: some View {
        HStack(spacing: 8) {
            Button {
                viewModel.backToGallery()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Gallery")
                        .font(.body.weight(.semibold))
                }
                .frame(height: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tint)
            .accessibilityLabel("Back to Gallery")

            Spacer()

            if let palette = viewModel.selectedPalette {
                BadgeView(
                    title: viewModel.candidatePasses(palette) ? "Pass" : "Needs Fix",
                    isPositive: viewModel.candidatePasses(palette)
                )
                .accessibilityLabel("Overall status: \(viewModel.candidatePasses(palette) ? "Pass" : "Needs Fix")")
            }
        }
    }

    // MARK: - Scrollable Content

    private var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                pageTitleBlock
                    .padding(.horizontal, hPad)

                if let palette = viewModel.selectedPalette {
                    GlassSurface(stylePreset: viewModel.stylePreset, cornerRadius: 20, padding: 14) {
                        PosterPreview(palette: palette, visionMode: viewModel.visionMode)
                    }
                    .padding(.horizontal, hPad)

                    checksCard
                        .padding(.horizontal, hPad)

                    simulationCard
                        .padding(.horizontal, hPad)

                    if !viewModel.selectedPalettePasses {
                        hintRow
                            .padding(.horizontal, hPad)
                    }
                }

                Spacer().frame(height: 8)
            }
            .padding(.bottom, 8)
        }
        .scrollIndicators(.hidden)
    }

    private var pageTitleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.selectedPalette?.template.rawValue ?? "Palette")
                .font(.title.weight(.bold))

            Label("Step 2 of 3  ·  Tune and validate", systemImage: "2.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Readability Checks Card

    private var checksCard: some View {
        GlassSurface(stylePreset: viewModel.stylePreset, cornerRadius: 20, padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Readability Checks")
                    .font(.title3.weight(.semibold))

                VStack(spacing: 0) {
                    ForEach(Array(viewModel.selectedChecks.enumerated()), id: \.offset) { index, item in
                        if index > 0 { Divider() }
                        CheckRowView(item: item)
                    }
                }
            }
        }
    }

    // MARK: - Simulation + Fixes Card

    private var simulationCard: some View {
        GlassSurface(stylePreset: viewModel.stylePreset, cornerRadius: 20, padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: "eye")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text("Color Vision Simulation")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    Picker("Color vision simulation", selection: $viewModel.visionMode) {
                        ForEach(VisionMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Simulation mode")
                    .accessibilityHint("Applies preview-only color vision simulation")
                }

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: "wand.and.sparkles")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text("One-tap Fixes")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 10) {
                        fixButton("Darken Text", icon: "textformat", action: viewModel.makeTextDarker)
                        fixButton("Lighten Background", icon: "sun.max", action: viewModel.lightenBackground)
                    }
                }
            }
        }
    }

    private func fixButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
        .buttonStyle(.bordered)
        .accessibilityLabel(title)
    }

    // MARK: - Hint Row

    private var hintRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "lightbulb")
                .font(.subheadline)
                .foregroundStyle(.orange)
            Text("Apply fixes until all checks show Pass.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Bottom CTA

    private var ctaSection: some View {
        VStack(spacing: 0) {
            Divider()
            Button {
                viewModel.continueToResult()
            } label: {
                Text("Create Style Card")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.selectedPalettePasses)
            .padding(.horizontal, hPad)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .accessibilityHint("Moves to the final style card")
        }
        .background(.regularMaterial)
    }
}
