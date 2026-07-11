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
- **Rule:** Guard post-await state writes. In `@riverpod` codegen Notifier classes: `_disposed` flag reset in `build()` + `ref.onDispose(() => _disposed = true)`. In `StateNotifier` subclasses: use the built-in `mounted` getter (state_notifier 1.0.0, line 152 — it exists, despite it being commonly believed to be State-only).
- **Where it applies:** Every async method in `@riverpod` Notifier and `StateNotifier` classes that writes `state` after an await.

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

### 2026-07-11 — Custom validateStatus can silently disable token refresh
- **What happened:** `LegacyRouteOptions.allowNotFound` used `validateStatus: status < 500`, which accepted 401/403 as normal responses — `TokenRefreshInterceptor` only acts in `onError`, so expired sessions on legacy routes would never refresh and would render as "empty data" instead.
- **Rule:** Any per-request `validateStatus` override must keep 401/403 as errors. Widen acceptance only for the specific status being tolerated (e.g. `2xx || 404`), never with a blanket `< 500`.
- **Where it applies:** All Dio `Options(validateStatus: ...)` overrides; currently `legacy_route_options.dart` used by orders, store-hours, and profile datasources.

### 2026-07-11 — Verify review-hook claims against package source
- **What happened:** The automated review hook flagged `if (!mounted)` in a StateNotifier as a runtime error, claiming StateNotifier has no `mounted`; checking `~/.pub-cache/.../state_notifier.dart` proved the property exists and the flag was a false positive.
- **Rule:** When a review claim is about an API's existence or signature, verify against the actual package source in the pub cache before rewriting correct code.
- **Where it applies:** All hook/reviewer feedback that asserts framework or package API facts.

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

- **What happened:** `allCities` / `allGovernments` / `allStoreCategories` called the live API with `page=0`, which returns HTTP 500; `page=1` (or omitting `page`) returns 200.
- **Rule:** The xStoreEcommerce `/api/*` list endpoints use **1-based** `page`. Never send `page=0` on the wire — use `page: 1` for the first page, or translate 0-based notifier state at the datasource boundary (see `notifications_remote_datasource.dart`: `page + 1`).
- **Where it applies:** Cities, governments, store categories, listings, reviews, notifications — any paginated GET.

### 2026-07-11 — Listing write payload uses command wrapper
- **What happened:** `POST /api/listings` returned 400: `command` required, `condition` rejected as `"LikeNew"` string, `attributes` rejected as `{}` object.
- **Rule:** Confirmed live contract for create/update: wrap fields in `{"command": {...}}`, send `condition` and `status` as integer codes, and `attributes` as a JSON **string** (`""` or `jsonEncode(map)`). Reads still coerce numeric `condition`/`status` in `ListingModel`.
- **Where it applies:** `listing_remote_datasource.dart`, `listing_model.dart` wire helpers (`listingConditionToWire`, `listingStatusToWire`).

### 2026-07-11 — Parse formatted money with Validators.parseMoneyInput
- **What happened:** Add-listing commission preview used `double.tryParse` on `form.priceInput` after `_formatPriceInput` inserted commas (`1,500`); parse failed above 999 so price read as null and the breakdown hid.
- **Rule:** Any UI reading `priceInput` / `compareAtPriceInput` / `shippingCostInput` from listing form state must use `Validators.parseMoneyInput` (strips commas) — never raw `double.tryParse`.
- **Where it applies:** `add_listing_screen.dart`, any widget displaying derived values from formatted money fields.

### 2026-07-11 — POST /api/listings 500 is backend SaveChanges
- **What happened:** After fixing the `command` wrapper and integer `condition`, create still returned 500 `saving the entity changes` for every vendor probed on the hosted API — payload passes validation but EF Core fails to persist (not a client shape bug).
- **Rule:** When live probes confirm 400-fixed payloads still 500 on write, map the opaque EF message to a user-facing publish error (`listingPublishServerError`) and treat as backend gap — don't add more client payload guesses without a confirmed contract change.
- **Where it applies:** `dio_error_mapper.dart`, `listing_form_notifier.dart`, any future write endpoint returning the same EF boilerplate.
