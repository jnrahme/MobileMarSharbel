#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> make help"
make help >/dev/null

echo "==> make verify-repo"
make verify-repo

echo "==> make hygiene-check"
make hygiene-check

echo "==> make preflight-release"
make preflight-release

echo "==> make print-blockers"
make print-blockers >/dev/null

echo "==> make docs-site"
make docs-site >/dev/null

echo "==> launcher command help"
bash scripts/run-ios-sim.sh --help >/dev/null
bash scripts/run-android-target.sh --help >/dev/null
bash scripts/maestro-smoke.sh --help >/dev/null
bash scripts/sync_ios_store_assets.sh --help >/dev/null
bash scripts/ios-submit-review.sh --help >/dev/null
bash scripts/ios-fastlane.sh lanes >/dev/null
bash scripts/store-python.sh scripts/check_store_access.py --help >/dev/null
bash scripts/store-python.sh scripts/asc_verify_ready.py --help >/dev/null
bash scripts/store-python.sh scripts/asc_poll_version_state.py --help >/dev/null
python3 scripts/validate_release_branch.py --help >/dev/null
python3 scripts/validate_release_branch.py --head-ref develop >/dev/null
python3 scripts/validate_release_branch.py --head-ref release/v1.0.0 >/dev/null

echo "==> gitleaks bootstrap"
bash scripts/ensure-gitleaks.sh >/dev/null

echo "CLI smoke checks passed"
