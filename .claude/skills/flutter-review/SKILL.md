---
name: flutter-review
description: Team-lead review checklist and accumulated lessons for xStore Flutter code. Use BEFORE writing or modifying any Dart code in this repo, and AFTER completing a change to self-review it. Also use when a review finding or user correction produces a new lesson to record.
---

# xStore Flutter Review — Team Lead Skill

Two jobs:
1. **Before writing Dart code**: read the Lessons Learned log below and apply every relevant lesson.
2. **After a review finding or user correction**: record the lesson (see "Recording a lesson").

The base rules (disposal, Riverpod lifecycles, mounted checks, rebuild storms, over-engineering bans) live in the project CLAUDE.md — this skill holds what we learn on top of them.

## Recording a lesson

Append to the Lessons Learned log whenever any of these happen:
- The review hook or your own self-review catches a real issue in your change.
- The user corrects your approach, style, or a design decision.
- You discover a repo-specific pattern the hard way (an API quirk, a widget that must be used a certain way, a backend contract detail).

Format — one entry, newest last:

```
### YYYY-MM-DD — <short title>
- **What happened:** <the mistake or correction, one sentence>
- **Rule:** <the generalized do/don't to apply next time, one or two sentences>
- **Where it applies:** <file/feature/pattern scope>
```

Rules for the log:
- Generalize: record the *rule*, not the incident. "Dispose PageControllers in carousel widgets" not "fixed banner_carousel.dart".
- No duplicates: if a lesson already covers it, sharpen that entry instead of adding a new one.
- Keep entries short — this whole file gets loaded into context; prune entries that graduate into CLAUDE.md hard rules.
- If a lesson is important enough to be a hard requirement for every change, promote it into CLAUDE.md's rules section and remove it from here.

## Lessons Learned

<!-- Newest entries at the bottom. Do not delete this section; append below. -->

### 2026-07-11 — Log initialized
- **What happened:** Learning loop created; no incidents recorded yet.
- **Rule:** Every review finding or user correction must be appended here before the task is considered complete.
- **Where it applies:** All Dart code in this repo.

### 2026-07-11 — Domain logic in widget files
- **What happened:** `commissionStatusForOrder` (order status → commission status mapping) was defined in `order_price_breakdown.dart` (a widget file) and imported by `vendor_commission_wallet_provider.dart`, creating a provider→widget dependency.
- **Rule:** Pure mapping/business functions go in the feature's `domain/` layer, never in presentation widget files. Providers must never import widget files.
- **Where it applies:** All features; watch for it when a helper function is "convenient" to co-locate with the widget that first used it.

### 2026-07-11 — Financial aggregates capped by page size
- **What happened:** The vendor commission wallet sums fees over a single fetch of 200 orders; a vendor with more due orders gets a silently understated outstanding balance, which gates listing publishes.
- **Rule:** Never compute a money/balance figure from one page of a paginated endpoint. Either loop pages until exhausted, or detect `results == pageSize` and surface that the figure is a lower bound; push for a backend aggregate endpoint for anything financial.
- **Where it applies:** Commission wallet, any future totals/earnings/analytics computed client-side.

### 2026-07-11 — State writes after await in Riverpod notifiers
- **What happened:** Auth flow notifiers (e.g. `LoginNotifier.login`) assign `state = ...` after `await` with no disposal guard; if the user navigates away mid-request, the autoDispose notifier is disposed and the assignment throws an unhandled StateError.
- **Rule:** Guard post-await state writes. In `@riverpod` codegen Notifier classes: `_disposed` flag reset in `build()` + `ref.onDispose(() => _disposed = true)`. In `StateNotifier` subclasses: use the built-in `mounted` getter (state_notifier 1.0.0, line 152 — it exists, despite it being commonly believed to be State-only). Caveat for keepAlive notifiers cleared via `ref.invalidate`: riverpod 2.x reuses the same notifier instance across rebuilds (verified empirically), so a `_disposed` flag reset in `build()` reopens the gate for a fetch still in flight — use a monotonic epoch bumped in `ref.onDispose` and compared per call instead (see `ProfileNotifier._sessionEpoch`).
- **Where it applies:** Every async method in `@riverpod` Notifier and `StateNotifier` classes that writes `state` after an await. 2026-07-18: audit found only auth/profile hardened; product_detail, product_reviews, explore, checkout, order_detail, listing_form, my_listings, vendor_orders, vendor_order_detail were then guarded the same way — apply the pattern to every NEW notifier from day one.

### 2026-07-11 — StateNotifier with Timer needs a dispose override
- **What happened:** `PhoneAuthNotifier` (StateNotifier) started a `Timer.periodic` resend cooldown but had no `dispose()` override; a disposal during the 60s cooldown would leave the timer firing into a disposed notifier.
- **Rule:** Any `StateNotifier` owning a `Timer`/`StreamSubscription` must override `dispose()` to cancel it, and long-lived periodic callbacks must check `mounted` before writing state.
- **Where it applies:** `phone_auth_provider.dart` and any StateNotifier-based provider (legacy pattern in this repo alongside codegen `@riverpod`).

### 2026-07-11 — Route role-classification must be verified against call sites
- **What happened:** While adding role guards, `/order/:id` looked consumer-only but vendors also open it (`/incoming-orders` → OrdersScreen → OrderCard); restricting it would have broken the vendor incoming-orders flow.
- **Rule:** Before classifying a route as role-restricted, `rg` every `context.push`/`go` call site for it and trace which role reaches each one. Shared routes in this repo: `/order/:id`, `/product/*`, `/seller/*`, `/profile*`, notifications, info screens. Guards live centrally in `computeXStoreAuthRedirect` + `isVendorRestrictedRoute`/`isConsumerRestrictedRoute` (app_routes.dart) — extend those, never scatter per-screen checks.
- **Where it applies:** Any new route or role-gated feature touching `lib/core/router/`.

### 2026-07-11 — Guest mode: three enforcement layers, one flag
- **What happened:** Guest mode was added as a persisted `guestModeProvider` flag with enforcement in exactly three places: `isGuestAccessibleRoute` + `computeXStoreAuthRedirect` (routes), and `requireLogin(context, ref)` in `shared/utils/` (inline actions on browsable screens).
- **Rule:** Account-gated behavior goes through `requireLogin` — never hand-roll `authProvider.valueOrNull == null` checks at action sites. It shows a decision dialog (Sign in / Not now) and returns false synchronously; the caller just aborts. New browse-safe routes must be added to `isGuestAccessibleRoute` or guests get bounced to login. Prefs-backed flags needed by the router at cold start must be synced synchronously in splash (`enable()` before `context.go`) — the provider's lazy prefs load races the first redirect otherwise.
- **Where it applies:** Any new user-triggered action (cart, wishlist, reviews, chat, checkout) and any new route added to the router.

### 2026-07-11 — The route redirect is a safety net, not the guest UX
- **What happened:** Guest gating was wired into inline actions only; tapping nav tabs (wishlist/orders/profile), the home cart icon, or help-screen shortcuts hit the silent route redirect and dumped guests on the login screen with no dialog — user reported "the pop up is not showing".
- **Rule:** Every user-visible entry point to an account-bound route must call `requireLogin` at the tap site (bottom-nav `_onTap`, header icons, CTA buttons on guest-browsable screens). The `computeXStoreAuthRedirect` guard only backstops deep links and programmatic navigation. When adding a gated route, grep for every widget that navigates to it and gate each tap.
- **Where it applies:** `xstore_bottom_nav.dart`, any header/app-bar action icons, CTA buttons on guest-accessible screens (help/info), and every future navigation into cart/orders/profile/wishlist/notifications.

### 2026-07-11 — Lazy async providers read as Loading in widget tests
- **What happened:** A widget test tapped a button whose handler did `ref.read(authProvider).valueOrNull` — the first-ever read of the lazy async provider returned AsyncLoading, so a signed-in fake user read as null and the test failed.
- **Rule:** In widget tests exercising handlers that `ref.read` an async provider, warm the provider up in the harness (`ref.watch` it in the tree, then `pumpAndSettle`) so tap-time reads see AsyncData — mirroring the real app where splash awaits auth first.
- **Where it applies:** All widget tests around auth-gated actions or any FutureProvider/async-notifier read inside callbacks.

### 2026-07-11 — Live backend is the default; mock is opt-in
- **What happened:** The repo flipped from mock-first (MOCK defaulted true, placeholder API URLs) to live-first: `MockConfig` defaults MOCK=false, and `ApiEndpoints.baseUrl` falls back to the hosted backend `https://xstoreegy-001-site1.jtempurl.com` (HTTPS verified; 401 without the Basic license key, real data with it).
- **Rule:** Assume every run/build/test hits the live backend unless `--dart-define=MOCK=true` is passed. When adding datasource code, the real API path is the primary path — mock branches are legacy fixtures. Tests must keep their `skip: MockConfig.useMock ...` guards so both CI modes stay green.
- **Where it applies:** All datasources, Taskfile/CI defines, and anything reading `MockConfig.useMock`.

### 2026-07-11 — Backend enums are 1-based C#; 0 means unset, not the first member
- **What happened:** The app mapped listing conditions 0-based (0=New…) from a "confirmed by live probe" comment, but the probe data all had `condition: 0` — the C# default for an unset field, not a member. The real contract is `ListingCondition { New=1, LikeNew=2, Good=3, UsedForParts=4 }`, so every parsed condition was off by one and the app offered 5 seller options against 4 backend values (lossy round-trip).
- **Rule:** Never infer enum wire codes from seed data — ask for the C# enum declaration. Treat `0` as unset/null for any backend enum. Keep app enums 1:1 with backend enums (no app-only members). Condition mapping is centralized in `listing_model.dart` (`listingConditionFromToken`/`ToWire`/`Label*`) with a contract test in `test/listing_condition_wire_test.dart` — extend those, don't add local switches.
- **Where it applies:** All wire-enum handling (condition, listing status, order status, payment method) in `data/models`.

### 2026-07-11 — This app cannot run on Flutter web; verify flows with widget tests
- **What happened:** Attempting browser verification of the guest sheet hit a permanent black screen: `firebase_options.dart` throws `UnsupportedError` for web inside `bootstrap()` before `runApp`, so the web build never renders a frame.
- **Rule:** Don't burn time on `flutter run -d chrome/web-server` for this repo until web Firebase options exist. Prove UI flows with widget tests (GoRouter stub harness in `test/require_login_test.dart` is the template). When a user reports old behavior that the current code demonstrably gates, suspect a stale build first and say so — hot reload doesn't always re-run existing widgets; ask for hot restart or a rebuild.
- **Where it applies:** All manual verification attempts; any future "works in code, user sees old behavior" reports.

### 2026-07-11 — Fixed-height Columns in bottom sheets overflow
- **What happened:** The sign-in sheet's Column (icon + title + body + two buttons) overflowed by 14px inside a default `showModalBottomSheet` height constraint — caught only because a widget test rendered it in a 600px-tall viewport.
- **Rule:** Bottom-sheet content must be wrapped in `SingleChildScrollView` (or use `isScrollControlled` with explicit constraints) — never rely on the content fitting the sheet's max height. Widget-test every new sheet/dialog; the test viewport catches overflows real phones might hide.
- **Where it applies:** All `showModalBottomSheet`/`showDialog` content in `shared/` and feature widgets.

### 2026-07-11 — Custom validateStatus can silently disable token refresh
- **What happened:** `LegacyRouteOptions.allowNotFound` used `validateStatus: status < 500`, which accepted 401/403 as normal responses — `TokenRefreshInterceptor` only acts in `onError`, so expired sessions on legacy routes would never refresh and would render as "empty data" instead.
- **Rule:** Any per-request `validateStatus` override must keep 401/403 as errors. Widen acceptance only for the specific status being tolerated (e.g. `2xx || 404`), never with a blanket `< 500`.
- **Where it applies:** All Dio `Options(validateStatus: ...)` overrides; currently `legacy_route_options.dart` used by orders, store-hours, and profile datasources.

### 2026-07-11 — Verify review-hook claims against package source
- **What happened:** The automated review hook flagged `if (!mounted)` in a StateNotifier as a runtime error, claiming StateNotifier has no `mounted`; checking `~/.pub-cache/.../state_notifier.dart` proved the property exists (state_notifier 1.0.0 line 152) and the flag was a false positive. It recurred 2026-07-18, plus a second misread: the hook called `if (!mounted) return result.isRight();` "inconsistent" while every sibling method used the identical pattern — it only saw the partial edit.
- **Rule:** When a review claim is about an API's existence/signature, verify against the package source in the pub cache; when it claims inconsistency or bypassed logic, re-read the full file — hooks judge partial snippets. Only rewrite after the claim survives verification.
- **Where it applies:** All hook/reviewer feedback that asserts framework/package API facts or cross-method consistency.

### 2026-07-11 — Surface API error bodies on 401
- **What happened:** Login 401 from `{"error":"Invalid email or password."}` was mapped to Dio's generic status-code boilerplate in the UI because `mapDioException` only read `e.message`, not the response body.
- **Rule:** For `badResponse`, always try `_serverErrorMessage` (`error`, `message`, nested `error.message`) before falling back to Dio's message — especially on 401/403 where the backend sends actionable text.
- **Where it applies:** `dio_error_mapper.dart` and any new error-mapping code.

### 2026-07-11 — Self-referencing implements clause
- **What happened:** While rewriting the wishlist datasource header, the impl class was declared as `class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSourceImpl` — implementing itself instead of the abstract interface, a compile error.
- **Rule:** When editing a `class XImpl implements X` declaration, re-read the `implements` target after the edit; the Impl/interface name pair differs by only a suffix and is easy to autocomplete wrong.
- **Where it applies:** All datasource/repository interface+impl pairs in `data/` layers.

### 2026-07-11 — Legacy store-hours 404 until backend ships
- **What happened:** `GET /vendors/{id}/store-hours` returns 404 on the hosted backend (no `/api` equivalent yet); profile load logged errors and store-open badge stayed broken.
- **Rule:** Undeployed legacy modules (`/vendors/*/store-hours`, `/users/*/store`, `/orders/*`) get 404 fallbacks at the datasource: reads return sensible defaults, writes/toggles persist in the in-memory cache for the session. Use `LegacyRouteOptions.allowNotFound()` so Dio does not throw (and the debug logger stays quiet). Skip vendor-only fetches when `user.role != UserRole.vendor`.
- **Where it applies:** `legacy_route_options.dart`, `store_hours_datasource.dart`, `profile_remote_datasource.dart`, `orders_remote_datasource.dart`.

### 2026-07-11 — Dialog dismiss must use dialog context
- **What happened:** "Confirm all pending" on `VendorOrdersScreen` called `Navigator.pop(context)` with the screen's `context` inside a `showDialog` builder that discarded `dialogContext`; go_router popped the shell branch instead of the overlay, emptying the stack.
- **Rule:** In `showDialog`/`showModalBottomSheet` builders, always `Navigator.pop(dialogContext)` (or `Navigator.of(dialogContext).pop()`) — never the parent screen `context`. Follow `require_login.dart` / `order_card.dart`.
- **Where it applies:** Any overlay (dialog, bottom sheet) inside a `StatefulShellRoute` tab or other go_router-managed navigator.

### 2026-07-11 — No postFrameCallback fetch on empty list state
- **What happened:** `ProfileMenuBlocks` called `fetchOrders()` in a `postFrameCallback` whenever `totalCount == 0` — after a failed or empty fetch, every rebuild re-fired the request, hammering `/orders/vendor/{id}` in a loop.
- **Rule:** Never tie a fetch side-effect to "list is empty" without a one-shot guard (`hasLoaded`, error latch, or fetch only from the destination screen). Profile badges read existing provider state; they don't prefetch.
- **Where it applies:** Profile widgets, any `build()`-time `addPostFrameCallback` that triggers network calls.

### 2026-07-11 — Paginated list endpoints use 1-based page
- **What happened:** `allCities` / `allGovernments` / `allStoreCategories` called the live API with `page=0`, which returns HTTP 500; `page=1` (or omitting `page`) returns 200.
- **Rule:** The xStoreEcommerce `/api/*` list endpoints use **1-based** `page`. Never send `page=0` on the wire — use `page: 1` for the first page, or translate 0-based notifier state at the datasource boundary (see `notifications_remote_datasource.dart`: `page + 1`).
- **Where it applies:** Cities, governments, store categories, listings, reviews, notifications — any paginated GET.

### 2026-07-11 — Listing write payload: flat body, int condition
- **What happened:** Earlier probes concluded POST/PUT needed a `{"command": {...}}` wrapper; that wrapper passes validation but EF SaveChanges 500s. The user's working Postman example is a flat body — but `"condition": "New"` (string) still 400s; `"condition": 0` (int) returns 201. Flat + int condition + string/null `attributes` is the live contract.
- **Rule:** POST/PUT `/api/listings` send fields at the root — never wrap in `command`. Wire `condition`/`status` as integer codes via `listingConditionToWire` / `listingStatusToWire`. Wire `attributes` as a JSON string (`""`, `jsonEncode(map)`, or null) — never a JSON object. Probe both flat and wrapped shapes before blaming backend SaveChanges.
- **Where it applies:** `listing_remote_datasource.dart`, `listing_model.dart` wire helpers.

### 2026-07-11 — Listing write payload uses command wrapper
- **What happened:** `POST /api/listings` returned 400: `command` required, `condition` rejected as `"LikeNew"` string, `attributes` rejected as `{}` object.
- **Rule:** ~~Confirmed live contract for create/update: wrap fields in `{"command": {...}}`~~ **Superseded** by the flat-body lesson above (2026-07-11 same day). Keep integer `condition`/`status` and string `attributes` — drop the wrapper.
- **Where it applies:** `listing_remote_datasource.dart`, `listing_model.dart` wire helpers (`listingConditionToWire`, `listingStatusToWire`).

### 2026-07-11 — Parse formatted money with Validators.parseMoneyInput
- **What happened:** Add-listing commission preview used `double.tryParse` on `form.priceInput` after `_formatPriceInput` inserted commas (`1,500`); parse failed above 999 so price read as null and the breakdown hid.
- **Rule:** Any UI reading `priceInput` / `compareAtPriceInput` / `shippingCostInput` from listing form state must use `Validators.parseMoneyInput` (strips commas) — never raw `double.tryParse`.
- **Where it applies:** `add_listing_screen.dart`, any widget displaying derived values from formatted money fields.

### 2026-07-11 — Never push a StatefulShellRoute branch from outside the shell
- **What happened:** After publish, Navigator threw `!keyReservation.contains(key)` (duplicate page keys). `/listing/add` lives in a shell branch; `MyListingsScreen` used `context.push('/listing/add')` from the overlay route `/listing/my`, stacking the same branch route twice. The publish flow also double-navigated (`go` with `?msg=published` then `go` again to strip the query).
- **Rule:** Routes registered under `StatefulShellRoute` branches are reached with `context.go` (tab switch), never `context.push` from sibling/overlay routes. One navigation per success — show snackbar then `go` once; don't pass toast state via query params that trigger a second `go` on the destination screen.
- **Where it applies:** `my_listings_screen.dart`, `add_listing_screen.dart`, any future shell-tab route (`listingAdd`, home/explore tabs).

### 2026-07-11 — POST /api/listings 500 was the command wrapper, not EF
- **What happened:** Create listing 500s were attributed to a backend EF bug; re-probing showed the `command` wrapper 500s while the flat Postman body (with int `condition`) returns 201. The earlier "backend gap" diagnosis was wrong for the current API.
- **Rule:** Before mapping opaque SaveChanges 500s to `listingPublishServerError`, diff the app's write shape against a known-good flat probe — wrapper vs flat is a common false positive. Keep the user-facing server-error mapping for genuine 500s after the payload shape is confirmed.
- **Where it applies:** `listing_remote_datasource.dart`, `listing_form_notifier.dart`, `dio_error_mapper.dart`.

### 2026-07-11 — Profile update-profile wire keys are asymmetric
- **What happened:** Edit Profile save used a partial PUT body and skipped `avatarUrl` when null, so avatar removal never reached the server; GET used `birthDate`/`whatsAppNumber`/`instagramPage` while read parsing only looked for `dateOfBirth`/`whatsappNumber`/`instagramHandle`.
- **Rule:** Derive update-profile PUT keys from CONFIRMED get-profile / `UserModel.fromJson` field names; keep documented write-only aliases (`whatsAppNumber`, `instagramPage`); always send `avatarUrl` (null to clear); add `optString` fallbacks in `fromJson` when read/write keys differ.
- **Where it applies:** `profile_remote_datasource.dart`, `user_model.dart`, `profile_state.dart` `toEditedUser()`.

### 2026-07-11 — Bilingual store name: parse vs display
- **What happened:** `UserModel.fromJson` collapsed `storeName` with legacy-first precedence and treated `""` as present, so localized keys were skipped; mock get-profile dropped lat/lng on fetch after save.
- **Rule:** Match `UserEntity.displayName(isArabic)`: add `displayStoreName(isArabic)` for runtime locale; in `fromJson` prefer `storeNameEn`/`storeNameAr` before legacy `storeName`; `optString` treats blank/whitespace as absent; mock get/update share one `_mockUserModelFromEntity` so save→fetch round-trips all profile fields.
- **Where it applies:** `user_model.dart`, `user_entity.dart`, `profile_remote_datasource.dart`, profile wire tests.

### 2026-07-11 — get-profile response wrapper
- **What happened:** Live GET/PUT `/api/auth/get-profile` returns `{"user":{...},"store":...}` but `ProfileRemoteDataSource.getProfile` parsed the top-level map as a user; login/register return `{token, refreshToken}` only — no user object.
- **Rule:** Unwrap profile responses through shared `parseProfileUserJson` (wrapper first, raw user map as safety net); never assume login and get-profile share the same shape; verify with a live probe before fixing parsers.
- **Where it applies:** `user_model.dart`, `auth_remote_datasource.dart`, `profile_remote_datasource.dart`.

### 2026-07-11 — Prefetch enriched profile after auth
- **What happened:** `profileNotifierProvider` stayed empty until ProfileScreen mounted, so stats/vendor enrichment lagged behind `authProvider` even though login already called get-profile for identity.
- **Rule:** After session adopt/restore, fire-and-forget `prefetchProfileData(ref)` → `ProfileNotifier.refreshProfileData()`; clear with `resetProfileData(ref)` on logout; one shared refresh method for prefetch, save, and pull-to-refresh — flag redundant on-mount fetches before removing.
- **Where it applies:** `profile_provider.dart`, `auth_provider.dart`, profile screens.

### 2026-07-11 — Reset enriched profile on forced 401 logout
- **What happened:** Token-refresh failure in `dio_provider` cleared auth storage and invalidated `authProvider` but left `profileNotifierProvider` warm with the previous user's stats until explicit logout.
- **Rule:** Any forced session clear (401 refresh failed, logout, delete account) must call `resetProfileData(ref)` alongside `ref.invalidate(authProvider)`; `TokenRefreshInterceptor.onRefreshFailed` only — not on retried 401s that refresh succeeds.
- **Where it applies:** `dio_provider.dart`, `auth_provider.dart`, `profile_provider.dart`.

### 2026-07-11 — Side-effects fired from inside build() see the provider as Loading
- **What happened:** `Auth.build()`'s restore fold called `prefetchProfileData(ref)` before `build()` returned; `refreshProfileData` immediately did `ref.read(authProvider).valueOrNull`, which on a first build is `AsyncLoading` with no previous value → null user → the prefetch reset profile state instead of loading it (proven with a minimal Riverpod repro). The existing prefetch test only covered `adoptSession`, which sets `state` before prefetching, so it stayed green.
- **Rule:** Never fire, from inside a provider's `build()`, a side-effect that synchronously reads that same provider's async state — on first build `valueOrNull` is null (invalidate-rebuilds keep the previous value, masking the bug). Either pass the value explicitly into the side-effect or defer it past build completion (`Future(() => ...)`). For first-build-only side-effects, a notifier instance field works: riverpod 2.x reuses the instance across `ref.invalidate` rebuilds (see `Auth._restoredOnce`). Test the cold-start/restore path, not just the adopt path.
- **Where it applies:** `auth_provider.dart` prefetch wiring; any cross-provider side-effect launched from a `build()` method.

### 2026-07-12 — Epoch guard on every await in keepAlive notifiers
- **What happened:** `ProfileNotifier._sessionEpoch` guarded only `refreshProfileData()`; `saveProfile()` had multiple post-await `state =` writes and could repopulate profile state after `resetProfileData` mid-save.
- **Rule:** In keepAlive notifiers using `_sessionEpoch`, capture `epoch` at method entry and compare after **every** `await` before any `state` write or `ref.invalidate` — including multi-step flows (`saveProfile`, not just single-fetch methods). Add a mid-invalidate race test per flow.
- **Where it applies:** `ProfileNotifier` and any keepAlive `@Riverpod` notifier cleared via `ref.invalidate`.

### 2026-07-12 — No mount-time refresh when auth prefetch already runs
- **What happened:** `ProfileScreen` called `refreshProfileData()` on mount while cold-start/adopt prefetch already loaded the same data — redundant double-fetch on tab open.
- **Rule:** One shared refresh entry point per resource; if auth adopt/restore prefetches enriched profile, screens read `profileNotifierProvider` and rely on pull-to-refresh for explicit reload — don't re-fetch on mount. Verify `isLoading && profile == null` still shows skeleton while prefetch is in flight.
- **Where it applies:** `profile_screen.dart`, any tab that mirrors a global prefetch.

### 2026-07-15 — Profile tab: don't block on enriched-profile fetch failure when auth has identity
- **What happened:** Login/restore already hydrates `authProvider` via get-profile, but a failed `profileNotifierProvider` prefetch showed a full-page `ErrorStateWidget` — the Profile tab looked broken even though the session user was available.
- **Rule:** Full-page profile error only when auth has no identity (`user.id.isEmpty` stub). Otherwise render the tab from `authProvider` and show the existing inline retry banner for enriched-profile failures. On mount, call `refreshProfileData()` only when `profile == null && !isLoading && error == null` (prefetch missed) — never duplicate an in-flight prefetch.
- **Where it applies:** `profile_screen.dart`, `profile_provider.dart` `refreshProfileData()`.

### 2026-07-13 — Phone-first auth: confirmed backend contract
- **What happened:** Switching auth to phone+password, live probes confirmed: consumer/vendor register succeed with the `email` key omitted entirely; `POST /api/auth/login`'s `emailOrPhone` accepts the 11-digit local phone; but `POST /api/auth/forgot-password` is email-only (it emails the OTP — omitting `email` 500s inside the mailer, and a phone value silently no-ops).
- **Rule:** Phone is the account identifier; wire the normalized local phone (`AppValidators.normalizeEgyptLocal`) into `emailOrPhone`. Omit the `email` key from register bodies when blank — don't send `""`. Password reset requires an email until the backend adds SMS OTP reset; keep register's optional email pitched as "for password recovery".
- **Where it applies:** `auth_remote_datasource.dart`, `LoginNotifier`, register step-2 validation, `forgot_password_screen.dart`.

### 2026-07-13 — build_runner --build-filter deletes everything else's outputs
- **What happened:** `dart run build_runner build --delete-conflicting-outputs --build-filter="lib/features/auth/..."` regenerated the auth files but **deleted every other tracked `.g.dart` in the repo**, breaking analyze until a full rebuild restored them.
- **Rule:** In this repo never combine `--build-filter` with `--delete-conflicting-outputs`; run the full `dart run build_runner build --delete-conflicting-outputs` (~16s). If generated files show as deleted in `git status`, rerun the full build rather than checking them out.
- **Where it applies:** All codegen (freezed/riverpod/json) regeneration.

### 2026-07-13 — Admin-dashboard prototype: responsive rules go last, size inline SVGs
- **What happened:** Making the dashboard prototype responsive, the mobile `.drawer` override silently lost because the media query sat mid-file before the base `.drawer` rule (media queries add no specificity — later equal-specificity rules win); separately, the new hamburger icon rendered 0×0 because topbar `<svg>`s had no CSS size (pre-existing: bell/help/search icons were invisible too).
- **Rule:** In `docs_business/admin-dashboard/src/styles.css`, all `@media` responsive overrides live in the final section of the file — never insert them mid-file. Inline SVG icons need an explicit CSS width/height on their container class. `xstore_admin_dashboard.html` is generated by inlining the three `src/` files — regenerate it after any src change, never hand-edit it.
- **Where it applies:** `docs_business/admin-dashboard/` (HTML prototype, not Flutter).

### 2026-07-15 — Medium_Phone_API_35 AVD has corrupted package-manager state
- **What happened:** `flutter run` on the Medium_Phone_API_35 emulator failed with "Error type 3: Activity class does not exist" despite a clean install; PM resolved zero activities for ALL sideloaded apps (xstore prod, dev, and unrelated apps), and reboot + reinstall didn't fix it. The APK itself was proven fine via `aapt dump badging`.
- **Rule:** When `am start` says an installed activity "does not exist", first check whether OTHER sideloaded apps resolve (`cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.LAUNCHER <pkg>`); if they all fail, the AVD's package-manager state is corrupted — switch AVDs (flutter_emulator works) instead of debugging the app. Note: wiping Medium_Phone_API_35 loses its signed-in Google account, which is needed for Google sign-in tests.
- **Where it applies:** All emulator runs/verification on this machine.

### 2026-07-15 — dart:developer log() is invisible in flutter run console
- **What happened:** A credential debug dump used `developer.log(...)`; nothing appeared in the `flutter run` output because dart:developer logs go to the VM/DevTools logging stream, not the run console — wasted a full rebuild cycle discovering it.
- **Rule:** For debug output that must be visible in `flutter run` / logcat, use `debugPrint` (one call per field keeps long tokens on single copy-pasteable logcat lines, <4KB each). Reserve `developer.log` for DevTools-structured logging.
- **Where it applies:** All debug/diagnostic printing in this repo.

### 2026-07-15 — Logout must clear local state even when provider sign-outs throw
- **What happened:** `AuthRepositoryImpl.logout()` awaited `signOutSocial()` (Firebase+Google+Facebook `Future.wait`) before the secure-storage deletes; the unconfigured Facebook SDK (placeholder app ID) made it throw, the deletes were skipped, and `restoreSession` re-hydrated the "logged-out" user — logout appeared to do nothing. The method's own comment promised local cleanup "always" runs, but only the remote call was guarded.
- **Rule:** In sign-out flows, every external/best-effort step (remote API, provider SDK sign-outs) gets its own try/catch; local session clearing runs unconditionally and is the source of truth. When a comment claims "always", verify the control flow actually guarantees it.
- **Where it applies:** `auth_repository_impl.dart` logout, forced 401 cleanup in `dio_provider`, any future account-deletion flow.

### 2026-07-17 — Adding a UserRole member touches four coupled places
- **What happened:** Adding `UserRole.courier` required coordinated changes: shell branches in `app_router.dart`, tab labels/icons in `xstore_bottom_nav.dart` (now length-driven, no hardcoded 5), and role-aware redirect fallbacks in `computeXStoreAuthRedirect` — `/home`/`/explore` only exist inside the consumer/vendor shells, so any redirect returning `AppRoutes.home` sends a courier to a "no route" error page.
- **Rule:** A new role = new shell branch list + matching nav tab list (kept in sync, both switch on `UserRole`) + a role-aware "home" target in every redirect fallback + restricting the role's tabs from other roles and vice versa. Grep `AppRoutes.home` in redirect logic whenever shell membership changes.
- **Where it applies:** `lib/core/router/`, `xstore_bottom_nav.dart`, any future role or shell-tab change.

### 2026-07-17 — Mock login matchers must key on phone digits
- **What happened:** A mock courier login matched identifiers containing "courier"/"driver", but the login UI is phone-first — the field validates an 11-digit Egyptian mobile and `LoginNotifier` sends `normalizeEgyptLocal(state.phone)` (digits only), so a keyword/email matcher was unreachable from the real screen.
- **Rule:** Any identifier-routed mock behavior in auth must match what the UI actually transmits: normalized phone digits (compare via `AppValidators.normalizeEgyptLocal` against the seed user's phone). Keep keyword forms only as test conveniences. Trace notifier → datasource before choosing a matcher key.
- **Where it applies:** `mock_users.dart` login matchers, any future identifier-based dev/demo shortcut in the auth flow.

### 2026-07-18 — Controllers created in show-dialog/sheet helper functions are never disposed
- **What happened:** A full memory audit found 10+ `TextEditingController`s created inside `show*Sheet`/dialog helper functions (checkout add-address sheet, order card reject/ship/review flows, order action buttons, cart quantity prompt, store-hours message sheet) with zero disposals — every open leaks the controllers.
- **Rule:** A controller created outside a `State` (in a `showDialog`/`showModalBottomSheet` helper) must be disposed after the sheet/dialog future resolves (`await show...; ctrl.dispose();`), or the sheet content must be a StatefulWidget owning its controllers. Grep helper functions for `TextEditingController(` during review.
- **Where it applies:** All `show*` helper functions and dialog builders in `presentation/widgets` and screens.

### 2026-07-18 — Static datasource caches survive logout
- **What happened:** `orders_remote_datasource.dart` keeps `static _consumerCache`/`_vendorCache` (and cart keeps `static _items`) that are never cleared on logout — a second account on the same device can read the previous user's orders from the warm cache.
- **Rule:** Datasource-level caches must be instance fields on autoDispose-scoped providers, or be explicitly cleared in the logout/forced-401 path alongside `resetProfileData`. No user-scoped data in `static` fields.
- **Where it applies:** `orders_remote_datasource.dart`, `cart_remote_datasource.dart`, any future datasource cache.

### 2026-07-18 — Family providers without autoDispose accumulate one instance per argument
- **What happened:** `vendorOrderDetailProvider` was a plain `StateNotifierProvider.family` — every order id ever opened kept its notifier and fetched order in memory for the rest of the session.
- **Rule:** `.family` providers for screen-scoped state must be `.autoDispose.family` (or codegen `@riverpod`, which defaults to autoDispose). A keepAlive family is a per-argument cache and must be a deliberate, commented decision.
- **Where it applies:** All `.family` providers, especially detail-screen notifiers keyed by entity id.

### 2026-07-17 — Sliver lists below the fold aren't built in widget tests
- **What happened:** A test expected 3 `DeliveryOrderCard`s but found 2 — the third lived in a lazily-built `SliverList` section below the 600px test viewport, so it was never constructed.
- **Rule:** In widget tests over lazy lists (SliverList/ListView.builder), assert only what fits the viewport, then `tester.scrollUntilVisible(...)` before asserting off-screen items — don't shrink the data to dodge it unless section ordering itself is under test.
- **Where it applies:** All widget tests over scrollable feature screens.

### 2026-07-18 — Count strings need ICU plurals from the start
- **What happened:** The delivery card's items summary rendered "1 items" — the arb key used a plain `{count} items` interpolation instead of a plural.
- **Rule:** Any l10n string containing a count uses ICU plural syntax in BOTH locales from the first draft — Arabic needs its own categories (`=1`, `=2`, `few`, `other`), not a copy of the English two-form plural.
- **Where it applies:** All new arb keys with numeric placeholders.

### 2026-07-18 — Web bootstrap dies before runApp; app is un-runnable on `flutter run -d web-server`
- **What happened:** A screenshot-capture session found the app renders a permanently blank canvas on web: `bootstrap()` awaits `Firebase.initializeApp(options: DefaultFirebaseOptions.forFlavor(...))` and `forFlavor` throws `UnsupportedError('Web Firebase options are not configured yet.')` under `kIsWeb`, so `runApp` is never reached. No visible error — just an empty `flt-scene-host`, while the DDC console logs a single DartError. Also: `google_sign_in_web` asserts at startup because no `google-signin-client_id` meta tag exists for web.
- **Rule:** Startup code must not `await` a call that is known to throw on a supported run target before `runApp`. Either register real web Firebase options, or branch on `kIsWeb` (skip AppCheck/FCM, supply web options) so mock-mode web runs. When debugging "blank canvas" on Flutter web, check `flt-scene-host` children and page errors first — a pre-runApp throw looks identical to a slow load.
- **Where it applies:** `lib/main.dart` bootstrap, `lib/core/firebase/firebase_options.dart`, any CI/tooling that runs the app with `-d web-server` (mock QA, screenshot jobs).

### 2026-07-18 — Vendor Incoming Orders list never renders: infinite-height constraint crash
- **What happened:** On `/vendor-orders` (mobile web viewport 390x844, MOCK=true) the header stats and "Needs Action — 8 orders" group render, but every order card fails layout with `BoxConstraints forces an infinite height` (box.dart:2251 assertions, then "Unexpected null value" and endless mouse_tracker asserts). The list area is permanently blank even though data is present.
- **Rule:** A widget inside a scrollable must not demand infinite height (e.g. unbounded `Column`/`Expanded` inside a sliver child, or `ListView` inside a `Column` without constraints). Reproduce vendor screens at a phone-sized viewport before merging; assertion spam from mouse_tracker after a layout throw is a symptom, not the cause — find the first `BoxConstraints`/`RenderBox` error above it.
- **Where it applies:** vendor incoming-orders screen widgets (order group list/cards), any sliver-based list screen.
