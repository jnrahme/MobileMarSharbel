#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="$ROOT_DIR/.tools/bin"
VERSION="${GITLEAKS_VERSION:-8.30.0}"

usage() {
  cat <<'EOF'
Usage: bash scripts/ensure-gitleaks.sh

Installs gitleaks into .tools/bin if it is not already available on PATH.
EOF
}

if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if command -v gitleaks >/dev/null 2>&1; then
  command -v gitleaks
  exit 0
fi

if [[ -x "$BIN_DIR/gitleaks" ]]; then
  printf '%s\n' "$BIN_DIR/gitleaks"
  exit 0
fi

mkdir -p "$BIN_DIR"

os="$(uname -s)"
arch="$(uname -m)"
case "$os:$arch" in
  Linux:x86_64|Linux:amd64) asset="gitleaks_${VERSION}_linux_x64.tar.gz" ;;
  Linux:aarch64|Linux:arm64) asset="gitleaks_${VERSION}_linux_arm64.tar.gz" ;;
  Darwin:x86_64) asset="gitleaks_${VERSION}_darwin_x64.tar.gz" ;;
  Darwin:arm64) asset="gitleaks_${VERSION}_darwin_arm64.tar.gz" ;;
  *)
    echo "Unsupported platform for automatic gitleaks install: $os/$arch" >&2
    exit 1
    ;;
esac

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

archive="$tmpdir/gitleaks.tar.gz"
curl -sSfL "https://github.com/gitleaks/gitleaks/releases/download/v${VERSION}/${asset}" -o "$archive"
tar -xzf "$archive" -C "$tmpdir" gitleaks
install -m 0755 "$tmpdir/gitleaks" "$BIN_DIR/gitleaks"

printf '%s\n' "$BIN_DIR/gitleaks"
