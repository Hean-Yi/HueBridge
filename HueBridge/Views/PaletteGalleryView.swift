//
//  PaletteGalleryView.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI

struct PaletteGalleryView: View {
    @ObservedObject var viewModel: HueBridgeViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pick a base color and compare three inclusive templates.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)

                stepPill

                controls

                ForEach(viewModel.candidates) { candidate in
                    PaletteCard(
                        palette: candidate,
                        passes: viewModel.candidatePasses(candidate),
                        onTap: { viewModel.openDetails(for: candidate) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Palette Gallery")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showAbout = true
                } label: {
                    Image(systemName: "info.circle")
                }
                .accessibilityLabel("About")
            }
        }
        .background(.clear)
    }

    // MARK: - Controls

    private var controls: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Base color")
                    .font(.headline)

                Spacer(minLength: 12)

                ColorPicker(
                    "Pick base color",
                    selection: Binding(
                        get: { viewModel.baseColor.color },
                        set: { viewModel.chooseBaseColor($0) }
                    ),
                    supportsOpacity: false
                )
                .labelsHidden()
                .accessibilityLabel("Base color picker")

                Text(viewModel.hexString(for: viewModel.baseColor))
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        Capsule(style: .continuous)
                            .fill(.quaternary)
                    )
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.basePresets) { preset in
                        let isSelected = preset.color == viewModel.baseColor
                        Button {
                            viewModel.choosePreset(preset)
                        } label: {
                            HStack(spacing: 7) {
                                Circle()
                                    .fill(preset.color.color)
                                    .frame(width: 14, height: 14)
                                Text(preset.name)
                                    .font(.subheadline.weight(.medium))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(isSelected ? preset.color.color.opacity(0.22) : Color.primary.opacity(0.08))
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(preset.name) preset")
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                    }
                }
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: - Step

    private var stepPill: some View {
        StepIndicatorView(currentStep: 1, subtitle: "Choose a candidate")
    }
}
