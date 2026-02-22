//
//  VisionMode.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import Foundation

enum VisionMode: String, CaseIterable, Identifiable {
    case normal = "Normal"
    case protanopia = "Protanopia"
    case deuteranopia = "Deuteranopia"
    case tritanopia = "Tritanopia"
    case grayscale = "Grayscale"

    var id: String { rawValue }

    var shortName: String {
        switch self {
        case .normal: return "Normal"
        case .protanopia: return "Protan"
        case .deuteranopia: return "Deutan"
        case .tritanopia: return "Tritan"
        case .grayscale: return "Gray"
        }
    }

    /// The three clinical color-vision deficiency types.
    static var cvdModes: [VisionMode] {
        [.protanopia, .deuteranopia, .tritanopia]
    }
}
