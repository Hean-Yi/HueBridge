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
                Section("HueBridge") {
                    Text("HueBridge is an offline micro-studio for creating readable, color-vision-friendly poster palettes.")
                    Text("No network used; runs fully offline.")
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
                    Text("WCAG 2 contrast ratio reference")
                    Text("Machado et al. color vision deficiency simulation")
                }
            }
            .navigationTitle("About")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
