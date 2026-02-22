//
//  StepIndicatorView.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI

struct StepIndicatorView: View {
    let currentStep: Int
    let totalSteps: Int = 3
    let subtitle: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 6) {
                ForEach(1...totalSteps, id: \.self) { step in
                    Circle()
                        .fill(step == currentStep ? Color.accentColor : Color.primary.opacity(0.18))
                        .frame(width: step == currentStep ? 10 : 7, height: step == currentStep ? 10 : 7)
                        .animation(reduceMotion ? nil : .spring(duration: 0.3), value: currentStep)
                }
            }

            Text("Step \(currentStep) · \(subtitle)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(currentStep) of \(totalSteps), \(subtitle)")
    }
}
