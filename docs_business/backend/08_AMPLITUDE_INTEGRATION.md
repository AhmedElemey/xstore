# xStore — Amplitude Integration & User-Journey Event Review

**Status:** client-side implemented and shipping. **Both dev and prod are live** — `task build:dev`
reports to the `xStore - Dev` Amplitude project, `task build:prod` and the release GitHub Actions
workflow report to `xStore - Prod`. See §2 for the exact wiring.
**Companion:** [`03_ANALYTICS_EVENTS_HANDOFF.md`](./03_ANALYTICS_EVENTS_HANDOFF.md) is the existing
wire contract to xStore's own backend collector; this doc covers the parallel Amplitude pipeline
and reviews the current event catalog for gaps in the mapped user journey.

## 1. What was built

`lib/core/analytics/analytics_service.dart` already batches every `track()` call and POSTs it to
xStore's own `/api/analytics/events` collector (session-gated: signed-in users only). This change
adds a **second, independent forwarder** in the same service that hands the identical event stream
to Amplitude via the official [`amplitude_flutter`](https://pub.dev/packages/amplitude_flutter) SDK.

> **Note:** this was originally built as a hand-rolled `Dio` client POSTing directly to Amplitude's
> HTTP API (`/2/httpapi`), specifically to avoid a native plugin dependency. It was switched to the
> official SDK on request. The plain-HTTP version is still the right call for a project that wants
> zero native dependency risk — see the flutter-review skill's 2026-09-22 lesson log for the
> tradeoffs either way.

- **Same event catalog, same names/properties** — nothing in `event_names.dart` changed. Every
  event already fired anywhere in the app (see §3) reaches both destinations with the same
  payload, so there is exactly one source of truth for "what did the app track," not two drifting
  definitions.
- **Not session-gated the same way as the xStore collector.** The xStore collector intentionally
  only sends events once a user is signed in (guest events queue locally until login — see
  `03_ANALYTICS_EVENTS_HANDOFF.md`). Amplitude forwarding sends **guest and signed-in events
  alike**, using the existing anonymous `device_id` (already generated and persisted for the
  xStore collector) as Amplitude's identity until a `user_id` is known. This is a deliberate
  product decision: a marketplace funnel is dominated by guest browsing before signup, and a
  journey tool that only sees post-login activity would misrepresent drop-off.
- **Independent failure domain.** Every `track()` call to the SDK is a single `amplitude.track(...)`
  — the SDK owns its own local queue, batching, and retry
  (`Configuration.flushQueueSize`/`flushIntervalMillis`/`flushMaxRetries`), so this class does no
  queueing of its own for Amplitude. `Configuration.autocapture` is set to `AutocaptureDisabled()`
  so the SDK never generates its own session/lifecycle/screen-view events — every Amplitude event
  traces back to an explicit `track()` call here, keeping the event catalog authoritative. An
  Amplitude outage cannot block or slow down the xStore collector, and vice versa — they don't
  share a client or a queue.
- **Revenue mapping.** The `purchase` event's `value_egp` property is additionally mapped onto
  Amplitude's top-level `revenue`/`revenue_type` fields (passed directly on the same `BaseEvent`,
  no separate `Revenue`/`revenue()` call) so Amplitude's built-in revenue/LTV charts work without a
  custom computed metric.

- **Short user ids.** Backend user ids are short integers (`"42"`), and Amplitude rejects any
  `user_id` under 5 characters by default (`400 "Invalid id length for user_id or device_id"`), so
  every signed-in event was dropped while guest events went through. The SDK is configured with
  `minIdLength: 1` (`AnalyticsService.amplitudeConfiguration`); do not remove it.

## 2. Enabling it

Amplitude is **on by default** once `AppConfig.init` has run (every real app launch via
`main_dev.dart` / `main_prod.dart` / `main.dart`). The key is resolved in this order:

1. Constructor override (tests).
2. `--dart-define=AMPLITUDE_API_KEY=...` when non-empty.
3. Flavor default on `AppFlavor.amplitudeApiKey` — `dev` → xStore-Dev, `prod` → xStore-Prod.
   These are the same keys `Taskfile.yml` already ships; they are project write keys, not
   treated as secrets.

A plain `flutter run --flavor dev -t lib/main_dev.dart` (or VS Code **xstore (dev)**) therefore
forwards events without any extra flag. Override a key at build time the same way as
`API_BASE_URL`:

```
flutter run --flavor dev -t lib/main_dev.dart --dart-define=AMPLITUDE_API_KEY=<other key>
```

Release / CI still pass the dart-define explicitly:

- `Taskfile.yml`'s `build:dev` / `build:prod` tasks pass
  `--dart-define=AMPLITUDE_API_KEY="{{.AMPLITUDE_API_KEY_DEV}}"` /
  `"{{.AMPLITUDE_API_KEY_PROD}}"` — override at call time with
  `AMPLITUDE_API_KEY_DEV=...`/`AMPLITUDE_API_KEY_PROD=... task build:...`.
- `.github/workflows/build-and-release-apk.yml` resolves the same two keys per `BUILD_FLAVOR`
  and passes `--dart-define=AMPLITUDE_API_KEY="$AMPLITUDE_KEY"`. If that secret is empty, the
  flavor default still applies.

## 3. Current event catalog (already forwarded to both destinations)

See the full table in
[`03_ANALYTICS_EVENTS_HANDOFF.md`](./03_ANALYTICS_EVENTS_HANDOFF.md#event-catalog-names-are-frozen--see-event_namesdart-do-not-rename-without-updating-both-sides).
Summary of what's live: `view_item`, `add_to_cart`, `begin_checkout`, `purchase`, `login_success`, `register_success`, `logout`,
`login_prompt_shown`, `screen_view` (auto-tracked on every go_router navigation), `search_performed`,
`wishlist_add`/`wishlist_remove`, `listing_published`/`listing_status_changed`/
`listing_resubmitted`/`listing_deleted`, `order_status_changed`, plus **all P0 and P1 gap-closing
events below** (`app_open`, `category_viewed`, `search_no_results`, `remove_from_cart`,
`cart_viewed`, `order_placement_failed`, `review_submitted`, `onboarding_completed`/
`onboarding_skipped`, `guest_mode_started`, `deep_link_opened`, `filter_applied`,
`checkout_address_selected`/`checkout_address_added`, `push_notification_received`/
`push_notification_opened`, `vendor_report_submitted`, `vendor_onboarding_step`) — all shipped as
of this change.

That is a solid **north-star funnel** (view → cart → checkout → purchase) and a **vendor-side
funnel** (listing live → order fulfilled), plus screen-level navigation via `screen_view`. Between
the P0 and P1 passes, this now covers acquisition (app open, onboarding, guest mode, deep links),
discovery (category browse, search misses, filter usage), the full transaction funnel (cart
add/remove/view, address selection, checkout failure with a reason code), post-purchase engagement
(reviews, push notifications), and vendor onboarding/trust signals (wizard drop-off, vendor
reports). Only the P2 rows below (impression-level tracking, a few secondary-engagement events)
remain unimplemented.

## 4. Gap analysis — events to add for a complete user journey

Reviewed against the actual screens/flows in `lib/features/*` (not aspirational — every
suggestion below maps to a real, already-built screen or provider). Grouped by journey stage,
ranked by how directly each maps to a business decision. **The P0 and P1 rows are implemented**
(see `event_names.dart` and their call sites); only P2 remains a proposal for a future pass.

### Acquisition & onboarding
| Suggested event | Fired when | Why it matters | Priority |
|---|---|---|---|
| `app_open` ✅ implemented | Fires once per app process start, from `AnalyticsService._init()` — a keepAlive provider created once for the app's lifetime. Does not (yet) cover foreground-resume from background; that would need a `WidgetsBindingObserver`, deliberately deferred as a separate, smaller follow-up | Baseline DAU/MAU and session-start marker | P0 |
| `onboarding_completed` / `onboarding_skipped` ✅ implemented | `OnboardingScreen._finish(skipped:)` — the last slide's "Get Started" vs. the Skip button, both routed through the same method with a `skipped` flag | First-run conversion — do new installs even make it past onboarding | P1 |
| `guest_mode_started` ✅ implemented | The login screen's "Continue as Guest" tap only — deliberately NOT wired inside `GuestMode.enable()` itself, since `splash_screen.dart` also calls `enable()` on every cold start for a *returning* guest, which is a re-entry, not a new choice | Guest vs. registered split is already a KPI in `03_funnel_metrics.md` §4 but has no explicit "chose to browse as guest" marker | P1 |
| `deep_link_opened` ✅ implemented | `deep_link_handling_provider.dart`'s `uriLinkStream` listener, right before it navigates | Attribution for shared product links / marketing campaigns (already flagged as a Phase B item in `03_funnel_metrics.md`) | P1 |

### Discovery & engagement
| Suggested event | Fired when | Why it matters | Priority |
|---|---|---|---|
| `category_viewed` ✅ implemented | `ExploreNotifier.bootstrapFromRouteCategory` — fires when a Home category chip navigates into Explore | `search_performed` already exists for keyword search; category browse is the other half of discovery | P0 |
| `search_no_results` ✅ implemented | `ExploreNotifier.search()` — a non-empty query returns 0 results, alongside the existing `search_performed` | Direct, actionable signal of catalog/inventory gaps by governorate/category | P0 |
| `product_impression` (batched) | A product card scrolls into view on Home/Explore | Needed for a true view→cart conversion rate at the impression level, not just `view_item` (detail-page opens). **Caution:** must be batched/sampled, not per-scroll-frame, to avoid event-volume blowup — flag as a follow-up design task, not a quick add | P2 |
| `filter_applied` ✅ implemented | `ExploreNotifier.applyFilters()` — every "Apply" tap from the filter sheet, not the "Reset" action | Which filters buyers actually use — informs catalog/category taxonomy priorities | P1 |
| `wishlist_viewed` | Wishlist tab opened | Engagement/retention signal already partially inferred from `screen_view`, but an explicit event is easier to build a funnel step on | P2 |

### Transaction funnel (fills real gaps in the existing funnel)
| Suggested event | Fired when | Why it matters | Priority |
|---|---|---|---|
| `remove_from_cart` ✅ implemented | `Cart.removeItem()` success | The funnel currently only sees additions — cart abandonment analysis needs the removal half too | P0 |
| `cart_viewed` ✅ implemented | `AnalyticsService`'s router listener — fires a dedicated event alongside `screen_view` whenever the route is `/cart` | Distinguishes "added to cart, never opened cart" from "opened cart, didn't check out" | P0 |
| `checkout_address_selected` / `checkout_address_added` ✅ implemented | `Checkout.selectAddress()` / `Checkout.addAddress()` — not the auto-preselected main address on checkout mount | Address friction is a known COD-market drop-off point; previously invisible | P1 |
| `order_placement_failed` ✅ implemented | `Checkout.placeOrder()` — every failure branch (offline, empty cart, no address, no consumer id, or the backend rejecting the order) tracks with a `reason` property | Every failure mode already has a mapped error code (`dio_error_mapper.dart`) — today's checkout failures are no longer silent to analytics | P0 |
| `coupon_applied` / `coupon_failed` | N/A today — no live coupon mechanic exists (see the flutter-review skill's 2026-08-29 lesson: no cart-wide coupon backend) | Skip until the feature is real — listed here only so it isn't "discovered missing" later | — |

### Post-purchase & retention
| Suggested event | Fired when | Why it matters | Priority |
|---|---|---|---|
| `order_cancelled` | Consumer or vendor cancels (distinct from the existing generic `order_status_changed`) | `order_status_changed` already carries `status: cancelled`, so this can be derived from existing data in Amplitude (a saved cohort/chart on `order_status_changed` where `status = cancelled`) rather than a new event — **no code change needed**, just an Amplitude-side chart | — |
| `order_delivered` | Same reasoning — already derivable from `order_status_changed` where `status = delivered` | — | — |
| `review_submitted` ✅ implemented | `ProductReviewsNotifier.submitReview()` (create only, not edit), plus the two duplicate order-card/order-detail review sheets (`order_card.dart`, `order_action_buttons.dart`) that bypass that notifier and call the use case directly | Post-purchase engagement + a proxy for satisfaction | P0 |
| `push_notification_received` / `push_notification_opened` ✅ implemented | `push_notification_received`: FCM `onMessage` (foreground only — a background/terminated receipt runs in a separate isolate with no Riverpod container, deliberately out of scope). `push_notification_opened`: every tap-to-open path — `onMessageOpenedApp`, cold-launch via `getInitialMessage()`, and the Android local-notification cold-launch path | Push is a real re-engagement channel (order updates, flash sales) with zero visibility today into open rates | P1 |
| `vendor_report_submitted` ✅ implemented | `_SellerSection._reportVendor()` in `order_detail_scroll_content.dart`, on a successful submit | Trust & safety signal — report volume by vendor is exactly the kind of thing a marketplace ops team needs a dashboard for | P1 |

### Vendor-side journey (the "other half" of the marketplace loop)
| Suggested event | Fired when | Why it matters | Priority |
|---|---|---|---|
| `vendor_onboarding_step` ✅ implemented | `RegisterNotifier.nextStep()` — every successful step advance, gated to `selectedRole == vendor` only (the method is shared with the consumer wizard, which has no separate funnel to instrument) | `listing_published` already exists as the *outcome*; this captures where vendor signups drop off mid-wizard | P1 |
| `vendor_store_hours_updated` | Store hours saved | Low priority — secondary engagement per `03_funnel_metrics.md` §7 governance rule (max 5 primary KPIs) | P2 |
| `commission_wallet_viewed` | Vendor opens the wallet screen | Whether vendors actually check their commission/payout status | P2 |

### Explicitly NOT recommended right now
- **Per-scroll or per-frame tracking of anything** — violates this app's own rebuild-storm rules
  and would flood both pipelines. `product_impression` above is flagged P2 specifically because it
  needs a batching design first.
- **Any event carrying PII** (raw phone/email/address text) — `03_ANALYTICS_EVENTS_HANDOFF.md`
  §8 already bans this for the xStore collector; the same rule applies to Amplitude properties.
  Every suggestion above uses only ids/enums/counts, matching the existing catalog's own convention.

## 5. Suggested next step

All 7 **P0** rows and all 9 **P1** rows above are implemented — together they closed the biggest
blind spots the original gap analysis found: cart abandonment (nothing used to distinguish "added
then removed" from "added then bought"), checkout failure (a failed order used to be silent),
first-run/guest-mode/deep-link acquisition, filter usage, address friction during checkout, push
re-engagement, and vendor trust/onboarding signals. None of them required a backend change — they
all flow through the exact same `AnalyticsService.track()` call already wired everywhere else.

What remains is **P2** only, each a smaller, more speculative addition than anything above:
- `product_impression` — needs a batching/sampling design first (see the caution note in §4);
  don't implement it the same way as the other events without that design pass.
- `wishlist_viewed`, `vendor_store_hours_updated`, `commission_wallet_viewed` — straightforward
  one-line additions in the same shape as everything above, just lower business priority per
  `03_funnel_metrics.md` §7's "no more than 5 primary KPIs" governance rule.

Also worth doing once real usage data exists: `order_cancelled`/`order_delivered` need no code
change at all — both are already derivable in Amplitude from `order_status_changed`'s `status`
property, so they're an Amplitude-side saved chart/cohort, not an engineering task.
