//
//  CheckItem.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import Foundation

struct CheckItem: Identifiable, Hashable {
    enum Kind: Hashable {
        case contrastRatio
        case distinguishability
    }

    let title: String
    let ratio: Double
    let threshold: Double
    let kind: Kind

    init(title: String, ratio: Double, threshold: Double, kind: Kind = .contrastRatio) {
        self.title = title
        self.ratio = ratio
        self.threshold = threshold
        self.kind = kind
    }

    var id: String { title }

    var isPass: Bool {
        ratio >= threshold
    }

    var ratioLabel: String {
        switch kind {
        case .contrastRatio:
            return String(format: "%.1f:1", ratio)
        case .distinguishability:
            return String(format: "ΔE %.1f", ratio)
        }
    }

    var thresholdLabel: String {
        switch kind {
        case .contrastRatio:
            return String(format: "Target %.1f:1", threshold)
        case .distinguishability:
            return String(format: "Min ΔE %.0f", threshold)
        }
    }

    /// User-friendly explanation for non-experts.
    var friendlyExplanation: String {
        switch kind {
        case .contrastRatio:
            if isPass {
                return "Text is easy to read on this background."
            } else {
                return "Text may be hard to read — needs more contrast."
            }
        case .distinguishability:
            if isPass {
                return "Colors are clearly different from each other."
            } else {
                return "Colors look too similar — may confuse viewers."
            }
        }
    }
}
