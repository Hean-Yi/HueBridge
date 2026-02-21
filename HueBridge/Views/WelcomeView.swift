//
//  WelcomeView.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI

struct WelcomeView: View {
    let stylePreset: StylePreset
    let startAction: () -> Void
    let aboutAction: () -> Void
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                GlassSurface(stylePreset: stylePreset, cornerRadius: 30, padding: compact ? 18 : 24) {
                    VStack(alignment: .leading, spacing: compact ? 14 : 18) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.primary.opacity(0.12))
                                    .frame(width: compact ? 50 : 58, height: compact ? 50 : 58)
                                Image(systemName: "eyedropper.halffull")
                                    .font(.system(size: compact ? 23 : 27, weight: .semibold))
                                    .foregroundStyle(.primary)
                            }
                            .accessibilityHidden(true)

                            Text("HueBridge")
                                .font(compact ? .title.weight(.bold) : .largeTitle.weight(.bold))
                        }

                        Text("Design that everyone can read.")
                            .font(compact ? .title3.weight(.semibold) : .title2.weight(.semibold))
                            .foregroundStyle(.primary)

                        Text("Build poster palettes with accessibility checks, color-vision simulation, and one-tap contrast fixes.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(alignment: .leading, spacing: 10) {
                            feature("3-step guided flow", icon: "list.number")
                            feature("WCAG contrast feedback", icon: "checkmark.shield")
                            feature("Offline and privacy-friendly", icon: "lock")
                        }
                    }
                }

                GlassSurface(stylePreset: stylePreset, cornerRadius: 26, padding: compact ? 16 : 20) {
                    VStack(spacing: 10) {
                        Button(action: startAction) {
                            Label("Start Palette Session", systemImage: "sparkles")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 50)
                        }
                        .buttonStyle(.borderedProminent)
                        .accessibilityHint("Begins palette generation")

                        Button(action: aboutAction) {
                            Text("About HueBridge")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 44)
                        }
                        .buttonStyle(.bordered)
                        .tint(.primary)
                    }
                }
            }
            .padding(.vertical, 10)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
    }

    private var compact: Bool {
        horizontalSizeClass == .compact
    }

    private func feature(_ text: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 18)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
