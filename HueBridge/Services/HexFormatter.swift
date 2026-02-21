//
//  HexFormatter.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import Foundation

struct HexFormatter {
    func hexString(for color: RGBA) -> String {
        let r = Int(round(color.red * 255))
        let g = Int(round(color.green * 255))
        let b = Int(round(color.blue * 255))
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
