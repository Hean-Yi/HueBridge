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
    let subtitle: String

    init(name: String, color: RGBA, subtitle: String = "") {
        self.name = name
        self.color = color
        self.subtitle = subtitle
    }

    static let defaults: [BaseColorPreset] = [
        // Academic
        BaseColorPreset(name: "Campus", color: RGBA(red: 0.24, green: 0.46, blue: 0.86), subtitle: "Academic & school events"),
        BaseColorPreset(name: "Club", color: RGBA(red: 0.69, green: 0.30, blue: 0.71), subtitle: "Creative clubs & art"),
        BaseColorPreset(name: "Nature", color: RGBA(red: 0.24, green: 0.58, blue: 0.37), subtitle: "Eco & outdoor activities"),
        // Vibrant
        BaseColorPreset(name: "Sunset", color: RGBA(red: 0.95, green: 0.55, blue: 0.22), subtitle: "Warm events & parties"),
        BaseColorPreset(name: "Coral", color: RGBA(red: 0.91, green: 0.40, blue: 0.28), subtitle: "Bold posters & flyers"),
        BaseColorPreset(name: "Rose", color: RGBA(red: 0.86, green: 0.34, blue: 0.50), subtitle: "Fashion & lifestyle"),
        // Cool
        BaseColorPreset(name: "Ocean", color: RGBA(red: 0.12, green: 0.56, blue: 0.72), subtitle: "Tech & innovation"),
        BaseColorPreset(name: "Night", color: RGBA(red: 0.16, green: 0.28, blue: 0.52), subtitle: "Evening & film events"),
        BaseColorPreset(name: "Mint", color: RGBA(red: 0.30, green: 0.78, blue: 0.65), subtitle: "Health & wellness"),
        // Neutral
        BaseColorPreset(name: "Slate", color: RGBA(red: 0.40, green: 0.44, blue: 0.50), subtitle: "Professional & formal"),
        BaseColorPreset(name: "Mocha", color: RGBA(red: 0.55, green: 0.38, blue: 0.26), subtitle: "Café & cozy themes")
    ]
}
