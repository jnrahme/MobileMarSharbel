# Mobile Automation Bootstrap Checklist

Use this when the target GitHub repo is available.

## 1. Lock the operating model

- Decide branch model: `develop/main` or trunk-only.
- Decide release lanes: `ios-internal`, `ios-review`, `android-internal`, `android-production`.
- Decide required CI gates for merge.
- Decide the canonical human commands we want behind `make`.

## 2. Create the minimum folder contract

- `.github/workflows/`
- `scripts/`
- `tests/playwright/`
- `.maestro/`
- `docs/`

## 3. Add the first command surface

- `make verify`
- `make verify-ios`
- `make verify-android`
- `make maestro-ios`
- `make maestro-android`
- `make store-checks`

## 4. Build the first CI slice

- Android build + unit tests
- iOS build + unit tests
- Python script tests if automation scripts exist
- Security scan lane
- Artifact upload for failures and reports

## 5. Add release gates before release workflows

- `scripts/preflight-release.sh`
- `scripts/verify_release.py`
- Store metadata inventory rules
- Screenshot completeness rules
- Version parity rules

## 6. Prepare secrets before wiring workflows

- App Store Connect API key
- App Store issuer ID
- App Store key ID
- iOS signing / match secrets
- Google Play service account JSON
- Android keystore + passwords
- Analytics / crash reporting credentials
- Playwright auth-state secrets for store-console checks

## 7. Copy later, not first

- Weekly growth workflows
- ASO keyword rotation
- Paid acquisition scripts
- PhoneClaw visual validation
- Project-board metric bots

## 8. First review question when repo arrives

- Which parts are mandatory for launch, and which parts are just nice-to-have operations tooling?
