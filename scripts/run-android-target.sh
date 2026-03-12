#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$ROOT_DIR/native-android"
APP_ID="com.jnrahme.androidsaintcharbel.debug"
ACTIVITY="com.jnrahme.androidsaintcharbel.MainActivity"

usage() {
  cat <<'EOF'
Usage: bash scripts/run-android-target.sh emulator|device

Builds and installs the Android debug app, then launches it on the selected target.
EOF
}

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required tool: $1" >&2
    exit 1
  fi
}

wait_for_boot() {
  local serial="$1"
  local status=""
  for _ in $(seq 1 60); do
    status="$(adb -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
    if [[ "$status" == "1" ]]; then
      return 0
    fi
    sleep 2
  done
  echo "Timed out waiting for Android target $serial to finish booting" >&2
  exit 1
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" || $# -eq 0 ]]; then
  usage
  exit 0
fi

mode="$1"
if [[ "$mode" != "emulator" && "$mode" != "device" ]]; then
  echo "Unknown target mode: $mode" >&2
  usage
  exit 2
fi

require_tool adb
require_tool "$ANDROID_DIR/gradlew"

serial=""
if [[ "$mode" == "emulator" ]]; then
  serial="$(adb devices | awk '/^emulator-/{print $1; exit}')"
  if [[ -z "$serial" ]]; then
    require_tool emulator
    avd="$(emulator -list-avds | head -1)"
    if [[ -z "$avd" ]]; then
      echo "No Android Virtual Devices are configured. Create an AVD in Android Studio first." >&2
      exit 1
    fi

    echo "==> Starting emulator: $avd"
    nohup emulator -avd "$avd" -no-snapshot-load >/tmp/mobiletest-android-emulator.log 2>&1 &
    adb wait-for-device >/dev/null
    serial="$(adb devices | awk '/^emulator-/{print $1; exit}')"
    if [[ -z "$serial" ]]; then
      echo "Android emulator did not register with adb" >&2
      exit 1
    fi
    wait_for_boot "$serial"
  fi
else
  serial="$(adb devices | awk '$2=="device" && $1 !~ /^emulator-/{print $1; exit}')"
  if [[ -z "$serial" ]]; then
    echo "No connected Android device found. Connect one with USB debugging enabled." >&2
    exit 1
  fi
fi

echo "==> Using Android target: $serial"
(
  cd "$ANDROID_DIR"
  ANDROID_SERIAL="$serial" ./gradlew --no-daemon installDebug >/dev/null
)

echo "==> Launching app"
adb -s "$serial" shell am start -n "$APP_ID/$ACTIVITY" >/dev/null
