#!/usr/bin/env python3
"""Live probe: which PUT /api/auth/update-profile fields persist (multipart).

Usage:
  python3 scripts/probe_update_profile_fields.py [--phone 01112345678]

Requires network access to the hosted integration backend.
"""
from __future__ import annotations

import argparse
import json
import ssl
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from typing import Any

BASE = "https://xstoreegy002-001-site1.etempurl.com"
AUTH = "Basic MTEzMjQ4ODM6NjAtZGF5ZnJlZXRyaWFs"
CTX = ssl.create_default_context()
DELAY_S = 8.0  # avoid 429
MAX_429_RETRIES = 2
RATE_LIMIT_WAIT_S = 65


@dataclass
class FieldProbe:
    wire_key: str
    sent_value: Any
    read_path: str  # dot path in get-profile response
    section: str  # user | store


def req(method: str, path: str, token: str | None = None, json_body=None, multipart: dict[str, Any] | None = None):
    url = BASE + path
    headers = {"Authorization": AUTH, "Accept": "application/json"}
    if token:
        headers["X-Auth-Token"] = token
    body = None
    if json_body is not None:
        body = json.dumps(json_body).encode()
        headers["Content-Type"] = "application/json"
    elif multipart is not None:
        boundary = "----XStoreProbeBoundary"
        parts: list[str] = []
        for k, v in multipart.items():
            parts.append(
                f'--{boundary}\r\nContent-Disposition: form-data; name="{k}"\r\n\r\n{v}\r\n'
            )
        parts.append(f"--{boundary}--\r\n")
        body = "".join(parts).encode()
        headers["Content-Type"] = f"multipart/form-data; boundary={boundary}"
    for attempt in range(MAX_429_RETRIES + 1):
        request = urllib.request.Request(url, data=body, headers=headers, method=method)
        try:
            with urllib.request.urlopen(request, context=CTX) as resp:
                raw = resp.read()
                return resp.status, json.loads(raw) if raw else {}
        except urllib.error.HTTPError as e:
            if e.code == 429 and attempt < MAX_429_RETRIES:
                print(f"  429 on {method} {path} — waiting {RATE_LIMIT_WAIT_S}s...")
                time.sleep(RATE_LIMIT_WAIT_S)
                continue
            raise


def login(phone: str) -> str:
    _, otp_resp = req("POST", "/api/auth/send-login-otp", json_body={"phoneNumber": phone})
    otp = otp_resp["otp"]
    time.sleep(DELAY_S)
    _, login_resp = req(
        "POST",
        "/api/auth/login-with-otp",
        json_body={"phoneNumber": phone, "otpToken": otp, "rememberMe": True},
    )
    return login_resp["token"]


def get_path(data: dict, path: str) -> Any:
    cur: Any = data
    for part in path.split("."):
        if not isinstance(cur, dict):
            return None
        cur = cur.get(part)
    return cur


def values_match(sent: Any, got: Any) -> bool:
    if got is None:
        return False
    s, g = str(sent).strip(), str(got).strip()
    if s == g:
        return True
    # birthDate / ISO timestamps — compare date prefix
    if len(s) >= 10 and len(g) >= 10 and s[:10] == g[:10]:
        return True
    # numeric coords
    try:
        return abs(float(s) - float(g)) < 0.0001
    except ValueError:
        return False


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--phone", default="01112345678", help="Vendor test phone")
    args = parser.parse_args()

    print(f"Logging in as {args.phone}...")
    token = login(args.phone)
    time.sleep(DELAY_S)

    _, baseline = req("GET", "/api/auth/get-profile", token=token)
    has_store = baseline.get("store") is not None
    print(f"Account has store: {has_store}\n")

    suffix = str(int(time.time()))

    probes: list[FieldProbe] = [
        FieldProbe("fullNameEn", f"ProbeName_{suffix}", "user.fullNameEn", "user"),
        FieldProbe("fullNameAr", f"اسم_{suffix}", "user.fullNameAr", "user"),
        FieldProbe("birthDate", "1990-03-20", "user.birthDate", "user"),
        FieldProbe("storeNameEn", f"StoreEn_{suffix}", "store.nameEn", "store"),
        FieldProbe("storeNameAr", f"متجر_{suffix}", "store.nameAr", "store"),
        FieldProbe("storeDescriptionEn", f"DescEn_{suffix}", "store.descriptionEn", "store"),
        FieldProbe("storeDescriptionAr", f"وصف_{suffix}", "store.descriptionAr", "store"),
        FieldProbe("whatsAppNumber", "01099998888", "store.whatsAppNumber", "store"),
        FieldProbe("instagramPage", f"https://instagram.com/probe_{suffix}", "store.instagramPage", "store"),
        FieldProbe("facebookPage", f"https://facebook.com/probe_{suffix}", "store.facebookPage", "store"),
        FieldProbe(
            "detailedAddressByGoogleMaps",
            f"Probe Google Addr {suffix}",
            "store.detailedAddressByGoogleMaps",
            "store",
        ),
        FieldProbe(
            "detailedAddressByUser",
            f"Probe User Addr {suffix}",
            "store.detailedAddressByUser",
            "store",
        ),
        FieldProbe("cityByGoogleMaps", f"ProbeCity_{suffix}", "store.cityByGoogleMaps", "store"),
        FieldProbe(
            "governmentByGoogleMaps",
            f"ProbeGov_{suffix}",
            "store.governmentByGoogleMaps",
            "store",
        ),
        FieldProbe("lat", "30.1111", "store.lat", "store"),
        FieldProbe("lng", "31.2222", "store.lng", "store"),
        FieldProbe("storeCategoryId", "3", "store.storeCategoryId", "store"),
        FieldProbe("cityId", "3", "store.cityId", "store"),
        FieldProbe("governmentId", "3", "store.governmentId", "store"),
    ]

    # Alternate wire keys the backend might expect instead of app keys
    alt_probes = [
        ("descriptionEn (alt)", {"descriptionEn": f"AltDesc_{suffix}"}, "store.descriptionEn"),
        ("descriptionAr (alt)", {"descriptionAr": f"وصفAlt_{suffix}"}, "store.descriptionAr"),
        ("nameEn (alt)", {"nameEn": f"AltName_{suffix}"}, "store.nameEn"),
    ]

    results: list[dict[str, Any]] = []

    for probe in probes:
        if probe.section == "store" and not has_store:
            results.append(
                {
                    "field": probe.wire_key,
                    "status": "SKIP",
                    "reason": "no store on account",
                }
            )
            continue

        before = get_path(baseline, probe.read_path)
        try:
            status, put_resp = req(
                "PUT",
                "/api/auth/update-profile",
                token=token,
                multipart={probe.wire_key: str(probe.sent_value)},
            )
            time.sleep(DELAY_S)
            _, after_profile = req("GET", "/api/auth/get-profile", token=token)
            put_val = get_path(put_resp, probe.read_path)
            get_val = get_path(after_profile, probe.read_path)
            synced_put = values_match(probe.sent_value, put_val)
            synced_get = values_match(probe.sent_value, get_val)
            if synced_put and synced_get:
                status_label = "OK"
            elif synced_put and not synced_get:
                status_label = "PARTIAL"
            else:
                status_label = "FAIL"
            results.append(
                {
                    "field": probe.wire_key,
                    "status": status_label,
                    "sent": probe.sent_value,
                    "before": before,
                    "put_response": put_val,
                    "get_profile": get_val,
                    "http": status,
                }
            )
        except urllib.error.HTTPError as e:
            body = e.read().decode(errors="replace")
            results.append(
                {
                    "field": probe.wire_key,
                    "status": "HTTP_ERROR",
                    "http": e.code,
                    "body": body[:200],
                }
            )
        time.sleep(DELAY_S)

    print("=== Alternate wire key names ===")
    for label, fields, read_path in alt_probes:
        if not has_store:
            break
        try:
            _, put_resp = req(
                "PUT", "/api/auth/update-profile", token=token, multipart=fields
            )
            time.sleep(DELAY_S)
            _, after_profile = req("GET", "/api/auth/get-profile", token=token)
            sent = next(iter(fields.values()))
            put_val = get_path(put_resp, read_path)
            get_val = get_path(after_profile, read_path)
            synced = values_match(sent, get_val)
            print(
                f"  {label}: {'OK' if synced else 'FAIL'} "
                f"(sent={sent!r}, get={get_val!r})"
            )
            results.append(
                {
                    "field": label,
                    "status": "OK" if synced else "FAIL",
                    "sent": sent,
                    "get_profile": get_val,
                }
            )
        except urllib.error.HTTPError as e:
            print(f"  {label}: HTTP {e.code}")
        time.sleep(DELAY_S)

    print("\n=== JSON body (fullNameEn only) — expect FAIL if backend is multipart-only ===")
    try:
        _, put_resp = req(
            "PUT",
            "/api/auth/update-profile",
            token=token,
            json_body={"fullNameEn": f"JsonFail_{suffix}"},
        )
        json_val = get_path(put_resp, "user.fullNameEn")
        print(f"  JSON fullNameEn persisted: {json_val == f'JsonFail_{suffix}'} (got {json_val!r})")
    except urllib.error.HTTPError as e:
        print(f"  JSON request HTTP {e.code}")

    print("\n=== FIELD SYNC REPORT (multipart, one field per request) ===")
    print(f"{'FIELD':<32} {'STATUS':<8} {'SENT':<28} {'GET after':<28}")
    print("-" * 100)
    for r in results:
        if r.get("status") == "SKIP":
            print(f"{r['field']:<32} {'SKIP':<8} {r.get('reason', '')}")
            continue
        sent = str(r.get("sent", ""))[:26]
        got = str(r.get("get_profile", r.get("put_response", "")))[:26]
        print(f"{r['field']:<32} {r['status']:<8} {sent:<28} {got:<28}")

    failed = [r["field"] for r in results if r.get("status") in ("FAIL", "HTTP_ERROR", "PARTIAL")]
    ok = [r["field"] for r in results if r.get("status") == "OK"]
    print(f"\nSynced ({len(ok)}): {', '.join(ok) or 'none'}")
    print(f"Not syncing ({len(failed)}): {', '.join(failed) or 'none'}")


if __name__ == "__main__":
    main()
