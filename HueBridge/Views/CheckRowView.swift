//
//  CheckRowView.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI

struct CheckRowView: View {
    let item: CheckItem
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Image(systemName: item.isPass ? "checkmark.circle.fill" : "xmark.octagon.fill")
                    .foregroundStyle(item.isPass ? Color.green : Color.red)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                    Text(item.thresholdLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(item.ratioLabel)
                        .font(.subheadline.weight(.semibold).monospacedDigit())
                        .contentTransition(reduceMotion ? .identity : .numericText())
                        .animation(reduceMotion ? nil : .default, value: item.ratioLabel)
                    Text(item.isPass ? "Pass" : "Fail")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(item.isPass ? Color.green : Color.red)
                }
            }

            // User-friendly explanation
            Text(item.friendlyExplanation)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(item.title), \(item.ratioLabel), \(item.isPass ? "Pass" : "Fail"). \(item.friendlyExplanation)")
    }
}
