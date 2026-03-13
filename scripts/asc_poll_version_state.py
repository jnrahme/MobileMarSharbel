#!/usr/bin/env python3
"""Read and optionally poll the App Store Connect state for an iOS version."""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
from typing import Any, Dict, Optional

ROOT_DIR = os.path.dirname(os.path.dirname(__file__))
if ROOT_DIR not in sys.path:
    sys.path.insert(0, ROOT_DIR)

from scripts.asc_client import AscClient, AscClientError

DEFAULT_BUNDLE_ID = "com.rammyinn.saintcharbel"
TERMINAL_STATES = {
    "WAITING_FOR_REVIEW",
    "IN_REVIEW",
    "PENDING_DEVELOPER_RELEASE",
    "READY_FOR_SALE",
    "REJECTED",
    "DEVELOPER_REJECTED",
    "METADATA_REJECTED",
}


def _die(message: str, code: int = 1) -> "None":
    print(f"❌ {message}", file=sys.stderr)
    raise SystemExit(code)


def _get_app_id(client: AscClient, bundle_id: str) -> str:
    payload = client.get("/apps", params={"filter[bundleId]": bundle_id, "limit": "1"})
    data = payload.get("data", []) or []
    if not data:
        _die(f"No app found for bundleId '{bundle_id}'", 2)
    return str(data[0]["id"])


def _fetch_state(client: AscClient, bundle_id: str, version: str) -> Dict[str, Any]:
    app_id = _get_app_id(client, bundle_id)
    payload = client.get(
        f"/apps/{app_id}/appStoreVersions",
        params={
            "filter[platform]": "IOS",
            "filter[versionString]": version,
            "limit": "1",
            "fields[appStoreVersions]": "versionString,appStoreState,createdDate",
        },
    )
    data = payload.get("data", []) or []
    if not data:
        _die(f"App Store version '{version}' not found for bundleId '{bundle_id}'", 2)

    version_data = data[0]
    attrs = version_data.get("attributes", {}) or {}
    return {
        "bundle_id": bundle_id,
        "version": attrs.get("versionString") or version,
        "version_id": version_data.get("id"),
        "state": attrs.get("appStoreState") or "UNKNOWN",
        "created_date": attrs.get("createdDate"),
    }


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Read and optionally poll the App Store Connect state for an iOS version."
    )
    parser.add_argument("--version", required=True, help="App Store version string, e.g. 1.0.0")
    parser.add_argument(
        "--bundle-id",
        default=DEFAULT_BUNDLE_ID,
        help=f"Bundle ID (default: {DEFAULT_BUNDLE_ID})",
    )
    parser.add_argument("--wait", action="store_true", help="Poll until a terminal state is reached.")
    parser.add_argument(
        "--timeout",
        type=int,
        default=1800,
        help="Wait timeout in seconds when --wait is used (default: 1800).",
    )
    parser.add_argument(
        "--poll-interval",
        type=int,
        default=20,
        help="Polling interval in seconds when --wait is used (default: 20).",
    )
    parser.add_argument("--json", action="store_true", help="Print JSON only.")
    return parser.parse_args()


def _print_state(state: Dict[str, Any], *, as_json: bool) -> None:
    if as_json:
        print(json.dumps(state))
        return
    print(
        f"ASC {state['bundle_id']} v{state['version']} -> {state['state']}"
        + (f" (id={state['version_id']})" if state.get("version_id") else "")
    )


def main() -> int:
    args = _parse_args()

    try:
        client = AscClient(timeout=30)
        state = _fetch_state(client, args.bundle_id, args.version)
        _print_state(state, as_json=args.json)

        if not args.wait:
            return 0

        deadline = time.time() + args.timeout
        while state["state"] not in TERMINAL_STATES:
            if time.time() >= deadline:
                _die(
                    f"Timed out waiting for version {args.version} to reach a terminal state. Last state: {state['state']}"
                )
            time.sleep(args.poll_interval)
            state = _fetch_state(client, args.bundle_id, args.version)
            _print_state(state, as_json=args.json)

        return 0
    except AscClientError as exc:
        _die(str(exc), 2)


if __name__ == "__main__":
    raise SystemExit(main())
