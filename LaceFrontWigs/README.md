# LaceFrontWigs – Hybrid Virtual Wig Fitter

This repository now houses both halves of the LaceFrontWigs experience:

- **`LaceFrontWigs/`** – the SwiftUI + Vision iOS capture app that renders real-time overlays on top of the camera feed.
- **`LaceFrontApp/`** – a Vite + React "Virtual Lookbook" that mirrors the Lovable mockup and lets shoppers explore styles, tones, and accessories in the browser.

The iOS client can launch the React lookbook directly from the live view via a built-in web sheet, so stylists can capture guidance data and immediately browse curated inspiration without leaving the native app.

## Repository layout

| Path | Purpose |
| --- | --- |
| `LaceFrontWigs/` | Swift packages, SwiftUI views, Vision pipeline, and new `WebExperienceView` wrapper. |
| `LaceFrontWigs.xcodeproj/` | Xcode project for the iOS target + unit tests. |
| `LaceFrontApp/` | React + Vite Single Page App, including `src/App.tsx`, mock data, and styles. |
| `README.md` | This document – explains how to drive both sides together. |

## How the native + web flows connect

1. Launch the iOS app and position your face as usual. The overlay will surface tilt, ear-to-ear alignment, and advice based on `WigGuidelineCalculator`.
2. Tap the new **Lookbook** button to open `WebExperienceView`, which embeds a `WKWebView` pointing at the React experience (`https://review-n-zip.lovable.app` by default).
3. Optionally ship an offline build of the React app by copying its `dist/` output into `LaceFrontWigs/Resources/WebExperience`. When that folder exists, the iOS app loads the bundled HTML instead of the remote URL.

## Running the iOS capture app

**Requirements**

- macOS with Xcode 15 or newer
- iOS 17.0+ simulator (or physical device for true camera input)

**Steps**

```sh
open LaceFrontWigs.xcodeproj
```

Choose the **LaceFrontWigs** scheme and any iPhone simulator (the CI instructions below target iPhone 17 on iOS 26). Grant camera access when prompted.

## Running the React lookbook (`LaceFrontApp`)

**Requirements**: Node.js 18+ and npm 9+ (the cloud shell that generated these files does **not** include Node, so run the commands locally).

```bash
cd LaceFrontApp
npm install
npm run dev
```

Visit <http://localhost:5173> to explore the lookbook. Use `npm run build` to emit a production bundle under `dist/`.

## Embedding the web build inside the iOS app

1. Build the React app: `cd LaceFrontApp && npm run build`.
2. Copy the resulting `dist` folder into `LaceFrontWigs/Resources/WebExperience` (you can rename `dist` to `WebExperience`).
3. Rebuild the Xcode project. `WebExperienceView` will now load `Resources/WebExperience/index.html` offline, falling back to the hosted URL only if the folder is missing.

This keeps the Objective-C/Swift target purely local while sharing a single React-based marketing surface.

## iOS architecture refresher

| Layer | Purpose |
| --- | --- |
| `CameraSessionManager` | Owns `AVCaptureSession` and streams frames into Vision. |
| `FaceTrackingViewModel` | Throttles frames, runs `VNDetectFaceLandmarksRequest`, and exposes overlay state. |
| `WigGuidelineCalculator` | Converts normalized landmarks to lace-specific geometry + advice strings. |
| `GuidelineOverlayView` | Renders the hairline curve, ear-to-ear axis, center line, and temple dots. |
| `WebExperienceView` | Bridges the React lookbook inside a SwiftUI sheet with reload + offline support. |

## Testing

Run the unit tests or full UI target from Xcode, or use the CLI:

```sh
xcodebuild test \
   -project LaceFrontWigs.xcodeproj \
   -scheme LaceFrontWigs \
   -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.0.1'
```

> The command above is executed in CI to guarantee the latest iOS 17-era simulator remains green.

## Privacy

All face tracking runs on-device; video frames never leave the user’s hardware. The optional web lookbook is read-only and only consumes synthetic telemetry (tilt, offset, accessory toggles) once you wire it up to a backend.
