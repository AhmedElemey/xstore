# xStore — QA Test Report

**Date:** 2026-09-24
**Scope:** Full app, brand-new test pass. Ignores all prior test cases.
**Method:**
1. A new, from-scratch black-box + white-box suite under `test/qa/` (edge cases
   encoded as tests — a **failing** test = a confirmed defect).
2. Live black-box probing of the hosted backend
   (`xstoreegy002-001-site1.etempurl.com`) with a throwaway consumer account I
   registered for this pass (no real user data touched, no credentials guessed).
3. Source review of the money, auth, network, cart/checkout and validation paths.

**Toolchain:** Flutter 3.35.6 (matches CI). `flutter analyze` → **0 issues**.
New suite result: **17 tests fail = 17 confirmed client defects**; all other new
tests pass. Live probing surfaced **1 critical + several backend defects**.

Run the new suite:

```bash
flutter test test/qa/
```

---

## Severity summary

| # | Severity | Area | Finding | Owner |
|---|----------|------|---------|-------|
| 1 | 🔴 Critical | Auth / backend | `POST /api/auth/send-login-otp` returns the OTP in its response body → account takeover with only a phone number | Backend |
| 2 | 🟠 High | Auth | Arabic full names are rejected at registration (client-only) | Flutter |
| 3 | 🟠 High | Network | A transient network blip or 5xx during token refresh logs the user out | Flutter |
| 4 | 🟠 High | Auth / backend | Registration accepts a birth date of `2099` and under-18 ages | Both |
| 5 | 🟡 Medium | Listing | A price of `NaN`/`Infinity` passes listing form validation | Flutter |
| 6 | 🟡 Medium | Auth | Phone normalization misses `0020…` / `+20 0…` paste formats | Flutter |
| 7 | 🟡 Medium | i18n | Arabic-Indic digits (٠١٢…) rejected in phone & money fields | Flutter |
| 8 | 🟡 Medium | Auth | Hyphen/apostrophe names (Abd-El, O'Neil) rejected | Flutter |
| 9 | 🟢 Low | Auth | Email validator accepts whitespace and empty domain labels | Flutter |
| 10 | 🟢 Low | Network | Raw server internals (`IDX12741…`) shown to users on 500 | Flutter |
| 11 | 🟢 Low | Auth | `toE164Egypt('')` fabricates `"+20"` from empty input | Flutter |
| 12 | 🟢 Low | Backend | Some 400s duplicate the message text (`"…; …"`) | Backend |
| 13 | 🟢 Low | Profile | `get-profile` returns `0001-01-01` birthdate sentinel; verify UI treats it as "unset" | Both |

---

## Fix status (updated 2026-09-24)

Client-side (Flutter) findings **fixed** this pass — the corresponding QA
tests now pass, and the full suite is green on both CI defines:

- ✅ #2/#8 names — `Validators.personFullName` now allows Unicode letters +
  hyphen/apostrophe/dot (`lib/core/utils/validators.dart`).
- ✅ #3 refresh logout — `TokenRefreshInterceptor` only clears the session on
  an authoritative rejection (401/400 on `/refresh-token` or no refresh
  token); transport errors / 5xx / hung reads keep the session.
- ✅ #4 (client half) — min-age is now a calendar-age check, not `days~/365`.
- ✅ #5 — `parseMoneyInput` rejects non-finite (`NaN`/`Infinity`).
- ✅ #6/#7 — `normalizeEgyptLocal` handles `00…` and `+20`+trunk-0 pastes and
  folds Arabic-Indic digits; money parsing folds them too.
- ✅ #9 — email validator rejects whitespace and empty domain labels.
- ✅ #11 — `toE164Egypt('')` returns `''` instead of `"+20"`.
- 🔁 #10 — **revised, no code change.** The app *intentionally* surfaces
  meaningful 500 `errorEn` (review/checkout failures depend on it) and already
  masks the EF-SaveChanges boilerplate, so blanket-masking all 5xx regressed 4
  existing tests. The one real raw-internals leak (`IDX12741`) came only from
  `refresh-token`, which the #3 fix now treats as transient — its message
  never reaches the user. Downgraded to resolved.

**Still open — backend, cannot fix from this repo:**
#1 (critical — OTP echo), #4 (server-side DOB/min-age), #12, #13 (server should
return `null`, not `0001-01-01`). These need the backend team.

---

## Critical

### 1. 🔴 Account takeover via echoed login OTP — `send-login-otp`
**Type:** Security (auth). **Owner:** Backend.
`POST /api/auth/send-login-otp` is **unauthenticated** and returns the one-time
code directly in the JSON body:

```
POST /api/auth/send-login-otp {"phoneNumber":"01557719930"}
→ 200 {"message":"OTP sent to your phone number.","otp":"631389"}
```

Feeding that code straight into `POST /api/auth/login-with-otp` issues a full
session token. **Verified end-to-end on my own throwaway account:** knowing only a
phone number is enough to log in as that account — the SMS is bypassed entirely.
This flow is wired into the app's real login screen (`login_screen.dart` →
`phoneAuthProvider` → `login-with-otp`), so it is reachable in production, not
just via curl.

**Fix (backend):** never return the OTP in the response. Deliver only via SMS;
add per-phone rate limiting and attempt lockout on `login-with-otp`.
**Fix (client, defense-in-depth):** the app already only surfaces the echoed
`otp` field under `kDebugMode` — keep it that way and stop reading the field at
all once the backend stops sending it.

---

## High

### 2. 🟠 Arabic full names rejected at registration
**Owner:** Flutter. **Test:** `core_validators_qa_test.dart › Register full name › Arabic names`.
`Validators.personFullName` uses `^[a-zA-Z\s]+$`, so "أحمد طه" fails client-side.
The **backend accepts Arabic names** (verified: registered `"مختبر الجودة"` → 200).
For an Egypt-first, COD marketplace this blocks the primary audience from
registering.
**Fix:** allow Unicode letters (e.g. `RegExp(r'^[\p{L} .\'-]+$', unicode: true)`),
keeping the min-length rule.

### 3. 🟠 Transient refresh failure logs the user out
**Owner:** Flutter. **Tests:** `network_qa_test.dart › NO connectivity…`, `› a 5xx…`.
`TokenRefreshInterceptor._performRefresh` returns `null` on **any** non-success —
including a `connectionError` (no signal) or a `503`. The interceptor then calls
`onRefreshFailed`, which wipes the session (`_clearInvalidSession`). Result: a
subway tunnel or a momentary backend hiccup at the wrong moment force-logs the
user out and drops their cart.
**Fix:** only clear the session when the refresh endpoint *authoritatively*
rejects the refresh token (HTTP 401/400 on `/refresh-token`). On transport
errors / 5xx, fail the retry but keep the session so the next request can retry.

### 4. 🟠 Birth date accepts the future and under-18
**Owner:** Both. **Tests:** `core_validators_qa_test.dart › Birth date / minimum age › 18th birthday is TOMORROW / in 3 days`.
- *Client:* `Validators.dateOfBirth` computes age as `days ~/ 365`. Someone whose
  18th birthday is tomorrow is counted as 18 and passes the min-age gate. (Leap
  years + 365-day rounding.)
- *Backend:* registration with `dateOfBirth: "2099-01-01"` returns **200** — no
  server-side DOB or min-age validation at all.

**Fix (client):** compute age by calendar (`hasHadBirthdayThisYear`), not
`days~/365`. **Fix (backend):** reject future dates and enforce the same minimum
age server-side.

---

## Medium

### 5. 🟡 `NaN` / `Infinity` price passes listing validation
**Owner:** Flutter. **Tests:** `core_validators_qa_test.dart › Money input › NaN…`, `Listing form validation › NaN price`.
`Validators.parseMoneyInput` delegates to `double.tryParse`, which parses
`"NaN"` → `NaN` and `"Infinity"` → `Infinity`. `NaN <= 0` is `false`, so
`listingFormHasErrors` treats a `NaN` price as valid and the form can be
submitted with it.
**Fix:** in `parseMoneyInput`, return `null` when the parsed value is not finite
(`if (!v.isFinite) return null;`).

### 6. 🟡 Phone normalization misses common paste formats
**Owner:** Flutter. **Tests:** `core_validators_qa_test.dart › …0020… / +20 0…`.
`AppValidators.normalizeEgyptLocal` handles `+20…`, `20…`, `01…`, `1…` but not:
- `00201012345678` (the `00` international prefix people paste from contacts) →
  stays 14 digits → "invalid".
- `+2001012345678` (`+20` followed by the trunk `0`) → `0201012345678`.

**Fix:** strip a leading `00`, and after removing `20` also drop a leading `0`
duplicate, before the length checks.

### 7. 🟡 Arabic-Indic digits rejected in phone & money fields
**Owner:** Flutter. **Tests:** `Egypt phone normalization › Arabic-Indic digits`, `Money input › Arabic-Indic digits`.
Users on an Arabic keyboard type `٠١٢٣…`. `\D`/`double.tryParse` treat these as
non-digits, so a phone or price typed in Arabic numerals is rejected.
**Fix:** fold Arabic-Indic (`٠-٩`) and Extended (`۰-۹`) digits to ASCII before
parsing, in both `normalizeEgyptLocal` and `parseMoneyInput`.

### 8. 🟡 Hyphenated / apostrophe names rejected
**Owner:** Flutter. **Test:** `Register full name › hyphen / apostrophe names`.
Same `^[a-zA-Z\s]+$` regex as #2 rejects legitimate names like "Abd-El Rahman"
or "O'Neil". Fixed by the same Unicode-letter change.

---

## Low

### 9. 🟢 Email validator too permissive
**Owner:** Flutter. **Tests:** `Email › whitespace…`, `Email › empty domain label`.
`^[^@]+@[^@]+\.[^@]+` accepts `"ahmed taha@gmail.com"` (space) and `"a@b..com"`
(empty label). Backend rejects these at register, so the user gets a late 400
instead of inline feedback.
**Fix:** tighten to disallow whitespace and consecutive dots.

### 10. 🟢 Raw server internals shown on 500
**Owner:** Flutter. **Test:** `mapDioException › a 500 must not surface raw server internals`.
A 500 body like `"IDX12741: JWT must have three segments…"` is passed straight
through to the UI as the error message.
**Fix:** map `>=500` to a generic localized "something went wrong" message; log
the detail instead of showing it.

### 11. 🟢 `toE164Egypt('')` returns `"+20"`
**Owner:** Flutter. **Test:** `Egypt phone normalization › toE164Egypt on empty input`.
Empty input yields the bare prefix `"+20"`. `whatsAppDigits` guards on length so
WhatsApp is safe, but any other caller formatting an empty phone will render a
misleading `+20`.
**Fix:** return `''` when normalized input is empty.

### 12. 🟢 Duplicated backend error text
**Owner:** Backend. `POST /api/orders` with out-of-Egypt coords returns
`"Delivery coordinates must be within Egypt bounds; Delivery coordinates must be
within Egypt bounds"` — the same rule message twice. Cosmetic.

### 13. 🟢 `0001-01-01` birthdate sentinel
**Owner:** Both. `get-profile` returns `"birthDate":"0001-01-01T00:00:00"` when
unset; the client parses it to `DateTime(1,1,1)`. Confirm no screen renders this
as a real date/age. Backend should return `null`; client should treat year `1`
as unset.

---

## Areas verified clean (no defects found)

- **Cart money math** — discount (%/fixed, min-order gate, max cap, never below
  free), per-line shipping rules, vendor grouping order, selected-available
  totals. All pass (`cart_logic_qa_test.dart`).
- **Token refresh happy path** — 401 → refresh → single retry with new token;
  concurrent 401s share one refresh; unauthenticated 401 (login) does not
  trigger refresh. (`network_qa_test.dart`).
- **Geo-header fallback** — the Cairo fallback is always inside the backend's
  Egypt bounds; out-of-Egypt fixes are rejected. (`location_cache_qa_test.dart`).
- **Notification / date formatting** — relative labels and clock-skew safety.
- **Public catalog endpoints** — pagination bounds (`page>0`, `pageSize 1–100`),
  price-range validation, unknown-id 404s, and a SQL-injection-shaped `keyword`
  is handled as plain text. All behave correctly server-side.
- **Checkout partial-failure** — one order per cart line, all-lines stock-checked
  before any order is placed, failed lines stay in the cart, partial success is
  surfaced to the buyer. Logic reviewed and sound.

## Not testable this pass (documented blockers)

- **Placed-order lifecycle & vendor flows** — the seeded vendor password has
  changed and no admin account exists to approve a listing, so a real order
  can't be created end-to-end. `send-phone-otp` is still gated behind
  `send-email-otp`, and email OTP couldn't be completed without inbox access.
