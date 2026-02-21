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

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: compact ? 14 : 16) {
                header
                controls
                stepPill

                ForEach(viewModel.candidates) { candidate in
                    PaletteCard(
                        palette: candidate,
                        passes: viewModel.candidatePasses(candidate),
                        stylePreset: viewModel.stylePreset,
                        onTap: { viewModel.openDetails(for: candidate) }
                    )
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
            VStack(alignment: .leading, spacing: 4) {
                Text("Palette Gallery")
                    .font(compact ? .title.weight(.bold) : .largeTitle.weight(.bold))
                Text("Pick a base color and compare three inclusive templates.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)

            Button {
                viewModel.showAbout = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("About")
        }
        .padding(.horizontal, 2)
    }

    private var controls: some View {
        GlassSurface(stylePreset: viewModel.stylePreset, cornerRadius: 24, padding: compact ? 14 : 16) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Base color")
                        .font(.headline)

                    Spacer(minLength: 12)

                    HStack(spacing: 8) {
                        Circle()
                            .fill(viewModel.baseColor.color)
                            .frame(width: 14, height: 14)
                        Text(viewModel.hexString(for: viewModel.baseColor))
                            .font(.footnote.monospaced())
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.primary.opacity(0.08))
                    )
                }

                ColorPicker(
                    "Pick base color",
                    selection: Binding(
                        get: { viewModel.baseColor.color },
                        set: { viewModel.chooseBaseColor($0) }
                    ),
                    supportsOpacity: false
                )
                .accessibilityLabel("Base color picker")

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.basePresets) { preset in
                            let isSelected = preset.color == viewModel.baseColor
                            Button {
                                viewModel.choosePreset(preset)
                            } label: {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(preset.color.color)
                                        .frame(width: 16, height: 16)
                                    Text(preset.name)
                                        .font(.subheadline.weight(.semibold))
                                }
                                .padding(.horizontal, 12)
                                .frame(minHeight: 44)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(isSelected ? preset.color.color.opacity(0.22) : Color.primary.opacity(0.08))
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("\(preset.name) preset")
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Interface style")
                        .font(.headline)
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
        }
    }

    private var stepPill: some View {
        HStack(spacing: 8) {
            Image(systemName: "1.circle.fill")
                .symbolRenderingMode(.hierarchical)
            Text("Step 1 of 3 · Choose a candidate")
                .font(.subheadline.weight(.medium))
        }
        .foregroundStyle(.secondary)
        .frame(minHeight: 34)
    }

    private var compact: Bool {
        horizontalSizeClass == .compact
    }
}
