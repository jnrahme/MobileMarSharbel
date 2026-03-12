#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/native-ios"

cd "$APP_DIR"
chmod +x scripts/healthcheck.sh

if [[ "${SKIP_REMOTE_CHECKS:-1}" == "1" ]]; then
  echo "==> iOS verification with remote dependency checks disabled"
else
  echo "==> iOS verification with remote dependency checks enabled"
fi

SKIP_REMOTE_CHECKS="${SKIP_REMOTE_CHECKS:-1}" ./scripts/healthcheck.sh

