# Saint Charbel Android

Native Android companion app for `marsharbel.com`, built with Jetpack Compose and designed to match the current iOS experience as closely as possible.

## What is in this repo

- Native Android app in `app/`
- Child-friendly Saint Charbel storybook with swipe reading and streamed narration
- Rosary experience with mystery sets, meditation beads, prayer texts, and guided audio
- In-app remote dependency health check for website, artwork, and audio services
- GitHub Actions health check workflow for build verification

## Product goals

- Keep the Android app visually aligned with the shipped iOS design language
- Reuse the same live content sources from `marsharbel.com`
- Stay lightweight by streaming story art and audio instead of bundling large media
- Keep the architecture ready for future saint stories without rewriting the reader

## Tech stack

- Kotlin
- Jetpack Compose
- Navigation Compose
- Media3 ExoPlayer
- Coil
- Gradle Kotlin DSL

## Project structure

- `app/src/main/java/com/jnrahme/androidsaintcharbel/app`
  Android app shell and navigation graph
- `app/src/main/java/com/jnrahme/androidsaintcharbel/core`
  Shared models, theme, audio, health checks, and reusable UI
- `app/src/main/java/com/jnrahme/androidsaintcharbel/features`
  Home, Story, and Rosary feature surfaces
- `scripts/healthcheck.sh`
  Local verification script for debug, release, bundle, lint, and remote media checks
- `.github/workflows/`
  CI build and release automation

## Requirements

- macOS or Linux
- JDK 17
- Android SDK with API 35
- Android Build Tools 35

## Local development

```bash
./gradlew assembleDebug
adb install -r app/build/outputs/apk/debug/app-debug.apk
adb shell monkey -p com.jnrahme.androidsaintcharbel.debug -c android.intent.category.LAUNCHER 1
```

## Verification

Run the full local health check:

```bash
./scripts/healthcheck.sh
```

That command verifies:

- `assembleDebug`
- `assembleRelease`
- `bundleRelease`
- `lint`
- live website, story image, story narration, and rosary audio endpoints

## Release signing

For signed release builds, create `keystore.properties` in the repo root:

```properties
storeFile=/absolute/path/to/saint-charbel-upload.keystore
storePassword=...
keyAlias=...
keyPassword=...
```

Without `keystore.properties`, the repo still builds release artifacts locally for verification, but final Play Store upload should use a real upload key.

## GitHub Actions

- `healthcheck.yml`
  Runs the full Android verification workflow on pushes and pull requests
- `release.yml`
  Builds release artifacts and optionally signs them when keystore secrets are configured

Expected secrets for signed release automation:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

## Deployment notes

Before shipping to Google Play:

1. Provide a production upload keystore.
2. Review privacy policy and Play Console data safety disclosures.
3. Test story narration and rosary audio on at least one physical Android device.
4. Review app screenshots, icon presentation, and tablet behavior.
5. Upload the release AAB from `app/build/outputs/bundle/release/`.

## Remote dependencies

This app currently depends on live content hosted at:

- `https://marsharbel.com`
- `https://marsharbel.com/media/storybook/images`
- `https://marsharbel.com/media/storybook/en-elevenlabs`
- `https://marsharbel.com/media/rosary`

If those endpoints change, story and rosary media playback will be affected until the manifests are updated.

