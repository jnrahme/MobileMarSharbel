# Fastlane for Saint Charbel Android

Lanes:
- `fastlane android metadata` – sync metadata/screenshots with Google Play (uses `upload_to_play_store`).
- `fastlane android release` – builds the release AAB (`./gradlew bundleRelease`) and uploads it via Play Store service account.
- `fastlane android internal` – upload to internal track for quick QA.

Requirements: `GOOGLE_PLAY_JSON_KEY`, `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
