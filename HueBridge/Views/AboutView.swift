//
//  AboutView.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI

struct AboutView: View {
    @Binding var stylePreset: StylePreset
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("Offline micro-studio for creating readable, color‑vision‑friendly poster palettes.", systemImage: "eyedropper.halffull")
                        .font(.subheadline)
                    Label("No network used; runs fully on device.", systemImage: "wifi.slash")
                        .font(.subheadline)
                } header: {
                    Text("About")
                }

                Section("Appearance") {
                    Picker("Style", selection: $stylePreset) {
                        ForEach(StylePreset.allCases) { preset in
                            Text(preset.rawValue).tag(preset)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text("Visual style also available in Gallery view.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("WCAG 2 — Web Content Accessibility Guidelines", systemImage: "doc.text")
                        Text("The standard for measuring text readability. A ratio of 4.5:1 means the lighter color is 4.5x brighter than the darker one.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)

                    VStack(alignment: .leading, spacing: 6) {
                        Label("Machado et al. CVD simulation", systemImage: "eye")
                        Text("Research-based color transforms that show how people with color vision deficiency perceive colors.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)

                    VStack(alignment: .leading, spacing: 6) {
                        Label("Delta E (ΔE) — Color difference", systemImage: "circle.lefthalf.filled")
                        Text("Measures how different two colors look. Values below 10 mean colors might be confused.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                } header: {
                    Text("Glossary")
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
