# Release Automation

This repo now follows the same automation shape we are borrowing from `IgorGanapolsky/Random-Timer`, adapted to the Saint Charbel apps:

- one root `Makefile` command surface
- one release preflight gate before expensive native builds
- one local simulator/emulator launch path per platform
- one minimal Maestro smoke layer for installed builds
- one repo hygiene pass and one secret-scan install path

## Canonical commands

```bash
make verify
make verify-full
make preflight-release
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

## What is intentionally still blocked

- App Store Connect upload automation
- Google Play publishing automation
- Fastlane metadata sync and screenshot inventory
- authenticated store-console browser checks

Those items still require the credentials and store configuration listed in `docs/user-intervention-todo.md`.
