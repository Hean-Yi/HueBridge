//
//  GlassSurface.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI

struct GlassSurface<Content: View>: View {
    let stylePreset: StylePreset
    var cornerRadius: CGFloat = 22
    var padding: CGFloat = 16
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(stylePreset.fillStyle)

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(stylePreset.highlightOpacity),
                            Color.white.opacity(0.01),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(stylePreset.strokeOpacity), lineWidth: stylePreset == .clearGlass ? 1.2 : 0.9)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            content()
                .padding(padding)
        )
        .shadow(color: Color.black.opacity(stylePreset.shadowOpacity), radius: 18, x: 0, y: 8)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.black.opacity(stylePreset == .classicFlat ? 0.06 : 0.03), lineWidth: 0.8)
        )
    }
}
