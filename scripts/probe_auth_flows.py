#!/usr/bin/env python3
"""Live probe: exercise all auth endpoints against the integration backend.

Validates HTTP status, response shapes, and app wire contracts (token-only login
responses, get-profile user+store wrapper, otpToken key on OTP flows).

Usage:
  python3 scripts/probe_auth_flows.py [--password PASS] [--skip-register]

Requires network access to the hosted integration backend.
"""
from __future__ import annotations

import argparse
import json
import ssl
import struct
import sys
import time
import urllib.error
import urllib.request
import zlib
from dataclasses import dataclass, field
from typing import Any

BASE = "https://xstoreegy002-001-site1.etempurl.com"
AUTH = "Basic MTEzMjQ4ODM6NjAtZGF5ZnJlZXRyaWFs"
GOOGLE_CLIENT_ID = (
    "304127266125-agfonsmqpsub3tgocn3g4a0hs55tcrg0.apps.googleusercontent.com"
)
CTX = ssl.create_default_context()
DELAY_S = 3.0
MAX_429_RETRIES = 2
RATE_LIMIT_WAIT_S = 65

CONSUMER_PHONE = "01012345678"
CONSUMER_EMAIL = "consumer@test.com"
VENDOR_PHONE = "01112345678"
VENDOR_EMAIL = "vendor@test.com"


@dataclass
class FlowResult:
    flow: str
    status: str  # PASS | FAIL | SKIP | WARN
    detail: str
    http: int | None = None


@dataclass
class ProbeState:
    results: list[FlowResult] = field(default_factory=list)

    def record(self, flow: str, status: str, detail: str, http: int | None = None) -> None:
        self.results.append(FlowResult(flow, status, detail, http))
        icon = {"PASS": "✅", "FAIL": "❌", "SKIP": "⏭", "WARN": "⚠"}.get(status, "?")
        http_s = f" [{http}]" if http is not None else ""
        print(f"{icon} {flow}{http_s}: {detail}")


def sleep() -> None:
    time.sleep(DELAY_S)


def req(
    method: str,
    path: str,
    token: str | None = None,
    json_body: dict[str, Any] | None = None,
    multipart: dict[str, Any] | None = None,
    file_field: tuple[str, bytes, str, str] | None = None,
) -> tuple[int, dict[str, Any] | str]:
    """Returns (status_code, parsed_json_or_error_text)."""
    url = BASE + path
    headers = {"Authorization": AUTH, "Accept": "application/json"}
    if token:
        headers["X-Auth-Token"] = token
    body: bytes | None = None
    if json_body is not None:
        body = json.dumps(json_body).encode()
        headers["Content-Type"] = "application/json"
    elif multipart is not None or file_field is not None:
        boundary = "----XStoreAuthProbe"
        parts: list[bytes] = []
        for k, v in (multipart or {}).items():
            parts.append(
                f'--{boundary}\r\nContent-Disposition: form-data; name="{k}"\r\n\r\n{v}\r\n'.encode()
            )
        if file_field:
            name, data, filename, mime = file_field
            parts.append(
                f'--{boundary}\r\nContent-Disposition: form-data; name="{name}"; filename="{filename}"\r\n'
                f"Content-Type: {mime}\r\n\r\n".encode()
                + data
                + b"\r\n"
            )
        parts.append(f"--{boundary}--\r\n".encode())
        body = b"".join(parts)
        headers["Content-Type"] = f"multipart/form-data; boundary={boundary}"

    for attempt in range(MAX_429_RETRIES + 1):
        request = urllib.request.Request(url, data=body, headers=headers, method=method)
        try:
            with urllib.request.urlopen(request, context=CTX) as resp:
                raw = resp.read()
                if not raw:
                    return resp.status, {}
                try:
                    return resp.status, json.loads(raw)
                except json.JSONDecodeError:
                    return resp.status, raw.decode(errors="replace")
        except urllib.error.HTTPError as e:
            if e.code == 429 and attempt < MAX_429_RETRIES:
                print(f"  429 on {method} {path} — waiting {RATE_LIMIT_WAIT_S}s...")
                time.sleep(RATE_LIMIT_WAIT_S)
                continue
            raw = e.read()
            try:
                payload: Any = json.loads(raw) if raw else {}
            except json.JSONDecodeError:
                payload = raw.decode(errors="replace") if raw else str(e)
            return e.code, payload


def err_text(data: Any) -> str:
    if isinstance(data, dict):
        for k in ("message", "title", "error", "detail"):
            if data.get(k):
                return str(data[k])[:120]
        return json.dumps(data)[:120]
    return str(data)[:120]


def tiny_png() -> bytes:
    """Minimal valid 1×1 PNG."""
    def chunk(tag: bytes, data: bytes) -> bytes:
        crc = zlib.crc32(tag + data) & 0xFFFFFFFF
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", crc)

    ihdr = struct.pack(">IIBBBBB", 1, 1, 8, 2, 0, 0, 0)
    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", ihdr)
        + chunk(b"IDAT", zlib.compress(b"\x00\x02\x00\xFD\xFF\x00\x00\x00\x00\x01\x00\x01"))
        + chunk(b"IEND", b"")
    )


def otp_login(phone: str, state: ProbeState) -> tuple[str | None, str | None]:
    flow = f"OTP login ({phone})"
    status, otp_resp = req("POST", "/api/auth/send-login-otp", json_body={"phoneNumber": phone})
    if status != 200:
        state.record(flow, "FAIL", f"send-login-otp: {err_text(otp_resp)}", status)
        return None, None
    otp = otp_resp.get("otp") if isinstance(otp_resp, dict) else None
    if not otp:
        state.record(flow, "FAIL", "send-login-otp missing debug `otp` echo", status)
        return None, None
    sleep()
    status, login_resp = req(
        "POST",
        "/api/auth/login-with-otp",
        json_body={"phoneNumber": phone, "otpToken": otp, "rememberMe": True},
    )
    if status != 200:
        state.record(flow, "FAIL", f"login-with-otp: {err_text(login_resp)}", status)
        return None, None
    if not isinstance(login_resp, dict):
        state.record(flow, "FAIL", "login-with-otp response not JSON object", status)
        return None, None
    token = login_resp.get("token")
    refresh = login_resp.get("refreshToken")
    if not token:
        state.record(flow, "FAIL", "login-with-otp missing `token`", status)
        return None, None
    if not refresh:
        state.record(flow, "WARN", "login-with-otp missing `refreshToken` (app tolerates empty)", status)
    if login_resp.get("user"):
        state.record(flow, "WARN", "login-with-otp returned `user` (app expects token-only)", status)
    state.record(flow, "PASS", f"token + refreshToken received (otp={otp})", status)
    return token, refresh


def check_get_profile(token: str, phone: str, expect_store: bool, state: ProbeState) -> None:
    flow = f"get-profile ({phone})"
    sleep()
    status, data = req("GET", "/api/auth/get-profile", token=token)
    if status != 200:
        state.record(flow, "FAIL", err_text(data), status)
        return
    if not isinstance(data, dict) or "user" not in data:
        state.record(flow, "FAIL", "missing top-level `user` key", status)
        return
    user = data["user"]
    if not isinstance(user, dict):
        state.record(flow, "FAIL", "`user` is not an object", status)
        return
    phone_ok = str(user.get("phoneNumber", "")) == phone
    has_store = isinstance(data.get("store"), dict)
    if expect_store and not has_store:
        state.record(flow, "FAIL", "vendor account missing `store` object", status)
        return
    if not expect_store and has_store:
        state.record(flow, "WARN", "consumer has unexpected `store` object", status)
    missing = [k for k in ("id", "email", "phoneNumber") if not user.get(k)]
    if missing:
        state.record(flow, "WARN", f"user missing keys: {missing}", status)
    elif phone_ok:
        state.record(
            flow,
            "PASS",
            f"user.id={user.get('id')} store={'yes' if has_store else 'no'}",
            status,
        )
    else:
        state.record(flow, "WARN", f"phone mismatch: got {user.get('phoneNumber')}", status)


def check_refresh(refresh_token: str, state: ProbeState) -> str | None:
    flow = "refresh-token"
    if not refresh_token:
        state.record(flow, "SKIP", "no refreshToken from login")
        return None
    sleep()
    status, data = req("POST", "/api/auth/refresh-token", json_body={"token": refresh_token})
    if status != 200:
        state.record(flow, "FAIL", err_text(data), status)
        return None
    if not isinstance(data, dict) or not data.get("token"):
        state.record(flow, "FAIL", "missing new `token`", status)
        return None
    state.record(flow, "PASS", "new token + refreshToken issued", status)
    return data["token"]


def check_otp_verification(token: str, email: str, phone: str, state: ProbeState) -> None:
    sleep()
    status, data = req("POST", "/api/auth/send-email-otp", token=token, json_body={"email": email})
    if status != 200:
        state.record("send-email-otp", "FAIL", err_text(data), status)
    else:
        otp = data.get("otp") if isinstance(data, dict) else None
        if otp:
            sleep()
            v_status, v_data = req(
                "POST", "/api/auth/verify-email", token=token, json_body={"otpToken": otp}
            )
            if v_status in (200, 204):
                state.record("send-email-otp + verify-email", "PASS", "OTP echoed and accepted", status)
            else:
                state.record("verify-email", "FAIL", err_text(v_data), v_status)
        else:
            state.record("send-email-otp", "WARN", "200 but no debug OTP echo (gateway live?)", status)

    sleep()
    status, data = req(
        "POST", "/api/auth/send-phone-otp", token=token, json_body={"phoneNumber": phone}
    )
    if status != 200:
        state.record("send-phone-otp", "FAIL", err_text(data), status)
    else:
        otp = data.get("otp") if isinstance(data, dict) else None
        if otp:
            sleep()
            v_status, v_data = req(
                "POST", "/api/auth/verify-phone", token=token, json_body={"otpToken": otp}
            )
            if v_status in (200, 204):
                state.record("send-phone-otp + verify-phone", "PASS", "OTP echoed and accepted", status)
            else:
                state.record("verify-phone", "FAIL", err_text(v_data), v_status)
        else:
            state.record("send-phone-otp", "WARN", "200 but no debug OTP echo", status)


def check_forgot_password(email: str, state: ProbeState) -> None:
    sleep()
    status, data = req("POST", "/api/auth/forgot-password", json_body={"email": email})
    if status != 200:
        state.record("forgot-password", "FAIL", err_text(data), status)
        return
    otp = data.get("otp") if isinstance(data, dict) else None
    if not otp:
        state.record("forgot-password", "WARN", "200 but no debug OTP echo", status)
        return
    state.record("forgot-password", "PASS", f"OTP echoed for {email}", status)
    # Wrong OTP — confirms endpoint without mutating password.
    sleep()
    status, data = req(
        "POST",
        "/api/auth/verify-forget-password-otp",
        json_body={
            "email": email,
            "otpToken": "000000",
            "newPassword": "ProbeTemp1!",
            "confirmNewPassword": "ProbeTemp1!",
        },
    )
    if status in (400, 401, 422):
        state.record("verify-forget-password-otp (bad OTP)", "PASS", "rejects invalid OTP as expected", status)
    else:
        state.record("verify-forget-password-otp (bad OTP)", "WARN", err_text(data), status)


def check_password_login(phone: str, password: str, state: ProbeState) -> None:
    flow = f"password login ({phone})"
    sleep()
    status, data = req(
        "POST",
        "/api/auth/login",
        json_body={"phoneNumber": phone, "password": password, "rememberMe": True},
    )
    if status == 200 and isinstance(data, dict) and data.get("token"):
        state.record(flow, "PASS", "token + refreshToken received", status)
    elif status in (401, 400):
        state.record(flow, "FAIL", f"wrong password or invalid credentials: {err_text(data)}", status)
    else:
        state.record(flow, "FAIL", err_text(data), status)


def check_google(as_vendor: bool, state: ProbeState) -> None:
    path = (
        "/api/auth/google/vendor/login"
        if as_vendor
        else "/api/auth/google/consumer/login"
    )
    label = "Google vendor login" if as_vendor else "Google consumer login"
    sleep()
    status, data = req(
        "POST",
        path,
        json_body={"idToken": "invalid-probe-token", "clientId": GOOGLE_CLIENT_ID},
    )
    if status == 401:
        state.record(label, "PASS", f"endpoint live, rejects bad token: {err_text(data)}", status)
    elif status == 404:
        state.record(label, "FAIL", "endpoint not deployed", status)
    else:
        state.record(label, "WARN", err_text(data), status)


def check_social(state: ProbeState) -> None:
    sleep()
    status, data = req(
        "POST",
        "/api/auth/social",
        json_body={"provider": "google", "idToken": "invalid-probe-token"},
    )
    if status == 404:
        state.record("social login (/api/auth/social)", "WARN", "not deployed — app falls back to local session", status)
    elif status == 401:
        state.record("social login (/api/auth/social)", "PASS", "endpoint live, rejects bad token", status)
    else:
        state.record("social login (/api/auth/social)", "WARN", err_text(data), status)


def check_legacy_register(state: ProbeState) -> None:
    sleep()
    status, data = req(
        "POST",
        "/auth/register",
        json_body={
            "role": "consumer",
            "fullName": "Probe",
            "email": "legacy-probe@xstore.test",
            "phoneNumber": "01099999999",
            "password": "ProbeTemp1!",
        },
    )
    if status == 404:
        state.record("legacy /auth/register", "PASS", "404 as expected (app uses /api routes)", status)
    else:
        state.record("legacy /auth/register", "WARN", err_text(data), status)


def check_unknown_phone_otp(state: ProbeState) -> None:
    sleep()
    status, data = req(
        "POST",
        "/api/auth/send-login-otp",
        json_body={"phoneNumber": "01000000000"},
    )
    if status == 404:
        state.record("send-login-otp (unknown phone)", "PASS", "404 for unregistered phone", status)
    elif status == 400:
        state.record("send-login-otp (unknown phone)", "PASS", "400 for unregistered phone", status)
    else:
        state.record("send-login-otp (unknown phone)", "WARN", err_text(data), status)


def check_consumer_register(state: ProbeState) -> None:
    suffix = str(int(time.time()))[-8:]
    phone = f"010{suffix}"
    email = f"probe-consumer-{suffix}@xstore.test"
    sleep()
    status, data = req(
        "POST",
        "/api/auth/consumer/register",
        json_body={
            "fullNameEn": "Probe Consumer",
            "fullNameAr": "مستخدم تجريبي",
            "email": email,
            "phoneNumber": phone,
            "password": "ProbeTemp1!",
            "confirmPassword": "ProbeTemp1!",
            "dateOfBirth": "1995-06-15",
        },
    )
    if status == 200 and isinstance(data, dict) and data.get("token"):
        state.record("consumer register", "PASS", f"new account {phone} / {email}", status)
        sleep()
        prof_status, prof = req("GET", "/api/auth/get-profile", token=data["token"])
        if prof_status == 200 and isinstance(prof, dict) and prof.get("user"):
            state.record("consumer register → get-profile", "PASS", "profile hydrated", prof_status)
        else:
            state.record("consumer register → get-profile", "FAIL", err_text(prof), prof_status)
    elif status == 400 and "already" in err_text(data).lower():
        state.record("consumer register", "SKIP", "phone/email collision — retry later", status)
    else:
        state.record("consumer register", "FAIL", err_text(data), status)


def check_vendor_register(state: ProbeState) -> None:
    suffix = str(int(time.time()))[-8:]
    phone = f"011{suffix}"
    email = f"probe-vendor-{suffix}@xstore.test"
    png = tiny_png()
    sleep()
    status, data = req(
        "POST",
        "/api/auth/vendor/register",
        multipart={
            "fullNameEn": "Probe Vendor",
            "fullNameAr": "بائع تجريبي",
            "email": email,
            "phoneNumber": phone,
            "password": "ProbeTemp1!",
            "confirmPassword": "ProbeTemp1!",
            "dateOfBirth": "1990-01-01",
            "storeNameEn": "Probe Store",
            "storeNameAr": "متجر تجريبي",
            "storeDescriptionEn": "Probe",
            "storeDescriptionAr": "تجريبي",
            "storeCategoryId": "1",
            "storeCityId": "1",
            "storeGovernorateId": "1",
            "whatsappNumber": phone,
        },
        file_field=("profileImage", png, "probe.png", "image/png"),
    )
    if status == 200 and isinstance(data, dict) and data.get("token"):
        state.record("vendor register", "PASS", f"new account {phone} / {email}", status)
        sleep()
        prof_status, prof = req("GET", "/api/auth/get-profile", token=data["token"])
        has_store = isinstance(prof, dict) and isinstance(prof.get("store"), dict)
        if prof_status == 200 and has_store:
            state.record("vendor register → get-profile", "PASS", "profile + store hydrated", prof_status)
        else:
            state.record("vendor register → get-profile", "FAIL", err_text(prof), prof_status)
    elif status == 400:
        state.record("vendor register", "FAIL", err_text(data), status)
    else:
        state.record("vendor register", "FAIL", err_text(data), status)


def check_logout(token: str, state: ProbeState) -> None:
    sleep()
    status, data = req("POST", "/api/auth/logout", token=token)
    if status in (200, 204):
        state.record("logout", "PASS", "session revoked", status)
    else:
        state.record("logout", "WARN", err_text(data), status)


def print_summary(state: ProbeState) -> int:
    print("\n" + "=" * 72)
    print("AUTH FLOW SUMMARY")
    print("=" * 72)
    counts = {"PASS": 0, "FAIL": 0, "WARN": 0, "SKIP": 0}
    for r in state.results:
        counts[r.status] = counts.get(r.status, 0) + 1
    for r in state.results:
        print(f"  [{r.status:4}] {r.flow}")
    print("-" * 72)
    print(
        f"Total: {len(state.results)} | "
        f"✅ {counts['PASS']} | ❌ {counts['FAIL']} | ⚠ {counts['WARN']} | ⏭ {counts['SKIP']}"
    )
    return 1 if counts["FAIL"] > 0 else 0


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--password",
        help="Known password for seed accounts (010/011 test phones). Skips password login if omitted.",
    )
    parser.add_argument(
        "--skip-register",
        action="store_true",
        help="Skip consumer/vendor register probes (creates new backend accounts).",
    )
    args = parser.parse_args()
    state = ProbeState()

    print(f"Probing auth flows at {BASE}\n")

    # --- OTP login + profile (consumer) ---
    consumer_token, consumer_refresh = otp_login(CONSUMER_PHONE, state)
    if consumer_token:
        check_get_profile(consumer_token, CONSUMER_PHONE, expect_store=False, state=state)
        new_token = check_refresh(consumer_refresh or "", state) or consumer_token
        check_otp_verification(new_token, CONSUMER_EMAIL, CONSUMER_PHONE, state)
        check_forgot_password(CONSUMER_EMAIL, state)
        if args.password:
            check_password_login(CONSUMER_PHONE, args.password, state)
        else:
            state.record("password login (consumer)", "SKIP", "pass --password to test")
        check_logout(new_token, state)

    sleep()

    # --- OTP login + profile (vendor) ---
    vendor_token, vendor_refresh = otp_login(VENDOR_PHONE, state)
    if vendor_token:
        check_get_profile(vendor_token, VENDOR_PHONE, expect_store=True, state=state)
        check_refresh(vendor_refresh or "", state)
        if args.password:
            check_password_login(VENDOR_PHONE, args.password, state)
        else:
            state.record("password login (vendor)", "SKIP", "pass --password to test")
        check_logout(vendor_token, state)

    # --- Google / social / edge cases ---
    check_google(as_vendor=False, state=state)
    check_google(as_vendor=True, state=state)
    check_social(state)
    check_legacy_register(state)
    check_unknown_phone_otp(state)

    if not args.skip_register:
        check_consumer_register(state)
        check_vendor_register(state)
    else:
        state.record("consumer register", "SKIP", "--skip-register")
        state.record("vendor register", "SKIP", "--skip-register")

    sys.exit(print_summary(state))


if __name__ == "__main__":
    main()
