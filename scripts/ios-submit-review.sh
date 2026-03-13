#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ios-submit-review.sh [--version <X.Y.Z>] [--locale <locale>] [--dry-run] [--min-ipad <count>] [--min-iphone <count>]

Runs the Saint Charbel iOS App Store submission flow from CLI:
  1. sync screenshots into native-ios/fastlane/screenshots
  2. upload metadata and screenshots with fastlane deliver
  3. verify App Store Connect readiness via API
  4. optionally submit the version for review
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION=""
LOCALE="en-US"
DRY_RUN=0
MIN_IPHONE=1
MIN_IPAD=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version) VERSION="$2"; shift 2 ;;
    --locale) LOCALE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --min-iphone) MIN_IPHONE="$2"; shift 2 ;;
    --min-ipad) MIN_IPAD="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

if [[ -z "$VERSION" ]]; then
  VERSION="$(sed -n 's/.*MARKETING_VERSION = \([^;]*\);/\1/p' "$ROOT_DIR/native-ios/SaintCharbelApp.xcodeproj/project.pbxproj" | head -1)"
fi

if [[ -z "$VERSION" ]]; then
  echo "Could not determine MARKETING_VERSION from native-ios/SaintCharbelApp.xcodeproj/project.pbxproj" >&2
  exit 1
fi

bash "$ROOT_DIR/scripts/sync_ios_store_assets.sh" --locale "$LOCALE"
bash "$ROOT_DIR/scripts/ios-fastlane.sh" ios metadata version:"$VERSION"

bash "$ROOT_DIR/scripts/store-python.sh" "$ROOT_DIR/scripts/asc_verify_ready.py" \
  --version "$VERSION" \
  --locale "$LOCALE" \
  --min-iphone "$MIN_IPHONE" \
  --min-ipad "$MIN_IPAD"

if [[ "$DRY_RUN" == "1" ]]; then
  echo "Dry run complete. Submission was not triggered."
  exit 0
fi

bash "$ROOT_DIR/scripts/ios-fastlane.sh" ios submit_review version:"$VERSION"
