# Release Automation

This repo now follows the same automation shape we are borrowing from `IgorGanapolsky/Random-Timer`, adapted to the Saint Charbel apps:

- one root `Makefile` command surface
- one release preflight gate before expensive native builds
- one local simulator/emulator launch path per platform
- one minimal Maestro smoke layer for installed builds
- one repo hygiene pass and one secret-scan install path
- one store-access checker and one main-promotion policy gate
- one iOS fastlane path for TestFlight, metadata sync, and submit-for-review
- one App Store Connect readiness gate for screenshots, privacy URL, pricing, and review contact info
- one optional browser-automation path for store-console experiments

## Canonical commands

```bash
make verify
make verify-full
make preflight-release
make store-access-check
make run-ios-sim
make run-android-emulator
make maestro-ios
make maestro-android
make security-gitleaks
make ios-store-assets
make ios-metadata-sync
make ios-release-build
make ios-asc-ready
make ios-asc-poll
make ios-testflight
make ios-submit-review-dry
make ios-submit-review
```

## What is wired now

- iOS simulator build, install, and launch from the root repo
- Android emulator or device debug install and launch from the root repo
- release preflight checks for versioning, icons, privacy manifest, workflow presence, and native README delivery notes
- root CLI smoke coverage for the main automation entrypoints
- bootstrapped `gitleaks` install so the secret-scan command works on a fresh machine
- read-only `scripts/check_store_access.py` plumbing for official App Store Connect and Google Play credential checks
- `scripts/validate_release_branch.py` plus `.github/workflows/enforce-develop-to-main.yml` for main-promotion policy enforcement
- iOS `fastlane match` storage, TestFlight upload lanes, and App Store metadata scaffolding
- `native-ios/fastlane/` with Saint Charbel metadata, App Store URLs, and fastlane lanes for TestFlight, metadata sync, and App Review submission
- `scripts/sync_ios_store_assets.sh` for deterministic App Store screenshot export
- `scripts/asc_verify_ready.py` and `scripts/asc_poll_version_state.py` for App Store Connect API gating and state polling
- `.github/workflows/ios-metadata-sync.yml` and `.github/workflows/ios-submit-review.yml` for manual dispatch from GitHub Actions
- optional `agent-browser` and Anchor entrypoints for store-console automation experiments

## New Laptop Bootstrap

If you clone this repo onto another Mac, the repo now carries the local iOS automation surface. The remaining prerequisites are machine-side Apple signing state, not missing repo files.

Suggested order:

```bash
make cli-smoke
make ios-store-assets
APPLE_DEVELOPER_TEAM_ID=<APPLE_TEAM_ID> make ios-release-build
IOS_VERSION=<APP_STORE_VERSION> make ios-asc-ready
IOS_VERSION=<APP_STORE_VERSION> make ios-submit-review-dry
```

Notes:

- `scripts/ios-fastlane.sh` installs Bundler gems into `native-ios/vendor/bundle` automatically.
- `scripts/store-python.sh` bootstraps a local Python venv in `.tools/store-python` for the App Store / Play API helpers.
- `make ios-release-build` still requires a valid Xcode Apple account login and provisioning profile for `com.rammyinn.saintcharbel`.
- make sure `MARKETING_VERSION` in Xcode matches the App Store Connect version you plan to submit.

## What is intentionally still blocked

- fully trusted Apple signing state until `fastlane match` has created the first distribution certificate and provisioning profile
- Google Play publishing automation
- Android metadata sync and Play release lanes (keystore + service account needed)
- authenticated store-console browser checks without fresh console auth state
- unattended GitHub-hosted TestFlight build uploads until Apple signing assets are added
- iPad screenshot coverage while the iOS target remains universal

Those items still require the credentials and store configuration listed in `docs/user-intervention-todo.md`.

## Browser automation tooling

For local store-console automation experiments, this repo now exposes optional `agent-browser` and Anchor entrypoints:

```bash
make agent-browser-install
make agent-browser-open-asc
make agent-browser-open-play
make agent-browser-state-save
ANCHOR_API_KEY=... make anchor-smoke
```

See `tests/playwright/README.md` for auth-state handling and task overrides.
