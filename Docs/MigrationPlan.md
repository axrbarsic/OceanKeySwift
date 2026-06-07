# OceanKey Native iOS Migration Plan

## Decision

OceanKeySwift is a separate native iOS rewrite track for OceanKey. The Flutter
application remains the working fallback until the native app reaches practical
feature parity.

Android and Web are frozen for now. New work should optimize for iPhone first:
SwiftUI, native iOS performance tools, Apple platform storage, and real-device
verification.

## Current Baseline

- Project path: `/Users/alex/Developer/OceanKeySwift`
- App name: `OceanKey Swift`
- Bundle identifier: `com.alex.oceankey.swift`
- Minimum iOS: 17.0
- UI foundation: SwiftUI
- State foundation: Observation
- Project generation: XcodeGen through `project.yml`

The bundle identifier is intentionally different from the existing Flutter app
so the native app can be installed side by side when a provisioning profile is
available.

## Migration Phases

1. Native shell and summary screen
   - Build a small but real SwiftUI shell.
   - Port the main room list screen first.
   - Keep visual effects behind simple, measurable native rendering paths.

2. Domain parity
   - Port room status, task buttons, VIP state, timers, cart sections, and room
     history as domain data before adding complex UI.
   - Keep domain logic testable without SwiftUI.

3. Local-first persistence
   - Add a local repository as the source of truth.
   - Store room state, milestone timestamps, notes, cart notes, and local media
     metadata.
   - Keep media files local by default.

4. Apple-first sync
   - Evaluate CloudKit/iCloud as the primary iPhone-to-iPhone sync path.
   - Preserve idempotent local-first behavior: local edits must not disappear
     because an older cloud snapshot arrives.
   - Firebase can stay as a migration bridge only if needed.

5. Notes and media
   - Port voice notes with transcription.
   - Port photo and video capture with native AVFoundation/PhotosUI paths.
   - Build thumbnail and full-screen preview flows for vertical media first.

6. Diagnostics and performance
   - Keep frame/performance telemetry from the start.
   - Treat 120 Hz smoothness as the target on supported iPhones.
   - Test on real devices before considering visual effects done.

7. Cutover
   - Install OceanKeySwift side by side while Flutter remains production-safe.
   - Move the production bundle identifier only after the native app is stable
     enough to replace the Flutter app.

## Signing Note

The current Mac has an Apple Development certificate but no local provisioning
profiles. Installing `com.alex.oceankey.swift` on a physical iPhone requires an
Apple account/profile in Xcode or a matching `.mobileprovision` file.

