//
//  ContrastService.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import Foundation

struct ContrastService {
    // WCAG relative luminance from linearized sRGB components.
    func relativeLuminance(for color: RGBA) -> Double {
        let r = linearize(color.red)
        let g = linearize(color.green)
        let b = linearize(color.blue)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    func ratio(between first: RGBA, and second: RGBA) -> Double {
        let l1 = relativeLuminance(for: first)
        let l2 = relativeLuminance(for: second)
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    func bestTextColor(on background: RGBA) -> RGBA {
        let blackRatio = ratio(between: RGBA.black, and: background)
        let whiteRatio = ratio(between: RGBA.white, and: background)
        return blackRatio >= whiteRatio ? .black : .white
    }

    private func linearize(_ value: Double) -> Double {
        if value <= 0.03928 {
            return value / 12.92
        }
        return pow((value + 0.055) / 1.055, 2.4)
    }
}
