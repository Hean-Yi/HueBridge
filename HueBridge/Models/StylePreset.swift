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
}
