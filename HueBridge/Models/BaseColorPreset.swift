//
//  BaseColorPreset.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import Foundation

struct BaseColorPreset: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let color: RGBA

    static let defaults: [BaseColorPreset] = [
        BaseColorPreset(name: "Campus", color: RGBA(red: 0.24, green: 0.46, blue: 0.86)),
        BaseColorPreset(name: "Club", color: RGBA(red: 0.69, green: 0.30, blue: 0.71)),
        BaseColorPreset(name: "Poster", color: RGBA(red: 0.91, green: 0.40, blue: 0.28)),
        BaseColorPreset(name: "Night", color: RGBA(red: 0.16, green: 0.28, blue: 0.52)),
        BaseColorPreset(name: "Nature", color: RGBA(red: 0.24, green: 0.58, blue: 0.37))
    ]
}
