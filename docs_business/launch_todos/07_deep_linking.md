# Business brief: Deep linking (Universal Links / App Links)

**To-do ID:** `deep-linking`
**Priority:** P1 — sharing & conversion (product links from WhatsApp/social/ads open the app, not a dead page)
**Audience:** Product owner, backend, mobile, QA

---

## 1. Executive summary

A link like `https://xstore.com/product/<id>` shared in WhatsApp, SMS, or a social ad should open the xStore app straight to that product — installed or not (falls back to a web page if not installed). This is table stakes for word-of-mouth and paid-acquisition conversion in a COD marketplace where WhatsApp sharing is already the dominant channel (see doc 05).

**Phase 1 scope:** product detail links only (`/product/:id`). Seller/store pages, order-status links, and category links are natural Phase 2 additions — the mobile-side plumbing (below) already supports adding more path patterns without further native changes.

**Placeholder domain:** all mobile-side config below uses `xstore.com` as a placeholder. Swap it for the real production domain in three places once decided:
- `lib/core/deeplink/deep_link_route.dart` (`supportedDeepLinkHosts`)
- `android/app/src/main/AndroidManifest.xml` (the App Links `<intent-filter>` on `MainActivity`)
- `ios/Runner/Runner.entitlements` + `ios/Runner/RunnerRelease.entitlements` (`applinks:`)

---

## 2. Mobile — what's implemented

| Capability | Status |
|------------|--------|
| Incoming link → in-app route (cold start + while running) | Done — `app_links` package, `lib/core/deeplink/deep_link_handling_provider.dart` |
| URI → go_router path resolver | Done — `lib/core/deeplink/deep_link_route.dart` (`routeFromDeepLinkUri`), unit-tested |
| Android App Links intent-filter (`autoVerify`) | Done, placeholder host |
| iOS Associated Domains entitlement | Done, placeholder host |
| Unified with push-notification routing | Both flows resolve to the same `AppRoutes` path strings and are watched from the same place (`app.dart`), but product links navigate immediately since `/product/:id` is guest-accessible — they do **not** go through the push flow's login-staging (`navigateToPushRoute`/`pendingPushRouteProvider`), which exists because push payloads are only ever sent to logged-in users. |
| Web fallback page at `https://xstore.com/product/<id>` for users without the app | **Not mobile's job** — needs a real web page (backend/marketing), see §4 |

A link that doesn't match a known pattern (wrong host, unrecognized path) is silently ignored — it neither crashes nor navigates anywhere, so unrelated `https://xstore.com/...` links from a future web app don't accidentally hijack in-app navigation.

---

## 3. Backend requirements — domain verification files

Universal Links (iOS) and App Links (Android) both require the app to prove it owns the domain, by hosting a static file. Both are **prerequisites for the app-side config to actually activate** — without them, `https://xstore.com/product/123` just opens a browser, it never opens the app.

### 3.1 Android — `assetlinks.json`

Host at: `https://xstore.com/.well-known/assetlinks.json` (exact path, served as `application/json`, no redirect).

```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.xstore.app",
    "sha256_cert_fingerprints": ["<RELEASE_SIGNING_CERT_SHA256_FINGERPRINT>"]
  }
}]
```

- `package_name` is the **prod** flavor's applicationId (`com.xstore.app` — the `dev` flavor is `com.xstore.app.dev` and isn't worth verifying since App Links testing on dev builds can use `adb shell am start` directly).
- `sha256_cert_fingerprints`: the SHA-256 fingerprint of the **release signing certificate** — get it from Play Console → Setup → App integrity → App signing key certificate, or `keytool -list -v -keystore <release.keystore>`. This is not yet in the repo; whoever holds the release keystore/Play Console access needs to pull it.

### 3.2 iOS — `apple-app-site-association`

Host at: `https://xstore.com/.well-known/apple-app-site-association` (no `.json` extension, served as `application/json`, no redirect, must be reachable over plain HTTPS with a valid cert — Apple's crawler doesn't follow redirects or accept self-signed certs).

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "<APPLE_TEAM_ID>.com.xstore.app",
        "paths": ["/product/*"]
      }
    ]
  }
}
```

- `<APPLE_TEAM_ID>`: the 10-character Apple Developer Team ID (App Store Connect → Membership), not currently in this repo.
- `paths` is scoped to `/product/*` for Phase 1 — widen it (or add entries) as more link types ship, keeping it in sync with what `deep_link_route.dart` actually resolves.

### 3.3 Web fallback

Whoever owns `xstore.com` (marketing site / storefront web app, not this repo) should serve a real page at `/product/:id` — ideally the same product, or at minimum a smart-banner page that deep-links to the app store listings. Until that exists, a user without the app who taps a shared product link gets whatever the domain currently serves at that path (404 if nothing's there yet) — worth prioritizing before this ships to real users, since a broken web fallback undoes the "works even without the app" benefit of Universal/App Links over a bare custom scheme.

---

## 4. QA — test matrix (pre-production)

Universal/App Links can't be meaningfully tested in the simulator/emulator for the OS-level "does tapping a real link in Messages/WhatsApp open the app" behavior — needs physical devices with the **prod flavor** installed (App Links verification is tied to the signed APK's cert; dev builds won't verify against `assetlinks.json`).

- [ ] Domain verification files are live and return 200 with correct content-type (`curl -I https://xstore.com/.well-known/assetlinks.json` / `.../apple-app-site-association`)
- [ ] Android: `adb shell pm get-app-links com.xstore.app` shows the domain as `verified`
- [ ] Android, prod build installed: tap a `https://xstore.com/product/<id>` link in Chrome/Messages/WhatsApp → app opens directly to product detail (no chooser dialog — a chooser means verification failed)
- [ ] iOS, prod build installed (TestFlight or ad hoc): tap the same link in Messages/Notes → app opens directly to product detail (long-press should show "Open in xStore" in the preview)
- [ ] Cold start (app fully killed) via a tapped link → lands on product detail after launch, not home
- [ ] App already running (foreground) → tapping a link navigates immediately, no restart
- [ ] Guest (not logged in, no account) tapping a product link → product detail opens directly, no login prompt (guest-accessible route)
- [ ] Logged-in vendor/courier tapping a product link → product detail opens (product route isn't role-restricted)
- [ ] Unknown/garbage path (`https://xstore.com/nonsense`) → does not crash the app, does not navigate anywhere unexpected
- [ ] Uninstalled: tapping the link opens the web fallback (once §3.3 exists) instead of a dead 404
- [ ] `flutter test test/core/deeplink/deep_link_route_test.dart` green in CI

---

## 5. Dependencies

- Production domain confirmed (currently placeholder `xstore.com` throughout mobile config — see §1)
- Release signing certificate SHA-256 fingerprint (Android) and Apple Team ID (iOS) for the verification files
- Web team/backend to host `.well-known/*` and, ideally, a real product fallback page

## 6. Risks

| Risk | Mitigation |
|------|------------|
| Domain changes after this ships | Three mobile touch-points to update (§1) plus both verification files; a doc without a code comment pointing back here rots — comments were added at each touch-point |
| `assetlinks.json`/`apple-app-site-association` misconfigured (wrong fingerprint/team ID, wrong content-type) | Verification silently fails and links fall back to browser with no error surfaced to the team — check `adb shell pm get-app-links` and Apple's [AASA validator] after any change |
| Marketing shares a link type mobile doesn't resolve yet (e.g. category) | `routeFromDeepLinkUri` returns null for anything unrecognized — link falls back to web/browser rather than crashing, but silently doesn't open the app; keep marketing in sync with what's shipped per phase |

[AASA validator]: https://search.developer.apple.com/appsearch-validation-tool/
