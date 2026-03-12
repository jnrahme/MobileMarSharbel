#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/SaintCharbelApp.xcodeproj"
SCHEME="SaintCharbelApp"
PRIVACY_MANIFEST="$ROOT_DIR/SaintCharbelApp/PrivacyInfo.xcprivacy"

REMOTE_ENDPOINTS=(
  "https://marsharbel.com"
  "https://marsharbel.com/story.html"
  "https://marsharbel.com/media/storybook/images/event-01.png"
  "https://marsharbel.com/media/storybook/en-elevenlabs/page-01.mp3"
  "https://marsharbel.com/media/rosary/joyful_1/step-01.mp3"
)

log() {
  printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$1"
}

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required tool: $1" >&2
    exit 1
  fi
}

check_remote_endpoint() {
  local url="$1"
  curl --fail --silent --show-error --head --location --max-time 20 "$url" >/dev/null
}

require_tool xcodebuild
require_tool plutil
require_tool curl

if [[ ! -f "$PRIVACY_MANIFEST" ]]; then
  echo "Privacy manifest not found at $PRIVACY_MANIFEST" >&2
  exit 1
fi

log "Linting privacy manifest"
plutil -lint "$PRIVACY_MANIFEST"

log "Building Debug simulator target"
xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  build

log "Building Release iOS target"
xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO \
  build

if [[ "${SKIP_REMOTE_CHECKS:-0}" != "1" ]]; then
  log "Checking remote content dependencies"
  for url in "${REMOTE_ENDPOINTS[@]}"; do
    check_remote_endpoint "$url"
    printf '  - ok %s\n' "$url"
  done
else
  log "Skipping remote dependency checks"
fi

log "Health check completed"
