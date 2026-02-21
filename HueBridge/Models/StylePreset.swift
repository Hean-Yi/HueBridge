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
            return AnyShapeStyle(.regularMaterial)
        case .clearGlass:
            return AnyShapeStyle(.ultraThinMaterial)
        case .classicFlat:
            #if canImport(UIKit)
            return AnyShapeStyle(Color(uiColor: .secondarySystemBackground))
            #else
            return AnyShapeStyle(Color.secondary.opacity(0.14))
            #endif
        }
    }

    var panelStyle: AnyShapeStyle {
        switch self {
        case .frostedGlass:
            return AnyShapeStyle(.thinMaterial)
        case .clearGlass:
            return AnyShapeStyle(.ultraThinMaterial)
        case .classicFlat:
            #if canImport(UIKit)
            return AnyShapeStyle(Color(uiColor: .systemBackground))
            #else
            return AnyShapeStyle(Color.white)
            #endif
        }
    }

    var strokeOpacity: Double {
        switch self {
        case .frostedGlass:
            return 0.26
        case .clearGlass:
            return 0.42
        case .classicFlat:
            return 0.14
        }
    }

    var highlightOpacity: Double {
        switch self {
        case .frostedGlass:
            return 0.24
        case .clearGlass:
            return 0.36
        case .classicFlat:
            return 0
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .frostedGlass:
            return 0.14
        case .clearGlass:
            return 0.1
        case .classicFlat:
            return 0.06
        }
    }
}
