#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required_dirs=(
  ".github/workflows"
  ".trunk"
  "docs"
  "docs/plans"
  "native-ios"
  "native-android"
  "scripts"
  "tests/playwright"
  "tests/playwright/specs/local"
)

required_files=(
  ".gitleaks.toml"
  ".trunk/trunk.yaml"
  "Makefile"
  "README.md"
  "docs/index.html"
  "docs/random-timer-automation-playbook.html"
  "docs/plans/2026-03-12-mobile-automation-roadmap.md"
  "docs/user-intervention-todo.md"
  "scripts/check-repo-contract.sh"
  "scripts/install-hooks.sh"
  "scripts/pre-commit"
  "scripts/verify-ios.sh"
  "scripts/verify-android.sh"
  "tests/playwright/package.json"
  "tests/playwright/package-lock.json"
  "tests/playwright/playwright.config.ts"
  "tests/playwright/specs/local/repo-contract.local.spec.ts"
  ".github/workflows/ci.yml"
  ".github/workflows/security.yml"
  ".github/workflows/native-release.yml"
  ".github/workflows/remote-health.yml"
  ".github/workflows/docs-site.yml"
  ".github/pull_request_template.md"
  ".github/ISSUE_TEMPLATE/bug_report.md"
  ".github/ISSUE_TEMPLATE/feature_request.md"
)

errors=0

echo "==> Checking required directories"
for rel in "${required_dirs[@]}"; do
  if [[ ! -d "$ROOT_DIR/$rel" ]]; then
    echo "❌ Missing directory: $rel" >&2
    errors=$((errors + 1))
  fi
done

echo "==> Checking required files"
for rel in "${required_files[@]}"; do
  if [[ ! -f "$ROOT_DIR/$rel" ]]; then
    echo "❌ Missing file: $rel" >&2
    errors=$((errors + 1))
  fi
done

echo "==> Checking nested app contracts"
for rel in \
  "native-ios/scripts/healthcheck.sh" \
  "native-ios/SaintCharbelApp.xcodeproj/project.pbxproj" \
  "native-android/scripts/healthcheck.sh" \
  "native-android/app/build.gradle.kts" \
  "native-android/gradlew"; do
  if [[ ! -f "$ROOT_DIR/$rel" ]]; then
    echo "❌ Missing nested app file: $rel" >&2
    errors=$((errors + 1))
  fi
done

if [[ -d "$ROOT_DIR/native-ios/.git" || -d "$ROOT_DIR/native-android/.git" ]]; then
  echo "⚠️  Nested .git directories detected under native-ios/ or native-android/." >&2
  echo "    Decide whether the future GitHub repo will be a monorepo or use submodules before first push." >&2
fi

if (( errors > 0 )); then
  echo "==> Repo contract check failed with $errors error(s)." >&2
  exit 1
fi

echo "==> Repo contract check passed"
