#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

platform="both"
layer="1"
errors=0
warnings=0

usage() {
  cat <<'EOF'
Usage: bash scripts/preflight-release.sh --platform ios|android|both [--layer 1|2]

Layer 1 validates release readiness files, versions, and metadata placeholders.
Layer 2 runs the matching native verification commands after Layer 1 passes.
EOF
}

info() {
  printf '• %s\n' "$1"
}

error() {
  printf '❌ %s\n' "$1"
  errors=$((errors + 1))
}

warn() {
  printf '⚠️  %s\n' "$1"
  warnings=$((warnings + 1))
}

check_file() {
  local rel="$1"
  if [[ ! -f "$ROOT_DIR/$rel" ]]; then
    error "Missing file: $rel"
  fi
}

check_nonempty() {
  local rel="$1"
  if [[ ! -s "$ROOT_DIR/$rel" ]]; then
    error "Missing or empty file: $rel"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform)
      platform="${2:-}"
      shift 2
      ;;
    --layer)
      layer="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ "$platform" != "ios" && "$platform" != "android" && "$platform" != "both" ]]; then
  echo "Invalid platform: $platform" >&2
  exit 2
fi

if [[ "$layer" != "1" && "$layer" != "2" ]]; then
  echo "Invalid layer: $layer" >&2
  exit 2
fi

echo "Saint Charbel Release Preflight"
echo "Platform: $platform | Layer: $layer"

echo ""
echo "Repository contract"
for rel in \
  README.md \
  docs/release-automation.md \
  docs/user-intervention-todo.md \
  .github/workflows/ci.yml \
  .github/workflows/native-release.yml \
  .github/workflows/security.yml \
  scripts/verify-ios.sh \
  scripts/verify-android.sh; do
  check_file "$rel"
done

android_version_name="$(sed -n 's/.*versionName = "\(.*\)".*/\1/p' "$ROOT_DIR/native-android/app/build.gradle.kts" | head -1)"
android_version_code="$(sed -n 's/.*versionCode = \([0-9][0-9]*\).*/\1/p' "$ROOT_DIR/native-android/app/build.gradle.kts" | head -1)"
ios_version="$(sed -n 's/.*MARKETING_VERSION = \([^;]*\);/\1/p' "$ROOT_DIR/native-ios/SaintCharbelApp.xcodeproj/project.pbxproj" | head -1)"
ios_build="$(sed -n 's/.*CURRENT_PROJECT_VERSION = \([^;]*\);/\1/p' "$ROOT_DIR/native-ios/SaintCharbelApp.xcodeproj/project.pbxproj" | head -1)"
ios_bundle_id="$(sed -n 's/.*PRODUCT_BUNDLE_IDENTIFIER = \([^;]*\);/\1/p' "$ROOT_DIR/native-ios/SaintCharbelApp.xcodeproj/project.pbxproj" | head -1)"

info "Android version: ${android_version_name:-unknown} (${android_version_code:-unknown})"
info "iOS version: ${ios_version:-unknown} (${ios_build:-unknown})"
info "iOS bundle id: ${ios_bundle_id:-unknown}"

if [[ -n "$android_version_name" && -n "$ios_version" && "$android_version_name" != "$ios_version" ]]; then
  warn "Version mismatch between Android ($android_version_name) and iOS ($ios_version)"
fi

if [[ "$platform" == "ios" || "$platform" == "both" ]]; then
  echo ""
  echo "iOS readiness"
  check_file "native-ios/SaintCharbelApp.xcodeproj/project.pbxproj"
  check_nonempty "native-ios/SaintCharbelApp/PrivacyInfo.xcprivacy"
  check_nonempty "native-ios/SaintCharbelApp/Assets.xcassets/AppIcon.appiconset/Contents.json"
  check_file "native-ios/SaintCharbelApp/Assets.xcassets/AppIcon.appiconset/icon-1024-marketing.png"
  check_nonempty "native-ios/README.md"
  check_nonempty "native-ios/fastlane/Fastfile"
  check_nonempty "native-ios/fastlane/Appfile"
  check_nonempty "native-ios/fastlane/Matchfile"
  check_nonempty "native-ios/fastlane/metadata/en-US/name.txt"
  check_nonempty "native-ios/fastlane/metadata/en-US/subtitle.txt"
  check_nonempty "native-ios/fastlane/metadata/en-US/description.txt"
  check_nonempty "native-ios/fastlane/metadata/en-US/keywords.txt"
  check_nonempty "native-ios/fastlane/metadata/en-US/release_notes.txt"
  check_nonempty "native-ios/fastlane/metadata/en-US/privacy_url.txt"
  check_nonempty "native-ios/fastlane/metadata/en-US/support_url.txt"

  if command -v plutil >/dev/null 2>&1; then
    if ! plutil -lint "$ROOT_DIR/native-ios/SaintCharbelApp/PrivacyInfo.xcprivacy" >/dev/null; then
      error "iOS privacy manifest failed plutil validation"
    fi
  else
    warn "plutil is unavailable; skipped iOS privacy manifest lint"
  fi

  if ! grep -q "Remaining Apple-Side Delivery Steps" "$ROOT_DIR/native-ios/README.md"; then
    warn "native-ios/README.md does not list Apple-side delivery steps"
  fi

  if [[ ! -d "$ROOT_DIR/native-ios/fastlane/screenshots/en-US" ]]; then
    warn "native-ios/fastlane/screenshots/en-US is missing; automated screenshot upload remains blocked"
  fi
fi

if [[ "$platform" == "android" || "$platform" == "both" ]]; then
  echo ""
  echo "Android readiness"
  check_file "native-android/app/build.gradle.kts"
  check_file "native-android/app/src/main/res/mipmap-anydpi/ic_launcher.xml"
  check_file "native-android/app/src/main/res/mipmap-anydpi/ic_launcher_round.xml"
  check_file "native-android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"
  check_nonempty "native-android/README.md"

  if ! grep -q "Release signing" "$ROOT_DIR/native-android/README.md"; then
    warn "native-android/README.md does not document release signing"
  fi

  if [[ ! -f "$ROOT_DIR/native-android/keystore.properties" ]]; then
    warn "native-android/keystore.properties is not configured; signed Play uploads remain blocked"
  fi

  if ! grep -q 'create("release")' "$ROOT_DIR/native-android/app/build.gradle.kts"; then
    error "Android release signing config is missing from app/build.gradle.kts"
  fi

  if [[ ! -d "$ROOT_DIR/native-android/fastlane" ]]; then
    warn "native-android/fastlane is not present yet; Play metadata automation is still blocked"
  fi
fi

if (( errors > 0 )); then
  echo ""
  echo "Preflight failed before build execution"
  exit 1
fi

if [[ "$layer" == "2" ]]; then
  echo ""
  echo "Layer 2 native verification"
  case "$platform" in
    ios)
      SKIP_REMOTE_CHECKS=1 bash "$ROOT_DIR/scripts/verify-ios.sh"
      ;;
    android)
      SKIP_REMOTE_CHECKS=1 bash "$ROOT_DIR/scripts/verify-android.sh"
      ;;
    both)
      SKIP_REMOTE_CHECKS=1 bash "$ROOT_DIR/scripts/verify-ios.sh"
      SKIP_REMOTE_CHECKS=1 bash "$ROOT_DIR/scripts/verify-android.sh"
      ;;
  esac
fi

echo ""
echo "Warnings: $warnings"
echo "✅ Release preflight passed"
