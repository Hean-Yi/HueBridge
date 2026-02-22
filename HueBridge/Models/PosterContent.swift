//
//  PosterContent.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/22.
//


import Foundation

struct PosterContent {
    var organizer: String = "A11Y DESIGN CLUB"
    var date: String = "APR 24"
    var headline: String = "Campus Innovation Expo"
    var body: String = "Design that everyone can read. Build posters with clear contrast and inclusive color choices."
    var buttonText: String = "Join Now"
    var venue: String = "Hall B"
}

enum PosterSize: String, CaseIterable, Identifiable {
    case portrait = "Portrait"
    case square = "Square"
    case landscape = "Landscape"

    var id: String { rawValue }

    var aspectRatio: Double {
        switch self {
        case .portrait:  return 0.707   // ~A4 ratio
        case .square:    return 1.0
        case .landscape: return 1.91    // Meta / X banner
        }
    }

    var icon: String {
        switch self {
        case .portrait:  return "rectangle.portrait"
        case .square:    return "square"
        case .landscape: return "rectangle"
        }
    }

    var compactAspectRatio: Double {
        switch self {
        case .portrait:  return 0.85
        case .square:    return 1.3
        case .landscape: return 2.2
        }
    }
}
