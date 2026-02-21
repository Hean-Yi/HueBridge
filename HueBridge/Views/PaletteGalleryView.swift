//
//  PaletteGalleryView.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI

struct PaletteGalleryView: View {
    @ObservedObject var viewModel: HueBridgeViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var hPad: CGFloat { horizontalSizeClass == .compact ? 20 : 28 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                pageHeader
                    .padding(.horizontal, hPad)
                    .padding(.top, 16)

                controlsCard
                    .padding(.horizontal, hPad)

                candidateCards
                    .padding(.horizontal, hPad)
                    .padding(.bottom, 32)
            }
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Page Header

    private var pageHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Choose a Palette")
                    .font(.largeTitle.weight(.bold))

                Label("Step 1 of 3", systemImage: "1.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)

            Button {
                viewModel.showAbout = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.title2.weight(.regular))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .accessibilityLabel("About HueBridge")
        }
    }

    // MARK: - Controls Card

    private var controlsCard: some View {
        GlassSurface(stylePreset: viewModel.stylePreset, cornerRadius: 20, padding: 16) {
            VStack(alignment: .leading, spacing: 16) {
                baseColorRow
                ColorPicker(
                    "Choose a base color",
                    selection: Binding(
                        get: { viewModel.baseColor.color },
                        set: { viewModel.chooseBaseColor($0) }
                    ),
                    supportsOpacity: false
                )
                .accessibilityLabel("Base color picker")

                presetChips

                Divider()

                stylePresetRow
            }
        }
    }

    private var baseColorRow: some View {
        HStack(spacing: 10) {
            Text("Base Color")
                .font(.headline)

            Spacer()

            HStack(spacing: 6) {
                Circle()
                    .fill(viewModel.baseColor.color)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(.primary.opacity(0.15), lineWidth: 0.5))
                Text(viewModel.hexString(for: viewModel.baseColor))
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule(style: .continuous).fill(.primary.opacity(0.07)))
        }
    }

    private var presetChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.basePresets) { preset in
                    let isSelected = preset.color == viewModel.baseColor
                    Button {
                        viewModel.choosePreset(preset)
                    } label: {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(preset.color.color)
                                .frame(width: 14, height: 14)
                                .overlay(Circle().stroke(.primary.opacity(0.12), lineWidth: 0.5))
                            Text(preset.name)
                                .font(.subheadline.weight(.semibold))
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 36)
                        .background(
                            Capsule(style: .continuous)
                                .fill(isSelected
                                    ? preset.color.color.opacity(0.20)
                                    : Color.primary.opacity(0.07))
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(
                                    isSelected ? preset.color.color.opacity(0.45) : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(preset.name) preset\(isSelected ? ", selected" : "")")
                }
            }
        }
    }

    private var stylePresetRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "paintpalette")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("Interface Style")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Picker("Interface style", selection: $viewModel.stylePreset) {
                ForEach(StylePreset.allCases) { preset in
                    Text(preset.rawValue).tag(preset)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Style preset")
            .accessibilityHint("Switches glass and flat appearance")
        }
    }

    // MARK: - Candidate Cards

    private var candidateCards: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.candidates) { candidate in
                PaletteCard(
                    palette: candidate,
                    passes: viewModel.candidatePasses(candidate),
                    stylePreset: viewModel.stylePreset,
                    onTap: { viewModel.openDetails(for: candidate) }
                )
            }
        }
    }
}
