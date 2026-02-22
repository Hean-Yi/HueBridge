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

    /// User-friendly description explaining this vision mode for non-experts.
    var friendlyDescription: String {
        switch self {
        case .normal:
            return "Standard color vision"
        case .protanopia:
            return "Red-weak · ~1% of males"
        case .deuteranopia:
            return "Green-weak · ~6% of males"
        case .tritanopia:
            return "Blue-yellow · rare"
        case .grayscale:
            return "No color · luminance only"
        }
    }

    var icon: String {
        switch self {
        case .normal:       return "eye"
        case .protanopia:   return "eye.trianglebadge.exclamationmark"
        case .deuteranopia: return "eye.trianglebadge.exclamationmark"
        case .tritanopia:   return "eye.trianglebadge.exclamationmark"
        case .grayscale:    return "circle.lefthalf.filled"
        }
    }

    /// The three clinical color-vision deficiency types.
    static var cvdModes: [VisionMode] {
        [.protanopia, .deuteranopia, .tritanopia]
    }
}
