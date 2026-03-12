#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<'EOF'
Usage: bash scripts/maestro-smoke.sh ios|android

Runs a minimal Maestro smoke flow after ensuring the matching app is installed locally.
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" || $# -eq 0 ]]; then
  usage
  exit 0
fi

platform="$1"
if [[ "$platform" != "ios" && "$platform" != "android" ]]; then
  echo "Unknown platform: $platform" >&2
  usage
  exit 2
fi

if ! command -v maestro >/dev/null 2>&1; then
  echo "Maestro CLI is not installed. Install it from https://maestro.mobile.dev/ first." >&2
  exit 1
fi

case "$platform" in
  ios)
    bash "$ROOT_DIR/scripts/run-ios-sim.sh"
    maestro test "$ROOT_DIR/.maestro/ios-smoke.yaml"
    ;;
  android)
    bash "$ROOT_DIR/scripts/run-android-target.sh" emulator
    maestro test "$ROOT_DIR/.maestro/android-smoke.yaml"
    ;;
esac
