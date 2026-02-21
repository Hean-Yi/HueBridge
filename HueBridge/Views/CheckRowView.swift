//
//  CheckRowView.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI

struct CheckRowView: View {
    let item: CheckItem

    // Visual progress: how far toward 1.5× the threshold we are
    private var progress: Double {
        min(item.ratio / (item.threshold * 1.5), 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: item.isPass ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(item.isPass ? .green : .red)
                    .font(.title3)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.headline)
                    Text("Target \(String(format: "%.1f", item.threshold)):1")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(item.ratioLabel)
                        .font(.headline.monospacedDigit())
                    Text(item.isPass ? "Pass" : "Fail")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(item.isPass ? .green : .red)
                }
            }

            // Ratio bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(.primary.opacity(0.08))
                    Capsule(style: .continuous)
                        .fill(item.isPass ? Color.green : Color.orange)
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 4)
        }
        .padding(.vertical, 10)
        .frame(minHeight: 66)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(item.title), \(item.ratioLabel), \(item.isPass ? "Pass" : "Fail")")
    }
}
