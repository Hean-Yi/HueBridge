//
//  ColorToken.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import Foundation

struct ColorToken: Identifiable, Hashable {
    let id: String
    let name: String
    var rgba: RGBA

    init(name: String, rgba: RGBA) {
        self.id = name
        self.name = name
        self.rgba = rgba
    }
}
