//
//  HueBridgeRootView.swift
//  HueBridge
//
//  Created by 梁航川 on 2026/2/21.
//


import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct HueBridgeRootView: View {
    @StateObject private var viewModel = HueBridgeViewModel()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            AppBackdrop(stylePreset: viewModel.stylePreset)
                .ignoresSafeArea()

            content
                .frame(maxWidth: 820)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .animation(
                    reduceMotion ? nil : .spring(duration: 0.42, bounce: 0.04),
                    value: viewModel.stage
                )
        }
        .sheet(isPresented: $viewModel.showAbout) {
            AboutView(stylePreset: $viewModel.stylePreset)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.stage {
        case .welcome:
            WelcomeView(
                stylePreset: viewModel.stylePreset,
                startAction: viewModel.startExperience,
                aboutAction: { viewModel.showAbout = true }
            )
            .transition(stageTransition)
        case .gallery:
            PaletteGalleryView(viewModel: viewModel)
                .transition(stageTransition)
        case .detail:
            PaletteDetailView(viewModel: viewModel)
                .transition(stageTransition)
        case .result:
            ResultCardView(viewModel: viewModel)
                .transition(stageTransition)
        }
    }

    private var stageTransition: AnyTransition {
        guard !reduceMotion else { return .opacity }
        return .asymmetric(
            insertion: .opacity.combined(with: .move(edge: .trailing)),
            removal: .opacity.combined(with: .move(edge: .leading))
        )
    }
}

private struct AppBackdrop: View {
    let stylePreset: StylePreset

    var body: some View {
        ZStack {
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            AngularGradient(
                colors: accentColors,
                center: .topTrailing
            )
            .blendMode(.softLight)
            .opacity(stylePreset == .classicFlat ? 0.22 : 0.34)

            Circle()
                .fill(Color.white.opacity(stylePreset == .classicFlat ? 0.06 : 0.14))
                .frame(width: 260, height: 260)
                .offset(x: -110, y: -280)

            Ellipse()
                .fill(Color.white.opacity(stylePreset == .clearGlass ? 0.09 : 0.07))
                .frame(width: 340, height: 220)
                .rotationEffect(.degrees(-20))
                .offset(x: -120, y: 220)
                .blur(radius: 4)

            Circle()
                .fill(Color.white.opacity(stylePreset == .clearGlass ? 0.12 : 0.08))
                .frame(width: 300, height: 300)
                .offset(x: 150, y: 270)
        }
    }

    private var gradientColors: [Color] {
        switch stylePreset {
        case .frostedGlass:
            return [
                Color(red: 0.83, green: 0.90, blue: 0.99),
                Color(red: 0.93, green: 0.95, blue: 1.0),
                Color(red: 0.86, green: 0.94, blue: 0.91)
            ]
        case .clearGlass:
            return [
                Color(red: 0.80, green: 0.93, blue: 0.96),
                Color(red: 0.92, green: 0.97, blue: 0.98),
                Color(red: 0.87, green: 0.91, blue: 0.99)
            ]
        case .classicFlat:
            #if canImport(UIKit)
            return [
                Color(uiColor: .systemGroupedBackground),
                Color(uiColor: .secondarySystemGroupedBackground)
            ]
            #else
            return [
                Color(red: 0.95, green: 0.95, blue: 0.96),
                Color(red: 0.90, green: 0.91, blue: 0.93)
            ]
            #endif
        }
    }

    private var accentColors: [Color] {
        switch stylePreset {
        case .frostedGlass:
            return [
                Color(red: 0.46, green: 0.66, blue: 0.99),
                Color(red: 0.30, green: 0.84, blue: 0.73),
                .clear
            ]
        case .clearGlass:
            return [
                Color(red: 0.27, green: 0.78, blue: 0.91),
                Color(red: 0.36, green: 0.57, blue: 0.97),
                .clear
            ]
        case .classicFlat:
            return [
                Color.black.opacity(0.15),
                Color.black.opacity(0.03),
                .clear
            ]
        }
    }
}
