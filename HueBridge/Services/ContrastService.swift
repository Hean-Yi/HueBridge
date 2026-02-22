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

    /// Picks the softest text color that still meets the target contrast ratio (default 4.5:1).
    /// Candidates ordered from softest to most extreme; returns the first that passes.
    func bestTextColor(on background: RGBA, targetRatio: Double = 4.5) -> RGBA {
        let bgLuminance = relativeLuminance(for: background)
        let needDark = bgLuminance > 0.18  // heuristic: bright bg → dark text

        let candidates: [RGBA] = needDark
            ? [.systemDarkGray, .black]
            : [.systemLightGray, .white]

        for candidate in candidates {
            if ratio(between: candidate, and: background) >= targetRatio {
                return candidate
            }
        }
        // Fallback: pure black or white always has the highest contrast
        return needDark ? .black : .white
    }

    // MARK: - Smart Mix

    /// Binary-searches for the minimum mix amount of `target` into `color` that
    /// achieves `targetRatio` contrast against `against`. Returns `nil` when the
    /// ratio is already met, or 1.0 if even full mixing isn't enough.
    func mixAmountToReachRatio(
        color: RGBA,
        target: RGBA,
        against: RGBA,
        targetRatio: Double
    ) -> Double? {
        let current = ratio(between: color, and: against)
        if current >= targetRatio { return nil } // already passes

        var lo: Double = 0
        var hi: Double = 1

        // 20 iterations gives ~1e-6 precision
        for _ in 0..<20 {
            let mid = (lo + hi) / 2
            let mixed = color.mixed(with: target, amount: mid)
            let r = ratio(between: mixed, and: against)
            if r >= targetRatio {
                hi = mid
            } else {
                lo = mid
            }
        }
        return hi
    }

    // MARK: - CIE Lab & Delta-E (CIE76)

    /// Perceptual color difference. Higher values mean more distinguishable.
    func deltaE(between first: RGBA, and second: RGBA) -> Double {
        let lab1 = toLab(first)
        let lab2 = toLab(second)
        let dL = lab1.L - lab2.L
        let da = lab1.a - lab2.a
        let db = lab1.b - lab2.b
        return sqrt(dL * dL + da * da + db * db)
    }

    // MARK: - Private

    private func linearize(_ value: Double) -> Double {
        if value <= 0.03928 {
            return value / 12.92
        }
        return pow((value + 0.055) / 1.055, 2.4)
    }

    private struct Lab {
        let L: Double
        let a: Double
        let b: Double
    }

    private func toLab(_ color: RGBA) -> Lab {
        let r = linearize(color.red)
        let g = linearize(color.green)
        let b = linearize(color.blue)

        // D65 reference white
        let xn = 0.95047, yn = 1.0, zn = 1.08883

        let x = (0.4124564 * r + 0.3575761 * g + 0.1804375 * b) / xn
        let y = (0.2126729 * r + 0.7151522 * g + 0.0721750 * b) / yn
        let z = (0.0193339 * r + 0.1191920 * g + 0.9503041 * b) / zn

        let fx = labF(x)
        let fy = labF(y)
        let fz = labF(z)

        return Lab(
            L: 116.0 * fy - 16.0,
            a: 500.0 * (fx - fy),
            b: 200.0 * (fy - fz)
        )
    }

    private func labF(_ t: Double) -> Double {
        if t > 0.008856 {
            return pow(t, 1.0 / 3.0)
        }
        return 7.787 * t + 16.0 / 116.0
    }
}
