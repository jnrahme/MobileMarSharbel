#!/usr/bin/env python3
"""Shared App Store Connect API auth and request helpers."""

from __future__ import annotations

import os
import time
from dataclasses import dataclass
from typing import Any, Optional

APP_STORE_CONNECT_API = "https://api.appstoreconnect.apple.com/v1"


class AscClientError(RuntimeError):
    """Raised for auth, dependency, and HTTP/API failures."""


def _read_file(path: str) -> str:
    with open(path, "r", encoding="utf-8") as handle:
        return handle.read()


def read_private_key_material(key_id: str) -> str:
    value = (os.environ.get("APPSTORE_PRIVATE_KEY") or "").strip()
    if not value:
        value = (os.environ.get("APPSTORE_PRIVATE_KEY_PATH") or "").strip()
    if not value:
        default_path = os.path.expanduser(
            f"~/.appstoreconnect/private_keys/AuthKey_{key_id}.p8"
        )
        if os.path.isfile(default_path):
            value = default_path
    if not value:
        return ""

    expanded = os.path.expanduser(value)
    if os.path.isfile(expanded):
        return _read_file(expanded)
    return value


def safe_json_response(resp: Any) -> dict[str, Any]:
    if not getattr(resp, "content", None):
        return {}
    try:
        parsed = resp.json()
    except Exception:
        return {"raw": (resp.text or "")[:2000]}
    if isinstance(parsed, dict):
        return parsed
    return {"data": parsed}


@dataclass
class ASCAuth:
    key_id: str
    issuer_id: str
    private_key: str

    @classmethod
    def from_env(cls) -> "ASCAuth":
        key_id = (os.environ.get("APPSTORE_KEY_ID") or "").strip()
        issuer_id = (os.environ.get("APPSTORE_ISSUER_ID") or "").strip()
        private_key = read_private_key_material(key_id)

        missing: list[str] = []
        if not key_id:
            missing.append("APPSTORE_KEY_ID")
        if not issuer_id:
            missing.append("APPSTORE_ISSUER_ID")
        if not private_key:
            missing.append("APPSTORE_PRIVATE_KEY (or APPSTORE_PRIVATE_KEY_PATH)")
        if missing:
            raise AscClientError(f"Missing env vars: {', '.join(missing)}")

        return cls(key_id=key_id, issuer_id=issuer_id, private_key=private_key)

    def jwt(self) -> str:
        try:
            import jwt
        except ImportError as exc:
            raise AscClientError(
                "Missing PyJWT. Install: pip install pyjwt cryptography"
            ) from exc

        now = int(time.time())
        payload = {
            "iss": self.issuer_id,
            "iat": now,
            "exp": now + (20 * 60),
            "aud": "appstoreconnect-v1",
        }
        headers = {"alg": "ES256", "kid": self.key_id, "typ": "JWT"}
        return jwt.encode(payload, self.private_key, algorithm="ES256", headers=headers)


class ASCClient:
    def __init__(self, auth: Optional[ASCAuth] = None, *, timeout: int = 30):
        self._auth = auth or ASCAuth.from_env()
        self._timeout = timeout
        self._token: Optional[str] = None
        self._token_expiry = 0.0

    @classmethod
    def from_env(cls, *, timeout: int = 30) -> "ASCClient":
        return cls(ASCAuth.from_env(), timeout=timeout)

    def token_value(self) -> str:
        now = time.time()
        if self._token and now < self._token_expiry - 30:
            return self._token
        self._token = self._auth.jwt()
        self._token_expiry = now + (20 * 60)
        return self._token

    def request(
        self,
        method: str,
        path: str,
        *,
        params: Optional[dict[str, Any]] = None,
        payload: Optional[dict[str, Any]] = None,
    ) -> dict[str, Any]:
        try:
            import requests
        except ImportError as exc:
            raise AscClientError("Missing requests. Install: pip install requests") from exc

        url = path if path.startswith("https://") else f"{APP_STORE_CONNECT_API}{path}"
        response = requests.request(
            method=method.upper(),
            url=url,
            headers={
                "Authorization": f"Bearer {self.token_value()}",
                "Content-Type": "application/json",
            },
            params=params or {},
            json=payload,
            timeout=self._timeout,
        )
        if response.status_code >= 400:
            raise AscClientError(
                f"{method.upper()} {path} failed: HTTP {response.status_code} {safe_json_response(response)}"
            )
        return safe_json_response(response)

    def get(self, path: str, params: Optional[dict[str, Any]] = None) -> dict[str, Any]:
        return self.request("GET", path, params=params)

    def get_all(
        self, path: str, *, params: Optional[dict[str, Any]] = None
    ) -> list[dict[str, Any]]:
        items: list[dict[str, Any]] = []
        next_path = path
        next_params = dict(params or {})

        while True:
            payload = self.get(next_path, params=next_params)
            data = payload.get("data", [])
            if isinstance(data, list):
                items.extend(data)

            next_url = (payload.get("links") or {}).get("next")
            if not next_url:
                break
            if next_url.startswith(APP_STORE_CONNECT_API):
                next_url = next_url[len(APP_STORE_CONNECT_API) :]
            next_path = next_url
            next_params = {}

        return items


AscAuth = ASCAuth
AscClient = ASCClient
