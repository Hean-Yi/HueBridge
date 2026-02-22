//
//  RGBA.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct RGBA: Hashable, Codable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double

    init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red.clamped01
        self.green = green.clamped01
        self.blue = blue.clamped01
        self.alpha = alpha.clamped01
    }

    init(color: Color) {
        #if canImport(UIKit)
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) {
            self.init(red: Double(r), green: Double(g), blue: Double(b), alpha: Double(a))
            return
        }
        #endif
        self.init(red: 0, green: 0, blue: 0, alpha: 1)
    }

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }

    func mixed(with other: RGBA, amount: Double) -> RGBA {
        let t = amount.clamped01
        return RGBA(
            red: red + (other.red - red) * t,
            green: green + (other.green - green) * t,
            blue: blue + (other.blue - blue) * t,
            alpha: alpha + (other.alpha - alpha) * t
        )
    }

    // Adjust hue/saturation/brightness for tasteful palette templates.
    func adjusting(brightness brightnessDelta: Double = 0, saturation saturationDelta: Double = 0) -> RGBA {
        #if canImport(UIKit)
        let uiColor = UIColor(color)
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return RGBA(
                color: Color(
                    hue: Double(h),
                    saturation: (Double(s) + saturationDelta).clamped(min: 0, max: 0.85),
                    brightness: (Double(b) + brightnessDelta).clamped(min: 0, max: 1),
                    opacity: Double(a)
                )
            )
        }
        #endif
        return self
    }

    static let black = RGBA(red: 0, green: 0, blue: 0)
    static let white = RGBA(red: 1, green: 1, blue: 1)

    /// iOS system dark label color (#1C1C1E)
    static let systemDarkGray = RGBA(red: 0.110, green: 0.110, blue: 0.118)
    /// iOS system light label color (#F5F5F7)
    static let systemLightGray = RGBA(red: 0.961, green: 0.961, blue: 0.969)
}

private extension Double {
    var clamped01: Double { clamped(min: 0, max: 1) }

    func clamped(min: Double, max: Double) -> Double {
        Swift.max(min, Swift.min(max, self))
    }
}
