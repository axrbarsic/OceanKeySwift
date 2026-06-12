# OceanKeySwift

Native SwiftUI/iOS rewrite of OceanKey, a hotel housekeeping workflow app.

This repository is the Apple-native track for the app. The Flutter project is
kept separately as a behavior reference and fallback while the native iOS app
reaches full parity.

## What It Does

- Builds a daily housekeeping work session from selected carts, floors, rooms,
  and territories.
- Tracks room status, room tasks, VIP state, schedules, notes, media, cart
  consumables, and history.
- Uses SwiftUI, Observation, SwiftData, AVFoundation, Speech, UserNotifications,
  SpriteKit, and other native Apple APIs.
- Keeps the current app local-first. CloudKit/iCloud support is planned behind
  the existing repository boundary.

## Requirements

- macOS with Xcode installed.
- XcodeGen (`brew install xcodegen`).
- An Apple ID for local device signing.

You do not need a paid Apple Developer Program membership to build the app for
your own iPhone through Xcode's Personal Team signing. App Store distribution,
TestFlight, Push Notifications, and some iCloud/CloudKit capabilities require
Apple's paid Developer Program.

## Build

```sh
xcodegen generate
xcodebuild build \
  -project OceanKeySwift.xcodeproj \
  -scheme OceanKeySwift \
  -configuration Debug \
  -destination 'generic/platform=iOS'
```

To install on your own iPhone from Xcode, open `OceanKeySwift.xcodeproj`, select
your Apple ID team, and change the bundle identifier from
`com.alex.oceankey.swift` to one that belongs to you.

## Tests

```sh
xcodegen generate
xcodebuild test \
  -project OceanKeySwift.xcodeproj \
  -scheme OceanKeySwift \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'
```

## Repository Notes

- Margaritaville is a separate app and is not mixed back into this project.
- Generated DeepSeek/AI visual experiment code may exist in the codebase, but
  hidden or disabled UI is kept out of the production settings unless explicitly
  re-enabled.
- Do not commit local secrets, provisioning profiles, or personal signing files.

## License

MIT. See `LICENSE`.
