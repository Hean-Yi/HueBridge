//
//  PaletteDetailView.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct PaletteDetailView: View {
    @ObservedObject var viewModel: HueBridgeViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                stepPill

                if let palette = viewModel.selectedPalette {
                    PosterPreview(
                        palette: palette,
                        visionMode: viewModel.visionMode,
                        content: viewModel.posterContent,
                        posterSize: viewModel.posterSize
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    posterSettingsSection

                    creativeControlsSection

                    inclusiveCoverageSection

                    checksSection

                    distinguishabilitySection

                    fixButtonsSection

                    Button {
                        viewModel.continueToResult()
                    } label: {
                        Text("Create Style Card")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!viewModel.selectedPalettePasses)
                    .accessibilityHint("Moves to final style card")

                    if !viewModel.selectedPalettePasses {
                        let failingModes = viewModel.inclusiveReport
                            .filter { !$0.passes }
                            .map(\.mode.rawValue)
                        Label(
                            failingModes.isEmpty
                                ? "Apply one-tap fixes until all checks pass."
                                : "Issues in \(failingModes.joined(separator: ", ")). Try Auto Fix or adjust base color.",
                            systemImage: "lightbulb.fill"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(viewModel.selectedPalette?.template.rawValue ?? "Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                BadgeView(
                    title: viewModel.inclusivePasses ? "Inclusive" : "Needs Fix",
                    isPositive: viewModel.inclusivePasses
                )
            }
        }
        .background(.clear)
    }

    // MARK: - Creative Controls

    private var creativeControlsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Creative options")
                .font(.headline)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                // Layout style picker
                HStack {
                    Text("Layout")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Picker("Layout", selection: $viewModel.posterContent.layoutStyle) {
                        ForEach(PosterLayoutStyle.allCases) { style in
                            Label(style.rawValue, systemImage: style.icon).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 240)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)

                Divider().padding(.leading, 14)

                // Badge toggle
                HStack {
                    Label("Badge tag", systemImage: "tag.fill")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    if viewModel.posterContent.showBadge {
                        TextField("Badge", text: $viewModel.posterContent.badgeText)
                            .font(.caption)
                            .textFieldStyle(.plain)
                            .frame(width: 60)
                            .multilineTextAlignment(.trailing)
                    }
                    Toggle("", isOn: $viewModel.posterContent.showBadge)
                        .labelsHidden()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)

                Divider().padding(.leading, 14)

                // Decorative toggles
                Toggle(isOn: $viewModel.posterContent.showDivider) {
                    Label("Decorative divider", systemImage: "minus")
                        .font(.subheadline.weight(.medium))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)

                Divider().padding(.leading, 14)

                Toggle(isOn: $viewModel.posterContent.showDecorativeDots) {
                    Label("Dot grid pattern", systemImage: "circle.grid.3x3")
                        .font(.subheadline.weight(.medium))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)

                Divider().padding(.leading, 14)

                Toggle(isOn: $viewModel.posterContent.showAccentShape) {
                    Label("Accent shapes", systemImage: "circle")
                        .font(.subheadline.weight(.medium))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
            }
            .glassSurface(viewModel.stylePreset)
        }
    }

    // MARK: - Inclusive Coverage

    private var inclusiveCoverageSection: some View {
        let report = viewModel.inclusiveReport
        let passCount = report.filter(\.passes).count
        let total = report.count

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Inclusive coverage")
                    .font(.headline)
                Spacer()
                Text("\(passCount)/\(total)")
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .foregroundStyle(passCount == total ? Color.green : Color.orange)
            }
            .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(Array(report.enumerated()), id: \.element.id) { index, status in
                    modeRow(status: status)

                    if index < report.count - 1 {
                        Divider().padding(.leading, 46)
                    }
                }
            }
            .glassSurface(viewModel.stylePreset)
        }
    }

    private func modeRow(status: HueBridgeViewModel.ModeStatus) -> some View {
        Button {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                viewModel.visionMode = status.mode
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: status.passes ? "checkmark.circle.fill" : "xmark.octagon.fill")
                    .foregroundStyle(status.passes ? Color.green : Color.red)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 1) {
                    Text(status.mode.rawValue)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(status.mode.friendlyDescription)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                if !status.passes {
                    Text("\(status.issueCount) issue\(status.issueCount == 1 ? "" : "s")")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.red)
                }

                if viewModel.visionMode == status.mode {
                    Image(systemName: "eye.fill")
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(status.mode.rawValue), \(status.mode.friendlyDescription), \(status.passes ? "Pass" : "\(status.issueCount) issues")")
    }

    // MARK: - Checks

    private var checksSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("Readability")
                    .font(.headline)
                Text("· \(viewModel.visionMode.rawValue)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(Array(viewModel.selectedChecks.enumerated()), id: \.element.id) { index, item in
                    CheckRowView(item: item)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)

                    if index < viewModel.selectedChecks.count - 1 {
                        Divider().padding(.leading, 46)
                    }
                }
            }
            .glassSurface(viewModel.stylePreset)
        }
    }

    // MARK: - Distinguishability

    private var distinguishabilitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("Distinguishability")
                    .font(.headline)
                Text("· \(viewModel.visionMode.rawValue)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(Array(viewModel.selectedDistinguishability.enumerated()), id: \.element.id) { index, item in
                    CheckRowView(item: item)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)

                    if index < viewModel.selectedDistinguishability.count - 1 {
                        Divider().padding(.leading, 46)
                    }
                }
            }
            .glassSurface(viewModel.stylePreset)
        }
    }

    // MARK: - Fix Buttons

    private var fixButtonsSection: some View {
        VStack(spacing: 10) {
            // Primary: Auto Fix All
            if !viewModel.selectedPalettePasses {
                Button {
                    viewModel.autoFixAll()
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    #endif
                } label: {
                    Label("Auto Fix All", systemImage: "wand.and.stars")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .controlSize(.large)
                .accessibilityLabel("Auto fix all contrast issues")
                .accessibilityHint("Automatically darkens text and lightens background to pass all checks")
            }

            // Secondary: Manual fixes
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 10) {
                    fixButton(title: "Darken text", icon: "textformat", action: viewModel.makeTextDarker)
                    fixButton(title: "Lighten BG", icon: "sun.max", action: viewModel.lightenBackground)
                }

                VStack(spacing: 10) {
                    fixButton(title: "Darken text", icon: "textformat", action: viewModel.makeTextDarker)
                    fixButton(title: "Lighten BG", icon: "sun.max", action: viewModel.lightenBackground)
                }
            }

            if viewModel.canUndo {
                Button {
                    viewModel.undoFix()
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                } label: {
                    Label("Undo last fix", systemImage: "arrow.uturn.backward")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.bordered)
                .tint(.secondary)
                .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                .accessibilityLabel("Undo last fix")
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: viewModel.canUndo)
    }

    private func fixButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
        } label: {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
        }
        .buttonStyle(.bordered)
        .accessibilityLabel(title)
    }

    // MARK: - Poster Settings

    private var posterSettingsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Poster content")
                .font(.headline)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                // Size picker
                HStack {
                    Text("Size")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Picker("Size", selection: $viewModel.posterSize) {
                        ForEach(PosterSize.allCases) { size in
                            Label(size.rawValue, systemImage: size.icon).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 240)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)

                Divider().padding(.leading, 14)

                posterTextField(label: "Headline", text: $viewModel.posterContent.headline)
                Divider().padding(.leading, 14)
                posterTextField(label: "Body", text: $viewModel.posterContent.body, axis: .vertical)
                Divider().padding(.leading, 14)
                posterTextField(label: "Button", text: $viewModel.posterContent.buttonText)
                Divider().padding(.leading, 14)

                HStack(spacing: 10) {
                    posterCompactField(label: "Organizer", text: $viewModel.posterContent.organizer)
                    posterCompactField(label: "Date", text: $viewModel.posterContent.date)
                    posterCompactField(label: "Venue", text: $viewModel.posterContent.venue)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }
            .glassSurface(viewModel.stylePreset)
        }
    }

    private func posterTextField(label: String, text: Binding<String>, axis: Axis = .horizontal) -> some View {
        HStack(alignment: axis == .vertical ? .top : .center) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .frame(width: 70, alignment: .leading)
            TextField(label, text: text, axis: axis)
                .font(.subheadline)
                .textFieldStyle(.plain)
                .lineLimit(axis == .vertical ? 3 : 1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private func posterCompactField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
            TextField(label, text: text)
                .font(.caption)
                .textFieldStyle(.plain)
                .lineLimit(1)
        }
    }

    // MARK: - Step

    private var stepPill: some View {
        StepIndicatorView(currentStep: 2, subtitle: "Tune and validate")
    }
}
