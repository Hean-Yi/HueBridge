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
    enum Stage: Hashable {
        case welcome
        case gallery
        case detail
        case result
    }

    enum ExportFormat: String, CaseIterable, Identifiable {
        case hex = "HEX"
        case css = "CSS"
        case rgb = "RGB"

        var id: String { rawValue }
    }

    @Published var navigationPath: [Stage] = []
    @Published var showAbout = false

    var stage: Stage {
        navigationPath.last ?? .welcome
    }
    @Published var stylePreset: StylePreset = .frostedGlass
    @Published var visionMode: VisionMode = .normal
    @Published var posterContent = PosterContent()
    @Published var posterSize: PosterSize = .portrait
    @Published var exportFormat: ExportFormat = .hex

    @Published var baseColor: RGBA
    @Published var candidates: [PaletteCandidate] = []
    @Published private(set) var selectedPaletteID: PaletteTemplate?
    @Published private(set) var undoStack: [PaletteCandidate] = []

    var canUndo: Bool { !undoStack.isEmpty }

    let basePresets = BaseColorPreset.defaults

    private let paletteGenerator = PaletteGenerator()
    private let contrastService = ContrastService()
    private let cvdService = CVDService()
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
        return checks(for: selectedPalette, mode: visionMode)
    }

    var selectedDistinguishability: [CheckItem] {
        guard let selectedPalette else { return [] }
        return distinguishabilityChecks(for: selectedPalette, mode: visionMode)
    }

    var selectedPalettePasses: Bool {
        inclusivePasses
    }

    /// True only when every vision mode passes both contrast and distinguishability.
    var inclusivePasses: Bool {
        guard let palette = selectedPalette else { return false }
        return candidatePassesInclusive(palette)
    }

    struct ModeStatus: Identifiable {
        let mode: VisionMode
        let issueCount: Int
        var passes: Bool { issueCount == 0 }
        var id: String { mode.rawValue }
    }

    var inclusiveReport: [ModeStatus] {
        guard let palette = selectedPalette else { return [] }
        return VisionMode.allCases.map { mode in
            let contrastFails = checks(for: palette, mode: mode).filter { !$0.isPass }.count
            let deFails = distinguishabilityChecks(for: palette, mode: mode).filter { !$0.isPass }.count
            return ModeStatus(mode: mode, issueCount: contrastFails + deFails)
        }
    }

    func startExperience() {
        navigationPath = [.gallery]
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
        undoStack.removeAll()
        if navigationPath.last != .detail {
            navigationPath.append(.detail)
        }
    }

    func backToGallery() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    func continueToResult() {
        navigationPath.append(.result)
    }

    func backToChooseAnother() {
        navigationPath = [.gallery]
    }

    func restart() {
        navigationPath.removeAll()
        visionMode = .normal
        selectedPaletteID = nil
        undoStack.removeAll()
        posterContent = PosterContent()
        posterSize = .portrait
        if let first = basePresets.first {
            baseColor = first.color
        }
        regenerateCandidates()
    }

    func checks(for palette: PaletteCandidate) -> [CheckItem] {
        checks(for: palette, mode: .normal)
    }

    func checks(for palette: PaletteCandidate, mode: VisionMode) -> [CheckItem] {
        let bg = cvdService.simulate(palette.background, mode: mode)
        let txt = cvdService.simulate(palette.text, mode: mode)
        let acc = cvdService.simulate(palette.accent, mode: mode)
        let btnBg = cvdService.simulate(palette.buttonBackground, mode: mode)
        let btnTxt = cvdService.simulate(palette.buttonText, mode: mode)

        let titleRatio = contrastService.ratio(between: acc, and: bg)
        let bodyRatio = contrastService.ratio(between: txt, and: bg)
        let buttonRatio = contrastService.ratio(between: btnTxt, and: btnBg)

        return [
            CheckItem(title: "Title contrast", ratio: titleRatio, threshold: 3.0),
            CheckItem(title: "Body contrast", ratio: bodyRatio, threshold: 4.5),
            CheckItem(title: "Button contrast", ratio: buttonRatio, threshold: 4.5)
        ]
    }

    func distinguishabilityChecks(for palette: PaletteCandidate, mode: VisionMode) -> [CheckItem] {
        let bg = cvdService.simulate(palette.background, mode: mode)
        let acc = cvdService.simulate(palette.accent, mode: mode)
        let btnBg = cvdService.simulate(palette.buttonBackground, mode: mode)

        let accentVsBg = contrastService.deltaE(between: acc, and: bg)
        let buttonVsBg = contrastService.deltaE(between: btnBg, and: bg)

        return [
            CheckItem(title: "Accent vs Background", ratio: accentVsBg, threshold: 10.0, kind: .distinguishability),
            CheckItem(title: "Button vs Background", ratio: buttonVsBg, threshold: 10.0, kind: .distinguishability)
        ]
    }

    /// Gallery badge now reflects inclusive (all-modes) pass status.
    func candidatePasses(_ candidate: PaletteCandidate) -> Bool {
        candidatePassesInclusive(candidate)
    }

    /// Checks whether a candidate passes contrast and distinguishability across ALL vision modes.
    func candidatePassesInclusive(_ candidate: PaletteCandidate) -> Bool {
        VisionMode.allCases.allSatisfy { mode in
            checks(for: candidate, mode: mode).allSatisfy(\.isPass) &&
            distinguishabilityChecks(for: candidate, mode: mode).allSatisfy(\.isPass)
        }
    }

    /// Quick summary for gallery: normal-only pass status.
    func candidatePassesNormal(_ candidate: PaletteCandidate) -> Bool {
        checks(for: candidate, mode: .normal).allSatisfy(\.isPass)
    }

    // MARK: - Fixes

    func makeTextDarker() {
        updateSelectedPalette { [contrastService, cvdService] palette in
            let textAmount = VisionMode.allCases.compactMap { mode -> Double? in
                let simText = cvdService.simulate(palette.text, mode: mode)
                let simBg = cvdService.simulate(palette.background, mode: mode)
                return contrastService.mixAmountToReachRatio(
                    color: simText, target: .black, against: simBg, targetRatio: 4.5
                )
            }.max() ?? 0

            let accentAmount = VisionMode.allCases.compactMap { mode -> Double? in
                let simAcc = cvdService.simulate(palette.accent, mode: mode)
                let simBg = cvdService.simulate(palette.background, mode: mode)
                return contrastService.mixAmountToReachRatio(
                    color: simAcc, target: .black, against: simBg, targetRatio: 3.0
                )
            }.max() ?? 0

            let btnAmount = VisionMode.allCases.compactMap { mode -> Double? in
                let simBtn = cvdService.simulate(palette.buttonText, mode: mode)
                let simBtnBg = cvdService.simulate(palette.buttonBackground, mode: mode)
                return contrastService.mixAmountToReachRatio(
                    color: simBtn, target: .black, against: simBtnBg, targetRatio: 4.5
                )
            }.max() ?? 0

            if textAmount > 0 {
                palette.text = palette.text.mixed(with: .black, amount: textAmount)
            }
            if accentAmount > 0 {
                palette.accent = palette.accent.mixed(with: .black, amount: accentAmount)
            }
            if btnAmount > 0 {
                palette.buttonText = palette.buttonText.mixed(with: .black, amount: btnAmount)
            }
        }
    }

    func lightenBackground() {
        updateSelectedPalette { [contrastService, cvdService] palette in
            let amount = VisionMode.allCases.compactMap { mode -> Double? in
                let simBg = cvdService.simulate(palette.background, mode: mode)
                let simText = cvdService.simulate(palette.text, mode: mode)
                let simAcc = cvdService.simulate(palette.accent, mode: mode)

                let textAmt = contrastService.mixAmountToReachRatio(
                    color: simBg, target: .white, against: simText, targetRatio: 4.5
                )
                let accAmt = contrastService.mixAmountToReachRatio(
                    color: simBg, target: .white, against: simAcc, targetRatio: 3.0
                )
                return [textAmt, accAmt].compactMap { $0 }.max()
            }.compactMap { $0 }.max() ?? 0

            if amount > 0 {
                palette.background = palette.background.mixed(with: .white, amount: amount)
            }
        }
    }

    /// One-tap auto-fix: applies both text darkening and background lightening.
    func autoFixAll() {
        makeTextDarker()
        lightenBackground()
    }

    func undoFix() {
        guard let previous = undoStack.popLast(),
              let index = candidates.firstIndex(where: { $0.id == previous.id }) else {
            return
        }
        candidates[index] = previous
    }

    // MARK: - Export

    func exportText(for palette: PaletteCandidate) -> String {
        switch exportFormat {
        case .hex:
            return exportHex(for: palette)
        case .css:
            return exportCSS(for: palette)
        case .rgb:
            return exportRGB(for: palette)
        }
    }

    private func exportHex(for palette: PaletteCandidate) -> String {
        [
            "HueBridge Style Card — \(palette.template.rawValue)",
            "",
            "Background:        \(hexFormatter.hexString(for: palette.background))",
            "Text:              \(hexFormatter.hexString(for: palette.text))",
            "Accent:            \(hexFormatter.hexString(for: palette.accent))",
            "Button Background: \(hexFormatter.hexString(for: palette.buttonBackground))",
            "Button Text:       \(hexFormatter.hexString(for: palette.buttonText))"
        ].joined(separator: "\n")
    }

    private func exportCSS(for palette: PaletteCandidate) -> String {
        [
            "/* HueBridge — \(palette.template.rawValue) */",
            ":root {",
            "  --color-background: \(hexFormatter.hexString(for: palette.background));",
            "  --color-text: \(hexFormatter.hexString(for: palette.text));",
            "  --color-accent: \(hexFormatter.hexString(for: palette.accent));",
            "  --color-button-bg: \(hexFormatter.hexString(for: palette.buttonBackground));",
            "  --color-button-text: \(hexFormatter.hexString(for: palette.buttonText));",
            "}"
        ].joined(separator: "\n")
    }

    private func exportRGB(for palette: PaletteCandidate) -> String {
        func rgb(_ c: RGBA) -> String {
            "rgb(\(Int(round(c.red * 255))), \(Int(round(c.green * 255))), \(Int(round(c.blue * 255))))"
        }
        return [
            "HueBridge Style Card — \(palette.template.rawValue)",
            "",
            "Background:        \(rgb(palette.background))",
            "Text:              \(rgb(palette.text))",
            "Accent:            \(rgb(palette.accent))",
            "Button Background: \(rgb(palette.buttonBackground))",
            "Button Text:       \(rgb(palette.buttonText))"
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

    #if canImport(UIKit)
    @MainActor
    func renderPosterImage() -> UIImage? {
        guard let palette = selectedPalette else { return nil }
        let exportView = ExportablePoster(
            palette: palette,
            content: posterContent,
            posterSize: posterSize
        )
        let renderer = ImageRenderer(content: exportView)
        renderer.scale = 3.0
        return renderer.uiImage
    }
    #endif

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

        undoStack.append(candidates[index])

        var palette = candidates[index]
        update(&palette)
        candidates[index] = palette
    }
}
