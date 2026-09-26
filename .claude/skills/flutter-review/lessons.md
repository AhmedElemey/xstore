# xStore Flutter — Lessons Learned

Look up entries by searching this file for the feature, file, endpoint or widget you're about to touch (every entry's "Where it applies" names its files). Newest entries at the bottom; follow the format and rules in `SKILL.md` → "Recording a lesson".

### 2026-07-11 — Domain logic stays out of widget files
- **Rule:** Pure mapping/business functions go in the feature's `domain/` layer; providers never import widget files.
- **Where it applies:** All features — watch for helpers co-located with the widget that first used them.

### 2026-07-11 — Money figures can't come from one page of a paginated endpoint
- **Rule:** Never compute a balance/total from a single page. Loop pages until exhausted, or detect `results == pageSize` and show the figure as a lower bound; push for a backend aggregate for anything financial.
- **Where it applies:** Commission wallet, any client-side totals/earnings/analytics.

### 2026-07-11 — StateNotifier owning a Timer needs a dispose override
- **Rule:** A `StateNotifier` owning a `Timer`/`StreamSubscription` overrides `dispose()` to cancel it; periodic callbacks check `mounted` before writing state.
- **Where it applies:** `phone_auth_provider.dart` and other legacy `StateNotifier` providers.

### 2026-07-11 — Verify which roles reach a route before restricting it
- **Rule:** Before role-restricting a route, `rg` every `push`/`go` call site and trace which role reaches it. Shared routes: `/order/:id`, `/product/*`, `/seller/*`, `/profile*`, notifications, info screens. Guards live centrally in `computeXStoreAuthRedirect` + `isVendorRestrictedRoute`/`isConsumerRestrictedRoute` (`app_routes.dart`) — extend those, never per-screen checks.
- **Where it applies:** New routes and role-gated features in `lib/core/router/`.

### 2026-07-11 — Guest mode: gate every entry point with requireLogin
- **Rule:** Account-gated actions and every visible entry point to an account-bound route (bottom-nav `_onTap`, header icons, CTAs on guest-browsable screens) call `requireLogin(context, ref)` at the tap site — it shows the Sign in / Not now dialog and returns false; the caller aborts. Never hand-roll `authProvider.valueOrNull == null` checks. The router guard (`isGuestAccessibleRoute` + `computeXStoreAuthRedirect`) only backstops deep links; new browse-safe routes must be added to `isGuestAccessibleRoute`. Prefs-backed flags the router needs at cold start are set synchronously in splash (`enable()` before `context.go`).
- **Where it applies:** `xstore_bottom_nav.dart`, app-bar actions, cart/wishlist/reviews/checkout/orders/profile/notifications entry points, new routes.

### 2026-07-11 — Warm async providers in widget tests before tapping
- **Rule:** The first `ref.read` of a lazy async provider returns `AsyncLoading`. In tests whose handlers read one (e.g. `authProvider`), `ref.watch` it in the harness and `pumpAndSettle` first, mirroring splash awaiting auth.
- **Where it applies:** Widget tests of auth-gated actions or any async provider read inside callbacks.

### 2026-07-11 — Live backend is the default; mock is opt-in
- **Rule:** Every run/build/test hits the live backend unless `--dart-define=MOCK=true`. The real API path is primary; mock branches are legacy fixtures. Keep tests' `skip: MockConfig.useMock ...` guards so both CI modes stay green. Current host/key: see the "tempurl.com trial host and key rotate" lesson.
- **Where it applies:** All datasources, CI defines, anything reading `MockConfig.useMock`.

### 2026-07-11 — The app doesn't run on Flutter web; verify UI with widget tests
- **Rule:** `firebase_options.dart` throws for web before `runApp`, so don't try `flutter run -d chrome/web-server`. Prove UI flows with widget tests (`test/require_login_test.dart` has a GoRouter stub harness). When a user reports behavior the current code demonstrably prevents, suspect a stale build and ask for a hot restart or rebuild.
- **Where it applies:** Manual verification; "works in code, user sees old behavior" reports.

### 2026-07-11 — Bottom-sheet content must scroll
- **Rule:** Wrap `showModalBottomSheet`/dialog content in `SingleChildScrollView` (or `isScrollControlled` with explicit constraints) and widget-test every new sheet/dialog — the test viewport catches overflows.
- **Where it applies:** All sheets and dialogs.

### 2026-07-11 — Per-request validateStatus must keep 401/403 as errors
- **Rule:** `TokenRefreshInterceptor` acts only in `onError`, so a blanket `validateStatus: status < 500` silently disables refresh. Widen acceptance only for the tolerated status (e.g. `2xx || 404`).
- **Where it applies:** Dio `Options(validateStatus: ...)` overrides, `legacy_route_options.dart`.

### 2026-07-11 — Verify review-hook claims before acting on them
- **Rule:** The hook reviews one edit's snippet at a time, so it produces false positives: missing `dispose()` that is just outside the snippet, closure parameters "not in scope" (a closure always captures its enclosing method's parameters), "undefined" methods added by a sibling edit in the same batch, miscounted parens after wrapping a deep return in a new widget, and API-existence claims (e.g. `StateNotifier.mounted` does exist). Verify API claims against the package source in the pub cache; verify everything else by re-reading the full file and running `flutter analyze`. Only rewrite after the claim survives.
- **Where it applies:** All hook and reviewer feedback.

### 2026-07-11 — No build-time fetch keyed on "list is empty"
- **Rule:** Never fire a fetch from `build`/`addPostFrameCallback` because a list is empty without a one-shot guard (loaded flag, error latch) — after a failed or empty fetch it loops. Badges read existing provider state; they don't prefetch.
- **Where it applies:** Profile widgets, any build-time network side effect.

### 2026-07-11 — Paginated /api list endpoints are 1-based
- **Rule:** `page=0` returns 500. Send `page: 1` first, or translate 0-based notifier state at the datasource (`page + 1`, as in `notifications_remote_datasource.dart`).
- **Where it applies:** Every paginated GET.

### 2026-07-11 — Parse formatted money with Validators.parseMoneyInput
- **Rule:** Listing price fields are comma-formatted; read `priceInput`/`compareAtPriceInput`/`shippingCostInput` with `Validators.parseMoneyInput`, never raw `double.tryParse`.
- **Where it applies:** `add_listing_screen.dart` and anything derived from formatted money fields.

### 2026-07-11 — Reach StatefulShellRoute branches with go, once
- **Rule:** Shell-branch routes are reached with `context.go`, never `context.push` from overlay/sibling routes (duplicate page keys crash). One navigation per success: show the snackbar, then `go` once — no toast state in query params that triggers a second `go`.
- **Where it applies:** Shell-tab routes (`listingAdd`, home/explore/orders/wishlist) and screens navigating to them.

### 2026-07-11 — update-profile wire keys differ between read and write
- **Rule:** Derive PUT keys from confirmed get-profile / `UserModel.fromJson` names, keep documented write-only aliases (`whatsAppNumber`, `instagramPage`), and add `optString` fallbacks in `fromJson` wherever read and write keys differ. The PUT must be multipart `FormData` — a JSON PUT returns 200 and changes nothing. Debug logs expand `FormData` to `{field: value, file: "<file:name>"}`.
- **Where it applies:** `profile_remote_datasource.dart`, `user_model.dart`, `logging_interceptor.dart`.

### 2026-07-11 — One shared, coalesced profile refresh
- **Rule:** After session adopt/restore, fire-and-forget `prefetchProfileData(ref)`; all callers (prefetch, pull-to-refresh, post-save) share one in-flight `refreshProfileData()` future. Skip automatic re-fetch within 30s of a load; after a 429 apply a 1-minute cooldown and map to `rateLimitErrorCode`. Screens don't refresh on mount — only when `profile == null && !isLoading && error == null` (prefetch missed); pull-to-refresh and post-save pass `force: true`. The Profile tab shows a full-page error only when auth has no identity; otherwise it renders from `authProvider` with the inline retry banner.
- **Where it applies:** `profile_provider.dart`, `profile_screen.dart`, `edit_profile_screen.dart`, `auth_provider.dart`.

### 2026-07-11 — Every forced session clear resets profile state
- **Rule:** Logout, delete account, and a failed token refresh (`TokenRefreshInterceptor.onRefreshFailed` — not retried 401s that refresh fixes) call `resetProfileData(ref)` alongside `ref.invalidate(authProvider)`.
- **Where it applies:** `dio_provider.dart`, `auth_provider.dart`, `profile_provider.dart`.

### 2026-07-11 — Side effects fired from build() see their own provider as Loading
- **Rule:** On first build `valueOrNull` is null (invalidate-rebuilds keep the old value and hide the bug), so a side effect launched from `build()` must not read that provider — pass the value in. For first-build-only side effects use a notifier instance field (riverpod 2.x reuses the instance across `ref.invalidate`; see `Auth._restoredOnce`). Test the cold-start restore path, not only `adoptSession`.
- **Where it applies:** `auth_provider.dart`, any cross-provider side effect launched from `build()`.

### 2026-07-13 — Admin-dashboard prototype: responsive rules last, generated HTML
- **Rule:** In `docs_business/admin-dashboard/src/styles.css`, `@media` overrides live in the final section (later equal-specificity rules win). Inline SVG icons need explicit CSS width/height. `xstore_admin_dashboard.html` is generated by inlining the `src/` files — regenerate it, never hand-edit.
- **Where it applies:** `docs_business/admin-dashboard/` (HTML prototype).

### 2026-07-15 — Medium_Phone_API_35 emulator has corrupted package-manager state
- **Rule:** On the user's machine, if `am start` says an installed activity doesn't exist, check whether other sideloaded apps resolve (`cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.LAUNCHER <pkg>`). If none do, switch AVDs (`flutter_emulator` works). Wiping Medium_Phone_API_35 loses the Google account used for sign-in tests.
- **Where it applies:** Emulator runs on the user's machine.

### 2026-07-15 — Use debugPrint for output that must show in flutter run
- **Rule:** `developer.log` goes to DevTools, not the `flutter run`/logcat console. Use `debugPrint`, one call per field so long tokens stay on single lines under 4KB.
- **Where it applies:** Debug and diagnostic printing.

### 2026-07-15 — Logout clears local state even when remote steps throw
- **Rule:** Each best-effort step (remote logout, Firebase/Google/Facebook sign-out) gets its own try/catch; local session clearing runs unconditionally and is the source of truth.
- **Where it applies:** `auth_repository_impl.dart` logout, forced 401 cleanup, account deletion.

### 2026-07-17 — A new UserRole touches the router in several coupled places
- **Rule:** A new role needs its shell branch list, a matching nav tab list (both switch on `UserRole`; nav is length-driven), a role-aware home target in every redirect fallback (`/home`/`/explore` exist only in consumer/vendor shells), and mutual tab restrictions. Grep `AppRoutes.home` in redirect logic whenever shell membership changes.
- **Where it applies:** `lib/core/router/`, `xstore_bottom_nav.dart`.

### 2026-07-17 — Mock auth matchers key on what the UI sends
- **Rule:** The login UI sends normalized phone digits, so identifier-routed mock behavior matches on `AppValidators.normalizeEgyptLocal` against the seed user's phone; keyword matchers are test conveniences only.
- **Where it applies:** `mock_users.dart`, identifier-based demo shortcuts.

### 2026-07-17 — Lazy lists only build what's on screen in widget tests
- **Rule:** Assert only what fits the 600px test viewport, then `tester.scrollUntilVisible(...)` before asserting off-screen items.
- **Where it applies:** Widget tests over scrollable screens.

### 2026-07-18 — Screen-scoped family providers must autoDispose
- **Rule:** `.family` providers for screen state are `.autoDispose.family` (codegen `@riverpod` defaults to it); a keepAlive family is a per-argument cache and needs a comment justifying it.
- **Where it applies:** All `.family` providers, especially detail screens keyed by id.

### 2026-07-18 — Count strings use ICU plurals in both locales
- **Rule:** Any arb string with a count uses ICU plural syntax from the first draft; Arabic needs its own categories (`=1`, `=2`, `few`, `other`).
- **Where it applies:** New arb keys with numeric placeholders.

### 2026-07-19 — Auth wire contract
- **Rule:** Login posts `phoneNumber` (normalized 11-digit local, via `AppValidators.normalizeEgyptLocal`) — `LoginParams.emailOrPhone` is a historical name. Consumer register requires `email`; vendor register is multipart with a required `profileImage` file; `dateOfBirth` is date-only `YYYY-MM-DD`. Passwordless login is `send-login-otp` + `login-with-otp`. Password reset (`forgot-password`) is email-only. Google: `POST /api/auth/google/check-user` (`{idToken, clientId}` → `{exists, role}`, read-only) runs first; if the account exists, log in via the role-specific `google/{consumer|vendor}/login` with the returned role; otherwise (or if the lookup fails) set `needsRegistration` and send the user to register — Google never creates accounts (it collects no phone or password). Trust get-profile for the role. Reconcile against the Postman collection by probing each endpoint.
- **Where it applies:** `auth_remote_datasource.dart`, `api_endpoints.dart`, register/login/OTP/social providers and screens.

### 2026-07-19 — Tests stub repositories, not mock datasources
- **Rule:** Widget tests over screens backed by a mock datasource override the repository provider with a zero-latency, no-seed stub (`test/helpers/stub_delivery_request_repository.dart`, `StubOrdersRepository`) — `MockConfig.simulate` schedules real Timers (pending-timer assert) and the datasource seeds demo data.
- **Where it applies:** Widget tests over delivery/orders/cart screens and any datasource using `MockConfig.simulate`.

### 2026-07-19 — Hosted backend 500s during deploys
- **Rule:** When a previously green endpoint starts 500ing, re-probe a known-good call before blaming the payload; a raw SQL error in the body (`Invalid column name …`) means the backend is mid-migration, not an app bug.
- **Where it applies:** Live-backend verification.

### 2026-07-21 — Uploads send the file; auth headers are injected centrally
- **Rule:** An upload datasource attaches the file as a `MultipartFile` in `FormData` and maps errors via `mapDioException` — never a stub POST that ignores the file. `dio_provider`'s interceptor injects `X-Auth-Token` and the Basic license key on every request, so per-call `ApiAuthHeaders.authenticated()` is intent only; check the interceptor before diagnosing a missing auth header.
- **Where it applies:** File-upload datasources, auth-defect diagnosis.

### 2026-07-23 — update-profile: build from UpdateProfileRequest; user image and store image are separate
- **Rule:** Profile edit builds `UpdateProfileRequest` via `ProfileState.toUpdateProfileRequest()` and sends one multipart PUT (`updateProfileFormData`) carrying image + fields — no separate pre-save avatar upload. `userImageUrl`/`userImagePath` → `UserImage` (profile avatar; removal clears the user image only); `storeImageUrl`/`storeImagePath` → `StoreImage` (store logo). Always send both URL keys as strings (`''` to clear — JSON null is dropped on multipart); on clear also send the GET names (`avatarUrl`, `storeLogoUrl`). Location maps to `detailedAddressByGoogleMaps`/`detailedAddressByUser`/`cityByGoogleMaps`/`governmentByGoogleMaps`, IDs to `cityId`/`governorateId` (not `governmentId`), `lat`/`lng`, `birthDate` as `YYYY-MM-DD`; email/phone are not sent.
- **Where it applies:** `update_profile_request.dart`, `profile_state.dart`, `profile_provider.dart` `saveProfile`, `profile_remote_datasource.dart` `updateProfileWireFields`/`updateProfileFormData`.

### 2026-07-23 — Google backend login: Web client ID as audience and in the body
- **Rule:** Construct `GoogleSignIn(serverClientId: DefaultFirebaseOptions.googleWebClientId)` (the OAuth Web client, client_type 3) so the ID token's audience is what the backend verifies, and POST both `idToken` (the Google token, never the Firebase ID token) and `clientId` (same Web client ID) to the role-specific Google endpoint.
- **Where it applies:** `social_auth_datasource.dart`, `auth_remote_datasource.dart` `loginWithGoogle`, `firebase_options.dart`.

### 2026-07-23 — Auth must never read authProvider through its own ref
- **Rule:** Riverpod's self-dependency assert is keyed on ref identity, not timing: `ref.read(authProvider)` from inside `Auth` throws whether synchronous or deferred with `Future(() => ...)`. Every `Auth` method (`build`, `setUser`, `adoptSession`, …) has `user` in scope — pass `user: user` explicitly to `syncFcmDeviceTokenWithBackend`, `syncDeliveryBackendSession`, `prefetchProfileData`, with no fallback read. Verify with `flutter test --dart-define=MOCK=true`: the affected tests are skipped in the default run.
- **Where it applies:** `auth_provider.dart`, `fcm_device_token_sync_provider.dart`, `delivery_backend_session.dart`, `profile_provider.dart`, any side effect fired from a notifier that needs that notifier's own state.

### 2026-07-23 — Backend enums: never infer member mapping from seed data
- **Rule:** Wire enums arrive as ints (C# 1-based; `0` means unset unless the confirmed C# declaration assigns 0 to a real member, e.g. `OrderStatus.Pending=0`). Get the C# enum declaration before mapping; until then use an explicit fallback with a comment. Keep app enums 1:1 with backend enums (no app-only members). Parse with type-checked `_optString`/`_optInt`/`_optDouble`, not `as` casts, and skip malformed list rows individually. Mappings live next to the model/enum (`listing_model.dart`, `orderStatusFromWire`/`orderStatusToWireName` in `order_entity.dart`, tested in `test/order_status_wire_test.dart`).
- **Where it applies:** All wire-enum handling in `data/models` and datasources (notifications, condition, listing/order status, payment method).

### 2026-07-23 — get-profile returns {user, store}; login returns tokens only
- **Rule:** Parse profile responses through `parseProfileResponse` / `userModelFromProfileResponse`: unwrap `user`, merge the nested `store` into flat user keys (`storeNameEn`, `lat`/`lng`, address fields, `storeId`), and surface `isEmailVerificationRequired`/`isPhoneVerificationRequired` on `ProfileEntity`. Login/register return `{token, refreshToken}` with no user. Gate vendor profile UI on `user.hasStore`, not role alone.
- **Where it applies:** `user_model.dart`, `profile_remote_datasource.dart`, `auth_remote_datasource.dart`, `profile_screen.dart`.

### 2026-07-23 — Never navigate to /seller/ with an empty id
- **Rule:** Live get-profile can omit `user.id`. Use `AppRoutes.sellerPath(id)` only with a non-empty id resolved from the profile user, then the auth session, then the JWT (`userIdFromJwt`) on login/restore; disable the CTA while the id is unknown.
- **Where it applies:** `profile_screen.dart`, `jwt_payload.dart`, `auth_repository_impl.dart`, `userModelFromProfileResponse`.

### 2026-07-25 — Birth dates are calendar dates
- **Rule:** Parse `birthDate`/`dateOfBirth` as a literal `YYYY-MM-DD` (`dateOnly: true` in `UserModel.fromJson`), compare year/month/day only, normalize picker values to date-only, and re-sync edit-profile controllers when loading finishes and there are no unsaved changes.
- **Where it applies:** `user_model.dart`, `profile_provider.dart`, `edit_profile_screen.dart`.

### 2026-07-25 — Every release signing key must be registered in Firebase
- **Rule:** Register SHA-1 and SHA-256 of every signing key (local `key.properties` keystore and the CI `KEYSTORE_BASE64` secret — they may differ) for both `com.xstore.app` and `com.xstore.app.dev`, then re-download `google-services.json`. A debug-only SHA makes release Google sign-in fail with `DEVELOPER_ERROR`. List fingerprints with `task signing:report` or `./gradlew :app:signingReport`.
- **Where it applies:** `android/app/google-services.json`, `android/app/src/dev/google-services.json`, CI release workflow.

### 2026-07-26 — Reference-data providers: keepAlive on success only
- **Rule:** Keep reference lists (`allCities`, `allGovernments`, `allStoreCategories`) as autoDispose `@riverpod` and call `ref.keepAlive()` in the success branch — `@Riverpod(keepAlive: true)` would also pin an `AsyncError` with no retry. Request at most `pageSize: 100` (the API rejects more); if a table can exceed 100 rows, loop pages with `PaginatedResult.hasNextPage`.
- **Where it applies:** `city_dependencies.dart`, `government_dependencies.dart`, `store_category_dependencies.dart`, any lookup list provider.

### 2026-07-26 — One user-level location for all roles
- **Rule:** The backend has one `cityId`/`governmentId` pair, so register step 2 (all roles) owns the single cascade (validation key `storeLocation`); the vendor store step doesn't ask again, and edit profile puts it in the all-roles section, not inside `if (isVendor)`. On the wire: consumer register and update-profile send `cityId` + `governorateId` (never `governmentId`); vendor register sends those plus `storeCityId`/`storeGovernorateId`. Reads accept `governorateId`, then `governmentId`. Before wiring a form field, trace that its value reaches the wire — several register fields have been collected and never sent.
- **Where it applies:** `register_screen.dart`, `auth_provider.dart`, `consumer_register_params.dart`, `auth_remote_datasource.dart`, `edit_profile_screen.dart`.

### 2026-07-26 — Birth dates: today or earlier
- **Rule:** Future dates are rejected; today is allowed. Use `Validators.isBirthDateAfterToday` / `isSelectableBirthDate` / `latestBirthDate()`; the shared `pickBirthDate` sets `lastDate: todayCalendarDate()` and `selectableDayPredicate: isSelectableBirthDate` (`lastDate` alone isn't enforced on every platform). Register validates on pick and submit (with optional min-age), profile on save.
- **Where it applies:** `validators.dart`, `birth_date_picker.dart`, register and edit-profile DOB fields.

### 2026-08-02 — Listing write contract (create/update is multipart)
- **Rule:** POST/PUT `/api/listings` is `multipart/form-data`: attributes as an indexed list (`Attributes[i].Key` / `Attributes[i].Value`), images as repeated inline `imageFiles` parts (no pre-upload). Keep sending `condition`, `subcategoryId`, `status` even though the collection example omits them — unbound multipart keys are ignored. Resubmit (`PUT /api/listings/{id}/resubmit`) is JSON `{"newPrice": ...}` and only accepts cancelled listings. Pause is the bodyless `PUT .../deactivate` (active listings only). There is no `/activate`, and `/deactivate`/`/resubmit` reject paused listings, so resume calls the generic update with `status: active` and `keepImageUrls` — it returns 200 but doesn't persist Active (backend gap). Status on update: preserve it for live/paused/pending/rejected listings; a draft's submit (and every create) sends Pending (`status=1`, allowed even with no field changes) — C# default 0 is Draft, which never enters the admin queue, and vendors can't self-set Active. Existing hosted photos are removable on edit and persist as `imageUrls[i]`; they count toward the 5-photo cap. "Delete" is the soft `PUT .../cancel` (there is no DELETE route); don't refetch after it. A Postman collection outranks an old lesson, but live-probe when you can, and trust each request's own body over a resource-wide assumption.
- **Where it applies:** `listing_remote_datasource.dart` (`_listingFormData`), `api_endpoints.dart`, `my_listings_notifier.dart`.

### 2026-08-02 — Guard persisted local file paths before upload
- **Rule:** Paths restored from drafts may have been evicted from the picker cache; check `File(path).existsSync()` per path and skip missing ones instead of failing the whole upload.
- **Where it applies:** `listing_remote_datasource.dart` `_listingFormData`, any upload of persisted local paths.

### 2026-08-02 — Enforce "max N" caps at every entry point
- **Rule:** When a capped field can come from a user action, restored state, and a network write, clamp at each: listings clamp photos in `addPhotoPath`, in `_stateFromJson` (draft restore), and in `_listingFormData` (the network boundary).
- **Where it applies:** `listing_form_notifier.dart`, `listing_remote_datasource.dart`, any capped user content that flows through drafts.

### 2026-08-02 — Compress picked images once, and fail open
- **Rule:** Compress at pick time (`FlutterImageCompress.compressAndGetFile`, quality 80, min 1600px, target `'$sourcePath-compressed.jpg'` next to the source), not again at submit. On any compression error fall back to the original path — never block adding a photo.
- **Where it applies:** `listing_form_notifier.dart` `_compressPhoto`, any picker-sourced multipart upload.

### 2026-08-02 — Scope renames to the entity whose meaning changed
- **Rule:** Grep an identifier repo-wide and bucket hits by entity before a mechanical rename; names like `consumerId`, `vendorId`, `courierId`, `status` recur across orders/delivery/cart with different meanings.
- **Where it applies:** Any shared-name field rename.

### 2026-08-03 — Form sheets stay open on failure
- **Rule:** A menu/confirmation sheet with no user input may close unconditionally and let the screen listener show errors. A sheet holding user-entered data pops only on success and shows the error inline so the user can retry without retyping.
- **Where it applies:** `resubmit_listing_sheet.dart`, any sheet combining input with an async submit.

### 2026-08-03 — Offline fallback for id-only mutations
- **Rule:** An id-only mutation (resubmit, deactivate) can't fabricate a full offline model; mutate the cached entry (`_localMine`) if present, otherwise rethrow via `mapDioException`. Keep the fallback branch rather than skipping it.
- **Where it applies:** `listing_remote_datasource.dart`.

### 2026-08-03 — FCM push setup
- **Rule:** `configureFirebaseCloudMessaging()` runs once in `bootstrap()` (background handler, iOS foreground presentation options, Android local-notification channel); the permission prompt fires unawaited at bootstrap for every user. `fcmPushHandlingProvider` at the app root routes `onMessage`/tap/cold start via `routeFromRemoteMessage` → `goRouterProvider.go`, guarded by `isSafeInAppRoute`. Android foreground uses `flutter_local_notifications`; iOS foreground uses presentation options only. Init must call `getNotificationAppLaunchDetails()` or cold-launch taps on local notifications are lost. Notification icons are the alpha-only `@drawable/ic_stat_notify`, never `@mipmap/ic_launcher`. Release/Profile use `RunnerRelease.entitlements` (`production` APS); Debug keeps `development`.
- **Where it applies:** `lib/core/firebase/fcm_*.dart`, `fcm_push_handling_provider.dart`, `main.dart`, `AndroidManifest.xml`, iOS entitlements.

### 2026-08-03 — Never capture a WidgetRef in work that outlives the widget
- **Rule:** `WidgetRef.read` throws once the widget is disposed, so an `unawaited(...)` started from a `ConsumerState`/`ConsumerWidget` must not keep using the widget's `ref`. Read the keepAlive notifier synchronously while mounted, then call an async method on it that uses the notifier's own `ref` (e.g. `ProfileNotifier.autoDetectAndFillLocationIfMissing()`).
- **Where it applies:** Fire-and-forget work started from widgets (`splash_screen.dart` and similar).

### 2026-08-04 — Session-scoped state: never render another entity's data, always reset on logout
- **Rule:** A provider holding "the signed-in user's own X" (not keyed by id) must not render someone else's X — check `authUser.id == shownEntityId` or use a `.family` provider keyed by the entity (e.g. `storeHoursNotifierProvider` for own hours vs `sellerStoreHoursProvider` for a seller). Every session-scoped keepAlive provider or datasource cache (static or instance fields, and each sibling in a consumer/vendor pair) is reset at the central choke points — `Auth.logout()` and `TokenRefreshInterceptor.onRefreshFailed` — alongside `resetProfileData`, `resetStoreHoursData`, `resetListingLocalCache`; otherwise the next account on the device sees the previous user's data. A `ref.listen(authProvider)` inside a notifier that may never be built is not enough. Grep every keepAlive provider in the feature when adding one reset.
- **Where it applies:** `store_hours_provider.dart`, `seller_card.dart`, `orders_remote_datasource.dart`, `cart_remote_datasource.dart`, `vendor_orders_provider.dart`, `listing_remote_datasource.dart`, `auth_provider.dart`, `dio_provider.dart`.

### 2026-08-04 — Re-read the whole file after Stateful↔Stateless conversions
- **Rule:** Make the state-class removal, `widget.x` → `x` renames and controller replacement together, then re-read the file and grep for `widget\.` and the old names — a missed rename can silently bind to a same-named field instead of failing to compile.
- **Where it applies:** Widget refactors and local renames that could shadow fields.

### 2026-08-04 — "When the user enters the app" has many entry points
- **Rule:** `context.go(AppRoutes.home)` after auth fires from splash, login, OTP, register and courier-login screens. A post-auth feature goes in one shared helper called at every such site (with `mounted` guards after awaits). A "first time the app opens" feature runs on first launch regardless of auth state — don't narrow the trigger to what the payoff needs. Example: `maybeShowLocationPermissionPrompt` runs unconditionally in splash and after each auth success.
- **Where it applies:** `location_permission_prompt.dart`, first-run or post-auth prompts.

### 2026-08-04 — Android plugins may need core library desugaring
- **Rule:** When Gradle says a dependency requires desugaring, set `isCoreLibraryDesugaringEnabled = true` in `compileOptions` and add `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:<version>")`. This only fails at `flutter build apk`, not analyze/test — verify new Android plugins with a real build or CI.
- **Where it applies:** `android/app/build.gradle.kts`, new Android plugins.

### 2026-08-04 — Trace from a screen before reporting a datasource bug
- **Rule:** Trace screen → provider → use case → repository → datasource before calling a method a live bug; near-identical methods can differ in reachability. Grep for `SomeParams(` construction to confirm a use-case path is dead. Known dead auth paths: `verifyOtpUseCase`/`loginWithPhoneToken`, `RegisterUseCase`, `verifyEmailOtp`/`verifyPhoneOtpBackend`.
- **Where it applies:** Bug reports against datasources/repositories, especially `auth_remote_datasource.dart`.

### 2026-08-04 — tempurl.com trial host and key rotate
- **Rule:** The hosted backend is a free-trial `tempurl.com` instance whose host and Basic license key expire and are replaced (current host: `xstoreegy002-001-site1.etempurl.com`). When hosts/keys conflict or "no data" might be a stale host, ask the user which is current — don't pick the majority. Update every occurrence together: `api_endpoints.dart`, `api_auth_headers.dart`, `Taskfile.yml`, `.github/workflows/build-and-release-apk.yml`, `scripts/probe_*.py`.
- **Where it applies:** Any hardcoded API origin or license key.

### 2026-08-05 — Home carousels share one fetch
- **Rule:** `getNewArrivals()` and `getRecommended()` re-sort the same `getHotDeals()` result (`GET /api/listings?page=1&pageSize=40`); overlapping carousels are a backend ask (dedicated endpoints or sort params), not a client fix.
- **Where it applies:** `home_repository_impl.dart`.

### 2026-08-06 — A second backend gets its own Dio and a session bridge
- **Rule:** The delivery backend (separate host, Bearer JWT) uses its own keepAlive Dio (`delivery_dio_provider.dart`) and token key (`PrefsKeys.deliveryAuthToken`). `delivery_backend_session.dart` silently exchanges the main session for a delivery token (consumer/vendor only), is re-run from the Dio's 401 interceptor as the refresh, must never block main auth, is wired into `Auth.build()` restore, `setUser` and `adoptSession`, and is cleared in `logout()`.
- **Where it applies:** `delivery_dio_provider.dart`, `delivery_backend_session.dart`, `auth_provider.dart`, any future external backend.

### 2026-08-06 — Check what creates the data before wiring its reads to a backend
- **Rule:** Before wiring a datasource to a real backend, trace what creates the data it reads. If creation is still an unwired mock (e.g. checkout computing prices client-side while the server recomputes them), wiring only the reads leaves an inconsistent half-real feature — flag the upstream gap and scope to what is self-contained.
- **Where it applies:** "Wire X to the real backend" tasks, especially orders vs `cart_remote_datasource.dart` checkout.

### 2026-08-06 — Verify backend claims in the backend repo
- **Rule:** Before scoping "the backend just needs X", grep the backend repo (`~/repos/xStoreEcommerce` on the user's machine) for the entity/controller — mobile-side comments and wired-looking UI are not evidence. If a whole domain is missing, stop and re-scope with the user.
- **Where it applies:** Tasks framed as small backend additions or "wire to the real API".

### 2026-08-07 — ref.listen(authProvider) misses logins that happened before the provider was built
- **Rule:** `ref.listen` doesn't fire for the current value, and lazily built keepAlive notifiers often come alive after login. For "load on login", use `fireImmediately: true` (as `WishlistNotifier`/`NotificationsNotifier` do) or seed from the auth state read in `build()`, and also fetch when the screen opens (`RouteReentryRefresh` only covers returning to a tab). Don't clear rows at the start of a refresh. Fix every sibling with the same `ref.listen(authProvider) → fetch` shape, not only the one you found. When a notifier starts fetching eagerly, see the eager-fetch test lesson below.
- **Where it applies:** `cart_provider.dart`, `orders_provider.dart`, `vendor_orders_provider.dart`, any keepAlive notifier fetching off auth.

### 2026-08-07 — Mock coverage is per datasource method
- **Rule:** Before relying on `MOCK=true` for a screen, grep `MockConfig` in the specific datasource backing it — read paths (detail, search) are often unmocked while writes are. When adding a mock branch to one method, check every method on that interface.
- **Where it applies:** All datasources (e.g. `explore_remote_datasource.dart` `searchListings`).

### 2026-08-14 — Backend error envelope
- **Rule:** Errors come back as `{isSuccess, data, errorEn, errorAr, statusCode}`. For `badResponse`, `_serverErrorMessage` reads `errorEn` first, then legacy `error`/`message`/nested `error.message`, before Dio's generic text. Users see `errorAr` when the app is Arabic (top-level `errorMessagesInArabic`, kept in sync by `AppLocaleNotifier`), but stable-code matching always keys on `errorEn`. Don't blanket-mask 5xx: meaningful 500 `errorEn` text is intentionally shown. Error envelopes are contracts too — when a probe shows a new shape, add the keys as candidates.
- **Where it applies:** `dio_error_mapper.dart`.

### 2026-08-14 — Every request carries X-Latitude/X-Longitude
- **Rule:** `GET /api/listings` is a geo search (see the Home vs Explore lesson) driven by `X-Latitude`/`X-Longitude`; without them it has returned 400 and, more recently, 200 empty. `AppLocationCache` (primed from `Geolocator.getLastKnownPosition()` at bootstrap, updated by `LocationService.getCurrentLocation()`, Cairo fallback) supplies them in `dio_provider.dart`'s `onRequest` — never per call site. When a previously unconditional endpoint 400s everywhere, check for a new required header first.
- **Where it applies:** `dio_provider.dart`, `app_location_cache.dart`, `location_service.dart`.

### 2026-08-14 — Postman example values may not pass current validation
- **Rule:** Register passwords need 8+ characters with upper, lower, digit and special character; the collection's `"123456"` example fails. Probe with values production validation would accept, and keep client-side password validation in sync with this rule.
- **Where it applies:** Register validation, `Validators`, live probes.

### 2026-08-14 — Gated write flows: self-service preconditions surface one at a time
- **Rule:** Before treating "must be verified"/"not available" as an admin wall, check self-service gates: a verified account is required before creating listings and placing orders (phone OTP via `send-phone-otp` + `verify-phone` 400s until the email is verified, so verify email first); a vendor needs store lat/lng (set via update-profile) before creating listings; new listings need admin approval (`PUT /api/admin/listings/{id}/approve`) before they can be ordered. The mapper turns these into `phoneNotVerifiedErrorCode` (checkout opens `phone_verification_sheet.dart`, then retries) and `storeLocationRequiredErrorCode` (add-listing offers a "Set location" action). Error texts change — match on the current `errorEn` and re-probe before trusting a "CONFIRMED" string. Seeded test vendor for probes: `01112345678` / `P@ssw0rd`.
- **Where it applies:** Checkout, add-listing, registration/verification, live probes of gated flows.

### 2026-08-14 — Wrapping notifiers must read the wrapped notifier's error
- **Rule:** When one notifier wraps another's mutation (e.g. `CheckoutNotifier.placeOrder()` over `Cart.placeOrder()`), build the failure from the wrapped notifier's state (`ref.read(cartProvider).error`), not from its own previous state.
- **Where it applies:** `checkout_provider.dart`, any two-notifier composition.

### 2026-08-14 — Don't thread data through entities nothing displays
- **Rule:** When wiring an endpoint (e.g. `PUT /orders/{id}` delivery coordinates), don't add fields to domain entities that no UI reads. Map `LocationService`'s three exceptions to the existing `locationServiceDisabled`/`locationPermissionDenied` codes and their l10n strings.
- **Where it applies:** `order_detail_provider.dart`, `orders_remote_datasource.dart`, anything using `LocationService`.

### 2026-08-15 — COD-only launch; no dead-end routes; WhatsApp numbers
- **Rule:** Never collect card PAN/CVV; keep old `PaymentMethod` members only to parse old orders. Hide or redirect unfinished routes instead of leaving Coming Soon stubs tappable — and when redirecting a route, grep the constant everywhere it's a target (notification `actionRoute`, deep links, push routing), not just `onTap` sites. Open WhatsApp via `whatsAppDigits`/`launchWhatsApp` (`01…` → `20…`); E.164 digits without `+` are exactly 12 (local form is 11) — check with `==`, never `<`.
- **Where it applies:** Checkout, profile menu, `app_router.dart` redirects, `lib/shared/utils/whatsapp.dart`.

### 2026-08-15 — Never fabricate marketplace data
- **Rule:** When the API omits rating/sales, show "New seller" — no invented numbers. Missing stock is 0. A "stop fabricating X" fix must grep the field (`vendorRating`, `rating`, `salesCount`, …) across all of `lib/`: the same fake default (`@Default(4.8)`, `?? 4.8`, `x == 0 ? fallback : x`) is copied into product, cart, order and profile entities and datasources. When replacing a fake default with the real field, check mock/seed data populates it too. Don't publish templated `{{PLACEHOLDER}}` legal text; Terms/Privacy describe what the app actually does.
- **Where it applies:** Seller/product/cart/order entities and datasources, `mock_listings.dart`, `profile_stats_row.dart`, Terms/Privacy screens.

### 2026-08-15 — Release builds can't use mock or dev hosts
- **Rule:** `MockConfig.useMock` is false in `kReleaseMode` even if `MOCK=true` is passed, and the delivery base URL never falls back to localhost in release (`DeliveryApiEndpoints.baseUrl` throws if `DELIVERY_API_BASE_URL` is missing). Changing a global flag like `useMock` means grepping every consumer for a live path that throws in release and confirming the build pipeline supplies the required defines.
- **Where it applies:** `mock_config.dart`, `delivery_api_endpoints.dart`, `delivery_dio_provider.dart`, Taskfile/CI build defines.

### 2026-08-15 — Platform commission is a flat EGP fee
- **Rule:** Commission is a flat fee per order (`kStarterCommissionFeeEgp`, `commissionFeeEgpForCategory`, `CommissionBreakdown.forPrice(..., feeEgp:)`) — never `price * rate / 100` or a `%` label. A fee-model change updates domain, config, listing preview, order breakdown and wallet together.
- **Where it applies:** `lib/features/commission/`, add-listing breakdown, vendor order breakdown, commission wallet.

### 2026-08-15 — Categories come as a tree
- **Rule:** `GET /api/categories` returns top-level categories with nested `children` (which also carry `parentId`). Keep the tree on `CatalogCategoryEntity.children` and drive the subcategory picker from it — don't flatten and filter. The picker sheet watches `allCatalogCategoriesProvider` itself.
- **Where it applies:** `catalog_category_remote_datasource.dart`, `catalog_category_model.dart`, `category_picker_sheet.dart`, add-listing category fields.

### 2026-08-15 — Moving a list to the API deletes the hardcoded copy
- **Rule:** When reference data moves to a `GET /api/…` endpoint, delete the static options, slug→label maps and matching arb keys in the same change; names display from the API's bilingual fields. Keep only values the API doesn't own (e.g. listing condition tokens). Brand is free text.
- **Where it applies:** `listing_categories_data.dart`, `listing_localized_labels.dart`, `lib/l10n/app_*.arb`, `mock_categories.dart`.

### 2026-08-15 — Picker sheets opened from shell tabs
- **Rule:** Open the sheet on tap immediately — don't await the fetch first (a failed fetch looks like a dead button). Inside, `ref.watch` + `AsyncValue.when` (spinner / error with a retry that invalidates / data). Give the list a tight `SizedBox(height: ~55% of sheet)` + `Expanded(ListView)`, never `Flexible` in a min-sized Column. Use `useRootNavigator: true` on shell tabs and pop the sheet body's context. Widget-test the tap through a nested navigator and bottom bar, with delayed and error providers.
- **Where it applies:** `category_picker_sheet.dart`, `add_listing_screen.dart`, any picker opened from a `StatefulShellBranch`.

### 2026-08-15 — Re-run analyze after commenting out code
- **Rule:** Commenting out a block can orphan imports, and removing one unused import can reveal another (extension-method imports like `go_router` have no textual trace). Run `flutter analyze` after each removal.
- **Where it applies:** "Comment out for phase N" changes.

### 2026-08-15 — Check a backend endpoint's role before wiring it
- **Rule:** Grep the backend controller's `[Authorize(Roles = ...)]` before wiring an endpoint from a Postman body. System settings and vendor wallets are admin-only; vendors only get the echo in `GET /api/vendor/orders` (`commissionValueOnOrder`, `warnThresholdEgp`, `pauseThresholdEgp`, `exceedsWarnThreshold`, `exceedsPauseThreshold` — never the outstanding amount). When a role only gets a derived boolean, don't show a client-computed version of the raw figure — it can't re-sync after an admin settlement.
- **Where it applies:** `commission_config_provider.dart`, `vendor_commission_wallet_provider.dart`, `vendor_commission_alert_banner.dart`, any "wire this admin endpoint" ask.

### 2026-08-15 — pickMultiImage(limit:) is not a cap
- **Rule:** `limit` below 2 throws, and Android below API 33 ignores it. Use `pickMultiImage(limit: remaining)` only when `remaining >= 2`, else `pickImage`; always `take(remaining)` and clamp again in `addPhotoPaths`.
- **Where it applies:** `listing_form_notifier.dart`, any capped multi-image pick.

### 2026-08-23 — Location cascade: governorate → city
- **Rule:** `LocationCascadeField` is one tile: tap → governorate sheet (`allGovernments`, `/api/governorates`) → auto-opens the city sheet (`allCities` filtered client-side by `governorateId`, fallback `governmentId` — the endpoint ignores filter params) → renders "Governorate - City". Every tap path must reach the city sheet (a merged tile once left `cityId` unset). Dismissing the city sheet after changing the governorate clears the stale city; with the governorate unchanged it keeps it. The city sheet's back button pops a private `Object` sentinel (`showModalBottomSheet<Object>`) handled in a `while (true)` loop — never overload `null`. Both sheets search `nameEn` and `nameAr`, own their search controller in a StatefulWidget, pad with `viewInsetsOf`, and don't autofocus (cursor blink hangs `pumpAndSettle`). Edit profile passes the registered names (parsed from nested `{id,nameEn,nameAr}` on `user` or `store`) as `hint` until lookups resolve; never mix GPS town/governorate into it. Form state fields are `storeCityId`/`storeGovernmentId`. Both endpoints currently return a bare JSON array — fetch reference lists as `dynamic` and unwrap a bare array or `{items|data|results}` (`json_list_unwrap.dart`). If pickers break, re-probe both endpoints; this contract has changed twice.
- **Where it applies:** `location_cascade_field.dart`, `government_remote_datasource.dart`, `city_remote_datasource.dart`, register and edit-profile location fields.

### 2026-08-23 — Analytics collector
- **Rule:** Telemetry uses its own Dio (the shared client's interceptors trigger the global error screen and forced logout); it attaches `X-Auth-Token` itself and never uses `TokenRefreshInterceptor` (a telemetry 401 backs off, never logs out). POST `/api/analytics/events` only for a signed-in user with a token, queueing locally for guests; await `authProvider.future` so the first flush sees the restored session; coalesce in-flight flushes. The body is exactly `{ "events": [...] }`; each event carries `eventName` (plus `name`), `timestamp` (plus `occurredAt`), a non-empty `screenName`, `userId`/`userRole` stamped at flush, and `properties` as a string dictionary — a missing `EventName` or unbindable properties 400s the whole batch. On any 2xx remove only the sent batch and persist; keep the queue on 404 or errors. Property values are stable codes, ids or numbers only — never l10n copy, user-typed text or server messages (allowlist codes, else `server_error`; redact phones/emails from search queries); Amplitude receives guest events immediately, so leaks aren't filtered by sign-in.
- **Where it applies:** `analytics_service.dart`, every `track()` call site.

### 2026-08-23 — iOS FCM getToken needs an APNS token first
- **Rule:** On Apple platforms, poll `getAPNSToken()` until non-empty before `getToken()` (which otherwise throws `apns-token-not-set`); if it never arrives, skip `getToken()` and rely on `onTokenRefresh`.
- **Where it applies:** `fcm_token.dart`.

### 2026-08-23 — Text field hints with prefix icons
- **Rule:** Fields with a prefix/suffix icon use `AppSpacing.inputContentPaddingV` (12), not 16px vertical padding, `isDense: true`, and `prefixIconConstraints` (min ~40) — copy `PhoneInputField`. Hint style: `height: 1`, color `textSecondary` (`textHint` on white is ~2.5:1). `find.text` doesn't prove a hint is visible — assert its width on a phone-sized surface. Hot reload may not rebuild an `InputDecoration`; restart. `AuthTextField` doesn't derive a hint from `label`: pass `hint` to every `AuthTextField(` on the screen in the same change. Hint examples use generic names ("Ahmed Mohamed"), never a real person's.
- **Where it applies:** `auth_text_field.dart`, `phone_input_field.dart`, auth screens, hint strings in `lib/l10n/`.

### 2026-08-23 — Don't validate a field you hid
- **Rule:** Removing or hiding a form field deletes its `validateStep` entry in the same change — an error key with no widget looks like a dead Continue button. If the backend still needs the value, copy a visible field onto the wire (e.g. `fullName` → `fullNameAr`).
- **Where it applies:** `auth_provider.dart` `validateStep`, any wizard.

### 2026-08-24 — Display name wire key is fullName
- **Rule:** Register and update-profile send `fullName` only — not `fullNameEn`/`fullNameAr`. Reads accept `fullName`, then `fullNameEn`, then `name`.
- **Where it applies:** `auth_remote_datasource.dart`, `profile_remote_datasource.dart`, `user_model.dart`.

### 2026-08-25 — Store category ids are not catalog category ids
- **Rule:** Vendor `storeCategoryId` comes from `allStoreCategoriesProvider` (`GET /api/storecategories`); `allCatalogCategoriesProvider` (`GET /api/categories`) is only product taxonomy. The id spaces differ, and mixing them fails vendor create.
- **Where it applies:** `register_screen.dart` store step, `edit_profile_screen.dart` store category picker.

### 2026-08-26 — Routes reading a required state.extra need a redirect guard
- **Rule:** `extra` isn't serialized, so deep links and restarts arrive with `null`. A route whose screen needs a non-null `extra` adds `redirect:` checking `state.extra is! ExpectedType` (like `AppRoutes.otp`); if the argument can be optional, cast nullable instead (like `sendPackage`). Never force-cast in `pageBuilder`.
- **Where it applies:** `app_router.dart`.

### 2026-08-26 — Don't call a state-writing notifier method synchronously from initState
- **Rule:** Riverpod forbids provider writes during `initState`/`build`/`dispose`; a method whose first statement sets `state` crashes when called there. Defer: `Future(() { if (!mounted) return; ref.read(p.notifier).method(); })`. Local `setState` is fine.
- **Where it applies:** Screens that start a fetch/send from `initState` (e.g. `profile_verification_screen.dart`).

### 2026-08-27 — Verification flags are top-level in get-profile
- **Rule:** get-profile returns `{user, store, isEmailVerified, isPhoneVerified}` with the flags beside `user`, not inside it; they live on `ProfileEntity`. The `*VerificationRequired` flags may be absent — gate verification UX on `!isEmailVerified` / `!isPhoneVerified`. Only `send-login-otp` still echoes `otp`; debug-OTP snackbars key off a real non-empty `otp` field, not `kDebugMode`. A captured response always outranks an inherited code comment about a field's location — when a flag never flips, check where it's parsed before adding guards.
- **Where it applies:** `user_model.dart` `parseProfileResponse`, `profile_entity.dart`.

### 2026-08-27 — A compiling use-case chain isn't proof a feature is reachable
- **Rule:** When a collection confirms a route, adopt its body and headers too, not just the path (delete-account is `DELETE /api/auth/delete-account` with `{password, confirmationText}`). When auditing "is X implemented", grep the use-case provider for real call sites from a screen.
- **Where it applies:** Endpoint audits, `api_endpoints.dart`, profile verification and delete-account flows.

### 2026-08-27 — Field-level actions go in suffixIcon
- **Rule:** Inline field actions (Verify, status badges) are a compact `suffixIcon` with `suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0)` and a shrink-wrapped `TextButton`, not a row below the field. Shared inputs like `PhoneInputField` take an optional `suffix`.
- **Where it applies:** `edit_profile_screen.dart`, `phone_input_field.dart`, any trailing field action.

### 2026-08-27 — force: true must bypass request coalescing
- **Rule:** A `force: true` refresh starts a new fetch instead of awaiting one already in flight, and a monotonic per-fetch request id (checked before every `state` write) stops the older fetch from overwriting the fresh result. This is separate from `_sessionEpoch`, which only guards session boundaries.
- **Where it applies:** `ProfileNotifier.refreshProfileData`, any coalesced refresh with a force option.

### 2026-08-27 — Name wire-backed fields after the live keys
- **Rule:** Keep Dart field names for profile flags 1:1 with the JSON (`isEmailVerified`, `isPhoneVerified`); older alternate keys are parse fallbacks only.
- **Where it applies:** `parseProfileResponse`, `ProfileEntity`, `ProfileModel`, verification UI.

### 2026-08-27 — Id-backed edit fields need their own edit-state slot
- **Rule:** Every id-backed edit field (category, city, governorate…) has its own `editXxxId` in the edit state, written by the picker and read by `toUpdateProfileRequest()` — never fall back to the loaded entity's id in the request builder, or edits to that field silently don't save. Pickers in sheets use a bounded `ListView.builder` and pop the chosen id. Display labels are looked up by id from the reference list; dirty-checking compares ids, never localized names. When one screen's picker moves to a live API, grep sibling screens for the same picker.
- **Where it applies:** `profile_state.dart`, `profile_provider.dart` (`_profileEditEqualsUser`, `updateStoreCategory`), `edit_profile_screen.dart`.

### 2026-08-27 — Side effects on the session-restore path must not throw
- **Rule:** Providers read unconditionally from `Auth.build()`'s restore path (FCM token sync, analytics, delivery bridge) wrap platform calls in try/catch and log-and-no-op — e.g. `FirebaseMessaging.instance` throws on devices without Play Services. A nice-to-have feature must never fail session restore.
- **Where it applies:** `fcm_device_token_sync_provider.dart`, anything read from `Auth.build()`.

### 2026-08-27 — Mock profile merges backfill demo values
- **Rule:** `_mergeVendorMock`/`_mergeConsumerMock` fill any field the request didn't set from `mockVendorUser`/`mockConsumerUser`. Mock round-trip tests assert the backfilled value (with a comment) for those fields, not `null`.
- **Where it applies:** `profile_remote_datasource.dart`, `mock_users.dart`, `profile_update_payload_test.dart`.

### 2026-08-27 — No debug-mode exceptions in secret redaction
- **Rule:** Session/auth tokens are never exempted from log redaction, even in debug builds. If one debugging session needs a value, add a temporary `debugPrint` at the call site and remove it.
- **Where it applies:** `logging_interceptor.dart` `_redact`, any redaction utility.

### 2026-08-28 — Store name and description are single fields
- **Rule:** Vendor store name and description are one field each on the domain, DTO and wire (`storeName`, `storeDescription`) — don't send or store En/Ar variants. Parse `store.name`/`store.description` first; accept old En/Ar keys only as read fallbacks, skipping blanks. The user's full name stays bilingual (`fullName`/`fullNameAr`).
- **Where it applies:** `VendorRegisterParams`, `UpdateProfileRequest`, `UserEntity`/`UserModel`, register and update-profile datasources, edit-profile form.

### 2026-08-28 — Backend images
- **Rule:** Display backend images only through `AppCachedNetworkImage` / `AppNetworkImage.cached` / `AppNetworkImage.network` — raw `CachedNetworkImage`/`Image.network` lack the Basic license header and 401. They resolve URLs with `resolveBackendMediaUrl`, which rewrites relative `/uploads/…` paths, stale-origin `/uploads/` URLs and `*.tempurl.com`/`*.jtempurl.com`/`*.etempurl.com` hosts (stored with the upload-time trial host) onto `ApiEndpoints.baseUrl`, leaving third-party URLs alone — don't mutate stored URLs. Pass `errorListener` so real 404s show `errorWidget` quietly, and `cacheSize` for avatars.
- **Where it applies:** `media_url.dart`, `app_cached_network_image.dart`, `image_cache_manager.dart`, every backend image.

### 2026-08-28 — Providers that depend on auth are never read from Auth
- **Rule:** Session identity flows one way: `Auth` pushes into dependents through explicit methods (`bindSession`, `user:` arguments), and no provider that `Auth` reads may `ref.listen(authProvider)` — that's a `CircularDependencyError` in debug, whatever the timing. A notifier doesn't `ref.read` a sibling notifier to run teardown the sibling owns: return success and let the widget call it (e.g. `ProfileNotifier.deleteAccount` returns `bool`; the widget calls `Auth.logout`). Login/register analytics fire from the calling notifiers. When a listener is replaced by a push, rewrite the tests that drove it through fake emits.
- **Where it applies:** `auth_provider.dart`, `analytics_service.dart`, `profile_provider.dart`, `profile_menu_blocks.dart`, related tests.

### 2026-08-28 — iOS system context menu and navigator-wrapping widgets
- **Rule:** Keep `MediaQuery.supportsShowingSystemContextMenu` false in `MaterialApp.builder` (the iOS system menu asserts without an active text input connection). Don't animate or insert/remove siblings above a widget wrapping the navigator — it remounts every route. When Flutter names a chrome widget like `OfflineBannerHost` as the error-causing widget, it's an ancestor, not the culprit.
- **Where it applies:** `app.dart`, `offline_banner.dart`.

### 2026-08-28 — Reset debug platform overrides inside the test body
- **Rule:** Clear `debugDefaultTargetPlatformOverride` in a `try/finally` around the test body — `_verifyInvariants` runs before `addTearDown`.
- **Where it applies:** Widget tests overriding `TargetPlatform`.

### 2026-08-28 — Screens on shell branches must react to changed arguments
- **Rule:** A `StatefulShellRoute` branch can reuse its `State` across navigations, so a screen taking an identity-bearing `extra` (e.g. Add Listing in edit mode) syncs from both `initState` and `didUpdateWidget`, comparing the argument's id to what was applied, and resets when it goes back to null. Split "mark as editing" (plain field setter like `prepareForEdit`, safe synchronously; the draft loader checks it and skips) from the `state =` hydration (`loadForEdit`, deferred with a mounted check).
- **Where it applies:** `add_listing_screen.dart`, `listing_form_notifier.dart`, `app_router.dart`.

### 2026-08-28 — Removing a role's tab: catch stray navigations centrally
- **Rule:** Vendors have no Home/Explore tabs (vendor shell: Orders, Add Listing, Wallet, Profile). `computeXStoreAuthRedirect` redirects vendors and couriers from `home`/`explore` to `roleHome`, covering every stray `context.go`; compute `roleHome` before any earlier `return` that needs it. When removing a tab, grep `AppRoutes.<tab>` repo-wide.
- **Where it applies:** `router_notifier.dart`, `app_router.dart`, `xstore_bottom_nav.dart`.

### 2026-08-29 — Await AnalyticsService readiness in plain ProviderContainer tests
- **Rule:** `AnalyticsService` initializes asynchronously; a plain `ProviderContainer` test whose path tracks events must `await container.read(analyticsServiceProvider).ready` before assertions, or disposal races `_init()` and a later test fails. Widget-tree tests don't need this.
- **Where it applies:** `ProviderContainer` tests over checkout, explore, cart and other tracked flows.

### 2026-08-29 — Tests tapping through verification-gated screens seed a verified profile
- **Rule:** `requirePhoneVerified` (email OTP first when the email is unverified, then phone) opens real OTP sheets. Screen-level tests tapping through checkout or other gated flows override `profileNotifierProvider` with `ProfileState(profile: ProfileEntity(user: ..., isEmailVerified: true, isPhoneVerified: true))`. Tests calling the notifiers directly skip the gate but lose wiring coverage — choose deliberately.
- **Where it applies:** `checkout_screen.dart`, `require_phone_verified.dart`, gated-screen tests.

### 2026-08-29 — Never fabricate live-looking state
- **Rule:** Countdowns, "X viewing" counters and urgency badges need a real backing field or they don't ship; if there's none, remove the element rather than inventing a schedule (a flash-sale timer that reset every launch was removed).
- **Where it applies:** Home, product and listing UI.

### 2026-08-29 — Hold a listener on autoDispose providers across awaits in tests
- **Rule:** `container.read` doesn't keep an autoDispose provider alive; if a test awaits anything between setup and assertions, call `container.listen(provider, (_, __) {})` first, or the provider is disposed and rebuilt mid-test.
- **Where it applies:** `ProviderContainer` tests of autoDispose providers.

### 2026-08-29 — Refetch the detail before editing an item from a list
- **Rule:** List endpoints may return a summary shape. Before hydrating an edit form from a list entity, refetch the item (`fetchListingById` → `GET /api/listings/{id}`), falling back to the list entity on failure.
- **Where it applies:** `my_listings_screen.dart` `_openEdit`, listing repository/datasource, any edit flow opened from a list.

### 2026-08-29 — get-profile 404 with a token means the session is dead
- **Rule:** `restoreSession` trusts cached credentials without validating them. A `GET /api/auth/get-profile` 404 on a request carrying `X-Auth-Token` (deleted account, rotated host) runs the same cleanup as a failed refresh — the shared `_clearInvalidSession` in `dio_provider.dart` — never a separate copy.
- **Where it applies:** `dio_provider.dart`, any future "this error means the session is dead" signal.

### 2026-08-29 — Screens showing commission read vendor order stats
- **Rule:** `commissionFeeEgpForCategoryProvider` always watches `vendorCommissionSnapshotProvider`, which fetches vendor order stats (a real Timer under `MOCK=true`). Tests mounting Add Listing or commission widgets with a vendor session override `vendorCommissionSnapshotProvider` directly (e.g. `overrideWith((ref) async => null)`).
- **Where it applies:** Tests over `AddListingScreen`, `CommissionBreakdownCard`, `VendorCommissionAlertBanner`.

### 2026-08-29 — Home is the Active catalog; Explore is a 50 km geo search
- **Rule:** `GET /api/home` returns the unfiltered Active catalog; `GET /api/listings` only returns Active listings within 50 km of `X-Latitude`/`X-Longitude` (seed stores have bad coordinates). When the nearby search's first page is empty, Explore falls back to the home aggregate (deduped, narrowed by keyword/filters) — never send fake coordinates. Parse tiles from the live DTO (`title`/`titleEn`, `categoryNameEn`, `userName`/`storeName`) and drop non-public statuses with `isPublicLiveListingStatus`.
- **Where it applies:** `explore_remote_datasource.dart`, `search_result_model.dart`, `home_remote_datasource.dart`, `listing_model.dart`.

### 2026-08-29 — Shell navigation rules
- **Rule:** Shell-branch `GoRoute`s use `builder`, never `pageBuilder`/`state.pageKey` (duplicate GlobalKeys on tab switch). Moving a screen into a shell branch: delete the old stack route with the same path, switch every `push` of it to `go`, remove back-button chrome, and keep `_vendorShellBranches()` and `xstore_bottom_nav.dart` labels/icons/accent index in the same order (the accent is the Add Listing index). When the GoRouter instance changes, key `MaterialApp.router` on it (`ObjectKey(router)`) and dispose the old router next frame.
- **Where it applies:** `app_router.dart`, `app.dart`, `xstore_bottom_nav.dart`.

### 2026-08-29 — GoRouter redirect must not use a ref that watches auth
- **Rule:** A redirect closure captured at provider build time can't use that provider's `ref` when the provider watches something that changes in the same frame as `context.go` (Riverpod's "dependency changed but before rebuilt" assert). Read through `RouterNotifier.redirectFor` (which only `listen`s) or `ProviderScope.containerOf(context)`. Reproduce with `go` on the captured router instance, not a fresh `container.read(goRouterProvider)`.
- **Where it applies:** `app_router.dart`, `router_notifier.dart`.

### 2026-08-29 — Logout keeps the router; splash is first-run only
- **Rule:** Keep the last signed-in shell role across logout so GoRouter isn't rebuilt at splash; `computeXStoreAuthRedirect` sends signed-out users to login. A router rebuilt by a real role change starts from current auth (login or role home), not splash. Persist `onboardingComplete` when splash leaves for a restored session.
- **Where it applies:** `app_router.dart` (`_routerInitialLocation`), `splash_screen.dart`, logout/delete-account.

### 2026-08-29 — Never use a late final field initializer for AnimationController
- **Rule:** A `late final AnimationController = AnimationController(...)` initializer runs on first access, which can be `dispose()` — creating a ticker on a deactivated element and aborting unmount. Create controllers in `initState`, or use `PulsingAnimationBuilder` for conditional pulses.
- **Where it applies:** Any `State` with a ticker mixin (e.g. `vendor_orders_screen.dart`).

### 2026-08-29 — Listing writes require title and description
- **Rule:** The listing write DTO binds `title`/`description`; send them (EN value, falling back to AR). `titleEn`/`titleAr`/`descriptionEn`/`descriptionAr` are GET keys — sending them extra is harmless.
- **Where it applies:** `listing_remote_datasource.dart` `_listingFormData`, `test/listing_create_multipart_test.dart`.

### 2026-08-29 — Hide unfinished features completely
- **Rule:** Don't ship profile tiles or preference switches for features that aren't live: comment them with `TODO(phase-2)` and drop their `ref.watch`. Keep route constants but redirect them to profile; `rg` every other entry into the path (app-bar gear, aliases, inbox icons) and remove guest-accessible entries plus their tests in the same change. Currently deferred: payment methods, saved addresses menu, store hours, packages, push/email prefs, help center, notification settings, seller chat (product chat button, `_messageSeller`, `/chat/:threadId` → notifications). Live WhatsApp contact buttons (store, orders) stay.
- **Where it applies:** `profile_menu_blocks.dart`, `profile_sliver_app_bar.dart`, `app_router.dart`, `app_routes.dart`.

### 2026-08-29 — There is no cart API
- **Rule:** The hosted API has no `/cart` resource: the live cart is client-side, persisted per user in SharedPreferences (`cart_items_v1_<userId>`), and checkout posts `POST /api/orders` per line. Never call `/cart` or apply client-side coupon discounts (they aren't sent with the order). Screens show error/retry when `items.isEmpty && error != null`, never the empty state.
- **Where it applies:** `cart_remote_datasource.dart`, `cart_consumer_body.dart`, `coupon_input_row.dart`, any list screen that maps empty+error to its empty state.

### 2026-08-29 — Banners are tappable only with a real actionUrl
- **Rule:** Wire `onTap` only when `actionUrl` is non-empty after trimming; live banners without one stay inert — no invented destination.
- **Where it applies:** `hero_banner_carousel.dart`, promotional tiles.

### 2026-08-29 — Confirm the live navigation graph before deleting an auth path
- **Rule:** Same-named providers can be the live flow (`phone_auth_provider.dart` is the backend OTP login — keep it). `rg` every push/go and notifier call site before deleting; once confirmed dead, remove the datasource, use cases and endpoint constant together.
- **Where it applies:** Auth feature, any "dead" login variant.

### 2026-08-30 — Email and phone changes are OTP-gated
- **Rule:** `PUT /api/auth/update-profile` ignores `email`/`phoneNumber`, so never add them to `UpdateProfileRequest`. On Edit Profile (consumers), tapping email/phone prompts for the new value and runs `ProfileVerificationScreen`; Save OTP-gates any value that differs from the stored one. After OTP, `refreshProfileData(preserveEdits: true)`. Show "Verified" for the typed value (session OTP, or stored value + flag). Phone requires a verified email first. Vendors' email/phone are read-only.
- **Where it applies:** `edit_profile_screen.dart`, `phone_input_field.dart`, `profile_provider.dart`, `profile_verification_screen.dart`.

### 2026-08-30 — Every pre-login screen must be in isAuthRoute
- **Rule:** Adding a pre-login `GoRoute` isn't enough — list it in `isAuthRoute` or signed-out users bounce to login. Forgot-password: `POST /api/auth/verify-forget-password-otp` takes email, otpToken, newPassword and confirmNewPassword in one body — collect the OTP on its screen and submit all four from the password screen.
- **Where it applies:** `router_notifier.dart`, forgot-password screens.

### 2026-08-30 — Resend cooldowns block pumpAndSettle
- **Rule:** Screens starting `OtpResendCooldown` in `initState` are driven with `pump()`/`pump(Duration)`, not `pumpAndSettle()`.
- **Where it applies:** Tests of OTP screens.

### 2026-08-30 — ref.invalidate resets a list; it doesn't refetch
- **Rule:** Invalidating a non-autoDispose `StateNotifierProvider` recreates it empty; a refetch only happens if the screen's `initState` runs again, which doesn't happen on pop or inside a shell `IndexedStack`. After a mutation, update the list in place (`VendorOrdersNotifier._mergeOrder`) instead of invalidating it. Check both the vendor and consumer order-detail notifiers — they have different shapes but share this hazard. Tests assert the list stays populated after a mutation.
- **Where it applies:** `vendor_order_detail_provider.dart`, `order_detail_provider.dart` `_finalizeMutation`, `orders_provider.dart`.

### 2026-08-30 — Change a helper's signature and its call sites together
- **Rule:** Grep call sites first and change signature and callers in the same edit batch (a multi-line `perl`/`sed` is fine for mechanical changes).
- **Where it applies:** Shared and test helpers.

### 2026-08-30 — Password fields get the eye toggle
- **Rule:** Every password `AuthTextField` has the `LucideIcons.eye`/`eyeOff` suffix toggling `obscureText`, as login and register do.
- **Where it applies:** Auth and password screens.

### 2026-08-30 — Deep links to guest routes must not use push's login staging
- **Rule:** `navigateToPushRoute`/`pendingPushRouteProvider` stage every route until login (push is logged-in only). Deep links can target guest-accessible routes like `/product/:id`, so unify at the route-string level, not by reusing that helper. Check a navigation helper's auth assumptions before routing a new trigger through it.
- **Where it applies:** `lib/core/deeplink/deep_link_handling_provider.dart`, `fcm_push_navigation.dart`.

### 2026-08-31 — Release compile error naming IntegrationTestPlugin is a stale registrant
- **Rule:** Run `flutter clean` (and delete `android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java` if it remains), then rebuild. Never move `integration_test` into `dependencies`.
- **Where it applies:** Local release builds.

### 2026-09-01 — Only send coordinates inside Egypt
- **Rule:** The API 400s coordinates outside Egypt. `AppLocationCache.set` ignores fixes failing `LocationService.isInEgypt` (≈ lat 22–31.7, lng 25–37) and keeps the Cairo fallback. On the iOS Simulator, set an Egyptian location with `xcrun simctl location booted set` (it resets on Simulator restart).
- **Where it applies:** `app_location_cache.dart`, `location_service.dart`, `dio_provider.dart`, Simulator runs.

### 2026-09-01 — Forms split between notifier state and local controllers
- **Rule:** Add Listing's controllers re-sync only when `draftRevision` changes, so every reset (including publish success, done synchronously before awaiting draft deletion) must bump it. When a parent picker change invalidates a child text field (category → brand), clear it in the same `copyWith` and sync its controller (bump the revision or `ref.listen` the field).
- **Where it applies:** `listing_form_notifier.dart`, `add_listing_screen.dart`, other shell-tab forms with local controllers.

### 2026-09-01 — Money defaults of 0 need more than ??
- **Rule:** `SystemSetting.CommissionValueOnOrder` is seeded as 0, so treat a missing or non-positive fee as unset and use `kStarterCommissionFeeEgp` — `??` only replaces null. Parse vendor-orders stats tolerantly (camelCase/PascalCase, number or string, optional `{data: {...}}` envelope).
- **Where it applies:** `commission_config_provider.dart`, `orders_remote_datasource.dart` `getVendorOrderStats`.

### 2026-09-02 — Storefronts and undeployed legacy routes
- **Rule:** Auxiliary legacy modules the hosted backend doesn't serve (e.g. `/vendors/*/store-hours`) use `LegacyRouteOptions.allowNotFound()`: reads return defaults, writes persist in the session cache, and vendor-only fetches are skipped for non-vendors. Other sellers' storefronts come from the catalog (`GET /api/listings`, home fallback) filtered by listing `userId` — never the undeployed `/users/{id}/store` or `/users/{id}/listings`; a seller missing from the catalog is an empty store, not an error. Store head and grid share one fetch, invalidated at the start of `getVendorStoreProfile` so pull-to-refresh refetches; skip unparseable rows and never null a loaded profile because listings failed. The vendor's own store waits for auth before deciding it's theirs, then uses `GET /api/listings/my-listings`.
- **Where it applies:** `legacy_route_options.dart`, `store_hours_datasource.dart`, `profile_remote_datasource.dart`, `vendor_store_screen.dart`, Visit Store call sites.

### 2026-09-02 — Text fields in dialogs and sheets
- **Rule:** A field read only at submit time needs no controller: track it with `onChanged: (v) => local = v`, or use `TextFormField.initialValue`. When a controller is needed, own it in a `StatefulWidget` inside the dialog/sheet and dispose it in `State.dispose`. Never create one in a `show*` helper and dispose it when `showAnimatedDialog`/`showGeneralDialog`/`showModalBottomSheet`/`showDialog` returns — those futures complete at `Navigator.pop` while the exit animation still holds the field ("used after being disposed", then Duplicate GlobalKeys / `_dependents.isEmpty`). Grep `show*` helpers for `TextEditingController(` in review.
- **Where it applies:** All dialogs, sheets and `show*` helpers.

### 2026-09-02 — Cross-role tests share one fake repository
- **Rule:** Mock consumer and vendor order fixtures are disjoint, and live orders need admin-approved listings. To test one order as seen by both roles, implement an in-memory `OrdersRepository` and point two `ProviderContainer`s (one `authProvider` override per role) at the same instance via `ordersRepositoryProvider.overrideWithValue(repo)`.
- **Where it applies:** `test/order_lifecycle_full_app_test.dart`, cross-role tests.

### 2026-09-02 — Live-path datasource tests skip under MOCK=true
- **Rule:** A test scripting Dio exercises the live path only: gate its groups with `skip: MockConfig.useMock ? 'Requires MOCK=false — exercises the live (non-mock) datasource path' : false`. CI runs on `main`, not `dev`, so run `flutter test --dart-define=MOCK=true` locally rather than trusting the workflow step exists.
- **Where it applies:** Datasource tests with scripted Dio.

### 2026-09-02 — Screen-level live-mode widget tests (template: test/orders_screen_live_flow_test.dart)
- **Rule:** Wrap shell screens in `Scaffold`. Set `SharedPreferences.setMockInitialValues({})` and `FlutterSecureStorage.setMockInitialValues({})` in `setUp` (otherwise it hangs silently). Use `ProviderScope`, not `UncontrolledProviderScope` with manual disposal (pending Timer), and get the container via `ProviderScope.containerOf`. After `pumpWidget` + `pump()`, `await container.read(authProvider.future)` and re-trigger the screen's fetch — the `initState` post-frame fetch can run before the fake auth resolves and bail silently. Inside the test's FakeAsync zone, never `await` a Dio-backed call directly: fire it `unawaited` and drive it with a bounded `tester.pump(duration)` loop (`pumpAndSettle` hangs on `flutter_animate` entrances). Never `expect()` inside a Dio interceptor — capture `RequestOptions` and assert afterwards. To debug a silent hang, bisect with a throwaway print-instrumented test under a shell `timeout`.
- **Where it applies:** Screen-level `skip: MockConfig.useMock` widget tests.

### 2026-09-02 — Reuse another feature's use case instead of duplicating it
- **Rule:** Order reviews call the product feature's `createReviewUseCaseProvider` with `ReviewWriteParams` for the order's listing (`POST /api/listings/{listingId}/reviews`); reviews belong to listings. Importing another feature's domain entity and dependency provider is fine; a parallel use case duplicates the wire contract. Order actions (confirm/reject/ship/review) exist in both `order_card.dart` and `order_action_buttons.dart` — fix both copies together.
- **Where it applies:** `order_card.dart`, `order_action_buttons.dart`, cross-feature capabilities.

### 2026-09-02 — Consumer order detail
- **Rule:** On `/me`-scoped routes, reject only a present owner id that mismatches — never a missing one. If `GET /orders/me/{id}` 404s or throws, fall back to the order from `GET /orders/me`. Unwrap `{data|Data}` and read camelCase/PascalCase. Orders echo the create body (`listingId`, `quantity`, `latitude`, `longitude`) or `items: []` plus nested `listing`/`deliveryAddress`/`seller`: parse display fields from the nested objects with listing keys (`titleEn`, `imageUrls`, `userId`/`userName`/`userAvatar`, `storeName`), falling back to the flat `listingId` line; fetch `GET /api/listings/{id}` only for a line missing name, image or price, with `allowNotFound()` and a cached miss (sold listings 404). Never map listing `userId` onto `consumerId`. Disable Visit Store when `order.vendorId` is empty. A 202 from the analytics endpoint is success, not the error.
- **Where it applies:** `orders_repository_impl.dart`, `orders_remote_datasource.dart`, order detail UI.

### 2026-09-02 — Wishlist wire contract
- **Rule:** Unwrap `{data|Data}` (or a bare array / `{items|data|results}` via `unwrapJsonObjectList`) on GET/POST; keep the request `listingId` if the body omits it. Remove tries candidate ids (wishlist row id, then listing id, skipping client-side `wish_` ids), treating 404 as already gone. POST 409 means already saved — return the existing row. When upstream changes a datasource your test scripts, read the full diff and trace which id actually gets sent.
- **Where it applies:** `wishlist_remote_datasource.dart`, `wishlist_provider.dart`, wishlist tests.

### 2026-09-02 — Finding widgets vs tapping them in scrollable tests
- **Rule:** `skipOffstage: false` finds sliver children built within the cache extent but unpainted; content beyond it isn't built at all, so scroll with `tester.drag` in a few small steps (one big drag can recycle earlier sections). A widget being found doesn't mean it's tappable: scroll it into view before `tap`, and with a large `cacheExtent` near a fixed footer, check `tester.getRect` — the tap can land on the footer instead. `pump()` after `enterText` before tapping a button enabled by that text. When a tap misses, look for a SnackBar/dialog covering the target before using `warnIfMissed: false`.
- **Where it applies:** Widget tests over sliver screens (order detail, product detail, home, cart).

### 2026-09-02 — Guard auth-derived ids in every notifier method
- **Rule:** Any notifier method that derives an id from `ref.read(authProvider).valueOrNull` bails with `if (user == null) return;` — otherwise an `initState` fetch racing auth produces a real, user-visible unauthorized error.
- **Where it applies:** `order_detail_provider.dart` `fetchOrder` and similar methods.

### 2026-09-02 — Screens needing a routed test harness
- **Rule:** If `initState`/`build` calls `GoRouterState.of`/`context.go`/`push` unconditionally (e.g. `ExploreScreen` reads `?category=`), the test needs a `GoRouter` harness from the first pump. Explore's typeahead reuses the search endpoint, so a matching query legitimately renders the same title twice — use `findsWidgets`.
- **Where it applies:** `test/explore_screen_live_flow_test.dart`, screens reading router state early.

### 2026-09-02 — Check for a mock split before adding skip guards
- **Rule:** Grep the feature's datasource for `MockConfig` before adding `skip: MockConfig.useMock`. Notifications has no mock branch and always hits the live backend, so its tests run in both modes without a skip.
- **Where it applies:** New screen tests.

### 2026-09-02 — VendorOrdersScreen is its own implementation; layout rules found there
- **Rule:** `VendorOrdersScreen` (vendor shell tab, `VendorOrdersNotifier`, `VendorOrderCard`, `RejectOrderSheet`) is separate from `OrdersScreen`'s `VendorOrdersView` — confirm which class a route builds before assuming test coverage. A `Row` with `CrossAxisAlignment.stretch` inside a list item needs `IntrinsicHeight` (unbounded height otherwise throws). Center empty states with `LayoutBuilder` + `SingleChildScrollView` + `ConstrainedBox(minHeight: maxHeight)`, not a fixed fraction of screen height. When a test fails with an unrelated-looking framework error, override `FlutterError.onError` in a throwaway script (calling the original) to see the first layout error.
- **Where it applies:** `vendor_order_card.dart`, `vendor_orders_screen.dart`, list items and empty states.

### 2026-09-02 — Don't dart format whole files after targeted edits
- **Rule:** Many files here aren't at the default 80-column width, so `dart format` on a whole file (or a batch) produces hundreds of unrelated changed lines — never run it on a directory (`dart format lib` rewrote 440 files); format only files you wrote from scratch. Check `git diff --stat` after formatting; if it's out of proportion, restore the file (`git show HEAD:<path>`, or a pre-format copy when it has other uncommitted edits) and reapply the edit by hand. A slightly misindented wrapped block is better than a 100-line unrelated diff.
- **Where it applies:** Every targeted edit.

### 2026-09-02 — Shared labels on detail screens appear twice
- **Rule:** Vendor order detail renders actions both in an inline urgent card and in the bottom action sheet (same l10n keys, e.g. `vendorMarkProcessing`), and the buyer name can appear in two cards. Check both surfaces before asserting `findsOneWidget`; default to `findsWidgets` for status-dependent labels.
- **Where it applies:** `test/vendor_order_detail_screen_live_flow_test.dart`, screens with an inline card plus an action bar.

### 2026-09-03 — Live-flow test harness: read the screen before choosing the pattern
- **Rule:** Read how the screen gets its data before copying the `_pumpReady` re-trigger pattern: screens that `await authProvider.future` themselves (`VendorStoreScreen`) or are driven by a `FutureProvider` watching auth (`courierCashWalletProvider`) need only `pumpWidget` + settle. Screens that fetch nothing (`EditProfileScreen`, OTP screens seeded by an earlier screen) need the harness to seed state — call the real method `unawaited(...)` then pump; a direct `await` of any Dio-backed call anywhere in a test body hangs. `authRepositoryProvider` is separate from `authProvider`: code reading it builds the real `AuthRepositoryImpl`, which touches Firebase both through `SocialAuthDatasource` and its own `firebaseAuth` parameter. Stub it with a `Fake implements AuthRepository` when it's incidental (see `profile_prefetch_test.dart`), or build a real `AuthRepositoryImpl` with fake social/Firebase arguments when the screen's own flow runs on it. Snackbars queue one at a time (3s each), so budget settle time for the queue; screens with a minimum delay (splash: 2.5s) need a longer settle too. Skip auth-local methods from Dio scripting when they don't hit the network (`restoreSession` only reads secure storage); seed a persisted session with the real `UserModel(...).toJson()` under `PrefsKeys.authUser`.
- **Where it applies:** All `test/*_live_flow_test.dart`.

### 2026-09-03 — Whether a test needs the MOCK skip depends on the whole path
- **Rule:** A screen is mode-agnostic only if every provider its flow touches — including gates it calls first (`requirePhoneVerified` → `profileNotifierProvider` → mocked `getProfile`) and the provider that picks the datasource class (delivery chooses between `DeliveryRequestMockDataSource` and `DeliveryRequestRemoteDataSource` in `delivery_request_dependencies.dart`) — is live in both modes. Grep dependency files as well as datasources for `MockConfig`.
- **Where it applies:** Live-flow tests for add-listing, delivery and courier screens, and anything behind `requirePhoneVerified`/`requireLogin`.

### 2026-09-03 — Test fixtures for fixed-enum screens and legacy routes
- **Rule:** Screens doing `.firstWhere` over a fixed list with no `orElse` (store hours over all 7 `egyptWeekOrder` days) need every value in the fixture. `LegacyRouteOptions.allowNotFound()` routes need no special handling when the scripted interceptor answers 200. The routed interceptor matches method + path only, so one route serves callers that differ only in query params.
- **Where it applies:** `test/store_hours_screen_live_flow_test.dart`, scripted-Dio tests.

### 2026-09-03 — Indexing form fields in tests
- **Rule:** `PhoneInputField` wraps a `TextFormField`, so address fields on long forms by position in `find.byType(TextFormField)` (build order) — `find.byType(TextField)` also matches the field inside every `TextFormField`.
- **Where it applies:** `test/send_package_screen_live_flow_test.dart`, forms mixing custom and plain fields.

### 2026-09-03 — Seed SharedPreferences with the constant, not its name
- **Rule:** `PrefsKeys` identifiers differ from their string values (`locationPermissionRationaleShown` = `'location_permission_rationale_shown'`), so seed with `{PrefsKeys.x: value}`. Every auth-success path calls `maybeShowLocationPermissionPrompt`, so live tests of splash, login, OTP, register and courier login seed that flag. A test that hangs with no error is usually awaiting a real dialog — bisect with temporary prints in the screen method (remove them afterwards) instead of adding pumps.
- **Where it applies:** Tests seeding `SharedPreferences`, auth screen tests.

### 2026-09-03 — Variable-length text in fixed-flex slices must scroll
- **Rule:** A text block sharing a fixed-`flex` or fixed-fraction slice with fixed-height siblings (buttons, dots, padding) overflows on short screens or longer translations. Wrap it in `SingleChildScrollView` (keeping `CrossAxisAlignment.stretch`); with `AnimatedSwitcher`, put the `ValueKey` on the scroll view.
- **Where it applies:** `onboarding_screen.dart`, similar layouts.

### 2026-09-03 — Router-driven screens and test containers
- **Rule:** When a screen's success path relies on the app's redirect (e.g. `SocialRoleScreen` never navigates itself), build the test router with the real `routerNotifierProvider` (`refreshListenable` + `redirect: (_, s) => refresh.redirectFor(s.matchedLocation)`) from an explicit `ProviderContainer` passed via `UncontrolledProviderScope` — don't invent routing rules. Seed container state only after the first `pumpWidget` (FakeAsync doesn't advance before it). Any `ListView`, `.builder` or not, can leave off-screen children unbuilt: `scrollUntilVisible(..., scrollable: find.byType(Scrollable).first)` before asserting. In `testWidgets` with a self-created container that reaches `adoptSession`/`setUser`, await `analyticsServiceProvider.ready` and call `container.dispose()` as the last line of the body — the pending-timer check runs before `addTearDown`.
- **Where it applies:** `test/social_role_screen_live_flow_test.dart`, redirect-driven screens, tests owning their container.

### 2026-09-03 — Prefer real repositories in auth screen tests
- **Rule:** Before faking `AuthRepository`, grep the methods the screen calls: when they're plain Dio calls with no `MockConfig` branch or Firebase/social use (forgot-password, verify OTP), use the real `AuthRepositoryImpl` with inert social/Firebase fakes, script Dio, assert on captured `RequestOptions.data`, and skip no mode. `test/helpers/stub_auth_repository.dart` remains only for `auth_redirect_and_providers_test.dart`. Advance past `OtpResendCooldown` (`pump(Duration(seconds: 61))`) before tapping Resend, and use a settle loop, not two bare `pump()`s, after scripted responses.
- **Where it applies:** Auth screen tests.

### 2026-09-03 — Assert on real l10n strings and the real tap target
- **Rule:** Grep `lib/l10n/app_en.arb` for the exact value before writing `find.text` — never guess wording from key names. When a `ListTile` has no `onTap`, tap its interactive child (`find.descendant(of: tile, matching: find.byType(Switch))`).
- **Where it applies:** Widget tests.

### 2026-09-03 — integration_test needs a real Android/iOS target
- **Rule:** `bootstrap()` initializes Firebase unconditionally and `firebase_options.dart` has no Linux case, so integration tests can't run on Linux desktop regardless of toolchain fixes. Before promising to run one, check for a real device/emulator (`flutter devices`); otherwise deliver analyze-clean `integration_test/*.dart` files and say they weren't executed. (If Linux builds are ever needed: install `libgtk-3-dev libsecret-1-dev`, run Xvfb with `DISPLAY`, and `flutter clean` if `CMAKE_INSTALL_PREFIX` is stale.)
- **Where it applies:** `integration_test/`, headless sessions.

### 2026-09-03 — Integration tests stop before known backend walls
- **Rule:** Check these lessons for known backend blockers before chaining real preconditions. A fresh account can't complete checkout end to end: email OTP delivery doesn't work and new listings need admin approval. Stop the test at the last reliably reachable step (e.g. add to cart) and name the blockers in a file comment.
- **Where it applies:** `integration_test/register_and_shop_test.dart`, future end-to-end tests.

### 2026-09-04 — Never parent the navigator with a Flex
- **Rule:** `MaterialApp.builder`'s child never goes inside `Column`/`Row`/`Flex`/`Expanded`. App-wide chrome overlays it in a `Stack` (`StackFit.expand`, navigator always index 0, banner `Positioned`), so showing chrome never changes the navigator's slot, constraints or parent. Regression-test with an open dialog plus a connectivity toggle and assert Overlay element identity.
- **Where it applies:** `offline_banner.dart`, any app-wide banner.

### 2026-09-04 — Screens opened with go need an explicit back button
- **Rule:** A screen reached by `GoRouter.go` (post-checkout, FCM, deep link) has no stack, so the implied back button disappears. Give it a `leading` that pops when `Navigator.canPop()` and otherwise `go`s to the role's list; use `GoRouter.maybeOf` so tests without a router work. Don't switch the confirmation CTA to `push` (checkout would stay underneath).
- **Where it applies:** `order_detail_screen.dart`, screens opened with `go` after a flow.

### 2026-09-05 — POSTs to this backend need a JSON body
- **Rule:** Dio only sets `Content-Type: application/json` when `data` is present, and the ASP.NET API returns 415 for a bodyless POST. Send the field the UI already has (e.g. `reason` on cancel).
- **Where it applies:** `orders_remote_datasource.dart` `cancelOrder`, action POSTs.

### 2026-09-05 — Cancelled orders vanish from the consumer endpoints
- **Rule:** After a 2xx cancel, don't GET `/orders/me/{id}` — cancelled orders 404 there and drop out of `/orders/me`. Post with `_dio.post<dynamic>`, unwrap via `_asOrderMap` (a `data: null` envelope isn't an order), keep the UI snapshot (`takingStatusFrom`) as a cancelled stub, and keep a loaded order on `Failure.notFound`. Use `allowNotFound()` on the by-id GET.
- **Where it applies:** `orders_remote_datasource.dart`, `order_detail_provider.dart`, `orders_provider.dart`, `OrderEntity.takingStatusFrom`.

### 2026-09-05 — Refresh shell-tab lists on re-entry
- **Rule:** `IndexedStack` shell tabs stay mounted, so `initState` fetches once. Refresh when the route becomes this tab again (listening to `GoRouter.routerDelegate` via `GoRouter.maybeOf`), keeping the current list visible while refetching.
- **Where it applies:** `orders_screen.dart`, `vendor_orders_screen.dart`, other shell-tab lists.

### 2026-09-05 — Vendor status mutations fall back to vendor endpoints
- **Rule:** `_setVendorOrderStatus` unwraps via `_asOrderMap` before checking the response, and with a `vendorId` falls back to searching `getVendorOrders` instead of the consumer-scoped `GET /orders/me/{id}`. `vendorId` is optional through the use cases because couriers call the same `markShipped`/`markDelivered` (`courier_deliveries_provider.dart`). Grep every use-case provider call site before calling a method single-role.
- **Where it applies:** `orders_remote_datasource.dart`, orders repository and use cases.

### 2026-09-07 — Inline links in sentences
- **Rule:** Tappable words inside a sentence are `InkWell` + `Text` (same typography, accent + weight) in a `Wrap` with `WrapCrossAlignment.center` — not `TextButton`, and no `TapGestureRecognizer` created in a stateless `build` (it leaks). Follow `register_screen.dart`.
- **Where it applies:** `checkout_review_section.dart`, terms/privacy copy.

### 2026-09-07 — Checkout review shows everything that will be submitted
- **Rule:** The confirm step displays address, payment and the delivery note (under estimated delivery, hidden when blank). The payment step's note controller is seeded from `checkoutProvider.deliveryNote` because the step widget is recreated on each visit. The review block uses the same raised `Material` as `CartSummaryCard` (`surfaceColor`, `AppSpacing.lg` radius, elevation 1, shadow 6% of `textPrimary`, `AppSpacing.lg` padding), with terms and the summary card outside it.
- **Where it applies:** `checkout_review_section.dart`, `checkout_payment_section.dart`.

### 2026-09-07 — Full-height confirmation sheets center their message
- **Rule:** Wrap the message in `Expanded` + `MainAxisAlignment.center` above pinned bottom CTAs; a trailing `Spacer` alone top-aligns it.
- **Where it applies:** `order_confirmation_sheet.dart`, similar success sheets.

### 2026-09-07 — Consumer order detail layout
- **Rule:** Status icon sits in a `Row` with the status word. Sections (timeline, items, address, payment) use the existing `_WhiteCard` with the title inside and `AppSpacing.lg` below it. Item rows: name, then one `bodySmall` line `category · condition` — no `Chip`s. Shop photo via `AppCachedNetworkImage` (initial on error/empty), parsed from `storeImageUrl`/`storeLogoUrl` before `userAvatar`. Shipped cards pair Track and Confirm Receipt as equal compact `Expanded` buttons, `maxLines: 1`, with the check as an `Icon` (`ordersConfirmReceipt` is plain text).
- **Where it applies:** `order_detail_scroll_content.dart`, `order_item_tile.dart`, `order_card.dart`, `order_action_buttons.dart`.

### 2026-09-07 — Vendor order detail layout
- **Rule:** Status actions (confirm/reject, mark processing/shipped) appear only in the bottom action bar, not above the fold. Status banners are compact (`titleSmall`, `md`/`sm` padding). Reject and Confirm get equal `Expanded` width. Confirm is `AppColors.success`; Mark as Processing/Shipped use `AppColors.accent`. The buyer card is identity (avatar, name, phone, WhatsApp); the address card is location only (street, then city/wilaya), skipping empty lines, with no dead map button.
- **Where it applies:** `vendor_order_detail_screen.dart`, `vendor_order_action_sheet.dart`, `vendor_order_card.dart`.

### 2026-09-07 — Parsing the buyer on vendor orders
- **Rule:** Live vendor rows omit top-level `consumerName`. Read name/phone/avatar from nested `buyer`/`consumer`/`customer`, then the order-level `user` when it isn't the vendor (id ≠ `vendorId`, name ≠ store name), then root `fullName`/`fullNameEn`/`fullNameAr` (never `userName`/`name` — those are the listing or vendor), then the delivery address.
- **Where it applies:** `orders_remote_datasource.dart` `_orderFromApiMap`.

### 2026-09-07 — Vendor status PUT sends the status name
- **Rule:** `PUT /api/vendor/orders/status` body is `{orderIds: [...], status: "Confirmed"}` using `orderStatusToWireName` (Pending/Confirmed/Processing/Shipped/Delivered/Cancelled) at the JSON root — not the int code (GET responses carry ints, parsed by `orderStatusFromWire`) and not wrapped in `{request: ...}`.
- **Where it applies:** `orders_remote_datasource.dart` `_setVendorOrderStatus`, `order_entity.dart`.

### 2026-09-07 — Shipping info is local; refetches must not blank it
- **Rule:** `GET /vendor/orders` has no tracking fields. After Mark as Shipped keep tracking, courier and ETA on the order and keep previous non-empty values when a refetch omits them. The sheet collects tracking + courier with a default ETA (now + 2 days); empty tracking is null. The shipped card skips empty fields.
- **Where it applies:** `vendor_order_detail_provider.dart`, `shipping_info_sheet.dart`, `vendor_order_detail_screen.dart`.

### 2026-09-07 — Incoming Orders keeps its list visible
- **Rule:** `fetchOrders` sets `isLoading` only when the list is empty; the body shows the skeleton only for `isLoading && orders.isEmpty`, then the empty state, then cards. (Don't invalidate the keepAlive list after merging a mutation — see the invalidate lesson.)
- **Where it applies:** `vendor_orders_provider.dart`, `vendor_orders_screen.dart`.

### 2026-09-07 — Card chrome shared across lists
- **Rule:** Order cards (`VendorOrderCard`, `OrderCard`), My Listings grid/list cards, wishlist list cards and Explore `ProductListCard` share one chrome: `cardShadowColor` shadow (blur 10, offset (0, 3)) outside the clip, a 4px left accent bar, and a 45% accent-color border. The accent is `orderStatusColor`, `listingStatusAccent`, or primary (success for a price drop). Pending orders use the same surface with a warning accent — no yellow fill or banner. Inset grid tiles with `Padding` inside the cell to keep the shadow; never set `clipBehavior: Clip.none` on the My Listings list/grid (cards paint over the pinned header). Grid images inside unbounded cells must not pass `double.infinity` into `memCacheWidth`.
- **Where it applies:** The card widgets above, `status_badge.dart`, `listing_thumbnail.dart`, `my_listings_screen.dart`.

### 2026-09-08 — Vendor home and listing UI decisions
- **Rule:** The vendor stats banner is a solid `Color.lerp(surface, primary, 0.9)` fill with white figures (pending stays warning); its labels are one word — Pending / Active / Total (`معلقة` / `نشطة` / `إجمالي`). Sort controls on Incoming Orders and My Listings are a compact "Sort by" + `PopupMenuButton` line with no border or `DropdownButton` (Incoming Orders: count on the right, warning color for `needsAction`; My Listings: 18px list/grid toggles with `AppSpacing.xs` padding). Add-listing keeps "Product Photos" above the photo strip and the helper line and error below it.
- **Where it applies:** `vendor_order_stats_banner.dart`, vendor stat arb keys, `vendor_order_sort_row.dart`, `listing_sort_bar.dart`, `photo_upload_section.dart`.

### 2026-09-08 — Storefront screen
- **Rule:** `VendorStoreScreen` uses a plain pinned `SliverAppBar` (back + share, no banner image) and an inline avatar + name row (initials fitted with `FittedBox`). Its grid uses `ListingCardGrid` (`imageHeight: 110`, `childAspectRatio: 0.82`), opens product detail on tap, and has no My Listings overflow menu. Store logo parses `firstNonBlank(storeLogoUrl, storeImageUrl, logoUrl, imageUrl)`. The Profile "Manage Store" button is commented out (keep `onManageStore` and `AppRoutes.sellerPath`).
- **Where it applies:** `vendor_store_screen.dart`, `vendor_store_card.dart`, `user_model.dart`.

### 2026-09-08 — Product detail hides buyer actions on your own listing
- **Rule:** Compare the session user id to `listing.vendorId` (fallback `seller.id`) — not `isVendor` — to hide quantity, Chat, Add to cart and Buy Now.
- **Where it applies:** `product_detail_screen.dart`.

### 2026-09-08 — Hidden UI stays in source, commented out
- **Rule:** When product asks to hide a piece of UI, comment out its usage (and import) and leave the widget and logic in place, adjusting indexes/counts around it; then run analyze for orphaned variables. Currently hidden this way: cart promo code row (`coupon_input_row.dart`, usage in `cart_consumer_body.dart`, phase 2), cart Select All row (`cart_consumer_body.dart`), cart vendor header (`cart_vendor_group.dart`), Wishlist toolbar `WishlistHeaderBar` including Select (`wishlist_consumer_body.dart`; Wishlist is a title-only `AppBar`, list-only, sort via the Recently Added chip), Profile Manage Store.
- **Where it applies:** Cart, wishlist and profile UI.

### 2026-09-08 — Wishlist and cart card hierarchy
- **Rule:** Wishlist list cards: title → price (+ strikethrough / `-N%`) → store name (+ verified) → `★ rating (count)` with shipping on the same row; actions below a divider; no `condition · category` line or redundant price-drop text. Cart item cards use only real cart fields (title, `vendorStoreName`, price + compare-at on one row, shipping, availability, condition/category, qty, remove, save for later) — no invented social proof or promo badges; checkbox on the image; `QuantityControl` is one bordered pill (trash/minus · qty · plus).
- **Where it applies:** `wishlist_item_card.dart`, `cart_item_card.dart`, `quantity_control.dart`.

### 2026-09-08 — Tall filter sheets from shell tabs
- **Rule:** Open with `useRootNavigator: true` (otherwise the shell nav stays visible and the header sits under the status bar). Capture `MediaQuery.viewPaddingOf(callerContext).top` before opening and pass it in; constrain the height with it plus bottom insets, pin the title and Apply/Reset, and scroll the middle.
- **Where it applies:** `filter_bottom_sheet.dart`, tall sheets from shell tabs.

### 2026-09-08 — Overlapping across slivers needs a negative offset
- **Rule:** To paint into the previous sliver, offset negatively (`Positioned(top: -X)` in a `Stack(clipBehavior: Clip.none)` or `Transform.translate`, as `profile_screen.dart` does with `AppSpacing.profileAvatarHalfOut`); a positive margin only moves content down within its own sliver.
- **Where it applies:** Headers overlapping a `SliverAppBar`.

### 2026-09-08 — Merge conflicts on screens both branches redesigned
- **Rule:** Read both full versions and keep each side's category of change (data fixes and visual fixes) instead of taking one side. Check `git log --oneline -- <file>` before starting a redesign.
- **Where it applies:** Merge conflicts on screens.

### 2026-09-08 — CompareAtPrice must exceed price
- **Rule:** Compare-at is optional; if set it must be strictly greater than price (the API 400s otherwise). Validate client-side, never send one ≤ price, and word the warning as "greater than".
- **Where it applies:** `validators.dart`, `listing_form_notifier.dart`, add-listing compare-at UI.

### 2026-09-09 — Fabricated values hide in widget default parameters too
- **Rule:** When auditing for fabricated stats, grep widget constructors for literal defaults (`= '4.7'`, `= 4.8`, round placeholder numbers), not just entity/datasource defaults. `ProductHeader` rating/review labels are nullable and fall back to `noReviewsYet`.
- **Where it applies:** `product_header.dart`, `product_detail_screen.dart`, display widgets.

### 2026-09-10 — Guard every state write after an await
- **Rule:** In autoDispose `@riverpod` notifiers use a `_disposed` flag reset in `build()` + `ref.onDispose`; in `StateNotifier` use its `mounted` getter (it exists in state_notifier 1.0.0). keepAlive notifiers that can be reset (by an auth listener or an external `ref.invalidate`) need a generation counter instead, because riverpod 2.x reuses the instance: bump it at every reset point (in the listener's reset branch, or at the top of `build()` for invalidate-reset providers), capture it at method entry, and compare after every `await` before any `state =` or `ref.invalidate` — every mutator in the file (grep each `await ref.read(...UseCaseProvider)` and `.fold(`), including multi-step flows like `saveProfile`. Applied in cart, orders, notifications, profile (`_sessionEpoch`), wishlist and store hours; do it in every new notifier from day one and add a mid-reset race test.
- **Where it applies:** Every async notifier method that writes `state` after an await.

### 2026-09-10 — Fixes to duplicated features must cover every copy
- **Rule:** When a fix lands in one implementation of a concept, grep for siblings before closing it. Order actions exist in the vendor-only stack (`vendor_orders_provider.dart`, `vendor_order_detail_provider.dart`) and behind role-shared widgets (`OrderCard` → `orders_provider.dart`, `OrderActionButtons` → `order_detail_provider.dart`); `rg` the method across `lib/` and fix every `flutter analyze` error. Other pairs: role pickers (`register_screen.dart` / `social_role_screen.dart`), trust badges (`home_header.dart` / `quick_actions_row.dart`), password toggles (courier login reuses `loginNotifierProvider`). When migrating callers off a shared helper or constants file, delete it once no callers remain. A no-op `onTap: () {}` on link-styled text is a bug — check for an existing target (Terms/Privacy open the website via `launchLegalUrl`). Don't link to content that doesn't exist (the checkout "Return Policy" link is commented out `TODO(phase-2)`).
- **Where it applies:** Audits and bug fixes across features.

### 2026-09-10 — Time out platform-channel calls on blocking paths
- **Rule:** `FlutterSecureStorage` reads can hang (not throw) on some Android keystores, and a hang inside a Dio interceptor happens before Dio's timeouts start. Every native call on a request- or startup-blocking path gets `.timeout(...)` (≈5s) plus a catch that degrades (proceed unauthenticated / no stored session): Dio interceptors, `TokenRefreshInterceptor._performRefresh`, `AuthRepositoryImpl.restoreSession`/`persistSessionUser`, `delivery_dio_provider.dart`. A user already stuck needs a full uninstall/reinstall. Adding `.timeout` creates a real Timer, so tests reaching an unmocked platform call now fail `!timersPending` — grep for tests that reach the path without overriding the provider (e.g. add-listing tests must override `vendorCommissionSnapshotProvider`).
- **Where it applies:** Interceptors, session restore, any platform call gating a request or screen.

### 2026-09-10 — Empty or all-zero phones are missing, not unverified
- **Rule:** get-profile can return no phone or a placeholder like `000000000`. Check with `AppValidators.isMissingPhoneNumber`: show add-phone copy and route to Edit Profile; only run phone OTP for a real number.
- **Where it applies:** `profile_verification_banner.dart`, `profile_screen.dart`, `require_phone_verified.dart`, `edit_profile_screen.dart`.

### 2026-09-10 — Contact-change UI on Edit Profile
- **Rule:** A new email/phone is collected in a bottom sheet (`showAnimatedBottomSheet` + `EditProfileContactValueSheet`, scrollable, padded by `viewInsetsOf`, controller owned by the sheet's `State`); confirm-only prompts stay dialogs. Verify stays disabled until the normalized value differs from the initial one and passes `Validators.registerEmail`/`Validators.egyptPhone`; rebuild just the button with `ListenableBuilder`. Phone-verification OTP is delivered to the account's email, so its copy is `phoneOtpSentToAssociatedEmail`, never "sent to <phone>".
- **Where it applies:** `edit_profile_screen.dart`, `profile_verification_screen.dart`, `phone_verification_sheet.dart`, `test/features/profile/edit_profile_contact_otp_test.dart`.

### 2026-09-10 — Primary actions stay dimmed until inputs are valid
- **Rule:** Dim submit buttons until the relevant shared validators pass (`registerEmail`, `egyptPhone`/`registerPhoneEgypt`, `loginPassword`, `registerPassword` + `confirmPasswordMatches`; OTP buttons need 6 digits); empty forms start dimmed. Require a changed value only when editing existing data — already-valid prefills (first checkout address, send-package sender phone) enable immediately. Optional WhatsApp: empty is fine, invalid dims. Reuse validators, never copy regexes into widgets, and create the `Listenable.merge` once in `initState`.
- **Where it applies:** Login, register, forgot/reset/change password, courier login, send-package, checkout address sheet, OTP sheets.

### 2026-09-10 — Per-line checkout must survive partial failure
- **Rule:** With no batch endpoint, `placeOrder` catches each line: a success removes only that line from the cart, a failure is recorded and the loop continues, and only an all-lines failure rethrows. Checkout compares created items with the submitted count and tells the user which items are still in the cart — a retry never re-orders what succeeded.
- **Where it applies:** `cart_remote_datasource.dart` `placeOrder`, `checkout_screen.dart`, any one-call-per-line loop.

### 2026-09-10 — Performance and logging fixes from the audit
- **Rule:** In sheets that rebuild often, read `MediaQuery.viewPaddingOf`/`viewInsetsOf`/`sizeOf`, not `MediaQuery.of`. A small, bounded list inside an existing scroll view is a `Column`, not a `shrinkWrap` `ListView`. Size avatar image providers with `AppNetworkImage.network(url, cacheSize: ...)`. Uniform `ListTile` lists use `prototypeItem: const ListTile(title: Text(''))`. Token logging: see the "debug a session token" lesson — never ad-hoc prints of tokens elsewhere.
- **Where it applies:** `filter_bottom_sheet.dart`, `search_suggestions_overlay.dart`, `app_cached_network_image.dart`, list pickers, `dio_provider.dart`, `social_auth_datasource.dart`.

### 2026-09-10 — Roll back only the item you changed
- **Rule:** An optimistic mutation over a list restores only its own item, by id, in the current state (`_orderById` + `_restoreOrder` in `orders_provider.dart`) — never a whole-list snapshot, which reverts other mutations that landed in between. Grep for `final snapshot = state.<list>;` restored in failure branches.
- **Where it applies:** `orders_provider.dart`, cart/notifications/wishlist lists.

### 2026-09-10 — Add an import in the same edit as its first use
- **Rule:** The review hook sees each edit alone, so an import-only edit reads as unused. Add the import together with its first usage.
- **Where it applies:** Edits adding imports.

### 2026-09-11 — Merge conflicts against a moved base
- **Rule:** Diff each conflicted file against the merge base on both sides (`git diff <merge-base> <other> -- <file>`); where the other branch already solved the same problem, drop your change rather than defending it.
- **Where it applies:** Resolving conflicts on your own PRs.

### 2026-09-11 — Automation triggers need hooks
- **Rule:** "Do X after Y" requires a hook in `.claude/settings.json`; skill text can't trigger itself. Keep the hook command minimal (a condition plus a fixed reminder) and leave judgment calls (e.g. whether a merge targeted `dev`) to the reminder text.
- **Where it applies:** `.claude/settings.json` hooks.

### 2026-09-12 — Codegen and pub get side effects
- **Rule:** Never combine `build_runner --build-filter` with `--delete-conflicting-outputs` — it deletes every other `.g.dart`; run the full `dart run build_runner build --delete-conflicting-outputs`. `pub get`/`pub add` re-runs gen-l10n and rewrites unrelated strings in `lib/core/localization/`, and build_runner can change `_$xxxHash()` literals in untouched `.g.dart` files: check `git diff --stat` and revert hunks you didn't intend. Add l10n keys by hand-mirroring them into `app_*.arb` and the three generated `app_localizations*.dart` files, matching an adjacent entry.
- **Where it applies:** Any codegen or `pub` run.

### 2026-09-12 — Notifier errors are shown exactly once
- **Rule:** When a notifier writes `error` on failure, something must display it: screens `ref.listen(provider, (prev, next) { if (next.error != null && next.error != prev?.error && mounted) AppSnackbar.error(context, next.error!); })` (as `register_screen.dart` and `SocialRoleScreen` do), and a caller that only checks a `bool` result must still show the stored error. Before adding a toast at a call site, check for such a listener so errors aren't shown twice — then toast only success locally.
- **Where it applies:** Screens driven by notifiers with an error field (`product_reviews_screen.dart`, `my_listings_screen.dart`, auth screens).

### 2026-09-12 — Google sign-in is login-only
- **Rule:** `_handleGoogleSuccess` calls `checkGoogleUser` (which matches Google-linked identities, not emails). `exists: true` logs in with the returned role. On a miss, Firebase `isNewUser: false` means a returning identity (e.g. an email account sharing the Gmail): log in as consumer, retrying vendor on a "different role" error (and the reverse). Only `isNewUser: true` plus a miss sets `SocialAuthState.needsRegistration` — `LoginScreen` shows a snackbar and goes to register, `RegisterScreen` just acknowledges; both call `acknowledgeNeedsRegistration()` and show `socialAuthProvider.error`. Parse `exists`/`role`/`roleName` tolerantly (bool, Yes/No, int, PascalCase) and unwrap `{isSuccess, data: {token}}` login responses. `SocialRoleScreen` (buyer/seller picker) now serves only Apple/Facebook. Notifiers never navigate by reading `goRouterProvider` (it depends on `routerNotifierProvider`, which listens to `socialAuthProvider` — a cycle); set a flag and let a widget `ref.listen` it. Hand-written `implements AuthRepository`/`AuthRemoteDataSource` doubles that don't extend `Fake` (`StubAuthRepository`, `_RecordingRemote`) need every new interface method. When a producer stops setting some state, grep its consumers for now-dead branches and stale comments.
- **Where it applies:** `social_auth_provider.dart`, `login_screen.dart`, `register_screen.dart`, `router_notifier.dart`, auth test doubles.

### 2026-09-12 — Order coordinates come from the chosen address
- **Rule:** `OrderAddress`/`OrderAddressModel` carry optional `latitude`/`longitude` from `showMapAddressPicker` (persisted by `checkout_provider.dart`'s `_addressToJson`/`_addressFromJson`). `placeOrder` uses the selected address's pin when it's inside Egypt and falls back to `AppLocationCache` only when there's none.
- **Where it applies:** `order_entity.dart`, `order_model.dart`, `checkout_provider.dart`, `cart_remote_datasource.dart`, `address_form_sheet.dart`, `map_address_picker.dart`.

### 2026-09-12 — Action failures toast where the user is
- **Rule:** Don't route a one-shot action failure (delete account, save) through a `state.error` that drives a load-retry banner at the top of a long screen. Return the error to the caller and show `AppSnackbar.error`.
- **Where it applies:** `profile_provider.dart` `deleteAccount`, `profile_menu_blocks.dart`, long screens with load banners.

### 2026-09-12 — Android Kotlin version skew
- **Rule:** A Kotlin `FileAnalysisException`/K2 crash or "compiled with an incompatible version of Kotlin" in a plugin means a transitive `kotlin-stdlib` is newer than our `org.jetbrains.kotlin.android` in `android/settings.gradle.kts` — bump the plugin (the log's "Flutter Fix" names it). Kotlin 2.3 rejects the legacy `android { kotlinOptions { jvmTarget = ... } }`; use top-level `kotlin { compilerOptions { jvmTarget.set(JvmTarget.JVM_11) } }`. Before a Kotlin minor bump, grep `android/` for removed DSL; a failure within ~2 minutes is a build-script error, not source compilation.
- **Where it applies:** `android/settings.gradle.kts`, `android/app/build.gradle.kts`.

### 2026-09-13 — Run analyze and the full suite in both modes before calling a change done
- **Rule:** Re-reading a diff isn't testing. Run `flutter analyze`, then the full `flutter test` and `flutter test --dart-define=MOCK=true` (matching `ci.yml`) — tests gated on `MockConfig.useMock` only run in one mode, and bugs hide outside the module being changed. A compile error makes a whole test file fail to load, hiding every test in it; compare failures against a baseline worktree of the pre-change commit before assuming you caused them. Check that existing tests actually exercise the changed branch (e.g. create vs edit). Plain `ProviderContainer` tests reading `authProvider` cold override `fcmDeviceTokenSyncProvider`/`fcmPushHandlingProvider` with no-ops. To script `GET /orders/me` without listing-detail hydration, give items `titleEn`, `imageUrls` and a positive price.
- **Where it applies:** Every completed change.

### 2026-09-13 — Tests that newly compile are new signal
- **Rule:** When a test file starts compiling again after an unrelated fix, don't assume it was green before — check whether it could load at the baseline. Every widget test rendering a screen that reads `context.l10n` needs the standard localization block: `AppLocalizations.delegate`, `GlobalMaterialLocalizations.delegate`, `GlobalWidgetsLocalizations.delegate`, `GlobalCupertinoLocalizations.delegate`, `supportedLocales: AppLocalizations.supportedLocales`.
- **Where it applies:** Widget test harnesses (e.g. `test/go_router_stale_ref_test.dart`).

### 2026-09-13 — Diagnosing clustered test failures
- **Rule:** When failures in one file share a signature (e.g. a Timer from `dio_provider.dart`'s `.timeout`), fix that shared cause first and re-run — leaks misattribute to later tests. Fix leaked Dio timers by overriding the specific provider that reaches Dio (e.g. `allGovernmentsProvider`/`allCitiesProvider` with static data). A `No element`/`RangeError` from a positional finder usually means the UI changed: `LocationCascadeField` replaced free-text city fields in checkout address and send-package (both pickup and dropoff) — drive it with the tap sequence from `location_cascade_field_test.dart`, and index multiple instances by document order (`find.byKey(ValueKey('locationCascadeField')).at(n)`), using `ensureVisible` below the fold. When a shared widget migrates, `rg` every screen using it and fix all their tests.
- **Where it applies:** `checkout_add_address_sheet_test.dart`, `send_package_screen_live_flow_test.dart`, tests over location pickers.

### 2026-09-13 — Failure-path tests for guarded mutators seed the item first
- **Rule:** Order mutators return early when `_orderById(id)` is null, so a failure-path test must first load the order with a stubbed successful `fetchOrders()`; otherwise the call silently no-ops.
- **Where it applies:** Tests of `OrdersNotifier` mutators.

### 2026-09-13 — "CI green" means every job on the commit
- **Rule:** Check every job in every workflow on the commit (`ci.yml` Analyze & Test, Build Android, Build iOS; `build-and-release-apk.yml`), not just the one reported. `flutter analyze` fails CI even at info level — e.g. `no_leading_underscores_for_local_identifiers` on local functions in tests.
- **Where it applies:** "Make CI pass" tasks.

### 2026-09-13 — Reviews require a delivered order
- **Rule:** Writing a new review requires a consumer with a delivered order containing the listing (`hasDeliveredOrderForListing`, orders fetched fresh at tap time); otherwise show `reviewRequiresDeliveredOrder`. A second write attempt opens `showAlreadyReviewedSheet` (Edit from there is the only path into the editor); editing skips the eligibility check. After posting, pop the sheet with `added`, show `ordersReviewThanks`, clear the fields, and invalidate `productDetailProvider`. When a feature "already exists", audit every entry point into it.
- **Where it applies:** `order_entity.dart`, `product_reviews_screen.dart`, `already_reviewed_sheet.dart`, order leave-review sheets.

### 2026-09-13 — iOS minimum version bumps touch three places
- **Rule:** When CocoaPods says a plugin needs a higher deployment target, raise `platform :ios` in `ios/Podfile` (uncommented — otherwise CocoaPods assumes 13.0), `IPHONEOS_DEPLOYMENT_TARGET` in `project.pbxproj`, and `MinimumOSVersion` in `ios/Flutter/AppFrameworkInfo.plist` together (`google_maps_flutter_ios` needs 14).
- **Where it applies:** iOS build config.

### 2026-09-13 — Delivered is a vendor transition from Shipped
- **Rule:** Only the vendor bulk `PUT /api/vendor/orders/status` writes Delivered, and only from Shipped (transitions go one step at a time). There is no buyer delivered route — don't call a guessed path. A vendor 403 on that PUT is `error.vendor.wallet.paused`; surface its `errorEn`.
- **Where it applies:** `orders_remote_datasource.dart` `markDelivered`, vendor "Mark as Delivered".

### 2026-09-13 — Listing reviews wire contract
- **Rule:** `GET /api/listings/{id}/reviews` is 1-based — the live datasource sends `page + 1`. Listing detail exposes flat `rating`/`reviewCount`; parse them into `reviewSummary`. Review authors display `fullName`/`fullNameEn`/`fullNameAr`; `userName` is the email, so if the wire name looks like an email, show the viewer's `displayName` for their own review.
- **Where it applies:** `product_remote_datasource.dart`, `review_entity.dart` `reviewAuthorLabel`, `reviews_summary.dart`.

### 2026-09-13 — Debug a session token at its attach site
- **Rule:** `LoggingInterceptor` keeps session token, password, `X-Auth-Token` and Google `idToken` redacted. When the user needs a live token, print it once per distinct value where it's attached (`dio_provider.dart` `_debugLogAuthToken`), and log Google `idToken`/`clientId` with `print` via `printFullToken` (800-char slices; `debugPrint` truncates at ~1024 chars) plus the decoded payload. Tests spying on `debugPrint` miss `print` — capture with `runZoned` + `ZoneSpecification.print`.
- **Where it applies:** `logging_interceptor.dart`, `dio_provider.dart`, `social_auth_datasource.dart`, `test/logging_interceptor_test.dart`.

### 2026-09-13 — hasPassword controls the current-password field
- **Rule:** get-profile's `hasPassword` is Yes/No (also bool or 0/1), top-level then nested `user`; missing means true. When false, hide the current-password field and omit it (`currentPassword` on change-password, `password` on delete-account). Delete account then shows a confirm dialog and still sends `confirmationText: DELETE`. After a successful change-password, force-refresh with the already-loaded profile user (`refreshProfileData(user:, force: true)`); never read `authProvider` from that screen — it starts restore timers in tests. Skip the refresh when profile has no user.
- **Where it applies:** `user_model.dart` `_yesNoFlag`, `ProfileEntity.hasPassword`, `change_password_screen.dart`, `AuthRemoteDataSource.changePassword`, `delete_account_dialog.dart`, `profile_menu_blocks.dart`, `profile_remote_datasource.dart` `deleteAccount`.

### 2026-09-15 — Widgets take typed entities, never dynamic
- **Rule:** A widget's data parameter is the real domain type, never `dynamic` with `as` casts, even for a one-off card.
- **Where it applies:** All presentation widgets.

### 2026-09-15 — Address book is a shared local keepAlive provider
- **Rule:** There's no address-book API yet. `AddressBook` (`address_book_provider.dart`) is the single keepAlive owner of saved addresses, persisted under the original `checkout_addresses_v1_` key; checkout keeps only the per-order selection and delegates edits to it. A non-empty list always has exactly one default, enforced inside the provider (`_normalizeDefault`). `address_form_sheet.dart`/`remove_address_sheet.dart` take `onSave`/`onConfirm` callbacks so either screen can use them. When a second screen needs data another feature persists locally, promote it to a shared provider rather than duplicating persistence.
- **Where it applies:** `address_book_provider.dart`, `checkout_provider.dart`, address sheets.

### 2026-09-15 — User-switch listeners must ignore the first auth resolution
- **Rule:** In `ref.listen(authProvider, (prev, next) ...)` comparing ids to detect a user switch, return when `prev == null || prev.isLoading` — otherwise the normal loading→data resolution on every cold build looks like a switch and wipes state. If a `Duration.zero` settle test starts failing after adding such a listener, suspect this before lengthening delays.
- **Where it applies:** `address_book_provider.dart`, any listener comparing `prev` to `next`.

### 2026-09-15 — Missing backend endpoints: ask, then document the contract
- **Rule:** When a feature needs an endpoint that isn't in the code or roadmap docs (`docs_business/backend/`), ask the product owner how to handle it instead of inferring a contract. Stage an agreed contract in `ApiEndpoints` with a "PROPOSED, not yet built" comment, like `analyticsEvents`. User-facing one-shot actions surface a real error; only fire-and-forget telemetry queues. Vendor reports are now live: `POST /api/reports/vendor` `{vendorId, orderId, reason, comment}` with numeric ids (`int.tryParse(id) ?? id`); only `Fraud`/`Harassment` reasons are confirmed. Also `POST /api/reports/user` and admin list routes exist.
- **Where it applies:** `lib/features/reports/`, `api_endpoints.dart`, `order_detail_scroll_content.dart`, `report_vendor_sheet.dart`.

### 2026-09-15 — Read use cases before opening a sheet
- **Rule:** Read a use case (a plain callable) with `ref.read` before `showModalBottomSheet` and close over it in `onSubmit`, rather than reading `ref` inside the async callback. `order_card.dart`'s `_reviewSheet` still reads inside — hoist it next time that file is touched.
- **Where it applies:** Sheets with async submit callbacks.

### 2026-09-15 — Legal links open the website
- **Rule:** Terms and Privacy links (register, profile menu, checkout) call `launchLegalUrl(xstoreTermsUrl/xstorePrivacyUrl)` from `lib/shared/utils/legal_links.dart`. `TermsInfoScreen`/`PrivacyInfoScreen` routes stay registered. Match a request's stated scope; widen only when the user confirms.
- **Where it applies:** `legal_links.dart`, `register_screen.dart`, `profile_menu_blocks.dart`, `checkout_review_section.dart`.

### 2026-09-19 — Reset Google Sign-In before each attempt
- **Rule:** On the live path, `signInWithGoogle` first calls `disconnect()` (falling back to `signOut()`), signs out of Firebase, and builds a new `GoogleSignIn(serverClientId: DefaultFirebaseOptions.googleWebClientId)` unless a test injected one; reset errors never block sign-in. Never `user.delete()` — it flips `isNewUser`.
- **Where it applies:** `social_auth_datasource.dart` `_resetGoogleSignIn`.

### 2026-09-21 — Overlay navigation
- **Rule:** Pop dialogs and sheets with the builder's own context (`dialogContext`), never the screen `context` — under go_router shells the screen context pops the branch. Await a sheet (returning an action result) before showing the next overlay; pushing during the pop hits `!_debugLocked`.
- **Where it applies:** All dialogs and sheets (e.g. `listing_options_sheet.dart`, `my_listings_screen.dart`).

### 2026-09-21 — Shipping comes from the listing
- **Rule:** A cart line's shipping is `cartLineShippingCost` (listing `shippingAvailable` + `shippingCost`, in `cart_shipping_rules.dart`) — never a client-side flat fee or free-shipping price cutoff. Cart and wishlist parsers use the same helper. UI copy describes what the code actually computes.
- **Where it applies:** `cart_remote_datasource.dart`, `wishlist_remote_datasource.dart`, `cart_summary_card.dart`.

### 2026-09-21 — Store ids, resolve display names at render time
- **Rule:** Persisting a locale-resolved name freezes it in the save-time language. `OrderAddress` stores `cityId`/`governorateId`, and every render site (lists, checkout, and form hints) uses `resolveAddressLocation(ref, address)`, which matches by id, then by the stored name in either language, then falls back to the stored string — so old data self-heals. When fixing display bugs, grep raw field names (`.city`, `.wilaya`) for every render site, including edit-form hints, and handle data saved before the fix.
- **Where it applies:** `order_entity.dart`, `address_book_provider.dart`, `address_form_sheet.dart`, `address_location_display.dart`, address screens.

### 2026-09-21 — Look for existing l10n keys before adding new ones
- **Rule:** Grep the `.arb` files for likely keys (`<field>Label`, `<field>Hint`) before writing new copy — orphaned keys exist (e.g. `instagramLabel`/`facebookLabel`). Never concatenate two l10n getters into one sentence unless each is a verified fragment; when both contain the same noun, use one key for the whole phrase.
- **Where it applies:** `edit_profile_screen.dart`, `cart_empty_state.dart`, any new copy.

### 2026-09-21 — Side-by-side buttons with different label lengths
- **Rule:** Wrap each button's icon + label in `FittedBox(fit: BoxFit.scaleDown, child: Row(mainAxisSize: MainAxisSize.min, ...))` instead of `Flexible` + ellipsis, so the longer label (which differs by locale) scales instead of truncating.
- **Where it applies:** `product_sticky_bar.dart`, other button rows.

### 2026-09-21 — Disabled nested tap targets keep a non-null onTap
- **Rule:** An `InkWell`/`IconButton` inside a tappable card keeps `onTap` non-null when disabled (`if (!enabled) return;`); `onTap: null` lets the card's tap win.
- **Where it applies:** `quantity_control.dart`, steppers and chips inside cards.

### 2026-09-21 — Shell-tab screens react to route params in didChangeDependencies
- **Rule:** Shell branches keep their `State` alive, so `initState` reads route params only once. Read `GoRouterState.of(context)` in `didChangeDependencies()` with a last-seen guard (e.g. Explore's `?category=` via `_syncWithRouteCategory`). Test inside a real `StatefulShellRoute.indexedStack` harness — a plain `GoRoute` recreates the `State` and hides the bug.
- **Where it applies:** `explore_screen.dart`, shell-tab screens reading their own params.

### 2026-09-21 — One shared derivation for shared concepts
- **Rule:** When a display and a filter/count/sort both decide the same condition, derive it once on the entity from the raw fields actually present. Wishlist price drop uses `WishlistItemEntity.effectiveDropPercent` (backend `priceDropPercent`, else `previousPrice > price`) — never `compareAtPrice`, which is a vendor markdown with its own `biggestDiscount` sort.
- **Where it applies:** `wishlist_item_entity.dart`, `wishlist_provider.dart`, `wishlist_item_card.dart`.

### 2026-09-21 — Edit Listing: back button and a complete dirty check
- **Rule:** Editing reaches the Add Listing tab via `context.go`, so it has no back stack — show an explicit `leading` back button when `isEditing`. Gate Update on a dirty check (`_editSnapshot` vs current state, like `address_form_sheet.dart`'s `_hasChanged`) because even an unchanged PUT has server-side effects; the snapshot must include every user-editable field, including hosted `existingImageUrls`. Drafts are the exception (see the listing write contract).
- **Where it applies:** `add_listing_screen.dart`, `listing_form_notifier.dart`.

### 2026-09-21 — Share links use real website URLs
- **Rule:** App and wishlist shares use `legal_links.dart` (`xstoreDownloadUrl`, plus `/en/terms` and `/en/privacy`). A listing share uses `productDeepLink` (`https://xstore.com/product/<id>`), the same host and path `routeFromDeepLinkUri` opens — never the in-app path `/product/<id>`, a download URL, or an invented `xstore.app` host.
- **Where it applies:** `product_detail_screen.dart`, `deep_link_route.dart`, `legal_links.dart`, any `Share.share`.

### 2026-09-21 — Phone fields showing +20 edit the 10-digit national number
- **Rule:** With a `+20` prefix on screen, the field holds `1XXXXXXXXX`; convert to the 11-digit `01…` only for the API (`normalizeEgyptLocal`). Never prepend `0` in the widget.
- **Where it applies:** `phone_input_field.dart`, `AppValidators.egyptNationalSignificantNumber`.

### 2026-09-22 — A map starting point is not a user pick
- **Rule:** The map picker's initial camera position (`AppLocationCache` or Cairo) isn't a selection: camera-start callbacks fire at creation, so `_hasPicked` stays false until the camera moves meaningfully from the start (`mapCameraMovedFromStart`) or the user taps Use my location; no reverse-geocoding or Confirm before that. Reopening with `initialLatitude`/`initialLongitude` starts as picked. `GoogleMap` can't run under `flutter_test` — unit-test the helper.
- **Where it applies:** `map_address_picker.dart`.

### 2026-09-22 — Currency display has several code paths
- **Rule:** `context.formatCurrency()` shows the amount then "LE" in English (Arabic already trails `ج.م`). Other paths show currency separately: `commission_breakdown_card.dart` and the Add Listing price fields' `prefixText: '${notifier.currencyCode} '`. Grep currency literals across `lib/` and scope the edit to what was asked.
- **Where it applies:** `context_extensions.dart` and the files above.

### 2026-09-22 — Clearing an image must survive the post-save refresh
- **Rule:** On removal, send `''` on both the write key (`storeImageUrl`/`userImageUrl`) and the GET key (`storeLogoUrl`/`avatarUrl`), with no file part. After the PUT and the post-save GET, force that URL to null if this save cleared it — the backend may still echo the old URL. Parse blank URLs as null.
- **Where it applies:** `profile_remote_datasource.dart`, `user_model.dart`, `profile_provider.dart` `saveProfile`.

### 2026-09-22 — Wishlist heart lives in Home's header
- **Rule:** The Orbit dock has no Wishlist tab (Home, Explore, Cart orb, Orders, Profile); `/wishlist` is a stack route opened with `context.push` from Home's header heart, which shows a filled red heart when `wishlistProvider.select((s) => s.itemCount > 0)`. No count badge unless asked. The Cart orb pushes `/cart` after `requireLogin`.
- **Where it applies:** `xstore_bottom_nav.dart`, `home_header.dart`, `app_router.dart`.

### 2026-09-22 — Events tracked during service init change test expectations
- **Rule:** `app_open` is tracked in `AnalyticsService._init()`, so tests can't assume an empty queue after `ready`. Assert with `contains`/`isNot(contains(...))`, or `await service.flushNow()` right after `ready` for a clean start — the init flush is unawaited and racy. Adding any init-time event means auditing `queuedEventNames`, `.single` and `hasLength` assertions.
- **Where it applies:** `analytics_service_test.dart`, `checkout_order_flow_test.dart`.

### 2026-09-22 — Tracking calls go after the mounted check
- **Rule:** `ref.read(analyticsServiceProvider).track(...)` after an `await` belongs after the `mounted`/`context.mounted` guard like any other `ref` use. After adding several track calls, grep every new call site to confirm.
- **Where it applies:** All widget-level `track()` calls.

### 2026-09-23 — Flutter SDK in remote sessions
- **Rule:** Check `which flutter dart` before promising analyze/test or codegen. With no SDK, clone `flutter/flutter` at the tag CI pins (`FLUTTER_VERSION` in `.github/workflows/ci.yml`, currently 3.35.6) — newer SDKs break `lucide_icons`, and `pub add` on them bumps SDK-pinned lock entries the team toolchain can't resolve (keep only the new package's entries) — and `git fetch --unshallow --tags` if the version reads `0.0.0-unknown`. If no SDK is possible, hand-mirror only pure renames in generated files and say plainly that analyze/test didn't run. A working SDK doesn't mean the backend is reachable: the session proxy may block the app's host — check with `curl` or `$HTTPS_PROXY/__agentproxy/status`, never route around it, and fall back to scripted-Dio tests. iOS has `dev`/`prod` schemes (`ios/Runner.xcodeproj/xcshareddata/xcschemes/`), so `flutter run --flavor dev` works on iOS.
- **Where it applies:** Every session that needs Flutter or live probes.

### 2026-09-23 — Dead-code deletions
- **Rule:** An audit is a snapshot: re-verify each finding against current HEAD right before deleting, and re-run the justifying grep before merging. Grep `test/` as well as `lib/` (live-flow tests construct screens directly — `NotificationSettingsScreen` stays), and grep for comparisons like `location == AppRoutes.foo`. Check each dead symbol's twin (consumer/vendor, en/ar). Never delete code marked for a later phase, "hidden for now" or "keep for restore", including its commented restore point — grep `phase-2`, `deferred`, `coming soon`, `hidden for now`, `keep for restore` first. The product owner decided to keep `cart_select_all_row.dart`, `wishlist_header_bar.dart`, `AppRoutes.earnings` and `AppRoutes.chatThread()`, and to park Apple/Facebook sign-in as phase-2 (notifier methods, repository/datasource, `SocialRoleScreen`, `/api/auth/social`, both SDKs, and their l10n keys); don't re-flag them. The next audit starts by checking the previous deletions left no dangling reference. Collapse leftover blank lines by hand.
- **Where it applies:** Dead-code audits and cleanups.

### 2026-09-23 — Amplitude
- **Rule:** `AnalyticsService` forwards with the official `amplitude_flutter` SDK (an injected `Amplitude?`; tests build a real `Amplitude` on a fake `MethodChannel`); it has no dispose method. The API key resolves from the constructor override, then a non-empty dart-define, then `AppFlavor.amplitudeApiKey`. `amplitudeConfiguration` sets `minIdLength: 1` — backend ids are short integers and Amplitude silently drops ids under 5 characters. When events go missing in a third-party tool, check key/zone with an empty-events request and probe with the real id shape before suspecting app code. When adopting a package, read its installed source in `~/.pub-cache/hosted/pub.dev/<pkg>-<version>/lib/` and look for an injectable transport before writing a wrapper; when a class gains a second disposable resource, update `dispose()` in the same edit.
- **Where it applies:** `analytics_service.dart`, `app_flavor.dart`, `test/analytics_service_test.dart`.

### 2026-09-23 — Analytics lifecycle rules
- **Rule:** Check this log before describing a subsystem — comments and handoff docs go stale (the collector is live and signed-in-only by decision). Tracking from a notifier's `build()` needs an instance flag (`_viewTracked`), since invalidate reuses the instance. Flush session-tied events before the call that revokes the token (`flushBeforeSignOut`, with a timeout) and never send one account's queued events under another's token (`_runFlush` owner filter). A drain loop over a coalesced call must first await the call already in flight.
- **Where it applies:** `analytics_service.dart`, `Auth.logout`, `track()` inside `build()`.

### 2026-09-23 — Start from the latest dev
- **Rule:** Before any audit, report or feature work, `git fetch origin dev` and check `git log HEAD..origin/dev`; if `dev` is ahead, restart or merge before reading code or describing how something works.
- **Where it applies:** Every session.

### 2026-09-23 — Analytics sinks hang off one choke point
- **Rule:** New sinks (collector, Amplitude, GA4) attach in `AnalyticsService._enqueue`, never at call sites; set identity in `_bindUser`; swallow every sink error (`Future.sync(...).catchError`) since uncaught async errors reach Crashlytics as fatal. GA4 needs sanitizing: bools become `"true"`/`"false"`, nulls dropped, strings cut to 100 characters, `screen_view` goes through `logScreenView`, `purchase` maps to `value`/`currency`/`transaction_id`. `test/firebase_analytics_forwarding_test.dart` drives the real plugin via `setupFirebaseCoreMocks()` and pigeon-channel mock handlers — reuse that technique for other Firebase plugins.
- **Where it applies:** `analytics_service.dart` (`_toFirebase`, `_logToFirebase`), analytics tests.

### 2026-09-24 — Reconciling against a new Postman collection
- **Rule:** Diff all of `api_endpoints.dart` against the collection's full folder list, not just the routes the task touches, and treat routes commented "assumption"/"not confirmed" as open items. Compare write bodies key by key — a misnamed multipart key (`storeGovernmentId` vs `storeGovernorateId`) silently drops data — and list documented query params the app never sends. A collection can be ahead of the server: an unauthenticated request returns 401/403 for a deployed route and a bare 404 for a missing one (compare with a made-up sibling path). Never guess seeded passwords — register a throwaway account or ask for a test account. Confirmed: `/api/governorates`; uploads `POST /api/uploads/{entityType}` (field `file`); `GET /api/banners` (tolerant parsing, static fallback); `GET /api/home`; report routes and admin vendor block/unblock are deployed; `POST /api/users/{id}/block|unblock` are not.
- **Where it applies:** `api_endpoints.dart` and its datasources.

### 2026-09-24 — Check stock for every line before ordering
- **Rule:** Before the per-line order loop, check all lines with `GET /api/listings/{id}/stock?quantity=N` (`Future.wait`; envelope `data` is a bool, 404 = unknown/inactive) and stop before the first POST if any is short (`outOfStockErrorCode`). Then fix the short lines: cap the quantity to what's left, or mark the line unavailable. A stock-check error or unreadable body means "no answer" — proceed and let the order POST decide; a 404 means no. A listing with no stock field is unavailable, not `maxQuantity: 10`. Tests asserting an exact request count break when a check is added — assert paths and intent instead.
- **Where it applies:** `cart_remote_datasource.dart` (`placeOrder`, `_hasStock`, `_refreshShortLine`, `_fromListingPayload`), `checkout_provider.dart`, `checkout_error_banner.dart`.

### 2026-09-24 — Making a provider eager breaks tests of every widget watching it
- **Rule:** When a keepAlive provider starts fetching in `build`/`fireImmediately`, grep every widget that watches it (`NotificationBellButton`, `WishHeartButton`, `XstoreBottomNav`, the profile wishlist tile) and run the full suite. Harnesses that mount such widgets without testing them override the provider with a no-op notifier or zero-latency stub. Recording interceptors on a shared Dio filter on `options.path == ApiEndpoints.x`, never "the last request". To find a leaked request, temporarily print `options.path` in `dio_provider.dart`'s `onRequest`.
- **Where it applies:** `profile_screen_test.dart`, `explore_screen_route_category_test.dart`, tests mounting those widgets.

### 2026-09-24 — Validation and auth rules from the QA pass
- **Rule:** Names allow Unicode letters (`^[\p{L} .'\-]+$` plus a `\p{L}` presence check) — never `[a-zA-Z]`. `AppValidators.foldDigits` folds Arabic-Indic digits and runs in `normalizeEgyptLocal` and `parseMoneyInput`; `normalizeEgyptLocal` strips a leading `00` and accepts a `20` prefix at length 12 or 13. `parseMoneyInput` rejects non-finite values (`double.tryParse` accepts `NaN`/`Infinity`). Date-of-birth age is calendar-based, not `days ~/ 365`. Email regex is `^[^\s@]+@[^\s@.]+(?:\.[^\s@.]+)+$`. `TokenRefreshInterceptor` clears the session only on a 401/400 from `/refresh-token` or a missing refresh token; transport errors, 5xx, hangs and empty bodies keep the session. get-profile's `birthDate: "0001-01-01T00:00:00"` (year < 1900) means unset. Open backend defects: `send-login-otp` echoes the OTP (login with only a phone number), and register has no server-side DOB validation (`QA_REPORT.md`).
- **Where it applies:** `validators.dart`, `AppValidators`, `token_refresh_interceptor.dart`, `user_model.dart`, `test/qa/`.

### 2026-09-24 — Tests must fail when the guarded bug returns
- **Rule:** For money, privacy and auth paths, break the real code (stash the fix) and confirm a test fails. Never re-implement the logic under test in the test file — drive the real notifier through a `ProviderContainer` with a fake repository (`test/qa/regression_gaps_qa_test.dart` pattern). Every guard for a past bug (epoch guards, retry caps, the Place Order re-entry guard) needs a test that breaks without it. Don't edit `lib/` while a mutation script runs — it restores its snapshot.
- **Where it applies:** Tests for fixed bugs.

### 2026-09-24 — Async persistence: snapshot before await, never cache a static Future
- **Rule:** Take the data snapshot before the first `await` (a sign-out during the await would otherwise save an empty cart). Never cache a Future in a static field — it outlives test zones and turns one stalled read into a permanent hang; keep a plain "restored for this user" marker and make restore idempotent (restore once, then save again after merging). The cart's `_items` is the user's cart — don't cap it. Tests running the real cart datasource call `CartRemoteDataSourceImpl.clearSessionCache()` and `SharedPreferences.setMockInitialValues` in `setUp`. Don't invent wire fields the backend hasn't agreed (order address/phone/note are blocked on the contract).
- **Where it applies:** `cart_remote_datasource.dart` (`_restoreSavedCart`, `_saveCart`), persistence code, cart tests.

### 2026-09-25 — All user-facing text goes through l10n
- **Rule:** `AppStrings` is gone; every user-facing string comes from `context.l10n`. Code without a `BuildContext` (providers, formatters) either takes `AppLocalizations` as a parameter (`Formatters.formatNotificationTime(t, l10n)`) or returns a kind/enum the widget localizes (`NotificationGroupKind`). Non-translatable tokens (route/query ids like `kCategoryQueryMens`) are Dart constants, not `.arb` keys. Dates use `DateFormat(pattern, locale)` with the app locale (`l10n.localeName`, or `isArabic ? 'ar' : 'en'` as in `context.formatDate`) — never a hardcoded English day/month list; `GlobalMaterialLocalizations` loads the date symbols in the app, and unit tests call `initializeDateFormatting`. A widget parameter whose default must be localized becomes nullable and resolves `param ?? context.l10n.key` in `build()` (const defaults can't use context) — e.g. `ErrorStateWidget.retryLabel`. Grep string-literal defaults in `lib/shared/widgets/**`. l10n audits must include dialogs, sheets and interpolated labels in secondary screens. Use `MediaQuery.sizeOf`, not `MediaQuery.of(context).size`.
- **Where it applies:** All screens, shared widgets, providers and formatters.

### 2026-09-26 — Orbit design: dark-first tokens, starfield behind the body
- **Rule:** First launch opens in light mode and Arabic (`AppThemeMode` and `AppLocaleNotifier` defaults; a saved choice wins), so tests that read English strings through `appIsArabicProvider` or server-error mapping pin English (`appIsArabicProvider.overrideWithValue(false)` or `setLanguage(AppLanguage.english)`). Use theme colours (`context.primaryColor` = plasma in dark, violet in light) — `AppColors.plasma` can't carry white text, so never use it as a light-mode fill. Money/COD amounts (prices, totals, cash to collect) use `context.cashColor` (amber in dark, amber-700 in light). Screen backdrops wrap the Scaffold `body` in `SpaceBackground` (dark: deep-space starfield; light: "daylight orbit" dawn gradient, pastel nebulae, faint violet stars, orbit rings — keep light-mode decoration faint so text stays crisp); keep Scaffolds opaque, because a transparent Scaffold lets the previous route show through during push transitions and un-pins sticky headers that paint `context.backgroundColor`. Replace hardcoded `AppColors.light*` in widgets with `context.*` getters so dark mode holds.
- **Where it applies:** `space_background.dart`, `app_theme.dart`, `app_colors.dart`, `xstore_bottom_nav.dart`, `xstore_button.dart`, any new screen.

### 2026-09-26 — Content added above a SliverFillRemaining state must not squeeze it
- **Rule:** An empty, error or placeholder state in `SliverFillRemaining` gets only the space left under the slivers above it. When you add a header (for example the Explore radar), give fixed-height states `hasScrollBody: false` so they grow and scroll instead of overflowing. Tests run in an 800×600 window, so they catch this before small phones do.
- **Where it applies:** `explore_screen.dart` and any screen whose states sit in `SliverFillRemaining`.

### 2026-09-26 — Home cards reuse the owning notifier, fetching only when it's empty
- **Rule:** A Home summary of another feature's data (the live order card) watches that feature's keepAlive notifier with `select` and reuses its fetch — no new datasource or endpoint. Fetch only when the notifier is empty and not loading (`postFrame` plus a check on sign-in, queued in a microtask behind the notifier's own auth reset), and refresh it on pull-to-refresh. Screen tests keep passing because unscripted routes just error and the card stays hidden.
- **Where it applies:** `home_live_order_card.dart`, `home_screen.dart`, any cross-feature summary card.

### 2026-09-26 — Orbit form primitives: uppercase labels, one password-rule source
- **Rule:** Field labels go through `OrbitFieldLabel` (via `AuthTextField`/`PhoneInputField`), which uppercases them, so tests find `'CURRENT PASSWORD *'`, not the arb value. Password checklists and strength meters read `Validators.passwordRules`, the same source as `registerPassword`, never their own regexes. When a redesign moves a form's submit below extra content, tests reach it with `scrollUntilVisible` (lazy `ListView`) or `ensureVisible` (`SingleChildScrollView`).
- **Where it applies:** `auth_text_field.dart`, `phone_input_field.dart`, `password_strength_bar.dart`, `validators.dart`, auth/profile form tests.

### 2026-09-26 — Seller and courier screens use the warm Orbit accent
- **Rule:** Shopper screens use `context.primaryColor` (plasma/violet); seller and courier screens use amber: `context.cashColor` for highlights and selected chips, and `XstoreButton(warm: true)` (amber→orange, dark ink) for primary actions (`height: 44` inside cards). Section headings on these screens are small uppercase labels, so tests find `'ACTIVE'`, `'HISTORY'`, `'COLLECTED ORDERS'`, not the arb value.
- **Where it applies:** `lib/features/orders` (vendor), `listing`, `commission`, `delivery`, `vendor_store_screen.dart`, `courier_login_screen.dart`, `xstore_button.dart`.

### 2026-09-26 — Sized orbs must center their glyph
- **Rule:** A fixed-size circle (`AnimatedContainer` / `Container` with width and height) pins its child to the top-start unless `alignment: Alignment.center` is set. The Orbit dock orb needs that alignment so the cart and Add Listing glyphs sit in the middle of the disc; the count badge stays on the icon via `NotificationIconBadge`.
- **Where it applies:** `xstore_bottom_nav.dart` (`_DockOrb`), any sized icon disc.
