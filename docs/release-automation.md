# Release Automation

This repo now follows the same automation shape we are borrowing from `IgorGanapolsky/Random-Timer`, adapted to the Saint Charbel apps:

- one root `Makefile` command surface
- one release preflight gate before expensive native builds
- one local simulator/emulator launch path per platform
- one minimal Maestro smoke layer for installed builds
- one repo hygiene pass and one secret-scan install path
- one store-access checker and one main-promotion policy gate

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

## What is intentionally still blocked

- fully trusted Apple signing state until `fastlane match` has created the first distribution certificate and provisioning profile
- Google Play publishing automation
- Android metadata sync and Play release lanes (keystore + service account needed)
- authenticated store-console browser checks

Those items still require the credentials and store configuration listed in `docs/user-intervention-todo.md`.
