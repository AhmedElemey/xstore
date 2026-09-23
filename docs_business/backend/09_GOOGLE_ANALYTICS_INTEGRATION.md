# xStore — Google Analytics (GA4) Integration

**Status:** client-side implemented. All apps live in one Firebase project (`xstore-22e2f`), so
they share one GA4 property: Android dev (`com.xstore.app.dev`) and prod (`com.xstore.app`) are
separate data streams — filter by stream/app id in reports. iOS `dev` and `prod` schemes share bundle
id `com.xstore.app`, so iOS dev traffic is mixed into the prod iOS stream until a separate iOS dev
app is registered.
**Companions:** [`03_ANALYTICS_EVENTS_HANDOFF.md`](./03_ANALYTICS_EVENTS_HANDOFF.md) (xStore backend
collector) and [`08_AMPLITUDE_INTEGRATION.md`](./08_AMPLITUDE_INTEGRATION.md) (Amplitude).

## 1. What was built

`AnalyticsService` (`lib/core/analytics/analytics_service.dart`) already sends every `track()` call
to the xStore collector and to Amplitude from one choke point (`_enqueue`). GA4 is a third sink on
that same line via the official [`firebase_analytics`](https://pub.dev/packages/firebase_analytics)
plugin, so **all three destinations receive the identical event catalog** from `event_names.dart`.
No call site changed.

| | xStore collector | Amplitude | Google Analytics |
|---|---|---|---|
| Guest events | queued until login | sent immediately | sent immediately |
| Identity | `userId` per event | `user_id` per event | `setUserId` + `role` user property, set on every `bindSession` (restore / login / logout) |
| Queue / retry | ours (`_queue`) | SDK | SDK |
| `screen_view` | route listener | route listener | route listener via `logScreenView` (native auto screen reporting is **off**) |
| Revenue | `value_egp` property | `revenue` field on `purchase` | `value` + `currency` + `transaction_id` on `purchase` |

## 2. GA4 mapping rules

- Event names pass through unchanged — every catalog name is already valid for GA4 (snake_case,
  ≤ 40 chars, no `firebase_`/`google_`/`ga_` prefix). `view_item`, `add_to_cart`,
  `remove_from_cart`, `begin_checkout`, `purchase` and `app_open` match GA4 recommended names.
- `screen_view` is reserved in GA4, so it goes through `logScreenView(screenName: <route>)` with
  `referrer` as an extra parameter.
- Parameters: strings are truncated to 100 chars, booleans become `"true"`/`"false"` (GA accepts only
  string/number), nulls are dropped. `screen_name` is attached to every event, as for Amplitude.
- GA failures are swallowed — they never affect `track()`, the xStore collector, or Amplitude.

## 3. Enabling it / console checklist

1. Firebase console → Project settings → Integrations → **Google Analytics: enable** for
   `xstore-22e2f`. Then re-download `GoogleService-Info.plist` (the committed one has
   `IS_ANALYTICS_ENABLED = false`, i.e. it predates GA being enabled) and `google-services.json`,
   and replace the repo copies.
2. On a Mac, run `cd ios && pod install` on this branch and commit the updated `ios/Podfile.lock`
   (it cannot be regenerated on Linux, so it does not list `FirebaseAnalytics` yet).
3. Mark `purchase` as a key event (conversion) in GA4.
4. Register custom dimensions for the parameters you want in reports (e.g. `payment_type`,
   `seller_id`, `source`, `status`, `referrer`) and the `role` user property.
5. Verify with DebugView: Android `adb shell setprop debug.firebase.analytics.app <applicationId>`,
   iOS launch argument `-FIRDebugEnabled`.
