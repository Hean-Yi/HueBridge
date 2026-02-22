//
//  StylePreset.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum StylePreset: String, CaseIterable, Identifiable {
    case frostedGlass = "Frosted Glass"
    case clearGlass = "Clear Glass"
    case classicFlat = "Classic Flat"

    var id: String { rawValue }

    var fillStyle: AnyShapeStyle {
        switch self {
        case .frostedGlass:
            return AnyShapeStyle(.ultraThinMaterial)
        case .clearGlass:
            return AnyShapeStyle(.thinMaterial)
        case .classicFlat:
            #if canImport(UIKit)
            return AnyShapeStyle(Color(.secondarySystemGroupedBackground))
            #else
            return AnyShapeStyle(Color(red: 0.95, green: 0.95, blue: 0.96))
            #endif
        }
    }

    var strokeOpacity: Double {
        switch self {
        case .frostedGlass: return 0.25
        case .clearGlass:   return 0.35
        case .classicFlat:  return 0.08
        }
    }

    var highlightOpacity: Double {
        switch self {
        case .frostedGlass: return 0.18
        case .clearGlass:   return 0.25
        case .classicFlat:  return 0.0
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .frostedGlass: return 0.08
        case .clearGlass:   return 0.06
        case .classicFlat:  return 0.03
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .frostedGlass: return 18
        case .clearGlass:   return 12
        case .classicFlat:  return 6
        }
    }
}
