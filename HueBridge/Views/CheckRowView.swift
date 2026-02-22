//
//  CheckRowView.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI

struct CheckRowView: View {
    let item: CheckItem

    var body: some View {
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
                    .contentTransition(.numericText())
                    .animation(.default, value: item.ratioLabel)
                Text(item.isPass ? "Pass" : "Fail")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(item.isPass ? Color.green : Color.red)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(item.title), \(item.ratioLabel), \(item.isPass ? "Pass" : "Fail")")
    }
}
