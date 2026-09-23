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

## 4. QA checklist — every event, one pass

Run a debug build with DebugView on (§3.5), then walk the flows below in order. For each row,
click the event in DebugView and check its parameters. Every event also carries `screen_name`
(the route it fired on). The same events should show up in Amplitude (*xStore – Dev*).

**Pass for every event:** the name appears in DebugView, the parameters match the table, no value
is empty or `null`, and no user-typed text shows up (search queries have phones/emails redacted).

### A. First launch & guest (fresh install: delete the app first)
| # | Action | Event | Parameters to check |
|---|---|---|---|
| 1 | Launch | `app_open` | — |
| 2 | Any navigation | `screen_view` | `screen_name` = route, `referrer` = previous route |
| 3 | Finish onboarding / tap Skip | `onboarding_completed` / `onboarding_skipped` | — |
| 4 | Login screen → Continue as guest | `guest_mode_started` | — |
| 5 | As guest, tap an action that needs an account (e.g. write a review) | `login_prompt_shown` | — |

### B. Discovery
| # | Action | Event | Parameters to check |
|---|---|---|---|
| 6 | Home → tap a category | `category_viewed` | `category` |
| 7 | Search something that exists | `search_performed` | `query`, `result_count` > 0 |
| 8 | Search nonsense | `search_no_results` | `query` |
| 9 | Explore → apply filters | `filter_applied` | `category_count`, `condition_count`, `has_price_range`, `shipping_only` (`"true"`/`"false"`) |
| 10 | Open a product | `view_item` | `item_id`, `category`, `seller_id`, `price_egp`, `guest` — **once** per open |
| 11 | Heart / un-heart it | `wishlist_add` / `wishlist_remove` | `item_id` |
| 12 | Product → WhatsApp seller; seller store → WhatsApp | `whatsapp_seller_tap` | `source` (`product`/`store`), `item_id` (product), `seller_id` |

### C. Auth (as the guest from A)
| # | Action | Event | Parameters to check |
|---|---|---|---|
| 13 | Register a new account | `register_success` | `method`, `role`; user property `user_id` set |
| 14 | Log out | `logout` | `role`; `user_id` cleared |
| 15 | Log in with phone, then Google / Apple | `login_success` | `method` (`otp`, `password`, `google`, `apple`, …), `role`; `user_id` + `role` user properties |

### D. Cart & checkout (signed in as a buyer)
| # | Action | Event | Parameters to check |
|---|---|---|---|
| 16 | Add to cart | `add_to_cart` | `item_id`, `quantity`, `cart_value_egp` |
| 17 | Open the cart | `screen_view` (`/cart`) + `cart_viewed` | — |
| 18 | Remove an item | `remove_from_cart` | `item_id`, `quantity`, `cart_value_egp` |
| 19 | Proceed to checkout | `begin_checkout` | `cart_value_egp`, `item_count`, `vendor_count` |
| 20 | Pick an address / add a new one | `checkout_address_selected` / `checkout_address_added` | — |
| 21 | Place a COD order | `purchase` | `order_id`, `transaction_id` (same id), `value` = `value_egp`, `currency` = `EGP`, `payment_type` = `cod`, `item_count` |
| 22 | Force a failure (airplane mode, then place order) | `order_placement_failed` | `reason` is a code (e.g. `server_error`), never a server message |

### E. After purchase (buyer)
| # | Action | Event | Parameters to check |
|---|---|---|---|
| 23 | Cancel a pending order | `order_status_changed` | `order_id`, `status` = `cancelled`, `role` = `consumer` |
| 24 | Review a delivered order / product | `review_submitted` | `item_id`, `rating` (number) |
| 25 | Order detail → report vendor | `vendor_report_submitted` | `seller_id`, `order_id` |

### F. Vendor account
| # | Action | Event | Parameters to check |
|---|---|---|---|
| 26 | Go through vendor onboarding | `vendor_onboarding_step` | `step` |
| 27 | Publish a listing / edit it | `listing_published` / `listing_updated` | `item_id`, `category`, `price_egp` |
| 28 | Pause/activate, resubmit, delete a listing | `listing_status_changed` / `listing_resubmitted` / `listing_deleted` | `item_id`, `status` / `price_egp` |
| 29 | Confirm → process → ship → deliver an order; reject one | `order_status_changed` (one per step) | `order_id`, `status`, `role` = `vendor`, `method` on confirm |

### G. Entry points (need a push / link sent to the device)
| # | Action | Event | Parameters to check |
|---|---|---|---|
| 30 | Send a push from Firebase Messaging while the app is open | `push_notification_received` | `message_id` |
| 31 | Tap the push | `push_notification_opened` | `message_id`, `screen_name` = target route |
| 32 | Open `https://xstore.com/product/<id>` (Android: `adb shell am start -a android.intent.action.VIEW -d <url>`) | `deep_link_opened` | `screen_name` = `/product/<id>` |

Row 32 needs the app-link domain verified (see `docs_business/launch_todos/07_deep_linking.md`);
on an unverified build the link opens in the browser and no event fires, which is expected.

**Should NOT appear:** `screen_view` named `MainActivity` / `FlutterViewController` (auto screen
reporting is off), duplicate `view_item` for a single product open, or `user_id` after logout.
