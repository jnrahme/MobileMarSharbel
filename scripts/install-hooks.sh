#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -d "$ROOT_DIR/.git" ]]; then
  echo "Root .git directory not found. Initialize or clone the future root repo first." >&2
  exit 1
fi

install -m 0755 "$ROOT_DIR/scripts/pre-commit" "$ROOT_DIR/.git/hooks/pre-commit"
echo "Installed root pre-commit hook"

