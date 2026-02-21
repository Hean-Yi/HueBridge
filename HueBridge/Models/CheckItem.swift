//
//  CheckItem.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import Foundation

struct CheckItem: Identifiable, Hashable {
    let title: String
    let ratio: Double
    let threshold: Double

    var id: String { title }

    var isPass: Bool {
        ratio >= threshold
    }

    var ratioLabel: String {
        String(format: "%.1f:1", ratio)
    }
}
