# MobileTest Automation Shell

This root directory is being prepared to become the GitHub-facing automation layer around the two existing native apps:

- `native-ios/`
- `native-android/`

The target state is a single repo that behaves more like Igor Ganapolsky's `Random-Timer` repo:

- one root command surface
- root CI and security workflows
- release-readiness and artifact workflows
- simulator / emulator launch commands from the repo root
- Maestro smoke scaffolding for installed native builds
- store-access and main-promotion guardrails
- docs that explain what is automated and what is still blocked on credentials or store access

## Current structure

- `native-ios/`
  Native SwiftUI app plus its existing health and release scripts
- `native-android/`
  Native Android app plus its existing health and release scripts
- `docs/`
  Automation playbook, roadmap, and handoff documentation
- `scripts/`
  Root-level verification and repo bootstrap scripts
- `tests/playwright/`
  Local contract checks for the root repo shell
- `.github/workflows/`
  Root automation that will run once this directory is pushed as a GitHub repo

## Monorepo note

This workspace has already been flattened into a single root repo shape for first push.

The previous nested git histories for `native-ios/` and `native-android/` were backed up locally outside the repo before initialization.

## Main commands

```bash
make help
make verify-repo
make verify
make verify-full
make preflight-release
make store-access-check
make run-ios-sim
make run-android-emulator
make maestro-ios
make maestro-android
make security-gitleaks
make remote-health
make playwright-verify-local
make install-hooks
```

## What works without store credentials

- repo contract validation
- iOS health/build checks
- Android health/build checks
- iOS simulator build/install/launch
- Android emulator/device build/install/launch
- release preflight checks modeled after Random-Timer
- read-only store credential check plumbing for App Store Connect and Google Play
- main-promotion workflow that enforces `develop` or versioned release branches into `main`
- Maestro smoke flow scaffolding for installed apps
- Playwright local checks for repo structure
- root CI and security workflow scaffolding
- artifact-oriented release readiness workflows

## What still needs platform intervention

See:

- `docs/user-intervention-todo.md`
- `docs/plans/2026-03-12-mobile-automation-roadmap.md`
- `docs/release-automation.md`
- `docs/random-timer-automation-playbook.html`
