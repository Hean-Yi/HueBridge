//
//  ResultCardView.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ResultCardView: View {
    @ObservedObject var viewModel: HueBridgeViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var copied = false
    @State private var exportedImage: UIImage?
    @State private var showShareSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    StepIndicatorView(currentStep: 3, subtitle: "Export")
                    Spacer()
                    BadgeView(
                        title: "Inclusive Poster Ready",
                        isPositive: true,
                        animated: true
                    )
                    .accessibilityLabel("Inclusive Poster Ready")
                }

                if let palette = viewModel.selectedPalette {
                    PosterPreview(
                        palette: palette,
                        visionMode: .normal,
                        content: viewModel.posterContent,
                        posterSize: viewModel.posterSize
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    styleCard(for: palette)

                    exportFormatSection(for: palette)

                    guidanceSection(for: palette)

                    actionsSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Style Card")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    performCopy()
                } label: {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
                }
                .accessibilityLabel("Copy color values")
            }
        }
        .background(.clear)
        .sheet(isPresented: $showShareSheet) {
            if let image = exportedImage {
                ShareSheet(items: [image])
            }
        }
    }

    // MARK: - Style Card

    @ViewBuilder
    private func styleCard(for palette: PaletteCandidate) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Style Card")
                .font(.headline)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(Array(palette.tokens.enumerated()), id: \.element.id) { index, token in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(token.rgba.color)
                            .frame(width: 36, height: 36)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(.quaternary, lineWidth: 1)
                            )

                        Text(token.name)
                            .font(.body)

                        Spacer()

                        Text(viewModel.hexString(for: token.rgba))
                            .font(.body.monospaced())
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)

                    if index < palette.tokens.count - 1 {
                        Divider().padding(.leading, 62)
                    }
                }
            }
            .glassSurface(viewModel.stylePreset)
        }
    }

    // MARK: - Export Format

    @ViewBuilder
    private func exportFormatSection(for palette: PaletteCandidate) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Export format")
                    .font(.headline)
                Spacer()
                Picker("Format", selection: $viewModel.exportFormat) {
                    ForEach(HueBridgeViewModel.ExportFormat.allCases) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 200)
            }
            .padding(.horizontal, 4)

            Text(viewModel.exportText(for: palette))
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassSurface(viewModel.stylePreset, cornerRadius: 12)
        }
    }

    // MARK: - Guidance

    @ViewBuilder
    private func guidanceSection(for palette: PaletteCandidate) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommended usage")
                .font(.headline)
                .padding(.horizontal, 4)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(palette.guidance, id: \.self) { line in
                    Label(line, systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .symbolRenderingMode(.hierarchical)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassSurface(viewModel.stylePreset)
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                exportPosterImage()
            } label: {
                Label("Export Poster Image", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityLabel("Export poster as image")

            Button {
                performCopy()
            } label: {
                Label(copied ? "Copied!" : "Copy \(viewModel.exportFormat.rawValue) Values", systemImage: copied ? "checkmark" : "doc.on.doc")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .accessibilityLabel("Copy color values")

            HStack(spacing: 12) {
                Button {
                    viewModel.backToChooseAnother()
                } label: {
                    Label("Change Template", systemImage: "arrow.uturn.left")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(.bordered)
                .tint(.secondary)

                Button {
                    viewModel.restart()
                    copied = false
                } label: {
                    Label("Start Over", systemImage: "arrow.counterclockwise")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(.bordered)
                .tint(.secondary)
            }
        }
    }

    // MARK: - Helpers

    private func performCopy() {
        viewModel.copyStyleCardToClipboard()
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            copied = true
        }
        Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                withAnimation(reduceMotion ? nil : .default) { copied = false }
            }
        }
    }

    private func exportPosterImage() {
        #if canImport(UIKit)
        guard let image = viewModel.renderPosterImage() else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        exportedImage = image
        showShareSheet = true
        #endif
    }
}

// MARK: - Share Sheet

#if canImport(UIKit)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif
