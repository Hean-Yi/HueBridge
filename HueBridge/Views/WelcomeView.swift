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

    private var hPad: CGFloat { horizontalSizeClass == .compact ? 20 : 32 }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            hero
                .padding(.horizontal, hPad)

            Spacer().frame(height: 44)

            featureList
                .padding(.horizontal, hPad)

            Spacer()
        }
        .safeAreaInset(edge: .bottom) {
            ctaSection
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: 24) {
            appIcon

            VStack(spacing: 10) {
                Text("HueBridge")
                    .font(.largeTitle.weight(.bold))

                Text("Design that everyone can read.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var appIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.regularMaterial)
                .frame(width: 96, height: 96)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(.white.opacity(0.30), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.10), radius: 24, x: 0, y: 8)

            Image(systemName: "eyedropper.halffull")
                .font(.system(size: 42, weight: .medium))
                .foregroundStyle(.tint)
                .symbolRenderingMode(.hierarchical)
        }
        .accessibilityHidden(true)
    }

    // MARK: - Feature List

    private var featureList: some View {
        VStack(spacing: 0) {
            featureRow(
                "3-step guided workflow",
                caption: "Gallery → Validate → Export",
                icon: "list.number",
                accent: .blue
            )
            Divider().padding(.leading, 58)
            featureRow(
                "WCAG contrast validation",
                caption: "AA standard across all text roles",
                icon: "checkmark.shield.fill",
                accent: .green
            )
            Divider().padding(.leading, 58)
            featureRow(
                "Offline & privacy-friendly",
                caption: "No network, no tracking",
                icon: "lock.fill",
                accent: .purple
            )
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.primary.opacity(0.08), lineWidth: 1)
        )
    }

    private func featureRow(_ title: String, caption: String, icon: String, accent: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(accent.opacity(0.16))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Bottom CTA

    private var ctaSection: some View {
        VStack(spacing: 10) {
            Button(action: startAction) {
                Label("Get Started", systemImage: "sparkles")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityHint("Begins palette generation")

            Button(action: aboutAction) {
                Text("About HueBridge")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(height: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, hPad)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .background(.regularMaterial)
    }
}
