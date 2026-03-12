#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/native-ios/SaintCharbelApp.xcodeproj"
SCHEME="SaintCharbelApp"
BUNDLE_ID="com.rammyinn.saintcharbel"

usage() {
  cat <<'EOF'
Usage: bash scripts/run-ios-sim.sh

Builds the iOS app for an available iPhone simulator, installs it, and launches it.
EOF
}

if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

for tool in xcodebuild xcrun python3; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Missing required tool: $tool" >&2
    exit 1
  fi
done

sim_id="$(
  xcrun simctl list devices available -j | python3 -c '
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get("devices", {}).items():
    if "iOS" not in runtime:
        continue
    for device in devices:
        if device.get("isAvailable") and "iPhone" in device.get("name", ""):
            print(device["udid"])
            raise SystemExit(0)
raise SystemExit("No available iPhone simulator found")
'
)"

sim_name="$(xcrun simctl list devices available | grep "$sim_id" | head -1 | sed 's/ (.*//' | xargs)"
echo "==> Using simulator: $sim_name ($sim_id)"
xcrun simctl boot "$sim_id" >/dev/null 2>&1 || true
open -a Simulator

echo "==> Building debug app"
xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,id=$sim_id" \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build >/dev/null

app_path="$(
  xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,id=$sim_id" \
    -configuration Debug \
    -showBuildSettings 2>/dev/null | \
    awk '/CONFIGURATION_BUILD_DIR/ && !seen { print $3; seen=1 }'
)/$SCHEME.app"

if [[ ! -d "$app_path" ]]; then
  echo "Unable to resolve built .app path: $app_path" >&2
  exit 1
fi

echo "==> Installing app"
xcrun simctl install "$sim_id" "$app_path"

echo "==> Launching app"
xcrun simctl launch "$sim_id" "$BUNDLE_ID"
