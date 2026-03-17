# Saint Charbel Mobile

[![Platform: iOS](https://img.shields.io/badge/iOS-17%2B-0A84FF?logo=apple&logoColor=white)](native-ios/)
[![Platform: Android](https://img.shields.io/badge/Android-8%2B-3DDC84?logo=android&logoColor=white)](native-android/)
[![CI](https://github.com/jnrahme/MobileMarSharbel/actions/workflows/ci.yml/badge.svg?branch=develop)](https://github.com/jnrahme/MobileMarSharbel/actions/workflows/ci.yml)
[![Swift](https://img.shields.io/badge/Swift-5-F05138?logo=swift&logoColor=white)](native-ios/)
[![Kotlin](https://img.shields.io/badge/Kotlin-2.0.21-7F52FF?logo=kotlin&logoColor=white)](native-android/)

**Saint Charbel for prayer, story, and daily stillness.** This repo contains the native iPhone and Android companion for `marsharbel.com`: a child-friendly Saint Charbel storybook, a guided Rosary companion with daily mystery sets, and core prayer texts in one focused mobile experience.

**Current gallery is iPhone-first.** Android store-ready screenshots are the next capture pass so both storefronts can tell the same story.

## App Experience

<p align="center">
  <img src="docs/assets/app/ios/home.png" width="180" alt="Saint Charbel iPhone home screen" />
  <img src="docs/assets/app/ios/story-reader.png" width="180" alt="Saint Charbel iPhone story reader screen" />
  <img src="docs/assets/app/ios/rosary-hub.png" width="180" alt="Saint Charbel iPhone rosary hub screen" />
  <img src="docs/assets/app/ios/rosary-set.png" width="180" alt="Saint Charbel iPhone luminous mysteries screen" />
</p>
<p align="center"><em>iPhone flow: home → narrated storybook → daily Rosary guidance → mystery set detail.</em></p>

## What The App Does

- Opens with a calm home screen that routes directly into the storybook or the Rosary flow.
- Keeps Saint Charbel content close to the website while presenting it in a more focused native mobile experience.
- Uses the same live media library for story artwork, narration, and guided Rosary audio.

## Story Experience

- The story section behaves like a simple children's bookshelf instead of a dense article list.
- Opening Saint Charbel's book leads into a swipeable reader with large artwork, short page copy, and narration that can continue forward from the current page.
- The content model is reusable, so future saints can be added as new books instead of reworking the reader architecture.

## Rosary Experience

- The Rosary tab recommends the mystery set for today first, so the user does not have to remember the schedule.
- Each mystery set opens into a practical prayer path with mystery summaries, spiritual fruit, bead-by-bead prompts, and optional guided audio.
- Core Rosary prayers stay available inside the app, which makes the experience work for personal prayer, family prayer, and catechetical use.

## Product Docs

- [`docs/index.html`](docs/index.html) is the docs landing page.
- [`docs/app-experience.html`](docs/app-experience.html) is the polished product walkthrough with the full iPhone gallery.
- [`docs/random-timer-automation-playbook.html`](docs/random-timer-automation-playbook.html) explains the automation model adopted from Igor Ganapolsky's `Random-Timer`.

## Automation Shell

This repo is also the root automation layer for the native Saint Charbel apps in:

- `native-ios/`
- `native-android/`

It is being shaped after the disciplined root-automation model used in Igor Ganapolsky's `Random-Timer` repo, but adapted to this project's actual state.

It centralizes:

- one root command surface
- CI, security, remote-health, and docs workflows
- release-readiness checks before expensive native work
- local simulator and emulator launchers
- repo guardrails for branch promotion and secret scanning

## What This Repo Does Now

- Verifies the root repo contract and automation files
- Builds and checks the iOS app from the repo root
- Builds, bundles, and lints the Android app from the repo root
- Launches the iOS app on an available simulator
- Launches the Android app on an emulator or connected device
- Runs strict local Playwright checks for repo and release-readiness contracts
- Runs release preflight checks modeled after `Random-Timer`
- Bootstraps `gitleaks` locally for root secret scanning
- Syncs iOS App Store metadata and screenshots from the CLI
- Verifies iOS App Store submission readiness through the App Store Connect API
- Supports local TestFlight upload and App Review submission through fastlane
- Enforces the `main` promotion rule: PRs into `main` must come from `develop`, `release/vX.Y.Z`, or `hotfix/vX.Y.Z`

## Automation Surface

The root [`Makefile`](Makefile) is the canonical entrypoint.

### Quick Verification

```bash
make verify
make verify-full
```

### Release Readiness

```bash
make preflight-release
make store-access-check
make security-gitleaks
make ios-store-assets
make ios-metadata-sync
make ios-release-build
make ios-asc-ready
make ios-testflight
make ios-submit-review-dry
make ios-submit-review
```

### Local App Launch

```bash
make run-ios-sim
make run-android-emulator
make run-android-device
```

### Local Smoke Layers

```bash
make maestro-ios
make maestro-android
make playwright-verify-local
make playwright-verify-strict
make agent-browser-install
make agent-browser-open-asc
make agent-browser-open-play
make agent-browser-state-save
ANCHOR_API_KEY=... make anchor-smoke
```

### Other Useful Commands

```bash
make help
make verify-repo
make remote-health
make install-hooks
make print-blockers
```

## Current Workflow Layer

Root GitHub workflows currently cover:

- `CI`
  Repo contract, CLI surface, Playwright strict local checks, iOS health, Android health
- `Security`
  Root `gitleaks` scan and dependency review
- `Native Release Readiness`
  Artifact-oriented iOS and Android release builds after preflight
- `iOS Metadata Sync`
  Manual App Store metadata and screenshot upload via fastlane
- `iOS Submit Review`
  Manual App Store readiness gate and submit-for-review flow via fastlane + App Store Connect API
- `Remote Dependency Health`
  Scheduled checks for website, story, and audio dependencies
- `Docs Site`
  Docs publishing scaffold for `docs/`
- `Enforce Main Promotion Source`
  Guardrail for PRs targeting `main`

## Release Guardrails Added

These are the main `Random-Timer`-style quick wins already wired:

- [`scripts/preflight-release.sh`](scripts/preflight-release.sh)
  Checks version alignment, key repo files, icons, privacy manifest, and release-readiness documentation before deeper release work
- [`scripts/check_store_access.py`](scripts/check_store_access.py)
  Read-only credential check path for Google Play and App Store Connect
- [`scripts/sync_ios_store_assets.sh`](scripts/sync_ios_store_assets.sh)
  Exports App Store-sized screenshots into `native-ios/fastlane/screenshots/en-US`
- [`scripts/asc_verify_ready.py`](scripts/asc_verify_ready.py)
  Hard App Store Connect readiness gate for screenshots, pricing, review contact info, privacy URL, and attached build state
- [`scripts/ios-submit-review.sh`](scripts/ios-submit-review.sh)
  One CLI flow to sync assets, upload metadata, verify readiness, and submit for review
- [`scripts/validate_release_branch.py`](scripts/validate_release_branch.py)
  Validates which branches may promote into `main`
- [`scripts/hygiene-check.sh`](scripts/hygiene-check.sh)
  Repo hygiene pass for tracked artifacts and automation contract drift
- [`scripts/ensure-gitleaks.sh`](scripts/ensure-gitleaks.sh)
  Makes the root secret-scan command usable on a fresh machine

## Repository Structure

- `native-ios/`
  Native SwiftUI app, app-level health checks, and iOS delivery docs
- `native-android/`
  Native Android app, app-level health checks, and Android delivery docs
- `scripts/`
  Root verification, launch, release, and guardrail scripts
- `tests/playwright/`
  Local deterministic contract checks for repo and release-readiness rules
- `.maestro/`
  Minimal installed-build smoke flows
- `docs/`
  Playbook, roadmap, release automation notes, and user follow-up docs
- `.github/workflows/`
  Root automation for CI, security, release-readiness, docs, and policy enforcement

## What Still Needs Platform Access

This repo is not yet the full `Random-Timer` operations stack. The main blocked items are still account- and store-side:

- App Store Connect credentials and access
- Google Play service account credentials and app access
- Android signing assets and `keystore.properties`
- Store-console browser verification
- CI signing assets if you want fully unattended GitHub-hosted TestFlight uploads
- iPad App Store screenshots while the iOS target remains universal (`TARGETED_DEVICE_FAMILY = "1,2"`)

See:

- [`docs/user-intervention-todo.md`](docs/user-intervention-todo.md)
- [`docs/release-automation.md`](docs/release-automation.md)
- [`docs/plans/2026-03-12-mobile-automation-roadmap.md`](docs/plans/2026-03-12-mobile-automation-roadmap.md)
- [`docs/random-timer-automation-playbook.html`](docs/random-timer-automation-playbook.html)

## What Is Not Copied Yet From Random-Timer

The repo does **not** yet include most of Igor's larger ops layer, including:

- App Store / Play publish-and-verify automation
- screenshot reset tooling
- store-console browser checks
- device-test workflow depth
- project/status automation
- growth, attribution, ASO, analytics, and content workflows

That work should come later, after credentials, store access, and release ownership are in place.
