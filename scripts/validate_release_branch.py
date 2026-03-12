#!/usr/bin/env python3
"""Validate which branches are allowed to promote into main."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


class ValidationError(RuntimeError):
    """Raised when branch validation fails."""


RELEASE_BRANCH_RE = re.compile(r"^(?:release|hotfix)/v(?P<version>\d+\.\d+\.\d+)$")
ANDROID_VERSION_RE = re.compile(r'versionName\s*=\s*"([^"]+)"')
IOS_VERSION_RE = re.compile(r"MARKETING_VERSION\s*=\s*([0-9]+\.[0-9]+\.[0-9]+)\s*;")


def _read_text(path: Path) -> str:
    if not path.is_file():
        raise ValidationError(f"Missing required file: {path}")
    return path.read_text(encoding="utf-8", errors="replace")


def _extract_android_version(repo_root: Path) -> str:
    gradle_file = repo_root / "native-android" / "app" / "build.gradle.kts"
    match = ANDROID_VERSION_RE.search(_read_text(gradle_file))
    if not match:
        raise ValidationError(f"Could not parse Android versionName in {gradle_file}")
    return match.group(1)


def _extract_ios_version(repo_root: Path) -> str:
    pbxproj_file = repo_root / "native-ios" / "SaintCharbelApp.xcodeproj" / "project.pbxproj"
    match = IOS_VERSION_RE.search(_read_text(pbxproj_file))
    if not match:
        raise ValidationError(f"Could not parse iOS MARKETING_VERSION in {pbxproj_file}")
    return match.group(1)


def validate_branch(repo_root: Path, head_ref: str) -> dict:
    normalized = head_ref.strip()

    if normalized == "develop":
        return {"head_ref": normalized, "policy": "develop-to-main", "version": None}

    branch_match = RELEASE_BRANCH_RE.match(normalized)
    if not branch_match:
        raise ValidationError(
            "Only 'develop', 'release/vX.Y.Z', or 'hotfix/vX.Y.Z' branches may target main. "
            f"Received: '{normalized}'"
        )

    expected_version = branch_match.group("version")
    android_version = _extract_android_version(repo_root)
    ios_version = _extract_ios_version(repo_root)

    if android_version != ios_version:
        raise ValidationError(
            f"Version mismatch: Android versionName={android_version}, iOS MARKETING_VERSION={ios_version}"
        )

    if android_version != expected_version:
        raise ValidationError(
            f"Release branch mismatch: branch expects {expected_version}, app versions are {android_version}"
        )

    return {
        "head_ref": normalized,
        "policy": "release-or-hotfix",
        "version": expected_version,
        "android_version": android_version,
        "ios_version": ios_version,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate promotion branches for main.")
    parser.add_argument("--head-ref", required=True, help="Branch name that targets main")
    parser.add_argument("--repo-root", default=".", help="Repository root")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = Path(args.repo_root).resolve()

    try:
        result = validate_branch(repo_root=repo_root, head_ref=args.head_ref)
    except ValidationError as exc:
        print(f"[ERROR] {exc}", file=sys.stderr)
        return 1

    print("[OK] Main promotion branch validation passed")
    print(f"  branch: {result['head_ref']}")
    print(f"  policy: {result['policy']}")
    if result["policy"] == "release-or-hotfix":
        print(f"  version: {result['version']}")
        print(f"  android: {result['android_version']}")
        print(f"  ios:     {result['ios_version']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
