# User Intervention TODO

These items cannot be finished locally without your accounts or platform permissions.

## 1. Confirm repo settings

- Confirm the default branch policy if you want something other than `main` + `develop`.
- Confirm whether GitHub Pages should remain enabled for `docs/`.

## 2. Add GitHub secrets

- `APPSTORE_PRIVATE_KEY`
- `APPSTORE_KEY_ID`
- `APPSTORE_ISSUER_ID`
- `GOOGLE_PLAY_JSON_KEY`
- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

Optional later:

- Playwright auth-state secrets for store-console checks
- analytics / crash reporting credentials

## 3. Configure GitHub settings

- Branch protection
- Required checks
- Environment protection rules
- Optional Pages environment approval rules

## 4. Give store/platform access when needed

- App Store Connect access
- Google Play Console access
- Android signing assets
- Apple signing / provisioning strategy

## 5. Approve later automation only when ready

- Maestro flows
- Store-console browser verification
- Growth/ASO/attribution loops
- Project board automation
