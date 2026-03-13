#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="$(bash "$ROOT_DIR/scripts/ensure-store-python.sh")"

exec "$PYTHON_BIN" "$@"
