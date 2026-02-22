//
//  CVDService.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import Foundation

struct CVDService {
    func simulate(_ color: RGBA, mode: VisionMode) -> RGBA {
        switch mode {
        case .normal:
            return color
        case .deuteranopia:
            return applyMatrix(color, matrix: deuteranopia)
        case .protanopia:
            return applyMatrix(color, matrix: protanopia)
        case .tritanopia:
            return applyMatrix(color, matrix: tritanopia)
        case .grayscale:
            let gray = 0.299 * color.red + 0.587 * color.green + 0.114 * color.blue
            return RGBA(red: gray, green: gray, blue: gray, alpha: color.alpha)
        }
    }

    private func applyMatrix(_ color: RGBA, matrix: [[Double]]) -> RGBA {
        let r = color.red
        let g = color.green
        let b = color.blue

        let transformedR = (matrix[0][0] * r + matrix[0][1] * g + matrix[0][2] * b).clamped01
        let transformedG = (matrix[1][0] * r + matrix[1][1] * g + matrix[1][2] * b).clamped01
        let transformedB = (matrix[2][0] * r + matrix[2][1] * g + matrix[2][2] * b).clamped01

        return RGBA(red: transformedR, green: transformedG, blue: transformedB, alpha: color.alpha)
    }

    // Severity 1.0 simulation matrices based on Machado et al.
    private let protanopia: [[Double]] = [
        [0.152286, 1.052583, -0.204868],
        [0.114503, 0.786281, 0.099216],
        [-0.003882, -0.048116, 1.051998]
    ]

    private let deuteranopia: [[Double]] = [
        [0.367322, 0.860646, -0.227968],
        [0.280085, 0.672501, 0.047413],
        [-0.011820, 0.042940, 0.968881]
    ]

    // Machado et al. severity 1.0 tritanopia matrix
    private let tritanopia: [[Double]] = [
        [1.255528, -0.076749, -0.178779],
        [-0.078411, 0.930809, 0.147602],
        [0.004733, 0.691367, 0.303900]
    ]
}

private extension Double {
    var clamped01: Double {
        max(0, min(1, self))
    }
}
