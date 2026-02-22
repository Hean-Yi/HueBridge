//
//  WelcomeView.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI

struct WelcomeView: View {
    let startAction: () -> Void
    let aboutAction: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                heroSection
                featuresCard
                ctaSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("HueBridge")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: aboutAction) {
                    Image(systemName: "info.circle")
                }
                .accessibilityLabel("About HueBridge")
            }
        }
        .background(.clear)
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 80, height: 80)
                Image(systemName: "eyedropper.halffull")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.tint)
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.top, 4)
            .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("Design that everyone\ncan read.")
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)

                Text("Build poster palettes with accessibility checks, color‑vision simulation, and one‑tap contrast fixes.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Features

    private var featuresCard: some View {
        VStack(spacing: 0) {
            featureRow(
                "3-step guided flow",
                subtitle: "Pick, tune, and export",
                icon: "list.number",
                color: .blue
            )
            Divider().padding(.leading, 66)
            featureRow(
                "WCAG contrast checks",
                subtitle: "Real-time readability feedback",
                icon: "checkmark.shield.fill",
                color: .green
            )
            Divider().padding(.leading, 66)
            featureRow(
                "Offline & private",
                subtitle: "No data leaves your device",
                icon: "lock.fill",
                color: .orange
            )
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func featureRow(_ title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - CTA

    private var ctaSection: some View {
        Button(action: startAction) {
            Label("Start Palette Session", systemImage: "sparkles")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .accessibilityHint("Begins palette generation")
    }
}
