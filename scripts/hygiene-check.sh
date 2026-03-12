#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$ROOT_DIR" ]]; then
  ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

errors=0
warnings=0

error() {
  printf '  ❌ %s\n' "$1"
  errors=$((errors + 1))
}

warn() {
  printf '  ⚠️  %s\n' "$1"
  warnings=$((warnings + 1))
}

echo "=== Repo Hygiene Check ==="
echo ""
echo "1. Root markdown discipline"

allowed_root_md=(
  "README.md"
)

for file in "$ROOT_DIR"/*.md; do
  [[ -f "$file" ]] || continue
  base="$(basename "$file")"
  allowed=false
  for whitelisted in "${allowed_root_md[@]}"; do
    if [[ "$base" == "$whitelisted" ]]; then
      allowed=true
      break
    fi
  done
  if [[ "$allowed" == "false" ]]; then
    error "Unexpected root markdown file: $base"
  fi
done

echo "2. No absolute workstation paths in tracked files"
if git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  abs_hits="$(git -C "$ROOT_DIR" grep -l '/Users/\|/home/\|C:\\Users\\' -- '*.md' '*.sh' '*.yml' '*.yaml' '*.json' '*.toml' '*.kt' '*.swift' ':!docs/random-timer-automation-playbook.html' ':!scripts/hygiene-check.sh' 2>/dev/null || true)"
  if [[ -n "$abs_hits" ]]; then
    while IFS= read -r hit; do
      [[ -n "$hit" ]] || continue
      error "Absolute path found in $hit"
    done <<< "$abs_hits"
  fi
fi

echo "3. No tracked build artifacts"
if git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  tracked_builds="$(git -C "$ROOT_DIR" ls-files -- '*.apk' '*.aab' '*.ipa' '*.xcresult' 'native-ios/build/*' 'native-android/build/*' 'native-android/app/build/*' 2>/dev/null || true)"
  if [[ -n "$tracked_builds" ]]; then
    while IFS= read -r hit; do
      [[ -n "$hit" ]] || continue
      error "Tracked build artifact: $hit"
    done <<< "$tracked_builds"
  fi
fi

echo "4. Required root automation files"
required_files=(
  "Makefile"
  "README.md"
  "docs/release-automation.md"
  "docs/user-intervention-todo.md"
  "scripts/check-repo-contract.sh"
  "scripts/preflight-release.sh"
  "scripts/run-ios-sim.sh"
  "scripts/run-android-target.sh"
  "scripts/maestro-smoke.sh"
  "scripts/ensure-gitleaks.sh"
  ".maestro/ios-smoke.yaml"
  ".maestro/android-smoke.yaml"
)

for rel in "${required_files[@]}"; do
  if [[ ! -f "$ROOT_DIR/$rel" ]]; then
    error "Missing required automation file: $rel"
  fi
done

echo "5. Tool cache remains untracked"
if git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git -C "$ROOT_DIR" ls-files --error-unmatch .tools >/dev/null 2>&1; then
    error ".tools should stay untracked"
  fi
fi

echo "6. Release workflow references preflight"
if [[ -f "$ROOT_DIR/.github/workflows/native-release.yml" ]] && ! grep -q "preflight-release.sh" "$ROOT_DIR/.github/workflows/native-release.yml"; then
  warn "native-release workflow does not call preflight-release.sh"
fi

echo ""
echo "=== Results ==="
echo "Errors: $errors | Warnings: $warnings"

if (( errors > 0 )); then
  exit 1
fi

echo "✅ Hygiene check passed"
