//
//  PaletteTemplate.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import Foundation

enum PaletteTemplate: String, CaseIterable, Hashable {
    case airyPoster = "Airy Poster"
    case nightPoster = "Night Poster"
    case neutralStudio = "Neutral Studio"
}

struct PaletteCandidate: Identifiable, Hashable {
    let template: PaletteTemplate
    var background: RGBA
    var text: RGBA
    var accent: RGBA
    var buttonBackground: RGBA
    var buttonText: RGBA
    let guidance: [String]

    var id: PaletteTemplate { template }

    var tokens: [ColorToken] {
        [
            ColorToken(name: "Background", rgba: background),
            ColorToken(name: "Text", rgba: text),
            ColorToken(name: "Accent", rgba: accent),
            ColorToken(name: "Button Background", rgba: buttonBackground),
            ColorToken(name: "Button Text", rgba: buttonText)
        ]
    }
}
