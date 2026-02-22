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
                }

                Section("Credits") {
                    Label("WCAG 2 contrast ratio reference", systemImage: "doc.text")
                    Label("Machado et al. CVD simulation", systemImage: "eye")
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
