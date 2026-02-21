//
//  HueBridgeViewModel.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif

final class HueBridgeViewModel: ObservableObject {
    enum Stage {
        case welcome
        case gallery
        case detail
        case result
    }

    @Published var stage: Stage = .welcome
    @Published var showAbout = false
    @Published var stylePreset: StylePreset = .frostedGlass
    @Published var visionMode: VisionMode = .normal

    @Published var baseColor: RGBA
    @Published var candidates: [PaletteCandidate] = []
    @Published private(set) var selectedPaletteID: PaletteTemplate?

    let basePresets = BaseColorPreset.defaults

    private let paletteGenerator = PaletteGenerator()
    private let contrastService = ContrastService()
    private let hexFormatter = HexFormatter()

    init() {
        self.baseColor = BaseColorPreset.defaults.first?.color ?? RGBA(red: 0.24, green: 0.46, blue: 0.86)
        regenerateCandidates()
    }

    var selectedPalette: PaletteCandidate? {
        guard let selectedPaletteID else { return nil }
        return candidates.first(where: { $0.id == selectedPaletteID })
    }

    var selectedChecks: [CheckItem] {
        guard let selectedPalette else { return [] }
        return checks(for: selectedPalette)
    }

    var selectedPalettePasses: Bool {
        guard let selectedPalette else { return false }
        return checks(for: selectedPalette).allSatisfy(\CheckItem.isPass)
    }

    func startExperience() {
        stage = .gallery
    }

    func chooseBaseColor(_ color: Color) {
        baseColor = RGBA(color: color)
        regenerateCandidates()
    }

    func choosePreset(_ preset: BaseColorPreset) {
        baseColor = preset.color
        regenerateCandidates()
    }

    func openDetails(for candidate: PaletteCandidate) {
        selectedPaletteID = candidate.id
        visionMode = .normal
        stage = .detail
    }

    func backToGallery() {
        stage = .gallery
    }

    func continueToResult() {
        stage = .result
    }

    func restart() {
        stage = .welcome
        visionMode = .normal
        selectedPaletteID = nil
        if let first = basePresets.first {
            baseColor = first.color
        }
        regenerateCandidates()
    }

    func checks(for palette: PaletteCandidate) -> [CheckItem] {
        let titleRatio = contrastService.ratio(between: palette.accent, and: palette.background)
        let bodyRatio = contrastService.ratio(between: palette.text, and: palette.background)
        let buttonRatio = contrastService.ratio(between: palette.buttonText, and: palette.buttonBackground)

        return [
            CheckItem(title: "Title contrast", ratio: titleRatio, threshold: 3.0),
            CheckItem(title: "Body contrast", ratio: bodyRatio, threshold: 4.5),
            CheckItem(title: "Button contrast", ratio: buttonRatio, threshold: 4.5)
        ]
    }

    func candidatePasses(_ candidate: PaletteCandidate) -> Bool {
        checks(for: candidate).allSatisfy(\CheckItem.isPass)
    }

    func makeTextDarker() {
        updateSelectedPalette { palette in
            palette.text = palette.text.mixed(with: .black, amount: 0.14)
            palette.buttonText = palette.buttonText.mixed(with: .black, amount: 0.14)
            palette.accent = palette.accent.mixed(with: .black, amount: 0.12)
        }
    }

    func lightenBackground() {
        updateSelectedPalette { palette in
            palette.background = palette.background.mixed(with: .white, amount: 0.12)
        }
    }

    func exportText(for palette: PaletteCandidate) -> String {
        [
            "HueBridge Style Card",
            "Background: \(hexFormatter.hexString(for: palette.background))",
            "Text: \(hexFormatter.hexString(for: palette.text))",
            "Accent: \(hexFormatter.hexString(for: palette.accent))",
            "Button Background: \(hexFormatter.hexString(for: palette.buttonBackground))",
            "Button Text: \(hexFormatter.hexString(for: palette.buttonText))"
        ].joined(separator: "\n")
    }

    func hexString(for color: RGBA) -> String {
        hexFormatter.hexString(for: color)
    }

    func copyStyleCardToClipboard() {
        guard let selectedPalette else { return }
        #if canImport(UIKit)
        UIPasteboard.general.string = exportText(for: selectedPalette)
        #endif
    }

    private func regenerateCandidates() {
        let generated = paletteGenerator.generate(base: baseColor)
        candidates = generated

        if let selectedPaletteID,
           generated.contains(where: { $0.id == selectedPaletteID }) {
            return
        }

        if stage == .detail || stage == .result {
            self.selectedPaletteID = generated.first?.id
        }
    }

    private func updateSelectedPalette(_ update: (inout PaletteCandidate) -> Void) {
        guard let selectedPaletteID,
              let index = candidates.firstIndex(where: { $0.id == selectedPaletteID }) else {
            return
        }

        var palette = candidates[index]
        update(&palette)
        candidates[index] = palette
    }
}
