//
//  BadgeView.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI

struct BadgeView: View {
    let title: String
    let isPositive: Bool
    var animated: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    var body: some View {
        Label {
            Text(title)
                .font(.subheadline.weight(.semibold))
        } icon: {
            Image(systemName: isPositive ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                .symbolRenderingMode(.hierarchical)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .foregroundStyle(isPositive ? Color.green : Color.orange)
        .background(
            Capsule(style: .continuous)
                .fill((isPositive ? Color.green : Color.orange).opacity(0.14))
        )
        .scaleEffect(animated && !reduceMotion ? (isVisible ? 1 : 0.92) : 1)
        .opacity(animated && !reduceMotion ? (isVisible ? 1 : 0) : 1)
        .onAppear {
            guard animated, !reduceMotion else { return }
            withAnimation(.spring(duration: 0.45, bounce: 0.45)) {
                isVisible = true
            }
        }
    }
}
