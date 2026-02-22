//
//  PaletteGenerator.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import Foundation

struct PaletteGenerator {
    private let contrastService = ContrastService()

    func generate(base: RGBA) -> [PaletteCandidate] {
        [
            airyPoster(base: base),
            nightPoster(base: base),
            neutralStudio(base: base),
            boldPoster(base: base),
            socialCard(base: base)
        ]
    }

    private func airyPoster(base: RGBA) -> PaletteCandidate {
        let background = base
            .mixed(with: .white, amount: 0.84)
            .adjusting(brightness: 0.06, saturation: -0.18)
        let accent = base.adjusting(brightness: -0.08, saturation: 0.08)
        let text = contrastService.bestTextColor(on: background)
        let buttonBackground = accent.mixed(with: .black, amount: 0.08)
        let buttonText = contrastService.bestTextColor(on: buttonBackground)

        return PaletteCandidate(
            template: .airyPoster,
            background: background,
            text: text,
            accent: accent,
            buttonBackground: buttonBackground,
            buttonText: buttonText,
            guidance: [
                "Use for event posters and classroom announcements.",
                "Keep headlines in Accent and body text in Text color.",
                "Reserve button color for one clear call to action."
            ]
        )
    }

    private func nightPoster(base: RGBA) -> PaletteCandidate {
        let background = base
            .mixed(with: .black, amount: 0.74)
            .adjusting(brightness: -0.03, saturation: -0.06)
        let accent = base
            .mixed(with: .white, amount: 0.32)
            .adjusting(brightness: 0.1, saturation: 0.1)
        let text = contrastService.bestTextColor(on: background)
        let buttonBackground = accent.mixed(with: .black, amount: 0.22)
        let buttonText = contrastService.bestTextColor(on: buttonBackground)

        return PaletteCandidate(
            template: .nightPoster,
            background: background,
            text: text,
            accent: accent,
            buttonBackground: buttonBackground,
            buttonText: buttonText,
            guidance: [
                "Use for evening events, movie clubs, and dark-mode interfaces.",
                "Keep high contrast for longer reading sections.",
                "Pair with bold iconography for best visibility."
            ]
        )
    }

    private func neutralStudio(base: RGBA) -> PaletteCandidate {
        let neutralBase = RGBA(red: 0.95, green: 0.96, blue: 0.97)
        let background = neutralBase
            .mixed(with: base, amount: 0.06)
            .adjusting(brightness: 0.01, saturation: -0.2)
        let accent = base.adjusting(brightness: -0.03, saturation: 0.04)
        let text = contrastService.bestTextColor(on: background)
        let buttonBackground = accent.mixed(with: .black, amount: 0.15)
        let buttonText = contrastService.bestTextColor(on: buttonBackground)

        return PaletteCandidate(
            template: .neutralStudio,
            background: background,
            text: text,
            accent: accent,
            buttonBackground: buttonBackground,
            buttonText: buttonText,
            guidance: [
                "Use for handouts, educational apps, and portfolio cards.",
                "Neutral backgrounds reduce visual fatigue during reading.",
                "Accent and button tones should guide attention sparingly."
            ]
        )
    }

    private func boldPoster(base: RGBA) -> PaletteCandidate {
        // Saturated background keeping the base hue prominent
        let background = base
            .adjusting(brightness: 0.05, saturation: 0.15)
            .mixed(with: .white, amount: 0.10)
        let accent = base
            .mixed(with: .white, amount: 0.70)
            .adjusting(brightness: 0.15, saturation: -0.10)
        let text = contrastService.bestTextColor(on: background)
        let buttonBackground = RGBA.white.mixed(with: base, amount: 0.12)
        let buttonText = contrastService.bestTextColor(on: buttonBackground)

        return PaletteCandidate(
            template: .boldPoster,
            background: background,
            text: text,
            accent: accent,
            buttonBackground: buttonBackground,
            buttonText: buttonText,
            guidance: [
                "Use for high-energy events, concerts, and sports posters.",
                "The vivid background grabs attention — keep text brief.",
                "White button stands out against the saturated base."
            ]
        )
    }

    private func socialCard(base: RGBA) -> PaletteCandidate {
        // Warm, approachable tones for social media cards
        let warmNeutral = RGBA(red: 0.98, green: 0.96, blue: 0.93)
        let background = warmNeutral
            .mixed(with: base, amount: 0.08)
            .adjusting(brightness: 0.02, saturation: -0.08)
        let accent = base.adjusting(brightness: -0.05, saturation: 0.12)
        let text = contrastService.bestTextColor(on: background)
        let buttonBackground = accent.mixed(with: .black, amount: 0.05)
        let buttonText = contrastService.bestTextColor(on: buttonBackground)

        return PaletteCandidate(
            template: .socialCard,
            background: background,
            text: text,
            accent: accent,
            buttonBackground: buttonBackground,
            buttonText: buttonText,
            guidance: [
                "Use for Instagram stories, LinkedIn posts, and social banners.",
                "Warm neutrals feel approachable and modern on feeds.",
                "Keep the accent for one key visual element."
            ]
        )
    }
}
