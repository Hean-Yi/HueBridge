//
//  VisionMode.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import Foundation

enum VisionMode: String, CaseIterable, Identifiable {
    case normal = "Normal"
    case deuteranopia = "Deuteranopia"
    case protanopia = "Protanopia"
    case grayscale = "Grayscale"

    var id: String { rawValue }
}
