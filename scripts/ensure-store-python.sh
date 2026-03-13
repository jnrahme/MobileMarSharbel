#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="$ROOT_DIR/.tools/store-python"
PYTHON_BIN="$VENV_DIR/bin/python3"
STAMP_FILE="$VENV_DIR/.deps-installed"

mkdir -p "$ROOT_DIR/.tools"

if [[ ! -x "$PYTHON_BIN" ]]; then
  python3 -m venv "$VENV_DIR"
fi

if ! "$PYTHON_BIN" -m pip --version >/dev/null 2>&1; then
  "$PYTHON_BIN" -m ensurepip --upgrade >/dev/null
fi

if [[ ! -f "$STAMP_FILE" ]]; then
  "$PYTHON_BIN" -m pip install --upgrade pip >/dev/null
  "$PYTHON_BIN" -m pip install \
    requests \
    pyjwt \
    cryptography \
    google-api-python-client \
    google-auth >/dev/null
  date -u +"%Y-%m-%dT%H:%M:%SZ" >"$STAMP_FILE"
fi

printf '%s\n' "$PYTHON_BIN"
