#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/native-android"

cd "$APP_DIR"
chmod +x gradlew scripts/healthcheck.sh

if [[ "${SKIP_REMOTE_CHECKS:-1}" == "1" ]]; then
  echo "==> Android verification with remote dependency checks disabled"
  ./gradlew --no-daemon clean assembleDebug assembleRelease bundleRelease lint
else
  echo "==> Android verification with remote dependency checks enabled"
  ./scripts/healthcheck.sh
fi

