#!/usr/bin/env python3
"""Verify App Store Connect readiness for iOS submission."""

from __future__ import annotations

import argparse
import json
import os
import sys
from dataclasses import dataclass
from typing import Any, Dict, List, Optional, Tuple

ROOT_DIR = os.path.dirname(os.path.dirname(__file__))
if ROOT_DIR not in sys.path:
    sys.path.insert(0, ROOT_DIR)

from scripts.asc_client import AscClient, AscClientError

DEFAULT_BUNDLE_ID = "com.rammyinn.saintcharbel"
DEFAULT_LOCALE = "en-US"


def _die(code: int, message: str) -> "None":
    print(message, file=sys.stderr)
    raise SystemExit(code)


def _normalize(value: Optional[str]) -> str:
    return (value or "").strip()


def _first(items: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
    return items[0] if items else None


def _pick_localization(items: List[Dict[str, Any]], locale: str) -> Optional[Dict[str, Any]]:
    for item in items:
        if _normalize(item.get("attributes", {}).get("locale")) == locale:
            return item
    return _first(items)


@dataclass
class Check:
    name: str
    passed: bool
    details: str
    evidence: Optional[Dict[str, Any]] = None


def _get_app_id(client: AscClient, bundle_id: str) -> str:
    payload = client.get("/apps", params={"filter[bundleId]": bundle_id, "limit": "1"})
    data = payload.get("data", []) or []
    if not data:
        _die(2, f"❌ No app found with bundleId '{bundle_id}'")
    return str(data[0]["id"])


def _list_versions(
    client: AscClient, app_id: str, version: str
) -> Tuple[Dict[str, Any], Optional[Dict[str, Any]]]:
    payload = client.get(
        f"/apps/{app_id}/appStoreVersions",
        params={
            "filter[versionString]": version,
            "limit": "1",
            "include": "build,appStoreVersionLocalizations",
            "fields[appStoreVersions]": "versionString,appStoreState,build,appStoreVersionLocalizations",
            "fields[builds]": "processingState,version,uploadedDate",
            "fields[appStoreVersionLocalizations]": "locale,description,keywords,promotionalText,supportUrl,marketingUrl,whatsNew",
        },
    )
    versions = payload.get("data", []) or []
    return payload, _first(versions)


def _included_lookup(payload: Dict[str, Any], type_name: str, item_id: str) -> Optional[Dict[str, Any]]:
    for item in payload.get("included", []) or []:
        if item.get("type") == type_name and item.get("id") == item_id:
            return item
    return None


def _get_app_info_bundle(
    client: AscClient, app_id: str
) -> Tuple[Optional[Dict[str, Any]], List[Dict[str, Any]]]:
    payload = client.get(
        f"/apps/{app_id}/appInfos",
        params={
            "include": "appInfoLocalizations",
            "limit": "50",
            "fields[appInfos]": "appInfoLocalizations,appStoreAgeRating,state",
            "fields[appInfoLocalizations]": "locale,name,subtitle,privacyPolicyUrl,privacyChoicesUrl,privacyPolicyText",
        },
    )
    app_infos = payload.get("data", []) or []
    localizations = [
        item
        for item in (payload.get("included") or [])
        if item.get("type") == "appInfoLocalizations"
    ]
    return _first(app_infos), localizations


def _value_from_attrs(attrs: Dict[str, Any], *keys: str) -> str:
    for key in keys:
        value = _normalize(attrs.get(key))
        if value:
            return value
    return ""


def _get_review_detail(client: AscClient, version_id: str) -> Dict[str, Any]:
    payload = client.get(
        f"/appStoreVersions/{version_id}/appStoreReviewDetail",
        params={
            "fields[appStoreReviewDetails]": "contactFirstName,contactLastName,contactPhone,contactEmail"
        },
    )
    data = payload.get("data")
    return data if isinstance(data, dict) else {}


def _get_price_schedule(client: AscClient, app_id: str) -> Optional[Dict[str, Any]]:
    payload = client.get(f"/apps/{app_id}/appPriceSchedule")
    data = payload.get("data")
    return data if isinstance(data, dict) else None


def _get_screenshot_sets(client: AscClient, localization_id: str) -> List[Dict[str, Any]]:
    payload = client.get(
        f"/appStoreVersionLocalizations/{localization_id}/appScreenshotSets",
        params={"limit": "200", "fields[appScreenshotSets]": "screenshotDisplayType"},
    )
    return payload.get("data", []) or []


def _summarize_screenshot_set(client: AscClient, set_id: str) -> Dict[str, Any]:
    payload = client.get(
        f"/appScreenshotSets/{set_id}/appScreenshots",
        params={"limit": "200", "fields[appScreenshots]": "assetDeliveryState,fileName"},
    )
    items = payload.get("data", []) or []
    total = len(items)
    complete = 0
    state_counts: Dict[str, int] = {}

    for item in items:
        attrs = item.get("attributes", {}) or {}
        state = str((attrs.get("assetDeliveryState") or {}).get("state") or "UNKNOWN")
        state_counts[state] = state_counts.get(state, 0) + 1
        if state == "COMPLETE":
            complete += 1

    return {"total": total, "complete": complete, "state_counts": state_counts}


def _is_large_iphone(display_type: str) -> bool:
    dt = display_type.upper()
    return dt.startswith("APP_IPHONE") and any(
        token in dt for token in ("65", "67", "69", "6_5", "6_7", "6_9")
    )


def _is_large_ipad(display_type: str) -> bool:
    dt = display_type.upper()
    return ("IPAD" in dt) and any(
        token in dt for token in ("129", "_13", "13_", "PRO_13", "13_INCH")
    )


def verify_ready(
    *,
    bundle_id: str,
    version: str,
    locale: str,
    min_iphone: int,
    min_ipad: int,
    require_build: bool,
) -> Tuple[bool, Dict[str, Any]]:
    client = AscClient(timeout=30)
    checks: List[Check] = []

    app_id = _get_app_id(client, bundle_id)
    payload, app_store_version = _list_versions(client, app_id, version)
    if not app_store_version:
        checks.append(
            Check(
                name="App Store Version Exists",
                passed=False,
                details=f"App Store version '{version}' not found for bundleId '{bundle_id}'",
            )
        )
        return False, {"bundle_id": bundle_id, "version": version, "checks": [c.__dict__ for c in checks]}

    version_attrs = app_store_version.get("attributes", {}) or {}
    version_id = str(app_store_version.get("id") or "")
    version_state = str(version_attrs.get("appStoreState") or "UNKNOWN")
    checks.append(
        Check(
            name="App Store Version Exists",
            passed=True,
            details=f"Found version {version_attrs.get('versionString')} (state={version_state})",
            evidence={"appStoreState": version_state, "versionId": version_id},
        )
    )

    build_rel = (
        app_store_version.get("relationships", {}).get("build", {}).get("data")
    )
    build_obj = None
    if isinstance(build_rel, dict) and build_rel.get("id"):
        build_obj = _included_lookup(payload, "builds", str(build_rel["id"]))
    build_attrs = (build_obj or {}).get("attributes", {}) or {}
    build_processing = str(build_attrs.get("processingState") or "NONE")
    build_version = str(build_attrs.get("version") or "")
    build_ok = bool(build_obj) and build_processing == "VALID"
    if require_build:
        checks.append(
            Check(
                name="Valid Build Attached",
                passed=build_ok,
                details=(
                    f"Attached build {build_version} is VALID"
                    if build_ok
                    else "No VALID build is attached to this App Store version"
                ),
                evidence={
                    "buildPresent": bool(build_obj),
                    "processingState": build_processing,
                    "buildNumber": build_version,
                },
            )
        )

    localizations = [
        item
        for item in (payload.get("included") or [])
        if item.get("type") == "appStoreVersionLocalizations"
    ]
    version_localization = _pick_localization(localizations, locale)
    if not version_localization:
        checks.append(
            Check(
                name="Localized Version Metadata",
                passed=False,
                details=f"Missing appStoreVersionLocalization for locale '{locale}'",
            )
        )
        return False, {"bundle_id": bundle_id, "version": version, "checks": [c.__dict__ for c in checks]}

    loc_id = str(version_localization.get("id") or "")
    loc_attrs = version_localization.get("attributes", {}) or {}
    description = _normalize(loc_attrs.get("description"))
    keywords = _normalize(loc_attrs.get("keywords"))
    support_url = _value_from_attrs(loc_attrs, "supportUrl", "supportURL")
    checks.append(
        Check(
            name="Description Present",
            passed=bool(description),
            details="Description is set" if description else "Description is missing",
        )
    )
    checks.append(
        Check(
            name="Keywords Present",
            passed=bool(keywords),
            details="Keywords are set" if keywords else "Keywords are missing",
        )
    )
    checks.append(
        Check(
            name="Support URL Present",
            passed=bool(support_url),
            details=f"Support URL set to {support_url}" if support_url else "Support URL is missing",
        )
    )

    app_info, app_info_localizations = _get_app_info_bundle(client, app_id)
    app_info_loc = _pick_localization(app_info_localizations, locale)
    app_info_attrs = (app_info_loc or {}).get("attributes", {}) or {}
    app_info_state = ((app_info or {}).get("attributes") or {}).get("appStoreAgeRating")
    privacy_url = _value_from_attrs(app_info_attrs, "privacyPolicyUrl", "privacyPolicyURL")
    checks.append(
        Check(
            name="Privacy Policy URL Present",
            passed=bool(privacy_url),
            details=(
                f"Privacy policy URL set to {privacy_url}"
                if privacy_url
                else "Privacy policy URL is missing"
            ),
        )
    )

    review_detail = _get_review_detail(client, version_id)
    review_attrs = review_detail.get("attributes", {}) if review_detail else {}
    review_ok = all(
        _normalize(review_attrs.get(field))
        for field in ("contactFirstName", "contactLastName", "contactPhone", "contactEmail")
    )
    checks.append(
        Check(
            name="App Review Contact Info",
            passed=review_ok,
            details=(
                "App Review contact information is complete"
                if review_ok
                else "App Review contact information is incomplete"
            ),
        )
    )

    price_schedule = _get_price_schedule(client, app_id)
    checks.append(
        Check(
            name="Pricing Configured",
            passed=bool(price_schedule),
            details=(
                "App price schedule is configured"
                if price_schedule
                else "Pricing and availability have not been configured"
            ),
        )
    )

    checks.append(
        Check(
            name="Age Rating Configured",
            passed=bool(app_info_state),
            details=(
                f"Age rating is configured ({app_info_state})"
                if app_info_state
                else "Age rating is missing"
            ),
        )
    )

    screenshot_sets = _get_screenshot_sets(client, loc_id)
    iphone_complete = 0
    ipad_complete = 0
    screenshot_summary: Dict[str, Any] = {}
    for screenshot_set in screenshot_sets:
        display_type = str((screenshot_set.get("attributes") or {}).get("screenshotDisplayType") or "")
        set_summary = _summarize_screenshot_set(client, str(screenshot_set["id"]))
        screenshot_summary[display_type] = set_summary
        if _is_large_iphone(display_type):
            iphone_complete += int(set_summary["complete"])
        if _is_large_ipad(display_type):
            ipad_complete += int(set_summary["complete"])

    checks.append(
        Check(
            name="Large iPhone Screenshots",
            passed=iphone_complete >= min_iphone,
            details=(
                f"{iphone_complete} complete large-iPhone screenshots found (need >= {min_iphone})"
            ),
            evidence=screenshot_summary,
        )
    )
    if min_ipad > 0:
        checks.append(
            Check(
                name="Large iPad Screenshots",
                passed=ipad_complete >= min_ipad,
                details=f"{ipad_complete} complete large-iPad screenshots found (need >= {min_ipad})",
                evidence=screenshot_summary,
            )
        )

    result = {
        "bundle_id": bundle_id,
        "version": version,
        "locale": locale,
        "checks": [check.__dict__ for check in checks],
    }
    return all(check.passed for check in checks), result


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Verify App Store Connect readiness for an iOS App Store version."
    )
    parser.add_argument("--version", required=True, help="App Store version string, e.g. 1.0.0")
    parser.add_argument(
        "--bundle-id",
        default=DEFAULT_BUNDLE_ID,
        help=f"Bundle ID (default: {DEFAULT_BUNDLE_ID})",
    )
    parser.add_argument(
        "--locale",
        default=DEFAULT_LOCALE,
        help=f"App Store locale (default: {DEFAULT_LOCALE})",
    )
    parser.add_argument(
        "--min-iphone",
        type=int,
        default=1,
        help="Minimum number of complete large-iPhone screenshots required.",
    )
    parser.add_argument(
        "--min-ipad",
        type=int,
        default=1,
        help="Minimum number of complete large-iPad screenshots required.",
    )
    parser.add_argument(
        "--no-build",
        action="store_true",
        help="Do not require a VALID attached build.",
    )
    parser.add_argument(
        "--json",
        dest="json_path",
        default="",
        help="Optional path to write the JSON report.",
    )
    return parser.parse_args()


def main() -> int:
    args = _parse_args()
    try:
        ready, report = verify_ready(
            bundle_id=args.bundle_id,
            version=args.version,
            locale=args.locale,
            min_iphone=args.min_iphone,
            min_ipad=args.min_ipad,
            require_build=not args.no_build,
        )
    except AscClientError as exc:
        _die(2, f"❌ {exc}")

    if args.json_path:
        with open(args.json_path, "w", encoding="utf-8") as handle:
            json.dump(report, handle, indent=2)
            handle.write("\n")

    for check in report["checks"]:
        icon = "✅" if check["passed"] else "❌"
        print(f"{icon} {check['name']}: {check['details']}")

    print()
    print(f"Result: {'READY' if ready else 'NOT READY'}")
    return 0 if ready else 1


if __name__ == "__main__":
    raise SystemExit(main())
