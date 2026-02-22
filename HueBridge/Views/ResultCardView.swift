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
                        .contentTransition(.symbolEffect(.replace))
                }
                .accessibilityLabel("Copy HEX values")
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
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
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
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 12) {
            // Primary: Export poster image
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

            // Secondary: Copy HEX values
            Button {
                performCopy()
            } label: {
                Label(copied ? "Copied!" : "Copy HEX Values", systemImage: copied ? "checkmark" : "doc.on.doc")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .accessibilityLabel("Copy HEX values")

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
        withAnimation(.easeInOut(duration: 0.2)) {
            copied = true
        }
        Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                withAnimation { copied = false }
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
