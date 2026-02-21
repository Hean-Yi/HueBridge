# CLAUDE.md — HueBridge

This file describes the codebase structure, development conventions, and key workflows for AI assistants working on HueBridge.

---

## Project Overview

**HueBridge** is an iOS/macOS SwiftUI application that helps users create accessible, color-vision-friendly poster palettes. The core product is a three-step guided workflow:

1. **Gallery** — Pick a base color; browse three generated palette candidates.
2. **Detail** — Validate WCAG contrast ratios; preview under color-vision deficiency (CVD) simulations; apply one-tap fixes.
3. **Result** — View and export a style card with hex values for each palette role.

Key design goals:
- Fully offline — no network calls, no external APIs.
- Zero external dependencies — only native Apple frameworks.
- Accessibility-first — WCAG 2.0 contrast thresholds enforced in-app.

---

## Technology Stack

| Concern | Choice |
|---|---|
| Language | Swift (Swift 6.2 / Xcode 26.2) |
| UI framework | SwiftUI |
| State management | Combine (`@Published` / `ObservableObject`) |
| Color APIs | UIKit (`UIColor`) for channel extraction and HSB math |
| Build tool | Xcode (native project, no SwiftPM packages) |
| External packages | None |

UIKit is conditionally imported (`#if canImport(UIKit)`) wherever platform-specific color extraction is needed. All UI remains in SwiftUI.

---

## Repository Layout

```
HueBridge/
├── HueBridge/                   # All Swift source
│   ├── HueBridgeApp.swift       # @main entry point → HueBridgeRootView
│   ├── ContentView.swift        # Legacy Xcode template stub (unused)
│   ├── App/
│   │   └── HueBridgeViewModel.swift   # Central ObservableObject
│   ├── Models/
│   │   ├── RGBA.swift
│   │   ├── ColorToken.swift
│   │   ├── StylePreset.swift
│   │   ├── VisionMode.swift
│   │   ├── BaseColorPreset.swift
│   │   ├── PaletteTemplate.swift      # PaletteTemplate enum + PaletteCandidate struct
│   │   └── CheckItem.swift
│   ├── Services/
│   │   ├── ContrastService.swift
│   │   ├── PaletteGenerator.swift
│   │   ├── CVDService.swift
│   │   └── HexFormatter.swift
│   ├── Views/
│   │   ├── WelcomeView.swift
│   │   ├── PaletteGalleryView.swift
│   │   ├── PaletteDetailView.swift
│   │   ├── ResultCardView.swift
│   │   ├── AboutView.swift
│   │   └── CheckRowView.swift
│   ├── Components/
│   │   ├── GlassSurface.swift
│   │   ├── PaletteCard.swift
│   │   ├── BadgeView.swift
│   │   └── PosterPreview.swift
│   └── Assets.xcassets/
└── HueBridge.xcodeproj/
```

`ContentView.swift` is a dead file from the Xcode template. Do not route to it.

---

## Architecture

### State machine (`HueBridgeViewModel`)

`HueBridgeViewModel` (`App/HueBridgeViewModel.swift`) is the single source of truth. It owns:

- `stage: Stage` — drives which view is shown (`.welcome`, `.gallery`, `.detail`, `.result`).
- `baseColor: RGBA` — the user-selected input color.
- `candidates: [PaletteCandidate]` — three generated palettes, recomputed whenever `baseColor` changes.
- `selectedPaletteID: PaletteTemplate?` — which candidate is in focus for detail/result.
- `stylePreset: StylePreset` — UI chrome style.
- `visionMode: VisionMode` — active CVD preview filter.

Navigation is done exclusively by mutating `stage` on the ViewModel — never by pushing SwiftUI `NavigationLink` paths directly from views.

### Data flow

```
User input
    │
    ▼
HueBridgeViewModel          ← single ObservableObject injected via .environmentObject
    │
    ├─ PaletteGenerator      → produces [PaletteCandidate]
    ├─ ContrastService       → WCAG ratio checks, bestTextColor()
    ├─ CVDService            → per-pixel simulation for previews
    └─ HexFormatter          → export strings
```

Views read from the ViewModel via `@EnvironmentObject` and call named methods (`chooseBaseColor(_:)`, `openDetails(for:)`, `makeTextDarker()`, etc.). Views never perform color math directly.

---

## Core Types

### `RGBA` (`Models/RGBA.swift`)
Custom color struct with `Double` channels in `[0, 1]`. All channel assignments are clamped to `[0, 1]` on init. Key API:

- `mixed(with:amount:)` — linear interpolation between two colors.
- `adjusting(brightness:saturation:)` — HSB delta adjustments via UIKit.
- `color: Color` — bridging accessor to SwiftUI `Color`.
- Static: `.black`, `.white`.

### `PaletteCandidate` (`Models/PaletteTemplate.swift`)
Value type (`struct`) holding five `RGBA` roles: `background`, `text`, `accent`, `buttonBackground`, `buttonText`. Its `id` is its `PaletteTemplate` enum case, so there is always exactly one candidate per template. The `tokens` computed property returns a `[ColorToken]` array for display.

### `CheckItem` (`Models/CheckItem.swift`)
Holds a contrast check result: a label string, a measured ratio, a threshold, and a computed `isPass: Bool`. Three checks are evaluated per palette: title (≥ 3.0), body (≥ 4.5), button (≥ 4.5).

### `StylePreset` (`Models/StylePreset.swift`)
Controls the visual chrome of `GlassSurface` containers. Three cases: `.frostedGlass` (default), `.clearGlass`, `.classicFlat`. Each case vends `fillStyle`, `panelStyle`, `strokeOpacity`, `highlightOpacity`, and `shadowOpacity`.

### `VisionMode` (`Models/VisionMode.swift`)
Four cases: `.normal`, `.deuteranopia`, `.protanopia`, `.grayscale`. Used by `CVDService` and passed into `PosterPreview` for live simulation.

---

## Services

### `ContrastService` (`Services/ContrastService.swift`)
Implements WCAG 2.0 relative luminance and contrast ratio:
- `relativeLuminance(for:)` — linearizes sRGB channels (`value ≤ 0.03928 → /12.92`, else `((v+0.055)/1.055)^2.4`) then applies `0.2126·R + 0.7152·G + 0.0722·B`.
- `ratio(between:and:)` — `(lighter + 0.05) / (darker + 0.05)`.
- `bestTextColor(on:)` — returns `.black` or `.white` based on which has a higher contrast ratio against the background.

### `PaletteGenerator` (`Services/PaletteGenerator.swift`)
Generates three `PaletteCandidate` values from a single base `RGBA`:

| Template | Background strategy | Accent strategy |
|---|---|---|
| `airyPoster` | Mix 84% white, brightness +0.06, saturation −0.18 | Brightness −0.08, saturation +0.08 |
| `nightPoster` | Mix 74% black, brightness −0.03, saturation −0.06 | Mix 32% white, brightness +0.10, saturation +0.10 |
| `neutralStudio` | Near-white `(0.95, 0.96, 0.97)` mixed 6% base | Brightness −0.03, saturation +0.04 |

`buttonBackground` for all templates is the accent darkened with `mixed(with: .black, amount:)`. `text` and `buttonText` are always chosen by `ContrastService.bestTextColor(on:)`.

### `CVDService` (`Services/CVDService.swift`)
Applies Machado et al. severity-1.0 transformation matrices for protanopia and deuteranopia. Grayscale uses the BT.601 luma formula (`0.299·R + 0.587·G + 0.114·B`). The service is stateless and pure.

### `HexFormatter` (`Services/HexFormatter.swift`)
Converts `RGBA` → `#RRGGBB` hex string for export.

---

## Views & Navigation

Navigation is state-driven. `HueBridgeRootView` (or equivalent root) switches on `viewModel.stage`:

| Stage | View |
|---|---|
| `.welcome` | `WelcomeView` |
| `.gallery` | `PaletteGalleryView` |
| `.detail` | `PaletteDetailView` |
| `.result` | `ResultCardView` |

`AboutView` is presented as a sheet controlled by `viewModel.showAbout`.

### `PaletteGalleryView`
- SwiftUI `ColorPicker` for free color selection (calls `chooseBaseColor(_:)`).
- Preset buttons from `viewModel.basePresets` (calls `choosePreset(_:)`).
- Segmented picker for `StylePreset`.
- Tapping a `PaletteCard` calls `viewModel.openDetails(for:)`.

### `PaletteDetailView`
- Displays `viewModel.selectedChecks` as `CheckRowView` rows.
- `VisionMode` picker drives CVD simulation in `PosterPreview`.
- "Make Text Darker" button calls `viewModel.makeTextDarker()`.
- "Lighten Background" button calls `viewModel.lightenBackground()`.
- "Create Style Card" button is disabled until `viewModel.selectedPalettePasses` is `true`.

### `ResultCardView`
- Shows hex values for all five roles.
- "Copy Style Card" calls `viewModel.copyStyleCardToClipboard()` (UIPasteboard on iOS).
- "Start Over" calls `viewModel.restart()`.

---

## Reusable Components

### `GlassSurface`
Configurable glass-effect container. Reads `StylePreset` to determine fill, stroke, highlight, and shadow. Pass `cornerRadius` and `padding` as parameters.

### `PaletteCard`
Gallery card showing template name, a mini `PosterPreview`, and a pass/fail `BadgeView`. Used in `PaletteGalleryView`.

### `PosterPreview`
Renders a realistic poster mockup using the palette's five color roles. Accepts `compact: Bool` for thumbnail vs. full size. CVD simulation is applied per-color via `CVDService` before rendering.

### `BadgeView`
Pass/fail indicator chip. Positive variant shows a green checkmark; negative shows an orange warning. Optionally animates with a spring on appearance.

---

## Conventions

### Adding a new palette template
1. Add a case to `PaletteTemplate` enum (`Models/PaletteTemplate.swift`).
2. Implement a private generation method in `PaletteGenerator` following the existing pattern (background mixing → accent adjustments → `bestTextColor` for text roles → return `PaletteCandidate`).
3. Add the new method call to `PaletteGenerator.generate(base:)`.

### Adding a new CVD mode
1. Add a case to `VisionMode` enum (`Models/VisionMode.swift`).
2. Handle the new case in `CVDService.simulate(_:mode:)`.
3. The Picker in `PaletteDetailView` is driven by `VisionMode.allCases` — no UI change needed.

### Modifying contrast thresholds
Thresholds are defined inline in `HueBridgeViewModel.checks(for:)`. Title uses 3.0 (WCAG AA large text); body and button use 4.5 (WCAG AA normal text). Update both the threshold value and any explanatory strings in `PaletteDetailView`.

### Color math
Always work in `RGBA` (normalized `Double` channels). Never use `CGFloat`-based color APIs in model or service code — keep UIKit confined to `RGBA.init(color:)` and `RGBA.adjusting(brightness:saturation:)`. All arithmetic must be clamped to `[0, 1]` using `clamped01` or `clamped(min:max:)`.

### Platform conditionals
Wrap any UIKit-specific code in `#if canImport(UIKit) … #endif`. The project targets both iOS and macOS; macOS code paths fall back gracefully (e.g., clipboard copy is a no-op on macOS since `UIPasteboard` is absent).

### No networking
This project is deliberately offline-first. Do not add URLSession calls, third-party SDKs, or SwiftPM dependencies without explicit discussion.

---

## Build & Run

Open `HueBridge.xcodeproj` in Xcode 26 or later. Select an iOS simulator or device and press ▶. There is no `Makefile`, no `Package.swift`, and no `npm`/`yarn` step.

**Swift version**: 6.2 (set in project build settings).
**Deployment target**: iOS 16+ (SwiftUI 4 / material APIs required).
**Bundle ID**: `EDOC.HueBridge`.

---

## Testing

No formal test targets exist in the project. When adding tests:
- Create an `HueBridgeTests` target in Xcode.
- Pure logic (contrast math, palette generation, CVD matrices, hex formatting) is straightforward to unit test with `XCTest` since all services are value-type structs with no side effects.
- UI tests should focus on the stage transitions driven by `HueBridgeViewModel`.

---

## Git Workflow

- Default remote: `origin` (configured to a local proxy).
- Main integration branch: `main`.
- Claude AI works on branches prefixed `claude/`.

Commit messages should be imperative and scoped (e.g., `Add neutralStudio lightness cap`, `Fix deuteranopia matrix row ordering`).
