# Saint Charbel iOS App

Native SwiftUI iPhone companion for `marsharbel.com`, built around two primary experiences:

- a child-friendly Saint Charbel storybook with synced narration
- a guided Rosary companion with mystery navigation, prayer texts, and streamed audio

This repository contains the iOS app source, release automation, and delivery checks required to keep the project buildable and ready for App Store packaging.

## Product Highlights

- Native `SwiftUI` app for iPhone-first presentation
- Swipeable illustrated Saint Charbel storybook sourced from the live website media library
- Streamed story narration and Rosary mystery audio
- Home screen service-status health check for critical remote dependencies
- GitHub Actions health check and release workflow
- App Store delivery readiness with privacy manifest and export-compliance flag

## Repository Structure

- `SaintCharbelApp/`
  - SwiftUI app source, assets, privacy manifest, and shared models
- `SaintCharbelApp.xcodeproj/`
  - Xcode project configuration
- `.github/workflows/`
  - CI health check and manual release workflow
- `fastlane/`
  - Apple delivery lanes for verification, `match` signing, archive creation, TestFlight upload, and metadata sync
- `scripts/healthcheck.sh`
  - single-entry validation script for local and CI use
- `docs/plans/`
  - implementation and design notes

## Requirements

- macOS with Xcode 16 or newer
- iOS 17 SDK or newer
- network access to `https://marsharbel.com` for streamed artwork and audio

## Local Development

Open the project in Xcode:

```bash
open SaintCharbelApp.xcodeproj
```

Build from the terminal:

```bash
xcodebuild \
  -project SaintCharbelApp.xcodeproj \
  -scheme SaintCharbelApp \
  -destination 'generic/platform=iOS Simulator' \
  build
```

Build a release-style iOS archive target without signing:

```bash
xcodebuild \
  -project SaintCharbelApp.xcodeproj \
  -scheme SaintCharbelApp \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Health Check

Run the project health check locally:

```bash
./scripts/healthcheck.sh
```

The health check verifies:

- the privacy manifest is present and valid
- the app builds for iOS Simulator
- the app builds in Release configuration for iOS packaging
- the website and critical remote story/rosary media endpoints respond

If you need to skip remote endpoint checks temporarily:

```bash
SKIP_REMOTE_CHECKS=1 ./scripts/healthcheck.sh
```

## GitHub Automation

### `iOS Health Check`

Workflow: `.github/workflows/healthcheck.yml`

Runs on:

- pushes to `main`
- pull requests
- manual dispatch

It executes the same `./scripts/healthcheck.sh` script used locally.

### `Release`

Workflow: `.github/workflows/release.yml`

This manual workflow:

- runs the health check first
- builds the Release configuration
- creates a source archive artifact
- creates a GitHub Release for a `v<version>` tag

## App Store Delivery Readiness

The repository now includes baseline App Store submission readiness work:

- privacy manifest: [SaintCharbelApp/PrivacyInfo.xcprivacy](SaintCharbelApp/PrivacyInfo.xcprivacy)
- non-exempt encryption declaration in project settings
- app icon asset catalog configured in the Xcode target
- release workflow and repeatable health check
- Fastlane lanes for TestFlight and metadata delivery

## Fastlane

Install the Ruby dependencies:

```bash
bundle install
```

Common Apple delivery commands:

```bash
bundle exec fastlane ios verify
bundle exec fastlane ios build_release
bundle exec fastlane ios beta
bundle exec fastlane ios metadata
```

Configure the required environment variables before using signed delivery lanes:

- `APPLE_DEVELOPER_TEAM_ID`
- `APP_STORE_CONNECT_TEAM_ID`
- `APP_STORE_CONNECT_APPLE_ID`
- `APP_STORE_APP_IDENTIFIER`
- `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` when using Apple ID auth
- `MATCH_GIT_URL`
- `MATCH_PASSWORD`
- `MATCH_GIT_BASIC_AUTHORIZATION`

GitHub Actions now uses the same `match` flow for deterministic signing on clean macOS runners.

## Remaining Apple-Side Delivery Steps

These still need to be completed in Apple Developer / App Store Connect:

- production signing certificates and provisioning
- iPad App Store screenshots if the target stays universal
- final pricing / availability confirmation in App Store Connect
- final rollout decision after TestFlight / App Review approval

The repo now includes local fastlane and API-driven helpers for the rest:

- `bundle exec fastlane ios beta`
- `bundle exec fastlane ios metadata`
- `bundle exec fastlane ios submit_review`
- `python3 ../scripts/asc_verify_ready.py --version <X.Y.Z>`

## Remote Dependency Notes

The app intentionally streams content from `marsharbel.com` to keep the binary lightweight and aligned with the website:

- storybook illustrations
- story narration
- Rosary guided audio

If those URLs or hosting paths change, update the app manifests in:

- `SaintCharbelApp/Core/StoryCatalog.swift`
- `SaintCharbelApp/Core/AppContent.swift`

## Verification Command

For final pre-push verification, use:

```bash
./scripts/healthcheck.sh
```
