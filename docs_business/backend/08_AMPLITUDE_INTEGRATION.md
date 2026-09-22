# xStore — Amplitude Integration & User-Journey Event Review

**Status:** client-side implemented and shipping, **inert until `AMPLITUDE_API_KEY` is supplied**
(feature is fully opt-in — no behavior change for existing builds).
**Companion:** [`03_ANALYTICS_EVENTS_HANDOFF.md`](./03_ANALYTICS_EVENTS_HANDOFF.md) is the existing
wire contract to xStore's own backend collector; this doc covers the parallel Amplitude pipeline
and reviews the current event catalog for gaps in the mapped user journey.

## 1. What was built

`lib/core/analytics/analytics_service.dart` already batches every `track()` call and POSTs it to
xStore's own `/api/analytics/events` collector (session-gated: signed-in users only). This change
adds a **second, independent forwarder** in the same service that POSTs the identical event stream
directly to Amplitude's HTTP API (`POST https://api2.amplitude.com/2/httpapi`):

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
- **Independent failure domain.** A separate `Dio` client with **no default headers** — xStore's
  Basic license key and per-user `X-Auth-Token` are never sent to Amplitude. A separate in-memory
  queue and exponential backoff (10s → 300s, same shape as the xStore collector) mean an Amplitude
  outage cannot block or slow down the xStore collector, and vice versa.
- **No new persistence.** Unlike the xStore collector's SharedPreferences-backed queue (built to
  survive app kill because that's the only pipeline before this change), the Amplitude queue is
  in-memory only — a small, deliberate simplification: losing a handful of unsent events on a
  force-kill is an acceptable trade for not maintaining a second persisted-queue schema. If this
  needs revisiting (e.g. once Amplitude is the primary funnel dashboard), promote it the same way
  the xStore queue already works.
- **Revenue mapping.** The `purchase` event's `value_egp` property is additionally mapped onto
  Amplitude's top-level `revenue`/`revenue_type` fields so Amplitude's built-in revenue/LTV charts
  work without a custom computed metric.

## 2. Enabling it

Nothing is sent to Amplitude until a real project API key is supplied at build time:

```
flutter run --dart-define=AMPLITUDE_API_KEY=<your Amplitude project API key>
```

For CI/release builds, add `--dart-define=AMPLITUDE_API_KEY="{{.AMPLITUDE_API_KEY}}"` to the same
`flutter build` invocations in `Taskfile.yml` / `.github/workflows/build-and-release-apk.yml` that
already pass `API_BASE_URL`, once the business has created the Amplitude project and has a real
key to store as a secret — deliberately not wired into those files yet since a placeholder/blank
key would silently no-op (harmless, but pointless to add before the key exists).

## 3. Current event catalog (already forwarded to both destinations)

No changes here — see the full table in
[`03_ANALYTICS_EVENTS_HANDOFF.md`](./03_ANALYTICS_EVENTS_HANDOFF.md#event-catalog-names-are-frozen--see-event_namesdart-do-not-rename-without-updating-both-sides).
Summary of what's already live: `view_item`, `add_to_cart`, `begin_checkout`,
`checkout_payment_method_selected`, `purchase`, `login_success`, `register_success`, `logout`,
`login_prompt_shown`, `screen_view` (auto-tracked on every go_router navigation), `search_performed`,
`wishlist_add`/`wishlist_remove`, `listing_published`/`listing_status_changed`/
`listing_resubmitted`/`listing_deleted`, `order_status_changed`.

That is a solid **north-star funnel** (view → cart → checkout → purchase) and a **vendor-side
funnel** (listing live → order fulfilled), plus screen-level navigation via `screen_view`. It is
not, on its own, a full user-journey map — see the gap analysis below.

## 4. Gap analysis — events to add for a complete user journey

Reviewed against the actual screens/flows in `lib/features/*` (not aspirational — every
suggestion below maps to a real, already-built screen or provider). Grouped by journey stage,
ranked by how directly each maps to a business decision. None of these are implemented yet in
this change — implementing the ones marked **P0** should be the very next analytics task, since
they're the highest-leverage gaps in the current funnel view.

### Acquisition & onboarding
| Suggested event | Fired when | Why it matters | Priority |
|---|---|---|---|
| `app_open` | Cold start / app resumed from background (splash bootstrap) | Baseline DAU/MAU and session-start marker — Amplitude computes retention/session length from a clear session-start signal; today's `screen_view` on splash is a proxy, not a deliberate one | P0 |
| `onboarding_completed` / `onboarding_skipped` | Last onboarding slide "Get Started" vs. skip tap (`onboarding_screen.dart`) | First-run conversion — do new installs even make it past onboarding | P1 |
| `guest_mode_started` | Guest-browse enabled (`guestModeProvider.enable()`) | Guest vs. registered split is already a KPI in `03_funnel_metrics.md` §4 but has no explicit "chose to browse as guest" marker | P1 |
| `deep_link_opened` | `deep_link_handling_provider.dart` resolves a Universal/App Link | Attribution for shared product links / marketing campaigns (already flagged as a Phase B item in `03_funnel_metrics.md`) | P1 |

### Discovery & engagement
| Suggested event | Fired when | Why it matters | Priority |
|---|---|---|---|
| `category_viewed` | Explore category filter chip tapped, or Home category tile tapped | `search_performed` already exists for keyword search; category browse is the other half of discovery and is currently invisible | P0 |
| `search_no_results` | Explore search returns 0 results | Direct, actionable signal of catalog/inventory gaps by governorate/category — cheap to add since `search_performed` already carries `result_count` | P0 |
| `product_impression` (batched) | A product card scrolls into view on Home/Explore | Needed for a true view→cart conversion rate at the impression level, not just `view_item` (detail-page opens). **Caution:** must be batched/sampled, not per-scroll-frame, to avoid event-volume blowup — flag as a follow-up design task, not a quick add | P2 |
| `filter_applied` | Explore filter sheet "Apply" tapped | Which filters buyers actually use — informs catalog/category taxonomy priorities | P1 |
| `wishlist_viewed` | Wishlist tab opened | Engagement/retention signal already partially inferred from `screen_view`, but an explicit event is easier to build a funnel step on | P2 |

### Transaction funnel (fills real gaps in the existing funnel)
| Suggested event | Fired when | Why it matters | Priority |
|---|---|---|---|
| `remove_from_cart` | Cart item removed/quantity reduced to 0 | The funnel currently only sees additions — cart abandonment analysis needs the removal half too | P0 |
| `cart_viewed` | Cart tab opened with ≥1 item | Distinguishes "added to cart, never opened cart" from "opened cart, didn't check out" — narrows down exactly where the view→cart→checkout drop-off in `03_funnel_metrics.md` actually happens | P0 |
| `checkout_address_selected` / `checkout_address_added` | Address chosen or a new one saved during checkout | Address friction is a known COD-market drop-off point; currently invisible | P1 |
| `order_placement_failed` | `placeOrder()` fails (any reason: phone unverified, listing unavailable, network) | Every failure mode already has a mapped error code (`dio_error_mapper.dart`) — tag the failure reason as an event property; today a failed order is silent to analytics even though the user clearly intended to buy | P0 |
| `coupon_applied` / `coupon_failed` | N/A today — no live coupon mechanic exists (see the flutter-review skill's 2026-08-29 lesson: no cart-wide coupon backend) | Skip until the feature is real — listed here only so it isn't "discovered missing" later | — |

### Post-purchase & retention
| Suggested event | Fired when | Why it matters | Priority |
|---|---|---|---|
| `order_cancelled` | Consumer or vendor cancels (distinct from the existing generic `order_status_changed`) | `order_status_changed` already carries `status: cancelled`, so this can be derived from existing data in Amplitude (a saved cohort/chart on `order_status_changed` where `status = cancelled`) rather than a new event — **no code change needed**, just an Amplitude-side chart | — |
| `order_delivered` | Same reasoning — already derivable from `order_status_changed` where `status = delivered` | — | — |
| `review_submitted` | `createReviewUseCaseProvider`/`updateReviewUseCaseProvider` succeeds | Post-purchase engagement + a proxy for satisfaction; currently untracked entirely | P0 |
| `push_notification_received` / `push_notification_opened` | FCM `onMessage` fires / user taps a push (`fcm_push_navigation.dart`) | Push is a real re-engagement channel (order updates, flash sales) with zero visibility today into open rates | P1 |
| `vendor_report_submitted` | `SubmitVendorReportUseCase` succeeds (new Report Vendor feature) | Trust & safety signal — report volume by vendor is exactly the kind of thing a marketplace ops team needs a dashboard for | P1 |

### Vendor-side journey (the "other half" of the marketplace loop)
| Suggested event | Fired when | Why it matters | Priority |
|---|---|---|---|
| `vendor_onboarding_step` | Each step of `register_screen.dart`'s vendor wizard (personal → store → category → done) | `listing_published` already exists as the *outcome*; nothing captures where vendor signups drop off mid-wizard | P1 |
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

Implement the **P0** rows above first (`app_open`, `category_viewed`, `search_no_results`,
`remove_from_cart`, `cart_viewed`, `order_placement_failed`, `review_submitted`) — each is a small,
additive change to an existing provider (same shape as every event already in `event_names.dart`),
and together they close the two biggest blind spots in the current funnel: cart abandonment
(nothing today distinguishes "added then removed" from "added then bought") and checkout failure
(a failed order is currently silent). None of them require a backend change — they flow through
the exact same `AnalyticsService.track()` call already wired everywhere else.
